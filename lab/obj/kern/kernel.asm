
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
f0100048:	83 3d 80 fe 20 f0 00 	cmpl   $0x0,0xf020fe80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 fe 20 f0    	mov    %esi,0xf020fe80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 85 5b 00 00       	call   f0105be6 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 80 62 10 f0       	push   $0xf0106280
f010006d:	e8 fa 37 00 00       	call   f010386c <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 ca 37 00 00       	call   f0103846 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 60 6b 10 f0 	movl   $0xf0106b60,(%esp)
f0100083:	e8 e4 37 00 00       	call   f010386c <cprintf>
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
f01000ae:	68 ec 62 10 f0       	push   $0xf01062ec
f01000b3:	e8 b4 37 00 00       	call   f010386c <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000b8:	e8 f9 13 00 00       	call   f01014b6 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000bd:	e8 2d 30 00 00       	call   f01030ef <env_init>
	trap_init();
f01000c2:	e8 98 38 00 00       	call   f010395f <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000c7:	e8 10 58 00 00       	call   f01058dc <mp_init>
	lapic_init();
f01000cc:	e8 30 5b 00 00       	call   f0105c01 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 bd 36 00 00       	call   f0103793 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000d6:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000dd:	e8 72 5d 00 00       	call   f0105e54 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e2:	83 c4 10             	add    $0x10,%esp
f01000e5:	83 3d 88 fe 20 f0 07 	cmpl   $0x7,0xf020fe88
f01000ec:	77 16                	ja     f0100104 <i386_init+0x6a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000ee:	68 00 70 00 00       	push   $0x7000
f01000f3:	68 a4 62 10 f0       	push   $0xf01062a4
f01000f8:	6a 55                	push   $0x55
f01000fa:	68 07 63 10 f0       	push   $0xf0106307
f01000ff:	e8 3c ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100104:	83 ec 04             	sub    $0x4,%esp
f0100107:	b8 42 58 10 f0       	mov    $0xf0105842,%eax
f010010c:	2d c8 57 10 f0       	sub    $0xf01057c8,%eax
f0100111:	50                   	push   %eax
f0100112:	68 c8 57 10 f0       	push   $0xf01057c8
f0100117:	68 00 70 00 f0       	push   $0xf0007000
f010011c:	e8 f2 54 00 00       	call   f0105613 <memmove>
f0100121:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100124:	bb 20 00 21 f0       	mov    $0xf0210020,%ebx
f0100129:	eb 4d                	jmp    f0100178 <i386_init+0xde>
		if (c == cpus + cpunum())  // We've started already.
f010012b:	e8 b6 5a 00 00       	call   f0105be6 <cpunum>
f0100130:	6b c0 74             	imul   $0x74,%eax,%eax
f0100133:	05 20 00 21 f0       	add    $0xf0210020,%eax
f0100138:	39 c3                	cmp    %eax,%ebx
f010013a:	74 39                	je     f0100175 <i386_init+0xdb>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010013c:	89 d8                	mov    %ebx,%eax
f010013e:	2d 20 00 21 f0       	sub    $0xf0210020,%eax
f0100143:	c1 f8 02             	sar    $0x2,%eax
f0100146:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010014c:	c1 e0 0f             	shl    $0xf,%eax
f010014f:	05 00 90 21 f0       	add    $0xf0219000,%eax
f0100154:	a3 84 fe 20 f0       	mov    %eax,0xf020fe84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100159:	83 ec 08             	sub    $0x8,%esp
f010015c:	68 00 70 00 00       	push   $0x7000
f0100161:	0f b6 03             	movzbl (%ebx),%eax
f0100164:	50                   	push   %eax
f0100165:	e8 e5 5b 00 00       	call   f0105d4f <lapic_startap>
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
f0100178:	6b 05 c4 03 21 f0 74 	imul   $0x74,0xf02103c4,%eax
f010017f:	05 20 00 21 f0       	add    $0xf0210020,%eax
f0100184:	39 c3                	cmp    %eax,%ebx
f0100186:	72 a3                	jb     f010012b <i386_init+0x91>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100188:	83 ec 08             	sub    $0x8,%esp
f010018b:	6a 01                	push   $0x1
f010018d:	68 08 0c 1d f0       	push   $0xf01d0c08
f0100192:	e8 eb 30 00 00       	call   f0103282 <env_create>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
f0100197:	83 c4 08             	add    $0x8,%esp
f010019a:	6a 00                	push   $0x0
f010019c:	68 ec 98 16 f0       	push   $0xf01698ec
f01001a1:	e8 dc 30 00 00       	call   f0103282 <env_create>
	// ENV_CREATE(user_icode, ENV_TYPE_USER);
	// ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001a6:	e8 35 04 00 00       	call   f01005e0 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001ab:	e8 c2 42 00 00       	call   f0104472 <sched_yield>

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
f01001b6:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c0:	77 12                	ja     f01001d4 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c2:	50                   	push   %eax
f01001c3:	68 c8 62 10 f0       	push   $0xf01062c8
f01001c8:	6a 6c                	push   $0x6c
f01001ca:	68 07 63 10 f0       	push   $0xf0106307
f01001cf:	e8 6c fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001d4:	05 00 00 00 10       	add    $0x10000000,%eax
f01001d9:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001dc:	e8 05 5a 00 00       	call   f0105be6 <cpunum>
f01001e1:	83 ec 08             	sub    $0x8,%esp
f01001e4:	50                   	push   %eax
f01001e5:	68 13 63 10 f0       	push   $0xf0106313
f01001ea:	e8 7d 36 00 00       	call   f010386c <cprintf>

	lapic_init();
f01001ef:	e8 0d 5a 00 00       	call   f0105c01 <lapic_init>
	env_init_percpu();
f01001f4:	e8 c6 2e 00 00       	call   f01030bf <env_init_percpu>
	trap_init_percpu();
f01001f9:	e8 82 36 00 00       	call   f0103880 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001fe:	e8 e3 59 00 00       	call   f0105be6 <cpunum>
f0100203:	6b d0 74             	imul   $0x74,%eax,%edx
f0100206:	81 c2 20 00 21 f0    	add    $0xf0210020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010020c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100211:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100215:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f010021c:	e8 33 5c 00 00       	call   f0105e54 <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:

	lock_kernel();
	sched_yield();
f0100221:	e8 4c 42 00 00       	call   f0104472 <sched_yield>

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
f0100236:	68 29 63 10 f0       	push   $0xf0106329
f010023b:	e8 2c 36 00 00       	call   f010386c <cprintf>
	vcprintf(fmt, ap);
f0100240:	83 c4 08             	add    $0x8,%esp
f0100243:	53                   	push   %ebx
f0100244:	ff 75 10             	pushl  0x10(%ebp)
f0100247:	e8 fa 35 00 00       	call   f0103846 <vcprintf>
	cprintf("\n");
f010024c:	c7 04 24 60 6b 10 f0 	movl   $0xf0106b60,(%esp)
f0100253:	e8 14 36 00 00       	call   f010386c <cprintf>
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
f010028e:	8b 0d 24 f2 20 f0    	mov    0xf020f224,%ecx
f0100294:	8d 51 01             	lea    0x1(%ecx),%edx
f0100297:	89 15 24 f2 20 f0    	mov    %edx,0xf020f224
f010029d:	88 81 20 f0 20 f0    	mov    %al,-0xfdf0fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a3:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002a9:	75 0a                	jne    f01002b5 <cons_intr+0x36>
			cons.wpos = 0;
f01002ab:	c7 05 24 f2 20 f0 00 	movl   $0x0,0xf020f224
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
f01002e4:	83 0d 00 f0 20 f0 40 	orl    $0x40,0xf020f000
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
f01002fc:	8b 0d 00 f0 20 f0    	mov    0xf020f000,%ecx
f0100302:	89 cb                	mov    %ecx,%ebx
f0100304:	83 e3 40             	and    $0x40,%ebx
f0100307:	83 e0 7f             	and    $0x7f,%eax
f010030a:	85 db                	test   %ebx,%ebx
f010030c:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010030f:	0f b6 d2             	movzbl %dl,%edx
f0100312:	0f b6 82 a0 64 10 f0 	movzbl -0xfef9b60(%edx),%eax
f0100319:	83 c8 40             	or     $0x40,%eax
f010031c:	0f b6 c0             	movzbl %al,%eax
f010031f:	f7 d0                	not    %eax
f0100321:	21 c8                	and    %ecx,%eax
f0100323:	a3 00 f0 20 f0       	mov    %eax,0xf020f000
		return 0;
f0100328:	b8 00 00 00 00       	mov    $0x0,%eax
f010032d:	e9 a4 00 00 00       	jmp    f01003d6 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100332:	8b 0d 00 f0 20 f0    	mov    0xf020f000,%ecx
f0100338:	f6 c1 40             	test   $0x40,%cl
f010033b:	74 0e                	je     f010034b <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010033d:	83 c8 80             	or     $0xffffff80,%eax
f0100340:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100342:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100345:	89 0d 00 f0 20 f0    	mov    %ecx,0xf020f000
	}

	shift |= shiftcode[data];
f010034b:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010034e:	0f b6 82 a0 64 10 f0 	movzbl -0xfef9b60(%edx),%eax
f0100355:	0b 05 00 f0 20 f0    	or     0xf020f000,%eax
f010035b:	0f b6 8a a0 63 10 f0 	movzbl -0xfef9c60(%edx),%ecx
f0100362:	31 c8                	xor    %ecx,%eax
f0100364:	a3 00 f0 20 f0       	mov    %eax,0xf020f000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100369:	89 c1                	mov    %eax,%ecx
f010036b:	83 e1 03             	and    $0x3,%ecx
f010036e:	8b 0c 8d 80 63 10 f0 	mov    -0xfef9c80(,%ecx,4),%ecx
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
f01003ac:	68 43 63 10 f0       	push   $0xf0106343
f01003b1:	e8 b6 34 00 00       	call   f010386c <cprintf>
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
f0100498:	0f b7 05 28 f2 20 f0 	movzwl 0xf020f228,%eax
f010049f:	66 85 c0             	test   %ax,%ax
f01004a2:	0f 84 e6 00 00 00    	je     f010058e <cons_putc+0x1b3>
			crt_pos--;
f01004a8:	83 e8 01             	sub    $0x1,%eax
f01004ab:	66 a3 28 f2 20 f0    	mov    %ax,0xf020f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004b1:	0f b7 c0             	movzwl %ax,%eax
f01004b4:	66 81 e7 00 ff       	and    $0xff00,%di
f01004b9:	83 cf 20             	or     $0x20,%edi
f01004bc:	8b 15 2c f2 20 f0    	mov    0xf020f22c,%edx
f01004c2:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c6:	eb 78                	jmp    f0100540 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004c8:	66 83 05 28 f2 20 f0 	addw   $0x50,0xf020f228
f01004cf:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004d0:	0f b7 05 28 f2 20 f0 	movzwl 0xf020f228,%eax
f01004d7:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004dd:	c1 e8 16             	shr    $0x16,%eax
f01004e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004e3:	c1 e0 04             	shl    $0x4,%eax
f01004e6:	66 a3 28 f2 20 f0    	mov    %ax,0xf020f228
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
f0100522:	0f b7 05 28 f2 20 f0 	movzwl 0xf020f228,%eax
f0100529:	8d 50 01             	lea    0x1(%eax),%edx
f010052c:	66 89 15 28 f2 20 f0 	mov    %dx,0xf020f228
f0100533:	0f b7 c0             	movzwl %ax,%eax
f0100536:	8b 15 2c f2 20 f0    	mov    0xf020f22c,%edx
f010053c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100540:	66 81 3d 28 f2 20 f0 	cmpw   $0x7cf,0xf020f228
f0100547:	cf 07 
f0100549:	76 43                	jbe    f010058e <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010054b:	a1 2c f2 20 f0       	mov    0xf020f22c,%eax
f0100550:	83 ec 04             	sub    $0x4,%esp
f0100553:	68 00 0f 00 00       	push   $0xf00
f0100558:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010055e:	52                   	push   %edx
f010055f:	50                   	push   %eax
f0100560:	e8 ae 50 00 00       	call   f0105613 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100565:	8b 15 2c f2 20 f0    	mov    0xf020f22c,%edx
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
f0100586:	66 83 2d 28 f2 20 f0 	subw   $0x50,0xf020f228
f010058d:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010058e:	8b 0d 30 f2 20 f0    	mov    0xf020f230,%ecx
f0100594:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100599:	89 ca                	mov    %ecx,%edx
f010059b:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010059c:	0f b7 1d 28 f2 20 f0 	movzwl 0xf020f228,%ebx
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
f01005c4:	80 3d 34 f2 20 f0 00 	cmpb   $0x0,0xf020f234
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
f0100602:	a1 20 f2 20 f0       	mov    0xf020f220,%eax
f0100607:	3b 05 24 f2 20 f0    	cmp    0xf020f224,%eax
f010060d:	74 26                	je     f0100635 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010060f:	8d 50 01             	lea    0x1(%eax),%edx
f0100612:	89 15 20 f2 20 f0    	mov    %edx,0xf020f220
f0100618:	0f b6 88 20 f0 20 f0 	movzbl -0xfdf0fe0(%eax),%ecx
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
f0100629:	c7 05 20 f2 20 f0 00 	movl   $0x0,0xf020f220
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
f0100662:	c7 05 30 f2 20 f0 b4 	movl   $0x3b4,0xf020f230
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
f010067a:	c7 05 30 f2 20 f0 d4 	movl   $0x3d4,0xf020f230
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
f0100689:	8b 3d 30 f2 20 f0    	mov    0xf020f230,%edi
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
f01006ae:	89 35 2c f2 20 f0    	mov    %esi,0xf020f22c
	crt_pos = pos;
f01006b4:	0f b6 c0             	movzbl %al,%eax
f01006b7:	09 c8                	or     %ecx,%eax
f01006b9:	66 a3 28 f2 20 f0    	mov    %ax,0xf020f228

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
f01006d4:	e8 42 30 00 00       	call   f010371b <irq_setmask_8259A>
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
f0100737:	0f 95 05 34 f2 20 f0 	setne  0xf020f234
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
f0100759:	e8 bd 2f 00 00       	call   f010371b <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010075e:	83 c4 10             	add    $0x10,%esp
f0100761:	80 3d 34 f2 20 f0 00 	cmpb   $0x0,0xf020f234
f0100768:	75 10                	jne    f010077a <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f010076a:	83 ec 0c             	sub    $0xc,%esp
f010076d:	68 4f 63 10 f0       	push   $0xf010634f
f0100772:	e8 f5 30 00 00       	call   f010386c <cprintf>
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
f01007b3:	68 a0 65 10 f0       	push   $0xf01065a0
f01007b8:	68 be 65 10 f0       	push   $0xf01065be
f01007bd:	68 c3 65 10 f0       	push   $0xf01065c3
f01007c2:	e8 a5 30 00 00       	call   f010386c <cprintf>
f01007c7:	83 c4 0c             	add    $0xc,%esp
f01007ca:	68 7c 66 10 f0       	push   $0xf010667c
f01007cf:	68 cc 65 10 f0       	push   $0xf01065cc
f01007d4:	68 c3 65 10 f0       	push   $0xf01065c3
f01007d9:	e8 8e 30 00 00       	call   f010386c <cprintf>
f01007de:	83 c4 0c             	add    $0xc,%esp
f01007e1:	68 d5 65 10 f0       	push   $0xf01065d5
f01007e6:	68 f3 65 10 f0       	push   $0xf01065f3
f01007eb:	68 c3 65 10 f0       	push   $0xf01065c3
f01007f0:	e8 77 30 00 00       	call   f010386c <cprintf>
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
f0100802:	68 fd 65 10 f0       	push   $0xf01065fd
f0100807:	e8 60 30 00 00       	call   f010386c <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010080c:	83 c4 08             	add    $0x8,%esp
f010080f:	68 0c 00 10 00       	push   $0x10000c
f0100814:	68 a4 66 10 f0       	push   $0xf01066a4
f0100819:	e8 4e 30 00 00       	call   f010386c <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010081e:	83 c4 0c             	add    $0xc,%esp
f0100821:	68 0c 00 10 00       	push   $0x10000c
f0100826:	68 0c 00 10 f0       	push   $0xf010000c
f010082b:	68 cc 66 10 f0       	push   $0xf01066cc
f0100830:	e8 37 30 00 00       	call   f010386c <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	68 61 62 10 00       	push   $0x106261
f010083d:	68 61 62 10 f0       	push   $0xf0106261
f0100842:	68 f0 66 10 f0       	push   $0xf01066f0
f0100847:	e8 20 30 00 00       	call   f010386c <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084c:	83 c4 0c             	add    $0xc,%esp
f010084f:	68 00 f0 20 00       	push   $0x20f000
f0100854:	68 00 f0 20 f0       	push   $0xf020f000
f0100859:	68 14 67 10 f0       	push   $0xf0106714
f010085e:	e8 09 30 00 00       	call   f010386c <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100863:	83 c4 0c             	add    $0xc,%esp
f0100866:	68 08 10 25 00       	push   $0x251008
f010086b:	68 08 10 25 f0       	push   $0xf0251008
f0100870:	68 38 67 10 f0       	push   $0xf0106738
f0100875:	e8 f2 2f 00 00       	call   f010386c <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010087a:	b8 07 14 25 f0       	mov    $0xf0251407,%eax
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
f010089b:	68 5c 67 10 f0       	push   $0xf010675c
f01008a0:	e8 c7 2f 00 00       	call   f010386c <cprintf>
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
f01008da:	68 16 66 10 f0       	push   $0xf0106616
f01008df:	e8 88 2f 00 00       	call   f010386c <cprintf>

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
f010090c:	e8 23 42 00 00       	call   f0104b34 <debuginfo_eip>

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
f0100968:	68 88 67 10 f0       	push   $0xf0106788
f010096d:	e8 fa 2e 00 00       	call   f010386c <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f0100972:	83 c4 14             	add    $0x14,%esp
f0100975:	2b 75 cc             	sub    -0x34(%ebp),%esi
f0100978:	56                   	push   %esi
f0100979:	8d 45 8a             	lea    -0x76(%ebp),%eax
f010097c:	50                   	push   %eax
f010097d:	ff 75 c0             	pushl  -0x40(%ebp)
f0100980:	ff 75 bc             	pushl  -0x44(%ebp)
f0100983:	68 28 66 10 f0       	push   $0xf0106628
f0100988:	e8 df 2e 00 00       	call   f010386c <cprintf>

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
f01009b0:	68 c0 67 10 f0       	push   $0xf01067c0
f01009b5:	e8 b2 2e 00 00       	call   f010386c <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009ba:	c7 04 24 e4 67 10 f0 	movl   $0xf01067e4,(%esp)
f01009c1:	e8 a6 2e 00 00       	call   f010386c <cprintf>

	if (tf != NULL)
f01009c6:	83 c4 10             	add    $0x10,%esp
f01009c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009cd:	74 0e                	je     f01009dd <monitor+0x36>
		print_trapframe(tf);
f01009cf:	83 ec 0c             	sub    $0xc,%esp
f01009d2:	ff 75 08             	pushl  0x8(%ebp)
f01009d5:	e8 53 34 00 00       	call   f0103e2d <print_trapframe>
f01009da:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009dd:	83 ec 0c             	sub    $0xc,%esp
f01009e0:	68 3f 66 10 f0       	push   $0xf010663f
f01009e5:	e8 6d 49 00 00       	call   f0105357 <readline>
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
f0100a19:	68 43 66 10 f0       	push   $0xf0106643
f0100a1e:	e8 66 4b 00 00       	call   f0105589 <strchr>
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
f0100a39:	68 48 66 10 f0       	push   $0xf0106648
f0100a3e:	e8 29 2e 00 00       	call   f010386c <cprintf>
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
f0100a62:	68 43 66 10 f0       	push   $0xf0106643
f0100a67:	e8 1d 4b 00 00       	call   f0105589 <strchr>
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
f0100a90:	ff 34 85 20 68 10 f0 	pushl  -0xfef97e0(,%eax,4)
f0100a97:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a9a:	e8 8c 4a 00 00       	call   f010552b <strcmp>
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
f0100ab4:	ff 14 85 28 68 10 f0 	call   *-0xfef97d8(,%eax,4)
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
f0100ad5:	68 65 66 10 f0       	push   $0xf0106665
f0100ada:	e8 8d 2d 00 00       	call   f010386c <cprintf>
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
f0100afa:	e8 ee 2b 00 00       	call   f01036ed <mc146818_read>
f0100aff:	89 c6                	mov    %eax,%esi
f0100b01:	83 c3 01             	add    $0x1,%ebx
f0100b04:	89 1c 24             	mov    %ebx,(%esp)
f0100b07:	e8 e1 2b 00 00       	call   f01036ed <mc146818_read>
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
f0100b18:	83 3d 38 f2 20 f0 00 	cmpl   $0x0,0xf020f238
f0100b1f:	75 11                	jne    f0100b32 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b21:	ba 07 20 25 f0       	mov    $0xf0252007,%edx
f0100b26:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b2c:	89 15 38 f2 20 f0    	mov    %edx,0xf020f238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f0100b32:	8b 15 38 f2 20 f0    	mov    0xf020f238,%edx
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
f0100b46:	68 44 68 10 f0       	push   $0xf0106844
f0100b4b:	6a 70                	push   $0x70
f0100b4d:	68 5f 68 10 f0       	push   $0xf010685f
f0100b52:	e8 e9 f4 ff ff       	call   f0100040 <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f0100b57:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b63:	a3 38 f2 20 f0       	mov    %eax,0xf020f238

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
f0100b81:	3b 0d 88 fe 20 f0    	cmp    0xf020fe88,%ecx
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
f0100b90:	68 a4 62 10 f0       	push   $0xf01062a4
f0100b95:	68 2d 04 00 00       	push   $0x42d
f0100b9a:	68 5f 68 10 f0       	push   $0xf010685f
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
f0100be8:	68 94 6b 10 f0       	push   $0xf0106b94
f0100bed:	68 5e 03 00 00       	push   $0x35e
f0100bf2:	68 5f 68 10 f0       	push   $0xf010685f
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
f0100c0a:	2b 15 90 fe 20 f0    	sub    0xf020fe90,%edx
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
f0100c40:	a3 40 f2 20 f0       	mov    %eax,0xf020f240
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
f0100c4a:	8b 1d 40 f2 20 f0    	mov    0xf020f240,%ebx
f0100c50:	eb 53                	jmp    f0100ca5 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c52:	89 d8                	mov    %ebx,%eax
f0100c54:	2b 05 90 fe 20 f0    	sub    0xf020fe90,%eax
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
f0100c6e:	3b 15 88 fe 20 f0    	cmp    0xf020fe88,%edx
f0100c74:	72 12                	jb     f0100c88 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c76:	50                   	push   %eax
f0100c77:	68 a4 62 10 f0       	push   $0xf01062a4
f0100c7c:	6a 58                	push   $0x58
f0100c7e:	68 6b 68 10 f0       	push   $0xf010686b
f0100c83:	e8 b8 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c88:	83 ec 04             	sub    $0x4,%esp
f0100c8b:	68 80 00 00 00       	push   $0x80
f0100c90:	68 97 00 00 00       	push   $0x97
f0100c95:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c9a:	50                   	push   %eax
f0100c9b:	e8 26 49 00 00       	call   f01055c6 <memset>
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
f0100cb6:	8b 15 40 f2 20 f0    	mov    0xf020f240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cbc:	8b 0d 90 fe 20 f0    	mov    0xf020fe90,%ecx
		assert(pp < pages + npages);
f0100cc2:	a1 88 fe 20 f0       	mov    0xf020fe88,%eax
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
f0100ce1:	68 79 68 10 f0       	push   $0xf0106879
f0100ce6:	68 85 68 10 f0       	push   $0xf0106885
f0100ceb:	68 78 03 00 00       	push   $0x378
f0100cf0:	68 5f 68 10 f0       	push   $0xf010685f
f0100cf5:	e8 46 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cfa:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cfd:	72 19                	jb     f0100d18 <check_page_free_list+0x149>
f0100cff:	68 9a 68 10 f0       	push   $0xf010689a
f0100d04:	68 85 68 10 f0       	push   $0xf0106885
f0100d09:	68 79 03 00 00       	push   $0x379
f0100d0e:	68 5f 68 10 f0       	push   $0xf010685f
f0100d13:	e8 28 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d18:	89 d0                	mov    %edx,%eax
f0100d1a:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d1d:	a8 07                	test   $0x7,%al
f0100d1f:	74 19                	je     f0100d3a <check_page_free_list+0x16b>
f0100d21:	68 b8 6b 10 f0       	push   $0xf0106bb8
f0100d26:	68 85 68 10 f0       	push   $0xf0106885
f0100d2b:	68 7a 03 00 00       	push   $0x37a
f0100d30:	68 5f 68 10 f0       	push   $0xf010685f
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
f0100d44:	68 ae 68 10 f0       	push   $0xf01068ae
f0100d49:	68 85 68 10 f0       	push   $0xf0106885
f0100d4e:	68 7d 03 00 00       	push   $0x37d
f0100d53:	68 5f 68 10 f0       	push   $0xf010685f
f0100d58:	e8 e3 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d5d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d62:	75 19                	jne    f0100d7d <check_page_free_list+0x1ae>
f0100d64:	68 bf 68 10 f0       	push   $0xf01068bf
f0100d69:	68 85 68 10 f0       	push   $0xf0106885
f0100d6e:	68 7e 03 00 00       	push   $0x37e
f0100d73:	68 5f 68 10 f0       	push   $0xf010685f
f0100d78:	e8 c3 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d7d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d82:	75 19                	jne    f0100d9d <check_page_free_list+0x1ce>
f0100d84:	68 ec 6b 10 f0       	push   $0xf0106bec
f0100d89:	68 85 68 10 f0       	push   $0xf0106885
f0100d8e:	68 7f 03 00 00       	push   $0x37f
f0100d93:	68 5f 68 10 f0       	push   $0xf010685f
f0100d98:	e8 a3 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d9d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100da2:	75 19                	jne    f0100dbd <check_page_free_list+0x1ee>
f0100da4:	68 d8 68 10 f0       	push   $0xf01068d8
f0100da9:	68 85 68 10 f0       	push   $0xf0106885
f0100dae:	68 80 03 00 00       	push   $0x380
f0100db3:	68 5f 68 10 f0       	push   $0xf010685f
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
f0100dd3:	68 a4 62 10 f0       	push   $0xf01062a4
f0100dd8:	6a 58                	push   $0x58
f0100dda:	68 6b 68 10 f0       	push   $0xf010686b
f0100ddf:	e8 5c f2 ff ff       	call   f0100040 <_panic>
f0100de4:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100dea:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100ded:	0f 86 b6 00 00 00    	jbe    f0100ea9 <check_page_free_list+0x2da>
f0100df3:	68 10 6c 10 f0       	push   $0xf0106c10
f0100df8:	68 85 68 10 f0       	push   $0xf0106885
f0100dfd:	68 81 03 00 00       	push   $0x381
f0100e02:	68 5f 68 10 f0       	push   $0xf010685f
f0100e07:	e8 34 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e0c:	68 f2 68 10 f0       	push   $0xf01068f2
f0100e11:	68 85 68 10 f0       	push   $0xf0106885
f0100e16:	68 83 03 00 00       	push   $0x383
f0100e1b:	68 5f 68 10 f0       	push   $0xf010685f
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
f0100e3b:	68 0f 69 10 f0       	push   $0xf010690f
f0100e40:	68 85 68 10 f0       	push   $0xf0106885
f0100e45:	68 8b 03 00 00       	push   $0x38b
f0100e4a:	68 5f 68 10 f0       	push   $0xf010685f
f0100e4f:	e8 ec f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e54:	85 db                	test   %ebx,%ebx
f0100e56:	7f 19                	jg     f0100e71 <check_page_free_list+0x2a2>
f0100e58:	68 21 69 10 f0       	push   $0xf0106921
f0100e5d:	68 85 68 10 f0       	push   $0xf0106885
f0100e62:	68 8c 03 00 00       	push   $0x38c
f0100e67:	68 5f 68 10 f0       	push   $0xf010685f
f0100e6c:	e8 cf f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e71:	83 ec 0c             	sub    $0xc,%esp
f0100e74:	68 58 6c 10 f0       	push   $0xf0106c58
f0100e79:	e8 ee 29 00 00       	call   f010386c <cprintf>
}
f0100e7e:	eb 49                	jmp    f0100ec9 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e80:	a1 40 f2 20 f0       	mov    0xf020f240,%eax
f0100e85:	85 c0                	test   %eax,%eax
f0100e87:	0f 85 6f fd ff ff    	jne    f0100bfc <check_page_free_list+0x2d>
f0100e8d:	e9 53 fd ff ff       	jmp    f0100be5 <check_page_free_list+0x16>
f0100e92:	83 3d 40 f2 20 f0 00 	cmpl   $0x0,0xf020f240
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
f0100ed6:	a1 90 fe 20 f0       	mov    0xf020fe90,%eax
f0100edb:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100ee1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
f0100ee7:	be 41 68 10 f0       	mov    $0xf0106841,%esi
f0100eec:	81 ee c8 57 10 f0    	sub    $0xf01057c8,%esi
f0100ef2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	cprintf("[?] %x\n", size);
f0100ef8:	83 ec 08             	sub    $0x8,%esp
f0100efb:	56                   	push   %esi
f0100efc:	68 32 69 10 f0       	push   $0xf0106932
f0100f01:	e8 66 29 00 00       	call   f010386c <cprintf>

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f06:	83 c4 10             	add    $0x10,%esp
f0100f09:	bb 01 00 00 00       	mov    $0x1,%ebx
		if (i * PGSIZE >= MPENTRY_PADDR && i * PGSIZE < MPENTRY_PADDR + size) {
f0100f0e:	81 c6 00 70 00 00    	add    $0x7000,%esi
	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
	cprintf("[?] %x\n", size);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f14:	eb 61                	jmp    f0100f77 <page_init+0xa6>
f0100f16:	89 d8                	mov    %ebx,%eax
f0100f18:	c1 e0 0c             	shl    $0xc,%eax
		if (i * PGSIZE >= MPENTRY_PADDR && i * PGSIZE < MPENTRY_PADDR + size) {
f0100f1b:	3d ff 6f 00 00       	cmp    $0x6fff,%eax
f0100f20:	76 2a                	jbe    f0100f4c <page_init+0x7b>
f0100f22:	39 c6                	cmp    %eax,%esi
f0100f24:	76 26                	jbe    f0100f4c <page_init+0x7b>
			pages[i].pp_ref = 1;
f0100f26:	a1 90 fe 20 f0       	mov    0xf020fe90,%eax
f0100f2b:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100f2e:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = 0;
f0100f34:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			cprintf("[?] non-boot CPUs (APs)\n");
f0100f3a:	83 ec 0c             	sub    $0xc,%esp
f0100f3d:	68 3a 69 10 f0       	push   $0xf010693a
f0100f42:	e8 25 29 00 00       	call   f010386c <cprintf>
f0100f47:	83 c4 10             	add    $0x10,%esp
f0100f4a:	eb 28                	jmp    f0100f74 <page_init+0xa3>
		}
		else {
			pages[i].pp_ref = 0;
f0100f4c:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f53:	89 c2                	mov    %eax,%edx
f0100f55:	03 15 90 fe 20 f0    	add    0xf020fe90,%edx
f0100f5b:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100f61:	8b 0d 40 f2 20 f0    	mov    0xf020f240,%ecx
f0100f67:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100f69:	03 05 90 fe 20 f0    	add    0xf020fe90,%eax
f0100f6f:	a3 40 f2 20 f0       	mov    %eax,0xf020f240
	extern unsigned char mpentry_start[], mpentry_end[];
	uint32_t size = ROUNDUP(mpentry_end - mpentry_start, PGSIZE);
	cprintf("[?] %x\n", size);

	// 2)	[1-npages_basemem) free, except APs area (lab4)
	for (i = 1; i < npages_basemem; i++) {
f0100f74:	83 c3 01             	add    $0x1,%ebx
f0100f77:	3b 1d 44 f2 20 f0    	cmp    0xf020f244,%ebx
f0100f7d:	72 97                	jb     f0100f16 <page_init+0x45>
f0100f7f:	8b 0d 40 f2 20 f0    	mov    0xf020f240,%ecx
f0100f85:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100f8c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f91:	eb 23                	jmp    f0100fb6 <page_init+0xe5>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100f93:	89 c2                	mov    %eax,%edx
f0100f95:	03 15 90 fe 20 f0    	add    0xf020fe90,%edx
f0100f9b:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100fa1:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100fa3:	89 c1                	mov    %eax,%ecx
f0100fa5:	03 0d 90 fe 20 f0    	add    0xf020fe90,%ecx
		}
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
f0100fab:	83 c3 01             	add    $0x1,%ebx
f0100fae:	83 c0 08             	add    $0x8,%eax
f0100fb1:	ba 01 00 00 00       	mov    $0x1,%edx
f0100fb6:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100fbc:	76 d5                	jbe    f0100f93 <page_init+0xc2>
f0100fbe:	84 d2                	test   %dl,%dl
f0100fc0:	74 06                	je     f0100fc8 <page_init+0xf7>
f0100fc2:	89 0d 40 f2 20 f0    	mov    %ecx,0xf020f240
f0100fc8:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100fcf:	eb 1a                	jmp    f0100feb <page_init+0x11a>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100fd1:	89 c2                	mov    %eax,%edx
f0100fd3:	03 15 90 fe 20 f0    	add    0xf020fe90,%edx
f0100fd9:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = 0;
f0100fdf:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
f0100fe5:	83 c3 01             	add    $0x1,%ebx
f0100fe8:	83 c0 08             	add    $0x8,%eax
f0100feb:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100ff1:	76 de                	jbe    f0100fd1 <page_init+0x100>
f0100ff3:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f0100ffa:	eb 1a                	jmp    f0101016 <page_init+0x145>


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100ffc:	89 f0                	mov    %esi,%eax
f0100ffe:	03 05 90 fe 20 f0    	add    0xf020fe90,%eax
f0101004:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = 0;
f010100a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
f0101010:	83 c3 01             	add    $0x1,%ebx
f0101013:	83 c6 08             	add    $0x8,%esi
f0101016:	b8 00 00 00 00       	mov    $0x0,%eax
f010101b:	e8 f8 fa ff ff       	call   f0100b18 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101020:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101025:	77 15                	ja     f010103c <page_init+0x16b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101027:	50                   	push   %eax
f0101028:	68 c8 62 10 f0       	push   $0xf01062c8
f010102d:	68 7d 01 00 00       	push   $0x17d
f0101032:	68 5f 68 10 f0       	push   $0xf010685f
f0101037:	e8 04 f0 ff ff       	call   f0100040 <_panic>
f010103c:	05 00 00 00 10       	add    $0x10000000,%eax
f0101041:	c1 e8 0c             	shr    $0xc,%eax
f0101044:	39 c3                	cmp    %eax,%ebx
f0101046:	72 b4                	jb     f0100ffc <page_init+0x12b>
f0101048:	8b 0d 40 f2 20 f0    	mov    0xf020f240,%ecx
f010104e:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0101055:	ba 00 00 00 00       	mov    $0x0,%edx
f010105a:	eb 23                	jmp    f010107f <page_init+0x1ae>
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f010105c:	89 c2                	mov    %eax,%edx
f010105e:	03 15 90 fe 20 f0    	add    0xf020fe90,%edx
f0101064:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f010106a:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f010106c:	89 c1                	mov    %eax,%ecx
f010106e:	03 0d 90 fe 20 f0    	add    0xf020fe90,%ecx
		pages[i].pp_link = 0;
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
f0101074:	83 c3 01             	add    $0x1,%ebx
f0101077:	83 c0 08             	add    $0x8,%eax
f010107a:	ba 01 00 00 00       	mov    $0x1,%edx
f010107f:	3b 1d 88 fe 20 f0    	cmp    0xf020fe88,%ebx
f0101085:	72 d5                	jb     f010105c <page_init+0x18b>
f0101087:	84 d2                	test   %dl,%dl
f0101089:	74 06                	je     f0101091 <page_init+0x1c0>
f010108b:	89 0d 40 f2 20 f0    	mov    %ecx,0xf020f240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

}
f0101091:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101094:	5b                   	pop    %ebx
f0101095:	5e                   	pop    %esi
f0101096:	5d                   	pop    %ebp
f0101097:	c3                   	ret    

f0101098 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101098:	55                   	push   %ebp
f0101099:	89 e5                	mov    %esp,%ebp
f010109b:	56                   	push   %esi
f010109c:	53                   	push   %ebx
	// Fill this function in

	// no more page in free list, we run out of free memory
	if (page_free_list == 0)
f010109d:	8b 1d 40 f2 20 f0    	mov    0xf020f240,%ebx
f01010a3:	85 db                	test   %ebx,%ebx
f01010a5:	74 59                	je     f0101100 <page_alloc+0x68>
		return 0;

	// get the previous page in free link
	struct PageInfo* last_free = page_free_list->pp_link;
f01010a7:	8b 33                	mov    (%ebx),%esi
	struct PageInfo* result = page_free_list;

	// get a free page from the list
	page_free_list->pp_link = 0;
f01010a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) {
f01010af:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01010b3:	74 45                	je     f01010fa <page_alloc+0x62>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010b5:	89 d8                	mov    %ebx,%eax
f01010b7:	2b 05 90 fe 20 f0    	sub    0xf020fe90,%eax
f01010bd:	c1 f8 03             	sar    $0x3,%eax
f01010c0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010c3:	89 c2                	mov    %eax,%edx
f01010c5:	c1 ea 0c             	shr    $0xc,%edx
f01010c8:	3b 15 88 fe 20 f0    	cmp    0xf020fe88,%edx
f01010ce:	72 12                	jb     f01010e2 <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010d0:	50                   	push   %eax
f01010d1:	68 a4 62 10 f0       	push   $0xf01062a4
f01010d6:	6a 58                	push   $0x58
f01010d8:	68 6b 68 10 f0       	push   $0xf010686b
f01010dd:	e8 5e ef ff ff       	call   f0100040 <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f01010e2:	83 ec 04             	sub    $0x4,%esp
f01010e5:	68 00 10 00 00       	push   $0x1000
f01010ea:	6a 00                	push   $0x0
f01010ec:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010f1:	50                   	push   %eax
f01010f2:	e8 cf 44 00 00       	call   f01055c6 <memset>
f01010f7:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f01010fa:	89 35 40 f2 20 f0    	mov    %esi,0xf020f240

	return result;
}
f0101100:	89 d8                	mov    %ebx,%eax
f0101102:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101105:	5b                   	pop    %ebx
f0101106:	5e                   	pop    %esi
f0101107:	5d                   	pop    %ebp
f0101108:	c3                   	ret    

f0101109 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101109:	55                   	push   %ebp
f010110a:	89 e5                	mov    %esp,%ebp
f010110c:	83 ec 08             	sub    $0x8,%esp
f010110f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.

	if (pp == 0)
f0101112:	85 c0                	test   %eax,%eax
f0101114:	74 47                	je     f010115d <page_free+0x54>
		return;
	if (pp->pp_link != 0)
f0101116:	83 38 00             	cmpl   $0x0,(%eax)
f0101119:	74 17                	je     f0101132 <page_free+0x29>
		panic("page_free: double free or corrupted\n");
f010111b:	83 ec 04             	sub    $0x4,%esp
f010111e:	68 7c 6c 10 f0       	push   $0xf0106c7c
f0101123:	68 c2 01 00 00       	push   $0x1c2
f0101128:	68 5f 68 10 f0       	push   $0xf010685f
f010112d:	e8 0e ef ff ff       	call   f0100040 <_panic>
	if (pp->pp_ref != 0)
f0101132:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101137:	74 17                	je     f0101150 <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0101139:	83 ec 04             	sub    $0x4,%esp
f010113c:	68 a4 6c 10 f0       	push   $0xf0106ca4
f0101141:	68 c4 01 00 00       	push   $0x1c4
f0101146:	68 5f 68 10 f0       	push   $0xf010685f
f010114b:	e8 f0 ee ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f0101150:	8b 15 40 f2 20 f0    	mov    0xf020f240,%edx
f0101156:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101158:	a3 40 f2 20 f0       	mov    %eax,0xf020f240

}
f010115d:	c9                   	leave  
f010115e:	c3                   	ret    

f010115f <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010115f:	55                   	push   %ebp
f0101160:	89 e5                	mov    %esp,%ebp
f0101162:	83 ec 08             	sub    $0x8,%esp
f0101165:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101168:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010116c:	83 e8 01             	sub    $0x1,%eax
f010116f:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101173:	66 85 c0             	test   %ax,%ax
f0101176:	75 0c                	jne    f0101184 <page_decref+0x25>
		page_free(pp);
f0101178:	83 ec 0c             	sub    $0xc,%esp
f010117b:	52                   	push   %edx
f010117c:	e8 88 ff ff ff       	call   f0101109 <page_free>
f0101181:	83 c4 10             	add    $0x10,%esp
}
f0101184:	c9                   	leave  
f0101185:	c3                   	ret    

f0101186 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101186:	55                   	push   %ebp
f0101187:	89 e5                	mov    %esp,%ebp
f0101189:	56                   	push   %esi
f010118a:	53                   	push   %ebx
f010118b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	// we have virtual address
	// cprintf("[?] %x\n", va);
	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f010118e:	89 de                	mov    %ebx,%esi
f0101190:	c1 ee 0c             	shr    $0xc,%esi
f0101193:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
f0101199:	c1 eb 16             	shr    $0x16,%ebx
f010119c:	c1 e3 02             	shl    $0x2,%ebx
f010119f:	03 5d 08             	add    0x8(%ebp),%ebx
f01011a2:	83 3b 00             	cmpl   $0x0,(%ebx)
f01011a5:	75 30                	jne    f01011d7 <pgdir_walk+0x51>
		if (create == 0)
f01011a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011ab:	74 5c                	je     f0101209 <pgdir_walk+0x83>
			return NULL;
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f01011ad:	83 ec 0c             	sub    $0xc,%esp
f01011b0:	6a 01                	push   $0x1
f01011b2:	e8 e1 fe ff ff       	call   f0101098 <page_alloc>
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
f01011b7:	83 c4 10             	add    $0x10,%esp
f01011ba:	85 c0                	test   %eax,%eax
f01011bc:	74 52                	je     f0101210 <pgdir_walk+0x8a>
		// set level 1 page table entry to this new level 2 page table
		// this new page is for level2 PT, so flags are:
		// 	PTE_P: this page is present
		//	PTE_U: user process can use this page
		//	PTE_W: this page can be edit
		pgdir[Page_Directory_Index] = page2pa(new_page) | PTE_P | PTE_U | PTE_W;
f01011be:	89 c2                	mov    %eax,%edx
f01011c0:	2b 15 90 fe 20 f0    	sub    0xf020fe90,%edx
f01011c6:	c1 fa 03             	sar    $0x3,%edx
f01011c9:	c1 e2 0c             	shl    $0xc,%edx
f01011cc:	83 ca 07             	or     $0x7,%edx
f01011cf:	89 13                	mov    %edx,(%ebx)
		new_page->pp_ref = 1;
f01011d1:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	// cprintf("[?] %x\n", KADDR(PTE_ADDR(pgdir[Page_Directory_Index])));
	
	// remember each entry is 4 byte long
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));
f01011d7:	8b 03                	mov    (%ebx),%eax
f01011d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011de:	89 c2                	mov    %eax,%edx
f01011e0:	c1 ea 0c             	shr    $0xc,%edx
f01011e3:	3b 15 88 fe 20 f0    	cmp    0xf020fe88,%edx
f01011e9:	72 15                	jb     f0101200 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011eb:	50                   	push   %eax
f01011ec:	68 a4 62 10 f0       	push   $0xf01062a4
f01011f1:	68 11 02 00 00       	push   $0x211
f01011f6:	68 5f 68 10 f0       	push   $0xf010685f
f01011fb:	e8 40 ee ff ff       	call   f0100040 <_panic>

	return &p[Page_Table_Index];
f0101200:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0101207:	eb 0c                	jmp    f0101215 <pgdir_walk+0x8f>
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
		if (create == 0)
			return NULL;
f0101209:	b8 00 00 00 00       	mov    $0x0,%eax
f010120e:	eb 05                	jmp    f0101215 <pgdir_walk+0x8f>
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
			return NULL;
f0101210:	b8 00 00 00 00       	mov    $0x0,%eax
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));

	return &p[Page_Table_Index];
}
f0101215:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101218:	5b                   	pop    %ebx
f0101219:	5e                   	pop    %esi
f010121a:	5d                   	pop    %ebp
f010121b:	c3                   	ret    

f010121c <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010121c:	55                   	push   %ebp
f010121d:	89 e5                	mov    %esp,%ebp
f010121f:	57                   	push   %edi
f0101220:	56                   	push   %esi
f0101221:	53                   	push   %ebx
f0101222:	83 ec 1c             	sub    $0x1c,%esp
f0101225:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101228:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in	
	if (size % PGSIZE != 0)
f010122b:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
f0101231:	74 17                	je     f010124a <boot_map_region+0x2e>
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
f0101233:	83 ec 04             	sub    $0x4,%esp
f0101236:	68 e8 6c 10 f0       	push   $0xf0106ce8
f010123b:	68 26 02 00 00       	push   $0x226
f0101240:	68 5f 68 10 f0       	push   $0xf010685f
f0101245:	e8 f6 ed ff ff       	call   f0100040 <_panic>
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
f010124a:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101250:	75 23                	jne    f0101275 <boot_map_region+0x59>
f0101252:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0101257:	75 1c                	jne    f0101275 <boot_map_region+0x59>
f0101259:	c1 e9 0c             	shr    $0xc,%ecx
f010125c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f010125f:	89 c3                	mov    %eax,%ebx
f0101261:	be 00 00 00 00       	mov    $0x0,%esi

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f0101266:	89 d7                	mov    %edx,%edi
f0101268:	29 c7                	sub    %eax,%edi

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f010126a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010126d:	83 c8 01             	or     $0x1,%eax
f0101270:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101273:	eb 5c                	jmp    f01012d1 <boot_map_region+0xb5>
	// Fill this function in	
	if (size % PGSIZE != 0)
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");
f0101275:	83 ec 04             	sub    $0x4,%esp
f0101278:	68 1c 6d 10 f0       	push   $0xf0106d1c
f010127d:	68 29 02 00 00       	push   $0x229
f0101282:	68 5f 68 10 f0       	push   $0xf010685f
f0101287:	e8 b4 ed ff ff       	call   f0100040 <_panic>
	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f010128c:	83 ec 04             	sub    $0x4,%esp
f010128f:	6a 01                	push   $0x1
f0101291:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0101294:	50                   	push   %eax
f0101295:	ff 75 e0             	pushl  -0x20(%ebp)
f0101298:	e8 e9 fe ff ff       	call   f0101186 <pgdir_walk>

		if (pte == 0)
f010129d:	83 c4 10             	add    $0x10,%esp
f01012a0:	85 c0                	test   %eax,%eax
f01012a2:	75 17                	jne    f01012bb <boot_map_region+0x9f>
			panic("boot_map_region: pgdir_walk return NULL\n");
f01012a4:	83 ec 04             	sub    $0x4,%esp
f01012a7:	68 4c 6d 10 f0       	push   $0xf0106d4c
f01012ac:	68 34 02 00 00       	push   $0x234
f01012b1:	68 5f 68 10 f0       	push   $0xf010685f
f01012b6:	e8 85 ed ff ff       	call   f0100040 <_panic>

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f01012bb:	89 da                	mov    %ebx,%edx
f01012bd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01012c3:	0b 55 dc             	or     -0x24(%ebp),%edx
f01012c6:	89 10                	mov    %edx,(%eax)

		// deal with next page
		va += PGSIZE;
		pa += PGSIZE;
f01012c8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f01012ce:	83 c6 01             	add    $0x1,%esi
f01012d1:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01012d4:	75 b6                	jne    f010128c <boot_map_region+0x70>
		va += PGSIZE;
		pa += PGSIZE;

	}

}
f01012d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012d9:	5b                   	pop    %ebx
f01012da:	5e                   	pop    %esi
f01012db:	5f                   	pop    %edi
f01012dc:	5d                   	pop    %ebp
f01012dd:	c3                   	ret    

f01012de <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01012de:	55                   	push   %ebp
f01012df:	89 e5                	mov    %esp,%ebp
f01012e1:	53                   	push   %ebx
f01012e2:	83 ec 08             	sub    $0x8,%esp
f01012e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in

	// do a page table walk to find real PTE
	pte_t * pte = pgdir_walk(pgdir, va, 0);
f01012e8:	6a 00                	push   $0x0
f01012ea:	ff 75 0c             	pushl  0xc(%ebp)
f01012ed:	ff 75 08             	pushl  0x8(%ebp)
f01012f0:	e8 91 fe ff ff       	call   f0101186 <pgdir_walk>

	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
f01012f5:	83 c4 10             	add    $0x10,%esp
f01012f8:	85 c0                	test   %eax,%eax
f01012fa:	74 37                	je     f0101333 <page_lookup+0x55>
f01012fc:	83 38 00             	cmpl   $0x0,(%eax)
f01012ff:	74 39                	je     f010133a <page_lookup+0x5c>
		return NULL;
	
	// store pte
	if (pte_store != 0)
f0101301:	85 db                	test   %ebx,%ebx
f0101303:	74 02                	je     f0101307 <page_lookup+0x29>
		*pte_store = pte;
f0101305:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101307:	8b 00                	mov    (%eax),%eax
f0101309:	c1 e8 0c             	shr    $0xc,%eax
f010130c:	3b 05 88 fe 20 f0    	cmp    0xf020fe88,%eax
f0101312:	72 14                	jb     f0101328 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101314:	83 ec 04             	sub    $0x4,%esp
f0101317:	68 78 6d 10 f0       	push   $0xf0106d78
f010131c:	6a 51                	push   $0x51
f010131e:	68 6b 68 10 f0       	push   $0xf010686b
f0101323:	e8 18 ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101328:	8b 15 90 fe 20 f0    	mov    0xf020fe90,%edx
f010132e:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte)) ;
f0101331:	eb 0c                	jmp    f010133f <page_lookup+0x61>
	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
		return NULL;
f0101333:	b8 00 00 00 00       	mov    $0x0,%eax
f0101338:	eb 05                	jmp    f010133f <page_lookup+0x61>
f010133a:	b8 00 00 00 00       	mov    $0x0,%eax
	// store pte
	if (pte_store != 0)
		*pte_store = pte;

	return pa2page(PTE_ADDR(*pte)) ;
}
f010133f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101342:	c9                   	leave  
f0101343:	c3                   	ret    

f0101344 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101344:	55                   	push   %ebp
f0101345:	89 e5                	mov    %esp,%ebp
f0101347:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010134a:	e8 97 48 00 00       	call   f0105be6 <cpunum>
f010134f:	6b c0 74             	imul   $0x74,%eax,%eax
f0101352:	83 b8 28 00 21 f0 00 	cmpl   $0x0,-0xfdeffd8(%eax)
f0101359:	74 16                	je     f0101371 <tlb_invalidate+0x2d>
f010135b:	e8 86 48 00 00       	call   f0105be6 <cpunum>
f0101360:	6b c0 74             	imul   $0x74,%eax,%eax
f0101363:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f0101369:	8b 55 08             	mov    0x8(%ebp),%edx
f010136c:	39 50 60             	cmp    %edx,0x60(%eax)
f010136f:	75 06                	jne    f0101377 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101371:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101374:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101377:	c9                   	leave  
f0101378:	c3                   	ret    

f0101379 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101379:	55                   	push   %ebp
f010137a:	89 e5                	mov    %esp,%ebp
f010137c:	56                   	push   %esi
f010137d:	53                   	push   %ebx
f010137e:	83 ec 14             	sub    $0x14,%esp
f0101381:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101384:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in

	// pte_t *tmp;
	pte_t *pte_store = NULL;
f0101387:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * pp = page_lookup(pgdir, va, &pte_store);
f010138e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101391:	50                   	push   %eax
f0101392:	56                   	push   %esi
f0101393:	53                   	push   %ebx
f0101394:	e8 45 ff ff ff       	call   f01012de <page_lookup>

	// if not present, silently return
	if (pp == NULL)
f0101399:	83 c4 10             	add    $0x10,%esp
f010139c:	85 c0                	test   %eax,%eax
f010139e:	74 1f                	je     f01013bf <page_remove+0x46>
		return;

	// decrement ref count, and if reaches 0, free it
	page_decref(pp);
f01013a0:	83 ec 0c             	sub    $0xc,%esp
f01013a3:	50                   	push   %eax
f01013a4:	e8 b6 fd ff ff       	call   f010115f <page_decref>

	// null the real PTE pointer 
	*pte_store = 0;
f01013a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01013ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// cprintf("[?] In page_remove\n");
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", *pte_store, **pte_store);

	// tlb invalidate
	tlb_invalidate(pgdir, va);
f01013b2:	83 c4 08             	add    $0x8,%esp
f01013b5:	56                   	push   %esi
f01013b6:	53                   	push   %ebx
f01013b7:	e8 88 ff ff ff       	call   f0101344 <tlb_invalidate>
f01013bc:	83 c4 10             	add    $0x10,%esp

}
f01013bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01013c2:	5b                   	pop    %ebx
f01013c3:	5e                   	pop    %esi
f01013c4:	5d                   	pop    %ebp
f01013c5:	c3                   	ret    

f01013c6 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01013c6:	55                   	push   %ebp
f01013c7:	89 e5                	mov    %esp,%ebp
f01013c9:	57                   	push   %edi
f01013ca:	56                   	push   %esi
f01013cb:	53                   	push   %ebx
f01013cc:	83 ec 10             	sub    $0x10,%esp
f01013cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01013d2:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	
f01013d5:	6a 01                	push   $0x1
f01013d7:	57                   	push   %edi
f01013d8:	ff 75 08             	pushl  0x8(%ebp)
f01013db:	e8 a6 fd ff ff       	call   f0101186 <pgdir_walk>

	if (pte == 0)
f01013e0:	83 c4 10             	add    $0x10,%esp
f01013e3:	85 c0                	test   %eax,%eax
f01013e5:	74 59                	je     f0101440 <page_insert+0x7a>
f01013e7:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;

	// already have a page
	// remove it and invalidate tlb
	if (*pte != 0) {
f01013e9:	8b 00                	mov    (%eax),%eax
f01013eb:	85 c0                	test   %eax,%eax
f01013ed:	74 2d                	je     f010141c <page_insert+0x56>
		// corner case
		if (page2pa(pp) == PTE_ADDR(*pte))
f01013ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01013f4:	89 da                	mov    %ebx,%edx
f01013f6:	2b 15 90 fe 20 f0    	sub    0xf020fe90,%edx
f01013fc:	c1 fa 03             	sar    $0x3,%edx
f01013ff:	c1 e2 0c             	shl    $0xc,%edx
f0101402:	39 d0                	cmp    %edx,%eax
f0101404:	75 07                	jne    f010140d <page_insert+0x47>
			pp->pp_ref--;	// keep pp_ref consistent, in the meantime change perm potentially.
f0101406:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f010140b:	eb 0f                	jmp    f010141c <page_insert+0x56>
		else
			page_remove(pgdir, va);
f010140d:	83 ec 08             	sub    $0x8,%esp
f0101410:	57                   	push   %edi
f0101411:	ff 75 08             	pushl  0x8(%ebp)
f0101414:	e8 60 ff ff ff       	call   f0101379 <page_remove>
f0101419:	83 c4 10             	add    $0x10,%esp

	// set the real PTE to pa, zero out least 12 bits
	*pte = PTE_ADDR(page2pa(pp));
	
	// set flags
	*pte |= (perm | PTE_P);
f010141c:	89 d8                	mov    %ebx,%eax
f010141e:	2b 05 90 fe 20 f0    	sub    0xf020fe90,%eax
f0101424:	c1 f8 03             	sar    $0x3,%eax
f0101427:	c1 e0 0c             	shl    $0xc,%eax
f010142a:	8b 55 14             	mov    0x14(%ebp),%edx
f010142d:	83 ca 01             	or     $0x1,%edx
f0101430:	09 d0                	or     %edx,%eax
f0101432:	89 06                	mov    %eax,(%esi)

	// increment ref cnt
	pp->pp_ref++;
f0101434:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	return 0;
f0101439:	b8 00 00 00 00       	mov    $0x0,%eax
f010143e:	eb 05                	jmp    f0101445 <page_insert+0x7f>
	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	

	if (pte == 0)
		return -E_NO_MEM;
f0101440:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	// increment ref cnt
	pp->pp_ref++;

	return 0;
}
f0101445:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101448:	5b                   	pop    %ebx
f0101449:	5e                   	pop    %esi
f010144a:	5f                   	pop    %edi
f010144b:	5d                   	pop    %ebp
f010144c:	c3                   	ret    

f010144d <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f010144d:	55                   	push   %ebp
f010144e:	89 e5                	mov    %esp,%ebp
f0101450:	56                   	push   %esi
f0101451:	53                   	push   %ebx
f0101452:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	// panic("mmio_map_region not implemented");

	uintptr_t mmio = base;
f0101455:	8b 35 00 03 12 f0    	mov    0xf0120300,%esi

	if (ROUNDUP(mmio + size, PGSIZE) >= MMIOLIM)
f010145b:	8d 84 0e ff 0f 00 00 	lea    0xfff(%esi,%ecx,1),%eax
f0101462:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101467:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010146c:	76 17                	jbe    f0101485 <mmio_map_region+0x38>
		panic("mmio_map_region: mmio out of memory");
f010146e:	83 ec 04             	sub    $0x4,%esp
f0101471:	68 98 6d 10 f0       	push   $0xf0106d98
f0101476:	68 fb 02 00 00       	push   $0x2fb
f010147b:	68 5f 68 10 f0       	push   $0xf010685f
f0101480:	e8 bb eb ff ff       	call   f0100040 <_panic>
		
	boot_map_region(kern_pgdir, mmio, ROUNDUP(size, PGSIZE), pa, PTE_PCD|PTE_PWT|PTE_W);
f0101485:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f010148b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101491:	83 ec 08             	sub    $0x8,%esp
f0101494:	6a 1a                	push   $0x1a
f0101496:	ff 75 08             	pushl  0x8(%ebp)
f0101499:	89 d9                	mov    %ebx,%ecx
f010149b:	89 f2                	mov    %esi,%edx
f010149d:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
f01014a2:	e8 75 fd ff ff       	call   f010121c <boot_map_region>

	base += ROUNDUP(size, PGSIZE);
f01014a7:	01 1d 00 03 12 f0    	add    %ebx,0xf0120300

	return (void *)mmio;
}
f01014ad:	89 f0                	mov    %esi,%eax
f01014af:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01014b2:	5b                   	pop    %ebx
f01014b3:	5e                   	pop    %esi
f01014b4:	5d                   	pop    %ebp
f01014b5:	c3                   	ret    

f01014b6 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01014b6:	55                   	push   %ebp
f01014b7:	89 e5                	mov    %esp,%ebp
f01014b9:	57                   	push   %edi
f01014ba:	56                   	push   %esi
f01014bb:	53                   	push   %ebx
f01014bc:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01014bf:	b8 15 00 00 00       	mov    $0x15,%eax
f01014c4:	e8 26 f6 ff ff       	call   f0100aef <nvram_read>
f01014c9:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01014cb:	b8 17 00 00 00       	mov    $0x17,%eax
f01014d0:	e8 1a f6 ff ff       	call   f0100aef <nvram_read>
f01014d5:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01014d7:	b8 34 00 00 00       	mov    $0x34,%eax
f01014dc:	e8 0e f6 ff ff       	call   f0100aef <nvram_read>
f01014e1:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01014e4:	85 c0                	test   %eax,%eax
f01014e6:	74 07                	je     f01014ef <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01014e8:	05 00 40 00 00       	add    $0x4000,%eax
f01014ed:	eb 0b                	jmp    f01014fa <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01014ef:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01014f5:	85 f6                	test   %esi,%esi
f01014f7:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01014fa:	89 c2                	mov    %eax,%edx
f01014fc:	c1 ea 02             	shr    $0x2,%edx
f01014ff:	89 15 88 fe 20 f0    	mov    %edx,0xf020fe88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101505:	89 da                	mov    %ebx,%edx
f0101507:	c1 ea 02             	shr    $0x2,%edx
f010150a:	89 15 44 f2 20 f0    	mov    %edx,0xf020f244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101510:	89 c2                	mov    %eax,%edx
f0101512:	29 da                	sub    %ebx,%edx
f0101514:	52                   	push   %edx
f0101515:	53                   	push   %ebx
f0101516:	50                   	push   %eax
f0101517:	68 bc 6d 10 f0       	push   $0xf0106dbc
f010151c:	e8 4b 23 00 00       	call   f010386c <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101521:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101526:	e8 ed f5 ff ff       	call   f0100b18 <boot_alloc>
f010152b:	a3 8c fe 20 f0       	mov    %eax,0xf020fe8c
	memset(kern_pgdir, 0, PGSIZE);
f0101530:	83 c4 0c             	add    $0xc,%esp
f0101533:	68 00 10 00 00       	push   $0x1000
f0101538:	6a 00                	push   $0x0
f010153a:	50                   	push   %eax
f010153b:	e8 86 40 00 00       	call   f01055c6 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101540:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101545:	83 c4 10             	add    $0x10,%esp
f0101548:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010154d:	77 15                	ja     f0101564 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010154f:	50                   	push   %eax
f0101550:	68 c8 62 10 f0       	push   $0xf01062c8
f0101555:	68 9b 00 00 00       	push   $0x9b
f010155a:	68 5f 68 10 f0       	push   $0xf010685f
f010155f:	e8 dc ea ff ff       	call   f0100040 <_panic>
f0101564:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010156a:	83 ca 05             	or     $0x5,%edx
f010156d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f0101573:	a1 88 fe 20 f0       	mov    0xf020fe88,%eax
f0101578:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f010157f:	89 d8                	mov    %ebx,%eax
f0101581:	e8 92 f5 ff ff       	call   f0100b18 <boot_alloc>
f0101586:	a3 90 fe 20 f0       	mov    %eax,0xf020fe90
	memset(pages, 0, n);
f010158b:	83 ec 04             	sub    $0x4,%esp
f010158e:	53                   	push   %ebx
f010158f:	6a 00                	push   $0x0
f0101591:	50                   	push   %eax
f0101592:	e8 2f 40 00 00       	call   f01055c6 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	n = NENV * sizeof(struct Env);
	envs = (struct Env *) boot_alloc(n);
f0101597:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010159c:	e8 77 f5 ff ff       	call   f0100b18 <boot_alloc>
f01015a1:	a3 48 f2 20 f0       	mov    %eax,0xf020f248
	memset(envs, 0, n);
f01015a6:	83 c4 0c             	add    $0xc,%esp
f01015a9:	68 00 f0 01 00       	push   $0x1f000
f01015ae:	6a 00                	push   $0x0
f01015b0:	50                   	push   %eax
f01015b1:	e8 10 40 00 00       	call   f01055c6 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01015b6:	e8 16 f9 ff ff       	call   f0100ed1 <page_init>

	check_page_free_list(1);
f01015bb:	b8 01 00 00 00       	mov    $0x1,%eax
f01015c0:	e8 0a f6 ff ff       	call   f0100bcf <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01015c5:	83 c4 10             	add    $0x10,%esp
f01015c8:	83 3d 90 fe 20 f0 00 	cmpl   $0x0,0xf020fe90
f01015cf:	75 17                	jne    f01015e8 <mem_init+0x132>
		panic("'pages' is a null pointer!");
f01015d1:	83 ec 04             	sub    $0x4,%esp
f01015d4:	68 53 69 10 f0       	push   $0xf0106953
f01015d9:	68 9f 03 00 00       	push   $0x39f
f01015de:	68 5f 68 10 f0       	push   $0xf010685f
f01015e3:	e8 58 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015e8:	a1 40 f2 20 f0       	mov    0xf020f240,%eax
f01015ed:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015f2:	eb 05                	jmp    f01015f9 <mem_init+0x143>
		++nfree;
f01015f4:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015f7:	8b 00                	mov    (%eax),%eax
f01015f9:	85 c0                	test   %eax,%eax
f01015fb:	75 f7                	jne    f01015f4 <mem_init+0x13e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015fd:	83 ec 0c             	sub    $0xc,%esp
f0101600:	6a 00                	push   $0x0
f0101602:	e8 91 fa ff ff       	call   f0101098 <page_alloc>
f0101607:	89 c7                	mov    %eax,%edi
f0101609:	83 c4 10             	add    $0x10,%esp
f010160c:	85 c0                	test   %eax,%eax
f010160e:	75 19                	jne    f0101629 <mem_init+0x173>
f0101610:	68 6e 69 10 f0       	push   $0xf010696e
f0101615:	68 85 68 10 f0       	push   $0xf0106885
f010161a:	68 a7 03 00 00       	push   $0x3a7
f010161f:	68 5f 68 10 f0       	push   $0xf010685f
f0101624:	e8 17 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101629:	83 ec 0c             	sub    $0xc,%esp
f010162c:	6a 00                	push   $0x0
f010162e:	e8 65 fa ff ff       	call   f0101098 <page_alloc>
f0101633:	89 c6                	mov    %eax,%esi
f0101635:	83 c4 10             	add    $0x10,%esp
f0101638:	85 c0                	test   %eax,%eax
f010163a:	75 19                	jne    f0101655 <mem_init+0x19f>
f010163c:	68 84 69 10 f0       	push   $0xf0106984
f0101641:	68 85 68 10 f0       	push   $0xf0106885
f0101646:	68 a8 03 00 00       	push   $0x3a8
f010164b:	68 5f 68 10 f0       	push   $0xf010685f
f0101650:	e8 eb e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101655:	83 ec 0c             	sub    $0xc,%esp
f0101658:	6a 00                	push   $0x0
f010165a:	e8 39 fa ff ff       	call   f0101098 <page_alloc>
f010165f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101662:	83 c4 10             	add    $0x10,%esp
f0101665:	85 c0                	test   %eax,%eax
f0101667:	75 19                	jne    f0101682 <mem_init+0x1cc>
f0101669:	68 9a 69 10 f0       	push   $0xf010699a
f010166e:	68 85 68 10 f0       	push   $0xf0106885
f0101673:	68 a9 03 00 00       	push   $0x3a9
f0101678:	68 5f 68 10 f0       	push   $0xf010685f
f010167d:	e8 be e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101682:	39 f7                	cmp    %esi,%edi
f0101684:	75 19                	jne    f010169f <mem_init+0x1e9>
f0101686:	68 b0 69 10 f0       	push   $0xf01069b0
f010168b:	68 85 68 10 f0       	push   $0xf0106885
f0101690:	68 ac 03 00 00       	push   $0x3ac
f0101695:	68 5f 68 10 f0       	push   $0xf010685f
f010169a:	e8 a1 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010169f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016a2:	39 c6                	cmp    %eax,%esi
f01016a4:	74 04                	je     f01016aa <mem_init+0x1f4>
f01016a6:	39 c7                	cmp    %eax,%edi
f01016a8:	75 19                	jne    f01016c3 <mem_init+0x20d>
f01016aa:	68 f8 6d 10 f0       	push   $0xf0106df8
f01016af:	68 85 68 10 f0       	push   $0xf0106885
f01016b4:	68 ad 03 00 00       	push   $0x3ad
f01016b9:	68 5f 68 10 f0       	push   $0xf010685f
f01016be:	e8 7d e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016c3:	8b 0d 90 fe 20 f0    	mov    0xf020fe90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01016c9:	8b 15 88 fe 20 f0    	mov    0xf020fe88,%edx
f01016cf:	c1 e2 0c             	shl    $0xc,%edx
f01016d2:	89 f8                	mov    %edi,%eax
f01016d4:	29 c8                	sub    %ecx,%eax
f01016d6:	c1 f8 03             	sar    $0x3,%eax
f01016d9:	c1 e0 0c             	shl    $0xc,%eax
f01016dc:	39 d0                	cmp    %edx,%eax
f01016de:	72 19                	jb     f01016f9 <mem_init+0x243>
f01016e0:	68 c2 69 10 f0       	push   $0xf01069c2
f01016e5:	68 85 68 10 f0       	push   $0xf0106885
f01016ea:	68 ae 03 00 00       	push   $0x3ae
f01016ef:	68 5f 68 10 f0       	push   $0xf010685f
f01016f4:	e8 47 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016f9:	89 f0                	mov    %esi,%eax
f01016fb:	29 c8                	sub    %ecx,%eax
f01016fd:	c1 f8 03             	sar    $0x3,%eax
f0101700:	c1 e0 0c             	shl    $0xc,%eax
f0101703:	39 c2                	cmp    %eax,%edx
f0101705:	77 19                	ja     f0101720 <mem_init+0x26a>
f0101707:	68 df 69 10 f0       	push   $0xf01069df
f010170c:	68 85 68 10 f0       	push   $0xf0106885
f0101711:	68 af 03 00 00       	push   $0x3af
f0101716:	68 5f 68 10 f0       	push   $0xf010685f
f010171b:	e8 20 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101720:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101723:	29 c8                	sub    %ecx,%eax
f0101725:	c1 f8 03             	sar    $0x3,%eax
f0101728:	c1 e0 0c             	shl    $0xc,%eax
f010172b:	39 c2                	cmp    %eax,%edx
f010172d:	77 19                	ja     f0101748 <mem_init+0x292>
f010172f:	68 fc 69 10 f0       	push   $0xf01069fc
f0101734:	68 85 68 10 f0       	push   $0xf0106885
f0101739:	68 b0 03 00 00       	push   $0x3b0
f010173e:	68 5f 68 10 f0       	push   $0xf010685f
f0101743:	e8 f8 e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101748:	a1 40 f2 20 f0       	mov    0xf020f240,%eax
f010174d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101750:	c7 05 40 f2 20 f0 00 	movl   $0x0,0xf020f240
f0101757:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010175a:	83 ec 0c             	sub    $0xc,%esp
f010175d:	6a 00                	push   $0x0
f010175f:	e8 34 f9 ff ff       	call   f0101098 <page_alloc>
f0101764:	83 c4 10             	add    $0x10,%esp
f0101767:	85 c0                	test   %eax,%eax
f0101769:	74 19                	je     f0101784 <mem_init+0x2ce>
f010176b:	68 19 6a 10 f0       	push   $0xf0106a19
f0101770:	68 85 68 10 f0       	push   $0xf0106885
f0101775:	68 b7 03 00 00       	push   $0x3b7
f010177a:	68 5f 68 10 f0       	push   $0xf010685f
f010177f:	e8 bc e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101784:	83 ec 0c             	sub    $0xc,%esp
f0101787:	57                   	push   %edi
f0101788:	e8 7c f9 ff ff       	call   f0101109 <page_free>
	page_free(pp1);
f010178d:	89 34 24             	mov    %esi,(%esp)
f0101790:	e8 74 f9 ff ff       	call   f0101109 <page_free>
	page_free(pp2);
f0101795:	83 c4 04             	add    $0x4,%esp
f0101798:	ff 75 d4             	pushl  -0x2c(%ebp)
f010179b:	e8 69 f9 ff ff       	call   f0101109 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a7:	e8 ec f8 ff ff       	call   f0101098 <page_alloc>
f01017ac:	89 c6                	mov    %eax,%esi
f01017ae:	83 c4 10             	add    $0x10,%esp
f01017b1:	85 c0                	test   %eax,%eax
f01017b3:	75 19                	jne    f01017ce <mem_init+0x318>
f01017b5:	68 6e 69 10 f0       	push   $0xf010696e
f01017ba:	68 85 68 10 f0       	push   $0xf0106885
f01017bf:	68 be 03 00 00       	push   $0x3be
f01017c4:	68 5f 68 10 f0       	push   $0xf010685f
f01017c9:	e8 72 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017ce:	83 ec 0c             	sub    $0xc,%esp
f01017d1:	6a 00                	push   $0x0
f01017d3:	e8 c0 f8 ff ff       	call   f0101098 <page_alloc>
f01017d8:	89 c7                	mov    %eax,%edi
f01017da:	83 c4 10             	add    $0x10,%esp
f01017dd:	85 c0                	test   %eax,%eax
f01017df:	75 19                	jne    f01017fa <mem_init+0x344>
f01017e1:	68 84 69 10 f0       	push   $0xf0106984
f01017e6:	68 85 68 10 f0       	push   $0xf0106885
f01017eb:	68 bf 03 00 00       	push   $0x3bf
f01017f0:	68 5f 68 10 f0       	push   $0xf010685f
f01017f5:	e8 46 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017fa:	83 ec 0c             	sub    $0xc,%esp
f01017fd:	6a 00                	push   $0x0
f01017ff:	e8 94 f8 ff ff       	call   f0101098 <page_alloc>
f0101804:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101807:	83 c4 10             	add    $0x10,%esp
f010180a:	85 c0                	test   %eax,%eax
f010180c:	75 19                	jne    f0101827 <mem_init+0x371>
f010180e:	68 9a 69 10 f0       	push   $0xf010699a
f0101813:	68 85 68 10 f0       	push   $0xf0106885
f0101818:	68 c0 03 00 00       	push   $0x3c0
f010181d:	68 5f 68 10 f0       	push   $0xf010685f
f0101822:	e8 19 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101827:	39 fe                	cmp    %edi,%esi
f0101829:	75 19                	jne    f0101844 <mem_init+0x38e>
f010182b:	68 b0 69 10 f0       	push   $0xf01069b0
f0101830:	68 85 68 10 f0       	push   $0xf0106885
f0101835:	68 c2 03 00 00       	push   $0x3c2
f010183a:	68 5f 68 10 f0       	push   $0xf010685f
f010183f:	e8 fc e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101844:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101847:	39 c7                	cmp    %eax,%edi
f0101849:	74 04                	je     f010184f <mem_init+0x399>
f010184b:	39 c6                	cmp    %eax,%esi
f010184d:	75 19                	jne    f0101868 <mem_init+0x3b2>
f010184f:	68 f8 6d 10 f0       	push   $0xf0106df8
f0101854:	68 85 68 10 f0       	push   $0xf0106885
f0101859:	68 c3 03 00 00       	push   $0x3c3
f010185e:	68 5f 68 10 f0       	push   $0xf010685f
f0101863:	e8 d8 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101868:	83 ec 0c             	sub    $0xc,%esp
f010186b:	6a 00                	push   $0x0
f010186d:	e8 26 f8 ff ff       	call   f0101098 <page_alloc>
f0101872:	83 c4 10             	add    $0x10,%esp
f0101875:	85 c0                	test   %eax,%eax
f0101877:	74 19                	je     f0101892 <mem_init+0x3dc>
f0101879:	68 19 6a 10 f0       	push   $0xf0106a19
f010187e:	68 85 68 10 f0       	push   $0xf0106885
f0101883:	68 c4 03 00 00       	push   $0x3c4
f0101888:	68 5f 68 10 f0       	push   $0xf010685f
f010188d:	e8 ae e7 ff ff       	call   f0100040 <_panic>
f0101892:	89 f0                	mov    %esi,%eax
f0101894:	2b 05 90 fe 20 f0    	sub    0xf020fe90,%eax
f010189a:	c1 f8 03             	sar    $0x3,%eax
f010189d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018a0:	89 c2                	mov    %eax,%edx
f01018a2:	c1 ea 0c             	shr    $0xc,%edx
f01018a5:	3b 15 88 fe 20 f0    	cmp    0xf020fe88,%edx
f01018ab:	72 12                	jb     f01018bf <mem_init+0x409>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018ad:	50                   	push   %eax
f01018ae:	68 a4 62 10 f0       	push   $0xf01062a4
f01018b3:	6a 58                	push   $0x58
f01018b5:	68 6b 68 10 f0       	push   $0xf010686b
f01018ba:	e8 81 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01018bf:	83 ec 04             	sub    $0x4,%esp
f01018c2:	68 00 10 00 00       	push   $0x1000
f01018c7:	6a 01                	push   $0x1
f01018c9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018ce:	50                   	push   %eax
f01018cf:	e8 f2 3c 00 00       	call   f01055c6 <memset>
	page_free(pp0);
f01018d4:	89 34 24             	mov    %esi,(%esp)
f01018d7:	e8 2d f8 ff ff       	call   f0101109 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018e3:	e8 b0 f7 ff ff       	call   f0101098 <page_alloc>
f01018e8:	83 c4 10             	add    $0x10,%esp
f01018eb:	85 c0                	test   %eax,%eax
f01018ed:	75 19                	jne    f0101908 <mem_init+0x452>
f01018ef:	68 28 6a 10 f0       	push   $0xf0106a28
f01018f4:	68 85 68 10 f0       	push   $0xf0106885
f01018f9:	68 c9 03 00 00       	push   $0x3c9
f01018fe:	68 5f 68 10 f0       	push   $0xf010685f
f0101903:	e8 38 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101908:	39 c6                	cmp    %eax,%esi
f010190a:	74 19                	je     f0101925 <mem_init+0x46f>
f010190c:	68 46 6a 10 f0       	push   $0xf0106a46
f0101911:	68 85 68 10 f0       	push   $0xf0106885
f0101916:	68 ca 03 00 00       	push   $0x3ca
f010191b:	68 5f 68 10 f0       	push   $0xf010685f
f0101920:	e8 1b e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101925:	89 f0                	mov    %esi,%eax
f0101927:	2b 05 90 fe 20 f0    	sub    0xf020fe90,%eax
f010192d:	c1 f8 03             	sar    $0x3,%eax
f0101930:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101933:	89 c2                	mov    %eax,%edx
f0101935:	c1 ea 0c             	shr    $0xc,%edx
f0101938:	3b 15 88 fe 20 f0    	cmp    0xf020fe88,%edx
f010193e:	72 12                	jb     f0101952 <mem_init+0x49c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101940:	50                   	push   %eax
f0101941:	68 a4 62 10 f0       	push   $0xf01062a4
f0101946:	6a 58                	push   $0x58
f0101948:	68 6b 68 10 f0       	push   $0xf010686b
f010194d:	e8 ee e6 ff ff       	call   f0100040 <_panic>
f0101952:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101958:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
f010195e:	80 38 00             	cmpb   $0x0,(%eax)
f0101961:	74 19                	je     f010197c <mem_init+0x4c6>
f0101963:	68 56 6a 10 f0       	push   $0xf0106a56
f0101968:	68 85 68 10 f0       	push   $0xf0106885
f010196d:	68 ce 03 00 00       	push   $0x3ce
f0101972:	68 5f 68 10 f0       	push   $0xf010685f
f0101977:	e8 c4 e6 ff ff       	call   f0100040 <_panic>
f010197c:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
f010197f:	39 d0                	cmp    %edx,%eax
f0101981:	75 db                	jne    f010195e <mem_init+0x4a8>
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
	}

	// give free list back
	page_free_list = fl;
f0101983:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101986:	a3 40 f2 20 f0       	mov    %eax,0xf020f240

	// free the pages we took
	page_free(pp0);
f010198b:	83 ec 0c             	sub    $0xc,%esp
f010198e:	56                   	push   %esi
f010198f:	e8 75 f7 ff ff       	call   f0101109 <page_free>
	page_free(pp1);
f0101994:	89 3c 24             	mov    %edi,(%esp)
f0101997:	e8 6d f7 ff ff       	call   f0101109 <page_free>
	page_free(pp2);
f010199c:	83 c4 04             	add    $0x4,%esp
f010199f:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019a2:	e8 62 f7 ff ff       	call   f0101109 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019a7:	a1 40 f2 20 f0       	mov    0xf020f240,%eax
f01019ac:	83 c4 10             	add    $0x10,%esp
f01019af:	eb 05                	jmp    f01019b6 <mem_init+0x500>
		--nfree;
f01019b1:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019b4:	8b 00                	mov    (%eax),%eax
f01019b6:	85 c0                	test   %eax,%eax
f01019b8:	75 f7                	jne    f01019b1 <mem_init+0x4fb>
		--nfree;
	assert(nfree == 0);
f01019ba:	85 db                	test   %ebx,%ebx
f01019bc:	74 19                	je     f01019d7 <mem_init+0x521>
f01019be:	68 60 6a 10 f0       	push   $0xf0106a60
f01019c3:	68 85 68 10 f0       	push   $0xf0106885
f01019c8:	68 dc 03 00 00       	push   $0x3dc
f01019cd:	68 5f 68 10 f0       	push   $0xf010685f
f01019d2:	e8 69 e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01019d7:	83 ec 0c             	sub    $0xc,%esp
f01019da:	68 18 6e 10 f0       	push   $0xf0106e18
f01019df:	e8 88 1e 00 00       	call   f010386c <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019eb:	e8 a8 f6 ff ff       	call   f0101098 <page_alloc>
f01019f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019f3:	83 c4 10             	add    $0x10,%esp
f01019f6:	85 c0                	test   %eax,%eax
f01019f8:	75 19                	jne    f0101a13 <mem_init+0x55d>
f01019fa:	68 6e 69 10 f0       	push   $0xf010696e
f01019ff:	68 85 68 10 f0       	push   $0xf0106885
f0101a04:	68 46 04 00 00       	push   $0x446
f0101a09:	68 5f 68 10 f0       	push   $0xf010685f
f0101a0e:	e8 2d e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a13:	83 ec 0c             	sub    $0xc,%esp
f0101a16:	6a 00                	push   $0x0
f0101a18:	e8 7b f6 ff ff       	call   f0101098 <page_alloc>
f0101a1d:	89 c3                	mov    %eax,%ebx
f0101a1f:	83 c4 10             	add    $0x10,%esp
f0101a22:	85 c0                	test   %eax,%eax
f0101a24:	75 19                	jne    f0101a3f <mem_init+0x589>
f0101a26:	68 84 69 10 f0       	push   $0xf0106984
f0101a2b:	68 85 68 10 f0       	push   $0xf0106885
f0101a30:	68 47 04 00 00       	push   $0x447
f0101a35:	68 5f 68 10 f0       	push   $0xf010685f
f0101a3a:	e8 01 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a3f:	83 ec 0c             	sub    $0xc,%esp
f0101a42:	6a 00                	push   $0x0
f0101a44:	e8 4f f6 ff ff       	call   f0101098 <page_alloc>
f0101a49:	89 c6                	mov    %eax,%esi
f0101a4b:	83 c4 10             	add    $0x10,%esp
f0101a4e:	85 c0                	test   %eax,%eax
f0101a50:	75 19                	jne    f0101a6b <mem_init+0x5b5>
f0101a52:	68 9a 69 10 f0       	push   $0xf010699a
f0101a57:	68 85 68 10 f0       	push   $0xf0106885
f0101a5c:	68 48 04 00 00       	push   $0x448
f0101a61:	68 5f 68 10 f0       	push   $0xf010685f
f0101a66:	e8 d5 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a6b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101a6e:	75 19                	jne    f0101a89 <mem_init+0x5d3>
f0101a70:	68 b0 69 10 f0       	push   $0xf01069b0
f0101a75:	68 85 68 10 f0       	push   $0xf0106885
f0101a7a:	68 4b 04 00 00       	push   $0x44b
f0101a7f:	68 5f 68 10 f0       	push   $0xf010685f
f0101a84:	e8 b7 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a89:	39 c3                	cmp    %eax,%ebx
f0101a8b:	74 05                	je     f0101a92 <mem_init+0x5dc>
f0101a8d:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a90:	75 19                	jne    f0101aab <mem_init+0x5f5>
f0101a92:	68 f8 6d 10 f0       	push   $0xf0106df8
f0101a97:	68 85 68 10 f0       	push   $0xf0106885
f0101a9c:	68 4c 04 00 00       	push   $0x44c
f0101aa1:	68 5f 68 10 f0       	push   $0xf010685f
f0101aa6:	e8 95 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101aab:	a1 40 f2 20 f0       	mov    0xf020f240,%eax
f0101ab0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101ab3:	c7 05 40 f2 20 f0 00 	movl   $0x0,0xf020f240
f0101aba:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101abd:	83 ec 0c             	sub    $0xc,%esp
f0101ac0:	6a 00                	push   $0x0
f0101ac2:	e8 d1 f5 ff ff       	call   f0101098 <page_alloc>
f0101ac7:	83 c4 10             	add    $0x10,%esp
f0101aca:	85 c0                	test   %eax,%eax
f0101acc:	74 19                	je     f0101ae7 <mem_init+0x631>
f0101ace:	68 19 6a 10 f0       	push   $0xf0106a19
f0101ad3:	68 85 68 10 f0       	push   $0xf0106885
f0101ad8:	68 53 04 00 00       	push   $0x453
f0101add:	68 5f 68 10 f0       	push   $0xf010685f
f0101ae2:	e8 59 e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ae7:	83 ec 04             	sub    $0x4,%esp
f0101aea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101aed:	50                   	push   %eax
f0101aee:	6a 00                	push   $0x0
f0101af0:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0101af6:	e8 e3 f7 ff ff       	call   f01012de <page_lookup>
f0101afb:	83 c4 10             	add    $0x10,%esp
f0101afe:	85 c0                	test   %eax,%eax
f0101b00:	74 19                	je     f0101b1b <mem_init+0x665>
f0101b02:	68 38 6e 10 f0       	push   $0xf0106e38
f0101b07:	68 85 68 10 f0       	push   $0xf0106885
f0101b0c:	68 56 04 00 00       	push   $0x456
f0101b11:	68 5f 68 10 f0       	push   $0xf010685f
f0101b16:	e8 25 e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b1b:	6a 02                	push   $0x2
f0101b1d:	6a 00                	push   $0x0
f0101b1f:	53                   	push   %ebx
f0101b20:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0101b26:	e8 9b f8 ff ff       	call   f01013c6 <page_insert>
f0101b2b:	83 c4 10             	add    $0x10,%esp
f0101b2e:	85 c0                	test   %eax,%eax
f0101b30:	78 19                	js     f0101b4b <mem_init+0x695>
f0101b32:	68 70 6e 10 f0       	push   $0xf0106e70
f0101b37:	68 85 68 10 f0       	push   $0xf0106885
f0101b3c:	68 59 04 00 00       	push   $0x459
f0101b41:	68 5f 68 10 f0       	push   $0xf010685f
f0101b46:	e8 f5 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b4b:	83 ec 0c             	sub    $0xc,%esp
f0101b4e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b51:	e8 b3 f5 ff ff       	call   f0101109 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b56:	6a 02                	push   $0x2
f0101b58:	6a 00                	push   $0x0
f0101b5a:	53                   	push   %ebx
f0101b5b:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0101b61:	e8 60 f8 ff ff       	call   f01013c6 <page_insert>
f0101b66:	83 c4 20             	add    $0x20,%esp
f0101b69:	85 c0                	test   %eax,%eax
f0101b6b:	74 19                	je     f0101b86 <mem_init+0x6d0>
f0101b6d:	68 a0 6e 10 f0       	push   $0xf0106ea0
f0101b72:	68 85 68 10 f0       	push   $0xf0106885
f0101b77:	68 5d 04 00 00       	push   $0x45d
f0101b7c:	68 5f 68 10 f0       	push   $0xf010685f
f0101b81:	e8 ba e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b86:	8b 3d 8c fe 20 f0    	mov    0xf020fe8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b8c:	a1 90 fe 20 f0       	mov    0xf020fe90,%eax
f0101b91:	89 c1                	mov    %eax,%ecx
f0101b93:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b96:	8b 17                	mov    (%edi),%edx
f0101b98:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ba1:	29 c8                	sub    %ecx,%eax
f0101ba3:	c1 f8 03             	sar    $0x3,%eax
f0101ba6:	c1 e0 0c             	shl    $0xc,%eax
f0101ba9:	39 c2                	cmp    %eax,%edx
f0101bab:	74 19                	je     f0101bc6 <mem_init+0x710>
f0101bad:	68 d0 6e 10 f0       	push   $0xf0106ed0
f0101bb2:	68 85 68 10 f0       	push   $0xf0106885
f0101bb7:	68 5e 04 00 00       	push   $0x45e
f0101bbc:	68 5f 68 10 f0       	push   $0xf010685f
f0101bc1:	e8 7a e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bc6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bcb:	89 f8                	mov    %edi,%eax
f0101bcd:	e8 99 ef ff ff       	call   f0100b6b <check_va2pa>
f0101bd2:	89 da                	mov    %ebx,%edx
f0101bd4:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101bd7:	c1 fa 03             	sar    $0x3,%edx
f0101bda:	c1 e2 0c             	shl    $0xc,%edx
f0101bdd:	39 d0                	cmp    %edx,%eax
f0101bdf:	74 19                	je     f0101bfa <mem_init+0x744>
f0101be1:	68 f8 6e 10 f0       	push   $0xf0106ef8
f0101be6:	68 85 68 10 f0       	push   $0xf0106885
f0101beb:	68 5f 04 00 00       	push   $0x45f
f0101bf0:	68 5f 68 10 f0       	push   $0xf010685f
f0101bf5:	e8 46 e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101bfa:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bff:	74 19                	je     f0101c1a <mem_init+0x764>
f0101c01:	68 6b 6a 10 f0       	push   $0xf0106a6b
f0101c06:	68 85 68 10 f0       	push   $0xf0106885
f0101c0b:	68 60 04 00 00       	push   $0x460
f0101c10:	68 5f 68 10 f0       	push   $0xf010685f
f0101c15:	e8 26 e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101c1a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c1d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c22:	74 19                	je     f0101c3d <mem_init+0x787>
f0101c24:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0101c29:	68 85 68 10 f0       	push   $0xf0106885
f0101c2e:	68 61 04 00 00       	push   $0x461
f0101c33:	68 5f 68 10 f0       	push   $0xf010685f
f0101c38:	e8 03 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c3d:	6a 02                	push   $0x2
f0101c3f:	68 00 10 00 00       	push   $0x1000
f0101c44:	56                   	push   %esi
f0101c45:	57                   	push   %edi
f0101c46:	e8 7b f7 ff ff       	call   f01013c6 <page_insert>
f0101c4b:	83 c4 10             	add    $0x10,%esp
f0101c4e:	85 c0                	test   %eax,%eax
f0101c50:	74 19                	je     f0101c6b <mem_init+0x7b5>
f0101c52:	68 28 6f 10 f0       	push   $0xf0106f28
f0101c57:	68 85 68 10 f0       	push   $0xf0106885
f0101c5c:	68 64 04 00 00       	push   $0x464
f0101c61:	68 5f 68 10 f0       	push   $0xf010685f
f0101c66:	e8 d5 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c6b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c70:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
f0101c75:	e8 f1 ee ff ff       	call   f0100b6b <check_va2pa>
f0101c7a:	89 f2                	mov    %esi,%edx
f0101c7c:	2b 15 90 fe 20 f0    	sub    0xf020fe90,%edx
f0101c82:	c1 fa 03             	sar    $0x3,%edx
f0101c85:	c1 e2 0c             	shl    $0xc,%edx
f0101c88:	39 d0                	cmp    %edx,%eax
f0101c8a:	74 19                	je     f0101ca5 <mem_init+0x7ef>
f0101c8c:	68 64 6f 10 f0       	push   $0xf0106f64
f0101c91:	68 85 68 10 f0       	push   $0xf0106885
f0101c96:	68 65 04 00 00       	push   $0x465
f0101c9b:	68 5f 68 10 f0       	push   $0xf010685f
f0101ca0:	e8 9b e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ca5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101caa:	74 19                	je     f0101cc5 <mem_init+0x80f>
f0101cac:	68 8d 6a 10 f0       	push   $0xf0106a8d
f0101cb1:	68 85 68 10 f0       	push   $0xf0106885
f0101cb6:	68 66 04 00 00       	push   $0x466
f0101cbb:	68 5f 68 10 f0       	push   $0xf010685f
f0101cc0:	e8 7b e3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101cc5:	83 ec 0c             	sub    $0xc,%esp
f0101cc8:	6a 00                	push   $0x0
f0101cca:	e8 c9 f3 ff ff       	call   f0101098 <page_alloc>
f0101ccf:	83 c4 10             	add    $0x10,%esp
f0101cd2:	85 c0                	test   %eax,%eax
f0101cd4:	74 19                	je     f0101cef <mem_init+0x839>
f0101cd6:	68 19 6a 10 f0       	push   $0xf0106a19
f0101cdb:	68 85 68 10 f0       	push   $0xf0106885
f0101ce0:	68 69 04 00 00       	push   $0x469
f0101ce5:	68 5f 68 10 f0       	push   $0xf010685f
f0101cea:	e8 51 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cef:	6a 02                	push   $0x2
f0101cf1:	68 00 10 00 00       	push   $0x1000
f0101cf6:	56                   	push   %esi
f0101cf7:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0101cfd:	e8 c4 f6 ff ff       	call   f01013c6 <page_insert>
f0101d02:	83 c4 10             	add    $0x10,%esp
f0101d05:	85 c0                	test   %eax,%eax
f0101d07:	74 19                	je     f0101d22 <mem_init+0x86c>
f0101d09:	68 28 6f 10 f0       	push   $0xf0106f28
f0101d0e:	68 85 68 10 f0       	push   $0xf0106885
f0101d13:	68 6c 04 00 00       	push   $0x46c
f0101d18:	68 5f 68 10 f0       	push   $0xf010685f
f0101d1d:	e8 1e e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d22:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d27:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
f0101d2c:	e8 3a ee ff ff       	call   f0100b6b <check_va2pa>
f0101d31:	89 f2                	mov    %esi,%edx
f0101d33:	2b 15 90 fe 20 f0    	sub    0xf020fe90,%edx
f0101d39:	c1 fa 03             	sar    $0x3,%edx
f0101d3c:	c1 e2 0c             	shl    $0xc,%edx
f0101d3f:	39 d0                	cmp    %edx,%eax
f0101d41:	74 19                	je     f0101d5c <mem_init+0x8a6>
f0101d43:	68 64 6f 10 f0       	push   $0xf0106f64
f0101d48:	68 85 68 10 f0       	push   $0xf0106885
f0101d4d:	68 6d 04 00 00       	push   $0x46d
f0101d52:	68 5f 68 10 f0       	push   $0xf010685f
f0101d57:	e8 e4 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d5c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d61:	74 19                	je     f0101d7c <mem_init+0x8c6>
f0101d63:	68 8d 6a 10 f0       	push   $0xf0106a8d
f0101d68:	68 85 68 10 f0       	push   $0xf0106885
f0101d6d:	68 6e 04 00 00       	push   $0x46e
f0101d72:	68 5f 68 10 f0       	push   $0xf010685f
f0101d77:	e8 c4 e2 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101d7c:	83 ec 0c             	sub    $0xc,%esp
f0101d7f:	6a 00                	push   $0x0
f0101d81:	e8 12 f3 ff ff       	call   f0101098 <page_alloc>
f0101d86:	83 c4 10             	add    $0x10,%esp
f0101d89:	85 c0                	test   %eax,%eax
f0101d8b:	74 19                	je     f0101da6 <mem_init+0x8f0>
f0101d8d:	68 19 6a 10 f0       	push   $0xf0106a19
f0101d92:	68 85 68 10 f0       	push   $0xf0106885
f0101d97:	68 72 04 00 00       	push   $0x472
f0101d9c:	68 5f 68 10 f0       	push   $0xf010685f
f0101da1:	e8 9a e2 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101da6:	8b 15 8c fe 20 f0    	mov    0xf020fe8c,%edx
f0101dac:	8b 02                	mov    (%edx),%eax
f0101dae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101db3:	89 c1                	mov    %eax,%ecx
f0101db5:	c1 e9 0c             	shr    $0xc,%ecx
f0101db8:	3b 0d 88 fe 20 f0    	cmp    0xf020fe88,%ecx
f0101dbe:	72 15                	jb     f0101dd5 <mem_init+0x91f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101dc0:	50                   	push   %eax
f0101dc1:	68 a4 62 10 f0       	push   $0xf01062a4
f0101dc6:	68 75 04 00 00       	push   $0x475
f0101dcb:	68 5f 68 10 f0       	push   $0xf010685f
f0101dd0:	e8 6b e2 ff ff       	call   f0100040 <_panic>
f0101dd5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101dda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ddd:	83 ec 04             	sub    $0x4,%esp
f0101de0:	6a 00                	push   $0x0
f0101de2:	68 00 10 00 00       	push   $0x1000
f0101de7:	52                   	push   %edx
f0101de8:	e8 99 f3 ff ff       	call   f0101186 <pgdir_walk>
f0101ded:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101df0:	8d 51 04             	lea    0x4(%ecx),%edx
f0101df3:	83 c4 10             	add    $0x10,%esp
f0101df6:	39 d0                	cmp    %edx,%eax
f0101df8:	74 19                	je     f0101e13 <mem_init+0x95d>
f0101dfa:	68 94 6f 10 f0       	push   $0xf0106f94
f0101dff:	68 85 68 10 f0       	push   $0xf0106885
f0101e04:	68 76 04 00 00       	push   $0x476
f0101e09:	68 5f 68 10 f0       	push   $0xf010685f
f0101e0e:	e8 2d e2 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e13:	6a 06                	push   $0x6
f0101e15:	68 00 10 00 00       	push   $0x1000
f0101e1a:	56                   	push   %esi
f0101e1b:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0101e21:	e8 a0 f5 ff ff       	call   f01013c6 <page_insert>
f0101e26:	83 c4 10             	add    $0x10,%esp
f0101e29:	85 c0                	test   %eax,%eax
f0101e2b:	74 19                	je     f0101e46 <mem_init+0x990>
f0101e2d:	68 d4 6f 10 f0       	push   $0xf0106fd4
f0101e32:	68 85 68 10 f0       	push   $0xf0106885
f0101e37:	68 79 04 00 00       	push   $0x479
f0101e3c:	68 5f 68 10 f0       	push   $0xf010685f
f0101e41:	e8 fa e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e46:	8b 3d 8c fe 20 f0    	mov    0xf020fe8c,%edi
f0101e4c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e51:	89 f8                	mov    %edi,%eax
f0101e53:	e8 13 ed ff ff       	call   f0100b6b <check_va2pa>
f0101e58:	89 f2                	mov    %esi,%edx
f0101e5a:	2b 15 90 fe 20 f0    	sub    0xf020fe90,%edx
f0101e60:	c1 fa 03             	sar    $0x3,%edx
f0101e63:	c1 e2 0c             	shl    $0xc,%edx
f0101e66:	39 d0                	cmp    %edx,%eax
f0101e68:	74 19                	je     f0101e83 <mem_init+0x9cd>
f0101e6a:	68 64 6f 10 f0       	push   $0xf0106f64
f0101e6f:	68 85 68 10 f0       	push   $0xf0106885
f0101e74:	68 7a 04 00 00       	push   $0x47a
f0101e79:	68 5f 68 10 f0       	push   $0xf010685f
f0101e7e:	e8 bd e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e83:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e88:	74 19                	je     f0101ea3 <mem_init+0x9ed>
f0101e8a:	68 8d 6a 10 f0       	push   $0xf0106a8d
f0101e8f:	68 85 68 10 f0       	push   $0xf0106885
f0101e94:	68 7b 04 00 00       	push   $0x47b
f0101e99:	68 5f 68 10 f0       	push   $0xf010685f
f0101e9e:	e8 9d e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ea3:	83 ec 04             	sub    $0x4,%esp
f0101ea6:	6a 00                	push   $0x0
f0101ea8:	68 00 10 00 00       	push   $0x1000
f0101ead:	57                   	push   %edi
f0101eae:	e8 d3 f2 ff ff       	call   f0101186 <pgdir_walk>
f0101eb3:	83 c4 10             	add    $0x10,%esp
f0101eb6:	f6 00 04             	testb  $0x4,(%eax)
f0101eb9:	75 19                	jne    f0101ed4 <mem_init+0xa1e>
f0101ebb:	68 14 70 10 f0       	push   $0xf0107014
f0101ec0:	68 85 68 10 f0       	push   $0xf0106885
f0101ec5:	68 7c 04 00 00       	push   $0x47c
f0101eca:	68 5f 68 10 f0       	push   $0xf010685f
f0101ecf:	e8 6c e1 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101ed4:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
f0101ed9:	f6 00 04             	testb  $0x4,(%eax)
f0101edc:	75 19                	jne    f0101ef7 <mem_init+0xa41>
f0101ede:	68 9e 6a 10 f0       	push   $0xf0106a9e
f0101ee3:	68 85 68 10 f0       	push   $0xf0106885
f0101ee8:	68 7d 04 00 00       	push   $0x47d
f0101eed:	68 5f 68 10 f0       	push   $0xf010685f
f0101ef2:	e8 49 e1 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ef7:	6a 02                	push   $0x2
f0101ef9:	68 00 10 00 00       	push   $0x1000
f0101efe:	56                   	push   %esi
f0101eff:	50                   	push   %eax
f0101f00:	e8 c1 f4 ff ff       	call   f01013c6 <page_insert>
f0101f05:	83 c4 10             	add    $0x10,%esp
f0101f08:	85 c0                	test   %eax,%eax
f0101f0a:	74 19                	je     f0101f25 <mem_init+0xa6f>
f0101f0c:	68 28 6f 10 f0       	push   $0xf0106f28
f0101f11:	68 85 68 10 f0       	push   $0xf0106885
f0101f16:	68 80 04 00 00       	push   $0x480
f0101f1b:	68 5f 68 10 f0       	push   $0xf010685f
f0101f20:	e8 1b e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101f25:	83 ec 04             	sub    $0x4,%esp
f0101f28:	6a 00                	push   $0x0
f0101f2a:	68 00 10 00 00       	push   $0x1000
f0101f2f:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0101f35:	e8 4c f2 ff ff       	call   f0101186 <pgdir_walk>
f0101f3a:	83 c4 10             	add    $0x10,%esp
f0101f3d:	f6 00 02             	testb  $0x2,(%eax)
f0101f40:	75 19                	jne    f0101f5b <mem_init+0xaa5>
f0101f42:	68 48 70 10 f0       	push   $0xf0107048
f0101f47:	68 85 68 10 f0       	push   $0xf0106885
f0101f4c:	68 81 04 00 00       	push   $0x481
f0101f51:	68 5f 68 10 f0       	push   $0xf010685f
f0101f56:	e8 e5 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f5b:	83 ec 04             	sub    $0x4,%esp
f0101f5e:	6a 00                	push   $0x0
f0101f60:	68 00 10 00 00       	push   $0x1000
f0101f65:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0101f6b:	e8 16 f2 ff ff       	call   f0101186 <pgdir_walk>
f0101f70:	83 c4 10             	add    $0x10,%esp
f0101f73:	f6 00 04             	testb  $0x4,(%eax)
f0101f76:	74 19                	je     f0101f91 <mem_init+0xadb>
f0101f78:	68 7c 70 10 f0       	push   $0xf010707c
f0101f7d:	68 85 68 10 f0       	push   $0xf0106885
f0101f82:	68 82 04 00 00       	push   $0x482
f0101f87:	68 5f 68 10 f0       	push   $0xf010685f
f0101f8c:	e8 af e0 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f91:	6a 02                	push   $0x2
f0101f93:	68 00 00 40 00       	push   $0x400000
f0101f98:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f9b:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0101fa1:	e8 20 f4 ff ff       	call   f01013c6 <page_insert>
f0101fa6:	83 c4 10             	add    $0x10,%esp
f0101fa9:	85 c0                	test   %eax,%eax
f0101fab:	78 19                	js     f0101fc6 <mem_init+0xb10>
f0101fad:	68 b4 70 10 f0       	push   $0xf01070b4
f0101fb2:	68 85 68 10 f0       	push   $0xf0106885
f0101fb7:	68 85 04 00 00       	push   $0x485
f0101fbc:	68 5f 68 10 f0       	push   $0xf010685f
f0101fc1:	e8 7a e0 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101fc6:	6a 02                	push   $0x2
f0101fc8:	68 00 10 00 00       	push   $0x1000
f0101fcd:	53                   	push   %ebx
f0101fce:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0101fd4:	e8 ed f3 ff ff       	call   f01013c6 <page_insert>
f0101fd9:	83 c4 10             	add    $0x10,%esp
f0101fdc:	85 c0                	test   %eax,%eax
f0101fde:	74 19                	je     f0101ff9 <mem_init+0xb43>
f0101fe0:	68 ec 70 10 f0       	push   $0xf01070ec
f0101fe5:	68 85 68 10 f0       	push   $0xf0106885
f0101fea:	68 88 04 00 00       	push   $0x488
f0101fef:	68 5f 68 10 f0       	push   $0xf010685f
f0101ff4:	e8 47 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ff9:	83 ec 04             	sub    $0x4,%esp
f0101ffc:	6a 00                	push   $0x0
f0101ffe:	68 00 10 00 00       	push   $0x1000
f0102003:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0102009:	e8 78 f1 ff ff       	call   f0101186 <pgdir_walk>
f010200e:	83 c4 10             	add    $0x10,%esp
f0102011:	f6 00 04             	testb  $0x4,(%eax)
f0102014:	74 19                	je     f010202f <mem_init+0xb79>
f0102016:	68 7c 70 10 f0       	push   $0xf010707c
f010201b:	68 85 68 10 f0       	push   $0xf0106885
f0102020:	68 89 04 00 00       	push   $0x489
f0102025:	68 5f 68 10 f0       	push   $0xf010685f
f010202a:	e8 11 e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010202f:	8b 3d 8c fe 20 f0    	mov    0xf020fe8c,%edi
f0102035:	ba 00 00 00 00       	mov    $0x0,%edx
f010203a:	89 f8                	mov    %edi,%eax
f010203c:	e8 2a eb ff ff       	call   f0100b6b <check_va2pa>
f0102041:	89 c1                	mov    %eax,%ecx
f0102043:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102046:	89 d8                	mov    %ebx,%eax
f0102048:	2b 05 90 fe 20 f0    	sub    0xf020fe90,%eax
f010204e:	c1 f8 03             	sar    $0x3,%eax
f0102051:	c1 e0 0c             	shl    $0xc,%eax
f0102054:	39 c1                	cmp    %eax,%ecx
f0102056:	74 19                	je     f0102071 <mem_init+0xbbb>
f0102058:	68 28 71 10 f0       	push   $0xf0107128
f010205d:	68 85 68 10 f0       	push   $0xf0106885
f0102062:	68 8c 04 00 00       	push   $0x48c
f0102067:	68 5f 68 10 f0       	push   $0xf010685f
f010206c:	e8 cf df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102071:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102076:	89 f8                	mov    %edi,%eax
f0102078:	e8 ee ea ff ff       	call   f0100b6b <check_va2pa>
f010207d:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102080:	74 19                	je     f010209b <mem_init+0xbe5>
f0102082:	68 54 71 10 f0       	push   $0xf0107154
f0102087:	68 85 68 10 f0       	push   $0xf0106885
f010208c:	68 8d 04 00 00       	push   $0x48d
f0102091:	68 5f 68 10 f0       	push   $0xf010685f
f0102096:	e8 a5 df ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010209b:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01020a0:	74 19                	je     f01020bb <mem_init+0xc05>
f01020a2:	68 b4 6a 10 f0       	push   $0xf0106ab4
f01020a7:	68 85 68 10 f0       	push   $0xf0106885
f01020ac:	68 8f 04 00 00       	push   $0x48f
f01020b1:	68 5f 68 10 f0       	push   $0xf010685f
f01020b6:	e8 85 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020bb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020c0:	74 19                	je     f01020db <mem_init+0xc25>
f01020c2:	68 c5 6a 10 f0       	push   $0xf0106ac5
f01020c7:	68 85 68 10 f0       	push   $0xf0106885
f01020cc:	68 90 04 00 00       	push   $0x490
f01020d1:	68 5f 68 10 f0       	push   $0xf010685f
f01020d6:	e8 65 df ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01020db:	83 ec 0c             	sub    $0xc,%esp
f01020de:	6a 00                	push   $0x0
f01020e0:	e8 b3 ef ff ff       	call   f0101098 <page_alloc>
f01020e5:	83 c4 10             	add    $0x10,%esp
f01020e8:	85 c0                	test   %eax,%eax
f01020ea:	74 04                	je     f01020f0 <mem_init+0xc3a>
f01020ec:	39 c6                	cmp    %eax,%esi
f01020ee:	74 19                	je     f0102109 <mem_init+0xc53>
f01020f0:	68 84 71 10 f0       	push   $0xf0107184
f01020f5:	68 85 68 10 f0       	push   $0xf0106885
f01020fa:	68 93 04 00 00       	push   $0x493
f01020ff:	68 5f 68 10 f0       	push   $0xf010685f
f0102104:	e8 37 df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102109:	83 ec 08             	sub    $0x8,%esp
f010210c:	6a 00                	push   $0x0
f010210e:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0102114:	e8 60 f2 ff ff       	call   f0101379 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102119:	8b 3d 8c fe 20 f0    	mov    0xf020fe8c,%edi
f010211f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102124:	89 f8                	mov    %edi,%eax
f0102126:	e8 40 ea ff ff       	call   f0100b6b <check_va2pa>
f010212b:	83 c4 10             	add    $0x10,%esp
f010212e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102131:	74 19                	je     f010214c <mem_init+0xc96>
f0102133:	68 a8 71 10 f0       	push   $0xf01071a8
f0102138:	68 85 68 10 f0       	push   $0xf0106885
f010213d:	68 97 04 00 00       	push   $0x497
f0102142:	68 5f 68 10 f0       	push   $0xf010685f
f0102147:	e8 f4 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010214c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102151:	89 f8                	mov    %edi,%eax
f0102153:	e8 13 ea ff ff       	call   f0100b6b <check_va2pa>
f0102158:	89 da                	mov    %ebx,%edx
f010215a:	2b 15 90 fe 20 f0    	sub    0xf020fe90,%edx
f0102160:	c1 fa 03             	sar    $0x3,%edx
f0102163:	c1 e2 0c             	shl    $0xc,%edx
f0102166:	39 d0                	cmp    %edx,%eax
f0102168:	74 19                	je     f0102183 <mem_init+0xccd>
f010216a:	68 54 71 10 f0       	push   $0xf0107154
f010216f:	68 85 68 10 f0       	push   $0xf0106885
f0102174:	68 98 04 00 00       	push   $0x498
f0102179:	68 5f 68 10 f0       	push   $0xf010685f
f010217e:	e8 bd de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102183:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102188:	74 19                	je     f01021a3 <mem_init+0xced>
f010218a:	68 6b 6a 10 f0       	push   $0xf0106a6b
f010218f:	68 85 68 10 f0       	push   $0xf0106885
f0102194:	68 99 04 00 00       	push   $0x499
f0102199:	68 5f 68 10 f0       	push   $0xf010685f
f010219e:	e8 9d de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01021a3:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021a8:	74 19                	je     f01021c3 <mem_init+0xd0d>
f01021aa:	68 c5 6a 10 f0       	push   $0xf0106ac5
f01021af:	68 85 68 10 f0       	push   $0xf0106885
f01021b4:	68 9a 04 00 00       	push   $0x49a
f01021b9:	68 5f 68 10 f0       	push   $0xf010685f
f01021be:	e8 7d de ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01021c3:	6a 00                	push   $0x0
f01021c5:	68 00 10 00 00       	push   $0x1000
f01021ca:	53                   	push   %ebx
f01021cb:	57                   	push   %edi
f01021cc:	e8 f5 f1 ff ff       	call   f01013c6 <page_insert>
f01021d1:	83 c4 10             	add    $0x10,%esp
f01021d4:	85 c0                	test   %eax,%eax
f01021d6:	74 19                	je     f01021f1 <mem_init+0xd3b>
f01021d8:	68 cc 71 10 f0       	push   $0xf01071cc
f01021dd:	68 85 68 10 f0       	push   $0xf0106885
f01021e2:	68 9d 04 00 00       	push   $0x49d
f01021e7:	68 5f 68 10 f0       	push   $0xf010685f
f01021ec:	e8 4f de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01021f1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021f6:	75 19                	jne    f0102211 <mem_init+0xd5b>
f01021f8:	68 d6 6a 10 f0       	push   $0xf0106ad6
f01021fd:	68 85 68 10 f0       	push   $0xf0106885
f0102202:	68 9e 04 00 00       	push   $0x49e
f0102207:	68 5f 68 10 f0       	push   $0xf010685f
f010220c:	e8 2f de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102211:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102214:	74 19                	je     f010222f <mem_init+0xd79>
f0102216:	68 e2 6a 10 f0       	push   $0xf0106ae2
f010221b:	68 85 68 10 f0       	push   $0xf0106885
f0102220:	68 9f 04 00 00       	push   $0x49f
f0102225:	68 5f 68 10 f0       	push   $0xf010685f
f010222a:	e8 11 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010222f:	83 ec 08             	sub    $0x8,%esp
f0102232:	68 00 10 00 00       	push   $0x1000
f0102237:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f010223d:	e8 37 f1 ff ff       	call   f0101379 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102242:	8b 3d 8c fe 20 f0    	mov    0xf020fe8c,%edi
f0102248:	ba 00 00 00 00       	mov    $0x0,%edx
f010224d:	89 f8                	mov    %edi,%eax
f010224f:	e8 17 e9 ff ff       	call   f0100b6b <check_va2pa>
f0102254:	83 c4 10             	add    $0x10,%esp
f0102257:	83 f8 ff             	cmp    $0xffffffff,%eax
f010225a:	74 19                	je     f0102275 <mem_init+0xdbf>
f010225c:	68 a8 71 10 f0       	push   $0xf01071a8
f0102261:	68 85 68 10 f0       	push   $0xf0106885
f0102266:	68 a3 04 00 00       	push   $0x4a3
f010226b:	68 5f 68 10 f0       	push   $0xf010685f
f0102270:	e8 cb dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102275:	ba 00 10 00 00       	mov    $0x1000,%edx
f010227a:	89 f8                	mov    %edi,%eax
f010227c:	e8 ea e8 ff ff       	call   f0100b6b <check_va2pa>
f0102281:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102284:	74 19                	je     f010229f <mem_init+0xde9>
f0102286:	68 04 72 10 f0       	push   $0xf0107204
f010228b:	68 85 68 10 f0       	push   $0xf0106885
f0102290:	68 a4 04 00 00       	push   $0x4a4
f0102295:	68 5f 68 10 f0       	push   $0xf010685f
f010229a:	e8 a1 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010229f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022a4:	74 19                	je     f01022bf <mem_init+0xe09>
f01022a6:	68 f7 6a 10 f0       	push   $0xf0106af7
f01022ab:	68 85 68 10 f0       	push   $0xf0106885
f01022b0:	68 a5 04 00 00       	push   $0x4a5
f01022b5:	68 5f 68 10 f0       	push   $0xf010685f
f01022ba:	e8 81 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01022bf:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022c4:	74 19                	je     f01022df <mem_init+0xe29>
f01022c6:	68 c5 6a 10 f0       	push   $0xf0106ac5
f01022cb:	68 85 68 10 f0       	push   $0xf0106885
f01022d0:	68 a6 04 00 00       	push   $0x4a6
f01022d5:	68 5f 68 10 f0       	push   $0xf010685f
f01022da:	e8 61 dd ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01022df:	83 ec 0c             	sub    $0xc,%esp
f01022e2:	6a 00                	push   $0x0
f01022e4:	e8 af ed ff ff       	call   f0101098 <page_alloc>
f01022e9:	83 c4 10             	add    $0x10,%esp
f01022ec:	39 c3                	cmp    %eax,%ebx
f01022ee:	75 04                	jne    f01022f4 <mem_init+0xe3e>
f01022f0:	85 c0                	test   %eax,%eax
f01022f2:	75 19                	jne    f010230d <mem_init+0xe57>
f01022f4:	68 2c 72 10 f0       	push   $0xf010722c
f01022f9:	68 85 68 10 f0       	push   $0xf0106885
f01022fe:	68 a9 04 00 00       	push   $0x4a9
f0102303:	68 5f 68 10 f0       	push   $0xf010685f
f0102308:	e8 33 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010230d:	83 ec 0c             	sub    $0xc,%esp
f0102310:	6a 00                	push   $0x0
f0102312:	e8 81 ed ff ff       	call   f0101098 <page_alloc>
f0102317:	83 c4 10             	add    $0x10,%esp
f010231a:	85 c0                	test   %eax,%eax
f010231c:	74 19                	je     f0102337 <mem_init+0xe81>
f010231e:	68 19 6a 10 f0       	push   $0xf0106a19
f0102323:	68 85 68 10 f0       	push   $0xf0106885
f0102328:	68 ac 04 00 00       	push   $0x4ac
f010232d:	68 5f 68 10 f0       	push   $0xf010685f
f0102332:	e8 09 dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102337:	8b 0d 8c fe 20 f0    	mov    0xf020fe8c,%ecx
f010233d:	8b 11                	mov    (%ecx),%edx
f010233f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102345:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102348:	2b 05 90 fe 20 f0    	sub    0xf020fe90,%eax
f010234e:	c1 f8 03             	sar    $0x3,%eax
f0102351:	c1 e0 0c             	shl    $0xc,%eax
f0102354:	39 c2                	cmp    %eax,%edx
f0102356:	74 19                	je     f0102371 <mem_init+0xebb>
f0102358:	68 d0 6e 10 f0       	push   $0xf0106ed0
f010235d:	68 85 68 10 f0       	push   $0xf0106885
f0102362:	68 af 04 00 00       	push   $0x4af
f0102367:	68 5f 68 10 f0       	push   $0xf010685f
f010236c:	e8 cf dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102371:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102377:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010237a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010237f:	74 19                	je     f010239a <mem_init+0xee4>
f0102381:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0102386:	68 85 68 10 f0       	push   $0xf0106885
f010238b:	68 b1 04 00 00       	push   $0x4b1
f0102390:	68 5f 68 10 f0       	push   $0xf010685f
f0102395:	e8 a6 dc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010239a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010239d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01023a3:	83 ec 0c             	sub    $0xc,%esp
f01023a6:	50                   	push   %eax
f01023a7:	e8 5d ed ff ff       	call   f0101109 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01023ac:	83 c4 0c             	add    $0xc,%esp
f01023af:	6a 01                	push   $0x1
f01023b1:	68 00 10 40 00       	push   $0x401000
f01023b6:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f01023bc:	e8 c5 ed ff ff       	call   f0101186 <pgdir_walk>
f01023c1:	89 c7                	mov    %eax,%edi
f01023c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01023c6:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
f01023cb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01023ce:	8b 40 04             	mov    0x4(%eax),%eax
f01023d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023d6:	8b 0d 88 fe 20 f0    	mov    0xf020fe88,%ecx
f01023dc:	89 c2                	mov    %eax,%edx
f01023de:	c1 ea 0c             	shr    $0xc,%edx
f01023e1:	83 c4 10             	add    $0x10,%esp
f01023e4:	39 ca                	cmp    %ecx,%edx
f01023e6:	72 15                	jb     f01023fd <mem_init+0xf47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023e8:	50                   	push   %eax
f01023e9:	68 a4 62 10 f0       	push   $0xf01062a4
f01023ee:	68 b8 04 00 00       	push   $0x4b8
f01023f3:	68 5f 68 10 f0       	push   $0xf010685f
f01023f8:	e8 43 dc ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01023fd:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102402:	39 c7                	cmp    %eax,%edi
f0102404:	74 19                	je     f010241f <mem_init+0xf69>
f0102406:	68 08 6b 10 f0       	push   $0xf0106b08
f010240b:	68 85 68 10 f0       	push   $0xf0106885
f0102410:	68 b9 04 00 00       	push   $0x4b9
f0102415:	68 5f 68 10 f0       	push   $0xf010685f
f010241a:	e8 21 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010241f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102422:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102429:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010242c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102432:	2b 05 90 fe 20 f0    	sub    0xf020fe90,%eax
f0102438:	c1 f8 03             	sar    $0x3,%eax
f010243b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010243e:	89 c2                	mov    %eax,%edx
f0102440:	c1 ea 0c             	shr    $0xc,%edx
f0102443:	39 d1                	cmp    %edx,%ecx
f0102445:	77 12                	ja     f0102459 <mem_init+0xfa3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102447:	50                   	push   %eax
f0102448:	68 a4 62 10 f0       	push   $0xf01062a4
f010244d:	6a 58                	push   $0x58
f010244f:	68 6b 68 10 f0       	push   $0xf010686b
f0102454:	e8 e7 db ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102459:	83 ec 04             	sub    $0x4,%esp
f010245c:	68 00 10 00 00       	push   $0x1000
f0102461:	68 ff 00 00 00       	push   $0xff
f0102466:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010246b:	50                   	push   %eax
f010246c:	e8 55 31 00 00       	call   f01055c6 <memset>
	page_free(pp0);
f0102471:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102474:	89 3c 24             	mov    %edi,(%esp)
f0102477:	e8 8d ec ff ff       	call   f0101109 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010247c:	83 c4 0c             	add    $0xc,%esp
f010247f:	6a 01                	push   $0x1
f0102481:	6a 00                	push   $0x0
f0102483:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0102489:	e8 f8 ec ff ff       	call   f0101186 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010248e:	89 fa                	mov    %edi,%edx
f0102490:	2b 15 90 fe 20 f0    	sub    0xf020fe90,%edx
f0102496:	c1 fa 03             	sar    $0x3,%edx
f0102499:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010249c:	89 d0                	mov    %edx,%eax
f010249e:	c1 e8 0c             	shr    $0xc,%eax
f01024a1:	83 c4 10             	add    $0x10,%esp
f01024a4:	3b 05 88 fe 20 f0    	cmp    0xf020fe88,%eax
f01024aa:	72 12                	jb     f01024be <mem_init+0x1008>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024ac:	52                   	push   %edx
f01024ad:	68 a4 62 10 f0       	push   $0xf01062a4
f01024b2:	6a 58                	push   $0x58
f01024b4:	68 6b 68 10 f0       	push   $0xf010686b
f01024b9:	e8 82 db ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01024be:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01024c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01024c7:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01024cd:	f6 00 01             	testb  $0x1,(%eax)
f01024d0:	74 19                	je     f01024eb <mem_init+0x1035>
f01024d2:	68 20 6b 10 f0       	push   $0xf0106b20
f01024d7:	68 85 68 10 f0       	push   $0xf0106885
f01024dc:	68 c3 04 00 00       	push   $0x4c3
f01024e1:	68 5f 68 10 f0       	push   $0xf010685f
f01024e6:	e8 55 db ff ff       	call   f0100040 <_panic>
f01024eb:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01024ee:	39 d0                	cmp    %edx,%eax
f01024f0:	75 db                	jne    f01024cd <mem_init+0x1017>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01024f2:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
f01024f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01024fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102500:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102506:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102509:	89 0d 40 f2 20 f0    	mov    %ecx,0xf020f240

	// free the pages we took
	page_free(pp0);
f010250f:	83 ec 0c             	sub    $0xc,%esp
f0102512:	50                   	push   %eax
f0102513:	e8 f1 eb ff ff       	call   f0101109 <page_free>
	page_free(pp1);
f0102518:	89 1c 24             	mov    %ebx,(%esp)
f010251b:	e8 e9 eb ff ff       	call   f0101109 <page_free>
	page_free(pp2);
f0102520:	89 34 24             	mov    %esi,(%esp)
f0102523:	e8 e1 eb ff ff       	call   f0101109 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102528:	83 c4 08             	add    $0x8,%esp
f010252b:	68 01 10 00 00       	push   $0x1001
f0102530:	6a 00                	push   $0x0
f0102532:	e8 16 ef ff ff       	call   f010144d <mmio_map_region>
f0102537:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102539:	83 c4 08             	add    $0x8,%esp
f010253c:	68 00 10 00 00       	push   $0x1000
f0102541:	6a 00                	push   $0x0
f0102543:	e8 05 ef ff ff       	call   f010144d <mmio_map_region>
f0102548:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f010254a:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0102550:	83 c4 10             	add    $0x10,%esp
f0102553:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102559:	76 07                	jbe    f0102562 <mem_init+0x10ac>
f010255b:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102560:	76 19                	jbe    f010257b <mem_init+0x10c5>
f0102562:	68 50 72 10 f0       	push   $0xf0107250
f0102567:	68 85 68 10 f0       	push   $0xf0106885
f010256c:	68 d3 04 00 00       	push   $0x4d3
f0102571:	68 5f 68 10 f0       	push   $0xf010685f
f0102576:	e8 c5 da ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f010257b:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0102581:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102587:	77 08                	ja     f0102591 <mem_init+0x10db>
f0102589:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010258f:	77 19                	ja     f01025aa <mem_init+0x10f4>
f0102591:	68 78 72 10 f0       	push   $0xf0107278
f0102596:	68 85 68 10 f0       	push   $0xf0106885
f010259b:	68 d4 04 00 00       	push   $0x4d4
f01025a0:	68 5f 68 10 f0       	push   $0xf010685f
f01025a5:	e8 96 da ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01025aa:	89 da                	mov    %ebx,%edx
f01025ac:	09 f2                	or     %esi,%edx
f01025ae:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01025b4:	74 19                	je     f01025cf <mem_init+0x1119>
f01025b6:	68 a0 72 10 f0       	push   $0xf01072a0
f01025bb:	68 85 68 10 f0       	push   $0xf0106885
f01025c0:	68 d6 04 00 00       	push   $0x4d6
f01025c5:	68 5f 68 10 f0       	push   $0xf010685f
f01025ca:	e8 71 da ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f01025cf:	39 c6                	cmp    %eax,%esi
f01025d1:	73 19                	jae    f01025ec <mem_init+0x1136>
f01025d3:	68 37 6b 10 f0       	push   $0xf0106b37
f01025d8:	68 85 68 10 f0       	push   $0xf0106885
f01025dd:	68 d8 04 00 00       	push   $0x4d8
f01025e2:	68 5f 68 10 f0       	push   $0xf010685f
f01025e7:	e8 54 da ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01025ec:	8b 3d 8c fe 20 f0    	mov    0xf020fe8c,%edi
f01025f2:	89 da                	mov    %ebx,%edx
f01025f4:	89 f8                	mov    %edi,%eax
f01025f6:	e8 70 e5 ff ff       	call   f0100b6b <check_va2pa>
f01025fb:	85 c0                	test   %eax,%eax
f01025fd:	74 19                	je     f0102618 <mem_init+0x1162>
f01025ff:	68 c8 72 10 f0       	push   $0xf01072c8
f0102604:	68 85 68 10 f0       	push   $0xf0106885
f0102609:	68 da 04 00 00       	push   $0x4da
f010260e:	68 5f 68 10 f0       	push   $0xf010685f
f0102613:	e8 28 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102618:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010261e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102621:	89 c2                	mov    %eax,%edx
f0102623:	89 f8                	mov    %edi,%eax
f0102625:	e8 41 e5 ff ff       	call   f0100b6b <check_va2pa>
f010262a:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010262f:	74 19                	je     f010264a <mem_init+0x1194>
f0102631:	68 ec 72 10 f0       	push   $0xf01072ec
f0102636:	68 85 68 10 f0       	push   $0xf0106885
f010263b:	68 db 04 00 00       	push   $0x4db
f0102640:	68 5f 68 10 f0       	push   $0xf010685f
f0102645:	e8 f6 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010264a:	89 f2                	mov    %esi,%edx
f010264c:	89 f8                	mov    %edi,%eax
f010264e:	e8 18 e5 ff ff       	call   f0100b6b <check_va2pa>
f0102653:	85 c0                	test   %eax,%eax
f0102655:	74 19                	je     f0102670 <mem_init+0x11ba>
f0102657:	68 1c 73 10 f0       	push   $0xf010731c
f010265c:	68 85 68 10 f0       	push   $0xf0106885
f0102661:	68 dc 04 00 00       	push   $0x4dc
f0102666:	68 5f 68 10 f0       	push   $0xf010685f
f010266b:	e8 d0 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102670:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102676:	89 f8                	mov    %edi,%eax
f0102678:	e8 ee e4 ff ff       	call   f0100b6b <check_va2pa>
f010267d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102680:	74 19                	je     f010269b <mem_init+0x11e5>
f0102682:	68 40 73 10 f0       	push   $0xf0107340
f0102687:	68 85 68 10 f0       	push   $0xf0106885
f010268c:	68 dd 04 00 00       	push   $0x4dd
f0102691:	68 5f 68 10 f0       	push   $0xf010685f
f0102696:	e8 a5 d9 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010269b:	83 ec 04             	sub    $0x4,%esp
f010269e:	6a 00                	push   $0x0
f01026a0:	53                   	push   %ebx
f01026a1:	57                   	push   %edi
f01026a2:	e8 df ea ff ff       	call   f0101186 <pgdir_walk>
f01026a7:	83 c4 10             	add    $0x10,%esp
f01026aa:	f6 00 1a             	testb  $0x1a,(%eax)
f01026ad:	75 19                	jne    f01026c8 <mem_init+0x1212>
f01026af:	68 6c 73 10 f0       	push   $0xf010736c
f01026b4:	68 85 68 10 f0       	push   $0xf0106885
f01026b9:	68 df 04 00 00       	push   $0x4df
f01026be:	68 5f 68 10 f0       	push   $0xf010685f
f01026c3:	e8 78 d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01026c8:	83 ec 04             	sub    $0x4,%esp
f01026cb:	6a 00                	push   $0x0
f01026cd:	53                   	push   %ebx
f01026ce:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f01026d4:	e8 ad ea ff ff       	call   f0101186 <pgdir_walk>
f01026d9:	8b 00                	mov    (%eax),%eax
f01026db:	83 c4 10             	add    $0x10,%esp
f01026de:	83 e0 04             	and    $0x4,%eax
f01026e1:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01026e4:	74 19                	je     f01026ff <mem_init+0x1249>
f01026e6:	68 b0 73 10 f0       	push   $0xf01073b0
f01026eb:	68 85 68 10 f0       	push   $0xf0106885
f01026f0:	68 e0 04 00 00       	push   $0x4e0
f01026f5:	68 5f 68 10 f0       	push   $0xf010685f
f01026fa:	e8 41 d9 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01026ff:	83 ec 04             	sub    $0x4,%esp
f0102702:	6a 00                	push   $0x0
f0102704:	53                   	push   %ebx
f0102705:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f010270b:	e8 76 ea ff ff       	call   f0101186 <pgdir_walk>
f0102710:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102716:	83 c4 0c             	add    $0xc,%esp
f0102719:	6a 00                	push   $0x0
f010271b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010271e:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0102724:	e8 5d ea ff ff       	call   f0101186 <pgdir_walk>
f0102729:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010272f:	83 c4 0c             	add    $0xc,%esp
f0102732:	6a 00                	push   $0x0
f0102734:	56                   	push   %esi
f0102735:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f010273b:	e8 46 ea ff ff       	call   f0101186 <pgdir_walk>
f0102740:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102746:	c7 04 24 49 6b 10 f0 	movl   $0xf0106b49,(%esp)
f010274d:	e8 1a 11 00 00       	call   f010386c <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102752:	a1 90 fe 20 f0       	mov    0xf020fe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102757:	83 c4 10             	add    $0x10,%esp
f010275a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010275f:	77 15                	ja     f0102776 <mem_init+0x12c0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102761:	50                   	push   %eax
f0102762:	68 c8 62 10 f0       	push   $0xf01062c8
f0102767:	68 ca 00 00 00       	push   $0xca
f010276c:	68 5f 68 10 f0       	push   $0xf010685f
f0102771:	e8 ca d8 ff ff       	call   f0100040 <_panic>
f0102776:	83 ec 08             	sub    $0x8,%esp
f0102779:	6a 04                	push   $0x4
f010277b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102780:	50                   	push   %eax
f0102781:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102786:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010278b:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
f0102790:	e8 87 ea ff ff       	call   f010121c <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102795:	a1 48 f2 20 f0       	mov    0xf020f248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010279a:	83 c4 10             	add    $0x10,%esp
f010279d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027a2:	77 15                	ja     f01027b9 <mem_init+0x1303>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027a4:	50                   	push   %eax
f01027a5:	68 c8 62 10 f0       	push   $0xf01062c8
f01027aa:	68 d4 00 00 00       	push   $0xd4
f01027af:	68 5f 68 10 f0       	push   $0xf010685f
f01027b4:	e8 87 d8 ff ff       	call   f0100040 <_panic>
f01027b9:	83 ec 08             	sub    $0x8,%esp
f01027bc:	6a 04                	push   $0x4
f01027be:	05 00 00 00 10       	add    $0x10000000,%eax
f01027c3:	50                   	push   %eax
f01027c4:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01027c9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01027ce:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
f01027d3:	e8 44 ea ff ff       	call   f010121c <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027d8:	83 c4 10             	add    $0x10,%esp
f01027db:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f01027e0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027e5:	77 15                	ja     f01027fc <mem_init+0x1346>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027e7:	50                   	push   %eax
f01027e8:	68 c8 62 10 f0       	push   $0xf01062c8
f01027ed:	68 e2 00 00 00       	push   $0xe2
f01027f2:	68 5f 68 10 f0       	push   $0xf010685f
f01027f7:	e8 44 d8 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01027fc:	83 ec 08             	sub    $0x8,%esp
f01027ff:	6a 02                	push   $0x2
f0102801:	68 00 60 11 00       	push   $0x116000
f0102806:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010280b:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102810:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
f0102815:	e8 02 ea ff ff       	call   f010121c <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KERNBASE, ROUNDUP(~0 - KERNBASE, PGSIZE), 0, PTE_W);
f010281a:	83 c4 08             	add    $0x8,%esp
f010281d:	6a 02                	push   $0x2
f010281f:	6a 00                	push   $0x0
f0102821:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102826:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010282b:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
f0102830:	e8 e7 e9 ff ff       	call   f010121c <boot_map_region>
f0102835:	c7 45 c4 00 10 21 f0 	movl   $0xf0211000,-0x3c(%ebp)
f010283c:	83 c4 10             	add    $0x10,%esp
f010283f:	bb 00 10 21 f0       	mov    $0xf0211000,%ebx
f0102844:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102849:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010284f:	77 15                	ja     f0102866 <mem_init+0x13b0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102851:	53                   	push   %ebx
f0102852:	68 c8 62 10 f0       	push   $0xf01062c8
f0102857:	68 26 01 00 00       	push   $0x126
f010285c:	68 5f 68 10 f0       	push   $0xf010685f
f0102861:	e8 da d7 ff ff       	call   f0100040 <_panic>

	uint32_t kstacktop_i;

	for (int i=0; i<NCPU; i++) {
		kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(&percpu_kstacks[i]), PTE_W );
f0102866:	83 ec 08             	sub    $0x8,%esp
f0102869:	6a 02                	push   $0x2
f010286b:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102871:	50                   	push   %eax
f0102872:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102877:	89 f2                	mov    %esi,%edx
f0102879:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
f010287e:	e8 99 e9 ff ff       	call   f010121c <boot_map_region>
f0102883:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102889:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//
	// LAB 4: Your code here:

	uint32_t kstacktop_i;

	for (int i=0; i<NCPU; i++) {
f010288f:	83 c4 10             	add    $0x10,%esp
f0102892:	b8 00 10 25 f0       	mov    $0xf0251000,%eax
f0102897:	39 d8                	cmp    %ebx,%eax
f0102899:	75 ae                	jne    f0102849 <mem_init+0x1393>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010289b:	8b 3d 8c fe 20 f0    	mov    0xf020fe8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01028a1:	a1 88 fe 20 f0       	mov    0xf020fe88,%eax
f01028a6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01028a9:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01028b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01028b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028b8:	8b 35 90 fe 20 f0    	mov    0xf020fe90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028be:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01028c1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01028c6:	eb 55                	jmp    f010291d <mem_init+0x1467>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028c8:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01028ce:	89 f8                	mov    %edi,%eax
f01028d0:	e8 96 e2 ff ff       	call   f0100b6b <check_va2pa>
f01028d5:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01028dc:	77 15                	ja     f01028f3 <mem_init+0x143d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028de:	56                   	push   %esi
f01028df:	68 c8 62 10 f0       	push   $0xf01062c8
f01028e4:	68 f4 03 00 00       	push   $0x3f4
f01028e9:	68 5f 68 10 f0       	push   $0xf010685f
f01028ee:	e8 4d d7 ff ff       	call   f0100040 <_panic>
f01028f3:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01028fa:	39 c2                	cmp    %eax,%edx
f01028fc:	74 19                	je     f0102917 <mem_init+0x1461>
f01028fe:	68 e4 73 10 f0       	push   $0xf01073e4
f0102903:	68 85 68 10 f0       	push   $0xf0106885
f0102908:	68 f4 03 00 00       	push   $0x3f4
f010290d:	68 5f 68 10 f0       	push   $0xf010685f
f0102912:	e8 29 d7 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102917:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010291d:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102920:	77 a6                	ja     f01028c8 <mem_init+0x1412>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102922:	8b 35 48 f2 20 f0    	mov    0xf020f248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102928:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010292b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102930:	89 da                	mov    %ebx,%edx
f0102932:	89 f8                	mov    %edi,%eax
f0102934:	e8 32 e2 ff ff       	call   f0100b6b <check_va2pa>
f0102939:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102940:	77 15                	ja     f0102957 <mem_init+0x14a1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102942:	56                   	push   %esi
f0102943:	68 c8 62 10 f0       	push   $0xf01062c8
f0102948:	68 f9 03 00 00       	push   $0x3f9
f010294d:	68 5f 68 10 f0       	push   $0xf010685f
f0102952:	e8 e9 d6 ff ff       	call   f0100040 <_panic>
f0102957:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f010295e:	39 d0                	cmp    %edx,%eax
f0102960:	74 19                	je     f010297b <mem_init+0x14c5>
f0102962:	68 18 74 10 f0       	push   $0xf0107418
f0102967:	68 85 68 10 f0       	push   $0xf0106885
f010296c:	68 f9 03 00 00       	push   $0x3f9
f0102971:	68 5f 68 10 f0       	push   $0xf010685f
f0102976:	e8 c5 d6 ff ff       	call   f0100040 <_panic>
f010297b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102981:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102987:	75 a7                	jne    f0102930 <mem_init+0x147a>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102989:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010298c:	c1 e6 0c             	shl    $0xc,%esi
f010298f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102994:	eb 30                	jmp    f01029c6 <mem_init+0x1510>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102996:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010299c:	89 f8                	mov    %edi,%eax
f010299e:	e8 c8 e1 ff ff       	call   f0100b6b <check_va2pa>
f01029a3:	39 c3                	cmp    %eax,%ebx
f01029a5:	74 19                	je     f01029c0 <mem_init+0x150a>
f01029a7:	68 4c 74 10 f0       	push   $0xf010744c
f01029ac:	68 85 68 10 f0       	push   $0xf0106885
f01029b1:	68 fd 03 00 00       	push   $0x3fd
f01029b6:	68 5f 68 10 f0       	push   $0xf010685f
f01029bb:	e8 80 d6 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029c0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029c6:	39 f3                	cmp    %esi,%ebx
f01029c8:	72 cc                	jb     f0102996 <mem_init+0x14e0>
f01029ca:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01029cf:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01029d2:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01029d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01029d8:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f01029de:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01029e1:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01029e3:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01029e6:	05 00 80 00 20       	add    $0x20008000,%eax
f01029eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029ee:	89 da                	mov    %ebx,%edx
f01029f0:	89 f8                	mov    %edi,%eax
f01029f2:	e8 74 e1 ff ff       	call   f0100b6b <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029f7:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01029fd:	77 15                	ja     f0102a14 <mem_init+0x155e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029ff:	56                   	push   %esi
f0102a00:	68 c8 62 10 f0       	push   $0xf01062c8
f0102a05:	68 05 04 00 00       	push   $0x405
f0102a0a:	68 5f 68 10 f0       	push   $0xf010685f
f0102a0f:	e8 2c d6 ff ff       	call   f0100040 <_panic>
f0102a14:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102a17:	8d 94 0b 00 10 21 f0 	lea    -0xfdef000(%ebx,%ecx,1),%edx
f0102a1e:	39 d0                	cmp    %edx,%eax
f0102a20:	74 19                	je     f0102a3b <mem_init+0x1585>
f0102a22:	68 74 74 10 f0       	push   $0xf0107474
f0102a27:	68 85 68 10 f0       	push   $0xf0106885
f0102a2c:	68 05 04 00 00       	push   $0x405
f0102a31:	68 5f 68 10 f0       	push   $0xf010685f
f0102a36:	e8 05 d6 ff ff       	call   f0100040 <_panic>
f0102a3b:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a41:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102a44:	75 a8                	jne    f01029ee <mem_init+0x1538>
f0102a46:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a49:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102a4f:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102a52:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a54:	89 da                	mov    %ebx,%edx
f0102a56:	89 f8                	mov    %edi,%eax
f0102a58:	e8 0e e1 ff ff       	call   f0100b6b <check_va2pa>
f0102a5d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a60:	74 19                	je     f0102a7b <mem_init+0x15c5>
f0102a62:	68 bc 74 10 f0       	push   $0xf01074bc
f0102a67:	68 85 68 10 f0       	push   $0xf0106885
f0102a6c:	68 07 04 00 00       	push   $0x407
f0102a71:	68 5f 68 10 f0       	push   $0xf010685f
f0102a76:	e8 c5 d5 ff ff       	call   f0100040 <_panic>
f0102a7b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a81:	39 f3                	cmp    %esi,%ebx
f0102a83:	75 cf                	jne    f0102a54 <mem_init+0x159e>
f0102a85:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102a88:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102a8f:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102a96:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102a9c:	b8 00 10 25 f0       	mov    $0xf0251000,%eax
f0102aa1:	39 f0                	cmp    %esi,%eax
f0102aa3:	0f 85 2c ff ff ff    	jne    f01029d5 <mem_init+0x151f>
f0102aa9:	b8 00 00 00 00       	mov    $0x0,%eax
f0102aae:	eb 2a                	jmp    f0102ada <mem_init+0x1624>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102ab0:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102ab6:	83 fa 04             	cmp    $0x4,%edx
f0102ab9:	77 1f                	ja     f0102ada <mem_init+0x1624>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102abb:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102abf:	75 7e                	jne    f0102b3f <mem_init+0x1689>
f0102ac1:	68 62 6b 10 f0       	push   $0xf0106b62
f0102ac6:	68 85 68 10 f0       	push   $0xf0106885
f0102acb:	68 12 04 00 00       	push   $0x412
f0102ad0:	68 5f 68 10 f0       	push   $0xf010685f
f0102ad5:	e8 66 d5 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102ada:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102adf:	76 3f                	jbe    f0102b20 <mem_init+0x166a>
				assert(pgdir[i] & PTE_P);
f0102ae1:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102ae4:	f6 c2 01             	test   $0x1,%dl
f0102ae7:	75 19                	jne    f0102b02 <mem_init+0x164c>
f0102ae9:	68 62 6b 10 f0       	push   $0xf0106b62
f0102aee:	68 85 68 10 f0       	push   $0xf0106885
f0102af3:	68 16 04 00 00       	push   $0x416
f0102af8:	68 5f 68 10 f0       	push   $0xf010685f
f0102afd:	e8 3e d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b02:	f6 c2 02             	test   $0x2,%dl
f0102b05:	75 38                	jne    f0102b3f <mem_init+0x1689>
f0102b07:	68 73 6b 10 f0       	push   $0xf0106b73
f0102b0c:	68 85 68 10 f0       	push   $0xf0106885
f0102b11:	68 17 04 00 00       	push   $0x417
f0102b16:	68 5f 68 10 f0       	push   $0xf010685f
f0102b1b:	e8 20 d5 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102b20:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102b24:	74 19                	je     f0102b3f <mem_init+0x1689>
f0102b26:	68 84 6b 10 f0       	push   $0xf0106b84
f0102b2b:	68 85 68 10 f0       	push   $0xf0106885
f0102b30:	68 19 04 00 00       	push   $0x419
f0102b35:	68 5f 68 10 f0       	push   $0xf010685f
f0102b3a:	e8 01 d5 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102b3f:	83 c0 01             	add    $0x1,%eax
f0102b42:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102b47:	0f 86 63 ff ff ff    	jbe    f0102ab0 <mem_init+0x15fa>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b4d:	83 ec 0c             	sub    $0xc,%esp
f0102b50:	68 e0 74 10 f0       	push   $0xf01074e0
f0102b55:	e8 12 0d 00 00       	call   f010386c <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102b5a:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b5f:	83 c4 10             	add    $0x10,%esp
f0102b62:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b67:	77 15                	ja     f0102b7e <mem_init+0x16c8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b69:	50                   	push   %eax
f0102b6a:	68 c8 62 10 f0       	push   $0xf01062c8
f0102b6f:	68 fc 00 00 00       	push   $0xfc
f0102b74:	68 5f 68 10 f0       	push   $0xf010685f
f0102b79:	e8 c2 d4 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b7e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b83:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102b86:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b8b:	e8 3f e0 ff ff       	call   f0100bcf <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b90:	0f 20 c0             	mov    %cr0,%eax
f0102b93:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b96:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102b9b:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b9e:	83 ec 0c             	sub    $0xc,%esp
f0102ba1:	6a 00                	push   $0x0
f0102ba3:	e8 f0 e4 ff ff       	call   f0101098 <page_alloc>
f0102ba8:	89 c3                	mov    %eax,%ebx
f0102baa:	83 c4 10             	add    $0x10,%esp
f0102bad:	85 c0                	test   %eax,%eax
f0102baf:	75 19                	jne    f0102bca <mem_init+0x1714>
f0102bb1:	68 6e 69 10 f0       	push   $0xf010696e
f0102bb6:	68 85 68 10 f0       	push   $0xf0106885
f0102bbb:	68 f5 04 00 00       	push   $0x4f5
f0102bc0:	68 5f 68 10 f0       	push   $0xf010685f
f0102bc5:	e8 76 d4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102bca:	83 ec 0c             	sub    $0xc,%esp
f0102bcd:	6a 00                	push   $0x0
f0102bcf:	e8 c4 e4 ff ff       	call   f0101098 <page_alloc>
f0102bd4:	89 c7                	mov    %eax,%edi
f0102bd6:	83 c4 10             	add    $0x10,%esp
f0102bd9:	85 c0                	test   %eax,%eax
f0102bdb:	75 19                	jne    f0102bf6 <mem_init+0x1740>
f0102bdd:	68 84 69 10 f0       	push   $0xf0106984
f0102be2:	68 85 68 10 f0       	push   $0xf0106885
f0102be7:	68 f6 04 00 00       	push   $0x4f6
f0102bec:	68 5f 68 10 f0       	push   $0xf010685f
f0102bf1:	e8 4a d4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102bf6:	83 ec 0c             	sub    $0xc,%esp
f0102bf9:	6a 00                	push   $0x0
f0102bfb:	e8 98 e4 ff ff       	call   f0101098 <page_alloc>
f0102c00:	89 c6                	mov    %eax,%esi
f0102c02:	83 c4 10             	add    $0x10,%esp
f0102c05:	85 c0                	test   %eax,%eax
f0102c07:	75 19                	jne    f0102c22 <mem_init+0x176c>
f0102c09:	68 9a 69 10 f0       	push   $0xf010699a
f0102c0e:	68 85 68 10 f0       	push   $0xf0106885
f0102c13:	68 f7 04 00 00       	push   $0x4f7
f0102c18:	68 5f 68 10 f0       	push   $0xf010685f
f0102c1d:	e8 1e d4 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102c22:	83 ec 0c             	sub    $0xc,%esp
f0102c25:	53                   	push   %ebx
f0102c26:	e8 de e4 ff ff       	call   f0101109 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c2b:	89 f8                	mov    %edi,%eax
f0102c2d:	2b 05 90 fe 20 f0    	sub    0xf020fe90,%eax
f0102c33:	c1 f8 03             	sar    $0x3,%eax
f0102c36:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c39:	89 c2                	mov    %eax,%edx
f0102c3b:	c1 ea 0c             	shr    $0xc,%edx
f0102c3e:	83 c4 10             	add    $0x10,%esp
f0102c41:	3b 15 88 fe 20 f0    	cmp    0xf020fe88,%edx
f0102c47:	72 12                	jb     f0102c5b <mem_init+0x17a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c49:	50                   	push   %eax
f0102c4a:	68 a4 62 10 f0       	push   $0xf01062a4
f0102c4f:	6a 58                	push   $0x58
f0102c51:	68 6b 68 10 f0       	push   $0xf010686b
f0102c56:	e8 e5 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c5b:	83 ec 04             	sub    $0x4,%esp
f0102c5e:	68 00 10 00 00       	push   $0x1000
f0102c63:	6a 01                	push   $0x1
f0102c65:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c6a:	50                   	push   %eax
f0102c6b:	e8 56 29 00 00       	call   f01055c6 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c70:	89 f0                	mov    %esi,%eax
f0102c72:	2b 05 90 fe 20 f0    	sub    0xf020fe90,%eax
f0102c78:	c1 f8 03             	sar    $0x3,%eax
f0102c7b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c7e:	89 c2                	mov    %eax,%edx
f0102c80:	c1 ea 0c             	shr    $0xc,%edx
f0102c83:	83 c4 10             	add    $0x10,%esp
f0102c86:	3b 15 88 fe 20 f0    	cmp    0xf020fe88,%edx
f0102c8c:	72 12                	jb     f0102ca0 <mem_init+0x17ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c8e:	50                   	push   %eax
f0102c8f:	68 a4 62 10 f0       	push   $0xf01062a4
f0102c94:	6a 58                	push   $0x58
f0102c96:	68 6b 68 10 f0       	push   $0xf010686b
f0102c9b:	e8 a0 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102ca0:	83 ec 04             	sub    $0x4,%esp
f0102ca3:	68 00 10 00 00       	push   $0x1000
f0102ca8:	6a 02                	push   $0x2
f0102caa:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102caf:	50                   	push   %eax
f0102cb0:	e8 11 29 00 00       	call   f01055c6 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102cb5:	6a 02                	push   $0x2
f0102cb7:	68 00 10 00 00       	push   $0x1000
f0102cbc:	57                   	push   %edi
f0102cbd:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0102cc3:	e8 fe e6 ff ff       	call   f01013c6 <page_insert>
	assert(pp1->pp_ref == 1);
f0102cc8:	83 c4 20             	add    $0x20,%esp
f0102ccb:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102cd0:	74 19                	je     f0102ceb <mem_init+0x1835>
f0102cd2:	68 6b 6a 10 f0       	push   $0xf0106a6b
f0102cd7:	68 85 68 10 f0       	push   $0xf0106885
f0102cdc:	68 fc 04 00 00       	push   $0x4fc
f0102ce1:	68 5f 68 10 f0       	push   $0xf010685f
f0102ce6:	e8 55 d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ceb:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cf2:	01 01 01 
f0102cf5:	74 19                	je     f0102d10 <mem_init+0x185a>
f0102cf7:	68 00 75 10 f0       	push   $0xf0107500
f0102cfc:	68 85 68 10 f0       	push   $0xf0106885
f0102d01:	68 fd 04 00 00       	push   $0x4fd
f0102d06:	68 5f 68 10 f0       	push   $0xf010685f
f0102d0b:	e8 30 d3 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d10:	6a 02                	push   $0x2
f0102d12:	68 00 10 00 00       	push   $0x1000
f0102d17:	56                   	push   %esi
f0102d18:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0102d1e:	e8 a3 e6 ff ff       	call   f01013c6 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d23:	83 c4 10             	add    $0x10,%esp
f0102d26:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d2d:	02 02 02 
f0102d30:	74 19                	je     f0102d4b <mem_init+0x1895>
f0102d32:	68 24 75 10 f0       	push   $0xf0107524
f0102d37:	68 85 68 10 f0       	push   $0xf0106885
f0102d3c:	68 ff 04 00 00       	push   $0x4ff
f0102d41:	68 5f 68 10 f0       	push   $0xf010685f
f0102d46:	e8 f5 d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102d4b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d50:	74 19                	je     f0102d6b <mem_init+0x18b5>
f0102d52:	68 8d 6a 10 f0       	push   $0xf0106a8d
f0102d57:	68 85 68 10 f0       	push   $0xf0106885
f0102d5c:	68 00 05 00 00       	push   $0x500
f0102d61:	68 5f 68 10 f0       	push   $0xf010685f
f0102d66:	e8 d5 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102d6b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d70:	74 19                	je     f0102d8b <mem_init+0x18d5>
f0102d72:	68 f7 6a 10 f0       	push   $0xf0106af7
f0102d77:	68 85 68 10 f0       	push   $0xf0106885
f0102d7c:	68 01 05 00 00       	push   $0x501
f0102d81:	68 5f 68 10 f0       	push   $0xf010685f
f0102d86:	e8 b5 d2 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d8b:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d92:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d95:	89 f0                	mov    %esi,%eax
f0102d97:	2b 05 90 fe 20 f0    	sub    0xf020fe90,%eax
f0102d9d:	c1 f8 03             	sar    $0x3,%eax
f0102da0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102da3:	89 c2                	mov    %eax,%edx
f0102da5:	c1 ea 0c             	shr    $0xc,%edx
f0102da8:	3b 15 88 fe 20 f0    	cmp    0xf020fe88,%edx
f0102dae:	72 12                	jb     f0102dc2 <mem_init+0x190c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102db0:	50                   	push   %eax
f0102db1:	68 a4 62 10 f0       	push   $0xf01062a4
f0102db6:	6a 58                	push   $0x58
f0102db8:	68 6b 68 10 f0       	push   $0xf010686b
f0102dbd:	e8 7e d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102dc2:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102dc9:	03 03 03 
f0102dcc:	74 19                	je     f0102de7 <mem_init+0x1931>
f0102dce:	68 48 75 10 f0       	push   $0xf0107548
f0102dd3:	68 85 68 10 f0       	push   $0xf0106885
f0102dd8:	68 03 05 00 00       	push   $0x503
f0102ddd:	68 5f 68 10 f0       	push   $0xf010685f
f0102de2:	e8 59 d2 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102de7:	83 ec 08             	sub    $0x8,%esp
f0102dea:	68 00 10 00 00       	push   $0x1000
f0102def:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0102df5:	e8 7f e5 ff ff       	call   f0101379 <page_remove>
	assert(pp2->pp_ref == 0);
f0102dfa:	83 c4 10             	add    $0x10,%esp
f0102dfd:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102e02:	74 19                	je     f0102e1d <mem_init+0x1967>
f0102e04:	68 c5 6a 10 f0       	push   $0xf0106ac5
f0102e09:	68 85 68 10 f0       	push   $0xf0106885
f0102e0e:	68 05 05 00 00       	push   $0x505
f0102e13:	68 5f 68 10 f0       	push   $0xf010685f
f0102e18:	e8 23 d2 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e1d:	8b 0d 8c fe 20 f0    	mov    0xf020fe8c,%ecx
f0102e23:	8b 11                	mov    (%ecx),%edx
f0102e25:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102e2b:	89 d8                	mov    %ebx,%eax
f0102e2d:	2b 05 90 fe 20 f0    	sub    0xf020fe90,%eax
f0102e33:	c1 f8 03             	sar    $0x3,%eax
f0102e36:	c1 e0 0c             	shl    $0xc,%eax
f0102e39:	39 c2                	cmp    %eax,%edx
f0102e3b:	74 19                	je     f0102e56 <mem_init+0x19a0>
f0102e3d:	68 d0 6e 10 f0       	push   $0xf0106ed0
f0102e42:	68 85 68 10 f0       	push   $0xf0106885
f0102e47:	68 08 05 00 00       	push   $0x508
f0102e4c:	68 5f 68 10 f0       	push   $0xf010685f
f0102e51:	e8 ea d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102e56:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102e5c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102e61:	74 19                	je     f0102e7c <mem_init+0x19c6>
f0102e63:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0102e68:	68 85 68 10 f0       	push   $0xf0106885
f0102e6d:	68 0a 05 00 00       	push   $0x50a
f0102e72:	68 5f 68 10 f0       	push   $0xf010685f
f0102e77:	e8 c4 d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102e7c:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102e82:	83 ec 0c             	sub    $0xc,%esp
f0102e85:	53                   	push   %ebx
f0102e86:	e8 7e e2 ff ff       	call   f0101109 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e8b:	c7 04 24 74 75 10 f0 	movl   $0xf0107574,(%esp)
f0102e92:	e8 d5 09 00 00       	call   f010386c <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102e97:	83 c4 10             	add    $0x10,%esp
f0102e9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e9d:	5b                   	pop    %ebx
f0102e9e:	5e                   	pop    %esi
f0102e9f:	5f                   	pop    %edi
f0102ea0:	5d                   	pop    %ebp
f0102ea1:	c3                   	ret    

f0102ea2 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102ea2:	55                   	push   %ebp
f0102ea3:	89 e5                	mov    %esp,%ebp
f0102ea5:	57                   	push   %edi
f0102ea6:	56                   	push   %esi
f0102ea7:	53                   	push   %ebx
f0102ea8:	83 ec 1c             	sub    $0x1c,%esp
f0102eab:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102eae:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.

	pte_t* pte;

	// for every page in this region
	for (void* i=ROUNDDOWN((void *)va, PGSIZE); i<ROUNDUP((void *)(va+len), PGSIZE); i+=PGSIZE) {
f0102eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102eb4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102eb9:	89 c3                	mov    %eax,%ebx
f0102ebb:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102ebe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ec1:	03 45 10             	add    0x10(%ebp),%eax
f0102ec4:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102ec9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102ece:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102ed1:	eb 6f                	jmp    f0102f42 <user_mem_check+0xa0>

		if ((uintptr_t)i >= ULIM) {
f0102ed3:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0102ed6:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102edc:	76 15                	jbe    f0102ef3 <user_mem_check+0x51>
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0102ede:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0102ee1:	89 d8                	mov    %ebx,%eax
f0102ee3:	0f 44 45 0c          	cmove  0xc(%ebp),%eax
f0102ee7:	a3 3c f2 20 f0       	mov    %eax,0xf020f23c
			return -E_FAULT;
f0102eec:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102ef1:	eb 59                	jmp    f0102f4c <user_mem_check+0xaa>
		}

		//  get this page
		pte = pgdir_walk(env->env_pgdir, i, 0);
f0102ef3:	83 ec 04             	sub    $0x4,%esp
f0102ef6:	6a 00                	push   $0x0
f0102ef8:	53                   	push   %ebx
f0102ef9:	ff 77 60             	pushl  0x60(%edi)
f0102efc:	e8 85 e2 ff ff       	call   f0101186 <pgdir_walk>

		if (pte == NULL) {
f0102f01:	83 c4 10             	add    $0x10,%esp
f0102f04:	85 c0                	test   %eax,%eax
f0102f06:	75 16                	jne    f0102f1e <user_mem_check+0x7c>
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0102f08:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0102f0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f0e:	0f 44 45 0c          	cmove  0xc(%ebp),%eax
f0102f12:	a3 3c f2 20 f0       	mov    %eax,0xf020f23c
			return -E_FAULT;
f0102f17:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f1c:	eb 2e                	jmp    f0102f4c <user_mem_check+0xaa>
		}

		// perm wrong
		if (((uint32_t)(*pte) & perm) != perm) {
f0102f1e:	89 f2                	mov    %esi,%edx
f0102f20:	23 10                	and    (%eax),%edx
f0102f22:	39 d6                	cmp    %edx,%esi
f0102f24:	74 16                	je     f0102f3c <user_mem_check+0x9a>
			// if happens at first page, we return va instead of ROUNDDOWN(va, PGSIZE)
			// just to make it more precise 
			user_mem_check_addr = (i == ROUNDDOWN((void *)va, PGSIZE))? (uintptr_t)va:(uintptr_t)i;
f0102f26:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0102f29:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f2c:	0f 44 45 0c          	cmove  0xc(%ebp),%eax
f0102f30:	a3 3c f2 20 f0       	mov    %eax,0xf020f23c
			return -E_FAULT;
f0102f35:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f3a:	eb 10                	jmp    f0102f4c <user_mem_check+0xaa>
	// LAB 3: Your code here.

	pte_t* pte;

	// for every page in this region
	for (void* i=ROUNDDOWN((void *)va, PGSIZE); i<ROUNDUP((void *)(va+len), PGSIZE); i+=PGSIZE) {
f0102f3c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f42:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102f45:	72 8c                	jb     f0102ed3 <user_mem_check+0x31>
			return -E_FAULT;
		}

	}

	return 0;
f0102f47:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f4f:	5b                   	pop    %ebx
f0102f50:	5e                   	pop    %esi
f0102f51:	5f                   	pop    %edi
f0102f52:	5d                   	pop    %ebp
f0102f53:	c3                   	ret    

f0102f54 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102f54:	55                   	push   %ebp
f0102f55:	89 e5                	mov    %esp,%ebp
f0102f57:	53                   	push   %ebx
f0102f58:	83 ec 04             	sub    $0x4,%esp
f0102f5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f5e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f61:	83 c8 04             	or     $0x4,%eax
f0102f64:	50                   	push   %eax
f0102f65:	ff 75 10             	pushl  0x10(%ebp)
f0102f68:	ff 75 0c             	pushl  0xc(%ebp)
f0102f6b:	53                   	push   %ebx
f0102f6c:	e8 31 ff ff ff       	call   f0102ea2 <user_mem_check>
f0102f71:	83 c4 10             	add    $0x10,%esp
f0102f74:	85 c0                	test   %eax,%eax
f0102f76:	79 21                	jns    f0102f99 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f78:	83 ec 04             	sub    $0x4,%esp
f0102f7b:	ff 35 3c f2 20 f0    	pushl  0xf020f23c
f0102f81:	ff 73 48             	pushl  0x48(%ebx)
f0102f84:	68 a0 75 10 f0       	push   $0xf01075a0
f0102f89:	e8 de 08 00 00       	call   f010386c <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102f8e:	89 1c 24             	mov    %ebx,(%esp)
f0102f91:	e8 d5 05 00 00       	call   f010356b <env_destroy>
f0102f96:	83 c4 10             	add    $0x10,%esp
	}
}
f0102f99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f9c:	c9                   	leave  
f0102f9d:	c3                   	ret    

f0102f9e <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f9e:	55                   	push   %ebp
f0102f9f:	89 e5                	mov    %esp,%ebp
f0102fa1:	57                   	push   %edi
f0102fa2:	56                   	push   %esi
f0102fa3:	53                   	push   %ebx
f0102fa4:	83 ec 0c             	sub    $0xc,%esp
f0102fa7:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f0102fa9:	89 d3                	mov    %edx,%ebx
f0102fab:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102fb1:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102fb8:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0102fbe:	eb 56                	jmp    f0103016 <region_alloc+0x78>

		struct PageInfo* pp = page_alloc(ALLOC_ZERO);
f0102fc0:	83 ec 0c             	sub    $0xc,%esp
f0102fc3:	6a 01                	push   $0x1
f0102fc5:	e8 ce e0 ff ff       	call   f0101098 <page_alloc>
		if (pp == 0) {
f0102fca:	83 c4 10             	add    $0x10,%esp
f0102fcd:	85 c0                	test   %eax,%eax
f0102fcf:	75 17                	jne    f0102fe8 <region_alloc+0x4a>
			panic("region_alloc: page_alloc return 0");
f0102fd1:	83 ec 04             	sub    $0x4,%esp
f0102fd4:	68 d8 75 10 f0       	push   $0xf01075d8
f0102fd9:	68 2d 01 00 00       	push   $0x12d
f0102fde:	68 9c 76 10 f0       	push   $0xf010769c
f0102fe3:	e8 58 d0 ff ff       	call   f0100040 <_panic>
		}

		int err = page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
f0102fe8:	6a 06                	push   $0x6
f0102fea:	53                   	push   %ebx
f0102feb:	50                   	push   %eax
f0102fec:	ff 77 60             	pushl  0x60(%edi)
f0102fef:	e8 d2 e3 ff ff       	call   f01013c6 <page_insert>
		if (err < 0) {
f0102ff4:	83 c4 10             	add    $0x10,%esp
f0102ff7:	85 c0                	test   %eax,%eax
f0102ff9:	79 15                	jns    f0103010 <region_alloc+0x72>
			panic("region_alloc: page_insert failed: %e", err);
f0102ffb:	50                   	push   %eax
f0102ffc:	68 fc 75 10 f0       	push   $0xf01075fc
f0103001:	68 32 01 00 00       	push   $0x132
f0103006:	68 9c 76 10 f0       	push   $0xf010769c
f010300b:	e8 30 d0 ff ff       	call   f0100040 <_panic>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f0103010:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103016:	39 f3                	cmp    %esi,%ebx
f0103018:	72 a6                	jb     f0102fc0 <region_alloc+0x22>
		}

	}

	
}
f010301a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010301d:	5b                   	pop    %ebx
f010301e:	5e                   	pop    %esi
f010301f:	5f                   	pop    %edi
f0103020:	5d                   	pop    %ebp
f0103021:	c3                   	ret    

f0103022 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103022:	55                   	push   %ebp
f0103023:	89 e5                	mov    %esp,%ebp
f0103025:	56                   	push   %esi
f0103026:	53                   	push   %ebx
f0103027:	8b 45 08             	mov    0x8(%ebp),%eax
f010302a:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010302d:	85 c0                	test   %eax,%eax
f010302f:	75 1a                	jne    f010304b <envid2env+0x29>
		*env_store = curenv;
f0103031:	e8 b0 2b 00 00       	call   f0105be6 <cpunum>
f0103036:	6b c0 74             	imul   $0x74,%eax,%eax
f0103039:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f010303f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103042:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103044:	b8 00 00 00 00       	mov    $0x0,%eax
f0103049:	eb 70                	jmp    f01030bb <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010304b:	89 c3                	mov    %eax,%ebx
f010304d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103053:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103056:	03 1d 48 f2 20 f0    	add    0xf020f248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010305c:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103060:	74 05                	je     f0103067 <envid2env+0x45>
f0103062:	3b 43 48             	cmp    0x48(%ebx),%eax
f0103065:	74 10                	je     f0103077 <envid2env+0x55>
		*env_store = 0;
f0103067:	8b 45 0c             	mov    0xc(%ebp),%eax
f010306a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103070:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103075:	eb 44                	jmp    f01030bb <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103077:	84 d2                	test   %dl,%dl
f0103079:	74 36                	je     f01030b1 <envid2env+0x8f>
f010307b:	e8 66 2b 00 00       	call   f0105be6 <cpunum>
f0103080:	6b c0 74             	imul   $0x74,%eax,%eax
f0103083:	3b 98 28 00 21 f0    	cmp    -0xfdeffd8(%eax),%ebx
f0103089:	74 26                	je     f01030b1 <envid2env+0x8f>
f010308b:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010308e:	e8 53 2b 00 00       	call   f0105be6 <cpunum>
f0103093:	6b c0 74             	imul   $0x74,%eax,%eax
f0103096:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f010309c:	3b 70 48             	cmp    0x48(%eax),%esi
f010309f:	74 10                	je     f01030b1 <envid2env+0x8f>
		*env_store = 0;
f01030a1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01030aa:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030af:	eb 0a                	jmp    f01030bb <envid2env+0x99>
	}

	*env_store = e;
f01030b1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030b4:	89 18                	mov    %ebx,(%eax)
	return 0;
f01030b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01030bb:	5b                   	pop    %ebx
f01030bc:	5e                   	pop    %esi
f01030bd:	5d                   	pop    %ebp
f01030be:	c3                   	ret    

f01030bf <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01030bf:	55                   	push   %ebp
f01030c0:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01030c2:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f01030c7:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01030ca:	b8 23 00 00 00       	mov    $0x23,%eax
f01030cf:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01030d1:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01030d3:	b8 10 00 00 00       	mov    $0x10,%eax
f01030d8:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01030da:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01030dc:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01030de:	ea e5 30 10 f0 08 00 	ljmp   $0x8,$0xf01030e5
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f01030e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01030ea:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01030ed:	5d                   	pop    %ebp
f01030ee:	c3                   	ret    

f01030ef <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01030ef:	55                   	push   %ebp
f01030f0:	89 e5                	mov    %esp,%ebp
f01030f2:	56                   	push   %esi
f01030f3:	53                   	push   %ebx
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
		envs[i].env_id = 0;
f01030f4:	8b 35 48 f2 20 f0    	mov    0xf020f248,%esi
f01030fa:	8b 15 4c f2 20 f0    	mov    0xf020f24c,%edx
f0103100:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103106:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0103109:	89 c1                	mov    %eax,%ecx
f010310b:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103112:	89 50 44             	mov    %edx,0x44(%eax)
f0103115:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0103118:	89 ca                	mov    %ecx,%edx
	// Set up envs array
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
f010311a:	39 d8                	cmp    %ebx,%eax
f010311c:	75 eb                	jne    f0103109 <env_init+0x1a>
f010311e:	89 35 4c f2 20 f0    	mov    %esi,0xf020f24c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0103124:	e8 96 ff ff ff       	call   f01030bf <env_init_percpu>
}
f0103129:	5b                   	pop    %ebx
f010312a:	5e                   	pop    %esi
f010312b:	5d                   	pop    %ebp
f010312c:	c3                   	ret    

f010312d <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010312d:	55                   	push   %ebp
f010312e:	89 e5                	mov    %esp,%ebp
f0103130:	56                   	push   %esi
f0103131:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103132:	8b 1d 4c f2 20 f0    	mov    0xf020f24c,%ebx
f0103138:	85 db                	test   %ebx,%ebx
f010313a:	0f 84 2f 01 00 00    	je     f010326f <env_alloc+0x142>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103140:	83 ec 0c             	sub    $0xc,%esp
f0103143:	6a 01                	push   $0x1
f0103145:	e8 4e df ff ff       	call   f0101098 <page_alloc>
f010314a:	89 c6                	mov    %eax,%esi
f010314c:	83 c4 10             	add    $0x10,%esp
f010314f:	85 c0                	test   %eax,%eax
f0103151:	0f 84 1f 01 00 00    	je     f0103276 <env_alloc+0x149>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103157:	2b 05 90 fe 20 f0    	sub    0xf020fe90,%eax
f010315d:	c1 f8 03             	sar    $0x3,%eax
f0103160:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103163:	89 c2                	mov    %eax,%edx
f0103165:	c1 ea 0c             	shr    $0xc,%edx
f0103168:	3b 15 88 fe 20 f0    	cmp    0xf020fe88,%edx
f010316e:	72 12                	jb     f0103182 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103170:	50                   	push   %eax
f0103171:	68 a4 62 10 f0       	push   $0xf01062a4
f0103176:	6a 58                	push   $0x58
f0103178:	68 6b 68 10 f0       	push   $0xf010686b
f010317d:	e8 be ce ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103182:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	e->env_pgdir = page2kva(p);
f0103187:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f010318a:	83 ec 04             	sub    $0x4,%esp
f010318d:	68 00 10 00 00       	push   $0x1000
f0103192:	ff 35 8c fe 20 f0    	pushl  0xf020fe8c
f0103198:	50                   	push   %eax
f0103199:	e8 dd 24 00 00       	call   f010567b <memcpy>
	p->pp_ref++;
f010319e:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01031a3:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031a6:	83 c4 10             	add    $0x10,%esp
f01031a9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031ae:	77 15                	ja     f01031c5 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031b0:	50                   	push   %eax
f01031b1:	68 c8 62 10 f0       	push   $0xf01062c8
f01031b6:	68 c8 00 00 00       	push   $0xc8
f01031bb:	68 9c 76 10 f0       	push   $0xf010769c
f01031c0:	e8 7b ce ff ff       	call   f0100040 <_panic>
f01031c5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01031cb:	83 ca 05             	or     $0x5,%edx
f01031ce:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01031d4:	8b 43 48             	mov    0x48(%ebx),%eax
f01031d7:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01031dc:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01031e1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01031e6:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01031e9:	89 da                	mov    %ebx,%edx
f01031eb:	2b 15 48 f2 20 f0    	sub    0xf020f248,%edx
f01031f1:	c1 fa 02             	sar    $0x2,%edx
f01031f4:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01031fa:	09 d0                	or     %edx,%eax
f01031fc:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01031ff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103202:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103205:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010320c:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103213:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010321a:	83 ec 04             	sub    $0x4,%esp
f010321d:	6a 44                	push   $0x44
f010321f:	6a 00                	push   $0x0
f0103221:	53                   	push   %ebx
f0103222:	e8 9f 23 00 00       	call   f01055c6 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103227:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010322d:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103233:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103239:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103240:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	e->env_tf.tf_eflags |= FL_IF;
f0103246:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010324d:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103254:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103258:	8b 43 44             	mov    0x44(%ebx),%eax
f010325b:	a3 4c f2 20 f0       	mov    %eax,0xf020f24c
	*newenv_store = e;
f0103260:	8b 45 08             	mov    0x8(%ebp),%eax
f0103263:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103265:	83 c4 10             	add    $0x10,%esp
f0103268:	b8 00 00 00 00       	mov    $0x0,%eax
f010326d:	eb 0c                	jmp    f010327b <env_alloc+0x14e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010326f:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103274:	eb 05                	jmp    f010327b <env_alloc+0x14e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103276:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
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
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.

	struct Env *newenv_store;
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
f010328e:	6a 00                	push   $0x0
f0103290:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103293:	50                   	push   %eax
f0103294:	e8 94 fe ff ff       	call   f010312d <env_alloc>
	if (err < 0) 
f0103299:	83 c4 10             	add    $0x10,%esp
f010329c:	85 c0                	test   %eax,%eax
f010329e:	79 15                	jns    f01032b5 <env_create+0x33>
		panic("env_create: env_alloc failed: %e", err);
f01032a0:	50                   	push   %eax
f01032a1:	68 24 76 10 f0       	push   $0xf0107624
f01032a6:	68 bc 01 00 00       	push   $0x1bc
f01032ab:	68 9c 76 10 f0       	push   $0xf010769c
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
f01032c6:	68 48 76 10 f0       	push   $0xf0107648
f01032cb:	68 75 01 00 00       	push   $0x175
f01032d0:	68 9c 76 10 f0       	push   $0xf010769c
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
f01032f6:	68 c8 62 10 f0       	push   $0xf01062c8
f01032fb:	68 7e 01 00 00       	push   $0x17e
f0103300:	68 9c 76 10 f0       	push   $0xf010769c
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
f0103324:	68 70 76 10 f0       	push   $0xf0107670
f0103329:	68 87 01 00 00       	push   $0x187
f010332e:	68 9c 76 10 f0       	push   $0xf010769c
f0103333:	e8 08 cd ff ff       	call   f0100040 <_panic>

			// allocate and map each segment
			// this function needs e->env_pgdir
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103338:	8b 53 08             	mov    0x8(%ebx),%edx
f010333b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010333e:	e8 5b fc ff ff       	call   f0102f9e <region_alloc>

			// all clear to 0
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0103343:	83 ec 04             	sub    $0x4,%esp
f0103346:	ff 73 14             	pushl  0x14(%ebx)
f0103349:	6a 00                	push   $0x0
f010334b:	ff 73 08             	pushl  0x8(%ebx)
f010334e:	e8 73 22 00 00       	call   f01055c6 <memset>

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
f0103362:	e8 14 23 00 00       	call   f010567b <memcpy>
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
f0103386:	e8 13 fc ff ff       	call   f0102f9e <region_alloc>

	// after loading things from elf, restore cr3 in kernel
	lcr3(PADDR(kern_pgdir));
f010338b:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103390:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103395:	77 15                	ja     f01033ac <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103397:	50                   	push   %eax
f0103398:	68 c8 62 10 f0       	push   $0xf01062c8
f010339d:	68 a5 01 00 00       	push   $0x1a5
f01033a2:	68 9c 76 10 f0       	push   $0xf010769c
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
f01033d1:	e8 10 28 00 00       	call   f0105be6 <cpunum>
f01033d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01033d9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01033e0:	39 b8 28 00 21 f0    	cmp    %edi,-0xfdeffd8(%eax)
f01033e6:	75 30                	jne    f0103418 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01033e8:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033f2:	77 15                	ja     f0103409 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033f4:	50                   	push   %eax
f01033f5:	68 c8 62 10 f0       	push   $0xf01062c8
f01033fa:	68 d0 01 00 00       	push   $0x1d0
f01033ff:	68 9c 76 10 f0       	push   $0xf010769c
f0103404:	e8 37 cc ff ff       	call   f0100040 <_panic>
f0103409:	05 00 00 00 10       	add    $0x10000000,%eax
f010340e:	0f 22 d8             	mov    %eax,%cr3
f0103411:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103418:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010341b:	89 d0                	mov    %edx,%eax
f010341d:	c1 e0 02             	shl    $0x2,%eax
f0103420:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103423:	8b 47 60             	mov    0x60(%edi),%eax
f0103426:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103429:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010342f:	0f 84 a8 00 00 00    	je     f01034dd <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103435:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010343b:	89 f0                	mov    %esi,%eax
f010343d:	c1 e8 0c             	shr    $0xc,%eax
f0103440:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103443:	39 05 88 fe 20 f0    	cmp    %eax,0xf020fe88
f0103449:	77 15                	ja     f0103460 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010344b:	56                   	push   %esi
f010344c:	68 a4 62 10 f0       	push   $0xf01062a4
f0103451:	68 df 01 00 00       	push   $0x1df
f0103456:	68 9c 76 10 f0       	push   $0xf010769c
f010345b:	e8 e0 cb ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103460:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103463:	c1 e0 16             	shl    $0x16,%eax
f0103466:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103469:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010346e:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103475:	01 
f0103476:	74 17                	je     f010348f <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103478:	83 ec 08             	sub    $0x8,%esp
f010347b:	89 d8                	mov    %ebx,%eax
f010347d:	c1 e0 0c             	shl    $0xc,%eax
f0103480:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103483:	50                   	push   %eax
f0103484:	ff 77 60             	pushl  0x60(%edi)
f0103487:	e8 ed de ff ff       	call   f0101379 <page_remove>
f010348c:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010348f:	83 c3 01             	add    $0x1,%ebx
f0103492:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103498:	75 d4                	jne    f010346e <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010349a:	8b 47 60             	mov    0x60(%edi),%eax
f010349d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034a0:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034aa:	3b 05 88 fe 20 f0    	cmp    0xf020fe88,%eax
f01034b0:	72 14                	jb     f01034c6 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01034b2:	83 ec 04             	sub    $0x4,%esp
f01034b5:	68 78 6d 10 f0       	push   $0xf0106d78
f01034ba:	6a 51                	push   $0x51
f01034bc:	68 6b 68 10 f0       	push   $0xf010686b
f01034c1:	e8 7a cb ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01034c6:	83 ec 0c             	sub    $0xc,%esp
f01034c9:	a1 90 fe 20 f0       	mov    0xf020fe90,%eax
f01034ce:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034d1:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01034d4:	50                   	push   %eax
f01034d5:	e8 85 dc ff ff       	call   f010115f <page_decref>
f01034da:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034dd:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01034e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034e4:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01034e9:	0f 85 29 ff ff ff    	jne    f0103418 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01034ef:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034f2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034f7:	77 15                	ja     f010350e <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034f9:	50                   	push   %eax
f01034fa:	68 c8 62 10 f0       	push   $0xf01062c8
f01034ff:	68 ed 01 00 00       	push   $0x1ed
f0103504:	68 9c 76 10 f0       	push   $0xf010769c
f0103509:	e8 32 cb ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010350e:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103515:	05 00 00 00 10       	add    $0x10000000,%eax
f010351a:	c1 e8 0c             	shr    $0xc,%eax
f010351d:	3b 05 88 fe 20 f0    	cmp    0xf020fe88,%eax
f0103523:	72 14                	jb     f0103539 <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103525:	83 ec 04             	sub    $0x4,%esp
f0103528:	68 78 6d 10 f0       	push   $0xf0106d78
f010352d:	6a 51                	push   $0x51
f010352f:	68 6b 68 10 f0       	push   $0xf010686b
f0103534:	e8 07 cb ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103539:	83 ec 0c             	sub    $0xc,%esp
f010353c:	8b 15 90 fe 20 f0    	mov    0xf020fe90,%edx
f0103542:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103545:	50                   	push   %eax
f0103546:	e8 14 dc ff ff       	call   f010115f <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010354b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103552:	a1 4c f2 20 f0       	mov    0xf020f24c,%eax
f0103557:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010355a:	89 3d 4c f2 20 f0    	mov    %edi,0xf020f24c
}
f0103560:	83 c4 10             	add    $0x10,%esp
f0103563:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103566:	5b                   	pop    %ebx
f0103567:	5e                   	pop    %esi
f0103568:	5f                   	pop    %edi
f0103569:	5d                   	pop    %ebp
f010356a:	c3                   	ret    

f010356b <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010356b:	55                   	push   %ebp
f010356c:	89 e5                	mov    %esp,%ebp
f010356e:	53                   	push   %ebx
f010356f:	83 ec 04             	sub    $0x4,%esp
f0103572:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103575:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103579:	75 19                	jne    f0103594 <env_destroy+0x29>
f010357b:	e8 66 26 00 00       	call   f0105be6 <cpunum>
f0103580:	6b c0 74             	imul   $0x74,%eax,%eax
f0103583:	3b 98 28 00 21 f0    	cmp    -0xfdeffd8(%eax),%ebx
f0103589:	74 09                	je     f0103594 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f010358b:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103592:	eb 33                	jmp    f01035c7 <env_destroy+0x5c>
	}

	env_free(e);
f0103594:	83 ec 0c             	sub    $0xc,%esp
f0103597:	53                   	push   %ebx
f0103598:	e8 28 fe ff ff       	call   f01033c5 <env_free>

	if (curenv == e) {
f010359d:	e8 44 26 00 00       	call   f0105be6 <cpunum>
f01035a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01035a5:	83 c4 10             	add    $0x10,%esp
f01035a8:	3b 98 28 00 21 f0    	cmp    -0xfdeffd8(%eax),%ebx
f01035ae:	75 17                	jne    f01035c7 <env_destroy+0x5c>
		curenv = NULL;
f01035b0:	e8 31 26 00 00       	call   f0105be6 <cpunum>
f01035b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01035b8:	c7 80 28 00 21 f0 00 	movl   $0x0,-0xfdeffd8(%eax)
f01035bf:	00 00 00 
		sched_yield();
f01035c2:	e8 ab 0e 00 00       	call   f0104472 <sched_yield>
	}
}
f01035c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035ca:	c9                   	leave  
f01035cb:	c3                   	ret    

f01035cc <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035cc:	55                   	push   %ebp
f01035cd:	89 e5                	mov    %esp,%ebp
f01035cf:	53                   	push   %ebx
f01035d0:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01035d3:	e8 0e 26 00 00       	call   f0105be6 <cpunum>
f01035d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01035db:	8b 98 28 00 21 f0    	mov    -0xfdeffd8(%eax),%ebx
f01035e1:	e8 00 26 00 00       	call   f0105be6 <cpunum>
f01035e6:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01035e9:	8b 65 08             	mov    0x8(%ebp),%esp
f01035ec:	61                   	popa   
f01035ed:	07                   	pop    %es
f01035ee:	1f                   	pop    %ds
f01035ef:	83 c4 08             	add    $0x8,%esp
f01035f2:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01035f3:	83 ec 04             	sub    $0x4,%esp
f01035f6:	68 a7 76 10 f0       	push   $0xf01076a7
f01035fb:	68 24 02 00 00       	push   $0x224
f0103600:	68 9c 76 10 f0       	push   $0xf010769c
f0103605:	e8 36 ca ff ff       	call   f0100040 <_panic>

f010360a <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010360a:	55                   	push   %ebp
f010360b:	89 e5                	mov    %esp,%ebp
f010360d:	53                   	push   %ebx
f010360e:	83 ec 04             	sub    $0x4,%esp
f0103611:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	// context switch
	if (curenv != e) {
f0103614:	e8 cd 25 00 00       	call   f0105be6 <cpunum>
f0103619:	6b c0 74             	imul   $0x74,%eax,%eax
f010361c:	39 98 28 00 21 f0    	cmp    %ebx,-0xfdeffd8(%eax)
f0103622:	74 3a                	je     f010365e <env_run+0x54>

		if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103624:	e8 bd 25 00 00       	call   f0105be6 <cpunum>
f0103629:	6b c0 74             	imul   $0x74,%eax,%eax
f010362c:	83 b8 28 00 21 f0 00 	cmpl   $0x0,-0xfdeffd8(%eax)
f0103633:	74 29                	je     f010365e <env_run+0x54>
f0103635:	e8 ac 25 00 00       	call   f0105be6 <cpunum>
f010363a:	6b c0 74             	imul   $0x74,%eax,%eax
f010363d:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f0103643:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103647:	75 15                	jne    f010365e <env_run+0x54>
			curenv->env_status = ENV_RUNNABLE;
f0103649:	e8 98 25 00 00       	call   f0105be6 <cpunum>
f010364e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103651:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f0103657:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
			
	}
	
	curenv = e;
f010365e:	e8 83 25 00 00       	call   f0105be6 <cpunum>
f0103663:	6b c0 74             	imul   $0x74,%eax,%eax
f0103666:	89 98 28 00 21 f0    	mov    %ebx,-0xfdeffd8(%eax)
	curenv->env_status = ENV_RUNNING;
f010366c:	e8 75 25 00 00       	call   f0105be6 <cpunum>
f0103671:	6b c0 74             	imul   $0x74,%eax,%eax
f0103674:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f010367a:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103681:	e8 60 25 00 00       	call   f0105be6 <cpunum>
f0103686:	6b c0 74             	imul   $0x74,%eax,%eax
f0103689:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f010368f:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103693:	e8 4e 25 00 00       	call   f0105be6 <cpunum>
f0103698:	6b c0 74             	imul   $0x74,%eax,%eax
f010369b:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01036a1:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036a4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036a9:	77 15                	ja     f01036c0 <env_run+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036ab:	50                   	push   %eax
f01036ac:	68 c8 62 10 f0       	push   $0xf01062c8
f01036b1:	68 4e 02 00 00       	push   $0x24e
f01036b6:	68 9c 76 10 f0       	push   $0xf010769c
f01036bb:	e8 80 c9 ff ff       	call   f0100040 <_panic>
f01036c0:	05 00 00 00 10       	add    $0x10000000,%eax
f01036c5:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01036c8:	83 ec 0c             	sub    $0xc,%esp
f01036cb:	68 c0 03 12 f0       	push   $0xf01203c0
f01036d0:	e8 1c 28 00 00       	call   f0105ef1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01036d5:	f3 90                	pause  

	unlock_kernel();

	// iret to execute entry point stored in tf_eip
	// cprintf("[?] try to execute at entry point: %x\n", curenv->env_tf.tf_eip);
	env_pop_tf(&curenv->env_tf);
f01036d7:	e8 0a 25 00 00       	call   f0105be6 <cpunum>
f01036dc:	83 c4 04             	add    $0x4,%esp
f01036df:	6b c0 74             	imul   $0x74,%eax,%eax
f01036e2:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f01036e8:	e8 df fe ff ff       	call   f01035cc <env_pop_tf>

f01036ed <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01036ed:	55                   	push   %ebp
f01036ee:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036f0:	ba 70 00 00 00       	mov    $0x70,%edx
f01036f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01036f8:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036f9:	ba 71 00 00 00       	mov    $0x71,%edx
f01036fe:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01036ff:	0f b6 c0             	movzbl %al,%eax
}
f0103702:	5d                   	pop    %ebp
f0103703:	c3                   	ret    

f0103704 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103704:	55                   	push   %ebp
f0103705:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103707:	ba 70 00 00 00       	mov    $0x70,%edx
f010370c:	8b 45 08             	mov    0x8(%ebp),%eax
f010370f:	ee                   	out    %al,(%dx)
f0103710:	ba 71 00 00 00       	mov    $0x71,%edx
f0103715:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103718:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103719:	5d                   	pop    %ebp
f010371a:	c3                   	ret    

f010371b <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010371b:	55                   	push   %ebp
f010371c:	89 e5                	mov    %esp,%ebp
f010371e:	56                   	push   %esi
f010371f:	53                   	push   %ebx
f0103720:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103723:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103729:	80 3d 50 f2 20 f0 00 	cmpb   $0x0,0xf020f250
f0103730:	74 5a                	je     f010378c <irq_setmask_8259A+0x71>
f0103732:	89 c6                	mov    %eax,%esi
f0103734:	ba 21 00 00 00       	mov    $0x21,%edx
f0103739:	ee                   	out    %al,(%dx)
f010373a:	66 c1 e8 08          	shr    $0x8,%ax
f010373e:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103743:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103744:	83 ec 0c             	sub    $0xc,%esp
f0103747:	68 b3 76 10 f0       	push   $0xf01076b3
f010374c:	e8 1b 01 00 00       	call   f010386c <cprintf>
f0103751:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103754:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103759:	0f b7 f6             	movzwl %si,%esi
f010375c:	f7 d6                	not    %esi
f010375e:	0f a3 de             	bt     %ebx,%esi
f0103761:	73 11                	jae    f0103774 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103763:	83 ec 08             	sub    $0x8,%esp
f0103766:	53                   	push   %ebx
f0103767:	68 2b 7b 10 f0       	push   $0xf0107b2b
f010376c:	e8 fb 00 00 00       	call   f010386c <cprintf>
f0103771:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103774:	83 c3 01             	add    $0x1,%ebx
f0103777:	83 fb 10             	cmp    $0x10,%ebx
f010377a:	75 e2                	jne    f010375e <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010377c:	83 ec 0c             	sub    $0xc,%esp
f010377f:	68 60 6b 10 f0       	push   $0xf0106b60
f0103784:	e8 e3 00 00 00       	call   f010386c <cprintf>
f0103789:	83 c4 10             	add    $0x10,%esp
}
f010378c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010378f:	5b                   	pop    %ebx
f0103790:	5e                   	pop    %esi
f0103791:	5d                   	pop    %ebp
f0103792:	c3                   	ret    

f0103793 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103793:	c6 05 50 f2 20 f0 01 	movb   $0x1,0xf020f250
f010379a:	ba 21 00 00 00       	mov    $0x21,%edx
f010379f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037a4:	ee                   	out    %al,(%dx)
f01037a5:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037aa:	ee                   	out    %al,(%dx)
f01037ab:	ba 20 00 00 00       	mov    $0x20,%edx
f01037b0:	b8 11 00 00 00       	mov    $0x11,%eax
f01037b5:	ee                   	out    %al,(%dx)
f01037b6:	ba 21 00 00 00       	mov    $0x21,%edx
f01037bb:	b8 20 00 00 00       	mov    $0x20,%eax
f01037c0:	ee                   	out    %al,(%dx)
f01037c1:	b8 04 00 00 00       	mov    $0x4,%eax
f01037c6:	ee                   	out    %al,(%dx)
f01037c7:	b8 03 00 00 00       	mov    $0x3,%eax
f01037cc:	ee                   	out    %al,(%dx)
f01037cd:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037d2:	b8 11 00 00 00       	mov    $0x11,%eax
f01037d7:	ee                   	out    %al,(%dx)
f01037d8:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037dd:	b8 28 00 00 00       	mov    $0x28,%eax
f01037e2:	ee                   	out    %al,(%dx)
f01037e3:	b8 02 00 00 00       	mov    $0x2,%eax
f01037e8:	ee                   	out    %al,(%dx)
f01037e9:	b8 01 00 00 00       	mov    $0x1,%eax
f01037ee:	ee                   	out    %al,(%dx)
f01037ef:	ba 20 00 00 00       	mov    $0x20,%edx
f01037f4:	b8 68 00 00 00       	mov    $0x68,%eax
f01037f9:	ee                   	out    %al,(%dx)
f01037fa:	b8 0a 00 00 00       	mov    $0xa,%eax
f01037ff:	ee                   	out    %al,(%dx)
f0103800:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103805:	b8 68 00 00 00       	mov    $0x68,%eax
f010380a:	ee                   	out    %al,(%dx)
f010380b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103810:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103811:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0103818:	66 83 f8 ff          	cmp    $0xffff,%ax
f010381c:	74 13                	je     f0103831 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010381e:	55                   	push   %ebp
f010381f:	89 e5                	mov    %esp,%ebp
f0103821:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103824:	0f b7 c0             	movzwl %ax,%eax
f0103827:	50                   	push   %eax
f0103828:	e8 ee fe ff ff       	call   f010371b <irq_setmask_8259A>
f010382d:	83 c4 10             	add    $0x10,%esp
}
f0103830:	c9                   	leave  
f0103831:	f3 c3                	repz ret 

f0103833 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103833:	55                   	push   %ebp
f0103834:	89 e5                	mov    %esp,%ebp
f0103836:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103839:	ff 75 08             	pushl  0x8(%ebp)
f010383c:	e8 41 cf ff ff       	call   f0100782 <cputchar>
	*cnt++;
}
f0103841:	83 c4 10             	add    $0x10,%esp
f0103844:	c9                   	leave  
f0103845:	c3                   	ret    

f0103846 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103846:	55                   	push   %ebp
f0103847:	89 e5                	mov    %esp,%ebp
f0103849:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010384c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103853:	ff 75 0c             	pushl  0xc(%ebp)
f0103856:	ff 75 08             	pushl  0x8(%ebp)
f0103859:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010385c:	50                   	push   %eax
f010385d:	68 33 38 10 f0       	push   $0xf0103833
f0103862:	e8 db 16 00 00       	call   f0104f42 <vprintfmt>
	return cnt;
}
f0103867:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010386a:	c9                   	leave  
f010386b:	c3                   	ret    

f010386c <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010386c:	55                   	push   %ebp
f010386d:	89 e5                	mov    %esp,%ebp
f010386f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103872:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103875:	50                   	push   %eax
f0103876:	ff 75 08             	pushl  0x8(%ebp)
f0103879:	e8 c8 ff ff ff       	call   f0103846 <vcprintf>
	va_end(ap);

	return cnt;
}
f010387e:	c9                   	leave  
f010387f:	c3                   	ret    

f0103880 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103880:	55                   	push   %ebp
f0103881:	89 e5                	mov    %esp,%ebp
f0103883:	57                   	push   %edi
f0103884:	56                   	push   %esi
f0103885:	53                   	push   %ebx
f0103886:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t) percpu_kstacks[cpunum()];
f0103889:	e8 58 23 00 00       	call   f0105be6 <cpunum>
f010388e:	89 c3                	mov    %eax,%ebx
f0103890:	e8 51 23 00 00       	call   f0105be6 <cpunum>
f0103895:	6b db 74             	imul   $0x74,%ebx,%ebx
f0103898:	c1 e0 0f             	shl    $0xf,%eax
f010389b:	05 00 10 21 f0       	add    $0xf0211000,%eax
f01038a0:	89 83 30 00 21 f0    	mov    %eax,-0xfdeffd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01038a6:	e8 3b 23 00 00       	call   f0105be6 <cpunum>
f01038ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01038ae:	66 c7 80 34 00 21 f0 	movw   $0x10,-0xfdeffcc(%eax)
f01038b5:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01038b7:	e8 2a 23 00 00       	call   f0105be6 <cpunum>
f01038bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01038bf:	66 c7 80 92 00 21 f0 	movw   $0x68,-0xfdeff6e(%eax)
f01038c6:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01038c8:	e8 19 23 00 00       	call   f0105be6 <cpunum>
f01038cd:	8d 58 05             	lea    0x5(%eax),%ebx
f01038d0:	e8 11 23 00 00       	call   f0105be6 <cpunum>
f01038d5:	89 c7                	mov    %eax,%edi
f01038d7:	e8 0a 23 00 00       	call   f0105be6 <cpunum>
f01038dc:	89 c6                	mov    %eax,%esi
f01038de:	e8 03 23 00 00       	call   f0105be6 <cpunum>
f01038e3:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f01038ea:	f0 67 00 
f01038ed:	6b ff 74             	imul   $0x74,%edi,%edi
f01038f0:	81 c7 2c 00 21 f0    	add    $0xf021002c,%edi
f01038f6:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f01038fd:	f0 
f01038fe:	6b d6 74             	imul   $0x74,%esi,%edx
f0103901:	81 c2 2c 00 21 f0    	add    $0xf021002c,%edx
f0103907:	c1 ea 10             	shr    $0x10,%edx
f010390a:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f0103911:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f0103918:	99 
f0103919:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f0103920:	40 
f0103921:	6b c0 74             	imul   $0x74,%eax,%eax
f0103924:	05 2c 00 21 f0       	add    $0xf021002c,%eax
f0103929:	c1 e8 18             	shr    $0x18,%eax
f010392c:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0103933:	e8 ae 22 00 00       	call   f0105be6 <cpunum>
f0103938:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f010393f:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f0103940:	e8 a1 22 00 00       	call   f0105be6 <cpunum>
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103945:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f010394c:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f010394f:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f0103954:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103957:	83 c4 0c             	add    $0xc,%esp
f010395a:	5b                   	pop    %ebx
f010395b:	5e                   	pop    %esi
f010395c:	5f                   	pop    %edi
f010395d:	5d                   	pop    %ebp
f010395e:	c3                   	ret    

f010395f <trap_init>:
}


void
trap_init(void)
{
f010395f:	55                   	push   %ebp
f0103960:	89 e5                	mov    %esp,%ebp
f0103962:	83 ec 08             	sub    $0x8,%esp
	void _IRQ_SPURIOUS_handler();
	void _IRQ_IDE_handler();
	void _IRQ_ERROR_handler();

	// SETGATE(gate, istrap, sel, off, dpl);
	SETGATE(idt[T_DIVIDE], 0, GD_KT, _T_DIVIDE_handler, 0);
f0103965:	b8 00 43 10 f0       	mov    $0xf0104300,%eax
f010396a:	66 a3 60 f2 20 f0    	mov    %ax,0xf020f260
f0103970:	66 c7 05 62 f2 20 f0 	movw   $0x8,0xf020f262
f0103977:	08 00 
f0103979:	c6 05 64 f2 20 f0 00 	movb   $0x0,0xf020f264
f0103980:	c6 05 65 f2 20 f0 8e 	movb   $0x8e,0xf020f265
f0103987:	c1 e8 10             	shr    $0x10,%eax
f010398a:	66 a3 66 f2 20 f0    	mov    %ax,0xf020f266
	SETGATE(idt[T_DEBUG], 0, GD_KT, _T_DEBUG_handler, 0);
f0103990:	b8 0a 43 10 f0       	mov    $0xf010430a,%eax
f0103995:	66 a3 68 f2 20 f0    	mov    %ax,0xf020f268
f010399b:	66 c7 05 6a f2 20 f0 	movw   $0x8,0xf020f26a
f01039a2:	08 00 
f01039a4:	c6 05 6c f2 20 f0 00 	movb   $0x0,0xf020f26c
f01039ab:	c6 05 6d f2 20 f0 8e 	movb   $0x8e,0xf020f26d
f01039b2:	c1 e8 10             	shr    $0x10,%eax
f01039b5:	66 a3 6e f2 20 f0    	mov    %ax,0xf020f26e
	SETGATE(idt[T_NMI], 0, GD_KT, _T_NMI_handler, 0);
f01039bb:	b8 10 43 10 f0       	mov    $0xf0104310,%eax
f01039c0:	66 a3 70 f2 20 f0    	mov    %ax,0xf020f270
f01039c6:	66 c7 05 72 f2 20 f0 	movw   $0x8,0xf020f272
f01039cd:	08 00 
f01039cf:	c6 05 74 f2 20 f0 00 	movb   $0x0,0xf020f274
f01039d6:	c6 05 75 f2 20 f0 8e 	movb   $0x8e,0xf020f275
f01039dd:	c1 e8 10             	shr    $0x10,%eax
f01039e0:	66 a3 76 f2 20 f0    	mov    %ax,0xf020f276
	SETGATE(idt[T_BRKPT], 0, GD_KT, _T_BRKPT_handler, 3);
f01039e6:	b8 16 43 10 f0       	mov    $0xf0104316,%eax
f01039eb:	66 a3 78 f2 20 f0    	mov    %ax,0xf020f278
f01039f1:	66 c7 05 7a f2 20 f0 	movw   $0x8,0xf020f27a
f01039f8:	08 00 
f01039fa:	c6 05 7c f2 20 f0 00 	movb   $0x0,0xf020f27c
f0103a01:	c6 05 7d f2 20 f0 ee 	movb   $0xee,0xf020f27d
f0103a08:	c1 e8 10             	shr    $0x10,%eax
f0103a0b:	66 a3 7e f2 20 f0    	mov    %ax,0xf020f27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, _T_OFLOW_handler, 0);
f0103a11:	b8 1c 43 10 f0       	mov    $0xf010431c,%eax
f0103a16:	66 a3 80 f2 20 f0    	mov    %ax,0xf020f280
f0103a1c:	66 c7 05 82 f2 20 f0 	movw   $0x8,0xf020f282
f0103a23:	08 00 
f0103a25:	c6 05 84 f2 20 f0 00 	movb   $0x0,0xf020f284
f0103a2c:	c6 05 85 f2 20 f0 8e 	movb   $0x8e,0xf020f285
f0103a33:	c1 e8 10             	shr    $0x10,%eax
f0103a36:	66 a3 86 f2 20 f0    	mov    %ax,0xf020f286
	SETGATE(idt[T_BOUND], 0, GD_KT, _T_BOUND_handler, 0);
f0103a3c:	b8 22 43 10 f0       	mov    $0xf0104322,%eax
f0103a41:	66 a3 88 f2 20 f0    	mov    %ax,0xf020f288
f0103a47:	66 c7 05 8a f2 20 f0 	movw   $0x8,0xf020f28a
f0103a4e:	08 00 
f0103a50:	c6 05 8c f2 20 f0 00 	movb   $0x0,0xf020f28c
f0103a57:	c6 05 8d f2 20 f0 8e 	movb   $0x8e,0xf020f28d
f0103a5e:	c1 e8 10             	shr    $0x10,%eax
f0103a61:	66 a3 8e f2 20 f0    	mov    %ax,0xf020f28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, _T_ILLOP_handler, 0);
f0103a67:	b8 28 43 10 f0       	mov    $0xf0104328,%eax
f0103a6c:	66 a3 90 f2 20 f0    	mov    %ax,0xf020f290
f0103a72:	66 c7 05 92 f2 20 f0 	movw   $0x8,0xf020f292
f0103a79:	08 00 
f0103a7b:	c6 05 94 f2 20 f0 00 	movb   $0x0,0xf020f294
f0103a82:	c6 05 95 f2 20 f0 8e 	movb   $0x8e,0xf020f295
f0103a89:	c1 e8 10             	shr    $0x10,%eax
f0103a8c:	66 a3 96 f2 20 f0    	mov    %ax,0xf020f296
	SETGATE(idt[T_DEVICE], 0, GD_KT, _T_DEVICE_handler, 0);
f0103a92:	b8 2e 43 10 f0       	mov    $0xf010432e,%eax
f0103a97:	66 a3 98 f2 20 f0    	mov    %ax,0xf020f298
f0103a9d:	66 c7 05 9a f2 20 f0 	movw   $0x8,0xf020f29a
f0103aa4:	08 00 
f0103aa6:	c6 05 9c f2 20 f0 00 	movb   $0x0,0xf020f29c
f0103aad:	c6 05 9d f2 20 f0 8e 	movb   $0x8e,0xf020f29d
f0103ab4:	c1 e8 10             	shr    $0x10,%eax
f0103ab7:	66 a3 9e f2 20 f0    	mov    %ax,0xf020f29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, _T_DBLFLT_handler, 0);
f0103abd:	b8 34 43 10 f0       	mov    $0xf0104334,%eax
f0103ac2:	66 a3 a0 f2 20 f0    	mov    %ax,0xf020f2a0
f0103ac8:	66 c7 05 a2 f2 20 f0 	movw   $0x8,0xf020f2a2
f0103acf:	08 00 
f0103ad1:	c6 05 a4 f2 20 f0 00 	movb   $0x0,0xf020f2a4
f0103ad8:	c6 05 a5 f2 20 f0 8e 	movb   $0x8e,0xf020f2a5
f0103adf:	c1 e8 10             	shr    $0x10,%eax
f0103ae2:	66 a3 a6 f2 20 f0    	mov    %ax,0xf020f2a6
	SETGATE(idt[T_TSS], 0, GD_KT, _T_TSS_handler, 0);
f0103ae8:	b8 38 43 10 f0       	mov    $0xf0104338,%eax
f0103aed:	66 a3 b0 f2 20 f0    	mov    %ax,0xf020f2b0
f0103af3:	66 c7 05 b2 f2 20 f0 	movw   $0x8,0xf020f2b2
f0103afa:	08 00 
f0103afc:	c6 05 b4 f2 20 f0 00 	movb   $0x0,0xf020f2b4
f0103b03:	c6 05 b5 f2 20 f0 8e 	movb   $0x8e,0xf020f2b5
f0103b0a:	c1 e8 10             	shr    $0x10,%eax
f0103b0d:	66 a3 b6 f2 20 f0    	mov    %ax,0xf020f2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, _T_SEGNP_handler, 0);
f0103b13:	b8 3c 43 10 f0       	mov    $0xf010433c,%eax
f0103b18:	66 a3 b8 f2 20 f0    	mov    %ax,0xf020f2b8
f0103b1e:	66 c7 05 ba f2 20 f0 	movw   $0x8,0xf020f2ba
f0103b25:	08 00 
f0103b27:	c6 05 bc f2 20 f0 00 	movb   $0x0,0xf020f2bc
f0103b2e:	c6 05 bd f2 20 f0 8e 	movb   $0x8e,0xf020f2bd
f0103b35:	c1 e8 10             	shr    $0x10,%eax
f0103b38:	66 a3 be f2 20 f0    	mov    %ax,0xf020f2be
	SETGATE(idt[T_STACK], 0, GD_KT, _T_STACK_handler, 0);
f0103b3e:	b8 40 43 10 f0       	mov    $0xf0104340,%eax
f0103b43:	66 a3 c0 f2 20 f0    	mov    %ax,0xf020f2c0
f0103b49:	66 c7 05 c2 f2 20 f0 	movw   $0x8,0xf020f2c2
f0103b50:	08 00 
f0103b52:	c6 05 c4 f2 20 f0 00 	movb   $0x0,0xf020f2c4
f0103b59:	c6 05 c5 f2 20 f0 8e 	movb   $0x8e,0xf020f2c5
f0103b60:	c1 e8 10             	shr    $0x10,%eax
f0103b63:	66 a3 c6 f2 20 f0    	mov    %ax,0xf020f2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, _T_GPFLT_handler, 0);
f0103b69:	b8 44 43 10 f0       	mov    $0xf0104344,%eax
f0103b6e:	66 a3 c8 f2 20 f0    	mov    %ax,0xf020f2c8
f0103b74:	66 c7 05 ca f2 20 f0 	movw   $0x8,0xf020f2ca
f0103b7b:	08 00 
f0103b7d:	c6 05 cc f2 20 f0 00 	movb   $0x0,0xf020f2cc
f0103b84:	c6 05 cd f2 20 f0 8e 	movb   $0x8e,0xf020f2cd
f0103b8b:	c1 e8 10             	shr    $0x10,%eax
f0103b8e:	66 a3 ce f2 20 f0    	mov    %ax,0xf020f2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, _T_PGFLT_handler, 0);
f0103b94:	b8 48 43 10 f0       	mov    $0xf0104348,%eax
f0103b99:	66 a3 d0 f2 20 f0    	mov    %ax,0xf020f2d0
f0103b9f:	66 c7 05 d2 f2 20 f0 	movw   $0x8,0xf020f2d2
f0103ba6:	08 00 
f0103ba8:	c6 05 d4 f2 20 f0 00 	movb   $0x0,0xf020f2d4
f0103baf:	c6 05 d5 f2 20 f0 8e 	movb   $0x8e,0xf020f2d5
f0103bb6:	c1 e8 10             	shr    $0x10,%eax
f0103bb9:	66 a3 d6 f2 20 f0    	mov    %ax,0xf020f2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, _T_FPERR_handler, 0);
f0103bbf:	b8 4c 43 10 f0       	mov    $0xf010434c,%eax
f0103bc4:	66 a3 e0 f2 20 f0    	mov    %ax,0xf020f2e0
f0103bca:	66 c7 05 e2 f2 20 f0 	movw   $0x8,0xf020f2e2
f0103bd1:	08 00 
f0103bd3:	c6 05 e4 f2 20 f0 00 	movb   $0x0,0xf020f2e4
f0103bda:	c6 05 e5 f2 20 f0 8e 	movb   $0x8e,0xf020f2e5
f0103be1:	c1 e8 10             	shr    $0x10,%eax
f0103be4:	66 a3 e6 f2 20 f0    	mov    %ax,0xf020f2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, _T_ALIGN_handler, 0);
f0103bea:	b8 52 43 10 f0       	mov    $0xf0104352,%eax
f0103bef:	66 a3 e8 f2 20 f0    	mov    %ax,0xf020f2e8
f0103bf5:	66 c7 05 ea f2 20 f0 	movw   $0x8,0xf020f2ea
f0103bfc:	08 00 
f0103bfe:	c6 05 ec f2 20 f0 00 	movb   $0x0,0xf020f2ec
f0103c05:	c6 05 ed f2 20 f0 8e 	movb   $0x8e,0xf020f2ed
f0103c0c:	c1 e8 10             	shr    $0x10,%eax
f0103c0f:	66 a3 ee f2 20 f0    	mov    %ax,0xf020f2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, _T_MCHK_handler, 0);
f0103c15:	b8 56 43 10 f0       	mov    $0xf0104356,%eax
f0103c1a:	66 a3 f0 f2 20 f0    	mov    %ax,0xf020f2f0
f0103c20:	66 c7 05 f2 f2 20 f0 	movw   $0x8,0xf020f2f2
f0103c27:	08 00 
f0103c29:	c6 05 f4 f2 20 f0 00 	movb   $0x0,0xf020f2f4
f0103c30:	c6 05 f5 f2 20 f0 8e 	movb   $0x8e,0xf020f2f5
f0103c37:	c1 e8 10             	shr    $0x10,%eax
f0103c3a:	66 a3 f6 f2 20 f0    	mov    %ax,0xf020f2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, _T_SIMDERR_handler, 0);
f0103c40:	b8 5c 43 10 f0       	mov    $0xf010435c,%eax
f0103c45:	66 a3 f8 f2 20 f0    	mov    %ax,0xf020f2f8
f0103c4b:	66 c7 05 fa f2 20 f0 	movw   $0x8,0xf020f2fa
f0103c52:	08 00 
f0103c54:	c6 05 fc f2 20 f0 00 	movb   $0x0,0xf020f2fc
f0103c5b:	c6 05 fd f2 20 f0 8e 	movb   $0x8e,0xf020f2fd
f0103c62:	c1 e8 10             	shr    $0x10,%eax
f0103c65:	66 a3 fe f2 20 f0    	mov    %ax,0xf020f2fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, _T_SYSCALL_handler, 3);
f0103c6b:	b8 62 43 10 f0       	mov    $0xf0104362,%eax
f0103c70:	66 a3 e0 f3 20 f0    	mov    %ax,0xf020f3e0
f0103c76:	66 c7 05 e2 f3 20 f0 	movw   $0x8,0xf020f3e2
f0103c7d:	08 00 
f0103c7f:	c6 05 e4 f3 20 f0 00 	movb   $0x0,0xf020f3e4
f0103c86:	c6 05 e5 f3 20 f0 ee 	movb   $0xee,0xf020f3e5
f0103c8d:	c1 e8 10             	shr    $0x10,%eax
f0103c90:	66 a3 e6 f3 20 f0    	mov    %ax,0xf020f3e6

	SETGATE(idt[IRQ_TIMER + IRQ_OFFSET], 0, GD_KT, _IRQ_TIMER_handler, 0);
f0103c96:	b8 68 43 10 f0       	mov    $0xf0104368,%eax
f0103c9b:	66 a3 60 f3 20 f0    	mov    %ax,0xf020f360
f0103ca1:	66 c7 05 62 f3 20 f0 	movw   $0x8,0xf020f362
f0103ca8:	08 00 
f0103caa:	c6 05 64 f3 20 f0 00 	movb   $0x0,0xf020f364
f0103cb1:	c6 05 65 f3 20 f0 8e 	movb   $0x8e,0xf020f365
f0103cb8:	c1 e8 10             	shr    $0x10,%eax
f0103cbb:	66 a3 66 f3 20 f0    	mov    %ax,0xf020f366
	SETGATE(idt[IRQ_KBD + IRQ_OFFSET], 0, GD_KT, _IRQ_KBD_handler, 0);
f0103cc1:	b8 6e 43 10 f0       	mov    $0xf010436e,%eax
f0103cc6:	66 a3 68 f3 20 f0    	mov    %ax,0xf020f368
f0103ccc:	66 c7 05 6a f3 20 f0 	movw   $0x8,0xf020f36a
f0103cd3:	08 00 
f0103cd5:	c6 05 6c f3 20 f0 00 	movb   $0x0,0xf020f36c
f0103cdc:	c6 05 6d f3 20 f0 8e 	movb   $0x8e,0xf020f36d
f0103ce3:	c1 e8 10             	shr    $0x10,%eax
f0103ce6:	66 a3 6e f3 20 f0    	mov    %ax,0xf020f36e
	SETGATE(idt[IRQ_SERIAL + IRQ_OFFSET], 0, GD_KT, _IRQ_SERIAL_handler, 0);
f0103cec:	b8 74 43 10 f0       	mov    $0xf0104374,%eax
f0103cf1:	66 a3 80 f3 20 f0    	mov    %ax,0xf020f380
f0103cf7:	66 c7 05 82 f3 20 f0 	movw   $0x8,0xf020f382
f0103cfe:	08 00 
f0103d00:	c6 05 84 f3 20 f0 00 	movb   $0x0,0xf020f384
f0103d07:	c6 05 85 f3 20 f0 8e 	movb   $0x8e,0xf020f385
f0103d0e:	c1 e8 10             	shr    $0x10,%eax
f0103d11:	66 a3 86 f3 20 f0    	mov    %ax,0xf020f386
	SETGATE(idt[IRQ_SPURIOUS + IRQ_OFFSET], 0, GD_KT, _IRQ_SPURIOUS_handler, 0);
f0103d17:	b8 7a 43 10 f0       	mov    $0xf010437a,%eax
f0103d1c:	66 a3 98 f3 20 f0    	mov    %ax,0xf020f398
f0103d22:	66 c7 05 9a f3 20 f0 	movw   $0x8,0xf020f39a
f0103d29:	08 00 
f0103d2b:	c6 05 9c f3 20 f0 00 	movb   $0x0,0xf020f39c
f0103d32:	c6 05 9d f3 20 f0 8e 	movb   $0x8e,0xf020f39d
f0103d39:	c1 e8 10             	shr    $0x10,%eax
f0103d3c:	66 a3 9e f3 20 f0    	mov    %ax,0xf020f39e
	SETGATE(idt[IRQ_IDE + IRQ_OFFSET], 0, GD_KT, _IRQ_IDE_handler, 0);
f0103d42:	b8 80 43 10 f0       	mov    $0xf0104380,%eax
f0103d47:	66 a3 d0 f3 20 f0    	mov    %ax,0xf020f3d0
f0103d4d:	66 c7 05 d2 f3 20 f0 	movw   $0x8,0xf020f3d2
f0103d54:	08 00 
f0103d56:	c6 05 d4 f3 20 f0 00 	movb   $0x0,0xf020f3d4
f0103d5d:	c6 05 d5 f3 20 f0 8e 	movb   $0x8e,0xf020f3d5
f0103d64:	c1 e8 10             	shr    $0x10,%eax
f0103d67:	66 a3 d6 f3 20 f0    	mov    %ax,0xf020f3d6
	SETGATE(idt[IRQ_ERROR + IRQ_OFFSET], 0, GD_KT, _IRQ_ERROR_handler, 0);
f0103d6d:	b8 86 43 10 f0       	mov    $0xf0104386,%eax
f0103d72:	66 a3 f8 f3 20 f0    	mov    %ax,0xf020f3f8
f0103d78:	66 c7 05 fa f3 20 f0 	movw   $0x8,0xf020f3fa
f0103d7f:	08 00 
f0103d81:	c6 05 fc f3 20 f0 00 	movb   $0x0,0xf020f3fc
f0103d88:	c6 05 fd f3 20 f0 8e 	movb   $0x8e,0xf020f3fd
f0103d8f:	c1 e8 10             	shr    $0x10,%eax
f0103d92:	66 a3 fe f3 20 f0    	mov    %ax,0xf020f3fe

	// Per-CPU setup 
	trap_init_percpu();
f0103d98:	e8 e3 fa ff ff       	call   f0103880 <trap_init_percpu>
}
f0103d9d:	c9                   	leave  
f0103d9e:	c3                   	ret    

f0103d9f <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d9f:	55                   	push   %ebp
f0103da0:	89 e5                	mov    %esp,%ebp
f0103da2:	53                   	push   %ebx
f0103da3:	83 ec 0c             	sub    $0xc,%esp
f0103da6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103da9:	ff 33                	pushl  (%ebx)
f0103dab:	68 c7 76 10 f0       	push   $0xf01076c7
f0103db0:	e8 b7 fa ff ff       	call   f010386c <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103db5:	83 c4 08             	add    $0x8,%esp
f0103db8:	ff 73 04             	pushl  0x4(%ebx)
f0103dbb:	68 d6 76 10 f0       	push   $0xf01076d6
f0103dc0:	e8 a7 fa ff ff       	call   f010386c <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103dc5:	83 c4 08             	add    $0x8,%esp
f0103dc8:	ff 73 08             	pushl  0x8(%ebx)
f0103dcb:	68 e5 76 10 f0       	push   $0xf01076e5
f0103dd0:	e8 97 fa ff ff       	call   f010386c <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103dd5:	83 c4 08             	add    $0x8,%esp
f0103dd8:	ff 73 0c             	pushl  0xc(%ebx)
f0103ddb:	68 f4 76 10 f0       	push   $0xf01076f4
f0103de0:	e8 87 fa ff ff       	call   f010386c <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103de5:	83 c4 08             	add    $0x8,%esp
f0103de8:	ff 73 10             	pushl  0x10(%ebx)
f0103deb:	68 03 77 10 f0       	push   $0xf0107703
f0103df0:	e8 77 fa ff ff       	call   f010386c <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103df5:	83 c4 08             	add    $0x8,%esp
f0103df8:	ff 73 14             	pushl  0x14(%ebx)
f0103dfb:	68 12 77 10 f0       	push   $0xf0107712
f0103e00:	e8 67 fa ff ff       	call   f010386c <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e05:	83 c4 08             	add    $0x8,%esp
f0103e08:	ff 73 18             	pushl  0x18(%ebx)
f0103e0b:	68 21 77 10 f0       	push   $0xf0107721
f0103e10:	e8 57 fa ff ff       	call   f010386c <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e15:	83 c4 08             	add    $0x8,%esp
f0103e18:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e1b:	68 30 77 10 f0       	push   $0xf0107730
f0103e20:	e8 47 fa ff ff       	call   f010386c <cprintf>
}
f0103e25:	83 c4 10             	add    $0x10,%esp
f0103e28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e2b:	c9                   	leave  
f0103e2c:	c3                   	ret    

f0103e2d <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103e2d:	55                   	push   %ebp
f0103e2e:	89 e5                	mov    %esp,%ebp
f0103e30:	56                   	push   %esi
f0103e31:	53                   	push   %ebx
f0103e32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e35:	e8 ac 1d 00 00       	call   f0105be6 <cpunum>
f0103e3a:	83 ec 04             	sub    $0x4,%esp
f0103e3d:	50                   	push   %eax
f0103e3e:	53                   	push   %ebx
f0103e3f:	68 94 77 10 f0       	push   $0xf0107794
f0103e44:	e8 23 fa ff ff       	call   f010386c <cprintf>
	print_regs(&tf->tf_regs);
f0103e49:	89 1c 24             	mov    %ebx,(%esp)
f0103e4c:	e8 4e ff ff ff       	call   f0103d9f <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103e51:	83 c4 08             	add    $0x8,%esp
f0103e54:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103e58:	50                   	push   %eax
f0103e59:	68 b2 77 10 f0       	push   $0xf01077b2
f0103e5e:	e8 09 fa ff ff       	call   f010386c <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e63:	83 c4 08             	add    $0x8,%esp
f0103e66:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103e6a:	50                   	push   %eax
f0103e6b:	68 c5 77 10 f0       	push   $0xf01077c5
f0103e70:	e8 f7 f9 ff ff       	call   f010386c <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e75:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103e78:	83 c4 10             	add    $0x10,%esp
f0103e7b:	83 f8 13             	cmp    $0x13,%eax
f0103e7e:	77 09                	ja     f0103e89 <print_trapframe+0x5c>
		return excnames[trapno];
f0103e80:	8b 14 85 40 7a 10 f0 	mov    -0xfef85c0(,%eax,4),%edx
f0103e87:	eb 1f                	jmp    f0103ea8 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103e89:	83 f8 30             	cmp    $0x30,%eax
f0103e8c:	74 15                	je     f0103ea3 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103e8e:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103e91:	83 fa 10             	cmp    $0x10,%edx
f0103e94:	b9 5e 77 10 f0       	mov    $0xf010775e,%ecx
f0103e99:	ba 4b 77 10 f0       	mov    $0xf010774b,%edx
f0103e9e:	0f 43 d1             	cmovae %ecx,%edx
f0103ea1:	eb 05                	jmp    f0103ea8 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103ea3:	ba 3f 77 10 f0       	mov    $0xf010773f,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ea8:	83 ec 04             	sub    $0x4,%esp
f0103eab:	52                   	push   %edx
f0103eac:	50                   	push   %eax
f0103ead:	68 d8 77 10 f0       	push   $0xf01077d8
f0103eb2:	e8 b5 f9 ff ff       	call   f010386c <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103eb7:	83 c4 10             	add    $0x10,%esp
f0103eba:	3b 1d 60 fa 20 f0    	cmp    0xf020fa60,%ebx
f0103ec0:	75 1a                	jne    f0103edc <print_trapframe+0xaf>
f0103ec2:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ec6:	75 14                	jne    f0103edc <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103ec8:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103ecb:	83 ec 08             	sub    $0x8,%esp
f0103ece:	50                   	push   %eax
f0103ecf:	68 ea 77 10 f0       	push   $0xf01077ea
f0103ed4:	e8 93 f9 ff ff       	call   f010386c <cprintf>
f0103ed9:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103edc:	83 ec 08             	sub    $0x8,%esp
f0103edf:	ff 73 2c             	pushl  0x2c(%ebx)
f0103ee2:	68 f9 77 10 f0       	push   $0xf01077f9
f0103ee7:	e8 80 f9 ff ff       	call   f010386c <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103eec:	83 c4 10             	add    $0x10,%esp
f0103eef:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ef3:	75 49                	jne    f0103f3e <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103ef5:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103ef8:	89 c2                	mov    %eax,%edx
f0103efa:	83 e2 01             	and    $0x1,%edx
f0103efd:	ba 78 77 10 f0       	mov    $0xf0107778,%edx
f0103f02:	b9 6d 77 10 f0       	mov    $0xf010776d,%ecx
f0103f07:	0f 44 ca             	cmove  %edx,%ecx
f0103f0a:	89 c2                	mov    %eax,%edx
f0103f0c:	83 e2 02             	and    $0x2,%edx
f0103f0f:	ba 8a 77 10 f0       	mov    $0xf010778a,%edx
f0103f14:	be 84 77 10 f0       	mov    $0xf0107784,%esi
f0103f19:	0f 45 d6             	cmovne %esi,%edx
f0103f1c:	83 e0 04             	and    $0x4,%eax
f0103f1f:	be d1 78 10 f0       	mov    $0xf01078d1,%esi
f0103f24:	b8 8f 77 10 f0       	mov    $0xf010778f,%eax
f0103f29:	0f 44 c6             	cmove  %esi,%eax
f0103f2c:	51                   	push   %ecx
f0103f2d:	52                   	push   %edx
f0103f2e:	50                   	push   %eax
f0103f2f:	68 07 78 10 f0       	push   $0xf0107807
f0103f34:	e8 33 f9 ff ff       	call   f010386c <cprintf>
f0103f39:	83 c4 10             	add    $0x10,%esp
f0103f3c:	eb 10                	jmp    f0103f4e <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103f3e:	83 ec 0c             	sub    $0xc,%esp
f0103f41:	68 60 6b 10 f0       	push   $0xf0106b60
f0103f46:	e8 21 f9 ff ff       	call   f010386c <cprintf>
f0103f4b:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f4e:	83 ec 08             	sub    $0x8,%esp
f0103f51:	ff 73 30             	pushl  0x30(%ebx)
f0103f54:	68 16 78 10 f0       	push   $0xf0107816
f0103f59:	e8 0e f9 ff ff       	call   f010386c <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f5e:	83 c4 08             	add    $0x8,%esp
f0103f61:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103f65:	50                   	push   %eax
f0103f66:	68 25 78 10 f0       	push   $0xf0107825
f0103f6b:	e8 fc f8 ff ff       	call   f010386c <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f70:	83 c4 08             	add    $0x8,%esp
f0103f73:	ff 73 38             	pushl  0x38(%ebx)
f0103f76:	68 38 78 10 f0       	push   $0xf0107838
f0103f7b:	e8 ec f8 ff ff       	call   f010386c <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f80:	83 c4 10             	add    $0x10,%esp
f0103f83:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f87:	74 25                	je     f0103fae <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f89:	83 ec 08             	sub    $0x8,%esp
f0103f8c:	ff 73 3c             	pushl  0x3c(%ebx)
f0103f8f:	68 47 78 10 f0       	push   $0xf0107847
f0103f94:	e8 d3 f8 ff ff       	call   f010386c <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103f99:	83 c4 08             	add    $0x8,%esp
f0103f9c:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103fa0:	50                   	push   %eax
f0103fa1:	68 56 78 10 f0       	push   $0xf0107856
f0103fa6:	e8 c1 f8 ff ff       	call   f010386c <cprintf>
f0103fab:	83 c4 10             	add    $0x10,%esp
	}
}
f0103fae:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103fb1:	5b                   	pop    %ebx
f0103fb2:	5e                   	pop    %esi
f0103fb3:	5d                   	pop    %ebp
f0103fb4:	c3                   	ret    

f0103fb5 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103fb5:	55                   	push   %ebp
f0103fb6:	89 e5                	mov    %esp,%ebp
f0103fb8:	57                   	push   %edi
f0103fb9:	56                   	push   %esi
f0103fba:	53                   	push   %ebx
f0103fbb:	83 ec 1c             	sub    $0x1c,%esp
f0103fbe:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103fc1:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f0103fc4:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103fc8:	75 15                	jne    f0103fdf <page_fault_handler+0x2a>
		panic("page fault in kernel at %x!", fault_va);
f0103fca:	56                   	push   %esi
f0103fcb:	68 69 78 10 f0       	push   $0xf0107869
f0103fd0:	68 5b 01 00 00       	push   $0x15b
f0103fd5:	68 85 78 10 f0       	push   $0xf0107885
f0103fda:	e8 61 c0 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f0103fdf:	e8 02 1c 00 00       	call   f0105be6 <cpunum>
f0103fe4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fe7:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f0103fed:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103ff1:	0f 84 af 00 00 00    	je     f01040a6 <page_fault_handler+0xf1>
		uint32_t estack_top = UXSTACKTOP;

		// if pgfault happens in user exception stack
		// as mentioned above, we push things right after the previous exception stack 
		// started with dummy 4 bytes
		if (tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE)
f0103ff7:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103ffa:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			estack_top = tf->tf_esp - 4;
f0104000:	83 e8 04             	sub    $0x4,%eax
f0104003:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104009:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f010400e:	0f 46 f8             	cmovbe %eax,%edi

		// char* utrapframe = (char *)(estack_top - sizeof(struct UTrapframe));
		struct UTrapframe *utf = (struct UTrapframe *)(estack_top - sizeof(struct UTrapframe));
f0104011:	8d 47 cc             	lea    -0x34(%edi),%eax
f0104014:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// do a memory check
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_W | PTE_P);
f0104017:	e8 ca 1b 00 00       	call   f0105be6 <cpunum>
f010401c:	6a 03                	push   $0x3
f010401e:	6a 34                	push   $0x34
f0104020:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104023:	6b c0 74             	imul   $0x74,%eax,%eax
f0104026:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f010402c:	e8 23 ef ff ff       	call   f0102f54 <user_mem_assert>

		// copy context to utrapframe 
		// memcpy(utrapframe, (char *)tf, sizeof(struct UTrapframe));
		// *(uint32_t *)utrapframe = fault_va;
		utf->utf_fault_va = fault_va;
f0104031:	89 77 cc             	mov    %esi,-0x34(%edi)
        utf->utf_err      = tf->tf_trapno;
f0104034:	8b 43 28             	mov    0x28(%ebx),%eax
f0104037:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010403a:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs     = tf->tf_regs;
f010403d:	83 ef 2c             	sub    $0x2c,%edi
f0104040:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104045:	89 de                	mov    %ebx,%esi
f0104047:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        utf->utf_eflags   = tf->tf_eflags;
f0104049:	8b 43 38             	mov    0x38(%ebx),%eax
f010404c:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_eip      = tf->tf_eip;
f010404f:	8b 43 30             	mov    0x30(%ebx),%eax
f0104052:	89 d6                	mov    %edx,%esi
f0104054:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_esp      = tf->tf_esp;
f0104057:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010405a:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_esp = (uint32_t)utf;
f010405d:	e8 84 1b 00 00       	call   f0105be6 <cpunum>
f0104062:	6b c0 74             	imul   $0x74,%eax,%eax
f0104065:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f010406b:	89 70 3c             	mov    %esi,0x3c(%eax)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f010406e:	e8 73 1b 00 00       	call   f0105be6 <cpunum>
f0104073:	6b c0 74             	imul   $0x74,%eax,%eax
f0104076:	8b 98 28 00 21 f0    	mov    -0xfdeffd8(%eax),%ebx
f010407c:	e8 65 1b 00 00       	call   f0105be6 <cpunum>
f0104081:	6b c0 74             	imul   $0x74,%eax,%eax
f0104084:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f010408a:	8b 40 64             	mov    0x64(%eax),%eax
f010408d:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f0104090:	e8 51 1b 00 00       	call   f0105be6 <cpunum>
f0104095:	83 c4 04             	add    $0x4,%esp
f0104098:	6b c0 74             	imul   $0x74,%eax,%eax
f010409b:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f01040a1:	e8 64 f5 ff ff       	call   f010360a <env_run>

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040a6:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01040a9:	e8 38 1b 00 00       	call   f0105be6 <cpunum>
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040ae:	57                   	push   %edi
f01040af:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01040b0:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040b3:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01040b9:	ff 70 48             	pushl  0x48(%eax)
f01040bc:	68 1c 7a 10 f0       	push   $0xf0107a1c
f01040c1:	e8 a6 f7 ff ff       	call   f010386c <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01040c6:	89 1c 24             	mov    %ebx,(%esp)
f01040c9:	e8 5f fd ff ff       	call   f0103e2d <print_trapframe>
	env_destroy(curenv);
f01040ce:	e8 13 1b 00 00       	call   f0105be6 <cpunum>
f01040d3:	83 c4 04             	add    $0x4,%esp
f01040d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01040d9:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f01040df:	e8 87 f4 ff ff       	call   f010356b <env_destroy>
}
f01040e4:	83 c4 10             	add    $0x10,%esp
f01040e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040ea:	5b                   	pop    %ebx
f01040eb:	5e                   	pop    %esi
f01040ec:	5f                   	pop    %edi
f01040ed:	5d                   	pop    %ebp
f01040ee:	c3                   	ret    

f01040ef <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01040ef:	55                   	push   %ebp
f01040f0:	89 e5                	mov    %esp,%ebp
f01040f2:	57                   	push   %edi
f01040f3:	56                   	push   %esi
f01040f4:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01040f7:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01040f8:	83 3d 80 fe 20 f0 00 	cmpl   $0x0,0xf020fe80
f01040ff:	74 01                	je     f0104102 <trap+0x13>
		asm volatile("hlt");
f0104101:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104102:	e8 df 1a 00 00       	call   f0105be6 <cpunum>
f0104107:	6b d0 74             	imul   $0x74,%eax,%edx
f010410a:	81 c2 20 00 21 f0    	add    $0xf0210020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104110:	b8 01 00 00 00       	mov    $0x1,%eax
f0104115:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104119:	83 f8 02             	cmp    $0x2,%eax
f010411c:	75 10                	jne    f010412e <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010411e:	83 ec 0c             	sub    $0xc,%esp
f0104121:	68 c0 03 12 f0       	push   $0xf01203c0
f0104126:	e8 29 1d 00 00       	call   f0105e54 <spin_lock>
f010412b:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010412e:	9c                   	pushf  
f010412f:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104130:	f6 c4 02             	test   $0x2,%ah
f0104133:	74 19                	je     f010414e <trap+0x5f>
f0104135:	68 91 78 10 f0       	push   $0xf0107891
f010413a:	68 85 68 10 f0       	push   $0xf0106885
f010413f:	68 23 01 00 00       	push   $0x123
f0104144:	68 85 78 10 f0       	push   $0xf0107885
f0104149:	e8 f2 be ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010414e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104152:	83 e0 03             	and    $0x3,%eax
f0104155:	66 83 f8 03          	cmp    $0x3,%ax
f0104159:	0f 85 a0 00 00 00    	jne    f01041ff <trap+0x110>
f010415f:	83 ec 0c             	sub    $0xc,%esp
f0104162:	68 c0 03 12 f0       	push   $0xf01203c0
f0104167:	e8 e8 1c 00 00       	call   f0105e54 <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f010416c:	e8 75 1a 00 00       	call   f0105be6 <cpunum>
f0104171:	6b c0 74             	imul   $0x74,%eax,%eax
f0104174:	83 c4 10             	add    $0x10,%esp
f0104177:	83 b8 28 00 21 f0 00 	cmpl   $0x0,-0xfdeffd8(%eax)
f010417e:	75 19                	jne    f0104199 <trap+0xaa>
f0104180:	68 aa 78 10 f0       	push   $0xf01078aa
f0104185:	68 85 68 10 f0       	push   $0xf0106885
f010418a:	68 2d 01 00 00       	push   $0x12d
f010418f:	68 85 78 10 f0       	push   $0xf0107885
f0104194:	e8 a7 be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104199:	e8 48 1a 00 00       	call   f0105be6 <cpunum>
f010419e:	6b c0 74             	imul   $0x74,%eax,%eax
f01041a1:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01041a7:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01041ab:	75 2d                	jne    f01041da <trap+0xeb>
			env_free(curenv);
f01041ad:	e8 34 1a 00 00       	call   f0105be6 <cpunum>
f01041b2:	83 ec 0c             	sub    $0xc,%esp
f01041b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01041b8:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f01041be:	e8 02 f2 ff ff       	call   f01033c5 <env_free>
			curenv = NULL;
f01041c3:	e8 1e 1a 00 00       	call   f0105be6 <cpunum>
f01041c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01041cb:	c7 80 28 00 21 f0 00 	movl   $0x0,-0xfdeffd8(%eax)
f01041d2:	00 00 00 
			sched_yield();
f01041d5:	e8 98 02 00 00       	call   f0104472 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01041da:	e8 07 1a 00 00       	call   f0105be6 <cpunum>
f01041df:	6b c0 74             	imul   $0x74,%eax,%eax
f01041e2:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01041e8:	b9 11 00 00 00       	mov    $0x11,%ecx
f01041ed:	89 c7                	mov    %eax,%edi
f01041ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01041f1:	e8 f0 19 00 00       	call   f0105be6 <cpunum>
f01041f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01041f9:	8b b0 28 00 21 f0    	mov    -0xfdeffd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01041ff:	89 35 60 fa 20 f0    	mov    %esi,0xf020fa60
 
	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	struct PushRegs* r = &tf->tf_regs;

	switch(tf->tf_trapno) {
f0104205:	8b 46 28             	mov    0x28(%esi),%eax
f0104208:	83 f8 0e             	cmp    $0xe,%eax
f010420b:	74 18                	je     f0104225 <trap+0x136>
f010420d:	83 f8 0e             	cmp    $0xe,%eax
f0104210:	77 07                	ja     f0104219 <trap+0x12a>
f0104212:	83 f8 03             	cmp    $0x3,%eax
f0104215:	74 1f                	je     f0104236 <trap+0x147>
f0104217:	eb 56                	jmp    f010426f <trap+0x180>
f0104219:	83 f8 20             	cmp    $0x20,%eax
f010421c:	74 47                	je     f0104265 <trap+0x176>
f010421e:	83 f8 30             	cmp    $0x30,%eax
f0104221:	74 21                	je     f0104244 <trap+0x155>
f0104223:	eb 4a                	jmp    f010426f <trap+0x180>
		case (T_PGFLT):
			page_fault_handler(tf);
f0104225:	83 ec 0c             	sub    $0xc,%esp
f0104228:	56                   	push   %esi
f0104229:	e8 87 fd ff ff       	call   f0103fb5 <page_fault_handler>
f010422e:	83 c4 10             	add    $0x10,%esp
f0104231:	e9 89 00 00 00       	jmp    f01042bf <trap+0x1d0>
			break;
		case (T_BRKPT):
			monitor(tf);	// open a JOS monitor
f0104236:	83 ec 0c             	sub    $0xc,%esp
f0104239:	56                   	push   %esi
f010423a:	e8 68 c7 ff ff       	call   f01009a7 <monitor>
f010423f:	83 c4 10             	add    $0x10,%esp
f0104242:	eb 7b                	jmp    f01042bf <trap+0x1d0>
			break;
		case (T_SYSCALL):
			// call syscall in kern/syscall.c
			r->reg_eax = syscall(r->reg_eax, r->reg_edx, r->reg_ecx, r->reg_ebx, r->reg_edi, r->reg_esi);
f0104244:	83 ec 08             	sub    $0x8,%esp
f0104247:	ff 76 04             	pushl  0x4(%esi)
f010424a:	ff 36                	pushl  (%esi)
f010424c:	ff 76 10             	pushl  0x10(%esi)
f010424f:	ff 76 18             	pushl  0x18(%esi)
f0104252:	ff 76 14             	pushl  0x14(%esi)
f0104255:	ff 76 1c             	pushl  0x1c(%esi)
f0104258:	e8 9e 02 00 00       	call   f01044fb <syscall>
f010425d:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104260:	83 c4 20             	add    $0x20,%esp
f0104263:	eb 5a                	jmp    f01042bf <trap+0x1d0>
			break;
		case (IRQ_OFFSET + IRQ_TIMER):
			lapic_eoi();	// Acknowledge interrupt.
f0104265:	e8 c7 1a 00 00       	call   f0105d31 <lapic_eoi>
			sched_yield();
f010426a:	e8 03 02 00 00       	call   f0104472 <sched_yield>
			break;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			cprintf("[trapno: %x]\n", tf->tf_trapno);
f010426f:	83 ec 08             	sub    $0x8,%esp
f0104272:	50                   	push   %eax
f0104273:	68 b1 78 10 f0       	push   $0xf01078b1
f0104278:	e8 ef f5 ff ff       	call   f010386c <cprintf>
			print_trapframe(tf);
f010427d:	89 34 24             	mov    %esi,(%esp)
f0104280:	e8 a8 fb ff ff       	call   f0103e2d <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0104285:	83 c4 10             	add    $0x10,%esp
f0104288:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010428d:	75 17                	jne    f01042a6 <trap+0x1b7>
				panic("unhandled trap in kernel");
f010428f:	83 ec 04             	sub    $0x4,%esp
f0104292:	68 bf 78 10 f0       	push   $0xf01078bf
f0104297:	68 08 01 00 00       	push   $0x108
f010429c:	68 85 78 10 f0       	push   $0xf0107885
f01042a1:	e8 9a bd ff ff       	call   f0100040 <_panic>
			else {
				env_destroy(curenv);
f01042a6:	e8 3b 19 00 00       	call   f0105be6 <cpunum>
f01042ab:	83 ec 0c             	sub    $0xc,%esp
f01042ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b1:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f01042b7:	e8 af f2 ff ff       	call   f010356b <env_destroy>
f01042bc:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01042bf:	e8 22 19 00 00       	call   f0105be6 <cpunum>
f01042c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01042c7:	83 b8 28 00 21 f0 00 	cmpl   $0x0,-0xfdeffd8(%eax)
f01042ce:	74 2a                	je     f01042fa <trap+0x20b>
f01042d0:	e8 11 19 00 00       	call   f0105be6 <cpunum>
f01042d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01042d8:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01042de:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042e2:	75 16                	jne    f01042fa <trap+0x20b>
		env_run(curenv);
f01042e4:	e8 fd 18 00 00       	call   f0105be6 <cpunum>
f01042e9:	83 ec 0c             	sub    $0xc,%esp
f01042ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ef:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f01042f5:	e8 10 f3 ff ff       	call   f010360a <env_run>
	else
		sched_yield();
f01042fa:	e8 73 01 00 00       	call   f0104472 <sched_yield>
f01042ff:	90                   	nop

f0104300 <_T_DIVIDE_handler>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */


TRAPHANDLER_NOEC(_T_DIVIDE_handler, T_DIVIDE)
f0104300:	6a 00                	push   $0x0
f0104302:	6a 00                	push   $0x0
f0104304:	e9 83 00 00 00       	jmp    f010438c <_alltraps>
f0104309:	90                   	nop

f010430a <_T_DEBUG_handler>:
TRAPHANDLER_NOEC(_T_DEBUG_handler, T_DEBUG)
f010430a:	6a 00                	push   $0x0
f010430c:	6a 01                	push   $0x1
f010430e:	eb 7c                	jmp    f010438c <_alltraps>

f0104310 <_T_NMI_handler>:
TRAPHANDLER_NOEC(_T_NMI_handler, T_NMI)
f0104310:	6a 00                	push   $0x0
f0104312:	6a 02                	push   $0x2
f0104314:	eb 76                	jmp    f010438c <_alltraps>

f0104316 <_T_BRKPT_handler>:
TRAPHANDLER_NOEC(_T_BRKPT_handler, T_BRKPT)
f0104316:	6a 00                	push   $0x0
f0104318:	6a 03                	push   $0x3
f010431a:	eb 70                	jmp    f010438c <_alltraps>

f010431c <_T_OFLOW_handler>:
TRAPHANDLER_NOEC(_T_OFLOW_handler, T_OFLOW)
f010431c:	6a 00                	push   $0x0
f010431e:	6a 04                	push   $0x4
f0104320:	eb 6a                	jmp    f010438c <_alltraps>

f0104322 <_T_BOUND_handler>:
TRAPHANDLER_NOEC(_T_BOUND_handler, T_BOUND)
f0104322:	6a 00                	push   $0x0
f0104324:	6a 05                	push   $0x5
f0104326:	eb 64                	jmp    f010438c <_alltraps>

f0104328 <_T_ILLOP_handler>:
TRAPHANDLER_NOEC(_T_ILLOP_handler, T_ILLOP)
f0104328:	6a 00                	push   $0x0
f010432a:	6a 06                	push   $0x6
f010432c:	eb 5e                	jmp    f010438c <_alltraps>

f010432e <_T_DEVICE_handler>:
TRAPHANDLER_NOEC(_T_DEVICE_handler, T_DEVICE)
f010432e:	6a 00                	push   $0x0
f0104330:	6a 07                	push   $0x7
f0104332:	eb 58                	jmp    f010438c <_alltraps>

f0104334 <_T_DBLFLT_handler>:
TRAPHANDLER(_T_DBLFLT_handler, T_DBLFLT)
f0104334:	6a 08                	push   $0x8
f0104336:	eb 54                	jmp    f010438c <_alltraps>

f0104338 <_T_TSS_handler>:
TRAPHANDLER(_T_TSS_handler, T_TSS)
f0104338:	6a 0a                	push   $0xa
f010433a:	eb 50                	jmp    f010438c <_alltraps>

f010433c <_T_SEGNP_handler>:
TRAPHANDLER(_T_SEGNP_handler, T_SEGNP)
f010433c:	6a 0b                	push   $0xb
f010433e:	eb 4c                	jmp    f010438c <_alltraps>

f0104340 <_T_STACK_handler>:
TRAPHANDLER(_T_STACK_handler, T_STACK)
f0104340:	6a 0c                	push   $0xc
f0104342:	eb 48                	jmp    f010438c <_alltraps>

f0104344 <_T_GPFLT_handler>:
TRAPHANDLER(_T_GPFLT_handler, T_GPFLT)
f0104344:	6a 0d                	push   $0xd
f0104346:	eb 44                	jmp    f010438c <_alltraps>

f0104348 <_T_PGFLT_handler>:
TRAPHANDLER(_T_PGFLT_handler, T_PGFLT)
f0104348:	6a 0e                	push   $0xe
f010434a:	eb 40                	jmp    f010438c <_alltraps>

f010434c <_T_FPERR_handler>:
TRAPHANDLER_NOEC(_T_FPERR_handler, T_FPERR)
f010434c:	6a 00                	push   $0x0
f010434e:	6a 10                	push   $0x10
f0104350:	eb 3a                	jmp    f010438c <_alltraps>

f0104352 <_T_ALIGN_handler>:
TRAPHANDLER(_T_ALIGN_handler, T_ALIGN)
f0104352:	6a 11                	push   $0x11
f0104354:	eb 36                	jmp    f010438c <_alltraps>

f0104356 <_T_MCHK_handler>:
TRAPHANDLER_NOEC(_T_MCHK_handler, T_MCHK)
f0104356:	6a 00                	push   $0x0
f0104358:	6a 12                	push   $0x12
f010435a:	eb 30                	jmp    f010438c <_alltraps>

f010435c <_T_SIMDERR_handler>:
TRAPHANDLER_NOEC(_T_SIMDERR_handler, T_SIMDERR)
f010435c:	6a 00                	push   $0x0
f010435e:	6a 13                	push   $0x13
f0104360:	eb 2a                	jmp    f010438c <_alltraps>

f0104362 <_T_SYSCALL_handler>:
TRAPHANDLER_NOEC(_T_SYSCALL_handler, T_SYSCALL)
f0104362:	6a 00                	push   $0x0
f0104364:	6a 30                	push   $0x30
f0104366:	eb 24                	jmp    f010438c <_alltraps>

f0104368 <_IRQ_TIMER_handler>:

TRAPHANDLER_NOEC(_IRQ_TIMER_handler, IRQ_TIMER + IRQ_OFFSET)
f0104368:	6a 00                	push   $0x0
f010436a:	6a 20                	push   $0x20
f010436c:	eb 1e                	jmp    f010438c <_alltraps>

f010436e <_IRQ_KBD_handler>:
TRAPHANDLER_NOEC(_IRQ_KBD_handler, IRQ_KBD + IRQ_OFFSET)
f010436e:	6a 00                	push   $0x0
f0104370:	6a 21                	push   $0x21
f0104372:	eb 18                	jmp    f010438c <_alltraps>

f0104374 <_IRQ_SERIAL_handler>:
TRAPHANDLER_NOEC(_IRQ_SERIAL_handler, IRQ_SERIAL + IRQ_OFFSET)
f0104374:	6a 00                	push   $0x0
f0104376:	6a 24                	push   $0x24
f0104378:	eb 12                	jmp    f010438c <_alltraps>

f010437a <_IRQ_SPURIOUS_handler>:
TRAPHANDLER_NOEC(_IRQ_SPURIOUS_handler, IRQ_SPURIOUS + IRQ_OFFSET)
f010437a:	6a 00                	push   $0x0
f010437c:	6a 27                	push   $0x27
f010437e:	eb 0c                	jmp    f010438c <_alltraps>

f0104380 <_IRQ_IDE_handler>:
TRAPHANDLER_NOEC(_IRQ_IDE_handler, IRQ_IDE + IRQ_OFFSET)
f0104380:	6a 00                	push   $0x0
f0104382:	6a 2e                	push   $0x2e
f0104384:	eb 06                	jmp    f010438c <_alltraps>

f0104386 <_IRQ_ERROR_handler>:
TRAPHANDLER_NOEC(_IRQ_ERROR_handler, IRQ_ERROR + IRQ_OFFSET)
f0104386:	6a 00                	push   $0x0
f0104388:	6a 33                	push   $0x33
f010438a:	eb 00                	jmp    f010438c <_alltraps>

f010438c <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
f010438c:	1e                   	push   %ds
	pushl %es
f010438d:	06                   	push   %es
	pushal	/* push all general registers */
f010438e:	60                   	pusha  

	movl $GD_KD, %eax
f010438f:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f0104394:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f0104396:	8e c0                	mov    %eax,%es

	push %esp
f0104398:	54                   	push   %esp
f0104399:	e8 51 fd ff ff       	call   f01040ef <trap>

f010439e <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010439e:	55                   	push   %ebp
f010439f:	89 e5                	mov    %esp,%ebp
f01043a1:	83 ec 08             	sub    $0x8,%esp
f01043a4:	a1 48 f2 20 f0       	mov    0xf020f248,%eax
f01043a9:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01043ac:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01043b1:	8b 02                	mov    (%edx),%eax
f01043b3:	83 e8 01             	sub    $0x1,%eax
f01043b6:	83 f8 02             	cmp    $0x2,%eax
f01043b9:	76 10                	jbe    f01043cb <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01043bb:	83 c1 01             	add    $0x1,%ecx
f01043be:	83 c2 7c             	add    $0x7c,%edx
f01043c1:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01043c7:	75 e8                	jne    f01043b1 <sched_halt+0x13>
f01043c9:	eb 08                	jmp    f01043d3 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01043cb:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01043d1:	75 1f                	jne    f01043f2 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01043d3:	83 ec 0c             	sub    $0xc,%esp
f01043d6:	68 90 7a 10 f0       	push   $0xf0107a90
f01043db:	e8 8c f4 ff ff       	call   f010386c <cprintf>
f01043e0:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01043e3:	83 ec 0c             	sub    $0xc,%esp
f01043e6:	6a 00                	push   $0x0
f01043e8:	e8 ba c5 ff ff       	call   f01009a7 <monitor>
f01043ed:	83 c4 10             	add    $0x10,%esp
f01043f0:	eb f1                	jmp    f01043e3 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01043f2:	e8 ef 17 00 00       	call   f0105be6 <cpunum>
f01043f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01043fa:	c7 80 28 00 21 f0 00 	movl   $0x0,-0xfdeffd8(%eax)
f0104401:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104404:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104409:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010440e:	77 12                	ja     f0104422 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104410:	50                   	push   %eax
f0104411:	68 c8 62 10 f0       	push   $0xf01062c8
f0104416:	6a 52                	push   $0x52
f0104418:	68 b9 7a 10 f0       	push   $0xf0107ab9
f010441d:	e8 1e bc ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104422:	05 00 00 00 10       	add    $0x10000000,%eax
f0104427:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010442a:	e8 b7 17 00 00       	call   f0105be6 <cpunum>
f010442f:	6b d0 74             	imul   $0x74,%eax,%edx
f0104432:	81 c2 20 00 21 f0    	add    $0xf0210020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104438:	b8 02 00 00 00       	mov    $0x2,%eax
f010443d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104441:	83 ec 0c             	sub    $0xc,%esp
f0104444:	68 c0 03 12 f0       	push   $0xf01203c0
f0104449:	e8 a3 1a 00 00       	call   f0105ef1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010444e:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104450:	e8 91 17 00 00       	call   f0105be6 <cpunum>
f0104455:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104458:	8b 80 30 00 21 f0    	mov    -0xfdeffd0(%eax),%eax
f010445e:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104463:	89 c4                	mov    %eax,%esp
f0104465:	6a 00                	push   $0x0
f0104467:	6a 00                	push   $0x0
f0104469:	fb                   	sti    
f010446a:	f4                   	hlt    
f010446b:	eb fd                	jmp    f010446a <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010446d:	83 c4 10             	add    $0x10,%esp
f0104470:	c9                   	leave  
f0104471:	c3                   	ret    

f0104472 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104472:	55                   	push   %ebp
f0104473:	89 e5                	mov    %esp,%ebp
f0104475:	56                   	push   %esi
f0104476:	53                   	push   %ebx
	// below to halt the cpu.

	// LAB 4: Your code here.
	// cprintf("[yield]\n");

	struct Env *now = thiscpu->cpu_env;
f0104477:	e8 6a 17 00 00       	call   f0105be6 <cpunum>
f010447c:	6b c0 74             	imul   $0x74,%eax,%eax
f010447f:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
    int32_t startid = (now) ? ENVX(now->env_id): 0;
f0104485:	85 c0                	test   %eax,%eax
f0104487:	74 0b                	je     f0104494 <sched_yield+0x22>
f0104489:	8b 50 48             	mov    0x48(%eax),%edx
f010448c:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104492:	eb 05                	jmp    f0104499 <sched_yield+0x27>
f0104494:	ba 00 00 00 00       	mov    $0x0,%edx
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
        nextid = (startid+i)%NENV;
        if(envs[nextid].env_status == ENV_RUNNABLE) {
f0104499:	8b 0d 48 f2 20 f0    	mov    0xf020f248,%ecx
f010449f:	89 d6                	mov    %edx,%esi
f01044a1:	8d 9a 00 04 00 00    	lea    0x400(%edx),%ebx
f01044a7:	89 d0                	mov    %edx,%eax
f01044a9:	25 ff 03 00 00       	and    $0x3ff,%eax
f01044ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01044b1:	01 c8                	add    %ecx,%eax
f01044b3:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01044b7:	75 09                	jne    f01044c2 <sched_yield+0x50>
                env_run(&envs[nextid]);
f01044b9:	83 ec 0c             	sub    $0xc,%esp
f01044bc:	50                   	push   %eax
f01044bd:	e8 48 f1 ff ff       	call   f010360a <env_run>
f01044c2:	83 c2 01             	add    $0x1,%edx
	struct Env *now = thiscpu->cpu_env;
    int32_t startid = (now) ? ENVX(now->env_id): 0;
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
f01044c5:	39 da                	cmp    %ebx,%edx
f01044c7:	75 de                	jne    f01044a7 <sched_yield+0x35>
                env_run(&envs[nextid]);
                return;
            }
    }
    
    if(envs[startid].env_status == ENV_RUNNING && envs[startid].env_cpunum == cpunum()) {
f01044c9:	6b f6 7c             	imul   $0x7c,%esi,%esi
f01044cc:	01 f1                	add    %esi,%ecx
f01044ce:	83 79 54 03          	cmpl   $0x3,0x54(%ecx)
f01044d2:	75 1b                	jne    f01044ef <sched_yield+0x7d>
f01044d4:	8b 59 5c             	mov    0x5c(%ecx),%ebx
f01044d7:	e8 0a 17 00 00       	call   f0105be6 <cpunum>
f01044dc:	39 c3                	cmp    %eax,%ebx
f01044de:	75 0f                	jne    f01044ef <sched_yield+0x7d>
        env_run(&envs[startid]);
f01044e0:	83 ec 0c             	sub    $0xc,%esp
f01044e3:	03 35 48 f2 20 f0    	add    0xf020f248,%esi
f01044e9:	56                   	push   %esi
f01044ea:	e8 1b f1 ff ff       	call   f010360a <env_run>
    }

	// cprintf("[halt]\n");

	// sched_halt never returns
	sched_halt();
f01044ef:	e8 aa fe ff ff       	call   f010439e <sched_halt>
}
f01044f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01044f7:	5b                   	pop    %ebx
f01044f8:	5e                   	pop    %esi
f01044f9:	5d                   	pop    %ebp
f01044fa:	c3                   	ret    

f01044fb <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01044fb:	55                   	push   %ebp
f01044fc:	89 e5                	mov    %esp,%ebp
f01044fe:	57                   	push   %edi
f01044ff:	56                   	push   %esi
f0104500:	53                   	push   %ebx
f0104501:	83 ec 1c             	sub    $0x1c,%esp
f0104504:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f0104507:	83 f8 0d             	cmp    $0xd,%eax
f010450a:	0f 87 18 05 00 00    	ja     f0104a28 <syscall+0x52d>
f0104510:	ff 24 85 cc 7a 10 f0 	jmp    *-0xfef8534(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);		// just check if PTE_U is set
f0104517:	e8 ca 16 00 00       	call   f0105be6 <cpunum>
f010451c:	6a 00                	push   $0x0
f010451e:	ff 75 10             	pushl  0x10(%ebp)
f0104521:	ff 75 0c             	pushl  0xc(%ebp)
f0104524:	6b c0 74             	imul   $0x74,%eax,%eax
f0104527:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f010452d:	e8 22 ea ff ff       	call   f0102f54 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104532:	83 c4 0c             	add    $0xc,%esp
f0104535:	ff 75 0c             	pushl  0xc(%ebp)
f0104538:	ff 75 10             	pushl  0x10(%ebp)
f010453b:	68 c6 7a 10 f0       	push   $0xf0107ac6
f0104540:	e8 27 f3 ff ff       	call   f010386c <cprintf>
f0104545:	83 c4 10             	add    $0x10,%esp
	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
f0104548:	bb 00 00 00 00       	mov    $0x0,%ebx
f010454d:	e9 e2 04 00 00       	jmp    f0104a34 <syscall+0x539>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104552:	e8 9b c0 ff ff       	call   f01005f2 <cons_getc>
f0104557:	89 c3                	mov    %eax,%ebx
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f0104559:	e9 d6 04 00 00       	jmp    f0104a34 <syscall+0x539>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010455e:	e8 83 16 00 00       	call   f0105be6 <cpunum>
f0104563:	6b c0 74             	imul   $0x74,%eax,%eax
f0104566:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f010456c:	8b 58 48             	mov    0x48(%eax),%ebx
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f010456f:	e9 c0 04 00 00       	jmp    f0104a34 <syscall+0x539>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104574:	83 ec 04             	sub    $0x4,%esp
f0104577:	6a 01                	push   $0x1
f0104579:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010457c:	50                   	push   %eax
f010457d:	ff 75 0c             	pushl  0xc(%ebp)
f0104580:	e8 9d ea ff ff       	call   f0103022 <envid2env>
f0104585:	83 c4 10             	add    $0x10,%esp
		return r;
f0104588:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010458a:	85 c0                	test   %eax,%eax
f010458c:	0f 88 a2 04 00 00    	js     f0104a34 <syscall+0x539>
		return r;
	env_destroy(e);
f0104592:	83 ec 0c             	sub    $0xc,%esp
f0104595:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104598:	e8 ce ef ff ff       	call   f010356b <env_destroy>
f010459d:	83 c4 10             	add    $0x10,%esp
	return 0;
f01045a0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01045a5:	e9 8a 04 00 00       	jmp    f0104a34 <syscall+0x539>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01045aa:	e8 c3 fe ff ff       	call   f0104472 <sched_yield>
	// LAB 4: Your code here.
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
f01045af:	e8 32 16 00 00       	call   f0105be6 <cpunum>
f01045b4:	83 ec 08             	sub    $0x8,%esp
f01045b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01045ba:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01045c0:	ff 70 48             	pushl  0x48(%eax)
f01045c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045c6:	50                   	push   %eax
f01045c7:	e8 61 eb ff ff       	call   f010312d <env_alloc>
	if (err < 0)
f01045cc:	83 c4 10             	add    $0x10,%esp
		return err;
f01045cf:	89 c3                	mov    %eax,%ebx
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
	if (err < 0)
f01045d1:	85 c0                	test   %eax,%eax
f01045d3:	0f 88 5b 04 00 00    	js     f0104a34 <syscall+0x539>
		return err;

	// memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
	newenv->env_tf = curenv->env_tf;
f01045d9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01045dc:	e8 05 16 00 00       	call   f0105be6 <cpunum>
f01045e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01045e4:	8b b0 28 00 21 f0    	mov    -0xfdeffd8(%eax),%esi
f01045ea:	b9 11 00 00 00       	mov    $0x11,%ecx
f01045ef:	89 df                	mov    %ebx,%edi
f01045f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_status = ENV_NOT_RUNNABLE;
f01045f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045f6:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	// tweak newenv, to make it appear to return 0
	newenv->env_tf.tf_regs.reg_eax = 0;
f01045fd:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return newenv->env_id;
f0104604:	8b 58 48             	mov    0x48(%eax),%ebx
f0104607:	e9 28 04 00 00       	jmp    f0104a34 <syscall+0x539>

	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f010460c:	83 ec 04             	sub    $0x4,%esp
f010460f:	6a 01                	push   $0x1
f0104611:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104614:	50                   	push   %eax
f0104615:	ff 75 0c             	pushl  0xc(%ebp)
f0104618:	e8 05 ea ff ff       	call   f0103022 <envid2env>
	if (err < 0)
f010461d:	83 c4 10             	add    $0x10,%esp
f0104620:	85 c0                	test   %eax,%eax
f0104622:	78 20                	js     f0104644 <syscall+0x149>
		return err;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104624:	8b 45 10             	mov    0x10(%ebp),%eax
f0104627:	83 e8 02             	sub    $0x2,%eax
f010462a:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f010462f:	75 1a                	jne    f010464b <syscall+0x150>
		return -E_INVAL;

	env_store->env_status = status;
f0104631:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104634:	8b 55 10             	mov    0x10(%ebp),%edx
f0104637:	89 50 54             	mov    %edx,0x54(%eax)

	return 0;
f010463a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010463f:	e9 f0 03 00 00       	jmp    f0104a34 <syscall+0x539>
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f0104644:	89 c3                	mov    %eax,%ebx
f0104646:	e9 e9 03 00 00       	jmp    f0104a34 <syscall+0x539>

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f010464b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
f0104650:	e9 df 03 00 00       	jmp    f0104a34 <syscall+0x539>

	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104655:	83 ec 04             	sub    $0x4,%esp
f0104658:	6a 01                	push   $0x1
f010465a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010465d:	50                   	push   %eax
f010465e:	ff 75 0c             	pushl  0xc(%ebp)
f0104661:	e8 bc e9 ff ff       	call   f0103022 <envid2env>
	if (err < 0)
f0104666:	83 c4 10             	add    $0x10,%esp
f0104669:	85 c0                	test   %eax,%eax
f010466b:	78 6b                	js     f01046d8 <syscall+0x1dd>
		return err;	// E_BAD_ENV

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f010466d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104670:	0d 02 0e 00 00       	or     $0xe02,%eax
f0104675:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f010467a:	75 63                	jne    f01046df <syscall+0x1e4>
f010467c:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104683:	77 5a                	ja     f01046df <syscall+0x1e4>
f0104685:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010468c:	75 5b                	jne    f01046e9 <syscall+0x1ee>
		return -E_INVAL;
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
f010468e:	83 ec 0c             	sub    $0xc,%esp
f0104691:	6a 01                	push   $0x1
f0104693:	e8 00 ca ff ff       	call   f0101098 <page_alloc>
f0104698:	89 c6                	mov    %eax,%esi
	if (pp == NULL)
f010469a:	83 c4 10             	add    $0x10,%esp
f010469d:	85 c0                	test   %eax,%eax
f010469f:	74 52                	je     f01046f3 <syscall+0x1f8>
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
f01046a1:	ff 75 14             	pushl  0x14(%ebp)
f01046a4:	ff 75 10             	pushl  0x10(%ebp)
f01046a7:	50                   	push   %eax
f01046a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046ab:	ff 70 60             	pushl  0x60(%eax)
f01046ae:	e8 13 cd ff ff       	call   f01013c6 <page_insert>
f01046b3:	89 c7                	mov    %eax,%edi
	if (err < 0) {
f01046b5:	83 c4 10             	add    $0x10,%esp
		page_free(pp);
		return err; // E_NO_MEM
	}

	return 0;
f01046b8:	bb 00 00 00 00       	mov    $0x0,%ebx
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
	if (err < 0) {
f01046bd:	85 c0                	test   %eax,%eax
f01046bf:	0f 89 6f 03 00 00    	jns    f0104a34 <syscall+0x539>
		page_free(pp);
f01046c5:	83 ec 0c             	sub    $0xc,%esp
f01046c8:	56                   	push   %esi
f01046c9:	e8 3b ca ff ff       	call   f0101109 <page_free>
f01046ce:	83 c4 10             	add    $0x10,%esp
		return err; // E_NO_MEM
f01046d1:	89 fb                	mov    %edi,%ebx
f01046d3:	e9 5c 03 00 00       	jmp    f0104a34 <syscall+0x539>
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;	// E_BAD_ENV
f01046d8:	89 c3                	mov    %eax,%ebx
f01046da:	e9 55 03 00 00       	jmp    f0104a34 <syscall+0x539>

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f01046df:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046e4:	e9 4b 03 00 00       	jmp    f0104a34 <syscall+0x539>
f01046e9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046ee:	e9 41 03 00 00       	jmp    f0104a34 <syscall+0x539>
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
f01046f3:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01046f8:	e9 37 03 00 00       	jmp    f0104a34 <syscall+0x539>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
f01046fd:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104704:	0f 87 c2 00 00 00    	ja     f01047cc <syscall+0x2d1>
f010470a:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104711:	0f 85 bf 00 00 00    	jne    f01047d6 <syscall+0x2db>
f0104717:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010471e:	0f 87 b2 00 00 00    	ja     f01047d6 <syscall+0x2db>
f0104724:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f010472b:	0f 85 af 00 00 00    	jne    f01047e0 <syscall+0x2e5>
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
f0104731:	83 ec 04             	sub    $0x4,%esp
f0104734:	6a 01                	push   $0x1
f0104736:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104739:	50                   	push   %eax
f010473a:	ff 75 0c             	pushl  0xc(%ebp)
f010473d:	e8 e0 e8 ff ff       	call   f0103022 <envid2env>
	if(err < 0)
f0104742:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f0104745:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
f0104747:	85 c0                	test   %eax,%eax
f0104749:	0f 88 e5 02 00 00    	js     f0104a34 <syscall+0x539>
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
f010474f:	83 ec 04             	sub    $0x4,%esp
f0104752:	6a 01                	push   $0x1
f0104754:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104757:	50                   	push   %eax
f0104758:	ff 75 14             	pushl  0x14(%ebp)
f010475b:	e8 c2 e8 ff ff       	call   f0103022 <envid2env>
	if(err < 0)
f0104760:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f0104763:	89 c3                	mov    %eax,%ebx
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
	if(err < 0)
f0104765:	85 c0                	test   %eax,%eax
f0104767:	0f 88 c7 02 00 00    	js     f0104a34 <syscall+0x539>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
f010476d:	83 ec 04             	sub    $0x4,%esp
f0104770:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104773:	50                   	push   %eax
f0104774:	ff 75 10             	pushl  0x10(%ebp)
f0104777:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010477a:	ff 70 60             	pushl  0x60(%eax)
f010477d:	e8 5c cb ff ff       	call   f01012de <page_lookup>
	if (pp == NULL) 
f0104782:	83 c4 10             	add    $0x10,%esp
f0104785:	85 c0                	test   %eax,%eax
f0104787:	74 61                	je     f01047ea <syscall+0x2ef>
		return -E_INVAL;	// not mapped
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
f0104789:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010478c:	f6 02 02             	testb  $0x2,(%edx)
f010478f:	75 06                	jne    f0104797 <syscall+0x29c>
f0104791:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104795:	75 5d                	jne    f01047f4 <syscall+0x2f9>
		return -E_INVAL;	// read-only page

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
f0104797:	8b 55 1c             	mov    0x1c(%ebp),%edx
f010479a:	81 ca 02 0e 00 00    	or     $0xe02,%edx
f01047a0:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f01047a6:	75 56                	jne    f01047fe <syscall+0x303>
		return -E_INVAL;

	err = page_insert(dstenv->env_pgdir, pp, dstva, perm);
f01047a8:	ff 75 1c             	pushl  0x1c(%ebp)
f01047ab:	ff 75 18             	pushl  0x18(%ebp)
f01047ae:	50                   	push   %eax
f01047af:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01047b2:	ff 70 60             	pushl  0x60(%eax)
f01047b5:	e8 0c cc ff ff       	call   f01013c6 <page_insert>
f01047ba:	83 c4 10             	add    $0x10,%esp
f01047bd:	85 c0                	test   %eax,%eax
f01047bf:	bb 00 00 00 00       	mov    $0x0,%ebx
f01047c4:	0f 4e d8             	cmovle %eax,%ebx
f01047c7:	e9 68 02 00 00       	jmp    f0104a34 <syscall+0x539>

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
f01047cc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047d1:	e9 5e 02 00 00       	jmp    f0104a34 <syscall+0x539>
f01047d6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047db:	e9 54 02 00 00       	jmp    f0104a34 <syscall+0x539>
f01047e0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047e5:	e9 4a 02 00 00       	jmp    f0104a34 <syscall+0x539>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (pp == NULL) 
		return -E_INVAL;	// not mapped
f01047ea:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047ef:	e9 40 02 00 00       	jmp    f0104a34 <syscall+0x539>
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
		return -E_INVAL;	// read-only page
f01047f4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047f9:	e9 36 02 00 00       	jmp    f0104a34 <syscall+0x539>

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;
f01047fe:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
f0104803:	e9 2c 02 00 00       	jmp    f0104a34 <syscall+0x539>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f0104808:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010480f:	77 45                	ja     f0104856 <syscall+0x35b>
f0104811:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104818:	75 46                	jne    f0104860 <syscall+0x365>
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f010481a:	83 ec 04             	sub    $0x4,%esp
f010481d:	6a 01                	push   $0x1
f010481f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104822:	50                   	push   %eax
f0104823:	ff 75 0c             	pushl  0xc(%ebp)
f0104826:	e8 f7 e7 ff ff       	call   f0103022 <envid2env>
	if (err < 0)
f010482b:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f010482e:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
f0104830:	85 c0                	test   %eax,%eax
f0104832:	0f 88 fc 01 00 00    	js     f0104a34 <syscall+0x539>
		return err;	// E_BAD_ENV

	page_remove(env_store->env_pgdir, va);
f0104838:	83 ec 08             	sub    $0x8,%esp
f010483b:	ff 75 10             	pushl  0x10(%ebp)
f010483e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104841:	ff 70 60             	pushl  0x60(%eax)
f0104844:	e8 30 cb ff ff       	call   f0101379 <page_remove>
f0104849:	83 c4 10             	add    $0x10,%esp

	return 0;
f010484c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104851:	e9 de 01 00 00       	jmp    f0104a34 <syscall+0x539>

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f0104856:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010485b:	e9 d4 01 00 00       	jmp    f0104a34 <syscall+0x539>
f0104860:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104865:	e9 ca 01 00 00       	jmp    f0104a34 <syscall+0x539>
{
	// LAB 4: Your code here.
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f010486a:	83 ec 04             	sub    $0x4,%esp
f010486d:	6a 01                	push   $0x1
f010486f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104872:	50                   	push   %eax
f0104873:	ff 75 0c             	pushl  0xc(%ebp)
f0104876:	e8 a7 e7 ff ff       	call   f0103022 <envid2env>
	if (err < 0)
f010487b:	83 c4 10             	add    $0x10,%esp
f010487e:	85 c0                	test   %eax,%eax
f0104880:	78 13                	js     f0104895 <syscall+0x39a>
		return err;

	env_store->env_pgfault_upcall = func;
f0104882:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104885:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104888:	89 48 64             	mov    %ecx,0x64(%eax)

	return 0;
f010488b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104890:	e9 9f 01 00 00       	jmp    f0104a34 <syscall+0x539>
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f0104895:	89 c3                	mov    %eax,%ebx
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104897:	e9 98 01 00 00       	jmp    f0104a34 <syscall+0x539>
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// panic("sys_ipc_recv not implemented");

	if ((uint32_t)dstva < UTOP) {
f010489c:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01048a3:	77 21                	ja     f01048c6 <syscall+0x3cb>
		if ((uint32_t)dstva % PGSIZE != 0)
f01048a5:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01048ac:	0f 85 7d 01 00 00    	jne    f0104a2f <syscall+0x534>
			return -E_INVAL;
		curenv->env_ipc_dstva = dstva;
f01048b2:	e8 2f 13 00 00       	call   f0105be6 <cpunum>
f01048b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01048ba:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01048c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01048c3:	89 48 6c             	mov    %ecx,0x6c(%eax)
	}

	// set recving flags
	curenv->env_ipc_recving = true;
f01048c6:	e8 1b 13 00 00       	call   f0105be6 <cpunum>
f01048cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01048ce:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01048d4:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f01048d8:	e8 09 13 00 00       	call   f0105be6 <cpunum>
f01048dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01048e0:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01048e6:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)

	// mark yourself not runnable, and then give up the CPU.
	curenv->env_status = ENV_NOT_RUNNABLE;
f01048ed:	e8 f4 12 00 00       	call   f0105be6 <cpunum>
f01048f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01048f5:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01048fb:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0104902:	e8 6b fb ff ff       	call   f0104472 <sched_yield>
{
	// LAB 4: Your code here.
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
f0104907:	83 ec 04             	sub    $0x4,%esp
f010490a:	6a 00                	push   $0x0
f010490c:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010490f:	50                   	push   %eax
f0104910:	ff 75 0c             	pushl  0xc(%ebp)
f0104913:	e8 0a e7 ff ff       	call   f0103022 <envid2env>
	if(err < 0)
f0104918:	83 c4 10             	add    $0x10,%esp
f010491b:	85 c0                	test   %eax,%eax
f010491d:	0f 88 f3 00 00 00    	js     f0104a16 <syscall+0x51b>
		return err;	// E_BAD_ENV
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
f0104923:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104926:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f010492a:	0f 84 ea 00 00 00    	je     f0104a1a <syscall+0x51f>
f0104930:	8b 58 74             	mov    0x74(%eax),%ebx
f0104933:	85 db                	test   %ebx,%ebx
f0104935:	0f 85 e6 00 00 00    	jne    f0104a21 <syscall+0x526>

	// first check if the recver is willing to recv a page
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
f010493b:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f010493f:	0f 84 9d 00 00 00    	je     f01049e2 <syscall+0x4e7>
f0104945:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f010494c:	0f 87 90 00 00 00    	ja     f01049e2 <syscall+0x4e7>
			if ((uint32_t)srcva % PGSIZE != 0)
f0104952:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104959:	75 64                	jne    f01049bf <syscall+0x4c4>
				return -E_INVAL;
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
f010495b:	8b 45 18             	mov    0x18(%ebp),%eax
f010495e:	83 e0 05             	and    $0x5,%eax
f0104961:	83 f8 05             	cmp    $0x5,%eax
f0104964:	75 60                	jne    f01049c6 <syscall+0x4cb>
            	return -E_INVAL;

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104966:	e8 7b 12 00 00       	call   f0105be6 <cpunum>
f010496b:	83 ec 04             	sub    $0x4,%esp
f010496e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104971:	52                   	push   %edx
f0104972:	ff 75 14             	pushl  0x14(%ebp)
f0104975:	6b c0 74             	imul   $0x74,%eax,%eax
f0104978:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f010497e:	ff 70 60             	pushl  0x60(%eax)
f0104981:	e8 58 c9 ff ff       	call   f01012de <page_lookup>
			if (!pp) 
f0104986:	83 c4 10             	add    $0x10,%esp
f0104989:	85 c0                	test   %eax,%eax
f010498b:	74 40                	je     f01049cd <syscall+0x4d2>
				return -E_INVAL;  
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
f010498d:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104991:	74 08                	je     f010499b <syscall+0x4a0>
f0104993:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104996:	f6 02 02             	testb  $0x2,(%edx)
f0104999:	74 39                	je     f01049d4 <syscall+0x4d9>
				return -E_INVAL;

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
f010499b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010499e:	ff 75 18             	pushl  0x18(%ebp)
f01049a1:	ff 72 6c             	pushl  0x6c(%edx)
f01049a4:	50                   	push   %eax
f01049a5:	ff 72 60             	pushl  0x60(%edx)
f01049a8:	e8 19 ca ff ff       	call   f01013c6 <page_insert>
f01049ad:	83 c4 10             	add    $0x10,%esp
f01049b0:	85 c0                	test   %eax,%eax
f01049b2:	78 27                	js     f01049db <syscall+0x4e0>
				return -E_NO_MEM;
			
			env->env_ipc_perm = perm;
f01049b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049b7:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01049ba:	89 48 78             	mov    %ecx,0x78(%eax)
f01049bd:	eb 23                	jmp    f01049e2 <syscall+0x4e7>
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
			if ((uint32_t)srcva % PGSIZE != 0)
				return -E_INVAL;
f01049bf:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049c4:	eb 6e                	jmp    f0104a34 <syscall+0x539>
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
            	return -E_INVAL;
f01049c6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049cb:	eb 67                	jmp    f0104a34 <syscall+0x539>

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
			if (!pp) 
				return -E_INVAL;  
f01049cd:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049d2:	eb 60                	jmp    f0104a34 <syscall+0x539>
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
				return -E_INVAL;
f01049d4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049d9:	eb 59                	jmp    f0104a34 <syscall+0x539>

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
				return -E_NO_MEM;
f01049db:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01049e0:	eb 52                	jmp    f0104a34 <syscall+0x539>
			env->env_ipc_perm = perm;
		}

	}

	env->env_ipc_from = curenv->env_id;
f01049e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01049e5:	e8 fc 11 00 00       	call   f0105be6 <cpunum>
f01049ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01049ed:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01049f3:	8b 40 48             	mov    0x48(%eax),%eax
f01049f6:	89 46 74             	mov    %eax,0x74(%esi)
	env->env_ipc_recving = false;
f01049f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049fc:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_ipc_value = value;
f0104a00:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104a03:	89 78 70             	mov    %edi,0x70(%eax)
	env->env_status = ENV_RUNNABLE;
f0104a06:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	// make the recver return 0
	env->env_tf.tf_regs.reg_eax = 0;
f0104a0d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104a14:	eb 1e                	jmp    f0104a34 <syscall+0x539>
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
	if(err < 0)
		return err;	// E_BAD_ENV
f0104a16:	89 c3                	mov    %eax,%ebx
f0104a18:	eb 1a                	jmp    f0104a34 <syscall+0x539>
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
		return -E_IPC_NOT_RECV;
f0104a1a:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104a1f:	eb 13                	jmp    f0104a34 <syscall+0x539>
f0104a21:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f0104a26:	eb 0c                	jmp    f0104a34 <syscall+0x539>
		default:
			return -E_INVAL;
f0104a28:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a2d:	eb 05                	jmp    f0104a34 <syscall+0x539>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f0104a2f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
		default:
			return -E_INVAL;
	}
}
f0104a34:	89 d8                	mov    %ebx,%eax
f0104a36:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104a39:	5b                   	pop    %ebx
f0104a3a:	5e                   	pop    %esi
f0104a3b:	5f                   	pop    %edi
f0104a3c:	5d                   	pop    %ebp
f0104a3d:	c3                   	ret    

f0104a3e <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104a3e:	55                   	push   %ebp
f0104a3f:	89 e5                	mov    %esp,%ebp
f0104a41:	57                   	push   %edi
f0104a42:	56                   	push   %esi
f0104a43:	53                   	push   %ebx
f0104a44:	83 ec 14             	sub    $0x14,%esp
f0104a47:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104a4a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104a4d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104a50:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104a53:	8b 1a                	mov    (%edx),%ebx
f0104a55:	8b 01                	mov    (%ecx),%eax
f0104a57:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104a5a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104a61:	eb 7f                	jmp    f0104ae2 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104a66:	01 d8                	add    %ebx,%eax
f0104a68:	89 c6                	mov    %eax,%esi
f0104a6a:	c1 ee 1f             	shr    $0x1f,%esi
f0104a6d:	01 c6                	add    %eax,%esi
f0104a6f:	d1 fe                	sar    %esi
f0104a71:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104a74:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104a77:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104a7a:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104a7c:	eb 03                	jmp    f0104a81 <stab_binsearch+0x43>
			m--;
f0104a7e:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104a81:	39 c3                	cmp    %eax,%ebx
f0104a83:	7f 0d                	jg     f0104a92 <stab_binsearch+0x54>
f0104a85:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104a89:	83 ea 0c             	sub    $0xc,%edx
f0104a8c:	39 f9                	cmp    %edi,%ecx
f0104a8e:	75 ee                	jne    f0104a7e <stab_binsearch+0x40>
f0104a90:	eb 05                	jmp    f0104a97 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104a92:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104a95:	eb 4b                	jmp    f0104ae2 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104a97:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104a9a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104a9d:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104aa1:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104aa4:	76 11                	jbe    f0104ab7 <stab_binsearch+0x79>
			*region_left = m;
f0104aa6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104aa9:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104aab:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104aae:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ab5:	eb 2b                	jmp    f0104ae2 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104ab7:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104aba:	73 14                	jae    f0104ad0 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104abc:	83 e8 01             	sub    $0x1,%eax
f0104abf:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ac2:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104ac5:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104ac7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ace:	eb 12                	jmp    f0104ae2 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104ad0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104ad3:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104ad5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104ad9:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104adb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104ae2:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104ae5:	0f 8e 78 ff ff ff    	jle    f0104a63 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104aeb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104aef:	75 0f                	jne    f0104b00 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104af1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104af4:	8b 00                	mov    (%eax),%eax
f0104af6:	83 e8 01             	sub    $0x1,%eax
f0104af9:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104afc:	89 06                	mov    %eax,(%esi)
f0104afe:	eb 2c                	jmp    f0104b2c <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b00:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b03:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104b05:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b08:	8b 0e                	mov    (%esi),%ecx
f0104b0a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b0d:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104b10:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b13:	eb 03                	jmp    f0104b18 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104b15:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b18:	39 c8                	cmp    %ecx,%eax
f0104b1a:	7e 0b                	jle    f0104b27 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104b1c:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104b20:	83 ea 0c             	sub    $0xc,%edx
f0104b23:	39 df                	cmp    %ebx,%edi
f0104b25:	75 ee                	jne    f0104b15 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104b27:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b2a:	89 06                	mov    %eax,(%esi)
	}
}
f0104b2c:	83 c4 14             	add    $0x14,%esp
f0104b2f:	5b                   	pop    %ebx
f0104b30:	5e                   	pop    %esi
f0104b31:	5f                   	pop    %edi
f0104b32:	5d                   	pop    %ebp
f0104b33:	c3                   	ret    

f0104b34 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104b34:	55                   	push   %ebp
f0104b35:	89 e5                	mov    %esp,%ebp
f0104b37:	57                   	push   %edi
f0104b38:	56                   	push   %esi
f0104b39:	53                   	push   %ebx
f0104b3a:	83 ec 3c             	sub    $0x3c,%esp
f0104b3d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104b40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104b43:	c7 03 04 7b 10 f0    	movl   $0xf0107b04,(%ebx)
	info->eip_line = 0;
f0104b49:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104b50:	c7 43 08 04 7b 10 f0 	movl   $0xf0107b04,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104b57:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104b5e:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104b61:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104b68:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104b6e:	0f 87 a3 00 00 00    	ja     f0104c17 <debuginfo_eip+0xe3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104b74:	a1 00 00 20 00       	mov    0x200000,%eax
f0104b79:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104b7c:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104b82:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104b88:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104b8b:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104b90:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104b93:	e8 4e 10 00 00       	call   f0105be6 <cpunum>
f0104b98:	6a 04                	push   $0x4
f0104b9a:	6a 10                	push   $0x10
f0104b9c:	68 00 00 20 00       	push   $0x200000
f0104ba1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ba4:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f0104baa:	e8 f3 e2 ff ff       	call   f0102ea2 <user_mem_check>
f0104baf:	83 c4 10             	add    $0x10,%esp
f0104bb2:	85 c0                	test   %eax,%eax
f0104bb4:	0f 88 27 02 00 00    	js     f0104de1 <debuginfo_eip+0x2ad>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104bba:	e8 27 10 00 00       	call   f0105be6 <cpunum>
f0104bbf:	6a 04                	push   $0x4
f0104bc1:	89 f2                	mov    %esi,%edx
f0104bc3:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104bc6:	29 ca                	sub    %ecx,%edx
f0104bc8:	c1 fa 02             	sar    $0x2,%edx
f0104bcb:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104bd1:	52                   	push   %edx
f0104bd2:	51                   	push   %ecx
f0104bd3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd6:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f0104bdc:	e8 c1 e2 ff ff       	call   f0102ea2 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104be1:	83 c4 10             	add    $0x10,%esp
f0104be4:	85 c0                	test   %eax,%eax
f0104be6:	0f 88 fc 01 00 00    	js     f0104de8 <debuginfo_eip+0x2b4>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
f0104bec:	e8 f5 0f 00 00       	call   f0105be6 <cpunum>
f0104bf1:	6a 04                	push   $0x4
f0104bf3:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104bf6:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104bf9:	29 ca                	sub    %ecx,%edx
f0104bfb:	52                   	push   %edx
f0104bfc:	51                   	push   %ecx
f0104bfd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c00:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f0104c06:	e8 97 e2 ff ff       	call   f0102ea2 <user_mem_check>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104c0b:	83 c4 10             	add    $0x10,%esp
f0104c0e:	85 c0                	test   %eax,%eax
f0104c10:	79 1f                	jns    f0104c31 <debuginfo_eip+0xfd>
f0104c12:	e9 d8 01 00 00       	jmp    f0104def <debuginfo_eip+0x2bb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104c17:	c7 45 bc 85 5b 11 f0 	movl   $0xf0115b85,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104c1e:	c7 45 b8 dd 23 11 f0 	movl   $0xf01123dd,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104c25:	be dc 23 11 f0       	mov    $0xf01123dc,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104c2a:	c7 45 c0 b0 80 10 f0 	movl   $0xf01080b0,-0x40(%ebp)
		)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104c31:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104c34:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104c37:	0f 83 b9 01 00 00    	jae    f0104df6 <debuginfo_eip+0x2c2>
f0104c3d:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104c41:	0f 85 b6 01 00 00    	jne    f0104dfd <debuginfo_eip+0x2c9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104c47:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104c4e:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104c51:	c1 fe 02             	sar    $0x2,%esi
f0104c54:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104c5a:	83 e8 01             	sub    $0x1,%eax
f0104c5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104c60:	83 ec 08             	sub    $0x8,%esp
f0104c63:	57                   	push   %edi
f0104c64:	6a 64                	push   $0x64
f0104c66:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104c69:	89 d1                	mov    %edx,%ecx
f0104c6b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104c6e:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104c71:	89 f0                	mov    %esi,%eax
f0104c73:	e8 c6 fd ff ff       	call   f0104a3e <stab_binsearch>
	if (lfile == 0)
f0104c78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c7b:	83 c4 10             	add    $0x10,%esp
f0104c7e:	85 c0                	test   %eax,%eax
f0104c80:	0f 84 7e 01 00 00    	je     f0104e04 <debuginfo_eip+0x2d0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104c86:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104c89:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104c8f:	83 ec 08             	sub    $0x8,%esp
f0104c92:	57                   	push   %edi
f0104c93:	6a 24                	push   $0x24
f0104c95:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104c98:	89 d1                	mov    %edx,%ecx
f0104c9a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104c9d:	89 f0                	mov    %esi,%eax
f0104c9f:	e8 9a fd ff ff       	call   f0104a3e <stab_binsearch>

	if (lfun <= rfun) {
f0104ca4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ca7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104caa:	83 c4 10             	add    $0x10,%esp
f0104cad:	39 d0                	cmp    %edx,%eax
f0104caf:	7f 2e                	jg     f0104cdf <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104cb1:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104cb4:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104cb7:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104cba:	8b 36                	mov    (%esi),%esi
f0104cbc:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104cbf:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104cc2:	39 ce                	cmp    %ecx,%esi
f0104cc4:	73 06                	jae    f0104ccc <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104cc6:	03 75 b8             	add    -0x48(%ebp),%esi
f0104cc9:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104ccc:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104ccf:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104cd2:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104cd5:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104cd7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104cda:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104cdd:	eb 0f                	jmp    f0104cee <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104cdf:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104ce2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ce5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104ce8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ceb:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104cee:	83 ec 08             	sub    $0x8,%esp
f0104cf1:	6a 3a                	push   $0x3a
f0104cf3:	ff 73 08             	pushl  0x8(%ebx)
f0104cf6:	e8 af 08 00 00       	call   f01055aa <strfind>
f0104cfb:	2b 43 08             	sub    0x8(%ebx),%eax
f0104cfe:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104d01:	83 c4 08             	add    $0x8,%esp
f0104d04:	57                   	push   %edi
f0104d05:	6a 44                	push   $0x44
f0104d07:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104d0a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104d0d:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104d10:	89 f0                	mov    %esi,%eax
f0104d12:	e8 27 fd ff ff       	call   f0104a3e <stab_binsearch>
	if (lline == 0)
f0104d17:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104d1a:	83 c4 10             	add    $0x10,%esp
f0104d1d:	85 d2                	test   %edx,%edx
f0104d1f:	0f 84 e6 00 00 00    	je     f0104e0b <debuginfo_eip+0x2d7>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0104d25:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104d28:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104d2b:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104d30:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104d33:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d36:	89 d0                	mov    %edx,%eax
f0104d38:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104d3b:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104d3e:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104d42:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104d45:	eb 0a                	jmp    f0104d51 <debuginfo_eip+0x21d>
f0104d47:	83 e8 01             	sub    $0x1,%eax
f0104d4a:	83 ea 0c             	sub    $0xc,%edx
f0104d4d:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104d51:	39 c7                	cmp    %eax,%edi
f0104d53:	7e 05                	jle    f0104d5a <debuginfo_eip+0x226>
f0104d55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d58:	eb 47                	jmp    f0104da1 <debuginfo_eip+0x26d>
	       && stabs[lline].n_type != N_SOL
f0104d5a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104d5e:	80 f9 84             	cmp    $0x84,%cl
f0104d61:	75 0e                	jne    f0104d71 <debuginfo_eip+0x23d>
f0104d63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d66:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d6a:	74 1c                	je     f0104d88 <debuginfo_eip+0x254>
f0104d6c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104d6f:	eb 17                	jmp    f0104d88 <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104d71:	80 f9 64             	cmp    $0x64,%cl
f0104d74:	75 d1                	jne    f0104d47 <debuginfo_eip+0x213>
f0104d76:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104d7a:	74 cb                	je     f0104d47 <debuginfo_eip+0x213>
f0104d7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d7f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d83:	74 03                	je     f0104d88 <debuginfo_eip+0x254>
f0104d85:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104d88:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104d8b:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104d8e:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104d91:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104d94:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104d97:	29 f8                	sub    %edi,%eax
f0104d99:	39 c2                	cmp    %eax,%edx
f0104d9b:	73 04                	jae    f0104da1 <debuginfo_eip+0x26d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104d9d:	01 fa                	add    %edi,%edx
f0104d9f:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104da1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104da4:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104da7:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104dac:	39 f2                	cmp    %esi,%edx
f0104dae:	7d 67                	jge    f0104e17 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
f0104db0:	83 c2 01             	add    $0x1,%edx
f0104db3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104db6:	89 d0                	mov    %edx,%eax
f0104db8:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104dbb:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104dbe:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104dc1:	eb 04                	jmp    f0104dc7 <debuginfo_eip+0x293>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104dc3:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104dc7:	39 c6                	cmp    %eax,%esi
f0104dc9:	7e 47                	jle    f0104e12 <debuginfo_eip+0x2de>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104dcb:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104dcf:	83 c0 01             	add    $0x1,%eax
f0104dd2:	83 c2 0c             	add    $0xc,%edx
f0104dd5:	80 f9 a0             	cmp    $0xa0,%cl
f0104dd8:	74 e9                	je     f0104dc3 <debuginfo_eip+0x28f>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104dda:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ddf:	eb 36                	jmp    f0104e17 <debuginfo_eip+0x2e3>
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
		)
			return -1;
f0104de1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104de6:	eb 2f                	jmp    f0104e17 <debuginfo_eip+0x2e3>
f0104de8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ded:	eb 28                	jmp    f0104e17 <debuginfo_eip+0x2e3>
f0104def:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104df4:	eb 21                	jmp    f0104e17 <debuginfo_eip+0x2e3>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104df6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104dfb:	eb 1a                	jmp    f0104e17 <debuginfo_eip+0x2e3>
f0104dfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e02:	eb 13                	jmp    f0104e17 <debuginfo_eip+0x2e3>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104e04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e09:	eb 0c                	jmp    f0104e17 <debuginfo_eip+0x2e3>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0104e0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e10:	eb 05                	jmp    f0104e17 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104e12:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104e17:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e1a:	5b                   	pop    %ebx
f0104e1b:	5e                   	pop    %esi
f0104e1c:	5f                   	pop    %edi
f0104e1d:	5d                   	pop    %ebp
f0104e1e:	c3                   	ret    

f0104e1f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104e1f:	55                   	push   %ebp
f0104e20:	89 e5                	mov    %esp,%ebp
f0104e22:	57                   	push   %edi
f0104e23:	56                   	push   %esi
f0104e24:	53                   	push   %ebx
f0104e25:	83 ec 1c             	sub    $0x1c,%esp
f0104e28:	89 c7                	mov    %eax,%edi
f0104e2a:	89 d6                	mov    %edx,%esi
f0104e2c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e2f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e32:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e35:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104e38:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e3b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e40:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104e43:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104e46:	39 d3                	cmp    %edx,%ebx
f0104e48:	72 05                	jb     f0104e4f <printnum+0x30>
f0104e4a:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104e4d:	77 45                	ja     f0104e94 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104e4f:	83 ec 0c             	sub    $0xc,%esp
f0104e52:	ff 75 18             	pushl  0x18(%ebp)
f0104e55:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e58:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104e5b:	53                   	push   %ebx
f0104e5c:	ff 75 10             	pushl  0x10(%ebp)
f0104e5f:	83 ec 08             	sub    $0x8,%esp
f0104e62:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e65:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e68:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e6b:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e6e:	e8 6d 11 00 00       	call   f0105fe0 <__udivdi3>
f0104e73:	83 c4 18             	add    $0x18,%esp
f0104e76:	52                   	push   %edx
f0104e77:	50                   	push   %eax
f0104e78:	89 f2                	mov    %esi,%edx
f0104e7a:	89 f8                	mov    %edi,%eax
f0104e7c:	e8 9e ff ff ff       	call   f0104e1f <printnum>
f0104e81:	83 c4 20             	add    $0x20,%esp
f0104e84:	eb 18                	jmp    f0104e9e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104e86:	83 ec 08             	sub    $0x8,%esp
f0104e89:	56                   	push   %esi
f0104e8a:	ff 75 18             	pushl  0x18(%ebp)
f0104e8d:	ff d7                	call   *%edi
f0104e8f:	83 c4 10             	add    $0x10,%esp
f0104e92:	eb 03                	jmp    f0104e97 <printnum+0x78>
f0104e94:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104e97:	83 eb 01             	sub    $0x1,%ebx
f0104e9a:	85 db                	test   %ebx,%ebx
f0104e9c:	7f e8                	jg     f0104e86 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104e9e:	83 ec 08             	sub    $0x8,%esp
f0104ea1:	56                   	push   %esi
f0104ea2:	83 ec 04             	sub    $0x4,%esp
f0104ea5:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104ea8:	ff 75 e0             	pushl  -0x20(%ebp)
f0104eab:	ff 75 dc             	pushl  -0x24(%ebp)
f0104eae:	ff 75 d8             	pushl  -0x28(%ebp)
f0104eb1:	e8 5a 12 00 00       	call   f0106110 <__umoddi3>
f0104eb6:	83 c4 14             	add    $0x14,%esp
f0104eb9:	0f be 80 0e 7b 10 f0 	movsbl -0xfef84f2(%eax),%eax
f0104ec0:	50                   	push   %eax
f0104ec1:	ff d7                	call   *%edi
}
f0104ec3:	83 c4 10             	add    $0x10,%esp
f0104ec6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ec9:	5b                   	pop    %ebx
f0104eca:	5e                   	pop    %esi
f0104ecb:	5f                   	pop    %edi
f0104ecc:	5d                   	pop    %ebp
f0104ecd:	c3                   	ret    

f0104ece <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104ece:	55                   	push   %ebp
f0104ecf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104ed1:	83 fa 01             	cmp    $0x1,%edx
f0104ed4:	7e 0e                	jle    f0104ee4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104ed6:	8b 10                	mov    (%eax),%edx
f0104ed8:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104edb:	89 08                	mov    %ecx,(%eax)
f0104edd:	8b 02                	mov    (%edx),%eax
f0104edf:	8b 52 04             	mov    0x4(%edx),%edx
f0104ee2:	eb 22                	jmp    f0104f06 <getuint+0x38>
	else if (lflag)
f0104ee4:	85 d2                	test   %edx,%edx
f0104ee6:	74 10                	je     f0104ef8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104ee8:	8b 10                	mov    (%eax),%edx
f0104eea:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104eed:	89 08                	mov    %ecx,(%eax)
f0104eef:	8b 02                	mov    (%edx),%eax
f0104ef1:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ef6:	eb 0e                	jmp    f0104f06 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104ef8:	8b 10                	mov    (%eax),%edx
f0104efa:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104efd:	89 08                	mov    %ecx,(%eax)
f0104eff:	8b 02                	mov    (%edx),%eax
f0104f01:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104f06:	5d                   	pop    %ebp
f0104f07:	c3                   	ret    

f0104f08 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104f08:	55                   	push   %ebp
f0104f09:	89 e5                	mov    %esp,%ebp
f0104f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104f0e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104f12:	8b 10                	mov    (%eax),%edx
f0104f14:	3b 50 04             	cmp    0x4(%eax),%edx
f0104f17:	73 0a                	jae    f0104f23 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104f19:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104f1c:	89 08                	mov    %ecx,(%eax)
f0104f1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f21:	88 02                	mov    %al,(%edx)
}
f0104f23:	5d                   	pop    %ebp
f0104f24:	c3                   	ret    

f0104f25 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104f25:	55                   	push   %ebp
f0104f26:	89 e5                	mov    %esp,%ebp
f0104f28:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104f2b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104f2e:	50                   	push   %eax
f0104f2f:	ff 75 10             	pushl  0x10(%ebp)
f0104f32:	ff 75 0c             	pushl  0xc(%ebp)
f0104f35:	ff 75 08             	pushl  0x8(%ebp)
f0104f38:	e8 05 00 00 00       	call   f0104f42 <vprintfmt>
	va_end(ap);
}
f0104f3d:	83 c4 10             	add    $0x10,%esp
f0104f40:	c9                   	leave  
f0104f41:	c3                   	ret    

f0104f42 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104f42:	55                   	push   %ebp
f0104f43:	89 e5                	mov    %esp,%ebp
f0104f45:	57                   	push   %edi
f0104f46:	56                   	push   %esi
f0104f47:	53                   	push   %ebx
f0104f48:	83 ec 2c             	sub    $0x2c,%esp
f0104f4b:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f51:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f54:	eb 12                	jmp    f0104f68 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104f56:	85 c0                	test   %eax,%eax
f0104f58:	0f 84 89 03 00 00    	je     f01052e7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104f5e:	83 ec 08             	sub    $0x8,%esp
f0104f61:	53                   	push   %ebx
f0104f62:	50                   	push   %eax
f0104f63:	ff d6                	call   *%esi
f0104f65:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104f68:	83 c7 01             	add    $0x1,%edi
f0104f6b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104f6f:	83 f8 25             	cmp    $0x25,%eax
f0104f72:	75 e2                	jne    f0104f56 <vprintfmt+0x14>
f0104f74:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104f78:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104f7f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104f86:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104f8d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f92:	eb 07                	jmp    f0104f9b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f94:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104f97:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f9b:	8d 47 01             	lea    0x1(%edi),%eax
f0104f9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104fa1:	0f b6 07             	movzbl (%edi),%eax
f0104fa4:	0f b6 c8             	movzbl %al,%ecx
f0104fa7:	83 e8 23             	sub    $0x23,%eax
f0104faa:	3c 55                	cmp    $0x55,%al
f0104fac:	0f 87 1a 03 00 00    	ja     f01052cc <vprintfmt+0x38a>
f0104fb2:	0f b6 c0             	movzbl %al,%eax
f0104fb5:	ff 24 85 60 7c 10 f0 	jmp    *-0xfef83a0(,%eax,4)
f0104fbc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104fbf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104fc3:	eb d6                	jmp    f0104f9b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fc8:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fcd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104fd0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104fd3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104fd7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104fda:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104fdd:	83 fa 09             	cmp    $0x9,%edx
f0104fe0:	77 39                	ja     f010501b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104fe2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104fe5:	eb e9                	jmp    f0104fd0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104fe7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fea:	8d 48 04             	lea    0x4(%eax),%ecx
f0104fed:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104ff0:	8b 00                	mov    (%eax),%eax
f0104ff2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ff5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104ff8:	eb 27                	jmp    f0105021 <vprintfmt+0xdf>
f0104ffa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ffd:	85 c0                	test   %eax,%eax
f0104fff:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105004:	0f 49 c8             	cmovns %eax,%ecx
f0105007:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010500a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010500d:	eb 8c                	jmp    f0104f9b <vprintfmt+0x59>
f010500f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105012:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105019:	eb 80                	jmp    f0104f9b <vprintfmt+0x59>
f010501b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010501e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105021:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105025:	0f 89 70 ff ff ff    	jns    f0104f9b <vprintfmt+0x59>
				width = precision, precision = -1;
f010502b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010502e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105031:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105038:	e9 5e ff ff ff       	jmp    f0104f9b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010503d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105040:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105043:	e9 53 ff ff ff       	jmp    f0104f9b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105048:	8b 45 14             	mov    0x14(%ebp),%eax
f010504b:	8d 50 04             	lea    0x4(%eax),%edx
f010504e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105051:	83 ec 08             	sub    $0x8,%esp
f0105054:	53                   	push   %ebx
f0105055:	ff 30                	pushl  (%eax)
f0105057:	ff d6                	call   *%esi
			break;
f0105059:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010505c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010505f:	e9 04 ff ff ff       	jmp    f0104f68 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105064:	8b 45 14             	mov    0x14(%ebp),%eax
f0105067:	8d 50 04             	lea    0x4(%eax),%edx
f010506a:	89 55 14             	mov    %edx,0x14(%ebp)
f010506d:	8b 00                	mov    (%eax),%eax
f010506f:	99                   	cltd   
f0105070:	31 d0                	xor    %edx,%eax
f0105072:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105074:	83 f8 0f             	cmp    $0xf,%eax
f0105077:	7f 0b                	jg     f0105084 <vprintfmt+0x142>
f0105079:	8b 14 85 c0 7d 10 f0 	mov    -0xfef8240(,%eax,4),%edx
f0105080:	85 d2                	test   %edx,%edx
f0105082:	75 18                	jne    f010509c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0105084:	50                   	push   %eax
f0105085:	68 26 7b 10 f0       	push   $0xf0107b26
f010508a:	53                   	push   %ebx
f010508b:	56                   	push   %esi
f010508c:	e8 94 fe ff ff       	call   f0104f25 <printfmt>
f0105091:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105094:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105097:	e9 cc fe ff ff       	jmp    f0104f68 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f010509c:	52                   	push   %edx
f010509d:	68 97 68 10 f0       	push   $0xf0106897
f01050a2:	53                   	push   %ebx
f01050a3:	56                   	push   %esi
f01050a4:	e8 7c fe ff ff       	call   f0104f25 <printfmt>
f01050a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050af:	e9 b4 fe ff ff       	jmp    f0104f68 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01050b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01050b7:	8d 50 04             	lea    0x4(%eax),%edx
f01050ba:	89 55 14             	mov    %edx,0x14(%ebp)
f01050bd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01050bf:	85 ff                	test   %edi,%edi
f01050c1:	b8 1f 7b 10 f0       	mov    $0xf0107b1f,%eax
f01050c6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01050c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01050cd:	0f 8e 94 00 00 00    	jle    f0105167 <vprintfmt+0x225>
f01050d3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01050d7:	0f 84 98 00 00 00    	je     f0105175 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f01050dd:	83 ec 08             	sub    $0x8,%esp
f01050e0:	ff 75 d0             	pushl  -0x30(%ebp)
f01050e3:	57                   	push   %edi
f01050e4:	e8 77 03 00 00       	call   f0105460 <strnlen>
f01050e9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01050ec:	29 c1                	sub    %eax,%ecx
f01050ee:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01050f1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01050f4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01050f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01050fb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01050fe:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105100:	eb 0f                	jmp    f0105111 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0105102:	83 ec 08             	sub    $0x8,%esp
f0105105:	53                   	push   %ebx
f0105106:	ff 75 e0             	pushl  -0x20(%ebp)
f0105109:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010510b:	83 ef 01             	sub    $0x1,%edi
f010510e:	83 c4 10             	add    $0x10,%esp
f0105111:	85 ff                	test   %edi,%edi
f0105113:	7f ed                	jg     f0105102 <vprintfmt+0x1c0>
f0105115:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105118:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010511b:	85 c9                	test   %ecx,%ecx
f010511d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105122:	0f 49 c1             	cmovns %ecx,%eax
f0105125:	29 c1                	sub    %eax,%ecx
f0105127:	89 75 08             	mov    %esi,0x8(%ebp)
f010512a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010512d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105130:	89 cb                	mov    %ecx,%ebx
f0105132:	eb 4d                	jmp    f0105181 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105134:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105138:	74 1b                	je     f0105155 <vprintfmt+0x213>
f010513a:	0f be c0             	movsbl %al,%eax
f010513d:	83 e8 20             	sub    $0x20,%eax
f0105140:	83 f8 5e             	cmp    $0x5e,%eax
f0105143:	76 10                	jbe    f0105155 <vprintfmt+0x213>
					putch('?', putdat);
f0105145:	83 ec 08             	sub    $0x8,%esp
f0105148:	ff 75 0c             	pushl  0xc(%ebp)
f010514b:	6a 3f                	push   $0x3f
f010514d:	ff 55 08             	call   *0x8(%ebp)
f0105150:	83 c4 10             	add    $0x10,%esp
f0105153:	eb 0d                	jmp    f0105162 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0105155:	83 ec 08             	sub    $0x8,%esp
f0105158:	ff 75 0c             	pushl  0xc(%ebp)
f010515b:	52                   	push   %edx
f010515c:	ff 55 08             	call   *0x8(%ebp)
f010515f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105162:	83 eb 01             	sub    $0x1,%ebx
f0105165:	eb 1a                	jmp    f0105181 <vprintfmt+0x23f>
f0105167:	89 75 08             	mov    %esi,0x8(%ebp)
f010516a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010516d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105170:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105173:	eb 0c                	jmp    f0105181 <vprintfmt+0x23f>
f0105175:	89 75 08             	mov    %esi,0x8(%ebp)
f0105178:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010517b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010517e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105181:	83 c7 01             	add    $0x1,%edi
f0105184:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105188:	0f be d0             	movsbl %al,%edx
f010518b:	85 d2                	test   %edx,%edx
f010518d:	74 23                	je     f01051b2 <vprintfmt+0x270>
f010518f:	85 f6                	test   %esi,%esi
f0105191:	78 a1                	js     f0105134 <vprintfmt+0x1f2>
f0105193:	83 ee 01             	sub    $0x1,%esi
f0105196:	79 9c                	jns    f0105134 <vprintfmt+0x1f2>
f0105198:	89 df                	mov    %ebx,%edi
f010519a:	8b 75 08             	mov    0x8(%ebp),%esi
f010519d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051a0:	eb 18                	jmp    f01051ba <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01051a2:	83 ec 08             	sub    $0x8,%esp
f01051a5:	53                   	push   %ebx
f01051a6:	6a 20                	push   $0x20
f01051a8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01051aa:	83 ef 01             	sub    $0x1,%edi
f01051ad:	83 c4 10             	add    $0x10,%esp
f01051b0:	eb 08                	jmp    f01051ba <vprintfmt+0x278>
f01051b2:	89 df                	mov    %ebx,%edi
f01051b4:	8b 75 08             	mov    0x8(%ebp),%esi
f01051b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051ba:	85 ff                	test   %edi,%edi
f01051bc:	7f e4                	jg     f01051a2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051c1:	e9 a2 fd ff ff       	jmp    f0104f68 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01051c6:	83 fa 01             	cmp    $0x1,%edx
f01051c9:	7e 16                	jle    f01051e1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01051cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01051ce:	8d 50 08             	lea    0x8(%eax),%edx
f01051d1:	89 55 14             	mov    %edx,0x14(%ebp)
f01051d4:	8b 50 04             	mov    0x4(%eax),%edx
f01051d7:	8b 00                	mov    (%eax),%eax
f01051d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01051df:	eb 32                	jmp    f0105213 <vprintfmt+0x2d1>
	else if (lflag)
f01051e1:	85 d2                	test   %edx,%edx
f01051e3:	74 18                	je     f01051fd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01051e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01051e8:	8d 50 04             	lea    0x4(%eax),%edx
f01051eb:	89 55 14             	mov    %edx,0x14(%ebp)
f01051ee:	8b 00                	mov    (%eax),%eax
f01051f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051f3:	89 c1                	mov    %eax,%ecx
f01051f5:	c1 f9 1f             	sar    $0x1f,%ecx
f01051f8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01051fb:	eb 16                	jmp    f0105213 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01051fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0105200:	8d 50 04             	lea    0x4(%eax),%edx
f0105203:	89 55 14             	mov    %edx,0x14(%ebp)
f0105206:	8b 00                	mov    (%eax),%eax
f0105208:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010520b:	89 c1                	mov    %eax,%ecx
f010520d:	c1 f9 1f             	sar    $0x1f,%ecx
f0105210:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105213:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105216:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105219:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010521e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105222:	79 74                	jns    f0105298 <vprintfmt+0x356>
				putch('-', putdat);
f0105224:	83 ec 08             	sub    $0x8,%esp
f0105227:	53                   	push   %ebx
f0105228:	6a 2d                	push   $0x2d
f010522a:	ff d6                	call   *%esi
				num = -(long long) num;
f010522c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010522f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105232:	f7 d8                	neg    %eax
f0105234:	83 d2 00             	adc    $0x0,%edx
f0105237:	f7 da                	neg    %edx
f0105239:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010523c:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105241:	eb 55                	jmp    f0105298 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105243:	8d 45 14             	lea    0x14(%ebp),%eax
f0105246:	e8 83 fc ff ff       	call   f0104ece <getuint>
			base = 10;
f010524b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105250:	eb 46                	jmp    f0105298 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0105252:	8d 45 14             	lea    0x14(%ebp),%eax
f0105255:	e8 74 fc ff ff       	call   f0104ece <getuint>
			base = 8;
f010525a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f010525f:	eb 37                	jmp    f0105298 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0105261:	83 ec 08             	sub    $0x8,%esp
f0105264:	53                   	push   %ebx
f0105265:	6a 30                	push   $0x30
f0105267:	ff d6                	call   *%esi
			putch('x', putdat);
f0105269:	83 c4 08             	add    $0x8,%esp
f010526c:	53                   	push   %ebx
f010526d:	6a 78                	push   $0x78
f010526f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105271:	8b 45 14             	mov    0x14(%ebp),%eax
f0105274:	8d 50 04             	lea    0x4(%eax),%edx
f0105277:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010527a:	8b 00                	mov    (%eax),%eax
f010527c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105281:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105284:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105289:	eb 0d                	jmp    f0105298 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010528b:	8d 45 14             	lea    0x14(%ebp),%eax
f010528e:	e8 3b fc ff ff       	call   f0104ece <getuint>
			base = 16;
f0105293:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105298:	83 ec 0c             	sub    $0xc,%esp
f010529b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010529f:	57                   	push   %edi
f01052a0:	ff 75 e0             	pushl  -0x20(%ebp)
f01052a3:	51                   	push   %ecx
f01052a4:	52                   	push   %edx
f01052a5:	50                   	push   %eax
f01052a6:	89 da                	mov    %ebx,%edx
f01052a8:	89 f0                	mov    %esi,%eax
f01052aa:	e8 70 fb ff ff       	call   f0104e1f <printnum>
			break;
f01052af:	83 c4 20             	add    $0x20,%esp
f01052b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052b5:	e9 ae fc ff ff       	jmp    f0104f68 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01052ba:	83 ec 08             	sub    $0x8,%esp
f01052bd:	53                   	push   %ebx
f01052be:	51                   	push   %ecx
f01052bf:	ff d6                	call   *%esi
			break;
f01052c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01052c7:	e9 9c fc ff ff       	jmp    f0104f68 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01052cc:	83 ec 08             	sub    $0x8,%esp
f01052cf:	53                   	push   %ebx
f01052d0:	6a 25                	push   $0x25
f01052d2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01052d4:	83 c4 10             	add    $0x10,%esp
f01052d7:	eb 03                	jmp    f01052dc <vprintfmt+0x39a>
f01052d9:	83 ef 01             	sub    $0x1,%edi
f01052dc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01052e0:	75 f7                	jne    f01052d9 <vprintfmt+0x397>
f01052e2:	e9 81 fc ff ff       	jmp    f0104f68 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01052e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01052ea:	5b                   	pop    %ebx
f01052eb:	5e                   	pop    %esi
f01052ec:	5f                   	pop    %edi
f01052ed:	5d                   	pop    %ebp
f01052ee:	c3                   	ret    

f01052ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01052ef:	55                   	push   %ebp
f01052f0:	89 e5                	mov    %esp,%ebp
f01052f2:	83 ec 18             	sub    $0x18,%esp
f01052f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01052f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01052fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01052fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105302:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105305:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010530c:	85 c0                	test   %eax,%eax
f010530e:	74 26                	je     f0105336 <vsnprintf+0x47>
f0105310:	85 d2                	test   %edx,%edx
f0105312:	7e 22                	jle    f0105336 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105314:	ff 75 14             	pushl  0x14(%ebp)
f0105317:	ff 75 10             	pushl  0x10(%ebp)
f010531a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010531d:	50                   	push   %eax
f010531e:	68 08 4f 10 f0       	push   $0xf0104f08
f0105323:	e8 1a fc ff ff       	call   f0104f42 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105328:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010532b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010532e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105331:	83 c4 10             	add    $0x10,%esp
f0105334:	eb 05                	jmp    f010533b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105336:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010533b:	c9                   	leave  
f010533c:	c3                   	ret    

f010533d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010533d:	55                   	push   %ebp
f010533e:	89 e5                	mov    %esp,%ebp
f0105340:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105343:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105346:	50                   	push   %eax
f0105347:	ff 75 10             	pushl  0x10(%ebp)
f010534a:	ff 75 0c             	pushl  0xc(%ebp)
f010534d:	ff 75 08             	pushl  0x8(%ebp)
f0105350:	e8 9a ff ff ff       	call   f01052ef <vsnprintf>
	va_end(ap);

	return rc;
}
f0105355:	c9                   	leave  
f0105356:	c3                   	ret    

f0105357 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105357:	55                   	push   %ebp
f0105358:	89 e5                	mov    %esp,%ebp
f010535a:	57                   	push   %edi
f010535b:	56                   	push   %esi
f010535c:	53                   	push   %ebx
f010535d:	83 ec 0c             	sub    $0xc,%esp
f0105360:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105363:	85 c0                	test   %eax,%eax
f0105365:	74 11                	je     f0105378 <readline+0x21>
		cprintf("%s", prompt);
f0105367:	83 ec 08             	sub    $0x8,%esp
f010536a:	50                   	push   %eax
f010536b:	68 97 68 10 f0       	push   $0xf0106897
f0105370:	e8 f7 e4 ff ff       	call   f010386c <cprintf>
f0105375:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105378:	83 ec 0c             	sub    $0xc,%esp
f010537b:	6a 00                	push   $0x0
f010537d:	e8 21 b4 ff ff       	call   f01007a3 <iscons>
f0105382:	89 c7                	mov    %eax,%edi
f0105384:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105387:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010538c:	e8 01 b4 ff ff       	call   f0100792 <getchar>
f0105391:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105393:	85 c0                	test   %eax,%eax
f0105395:	79 29                	jns    f01053c0 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105397:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f010539c:	83 fb f8             	cmp    $0xfffffff8,%ebx
f010539f:	0f 84 9b 00 00 00    	je     f0105440 <readline+0xe9>
				cprintf("read error: %e\n", c);
f01053a5:	83 ec 08             	sub    $0x8,%esp
f01053a8:	53                   	push   %ebx
f01053a9:	68 1f 7e 10 f0       	push   $0xf0107e1f
f01053ae:	e8 b9 e4 ff ff       	call   f010386c <cprintf>
f01053b3:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01053b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01053bb:	e9 80 00 00 00       	jmp    f0105440 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01053c0:	83 f8 08             	cmp    $0x8,%eax
f01053c3:	0f 94 c2             	sete   %dl
f01053c6:	83 f8 7f             	cmp    $0x7f,%eax
f01053c9:	0f 94 c0             	sete   %al
f01053cc:	08 c2                	or     %al,%dl
f01053ce:	74 1a                	je     f01053ea <readline+0x93>
f01053d0:	85 f6                	test   %esi,%esi
f01053d2:	7e 16                	jle    f01053ea <readline+0x93>
			if (echoing)
f01053d4:	85 ff                	test   %edi,%edi
f01053d6:	74 0d                	je     f01053e5 <readline+0x8e>
				cputchar('\b');
f01053d8:	83 ec 0c             	sub    $0xc,%esp
f01053db:	6a 08                	push   $0x8
f01053dd:	e8 a0 b3 ff ff       	call   f0100782 <cputchar>
f01053e2:	83 c4 10             	add    $0x10,%esp
			i--;
f01053e5:	83 ee 01             	sub    $0x1,%esi
f01053e8:	eb a2                	jmp    f010538c <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01053ea:	83 fb 1f             	cmp    $0x1f,%ebx
f01053ed:	7e 26                	jle    f0105415 <readline+0xbe>
f01053ef:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01053f5:	7f 1e                	jg     f0105415 <readline+0xbe>
			if (echoing)
f01053f7:	85 ff                	test   %edi,%edi
f01053f9:	74 0c                	je     f0105407 <readline+0xb0>
				cputchar(c);
f01053fb:	83 ec 0c             	sub    $0xc,%esp
f01053fe:	53                   	push   %ebx
f01053ff:	e8 7e b3 ff ff       	call   f0100782 <cputchar>
f0105404:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105407:	88 9e 80 fa 20 f0    	mov    %bl,-0xfdf0580(%esi)
f010540d:	8d 76 01             	lea    0x1(%esi),%esi
f0105410:	e9 77 ff ff ff       	jmp    f010538c <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105415:	83 fb 0a             	cmp    $0xa,%ebx
f0105418:	74 09                	je     f0105423 <readline+0xcc>
f010541a:	83 fb 0d             	cmp    $0xd,%ebx
f010541d:	0f 85 69 ff ff ff    	jne    f010538c <readline+0x35>
			if (echoing)
f0105423:	85 ff                	test   %edi,%edi
f0105425:	74 0d                	je     f0105434 <readline+0xdd>
				cputchar('\n');
f0105427:	83 ec 0c             	sub    $0xc,%esp
f010542a:	6a 0a                	push   $0xa
f010542c:	e8 51 b3 ff ff       	call   f0100782 <cputchar>
f0105431:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105434:	c6 86 80 fa 20 f0 00 	movb   $0x0,-0xfdf0580(%esi)
			return buf;
f010543b:	b8 80 fa 20 f0       	mov    $0xf020fa80,%eax
		}
	}
}
f0105440:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105443:	5b                   	pop    %ebx
f0105444:	5e                   	pop    %esi
f0105445:	5f                   	pop    %edi
f0105446:	5d                   	pop    %ebp
f0105447:	c3                   	ret    

f0105448 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105448:	55                   	push   %ebp
f0105449:	89 e5                	mov    %esp,%ebp
f010544b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010544e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105453:	eb 03                	jmp    f0105458 <strlen+0x10>
		n++;
f0105455:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105458:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010545c:	75 f7                	jne    f0105455 <strlen+0xd>
		n++;
	return n;
}
f010545e:	5d                   	pop    %ebp
f010545f:	c3                   	ret    

f0105460 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105460:	55                   	push   %ebp
f0105461:	89 e5                	mov    %esp,%ebp
f0105463:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105466:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105469:	ba 00 00 00 00       	mov    $0x0,%edx
f010546e:	eb 03                	jmp    f0105473 <strnlen+0x13>
		n++;
f0105470:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105473:	39 c2                	cmp    %eax,%edx
f0105475:	74 08                	je     f010547f <strnlen+0x1f>
f0105477:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010547b:	75 f3                	jne    f0105470 <strnlen+0x10>
f010547d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010547f:	5d                   	pop    %ebp
f0105480:	c3                   	ret    

f0105481 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105481:	55                   	push   %ebp
f0105482:	89 e5                	mov    %esp,%ebp
f0105484:	53                   	push   %ebx
f0105485:	8b 45 08             	mov    0x8(%ebp),%eax
f0105488:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010548b:	89 c2                	mov    %eax,%edx
f010548d:	83 c2 01             	add    $0x1,%edx
f0105490:	83 c1 01             	add    $0x1,%ecx
f0105493:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105497:	88 5a ff             	mov    %bl,-0x1(%edx)
f010549a:	84 db                	test   %bl,%bl
f010549c:	75 ef                	jne    f010548d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010549e:	5b                   	pop    %ebx
f010549f:	5d                   	pop    %ebp
f01054a0:	c3                   	ret    

f01054a1 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01054a1:	55                   	push   %ebp
f01054a2:	89 e5                	mov    %esp,%ebp
f01054a4:	53                   	push   %ebx
f01054a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01054a8:	53                   	push   %ebx
f01054a9:	e8 9a ff ff ff       	call   f0105448 <strlen>
f01054ae:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01054b1:	ff 75 0c             	pushl  0xc(%ebp)
f01054b4:	01 d8                	add    %ebx,%eax
f01054b6:	50                   	push   %eax
f01054b7:	e8 c5 ff ff ff       	call   f0105481 <strcpy>
	return dst;
}
f01054bc:	89 d8                	mov    %ebx,%eax
f01054be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01054c1:	c9                   	leave  
f01054c2:	c3                   	ret    

f01054c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01054c3:	55                   	push   %ebp
f01054c4:	89 e5                	mov    %esp,%ebp
f01054c6:	56                   	push   %esi
f01054c7:	53                   	push   %ebx
f01054c8:	8b 75 08             	mov    0x8(%ebp),%esi
f01054cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01054ce:	89 f3                	mov    %esi,%ebx
f01054d0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01054d3:	89 f2                	mov    %esi,%edx
f01054d5:	eb 0f                	jmp    f01054e6 <strncpy+0x23>
		*dst++ = *src;
f01054d7:	83 c2 01             	add    $0x1,%edx
f01054da:	0f b6 01             	movzbl (%ecx),%eax
f01054dd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01054e0:	80 39 01             	cmpb   $0x1,(%ecx)
f01054e3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01054e6:	39 da                	cmp    %ebx,%edx
f01054e8:	75 ed                	jne    f01054d7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01054ea:	89 f0                	mov    %esi,%eax
f01054ec:	5b                   	pop    %ebx
f01054ed:	5e                   	pop    %esi
f01054ee:	5d                   	pop    %ebp
f01054ef:	c3                   	ret    

f01054f0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01054f0:	55                   	push   %ebp
f01054f1:	89 e5                	mov    %esp,%ebp
f01054f3:	56                   	push   %esi
f01054f4:	53                   	push   %ebx
f01054f5:	8b 75 08             	mov    0x8(%ebp),%esi
f01054f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01054fb:	8b 55 10             	mov    0x10(%ebp),%edx
f01054fe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105500:	85 d2                	test   %edx,%edx
f0105502:	74 21                	je     f0105525 <strlcpy+0x35>
f0105504:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105508:	89 f2                	mov    %esi,%edx
f010550a:	eb 09                	jmp    f0105515 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010550c:	83 c2 01             	add    $0x1,%edx
f010550f:	83 c1 01             	add    $0x1,%ecx
f0105512:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105515:	39 c2                	cmp    %eax,%edx
f0105517:	74 09                	je     f0105522 <strlcpy+0x32>
f0105519:	0f b6 19             	movzbl (%ecx),%ebx
f010551c:	84 db                	test   %bl,%bl
f010551e:	75 ec                	jne    f010550c <strlcpy+0x1c>
f0105520:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105522:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105525:	29 f0                	sub    %esi,%eax
}
f0105527:	5b                   	pop    %ebx
f0105528:	5e                   	pop    %esi
f0105529:	5d                   	pop    %ebp
f010552a:	c3                   	ret    

f010552b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010552b:	55                   	push   %ebp
f010552c:	89 e5                	mov    %esp,%ebp
f010552e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105531:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105534:	eb 06                	jmp    f010553c <strcmp+0x11>
		p++, q++;
f0105536:	83 c1 01             	add    $0x1,%ecx
f0105539:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010553c:	0f b6 01             	movzbl (%ecx),%eax
f010553f:	84 c0                	test   %al,%al
f0105541:	74 04                	je     f0105547 <strcmp+0x1c>
f0105543:	3a 02                	cmp    (%edx),%al
f0105545:	74 ef                	je     f0105536 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105547:	0f b6 c0             	movzbl %al,%eax
f010554a:	0f b6 12             	movzbl (%edx),%edx
f010554d:	29 d0                	sub    %edx,%eax
}
f010554f:	5d                   	pop    %ebp
f0105550:	c3                   	ret    

f0105551 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105551:	55                   	push   %ebp
f0105552:	89 e5                	mov    %esp,%ebp
f0105554:	53                   	push   %ebx
f0105555:	8b 45 08             	mov    0x8(%ebp),%eax
f0105558:	8b 55 0c             	mov    0xc(%ebp),%edx
f010555b:	89 c3                	mov    %eax,%ebx
f010555d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105560:	eb 06                	jmp    f0105568 <strncmp+0x17>
		n--, p++, q++;
f0105562:	83 c0 01             	add    $0x1,%eax
f0105565:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105568:	39 d8                	cmp    %ebx,%eax
f010556a:	74 15                	je     f0105581 <strncmp+0x30>
f010556c:	0f b6 08             	movzbl (%eax),%ecx
f010556f:	84 c9                	test   %cl,%cl
f0105571:	74 04                	je     f0105577 <strncmp+0x26>
f0105573:	3a 0a                	cmp    (%edx),%cl
f0105575:	74 eb                	je     f0105562 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105577:	0f b6 00             	movzbl (%eax),%eax
f010557a:	0f b6 12             	movzbl (%edx),%edx
f010557d:	29 d0                	sub    %edx,%eax
f010557f:	eb 05                	jmp    f0105586 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105581:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105586:	5b                   	pop    %ebx
f0105587:	5d                   	pop    %ebp
f0105588:	c3                   	ret    

f0105589 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105589:	55                   	push   %ebp
f010558a:	89 e5                	mov    %esp,%ebp
f010558c:	8b 45 08             	mov    0x8(%ebp),%eax
f010558f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105593:	eb 07                	jmp    f010559c <strchr+0x13>
		if (*s == c)
f0105595:	38 ca                	cmp    %cl,%dl
f0105597:	74 0f                	je     f01055a8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105599:	83 c0 01             	add    $0x1,%eax
f010559c:	0f b6 10             	movzbl (%eax),%edx
f010559f:	84 d2                	test   %dl,%dl
f01055a1:	75 f2                	jne    f0105595 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01055a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01055a8:	5d                   	pop    %ebp
f01055a9:	c3                   	ret    

f01055aa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01055aa:	55                   	push   %ebp
f01055ab:	89 e5                	mov    %esp,%ebp
f01055ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01055b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01055b4:	eb 03                	jmp    f01055b9 <strfind+0xf>
f01055b6:	83 c0 01             	add    $0x1,%eax
f01055b9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01055bc:	38 ca                	cmp    %cl,%dl
f01055be:	74 04                	je     f01055c4 <strfind+0x1a>
f01055c0:	84 d2                	test   %dl,%dl
f01055c2:	75 f2                	jne    f01055b6 <strfind+0xc>
			break;
	return (char *) s;
}
f01055c4:	5d                   	pop    %ebp
f01055c5:	c3                   	ret    

f01055c6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01055c6:	55                   	push   %ebp
f01055c7:	89 e5                	mov    %esp,%ebp
f01055c9:	57                   	push   %edi
f01055ca:	56                   	push   %esi
f01055cb:	53                   	push   %ebx
f01055cc:	8b 7d 08             	mov    0x8(%ebp),%edi
f01055cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01055d2:	85 c9                	test   %ecx,%ecx
f01055d4:	74 36                	je     f010560c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01055d6:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01055dc:	75 28                	jne    f0105606 <memset+0x40>
f01055de:	f6 c1 03             	test   $0x3,%cl
f01055e1:	75 23                	jne    f0105606 <memset+0x40>
		c &= 0xFF;
f01055e3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01055e7:	89 d3                	mov    %edx,%ebx
f01055e9:	c1 e3 08             	shl    $0x8,%ebx
f01055ec:	89 d6                	mov    %edx,%esi
f01055ee:	c1 e6 18             	shl    $0x18,%esi
f01055f1:	89 d0                	mov    %edx,%eax
f01055f3:	c1 e0 10             	shl    $0x10,%eax
f01055f6:	09 f0                	or     %esi,%eax
f01055f8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01055fa:	89 d8                	mov    %ebx,%eax
f01055fc:	09 d0                	or     %edx,%eax
f01055fe:	c1 e9 02             	shr    $0x2,%ecx
f0105601:	fc                   	cld    
f0105602:	f3 ab                	rep stos %eax,%es:(%edi)
f0105604:	eb 06                	jmp    f010560c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105606:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105609:	fc                   	cld    
f010560a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010560c:	89 f8                	mov    %edi,%eax
f010560e:	5b                   	pop    %ebx
f010560f:	5e                   	pop    %esi
f0105610:	5f                   	pop    %edi
f0105611:	5d                   	pop    %ebp
f0105612:	c3                   	ret    

f0105613 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105613:	55                   	push   %ebp
f0105614:	89 e5                	mov    %esp,%ebp
f0105616:	57                   	push   %edi
f0105617:	56                   	push   %esi
f0105618:	8b 45 08             	mov    0x8(%ebp),%eax
f010561b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010561e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105621:	39 c6                	cmp    %eax,%esi
f0105623:	73 35                	jae    f010565a <memmove+0x47>
f0105625:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105628:	39 d0                	cmp    %edx,%eax
f010562a:	73 2e                	jae    f010565a <memmove+0x47>
		s += n;
		d += n;
f010562c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010562f:	89 d6                	mov    %edx,%esi
f0105631:	09 fe                	or     %edi,%esi
f0105633:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105639:	75 13                	jne    f010564e <memmove+0x3b>
f010563b:	f6 c1 03             	test   $0x3,%cl
f010563e:	75 0e                	jne    f010564e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105640:	83 ef 04             	sub    $0x4,%edi
f0105643:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105646:	c1 e9 02             	shr    $0x2,%ecx
f0105649:	fd                   	std    
f010564a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010564c:	eb 09                	jmp    f0105657 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010564e:	83 ef 01             	sub    $0x1,%edi
f0105651:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105654:	fd                   	std    
f0105655:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105657:	fc                   	cld    
f0105658:	eb 1d                	jmp    f0105677 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010565a:	89 f2                	mov    %esi,%edx
f010565c:	09 c2                	or     %eax,%edx
f010565e:	f6 c2 03             	test   $0x3,%dl
f0105661:	75 0f                	jne    f0105672 <memmove+0x5f>
f0105663:	f6 c1 03             	test   $0x3,%cl
f0105666:	75 0a                	jne    f0105672 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105668:	c1 e9 02             	shr    $0x2,%ecx
f010566b:	89 c7                	mov    %eax,%edi
f010566d:	fc                   	cld    
f010566e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105670:	eb 05                	jmp    f0105677 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105672:	89 c7                	mov    %eax,%edi
f0105674:	fc                   	cld    
f0105675:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105677:	5e                   	pop    %esi
f0105678:	5f                   	pop    %edi
f0105679:	5d                   	pop    %ebp
f010567a:	c3                   	ret    

f010567b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010567b:	55                   	push   %ebp
f010567c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010567e:	ff 75 10             	pushl  0x10(%ebp)
f0105681:	ff 75 0c             	pushl  0xc(%ebp)
f0105684:	ff 75 08             	pushl  0x8(%ebp)
f0105687:	e8 87 ff ff ff       	call   f0105613 <memmove>
}
f010568c:	c9                   	leave  
f010568d:	c3                   	ret    

f010568e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010568e:	55                   	push   %ebp
f010568f:	89 e5                	mov    %esp,%ebp
f0105691:	56                   	push   %esi
f0105692:	53                   	push   %ebx
f0105693:	8b 45 08             	mov    0x8(%ebp),%eax
f0105696:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105699:	89 c6                	mov    %eax,%esi
f010569b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010569e:	eb 1a                	jmp    f01056ba <memcmp+0x2c>
		if (*s1 != *s2)
f01056a0:	0f b6 08             	movzbl (%eax),%ecx
f01056a3:	0f b6 1a             	movzbl (%edx),%ebx
f01056a6:	38 d9                	cmp    %bl,%cl
f01056a8:	74 0a                	je     f01056b4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01056aa:	0f b6 c1             	movzbl %cl,%eax
f01056ad:	0f b6 db             	movzbl %bl,%ebx
f01056b0:	29 d8                	sub    %ebx,%eax
f01056b2:	eb 0f                	jmp    f01056c3 <memcmp+0x35>
		s1++, s2++;
f01056b4:	83 c0 01             	add    $0x1,%eax
f01056b7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056ba:	39 f0                	cmp    %esi,%eax
f01056bc:	75 e2                	jne    f01056a0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01056be:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01056c3:	5b                   	pop    %ebx
f01056c4:	5e                   	pop    %esi
f01056c5:	5d                   	pop    %ebp
f01056c6:	c3                   	ret    

f01056c7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01056c7:	55                   	push   %ebp
f01056c8:	89 e5                	mov    %esp,%ebp
f01056ca:	53                   	push   %ebx
f01056cb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01056ce:	89 c1                	mov    %eax,%ecx
f01056d0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01056d3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01056d7:	eb 0a                	jmp    f01056e3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01056d9:	0f b6 10             	movzbl (%eax),%edx
f01056dc:	39 da                	cmp    %ebx,%edx
f01056de:	74 07                	je     f01056e7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01056e0:	83 c0 01             	add    $0x1,%eax
f01056e3:	39 c8                	cmp    %ecx,%eax
f01056e5:	72 f2                	jb     f01056d9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01056e7:	5b                   	pop    %ebx
f01056e8:	5d                   	pop    %ebp
f01056e9:	c3                   	ret    

f01056ea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01056ea:	55                   	push   %ebp
f01056eb:	89 e5                	mov    %esp,%ebp
f01056ed:	57                   	push   %edi
f01056ee:	56                   	push   %esi
f01056ef:	53                   	push   %ebx
f01056f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01056f6:	eb 03                	jmp    f01056fb <strtol+0x11>
		s++;
f01056f8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01056fb:	0f b6 01             	movzbl (%ecx),%eax
f01056fe:	3c 20                	cmp    $0x20,%al
f0105700:	74 f6                	je     f01056f8 <strtol+0xe>
f0105702:	3c 09                	cmp    $0x9,%al
f0105704:	74 f2                	je     f01056f8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105706:	3c 2b                	cmp    $0x2b,%al
f0105708:	75 0a                	jne    f0105714 <strtol+0x2a>
		s++;
f010570a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010570d:	bf 00 00 00 00       	mov    $0x0,%edi
f0105712:	eb 11                	jmp    f0105725 <strtol+0x3b>
f0105714:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105719:	3c 2d                	cmp    $0x2d,%al
f010571b:	75 08                	jne    f0105725 <strtol+0x3b>
		s++, neg = 1;
f010571d:	83 c1 01             	add    $0x1,%ecx
f0105720:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105725:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010572b:	75 15                	jne    f0105742 <strtol+0x58>
f010572d:	80 39 30             	cmpb   $0x30,(%ecx)
f0105730:	75 10                	jne    f0105742 <strtol+0x58>
f0105732:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105736:	75 7c                	jne    f01057b4 <strtol+0xca>
		s += 2, base = 16;
f0105738:	83 c1 02             	add    $0x2,%ecx
f010573b:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105740:	eb 16                	jmp    f0105758 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105742:	85 db                	test   %ebx,%ebx
f0105744:	75 12                	jne    f0105758 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105746:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010574b:	80 39 30             	cmpb   $0x30,(%ecx)
f010574e:	75 08                	jne    f0105758 <strtol+0x6e>
		s++, base = 8;
f0105750:	83 c1 01             	add    $0x1,%ecx
f0105753:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105758:	b8 00 00 00 00       	mov    $0x0,%eax
f010575d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105760:	0f b6 11             	movzbl (%ecx),%edx
f0105763:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105766:	89 f3                	mov    %esi,%ebx
f0105768:	80 fb 09             	cmp    $0x9,%bl
f010576b:	77 08                	ja     f0105775 <strtol+0x8b>
			dig = *s - '0';
f010576d:	0f be d2             	movsbl %dl,%edx
f0105770:	83 ea 30             	sub    $0x30,%edx
f0105773:	eb 22                	jmp    f0105797 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105775:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105778:	89 f3                	mov    %esi,%ebx
f010577a:	80 fb 19             	cmp    $0x19,%bl
f010577d:	77 08                	ja     f0105787 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010577f:	0f be d2             	movsbl %dl,%edx
f0105782:	83 ea 57             	sub    $0x57,%edx
f0105785:	eb 10                	jmp    f0105797 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105787:	8d 72 bf             	lea    -0x41(%edx),%esi
f010578a:	89 f3                	mov    %esi,%ebx
f010578c:	80 fb 19             	cmp    $0x19,%bl
f010578f:	77 16                	ja     f01057a7 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105791:	0f be d2             	movsbl %dl,%edx
f0105794:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105797:	3b 55 10             	cmp    0x10(%ebp),%edx
f010579a:	7d 0b                	jge    f01057a7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010579c:	83 c1 01             	add    $0x1,%ecx
f010579f:	0f af 45 10          	imul   0x10(%ebp),%eax
f01057a3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01057a5:	eb b9                	jmp    f0105760 <strtol+0x76>

	if (endptr)
f01057a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01057ab:	74 0d                	je     f01057ba <strtol+0xd0>
		*endptr = (char *) s;
f01057ad:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057b0:	89 0e                	mov    %ecx,(%esi)
f01057b2:	eb 06                	jmp    f01057ba <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01057b4:	85 db                	test   %ebx,%ebx
f01057b6:	74 98                	je     f0105750 <strtol+0x66>
f01057b8:	eb 9e                	jmp    f0105758 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01057ba:	89 c2                	mov    %eax,%edx
f01057bc:	f7 da                	neg    %edx
f01057be:	85 ff                	test   %edi,%edi
f01057c0:	0f 45 c2             	cmovne %edx,%eax
}
f01057c3:	5b                   	pop    %ebx
f01057c4:	5e                   	pop    %esi
f01057c5:	5f                   	pop    %edi
f01057c6:	5d                   	pop    %ebp
f01057c7:	c3                   	ret    

f01057c8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01057c8:	fa                   	cli    

	xorw    %ax, %ax
f01057c9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01057cb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01057cd:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01057cf:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01057d1:	0f 01 16             	lgdtl  (%esi)
f01057d4:	74 70                	je     f0105846 <mpsearch1+0x3>
	movl    %cr0, %eax
f01057d6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01057d9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01057dd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01057e0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01057e6:	08 00                	or     %al,(%eax)

f01057e8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01057e8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01057ec:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01057ee:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01057f0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01057f2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01057f6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01057f8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01057fa:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f01057ff:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105802:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105805:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010580a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010580d:	8b 25 84 fe 20 f0    	mov    0xf020fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105813:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105818:	b8 b0 01 10 f0       	mov    $0xf01001b0,%eax
	call    *%eax
f010581d:	ff d0                	call   *%eax

f010581f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010581f:	eb fe                	jmp    f010581f <spin>
f0105821:	8d 76 00             	lea    0x0(%esi),%esi

f0105824 <gdt>:
	...
f010582c:	ff                   	(bad)  
f010582d:	ff 00                	incl   (%eax)
f010582f:	00 00                	add    %al,(%eax)
f0105831:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105838:	00                   	.byte 0x0
f0105839:	92                   	xchg   %eax,%edx
f010583a:	cf                   	iret   
	...

f010583c <gdtdesc>:
f010583c:	17                   	pop    %ss
f010583d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105842 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105842:	90                   	nop

f0105843 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105843:	55                   	push   %ebp
f0105844:	89 e5                	mov    %esp,%ebp
f0105846:	57                   	push   %edi
f0105847:	56                   	push   %esi
f0105848:	53                   	push   %ebx
f0105849:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010584c:	8b 0d 88 fe 20 f0    	mov    0xf020fe88,%ecx
f0105852:	89 c3                	mov    %eax,%ebx
f0105854:	c1 eb 0c             	shr    $0xc,%ebx
f0105857:	39 cb                	cmp    %ecx,%ebx
f0105859:	72 12                	jb     f010586d <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010585b:	50                   	push   %eax
f010585c:	68 a4 62 10 f0       	push   $0xf01062a4
f0105861:	6a 57                	push   $0x57
f0105863:	68 bd 7f 10 f0       	push   $0xf0107fbd
f0105868:	e8 d3 a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010586d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105873:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105875:	89 c2                	mov    %eax,%edx
f0105877:	c1 ea 0c             	shr    $0xc,%edx
f010587a:	39 ca                	cmp    %ecx,%edx
f010587c:	72 12                	jb     f0105890 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010587e:	50                   	push   %eax
f010587f:	68 a4 62 10 f0       	push   $0xf01062a4
f0105884:	6a 57                	push   $0x57
f0105886:	68 bd 7f 10 f0       	push   $0xf0107fbd
f010588b:	e8 b0 a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105890:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105896:	eb 2f                	jmp    f01058c7 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105898:	83 ec 04             	sub    $0x4,%esp
f010589b:	6a 04                	push   $0x4
f010589d:	68 cd 7f 10 f0       	push   $0xf0107fcd
f01058a2:	53                   	push   %ebx
f01058a3:	e8 e6 fd ff ff       	call   f010568e <memcmp>
f01058a8:	83 c4 10             	add    $0x10,%esp
f01058ab:	85 c0                	test   %eax,%eax
f01058ad:	75 15                	jne    f01058c4 <mpsearch1+0x81>
f01058af:	89 da                	mov    %ebx,%edx
f01058b1:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01058b4:	0f b6 0a             	movzbl (%edx),%ecx
f01058b7:	01 c8                	add    %ecx,%eax
f01058b9:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01058bc:	39 d7                	cmp    %edx,%edi
f01058be:	75 f4                	jne    f01058b4 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01058c0:	84 c0                	test   %al,%al
f01058c2:	74 0e                	je     f01058d2 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01058c4:	83 c3 10             	add    $0x10,%ebx
f01058c7:	39 f3                	cmp    %esi,%ebx
f01058c9:	72 cd                	jb     f0105898 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01058cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01058d0:	eb 02                	jmp    f01058d4 <mpsearch1+0x91>
f01058d2:	89 d8                	mov    %ebx,%eax
}
f01058d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058d7:	5b                   	pop    %ebx
f01058d8:	5e                   	pop    %esi
f01058d9:	5f                   	pop    %edi
f01058da:	5d                   	pop    %ebp
f01058db:	c3                   	ret    

f01058dc <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01058dc:	55                   	push   %ebp
f01058dd:	89 e5                	mov    %esp,%ebp
f01058df:	57                   	push   %edi
f01058e0:	56                   	push   %esi
f01058e1:	53                   	push   %ebx
f01058e2:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01058e5:	c7 05 c0 03 21 f0 20 	movl   $0xf0210020,0xf02103c0
f01058ec:	00 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01058ef:	83 3d 88 fe 20 f0 00 	cmpl   $0x0,0xf020fe88
f01058f6:	75 16                	jne    f010590e <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01058f8:	68 00 04 00 00       	push   $0x400
f01058fd:	68 a4 62 10 f0       	push   $0xf01062a4
f0105902:	6a 6f                	push   $0x6f
f0105904:	68 bd 7f 10 f0       	push   $0xf0107fbd
f0105909:	e8 32 a7 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010590e:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105915:	85 c0                	test   %eax,%eax
f0105917:	74 16                	je     f010592f <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105919:	c1 e0 04             	shl    $0x4,%eax
f010591c:	ba 00 04 00 00       	mov    $0x400,%edx
f0105921:	e8 1d ff ff ff       	call   f0105843 <mpsearch1>
f0105926:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105929:	85 c0                	test   %eax,%eax
f010592b:	75 3c                	jne    f0105969 <mp_init+0x8d>
f010592d:	eb 20                	jmp    f010594f <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010592f:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105936:	c1 e0 0a             	shl    $0xa,%eax
f0105939:	2d 00 04 00 00       	sub    $0x400,%eax
f010593e:	ba 00 04 00 00       	mov    $0x400,%edx
f0105943:	e8 fb fe ff ff       	call   f0105843 <mpsearch1>
f0105948:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010594b:	85 c0                	test   %eax,%eax
f010594d:	75 1a                	jne    f0105969 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010594f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105954:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105959:	e8 e5 fe ff ff       	call   f0105843 <mpsearch1>
f010595e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105961:	85 c0                	test   %eax,%eax
f0105963:	0f 84 5d 02 00 00    	je     f0105bc6 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105969:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010596c:	8b 70 04             	mov    0x4(%eax),%esi
f010596f:	85 f6                	test   %esi,%esi
f0105971:	74 06                	je     f0105979 <mp_init+0x9d>
f0105973:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105977:	74 15                	je     f010598e <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105979:	83 ec 0c             	sub    $0xc,%esp
f010597c:	68 30 7e 10 f0       	push   $0xf0107e30
f0105981:	e8 e6 de ff ff       	call   f010386c <cprintf>
f0105986:	83 c4 10             	add    $0x10,%esp
f0105989:	e9 38 02 00 00       	jmp    f0105bc6 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010598e:	89 f0                	mov    %esi,%eax
f0105990:	c1 e8 0c             	shr    $0xc,%eax
f0105993:	3b 05 88 fe 20 f0    	cmp    0xf020fe88,%eax
f0105999:	72 15                	jb     f01059b0 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010599b:	56                   	push   %esi
f010599c:	68 a4 62 10 f0       	push   $0xf01062a4
f01059a1:	68 90 00 00 00       	push   $0x90
f01059a6:	68 bd 7f 10 f0       	push   $0xf0107fbd
f01059ab:	e8 90 a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01059b0:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01059b6:	83 ec 04             	sub    $0x4,%esp
f01059b9:	6a 04                	push   $0x4
f01059bb:	68 d2 7f 10 f0       	push   $0xf0107fd2
f01059c0:	53                   	push   %ebx
f01059c1:	e8 c8 fc ff ff       	call   f010568e <memcmp>
f01059c6:	83 c4 10             	add    $0x10,%esp
f01059c9:	85 c0                	test   %eax,%eax
f01059cb:	74 15                	je     f01059e2 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01059cd:	83 ec 0c             	sub    $0xc,%esp
f01059d0:	68 60 7e 10 f0       	push   $0xf0107e60
f01059d5:	e8 92 de ff ff       	call   f010386c <cprintf>
f01059da:	83 c4 10             	add    $0x10,%esp
f01059dd:	e9 e4 01 00 00       	jmp    f0105bc6 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01059e2:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01059e6:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01059ea:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01059ed:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01059f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01059f7:	eb 0d                	jmp    f0105a06 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f01059f9:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105a00:	f0 
f0105a01:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a03:	83 c0 01             	add    $0x1,%eax
f0105a06:	39 c7                	cmp    %eax,%edi
f0105a08:	75 ef                	jne    f01059f9 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105a0a:	84 d2                	test   %dl,%dl
f0105a0c:	74 15                	je     f0105a23 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105a0e:	83 ec 0c             	sub    $0xc,%esp
f0105a11:	68 94 7e 10 f0       	push   $0xf0107e94
f0105a16:	e8 51 de ff ff       	call   f010386c <cprintf>
f0105a1b:	83 c4 10             	add    $0x10,%esp
f0105a1e:	e9 a3 01 00 00       	jmp    f0105bc6 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105a23:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105a27:	3c 01                	cmp    $0x1,%al
f0105a29:	74 1d                	je     f0105a48 <mp_init+0x16c>
f0105a2b:	3c 04                	cmp    $0x4,%al
f0105a2d:	74 19                	je     f0105a48 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105a2f:	83 ec 08             	sub    $0x8,%esp
f0105a32:	0f b6 c0             	movzbl %al,%eax
f0105a35:	50                   	push   %eax
f0105a36:	68 b8 7e 10 f0       	push   $0xf0107eb8
f0105a3b:	e8 2c de ff ff       	call   f010386c <cprintf>
f0105a40:	83 c4 10             	add    $0x10,%esp
f0105a43:	e9 7e 01 00 00       	jmp    f0105bc6 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a48:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105a4c:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a50:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105a55:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105a5a:	01 ce                	add    %ecx,%esi
f0105a5c:	eb 0d                	jmp    f0105a6b <mp_init+0x18f>
f0105a5e:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105a65:	f0 
f0105a66:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a68:	83 c0 01             	add    $0x1,%eax
f0105a6b:	39 c7                	cmp    %eax,%edi
f0105a6d:	75 ef                	jne    f0105a5e <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a6f:	89 d0                	mov    %edx,%eax
f0105a71:	02 43 2a             	add    0x2a(%ebx),%al
f0105a74:	74 15                	je     f0105a8b <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105a76:	83 ec 0c             	sub    $0xc,%esp
f0105a79:	68 d8 7e 10 f0       	push   $0xf0107ed8
f0105a7e:	e8 e9 dd ff ff       	call   f010386c <cprintf>
f0105a83:	83 c4 10             	add    $0x10,%esp
f0105a86:	e9 3b 01 00 00       	jmp    f0105bc6 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105a8b:	85 db                	test   %ebx,%ebx
f0105a8d:	0f 84 33 01 00 00    	je     f0105bc6 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105a93:	c7 05 00 00 21 f0 01 	movl   $0x1,0xf0210000
f0105a9a:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105a9d:	8b 43 24             	mov    0x24(%ebx),%eax
f0105aa0:	a3 00 10 25 f0       	mov    %eax,0xf0251000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105aa5:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105aa8:	be 00 00 00 00       	mov    $0x0,%esi
f0105aad:	e9 85 00 00 00       	jmp    f0105b37 <mp_init+0x25b>
		switch (*p) {
f0105ab2:	0f b6 07             	movzbl (%edi),%eax
f0105ab5:	84 c0                	test   %al,%al
f0105ab7:	74 06                	je     f0105abf <mp_init+0x1e3>
f0105ab9:	3c 04                	cmp    $0x4,%al
f0105abb:	77 55                	ja     f0105b12 <mp_init+0x236>
f0105abd:	eb 4e                	jmp    f0105b0d <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105abf:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105ac3:	74 11                	je     f0105ad6 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105ac5:	6b 05 c4 03 21 f0 74 	imul   $0x74,0xf02103c4,%eax
f0105acc:	05 20 00 21 f0       	add    $0xf0210020,%eax
f0105ad1:	a3 c0 03 21 f0       	mov    %eax,0xf02103c0
			if (ncpu < NCPU) {
f0105ad6:	a1 c4 03 21 f0       	mov    0xf02103c4,%eax
f0105adb:	83 f8 07             	cmp    $0x7,%eax
f0105ade:	7f 13                	jg     f0105af3 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105ae0:	6b d0 74             	imul   $0x74,%eax,%edx
f0105ae3:	88 82 20 00 21 f0    	mov    %al,-0xfdeffe0(%edx)
				ncpu++;
f0105ae9:	83 c0 01             	add    $0x1,%eax
f0105aec:	a3 c4 03 21 f0       	mov    %eax,0xf02103c4
f0105af1:	eb 15                	jmp    f0105b08 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105af3:	83 ec 08             	sub    $0x8,%esp
f0105af6:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105afa:	50                   	push   %eax
f0105afb:	68 08 7f 10 f0       	push   $0xf0107f08
f0105b00:	e8 67 dd ff ff       	call   f010386c <cprintf>
f0105b05:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105b08:	83 c7 14             	add    $0x14,%edi
			continue;
f0105b0b:	eb 27                	jmp    f0105b34 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105b0d:	83 c7 08             	add    $0x8,%edi
			continue;
f0105b10:	eb 22                	jmp    f0105b34 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105b12:	83 ec 08             	sub    $0x8,%esp
f0105b15:	0f b6 c0             	movzbl %al,%eax
f0105b18:	50                   	push   %eax
f0105b19:	68 30 7f 10 f0       	push   $0xf0107f30
f0105b1e:	e8 49 dd ff ff       	call   f010386c <cprintf>
			ismp = 0;
f0105b23:	c7 05 00 00 21 f0 00 	movl   $0x0,0xf0210000
f0105b2a:	00 00 00 
			i = conf->entry;
f0105b2d:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105b31:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105b34:	83 c6 01             	add    $0x1,%esi
f0105b37:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105b3b:	39 c6                	cmp    %eax,%esi
f0105b3d:	0f 82 6f ff ff ff    	jb     f0105ab2 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105b43:	a1 c0 03 21 f0       	mov    0xf02103c0,%eax
f0105b48:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105b4f:	83 3d 00 00 21 f0 00 	cmpl   $0x0,0xf0210000
f0105b56:	75 26                	jne    f0105b7e <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105b58:	c7 05 c4 03 21 f0 01 	movl   $0x1,0xf02103c4
f0105b5f:	00 00 00 
		lapicaddr = 0;
f0105b62:	c7 05 00 10 25 f0 00 	movl   $0x0,0xf0251000
f0105b69:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105b6c:	83 ec 0c             	sub    $0xc,%esp
f0105b6f:	68 50 7f 10 f0       	push   $0xf0107f50
f0105b74:	e8 f3 dc ff ff       	call   f010386c <cprintf>
		return;
f0105b79:	83 c4 10             	add    $0x10,%esp
f0105b7c:	eb 48                	jmp    f0105bc6 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105b7e:	83 ec 04             	sub    $0x4,%esp
f0105b81:	ff 35 c4 03 21 f0    	pushl  0xf02103c4
f0105b87:	0f b6 00             	movzbl (%eax),%eax
f0105b8a:	50                   	push   %eax
f0105b8b:	68 d7 7f 10 f0       	push   $0xf0107fd7
f0105b90:	e8 d7 dc ff ff       	call   f010386c <cprintf>

	if (mp->imcrp) {
f0105b95:	83 c4 10             	add    $0x10,%esp
f0105b98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b9b:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105b9f:	74 25                	je     f0105bc6 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105ba1:	83 ec 0c             	sub    $0xc,%esp
f0105ba4:	68 7c 7f 10 f0       	push   $0xf0107f7c
f0105ba9:	e8 be dc ff ff       	call   f010386c <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bae:	ba 22 00 00 00       	mov    $0x22,%edx
f0105bb3:	b8 70 00 00 00       	mov    $0x70,%eax
f0105bb8:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105bb9:	ba 23 00 00 00       	mov    $0x23,%edx
f0105bbe:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bbf:	83 c8 01             	or     $0x1,%eax
f0105bc2:	ee                   	out    %al,(%dx)
f0105bc3:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105bc9:	5b                   	pop    %ebx
f0105bca:	5e                   	pop    %esi
f0105bcb:	5f                   	pop    %edi
f0105bcc:	5d                   	pop    %ebp
f0105bcd:	c3                   	ret    

f0105bce <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105bce:	55                   	push   %ebp
f0105bcf:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105bd1:	8b 0d 04 10 25 f0    	mov    0xf0251004,%ecx
f0105bd7:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105bda:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105bdc:	a1 04 10 25 f0       	mov    0xf0251004,%eax
f0105be1:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105be4:	5d                   	pop    %ebp
f0105be5:	c3                   	ret    

f0105be6 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105be6:	55                   	push   %ebp
f0105be7:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105be9:	a1 04 10 25 f0       	mov    0xf0251004,%eax
f0105bee:	85 c0                	test   %eax,%eax
f0105bf0:	74 08                	je     f0105bfa <cpunum+0x14>
		return lapic[ID] >> 24;
f0105bf2:	8b 40 20             	mov    0x20(%eax),%eax
f0105bf5:	c1 e8 18             	shr    $0x18,%eax
f0105bf8:	eb 05                	jmp    f0105bff <cpunum+0x19>
	return 0;
f0105bfa:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105bff:	5d                   	pop    %ebp
f0105c00:	c3                   	ret    

f0105c01 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105c01:	a1 00 10 25 f0       	mov    0xf0251000,%eax
f0105c06:	85 c0                	test   %eax,%eax
f0105c08:	0f 84 21 01 00 00    	je     f0105d2f <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105c0e:	55                   	push   %ebp
f0105c0f:	89 e5                	mov    %esp,%ebp
f0105c11:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105c14:	68 00 10 00 00       	push   $0x1000
f0105c19:	50                   	push   %eax
f0105c1a:	e8 2e b8 ff ff       	call   f010144d <mmio_map_region>
f0105c1f:	a3 04 10 25 f0       	mov    %eax,0xf0251004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105c24:	ba 27 01 00 00       	mov    $0x127,%edx
f0105c29:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105c2e:	e8 9b ff ff ff       	call   f0105bce <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105c33:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105c38:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105c3d:	e8 8c ff ff ff       	call   f0105bce <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105c42:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105c47:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105c4c:	e8 7d ff ff ff       	call   f0105bce <lapicw>
	lapicw(TICR, 10000000); 
f0105c51:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105c56:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105c5b:	e8 6e ff ff ff       	call   f0105bce <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105c60:	e8 81 ff ff ff       	call   f0105be6 <cpunum>
f0105c65:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c68:	05 20 00 21 f0       	add    $0xf0210020,%eax
f0105c6d:	83 c4 10             	add    $0x10,%esp
f0105c70:	39 05 c0 03 21 f0    	cmp    %eax,0xf02103c0
f0105c76:	74 0f                	je     f0105c87 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105c78:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c7d:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105c82:	e8 47 ff ff ff       	call   f0105bce <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105c87:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c8c:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105c91:	e8 38 ff ff ff       	call   f0105bce <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105c96:	a1 04 10 25 f0       	mov    0xf0251004,%eax
f0105c9b:	8b 40 30             	mov    0x30(%eax),%eax
f0105c9e:	c1 e8 10             	shr    $0x10,%eax
f0105ca1:	3c 03                	cmp    $0x3,%al
f0105ca3:	76 0f                	jbe    f0105cb4 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105ca5:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105caa:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105caf:	e8 1a ff ff ff       	call   f0105bce <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105cb4:	ba 33 00 00 00       	mov    $0x33,%edx
f0105cb9:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105cbe:	e8 0b ff ff ff       	call   f0105bce <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105cc3:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cc8:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ccd:	e8 fc fe ff ff       	call   f0105bce <lapicw>
	lapicw(ESR, 0);
f0105cd2:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cd7:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105cdc:	e8 ed fe ff ff       	call   f0105bce <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105ce1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ce6:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105ceb:	e8 de fe ff ff       	call   f0105bce <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105cf0:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cf5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105cfa:	e8 cf fe ff ff       	call   f0105bce <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105cff:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105d04:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d09:	e8 c0 fe ff ff       	call   f0105bce <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105d0e:	8b 15 04 10 25 f0    	mov    0xf0251004,%edx
f0105d14:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105d1a:	f6 c4 10             	test   $0x10,%ah
f0105d1d:	75 f5                	jne    f0105d14 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105d1f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d24:	b8 20 00 00 00       	mov    $0x20,%eax
f0105d29:	e8 a0 fe ff ff       	call   f0105bce <lapicw>
}
f0105d2e:	c9                   	leave  
f0105d2f:	f3 c3                	repz ret 

f0105d31 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105d31:	83 3d 04 10 25 f0 00 	cmpl   $0x0,0xf0251004
f0105d38:	74 13                	je     f0105d4d <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105d3a:	55                   	push   %ebp
f0105d3b:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105d3d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d42:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d47:	e8 82 fe ff ff       	call   f0105bce <lapicw>
}
f0105d4c:	5d                   	pop    %ebp
f0105d4d:	f3 c3                	repz ret 

f0105d4f <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105d4f:	55                   	push   %ebp
f0105d50:	89 e5                	mov    %esp,%ebp
f0105d52:	56                   	push   %esi
f0105d53:	53                   	push   %ebx
f0105d54:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105d5a:	ba 70 00 00 00       	mov    $0x70,%edx
f0105d5f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105d64:	ee                   	out    %al,(%dx)
f0105d65:	ba 71 00 00 00       	mov    $0x71,%edx
f0105d6a:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105d6f:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d70:	83 3d 88 fe 20 f0 00 	cmpl   $0x0,0xf020fe88
f0105d77:	75 19                	jne    f0105d92 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d79:	68 67 04 00 00       	push   $0x467
f0105d7e:	68 a4 62 10 f0       	push   $0xf01062a4
f0105d83:	68 98 00 00 00       	push   $0x98
f0105d88:	68 f4 7f 10 f0       	push   $0xf0107ff4
f0105d8d:	e8 ae a2 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105d92:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105d99:	00 00 
	wrv[1] = addr >> 4;
f0105d9b:	89 d8                	mov    %ebx,%eax
f0105d9d:	c1 e8 04             	shr    $0x4,%eax
f0105da0:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105da6:	c1 e6 18             	shl    $0x18,%esi
f0105da9:	89 f2                	mov    %esi,%edx
f0105dab:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105db0:	e8 19 fe ff ff       	call   f0105bce <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105db5:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105dba:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105dbf:	e8 0a fe ff ff       	call   f0105bce <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105dc4:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105dc9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105dce:	e8 fb fd ff ff       	call   f0105bce <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105dd3:	c1 eb 0c             	shr    $0xc,%ebx
f0105dd6:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105dd9:	89 f2                	mov    %esi,%edx
f0105ddb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105de0:	e8 e9 fd ff ff       	call   f0105bce <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105de5:	89 da                	mov    %ebx,%edx
f0105de7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105dec:	e8 dd fd ff ff       	call   f0105bce <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105df1:	89 f2                	mov    %esi,%edx
f0105df3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105df8:	e8 d1 fd ff ff       	call   f0105bce <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105dfd:	89 da                	mov    %ebx,%edx
f0105dff:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e04:	e8 c5 fd ff ff       	call   f0105bce <lapicw>
		microdelay(200);
	}
}
f0105e09:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e0c:	5b                   	pop    %ebx
f0105e0d:	5e                   	pop    %esi
f0105e0e:	5d                   	pop    %ebp
f0105e0f:	c3                   	ret    

f0105e10 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105e10:	55                   	push   %ebp
f0105e11:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105e13:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e16:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105e1c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e21:	e8 a8 fd ff ff       	call   f0105bce <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105e26:	8b 15 04 10 25 f0    	mov    0xf0251004,%edx
f0105e2c:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e32:	f6 c4 10             	test   $0x10,%ah
f0105e35:	75 f5                	jne    f0105e2c <lapic_ipi+0x1c>
		;
}
f0105e37:	5d                   	pop    %ebp
f0105e38:	c3                   	ret    

f0105e39 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105e39:	55                   	push   %ebp
f0105e3a:	89 e5                	mov    %esp,%ebp
f0105e3c:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105e3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105e45:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e48:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105e4b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105e52:	5d                   	pop    %ebp
f0105e53:	c3                   	ret    

f0105e54 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105e54:	55                   	push   %ebp
f0105e55:	89 e5                	mov    %esp,%ebp
f0105e57:	56                   	push   %esi
f0105e58:	53                   	push   %ebx
f0105e59:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105e5c:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105e5f:	74 14                	je     f0105e75 <spin_lock+0x21>
f0105e61:	8b 73 08             	mov    0x8(%ebx),%esi
f0105e64:	e8 7d fd ff ff       	call   f0105be6 <cpunum>
f0105e69:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e6c:	05 20 00 21 f0       	add    $0xf0210020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105e71:	39 c6                	cmp    %eax,%esi
f0105e73:	74 07                	je     f0105e7c <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105e75:	ba 01 00 00 00       	mov    $0x1,%edx
f0105e7a:	eb 20                	jmp    f0105e9c <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105e7c:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105e7f:	e8 62 fd ff ff       	call   f0105be6 <cpunum>
f0105e84:	83 ec 0c             	sub    $0xc,%esp
f0105e87:	53                   	push   %ebx
f0105e88:	50                   	push   %eax
f0105e89:	68 04 80 10 f0       	push   $0xf0108004
f0105e8e:	6a 41                	push   $0x41
f0105e90:	68 68 80 10 f0       	push   $0xf0108068
f0105e95:	e8 a6 a1 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105e9a:	f3 90                	pause  
f0105e9c:	89 d0                	mov    %edx,%eax
f0105e9e:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105ea1:	85 c0                	test   %eax,%eax
f0105ea3:	75 f5                	jne    f0105e9a <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105ea5:	e8 3c fd ff ff       	call   f0105be6 <cpunum>
f0105eaa:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ead:	05 20 00 21 f0       	add    $0xf0210020,%eax
f0105eb2:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105eb5:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105eb8:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105eba:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ebf:	eb 0b                	jmp    f0105ecc <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105ec1:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105ec4:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105ec7:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105ec9:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105ecc:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105ed2:	76 11                	jbe    f0105ee5 <spin_lock+0x91>
f0105ed4:	83 f8 09             	cmp    $0x9,%eax
f0105ed7:	7e e8                	jle    f0105ec1 <spin_lock+0x6d>
f0105ed9:	eb 0a                	jmp    f0105ee5 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105edb:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105ee2:	83 c0 01             	add    $0x1,%eax
f0105ee5:	83 f8 09             	cmp    $0x9,%eax
f0105ee8:	7e f1                	jle    f0105edb <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105eea:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105eed:	5b                   	pop    %ebx
f0105eee:	5e                   	pop    %esi
f0105eef:	5d                   	pop    %ebp
f0105ef0:	c3                   	ret    

f0105ef1 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105ef1:	55                   	push   %ebp
f0105ef2:	89 e5                	mov    %esp,%ebp
f0105ef4:	57                   	push   %edi
f0105ef5:	56                   	push   %esi
f0105ef6:	53                   	push   %ebx
f0105ef7:	83 ec 4c             	sub    $0x4c,%esp
f0105efa:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105efd:	83 3e 00             	cmpl   $0x0,(%esi)
f0105f00:	74 18                	je     f0105f1a <spin_unlock+0x29>
f0105f02:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105f05:	e8 dc fc ff ff       	call   f0105be6 <cpunum>
f0105f0a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f0d:	05 20 00 21 f0       	add    $0xf0210020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105f12:	39 c3                	cmp    %eax,%ebx
f0105f14:	0f 84 a5 00 00 00    	je     f0105fbf <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105f1a:	83 ec 04             	sub    $0x4,%esp
f0105f1d:	6a 28                	push   $0x28
f0105f1f:	8d 46 0c             	lea    0xc(%esi),%eax
f0105f22:	50                   	push   %eax
f0105f23:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105f26:	53                   	push   %ebx
f0105f27:	e8 e7 f6 ff ff       	call   f0105613 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105f2c:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105f2f:	0f b6 38             	movzbl (%eax),%edi
f0105f32:	8b 76 04             	mov    0x4(%esi),%esi
f0105f35:	e8 ac fc ff ff       	call   f0105be6 <cpunum>
f0105f3a:	57                   	push   %edi
f0105f3b:	56                   	push   %esi
f0105f3c:	50                   	push   %eax
f0105f3d:	68 30 80 10 f0       	push   $0xf0108030
f0105f42:	e8 25 d9 ff ff       	call   f010386c <cprintf>
f0105f47:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105f4a:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105f4d:	eb 54                	jmp    f0105fa3 <spin_unlock+0xb2>
f0105f4f:	83 ec 08             	sub    $0x8,%esp
f0105f52:	57                   	push   %edi
f0105f53:	50                   	push   %eax
f0105f54:	e8 db eb ff ff       	call   f0104b34 <debuginfo_eip>
f0105f59:	83 c4 10             	add    $0x10,%esp
f0105f5c:	85 c0                	test   %eax,%eax
f0105f5e:	78 27                	js     f0105f87 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105f60:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105f62:	83 ec 04             	sub    $0x4,%esp
f0105f65:	89 c2                	mov    %eax,%edx
f0105f67:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105f6a:	52                   	push   %edx
f0105f6b:	ff 75 b0             	pushl  -0x50(%ebp)
f0105f6e:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105f71:	ff 75 ac             	pushl  -0x54(%ebp)
f0105f74:	ff 75 a8             	pushl  -0x58(%ebp)
f0105f77:	50                   	push   %eax
f0105f78:	68 78 80 10 f0       	push   $0xf0108078
f0105f7d:	e8 ea d8 ff ff       	call   f010386c <cprintf>
f0105f82:	83 c4 20             	add    $0x20,%esp
f0105f85:	eb 12                	jmp    f0105f99 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105f87:	83 ec 08             	sub    $0x8,%esp
f0105f8a:	ff 36                	pushl  (%esi)
f0105f8c:	68 8f 80 10 f0       	push   $0xf010808f
f0105f91:	e8 d6 d8 ff ff       	call   f010386c <cprintf>
f0105f96:	83 c4 10             	add    $0x10,%esp
f0105f99:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105f9c:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105f9f:	39 c3                	cmp    %eax,%ebx
f0105fa1:	74 08                	je     f0105fab <spin_unlock+0xba>
f0105fa3:	89 de                	mov    %ebx,%esi
f0105fa5:	8b 03                	mov    (%ebx),%eax
f0105fa7:	85 c0                	test   %eax,%eax
f0105fa9:	75 a4                	jne    f0105f4f <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105fab:	83 ec 04             	sub    $0x4,%esp
f0105fae:	68 97 80 10 f0       	push   $0xf0108097
f0105fb3:	6a 67                	push   $0x67
f0105fb5:	68 68 80 10 f0       	push   $0xf0108068
f0105fba:	e8 81 a0 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105fbf:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105fc6:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105fcd:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fd2:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105fd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105fd8:	5b                   	pop    %ebx
f0105fd9:	5e                   	pop    %esi
f0105fda:	5f                   	pop    %edi
f0105fdb:	5d                   	pop    %ebp
f0105fdc:	c3                   	ret    
f0105fdd:	66 90                	xchg   %ax,%ax
f0105fdf:	90                   	nop

f0105fe0 <__udivdi3>:
f0105fe0:	55                   	push   %ebp
f0105fe1:	57                   	push   %edi
f0105fe2:	56                   	push   %esi
f0105fe3:	53                   	push   %ebx
f0105fe4:	83 ec 1c             	sub    $0x1c,%esp
f0105fe7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105feb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105fef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105ff7:	85 f6                	test   %esi,%esi
f0105ff9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105ffd:	89 ca                	mov    %ecx,%edx
f0105fff:	89 f8                	mov    %edi,%eax
f0106001:	75 3d                	jne    f0106040 <__udivdi3+0x60>
f0106003:	39 cf                	cmp    %ecx,%edi
f0106005:	0f 87 c5 00 00 00    	ja     f01060d0 <__udivdi3+0xf0>
f010600b:	85 ff                	test   %edi,%edi
f010600d:	89 fd                	mov    %edi,%ebp
f010600f:	75 0b                	jne    f010601c <__udivdi3+0x3c>
f0106011:	b8 01 00 00 00       	mov    $0x1,%eax
f0106016:	31 d2                	xor    %edx,%edx
f0106018:	f7 f7                	div    %edi
f010601a:	89 c5                	mov    %eax,%ebp
f010601c:	89 c8                	mov    %ecx,%eax
f010601e:	31 d2                	xor    %edx,%edx
f0106020:	f7 f5                	div    %ebp
f0106022:	89 c1                	mov    %eax,%ecx
f0106024:	89 d8                	mov    %ebx,%eax
f0106026:	89 cf                	mov    %ecx,%edi
f0106028:	f7 f5                	div    %ebp
f010602a:	89 c3                	mov    %eax,%ebx
f010602c:	89 d8                	mov    %ebx,%eax
f010602e:	89 fa                	mov    %edi,%edx
f0106030:	83 c4 1c             	add    $0x1c,%esp
f0106033:	5b                   	pop    %ebx
f0106034:	5e                   	pop    %esi
f0106035:	5f                   	pop    %edi
f0106036:	5d                   	pop    %ebp
f0106037:	c3                   	ret    
f0106038:	90                   	nop
f0106039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106040:	39 ce                	cmp    %ecx,%esi
f0106042:	77 74                	ja     f01060b8 <__udivdi3+0xd8>
f0106044:	0f bd fe             	bsr    %esi,%edi
f0106047:	83 f7 1f             	xor    $0x1f,%edi
f010604a:	0f 84 98 00 00 00    	je     f01060e8 <__udivdi3+0x108>
f0106050:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106055:	89 f9                	mov    %edi,%ecx
f0106057:	89 c5                	mov    %eax,%ebp
f0106059:	29 fb                	sub    %edi,%ebx
f010605b:	d3 e6                	shl    %cl,%esi
f010605d:	89 d9                	mov    %ebx,%ecx
f010605f:	d3 ed                	shr    %cl,%ebp
f0106061:	89 f9                	mov    %edi,%ecx
f0106063:	d3 e0                	shl    %cl,%eax
f0106065:	09 ee                	or     %ebp,%esi
f0106067:	89 d9                	mov    %ebx,%ecx
f0106069:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010606d:	89 d5                	mov    %edx,%ebp
f010606f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106073:	d3 ed                	shr    %cl,%ebp
f0106075:	89 f9                	mov    %edi,%ecx
f0106077:	d3 e2                	shl    %cl,%edx
f0106079:	89 d9                	mov    %ebx,%ecx
f010607b:	d3 e8                	shr    %cl,%eax
f010607d:	09 c2                	or     %eax,%edx
f010607f:	89 d0                	mov    %edx,%eax
f0106081:	89 ea                	mov    %ebp,%edx
f0106083:	f7 f6                	div    %esi
f0106085:	89 d5                	mov    %edx,%ebp
f0106087:	89 c3                	mov    %eax,%ebx
f0106089:	f7 64 24 0c          	mull   0xc(%esp)
f010608d:	39 d5                	cmp    %edx,%ebp
f010608f:	72 10                	jb     f01060a1 <__udivdi3+0xc1>
f0106091:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106095:	89 f9                	mov    %edi,%ecx
f0106097:	d3 e6                	shl    %cl,%esi
f0106099:	39 c6                	cmp    %eax,%esi
f010609b:	73 07                	jae    f01060a4 <__udivdi3+0xc4>
f010609d:	39 d5                	cmp    %edx,%ebp
f010609f:	75 03                	jne    f01060a4 <__udivdi3+0xc4>
f01060a1:	83 eb 01             	sub    $0x1,%ebx
f01060a4:	31 ff                	xor    %edi,%edi
f01060a6:	89 d8                	mov    %ebx,%eax
f01060a8:	89 fa                	mov    %edi,%edx
f01060aa:	83 c4 1c             	add    $0x1c,%esp
f01060ad:	5b                   	pop    %ebx
f01060ae:	5e                   	pop    %esi
f01060af:	5f                   	pop    %edi
f01060b0:	5d                   	pop    %ebp
f01060b1:	c3                   	ret    
f01060b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01060b8:	31 ff                	xor    %edi,%edi
f01060ba:	31 db                	xor    %ebx,%ebx
f01060bc:	89 d8                	mov    %ebx,%eax
f01060be:	89 fa                	mov    %edi,%edx
f01060c0:	83 c4 1c             	add    $0x1c,%esp
f01060c3:	5b                   	pop    %ebx
f01060c4:	5e                   	pop    %esi
f01060c5:	5f                   	pop    %edi
f01060c6:	5d                   	pop    %ebp
f01060c7:	c3                   	ret    
f01060c8:	90                   	nop
f01060c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01060d0:	89 d8                	mov    %ebx,%eax
f01060d2:	f7 f7                	div    %edi
f01060d4:	31 ff                	xor    %edi,%edi
f01060d6:	89 c3                	mov    %eax,%ebx
f01060d8:	89 d8                	mov    %ebx,%eax
f01060da:	89 fa                	mov    %edi,%edx
f01060dc:	83 c4 1c             	add    $0x1c,%esp
f01060df:	5b                   	pop    %ebx
f01060e0:	5e                   	pop    %esi
f01060e1:	5f                   	pop    %edi
f01060e2:	5d                   	pop    %ebp
f01060e3:	c3                   	ret    
f01060e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01060e8:	39 ce                	cmp    %ecx,%esi
f01060ea:	72 0c                	jb     f01060f8 <__udivdi3+0x118>
f01060ec:	31 db                	xor    %ebx,%ebx
f01060ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01060f2:	0f 87 34 ff ff ff    	ja     f010602c <__udivdi3+0x4c>
f01060f8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01060fd:	e9 2a ff ff ff       	jmp    f010602c <__udivdi3+0x4c>
f0106102:	66 90                	xchg   %ax,%ax
f0106104:	66 90                	xchg   %ax,%ax
f0106106:	66 90                	xchg   %ax,%ax
f0106108:	66 90                	xchg   %ax,%ax
f010610a:	66 90                	xchg   %ax,%ax
f010610c:	66 90                	xchg   %ax,%ax
f010610e:	66 90                	xchg   %ax,%ax

f0106110 <__umoddi3>:
f0106110:	55                   	push   %ebp
f0106111:	57                   	push   %edi
f0106112:	56                   	push   %esi
f0106113:	53                   	push   %ebx
f0106114:	83 ec 1c             	sub    $0x1c,%esp
f0106117:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010611b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010611f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106123:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106127:	85 d2                	test   %edx,%edx
f0106129:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010612d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106131:	89 f3                	mov    %esi,%ebx
f0106133:	89 3c 24             	mov    %edi,(%esp)
f0106136:	89 74 24 04          	mov    %esi,0x4(%esp)
f010613a:	75 1c                	jne    f0106158 <__umoddi3+0x48>
f010613c:	39 f7                	cmp    %esi,%edi
f010613e:	76 50                	jbe    f0106190 <__umoddi3+0x80>
f0106140:	89 c8                	mov    %ecx,%eax
f0106142:	89 f2                	mov    %esi,%edx
f0106144:	f7 f7                	div    %edi
f0106146:	89 d0                	mov    %edx,%eax
f0106148:	31 d2                	xor    %edx,%edx
f010614a:	83 c4 1c             	add    $0x1c,%esp
f010614d:	5b                   	pop    %ebx
f010614e:	5e                   	pop    %esi
f010614f:	5f                   	pop    %edi
f0106150:	5d                   	pop    %ebp
f0106151:	c3                   	ret    
f0106152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106158:	39 f2                	cmp    %esi,%edx
f010615a:	89 d0                	mov    %edx,%eax
f010615c:	77 52                	ja     f01061b0 <__umoddi3+0xa0>
f010615e:	0f bd ea             	bsr    %edx,%ebp
f0106161:	83 f5 1f             	xor    $0x1f,%ebp
f0106164:	75 5a                	jne    f01061c0 <__umoddi3+0xb0>
f0106166:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010616a:	0f 82 e0 00 00 00    	jb     f0106250 <__umoddi3+0x140>
f0106170:	39 0c 24             	cmp    %ecx,(%esp)
f0106173:	0f 86 d7 00 00 00    	jbe    f0106250 <__umoddi3+0x140>
f0106179:	8b 44 24 08          	mov    0x8(%esp),%eax
f010617d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106181:	83 c4 1c             	add    $0x1c,%esp
f0106184:	5b                   	pop    %ebx
f0106185:	5e                   	pop    %esi
f0106186:	5f                   	pop    %edi
f0106187:	5d                   	pop    %ebp
f0106188:	c3                   	ret    
f0106189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106190:	85 ff                	test   %edi,%edi
f0106192:	89 fd                	mov    %edi,%ebp
f0106194:	75 0b                	jne    f01061a1 <__umoddi3+0x91>
f0106196:	b8 01 00 00 00       	mov    $0x1,%eax
f010619b:	31 d2                	xor    %edx,%edx
f010619d:	f7 f7                	div    %edi
f010619f:	89 c5                	mov    %eax,%ebp
f01061a1:	89 f0                	mov    %esi,%eax
f01061a3:	31 d2                	xor    %edx,%edx
f01061a5:	f7 f5                	div    %ebp
f01061a7:	89 c8                	mov    %ecx,%eax
f01061a9:	f7 f5                	div    %ebp
f01061ab:	89 d0                	mov    %edx,%eax
f01061ad:	eb 99                	jmp    f0106148 <__umoddi3+0x38>
f01061af:	90                   	nop
f01061b0:	89 c8                	mov    %ecx,%eax
f01061b2:	89 f2                	mov    %esi,%edx
f01061b4:	83 c4 1c             	add    $0x1c,%esp
f01061b7:	5b                   	pop    %ebx
f01061b8:	5e                   	pop    %esi
f01061b9:	5f                   	pop    %edi
f01061ba:	5d                   	pop    %ebp
f01061bb:	c3                   	ret    
f01061bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01061c0:	8b 34 24             	mov    (%esp),%esi
f01061c3:	bf 20 00 00 00       	mov    $0x20,%edi
f01061c8:	89 e9                	mov    %ebp,%ecx
f01061ca:	29 ef                	sub    %ebp,%edi
f01061cc:	d3 e0                	shl    %cl,%eax
f01061ce:	89 f9                	mov    %edi,%ecx
f01061d0:	89 f2                	mov    %esi,%edx
f01061d2:	d3 ea                	shr    %cl,%edx
f01061d4:	89 e9                	mov    %ebp,%ecx
f01061d6:	09 c2                	or     %eax,%edx
f01061d8:	89 d8                	mov    %ebx,%eax
f01061da:	89 14 24             	mov    %edx,(%esp)
f01061dd:	89 f2                	mov    %esi,%edx
f01061df:	d3 e2                	shl    %cl,%edx
f01061e1:	89 f9                	mov    %edi,%ecx
f01061e3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01061e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01061eb:	d3 e8                	shr    %cl,%eax
f01061ed:	89 e9                	mov    %ebp,%ecx
f01061ef:	89 c6                	mov    %eax,%esi
f01061f1:	d3 e3                	shl    %cl,%ebx
f01061f3:	89 f9                	mov    %edi,%ecx
f01061f5:	89 d0                	mov    %edx,%eax
f01061f7:	d3 e8                	shr    %cl,%eax
f01061f9:	89 e9                	mov    %ebp,%ecx
f01061fb:	09 d8                	or     %ebx,%eax
f01061fd:	89 d3                	mov    %edx,%ebx
f01061ff:	89 f2                	mov    %esi,%edx
f0106201:	f7 34 24             	divl   (%esp)
f0106204:	89 d6                	mov    %edx,%esi
f0106206:	d3 e3                	shl    %cl,%ebx
f0106208:	f7 64 24 04          	mull   0x4(%esp)
f010620c:	39 d6                	cmp    %edx,%esi
f010620e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106212:	89 d1                	mov    %edx,%ecx
f0106214:	89 c3                	mov    %eax,%ebx
f0106216:	72 08                	jb     f0106220 <__umoddi3+0x110>
f0106218:	75 11                	jne    f010622b <__umoddi3+0x11b>
f010621a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010621e:	73 0b                	jae    f010622b <__umoddi3+0x11b>
f0106220:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106224:	1b 14 24             	sbb    (%esp),%edx
f0106227:	89 d1                	mov    %edx,%ecx
f0106229:	89 c3                	mov    %eax,%ebx
f010622b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010622f:	29 da                	sub    %ebx,%edx
f0106231:	19 ce                	sbb    %ecx,%esi
f0106233:	89 f9                	mov    %edi,%ecx
f0106235:	89 f0                	mov    %esi,%eax
f0106237:	d3 e0                	shl    %cl,%eax
f0106239:	89 e9                	mov    %ebp,%ecx
f010623b:	d3 ea                	shr    %cl,%edx
f010623d:	89 e9                	mov    %ebp,%ecx
f010623f:	d3 ee                	shr    %cl,%esi
f0106241:	09 d0                	or     %edx,%eax
f0106243:	89 f2                	mov    %esi,%edx
f0106245:	83 c4 1c             	add    $0x1c,%esp
f0106248:	5b                   	pop    %ebx
f0106249:	5e                   	pop    %esi
f010624a:	5f                   	pop    %edi
f010624b:	5d                   	pop    %ebp
f010624c:	c3                   	ret    
f010624d:	8d 76 00             	lea    0x0(%esi),%esi
f0106250:	29 f9                	sub    %edi,%ecx
f0106252:	19 d6                	sbb    %edx,%esi
f0106254:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010625c:	e9 18 ff ff ff       	jmp    f0106179 <__umoddi3+0x69>
