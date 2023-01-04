
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
f010005c:	e8 91 5b 00 00       	call   f0105bf2 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 80 62 10 f0       	push   $0xf0106280
f010006d:	e8 06 38 00 00       	call   f0103878 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 d6 37 00 00       	call   f0103852 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 60 6b 10 f0 	movl   $0xf0106b60,(%esp)
f0100083:	e8 f0 37 00 00       	call   f0103878 <cprintf>
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
f01000b3:	e8 c0 37 00 00       	call   f0103878 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000b8:	e8 f9 13 00 00       	call   f01014b6 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000bd:	e8 2d 30 00 00       	call   f01030ef <env_init>
	trap_init();
f01000c2:	e8 a4 38 00 00       	call   f010396b <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000c7:	e8 1c 58 00 00       	call   f01058e8 <mp_init>
	lapic_init();
f01000cc:	e8 3c 5b 00 00       	call   f0105c0d <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 c9 36 00 00       	call   f010379f <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000d6:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000dd:	e8 7e 5d 00 00       	call   f0105e60 <spin_lock>
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
f0100107:	b8 4e 58 10 f0       	mov    $0xf010584e,%eax
f010010c:	2d d4 57 10 f0       	sub    $0xf01057d4,%eax
f0100111:	50                   	push   %eax
f0100112:	68 d4 57 10 f0       	push   $0xf01057d4
f0100117:	68 00 70 00 f0       	push   $0xf0007000
f010011c:	e8 fe 54 00 00       	call   f010561f <memmove>
f0100121:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100124:	bb 20 00 21 f0       	mov    $0xf0210020,%ebx
f0100129:	eb 4d                	jmp    f0100178 <i386_init+0xde>
		if (c == cpus + cpunum())  // We've started already.
f010012b:	e8 c2 5a 00 00       	call   f0105bf2 <cpunum>
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
f0100165:	e8 f1 5b 00 00       	call   f0105d5b <lapic_startap>
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
f0100197:	83 c4 08             	add    $0x8,%esp
f010019a:	6a 00                	push   $0x0
f010019c:	68 d8 20 1c f0       	push   $0xf01c20d8
f01001a1:	e8 dc 30 00 00       	call   f0103282 <env_create>
	ENV_CREATE(user_icode, ENV_TYPE_USER);
	// ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001a6:	e8 35 04 00 00       	call   f01005e0 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001ab:	e8 ce 42 00 00       	call   f010447e <sched_yield>

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
f01001dc:	e8 11 5a 00 00       	call   f0105bf2 <cpunum>
f01001e1:	83 ec 08             	sub    $0x8,%esp
f01001e4:	50                   	push   %eax
f01001e5:	68 13 63 10 f0       	push   $0xf0106313
f01001ea:	e8 89 36 00 00       	call   f0103878 <cprintf>

	lapic_init();
f01001ef:	e8 19 5a 00 00       	call   f0105c0d <lapic_init>
	env_init_percpu();
f01001f4:	e8 c6 2e 00 00       	call   f01030bf <env_init_percpu>
	trap_init_percpu();
f01001f9:	e8 8e 36 00 00       	call   f010388c <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001fe:	e8 ef 59 00 00       	call   f0105bf2 <cpunum>
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
f010021c:	e8 3f 5c 00 00       	call   f0105e60 <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:

	lock_kernel();
	sched_yield();
f0100221:	e8 58 42 00 00       	call   f010447e <sched_yield>

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
f010023b:	e8 38 36 00 00       	call   f0103878 <cprintf>
	vcprintf(fmt, ap);
f0100240:	83 c4 08             	add    $0x8,%esp
f0100243:	53                   	push   %ebx
f0100244:	ff 75 10             	pushl  0x10(%ebp)
f0100247:	e8 06 36 00 00       	call   f0103852 <vcprintf>
	cprintf("\n");
f010024c:	c7 04 24 60 6b 10 f0 	movl   $0xf0106b60,(%esp)
f0100253:	e8 20 36 00 00       	call   f0103878 <cprintf>
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
f01003b1:	e8 c2 34 00 00       	call   f0103878 <cprintf>
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
f0100560:	e8 ba 50 00 00       	call   f010561f <memmove>
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
f01006d4:	e8 4e 30 00 00       	call   f0103727 <irq_setmask_8259A>
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
f0100759:	e8 c9 2f 00 00       	call   f0103727 <irq_setmask_8259A>
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
f0100772:	e8 01 31 00 00       	call   f0103878 <cprintf>
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
f01007c2:	e8 b1 30 00 00       	call   f0103878 <cprintf>
f01007c7:	83 c4 0c             	add    $0xc,%esp
f01007ca:	68 7c 66 10 f0       	push   $0xf010667c
f01007cf:	68 cc 65 10 f0       	push   $0xf01065cc
f01007d4:	68 c3 65 10 f0       	push   $0xf01065c3
f01007d9:	e8 9a 30 00 00       	call   f0103878 <cprintf>
f01007de:	83 c4 0c             	add    $0xc,%esp
f01007e1:	68 d5 65 10 f0       	push   $0xf01065d5
f01007e6:	68 f3 65 10 f0       	push   $0xf01065f3
f01007eb:	68 c3 65 10 f0       	push   $0xf01065c3
f01007f0:	e8 83 30 00 00       	call   f0103878 <cprintf>
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
f0100807:	e8 6c 30 00 00       	call   f0103878 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010080c:	83 c4 08             	add    $0x8,%esp
f010080f:	68 0c 00 10 00       	push   $0x10000c
f0100814:	68 a4 66 10 f0       	push   $0xf01066a4
f0100819:	e8 5a 30 00 00       	call   f0103878 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010081e:	83 c4 0c             	add    $0xc,%esp
f0100821:	68 0c 00 10 00       	push   $0x10000c
f0100826:	68 0c 00 10 f0       	push   $0xf010000c
f010082b:	68 cc 66 10 f0       	push   $0xf01066cc
f0100830:	e8 43 30 00 00       	call   f0103878 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	68 71 62 10 00       	push   $0x106271
f010083d:	68 71 62 10 f0       	push   $0xf0106271
f0100842:	68 f0 66 10 f0       	push   $0xf01066f0
f0100847:	e8 2c 30 00 00       	call   f0103878 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084c:	83 c4 0c             	add    $0xc,%esp
f010084f:	68 00 f0 20 00       	push   $0x20f000
f0100854:	68 00 f0 20 f0       	push   $0xf020f000
f0100859:	68 14 67 10 f0       	push   $0xf0106714
f010085e:	e8 15 30 00 00       	call   f0103878 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100863:	83 c4 0c             	add    $0xc,%esp
f0100866:	68 08 10 25 00       	push   $0x251008
f010086b:	68 08 10 25 f0       	push   $0xf0251008
f0100870:	68 38 67 10 f0       	push   $0xf0106738
f0100875:	e8 fe 2f 00 00       	call   f0103878 <cprintf>
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
f01008a0:	e8 d3 2f 00 00       	call   f0103878 <cprintf>
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
f01008df:	e8 94 2f 00 00       	call   f0103878 <cprintf>

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
f010090c:	e8 2f 42 00 00       	call   f0104b40 <debuginfo_eip>

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
f010096d:	e8 06 2f 00 00       	call   f0103878 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f0100972:	83 c4 14             	add    $0x14,%esp
f0100975:	2b 75 cc             	sub    -0x34(%ebp),%esi
f0100978:	56                   	push   %esi
f0100979:	8d 45 8a             	lea    -0x76(%ebp),%eax
f010097c:	50                   	push   %eax
f010097d:	ff 75 c0             	pushl  -0x40(%ebp)
f0100980:	ff 75 bc             	pushl  -0x44(%ebp)
f0100983:	68 28 66 10 f0       	push   $0xf0106628
f0100988:	e8 eb 2e 00 00       	call   f0103878 <cprintf>

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
f01009b5:	e8 be 2e 00 00       	call   f0103878 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009ba:	c7 04 24 e4 67 10 f0 	movl   $0xf01067e4,(%esp)
f01009c1:	e8 b2 2e 00 00       	call   f0103878 <cprintf>

	if (tf != NULL)
f01009c6:	83 c4 10             	add    $0x10,%esp
f01009c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009cd:	74 0e                	je     f01009dd <monitor+0x36>
		print_trapframe(tf);
f01009cf:	83 ec 0c             	sub    $0xc,%esp
f01009d2:	ff 75 08             	pushl  0x8(%ebp)
f01009d5:	e8 5f 34 00 00       	call   f0103e39 <print_trapframe>
f01009da:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009dd:	83 ec 0c             	sub    $0xc,%esp
f01009e0:	68 3f 66 10 f0       	push   $0xf010663f
f01009e5:	e8 79 49 00 00       	call   f0105363 <readline>
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
f0100a1e:	e8 72 4b 00 00       	call   f0105595 <strchr>
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
f0100a3e:	e8 35 2e 00 00       	call   f0103878 <cprintf>
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
f0100a67:	e8 29 4b 00 00       	call   f0105595 <strchr>
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
f0100a9a:	e8 98 4a 00 00       	call   f0105537 <strcmp>
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
f0100ada:	e8 99 2d 00 00       	call   f0103878 <cprintf>
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
f0100afa:	e8 fa 2b 00 00       	call   f01036f9 <mc146818_read>
f0100aff:	89 c6                	mov    %eax,%esi
f0100b01:	83 c3 01             	add    $0x1,%ebx
f0100b04:	89 1c 24             	mov    %ebx,(%esp)
f0100b07:	e8 ed 2b 00 00       	call   f01036f9 <mc146818_read>
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
f0100c9b:	e8 32 49 00 00       	call   f01055d2 <memset>
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
f0100e79:	e8 fa 29 00 00       	call   f0103878 <cprintf>
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
f0100ee7:	be 4d 68 10 f0       	mov    $0xf010684d,%esi
f0100eec:	81 ee d4 57 10 f0    	sub    $0xf01057d4,%esi
f0100ef2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	cprintf("[?] %x\n", size);
f0100ef8:	83 ec 08             	sub    $0x8,%esp
f0100efb:	56                   	push   %esi
f0100efc:	68 32 69 10 f0       	push   $0xf0106932
f0100f01:	e8 72 29 00 00       	call   f0103878 <cprintf>

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
f0100f42:	e8 31 29 00 00       	call   f0103878 <cprintf>
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
f01010f2:	e8 db 44 00 00       	call   f01055d2 <memset>
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
f010134a:	e8 a3 48 00 00       	call   f0105bf2 <cpunum>
f010134f:	6b c0 74             	imul   $0x74,%eax,%eax
f0101352:	83 b8 28 00 21 f0 00 	cmpl   $0x0,-0xfdeffd8(%eax)
f0101359:	74 16                	je     f0101371 <tlb_invalidate+0x2d>
f010135b:	e8 92 48 00 00       	call   f0105bf2 <cpunum>
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
f010151c:	e8 57 23 00 00       	call   f0103878 <cprintf>
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
f010153b:	e8 92 40 00 00       	call   f01055d2 <memset>
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
f0101592:	e8 3b 40 00 00       	call   f01055d2 <memset>
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
f01015b1:	e8 1c 40 00 00       	call   f01055d2 <memset>
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
f01018cf:	e8 fe 3c 00 00       	call   f01055d2 <memset>
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
f01019df:	e8 94 1e 00 00       	call   f0103878 <cprintf>
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
f010246c:	e8 61 31 00 00       	call   f01055d2 <memset>
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
f010274d:	e8 26 11 00 00       	call   f0103878 <cprintf>
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
f0102b55:	e8 1e 0d 00 00       	call   f0103878 <cprintf>
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
f0102c6b:	e8 62 29 00 00       	call   f01055d2 <memset>
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
f0102cb0:	e8 1d 29 00 00       	call   f01055d2 <memset>
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
f0102e92:	e8 e1 09 00 00       	call   f0103878 <cprintf>
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
f0102f89:	e8 ea 08 00 00       	call   f0103878 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102f8e:	89 1c 24             	mov    %ebx,(%esp)
f0102f91:	e8 e1 05 00 00       	call   f0103577 <env_destroy>
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
f0103031:	e8 bc 2b 00 00       	call   f0105bf2 <cpunum>
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
f010307b:	e8 72 2b 00 00       	call   f0105bf2 <cpunum>
f0103080:	6b c0 74             	imul   $0x74,%eax,%eax
f0103083:	3b 98 28 00 21 f0    	cmp    -0xfdeffd8(%eax),%ebx
f0103089:	74 26                	je     f01030b1 <envid2env+0x8f>
f010308b:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010308e:	e8 5f 2b 00 00       	call   f0105bf2 <cpunum>
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
f0103199:	e8 e9 24 00 00       	call   f0105687 <memcpy>
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
f0103222:	e8 ab 23 00 00       	call   f01055d2 <memset>
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
f010334e:	e8 7f 22 00 00       	call   f01055d2 <memset>

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
f0103362:	e8 20 23 00 00       	call   f0105687 <memcpy>
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

	if (type == ENV_TYPE_FS) {
f01033bd:	83 fa 01             	cmp    $0x1,%edx
f01033c0:	75 07                	jne    f01033c9 <env_create+0x147>
        newenv_store->env_tf.tf_eflags |= FL_IOPL_MASK;
f01033c2:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
    }

}
f01033c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033cc:	5b                   	pop    %ebx
f01033cd:	5e                   	pop    %esi
f01033ce:	5f                   	pop    %edi
f01033cf:	5d                   	pop    %ebp
f01033d0:	c3                   	ret    

f01033d1 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033d1:	55                   	push   %ebp
f01033d2:	89 e5                	mov    %esp,%ebp
f01033d4:	57                   	push   %edi
f01033d5:	56                   	push   %esi
f01033d6:	53                   	push   %ebx
f01033d7:	83 ec 1c             	sub    $0x1c,%esp
f01033da:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033dd:	e8 10 28 00 00       	call   f0105bf2 <cpunum>
f01033e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01033e5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01033ec:	39 b8 28 00 21 f0    	cmp    %edi,-0xfdeffd8(%eax)
f01033f2:	75 30                	jne    f0103424 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01033f4:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033f9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033fe:	77 15                	ja     f0103415 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103400:	50                   	push   %eax
f0103401:	68 c8 62 10 f0       	push   $0xf01062c8
f0103406:	68 d4 01 00 00       	push   $0x1d4
f010340b:	68 9c 76 10 f0       	push   $0xf010769c
f0103410:	e8 2b cc ff ff       	call   f0100040 <_panic>
f0103415:	05 00 00 00 10       	add    $0x10000000,%eax
f010341a:	0f 22 d8             	mov    %eax,%cr3
f010341d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103424:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103427:	89 d0                	mov    %edx,%eax
f0103429:	c1 e0 02             	shl    $0x2,%eax
f010342c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010342f:	8b 47 60             	mov    0x60(%edi),%eax
f0103432:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103435:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010343b:	0f 84 a8 00 00 00    	je     f01034e9 <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103441:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103447:	89 f0                	mov    %esi,%eax
f0103449:	c1 e8 0c             	shr    $0xc,%eax
f010344c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010344f:	39 05 88 fe 20 f0    	cmp    %eax,0xf020fe88
f0103455:	77 15                	ja     f010346c <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103457:	56                   	push   %esi
f0103458:	68 a4 62 10 f0       	push   $0xf01062a4
f010345d:	68 e3 01 00 00       	push   $0x1e3
f0103462:	68 9c 76 10 f0       	push   $0xf010769c
f0103467:	e8 d4 cb ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010346c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010346f:	c1 e0 16             	shl    $0x16,%eax
f0103472:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103475:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010347a:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103481:	01 
f0103482:	74 17                	je     f010349b <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103484:	83 ec 08             	sub    $0x8,%esp
f0103487:	89 d8                	mov    %ebx,%eax
f0103489:	c1 e0 0c             	shl    $0xc,%eax
f010348c:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010348f:	50                   	push   %eax
f0103490:	ff 77 60             	pushl  0x60(%edi)
f0103493:	e8 e1 de ff ff       	call   f0101379 <page_remove>
f0103498:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010349b:	83 c3 01             	add    $0x1,%ebx
f010349e:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034a4:	75 d4                	jne    f010347a <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034a6:	8b 47 60             	mov    0x60(%edi),%eax
f01034a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034ac:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034b6:	3b 05 88 fe 20 f0    	cmp    0xf020fe88,%eax
f01034bc:	72 14                	jb     f01034d2 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01034be:	83 ec 04             	sub    $0x4,%esp
f01034c1:	68 78 6d 10 f0       	push   $0xf0106d78
f01034c6:	6a 51                	push   $0x51
f01034c8:	68 6b 68 10 f0       	push   $0xf010686b
f01034cd:	e8 6e cb ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01034d2:	83 ec 0c             	sub    $0xc,%esp
f01034d5:	a1 90 fe 20 f0       	mov    0xf020fe90,%eax
f01034da:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034dd:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01034e0:	50                   	push   %eax
f01034e1:	e8 79 dc ff ff       	call   f010115f <page_decref>
f01034e6:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034e9:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01034ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034f0:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01034f5:	0f 85 29 ff ff ff    	jne    f0103424 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01034fb:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034fe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103503:	77 15                	ja     f010351a <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103505:	50                   	push   %eax
f0103506:	68 c8 62 10 f0       	push   $0xf01062c8
f010350b:	68 f1 01 00 00       	push   $0x1f1
f0103510:	68 9c 76 10 f0       	push   $0xf010769c
f0103515:	e8 26 cb ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010351a:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103521:	05 00 00 00 10       	add    $0x10000000,%eax
f0103526:	c1 e8 0c             	shr    $0xc,%eax
f0103529:	3b 05 88 fe 20 f0    	cmp    0xf020fe88,%eax
f010352f:	72 14                	jb     f0103545 <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103531:	83 ec 04             	sub    $0x4,%esp
f0103534:	68 78 6d 10 f0       	push   $0xf0106d78
f0103539:	6a 51                	push   $0x51
f010353b:	68 6b 68 10 f0       	push   $0xf010686b
f0103540:	e8 fb ca ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103545:	83 ec 0c             	sub    $0xc,%esp
f0103548:	8b 15 90 fe 20 f0    	mov    0xf020fe90,%edx
f010354e:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103551:	50                   	push   %eax
f0103552:	e8 08 dc ff ff       	call   f010115f <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103557:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010355e:	a1 4c f2 20 f0       	mov    0xf020f24c,%eax
f0103563:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103566:	89 3d 4c f2 20 f0    	mov    %edi,0xf020f24c
}
f010356c:	83 c4 10             	add    $0x10,%esp
f010356f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103572:	5b                   	pop    %ebx
f0103573:	5e                   	pop    %esi
f0103574:	5f                   	pop    %edi
f0103575:	5d                   	pop    %ebp
f0103576:	c3                   	ret    

f0103577 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103577:	55                   	push   %ebp
f0103578:	89 e5                	mov    %esp,%ebp
f010357a:	53                   	push   %ebx
f010357b:	83 ec 04             	sub    $0x4,%esp
f010357e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103581:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103585:	75 19                	jne    f01035a0 <env_destroy+0x29>
f0103587:	e8 66 26 00 00       	call   f0105bf2 <cpunum>
f010358c:	6b c0 74             	imul   $0x74,%eax,%eax
f010358f:	3b 98 28 00 21 f0    	cmp    -0xfdeffd8(%eax),%ebx
f0103595:	74 09                	je     f01035a0 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103597:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010359e:	eb 33                	jmp    f01035d3 <env_destroy+0x5c>
	}

	env_free(e);
f01035a0:	83 ec 0c             	sub    $0xc,%esp
f01035a3:	53                   	push   %ebx
f01035a4:	e8 28 fe ff ff       	call   f01033d1 <env_free>

	if (curenv == e) {
f01035a9:	e8 44 26 00 00       	call   f0105bf2 <cpunum>
f01035ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01035b1:	83 c4 10             	add    $0x10,%esp
f01035b4:	3b 98 28 00 21 f0    	cmp    -0xfdeffd8(%eax),%ebx
f01035ba:	75 17                	jne    f01035d3 <env_destroy+0x5c>
		curenv = NULL;
f01035bc:	e8 31 26 00 00       	call   f0105bf2 <cpunum>
f01035c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01035c4:	c7 80 28 00 21 f0 00 	movl   $0x0,-0xfdeffd8(%eax)
f01035cb:	00 00 00 
		sched_yield();
f01035ce:	e8 ab 0e 00 00       	call   f010447e <sched_yield>
	}
}
f01035d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035d6:	c9                   	leave  
f01035d7:	c3                   	ret    

f01035d8 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035d8:	55                   	push   %ebp
f01035d9:	89 e5                	mov    %esp,%ebp
f01035db:	53                   	push   %ebx
f01035dc:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01035df:	e8 0e 26 00 00       	call   f0105bf2 <cpunum>
f01035e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e7:	8b 98 28 00 21 f0    	mov    -0xfdeffd8(%eax),%ebx
f01035ed:	e8 00 26 00 00       	call   f0105bf2 <cpunum>
f01035f2:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01035f5:	8b 65 08             	mov    0x8(%ebp),%esp
f01035f8:	61                   	popa   
f01035f9:	07                   	pop    %es
f01035fa:	1f                   	pop    %ds
f01035fb:	83 c4 08             	add    $0x8,%esp
f01035fe:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01035ff:	83 ec 04             	sub    $0x4,%esp
f0103602:	68 a7 76 10 f0       	push   $0xf01076a7
f0103607:	68 28 02 00 00       	push   $0x228
f010360c:	68 9c 76 10 f0       	push   $0xf010769c
f0103611:	e8 2a ca ff ff       	call   f0100040 <_panic>

f0103616 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103616:	55                   	push   %ebp
f0103617:	89 e5                	mov    %esp,%ebp
f0103619:	53                   	push   %ebx
f010361a:	83 ec 04             	sub    $0x4,%esp
f010361d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	// context switch
	if (curenv != e) {
f0103620:	e8 cd 25 00 00       	call   f0105bf2 <cpunum>
f0103625:	6b c0 74             	imul   $0x74,%eax,%eax
f0103628:	39 98 28 00 21 f0    	cmp    %ebx,-0xfdeffd8(%eax)
f010362e:	74 3a                	je     f010366a <env_run+0x54>

		if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103630:	e8 bd 25 00 00       	call   f0105bf2 <cpunum>
f0103635:	6b c0 74             	imul   $0x74,%eax,%eax
f0103638:	83 b8 28 00 21 f0 00 	cmpl   $0x0,-0xfdeffd8(%eax)
f010363f:	74 29                	je     f010366a <env_run+0x54>
f0103641:	e8 ac 25 00 00       	call   f0105bf2 <cpunum>
f0103646:	6b c0 74             	imul   $0x74,%eax,%eax
f0103649:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f010364f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103653:	75 15                	jne    f010366a <env_run+0x54>
			curenv->env_status = ENV_RUNNABLE;
f0103655:	e8 98 25 00 00       	call   f0105bf2 <cpunum>
f010365a:	6b c0 74             	imul   $0x74,%eax,%eax
f010365d:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f0103663:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
			
	}
	
	curenv = e;
f010366a:	e8 83 25 00 00       	call   f0105bf2 <cpunum>
f010366f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103672:	89 98 28 00 21 f0    	mov    %ebx,-0xfdeffd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103678:	e8 75 25 00 00       	call   f0105bf2 <cpunum>
f010367d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103680:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f0103686:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f010368d:	e8 60 25 00 00       	call   f0105bf2 <cpunum>
f0103692:	6b c0 74             	imul   $0x74,%eax,%eax
f0103695:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f010369b:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f010369f:	e8 4e 25 00 00       	call   f0105bf2 <cpunum>
f01036a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a7:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01036ad:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036b0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036b5:	77 15                	ja     f01036cc <env_run+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036b7:	50                   	push   %eax
f01036b8:	68 c8 62 10 f0       	push   $0xf01062c8
f01036bd:	68 52 02 00 00       	push   $0x252
f01036c2:	68 9c 76 10 f0       	push   $0xf010769c
f01036c7:	e8 74 c9 ff ff       	call   f0100040 <_panic>
f01036cc:	05 00 00 00 10       	add    $0x10000000,%eax
f01036d1:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01036d4:	83 ec 0c             	sub    $0xc,%esp
f01036d7:	68 c0 03 12 f0       	push   $0xf01203c0
f01036dc:	e8 1c 28 00 00       	call   f0105efd <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01036e1:	f3 90                	pause  

	unlock_kernel();

	// iret to execute entry point stored in tf_eip
	// cprintf("[?] try to execute at entry point: %x\n", curenv->env_tf.tf_eip);
	env_pop_tf(&curenv->env_tf);
f01036e3:	e8 0a 25 00 00       	call   f0105bf2 <cpunum>
f01036e8:	83 c4 04             	add    $0x4,%esp
f01036eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ee:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f01036f4:	e8 df fe ff ff       	call   f01035d8 <env_pop_tf>

f01036f9 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01036f9:	55                   	push   %ebp
f01036fa:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036fc:	ba 70 00 00 00       	mov    $0x70,%edx
f0103701:	8b 45 08             	mov    0x8(%ebp),%eax
f0103704:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103705:	ba 71 00 00 00       	mov    $0x71,%edx
f010370a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010370b:	0f b6 c0             	movzbl %al,%eax
}
f010370e:	5d                   	pop    %ebp
f010370f:	c3                   	ret    

f0103710 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103710:	55                   	push   %ebp
f0103711:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103713:	ba 70 00 00 00       	mov    $0x70,%edx
f0103718:	8b 45 08             	mov    0x8(%ebp),%eax
f010371b:	ee                   	out    %al,(%dx)
f010371c:	ba 71 00 00 00       	mov    $0x71,%edx
f0103721:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103724:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103725:	5d                   	pop    %ebp
f0103726:	c3                   	ret    

f0103727 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103727:	55                   	push   %ebp
f0103728:	89 e5                	mov    %esp,%ebp
f010372a:	56                   	push   %esi
f010372b:	53                   	push   %ebx
f010372c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010372f:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103735:	80 3d 50 f2 20 f0 00 	cmpb   $0x0,0xf020f250
f010373c:	74 5a                	je     f0103798 <irq_setmask_8259A+0x71>
f010373e:	89 c6                	mov    %eax,%esi
f0103740:	ba 21 00 00 00       	mov    $0x21,%edx
f0103745:	ee                   	out    %al,(%dx)
f0103746:	66 c1 e8 08          	shr    $0x8,%ax
f010374a:	ba a1 00 00 00       	mov    $0xa1,%edx
f010374f:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103750:	83 ec 0c             	sub    $0xc,%esp
f0103753:	68 b3 76 10 f0       	push   $0xf01076b3
f0103758:	e8 1b 01 00 00       	call   f0103878 <cprintf>
f010375d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103760:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103765:	0f b7 f6             	movzwl %si,%esi
f0103768:	f7 d6                	not    %esi
f010376a:	0f a3 de             	bt     %ebx,%esi
f010376d:	73 11                	jae    f0103780 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f010376f:	83 ec 08             	sub    $0x8,%esp
f0103772:	53                   	push   %ebx
f0103773:	68 2b 7b 10 f0       	push   $0xf0107b2b
f0103778:	e8 fb 00 00 00       	call   f0103878 <cprintf>
f010377d:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103780:	83 c3 01             	add    $0x1,%ebx
f0103783:	83 fb 10             	cmp    $0x10,%ebx
f0103786:	75 e2                	jne    f010376a <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103788:	83 ec 0c             	sub    $0xc,%esp
f010378b:	68 60 6b 10 f0       	push   $0xf0106b60
f0103790:	e8 e3 00 00 00       	call   f0103878 <cprintf>
f0103795:	83 c4 10             	add    $0x10,%esp
}
f0103798:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010379b:	5b                   	pop    %ebx
f010379c:	5e                   	pop    %esi
f010379d:	5d                   	pop    %ebp
f010379e:	c3                   	ret    

f010379f <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010379f:	c6 05 50 f2 20 f0 01 	movb   $0x1,0xf020f250
f01037a6:	ba 21 00 00 00       	mov    $0x21,%edx
f01037ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037b0:	ee                   	out    %al,(%dx)
f01037b1:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037b6:	ee                   	out    %al,(%dx)
f01037b7:	ba 20 00 00 00       	mov    $0x20,%edx
f01037bc:	b8 11 00 00 00       	mov    $0x11,%eax
f01037c1:	ee                   	out    %al,(%dx)
f01037c2:	ba 21 00 00 00       	mov    $0x21,%edx
f01037c7:	b8 20 00 00 00       	mov    $0x20,%eax
f01037cc:	ee                   	out    %al,(%dx)
f01037cd:	b8 04 00 00 00       	mov    $0x4,%eax
f01037d2:	ee                   	out    %al,(%dx)
f01037d3:	b8 03 00 00 00       	mov    $0x3,%eax
f01037d8:	ee                   	out    %al,(%dx)
f01037d9:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037de:	b8 11 00 00 00       	mov    $0x11,%eax
f01037e3:	ee                   	out    %al,(%dx)
f01037e4:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037e9:	b8 28 00 00 00       	mov    $0x28,%eax
f01037ee:	ee                   	out    %al,(%dx)
f01037ef:	b8 02 00 00 00       	mov    $0x2,%eax
f01037f4:	ee                   	out    %al,(%dx)
f01037f5:	b8 01 00 00 00       	mov    $0x1,%eax
f01037fa:	ee                   	out    %al,(%dx)
f01037fb:	ba 20 00 00 00       	mov    $0x20,%edx
f0103800:	b8 68 00 00 00       	mov    $0x68,%eax
f0103805:	ee                   	out    %al,(%dx)
f0103806:	b8 0a 00 00 00       	mov    $0xa,%eax
f010380b:	ee                   	out    %al,(%dx)
f010380c:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103811:	b8 68 00 00 00       	mov    $0x68,%eax
f0103816:	ee                   	out    %al,(%dx)
f0103817:	b8 0a 00 00 00       	mov    $0xa,%eax
f010381c:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010381d:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0103824:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103828:	74 13                	je     f010383d <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010382a:	55                   	push   %ebp
f010382b:	89 e5                	mov    %esp,%ebp
f010382d:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103830:	0f b7 c0             	movzwl %ax,%eax
f0103833:	50                   	push   %eax
f0103834:	e8 ee fe ff ff       	call   f0103727 <irq_setmask_8259A>
f0103839:	83 c4 10             	add    $0x10,%esp
}
f010383c:	c9                   	leave  
f010383d:	f3 c3                	repz ret 

f010383f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010383f:	55                   	push   %ebp
f0103840:	89 e5                	mov    %esp,%ebp
f0103842:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103845:	ff 75 08             	pushl  0x8(%ebp)
f0103848:	e8 35 cf ff ff       	call   f0100782 <cputchar>
	*cnt++;
}
f010384d:	83 c4 10             	add    $0x10,%esp
f0103850:	c9                   	leave  
f0103851:	c3                   	ret    

f0103852 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103852:	55                   	push   %ebp
f0103853:	89 e5                	mov    %esp,%ebp
f0103855:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103858:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010385f:	ff 75 0c             	pushl  0xc(%ebp)
f0103862:	ff 75 08             	pushl  0x8(%ebp)
f0103865:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103868:	50                   	push   %eax
f0103869:	68 3f 38 10 f0       	push   $0xf010383f
f010386e:	e8 db 16 00 00       	call   f0104f4e <vprintfmt>
	return cnt;
}
f0103873:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103876:	c9                   	leave  
f0103877:	c3                   	ret    

f0103878 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103878:	55                   	push   %ebp
f0103879:	89 e5                	mov    %esp,%ebp
f010387b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010387e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103881:	50                   	push   %eax
f0103882:	ff 75 08             	pushl  0x8(%ebp)
f0103885:	e8 c8 ff ff ff       	call   f0103852 <vcprintf>
	va_end(ap);

	return cnt;
}
f010388a:	c9                   	leave  
f010388b:	c3                   	ret    

f010388c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010388c:	55                   	push   %ebp
f010388d:	89 e5                	mov    %esp,%ebp
f010388f:	57                   	push   %edi
f0103890:	56                   	push   %esi
f0103891:	53                   	push   %ebx
f0103892:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t) percpu_kstacks[cpunum()];
f0103895:	e8 58 23 00 00       	call   f0105bf2 <cpunum>
f010389a:	89 c3                	mov    %eax,%ebx
f010389c:	e8 51 23 00 00       	call   f0105bf2 <cpunum>
f01038a1:	6b db 74             	imul   $0x74,%ebx,%ebx
f01038a4:	c1 e0 0f             	shl    $0xf,%eax
f01038a7:	05 00 10 21 f0       	add    $0xf0211000,%eax
f01038ac:	89 83 30 00 21 f0    	mov    %eax,-0xfdeffd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01038b2:	e8 3b 23 00 00       	call   f0105bf2 <cpunum>
f01038b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01038ba:	66 c7 80 34 00 21 f0 	movw   $0x10,-0xfdeffcc(%eax)
f01038c1:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01038c3:	e8 2a 23 00 00       	call   f0105bf2 <cpunum>
f01038c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01038cb:	66 c7 80 92 00 21 f0 	movw   $0x68,-0xfdeff6e(%eax)
f01038d2:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01038d4:	e8 19 23 00 00       	call   f0105bf2 <cpunum>
f01038d9:	8d 58 05             	lea    0x5(%eax),%ebx
f01038dc:	e8 11 23 00 00       	call   f0105bf2 <cpunum>
f01038e1:	89 c7                	mov    %eax,%edi
f01038e3:	e8 0a 23 00 00       	call   f0105bf2 <cpunum>
f01038e8:	89 c6                	mov    %eax,%esi
f01038ea:	e8 03 23 00 00       	call   f0105bf2 <cpunum>
f01038ef:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f01038f6:	f0 67 00 
f01038f9:	6b ff 74             	imul   $0x74,%edi,%edi
f01038fc:	81 c7 2c 00 21 f0    	add    $0xf021002c,%edi
f0103902:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f0103909:	f0 
f010390a:	6b d6 74             	imul   $0x74,%esi,%edx
f010390d:	81 c2 2c 00 21 f0    	add    $0xf021002c,%edx
f0103913:	c1 ea 10             	shr    $0x10,%edx
f0103916:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f010391d:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f0103924:	99 
f0103925:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f010392c:	40 
f010392d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103930:	05 2c 00 21 f0       	add    $0xf021002c,%eax
f0103935:	c1 e8 18             	shr    $0x18,%eax
f0103938:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f010393f:	e8 ae 22 00 00       	call   f0105bf2 <cpunum>
f0103944:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f010394b:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f010394c:	e8 a1 22 00 00       	call   f0105bf2 <cpunum>
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103951:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103958:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f010395b:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f0103960:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103963:	83 c4 0c             	add    $0xc,%esp
f0103966:	5b                   	pop    %ebx
f0103967:	5e                   	pop    %esi
f0103968:	5f                   	pop    %edi
f0103969:	5d                   	pop    %ebp
f010396a:	c3                   	ret    

f010396b <trap_init>:
}


void
trap_init(void)
{
f010396b:	55                   	push   %ebp
f010396c:	89 e5                	mov    %esp,%ebp
f010396e:	83 ec 08             	sub    $0x8,%esp
	void _IRQ_SPURIOUS_handler();
	void _IRQ_IDE_handler();
	void _IRQ_ERROR_handler();

	// SETGATE(gate, istrap, sel, off, dpl);
	SETGATE(idt[T_DIVIDE], 0, GD_KT, _T_DIVIDE_handler, 0);
f0103971:	b8 0c 43 10 f0       	mov    $0xf010430c,%eax
f0103976:	66 a3 60 f2 20 f0    	mov    %ax,0xf020f260
f010397c:	66 c7 05 62 f2 20 f0 	movw   $0x8,0xf020f262
f0103983:	08 00 
f0103985:	c6 05 64 f2 20 f0 00 	movb   $0x0,0xf020f264
f010398c:	c6 05 65 f2 20 f0 8e 	movb   $0x8e,0xf020f265
f0103993:	c1 e8 10             	shr    $0x10,%eax
f0103996:	66 a3 66 f2 20 f0    	mov    %ax,0xf020f266
	SETGATE(idt[T_DEBUG], 0, GD_KT, _T_DEBUG_handler, 0);
f010399c:	b8 16 43 10 f0       	mov    $0xf0104316,%eax
f01039a1:	66 a3 68 f2 20 f0    	mov    %ax,0xf020f268
f01039a7:	66 c7 05 6a f2 20 f0 	movw   $0x8,0xf020f26a
f01039ae:	08 00 
f01039b0:	c6 05 6c f2 20 f0 00 	movb   $0x0,0xf020f26c
f01039b7:	c6 05 6d f2 20 f0 8e 	movb   $0x8e,0xf020f26d
f01039be:	c1 e8 10             	shr    $0x10,%eax
f01039c1:	66 a3 6e f2 20 f0    	mov    %ax,0xf020f26e
	SETGATE(idt[T_NMI], 0, GD_KT, _T_NMI_handler, 0);
f01039c7:	b8 1c 43 10 f0       	mov    $0xf010431c,%eax
f01039cc:	66 a3 70 f2 20 f0    	mov    %ax,0xf020f270
f01039d2:	66 c7 05 72 f2 20 f0 	movw   $0x8,0xf020f272
f01039d9:	08 00 
f01039db:	c6 05 74 f2 20 f0 00 	movb   $0x0,0xf020f274
f01039e2:	c6 05 75 f2 20 f0 8e 	movb   $0x8e,0xf020f275
f01039e9:	c1 e8 10             	shr    $0x10,%eax
f01039ec:	66 a3 76 f2 20 f0    	mov    %ax,0xf020f276
	SETGATE(idt[T_BRKPT], 0, GD_KT, _T_BRKPT_handler, 3);
f01039f2:	b8 22 43 10 f0       	mov    $0xf0104322,%eax
f01039f7:	66 a3 78 f2 20 f0    	mov    %ax,0xf020f278
f01039fd:	66 c7 05 7a f2 20 f0 	movw   $0x8,0xf020f27a
f0103a04:	08 00 
f0103a06:	c6 05 7c f2 20 f0 00 	movb   $0x0,0xf020f27c
f0103a0d:	c6 05 7d f2 20 f0 ee 	movb   $0xee,0xf020f27d
f0103a14:	c1 e8 10             	shr    $0x10,%eax
f0103a17:	66 a3 7e f2 20 f0    	mov    %ax,0xf020f27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, _T_OFLOW_handler, 0);
f0103a1d:	b8 28 43 10 f0       	mov    $0xf0104328,%eax
f0103a22:	66 a3 80 f2 20 f0    	mov    %ax,0xf020f280
f0103a28:	66 c7 05 82 f2 20 f0 	movw   $0x8,0xf020f282
f0103a2f:	08 00 
f0103a31:	c6 05 84 f2 20 f0 00 	movb   $0x0,0xf020f284
f0103a38:	c6 05 85 f2 20 f0 8e 	movb   $0x8e,0xf020f285
f0103a3f:	c1 e8 10             	shr    $0x10,%eax
f0103a42:	66 a3 86 f2 20 f0    	mov    %ax,0xf020f286
	SETGATE(idt[T_BOUND], 0, GD_KT, _T_BOUND_handler, 0);
f0103a48:	b8 2e 43 10 f0       	mov    $0xf010432e,%eax
f0103a4d:	66 a3 88 f2 20 f0    	mov    %ax,0xf020f288
f0103a53:	66 c7 05 8a f2 20 f0 	movw   $0x8,0xf020f28a
f0103a5a:	08 00 
f0103a5c:	c6 05 8c f2 20 f0 00 	movb   $0x0,0xf020f28c
f0103a63:	c6 05 8d f2 20 f0 8e 	movb   $0x8e,0xf020f28d
f0103a6a:	c1 e8 10             	shr    $0x10,%eax
f0103a6d:	66 a3 8e f2 20 f0    	mov    %ax,0xf020f28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, _T_ILLOP_handler, 0);
f0103a73:	b8 34 43 10 f0       	mov    $0xf0104334,%eax
f0103a78:	66 a3 90 f2 20 f0    	mov    %ax,0xf020f290
f0103a7e:	66 c7 05 92 f2 20 f0 	movw   $0x8,0xf020f292
f0103a85:	08 00 
f0103a87:	c6 05 94 f2 20 f0 00 	movb   $0x0,0xf020f294
f0103a8e:	c6 05 95 f2 20 f0 8e 	movb   $0x8e,0xf020f295
f0103a95:	c1 e8 10             	shr    $0x10,%eax
f0103a98:	66 a3 96 f2 20 f0    	mov    %ax,0xf020f296
	SETGATE(idt[T_DEVICE], 0, GD_KT, _T_DEVICE_handler, 0);
f0103a9e:	b8 3a 43 10 f0       	mov    $0xf010433a,%eax
f0103aa3:	66 a3 98 f2 20 f0    	mov    %ax,0xf020f298
f0103aa9:	66 c7 05 9a f2 20 f0 	movw   $0x8,0xf020f29a
f0103ab0:	08 00 
f0103ab2:	c6 05 9c f2 20 f0 00 	movb   $0x0,0xf020f29c
f0103ab9:	c6 05 9d f2 20 f0 8e 	movb   $0x8e,0xf020f29d
f0103ac0:	c1 e8 10             	shr    $0x10,%eax
f0103ac3:	66 a3 9e f2 20 f0    	mov    %ax,0xf020f29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, _T_DBLFLT_handler, 0);
f0103ac9:	b8 40 43 10 f0       	mov    $0xf0104340,%eax
f0103ace:	66 a3 a0 f2 20 f0    	mov    %ax,0xf020f2a0
f0103ad4:	66 c7 05 a2 f2 20 f0 	movw   $0x8,0xf020f2a2
f0103adb:	08 00 
f0103add:	c6 05 a4 f2 20 f0 00 	movb   $0x0,0xf020f2a4
f0103ae4:	c6 05 a5 f2 20 f0 8e 	movb   $0x8e,0xf020f2a5
f0103aeb:	c1 e8 10             	shr    $0x10,%eax
f0103aee:	66 a3 a6 f2 20 f0    	mov    %ax,0xf020f2a6
	SETGATE(idt[T_TSS], 0, GD_KT, _T_TSS_handler, 0);
f0103af4:	b8 44 43 10 f0       	mov    $0xf0104344,%eax
f0103af9:	66 a3 b0 f2 20 f0    	mov    %ax,0xf020f2b0
f0103aff:	66 c7 05 b2 f2 20 f0 	movw   $0x8,0xf020f2b2
f0103b06:	08 00 
f0103b08:	c6 05 b4 f2 20 f0 00 	movb   $0x0,0xf020f2b4
f0103b0f:	c6 05 b5 f2 20 f0 8e 	movb   $0x8e,0xf020f2b5
f0103b16:	c1 e8 10             	shr    $0x10,%eax
f0103b19:	66 a3 b6 f2 20 f0    	mov    %ax,0xf020f2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, _T_SEGNP_handler, 0);
f0103b1f:	b8 48 43 10 f0       	mov    $0xf0104348,%eax
f0103b24:	66 a3 b8 f2 20 f0    	mov    %ax,0xf020f2b8
f0103b2a:	66 c7 05 ba f2 20 f0 	movw   $0x8,0xf020f2ba
f0103b31:	08 00 
f0103b33:	c6 05 bc f2 20 f0 00 	movb   $0x0,0xf020f2bc
f0103b3a:	c6 05 bd f2 20 f0 8e 	movb   $0x8e,0xf020f2bd
f0103b41:	c1 e8 10             	shr    $0x10,%eax
f0103b44:	66 a3 be f2 20 f0    	mov    %ax,0xf020f2be
	SETGATE(idt[T_STACK], 0, GD_KT, _T_STACK_handler, 0);
f0103b4a:	b8 4c 43 10 f0       	mov    $0xf010434c,%eax
f0103b4f:	66 a3 c0 f2 20 f0    	mov    %ax,0xf020f2c0
f0103b55:	66 c7 05 c2 f2 20 f0 	movw   $0x8,0xf020f2c2
f0103b5c:	08 00 
f0103b5e:	c6 05 c4 f2 20 f0 00 	movb   $0x0,0xf020f2c4
f0103b65:	c6 05 c5 f2 20 f0 8e 	movb   $0x8e,0xf020f2c5
f0103b6c:	c1 e8 10             	shr    $0x10,%eax
f0103b6f:	66 a3 c6 f2 20 f0    	mov    %ax,0xf020f2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, _T_GPFLT_handler, 0);
f0103b75:	b8 50 43 10 f0       	mov    $0xf0104350,%eax
f0103b7a:	66 a3 c8 f2 20 f0    	mov    %ax,0xf020f2c8
f0103b80:	66 c7 05 ca f2 20 f0 	movw   $0x8,0xf020f2ca
f0103b87:	08 00 
f0103b89:	c6 05 cc f2 20 f0 00 	movb   $0x0,0xf020f2cc
f0103b90:	c6 05 cd f2 20 f0 8e 	movb   $0x8e,0xf020f2cd
f0103b97:	c1 e8 10             	shr    $0x10,%eax
f0103b9a:	66 a3 ce f2 20 f0    	mov    %ax,0xf020f2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, _T_PGFLT_handler, 0);
f0103ba0:	b8 54 43 10 f0       	mov    $0xf0104354,%eax
f0103ba5:	66 a3 d0 f2 20 f0    	mov    %ax,0xf020f2d0
f0103bab:	66 c7 05 d2 f2 20 f0 	movw   $0x8,0xf020f2d2
f0103bb2:	08 00 
f0103bb4:	c6 05 d4 f2 20 f0 00 	movb   $0x0,0xf020f2d4
f0103bbb:	c6 05 d5 f2 20 f0 8e 	movb   $0x8e,0xf020f2d5
f0103bc2:	c1 e8 10             	shr    $0x10,%eax
f0103bc5:	66 a3 d6 f2 20 f0    	mov    %ax,0xf020f2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, _T_FPERR_handler, 0);
f0103bcb:	b8 58 43 10 f0       	mov    $0xf0104358,%eax
f0103bd0:	66 a3 e0 f2 20 f0    	mov    %ax,0xf020f2e0
f0103bd6:	66 c7 05 e2 f2 20 f0 	movw   $0x8,0xf020f2e2
f0103bdd:	08 00 
f0103bdf:	c6 05 e4 f2 20 f0 00 	movb   $0x0,0xf020f2e4
f0103be6:	c6 05 e5 f2 20 f0 8e 	movb   $0x8e,0xf020f2e5
f0103bed:	c1 e8 10             	shr    $0x10,%eax
f0103bf0:	66 a3 e6 f2 20 f0    	mov    %ax,0xf020f2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, _T_ALIGN_handler, 0);
f0103bf6:	b8 5e 43 10 f0       	mov    $0xf010435e,%eax
f0103bfb:	66 a3 e8 f2 20 f0    	mov    %ax,0xf020f2e8
f0103c01:	66 c7 05 ea f2 20 f0 	movw   $0x8,0xf020f2ea
f0103c08:	08 00 
f0103c0a:	c6 05 ec f2 20 f0 00 	movb   $0x0,0xf020f2ec
f0103c11:	c6 05 ed f2 20 f0 8e 	movb   $0x8e,0xf020f2ed
f0103c18:	c1 e8 10             	shr    $0x10,%eax
f0103c1b:	66 a3 ee f2 20 f0    	mov    %ax,0xf020f2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, _T_MCHK_handler, 0);
f0103c21:	b8 62 43 10 f0       	mov    $0xf0104362,%eax
f0103c26:	66 a3 f0 f2 20 f0    	mov    %ax,0xf020f2f0
f0103c2c:	66 c7 05 f2 f2 20 f0 	movw   $0x8,0xf020f2f2
f0103c33:	08 00 
f0103c35:	c6 05 f4 f2 20 f0 00 	movb   $0x0,0xf020f2f4
f0103c3c:	c6 05 f5 f2 20 f0 8e 	movb   $0x8e,0xf020f2f5
f0103c43:	c1 e8 10             	shr    $0x10,%eax
f0103c46:	66 a3 f6 f2 20 f0    	mov    %ax,0xf020f2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, _T_SIMDERR_handler, 0);
f0103c4c:	b8 68 43 10 f0       	mov    $0xf0104368,%eax
f0103c51:	66 a3 f8 f2 20 f0    	mov    %ax,0xf020f2f8
f0103c57:	66 c7 05 fa f2 20 f0 	movw   $0x8,0xf020f2fa
f0103c5e:	08 00 
f0103c60:	c6 05 fc f2 20 f0 00 	movb   $0x0,0xf020f2fc
f0103c67:	c6 05 fd f2 20 f0 8e 	movb   $0x8e,0xf020f2fd
f0103c6e:	c1 e8 10             	shr    $0x10,%eax
f0103c71:	66 a3 fe f2 20 f0    	mov    %ax,0xf020f2fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, _T_SYSCALL_handler, 3);
f0103c77:	b8 6e 43 10 f0       	mov    $0xf010436e,%eax
f0103c7c:	66 a3 e0 f3 20 f0    	mov    %ax,0xf020f3e0
f0103c82:	66 c7 05 e2 f3 20 f0 	movw   $0x8,0xf020f3e2
f0103c89:	08 00 
f0103c8b:	c6 05 e4 f3 20 f0 00 	movb   $0x0,0xf020f3e4
f0103c92:	c6 05 e5 f3 20 f0 ee 	movb   $0xee,0xf020f3e5
f0103c99:	c1 e8 10             	shr    $0x10,%eax
f0103c9c:	66 a3 e6 f3 20 f0    	mov    %ax,0xf020f3e6

	SETGATE(idt[IRQ_TIMER + IRQ_OFFSET], 0, GD_KT, _IRQ_TIMER_handler, 0);
f0103ca2:	b8 74 43 10 f0       	mov    $0xf0104374,%eax
f0103ca7:	66 a3 60 f3 20 f0    	mov    %ax,0xf020f360
f0103cad:	66 c7 05 62 f3 20 f0 	movw   $0x8,0xf020f362
f0103cb4:	08 00 
f0103cb6:	c6 05 64 f3 20 f0 00 	movb   $0x0,0xf020f364
f0103cbd:	c6 05 65 f3 20 f0 8e 	movb   $0x8e,0xf020f365
f0103cc4:	c1 e8 10             	shr    $0x10,%eax
f0103cc7:	66 a3 66 f3 20 f0    	mov    %ax,0xf020f366
	SETGATE(idt[IRQ_KBD + IRQ_OFFSET], 0, GD_KT, _IRQ_KBD_handler, 0);
f0103ccd:	b8 7a 43 10 f0       	mov    $0xf010437a,%eax
f0103cd2:	66 a3 68 f3 20 f0    	mov    %ax,0xf020f368
f0103cd8:	66 c7 05 6a f3 20 f0 	movw   $0x8,0xf020f36a
f0103cdf:	08 00 
f0103ce1:	c6 05 6c f3 20 f0 00 	movb   $0x0,0xf020f36c
f0103ce8:	c6 05 6d f3 20 f0 8e 	movb   $0x8e,0xf020f36d
f0103cef:	c1 e8 10             	shr    $0x10,%eax
f0103cf2:	66 a3 6e f3 20 f0    	mov    %ax,0xf020f36e
	SETGATE(idt[IRQ_SERIAL + IRQ_OFFSET], 0, GD_KT, _IRQ_SERIAL_handler, 0);
f0103cf8:	b8 80 43 10 f0       	mov    $0xf0104380,%eax
f0103cfd:	66 a3 80 f3 20 f0    	mov    %ax,0xf020f380
f0103d03:	66 c7 05 82 f3 20 f0 	movw   $0x8,0xf020f382
f0103d0a:	08 00 
f0103d0c:	c6 05 84 f3 20 f0 00 	movb   $0x0,0xf020f384
f0103d13:	c6 05 85 f3 20 f0 8e 	movb   $0x8e,0xf020f385
f0103d1a:	c1 e8 10             	shr    $0x10,%eax
f0103d1d:	66 a3 86 f3 20 f0    	mov    %ax,0xf020f386
	SETGATE(idt[IRQ_SPURIOUS + IRQ_OFFSET], 0, GD_KT, _IRQ_SPURIOUS_handler, 0);
f0103d23:	b8 86 43 10 f0       	mov    $0xf0104386,%eax
f0103d28:	66 a3 98 f3 20 f0    	mov    %ax,0xf020f398
f0103d2e:	66 c7 05 9a f3 20 f0 	movw   $0x8,0xf020f39a
f0103d35:	08 00 
f0103d37:	c6 05 9c f3 20 f0 00 	movb   $0x0,0xf020f39c
f0103d3e:	c6 05 9d f3 20 f0 8e 	movb   $0x8e,0xf020f39d
f0103d45:	c1 e8 10             	shr    $0x10,%eax
f0103d48:	66 a3 9e f3 20 f0    	mov    %ax,0xf020f39e
	SETGATE(idt[IRQ_IDE + IRQ_OFFSET], 0, GD_KT, _IRQ_IDE_handler, 0);
f0103d4e:	b8 8c 43 10 f0       	mov    $0xf010438c,%eax
f0103d53:	66 a3 d0 f3 20 f0    	mov    %ax,0xf020f3d0
f0103d59:	66 c7 05 d2 f3 20 f0 	movw   $0x8,0xf020f3d2
f0103d60:	08 00 
f0103d62:	c6 05 d4 f3 20 f0 00 	movb   $0x0,0xf020f3d4
f0103d69:	c6 05 d5 f3 20 f0 8e 	movb   $0x8e,0xf020f3d5
f0103d70:	c1 e8 10             	shr    $0x10,%eax
f0103d73:	66 a3 d6 f3 20 f0    	mov    %ax,0xf020f3d6
	SETGATE(idt[IRQ_ERROR + IRQ_OFFSET], 0, GD_KT, _IRQ_ERROR_handler, 0);
f0103d79:	b8 92 43 10 f0       	mov    $0xf0104392,%eax
f0103d7e:	66 a3 f8 f3 20 f0    	mov    %ax,0xf020f3f8
f0103d84:	66 c7 05 fa f3 20 f0 	movw   $0x8,0xf020f3fa
f0103d8b:	08 00 
f0103d8d:	c6 05 fc f3 20 f0 00 	movb   $0x0,0xf020f3fc
f0103d94:	c6 05 fd f3 20 f0 8e 	movb   $0x8e,0xf020f3fd
f0103d9b:	c1 e8 10             	shr    $0x10,%eax
f0103d9e:	66 a3 fe f3 20 f0    	mov    %ax,0xf020f3fe

	// Per-CPU setup 
	trap_init_percpu();
f0103da4:	e8 e3 fa ff ff       	call   f010388c <trap_init_percpu>
}
f0103da9:	c9                   	leave  
f0103daa:	c3                   	ret    

f0103dab <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103dab:	55                   	push   %ebp
f0103dac:	89 e5                	mov    %esp,%ebp
f0103dae:	53                   	push   %ebx
f0103daf:	83 ec 0c             	sub    $0xc,%esp
f0103db2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103db5:	ff 33                	pushl  (%ebx)
f0103db7:	68 c7 76 10 f0       	push   $0xf01076c7
f0103dbc:	e8 b7 fa ff ff       	call   f0103878 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103dc1:	83 c4 08             	add    $0x8,%esp
f0103dc4:	ff 73 04             	pushl  0x4(%ebx)
f0103dc7:	68 d6 76 10 f0       	push   $0xf01076d6
f0103dcc:	e8 a7 fa ff ff       	call   f0103878 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103dd1:	83 c4 08             	add    $0x8,%esp
f0103dd4:	ff 73 08             	pushl  0x8(%ebx)
f0103dd7:	68 e5 76 10 f0       	push   $0xf01076e5
f0103ddc:	e8 97 fa ff ff       	call   f0103878 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103de1:	83 c4 08             	add    $0x8,%esp
f0103de4:	ff 73 0c             	pushl  0xc(%ebx)
f0103de7:	68 f4 76 10 f0       	push   $0xf01076f4
f0103dec:	e8 87 fa ff ff       	call   f0103878 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103df1:	83 c4 08             	add    $0x8,%esp
f0103df4:	ff 73 10             	pushl  0x10(%ebx)
f0103df7:	68 03 77 10 f0       	push   $0xf0107703
f0103dfc:	e8 77 fa ff ff       	call   f0103878 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e01:	83 c4 08             	add    $0x8,%esp
f0103e04:	ff 73 14             	pushl  0x14(%ebx)
f0103e07:	68 12 77 10 f0       	push   $0xf0107712
f0103e0c:	e8 67 fa ff ff       	call   f0103878 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e11:	83 c4 08             	add    $0x8,%esp
f0103e14:	ff 73 18             	pushl  0x18(%ebx)
f0103e17:	68 21 77 10 f0       	push   $0xf0107721
f0103e1c:	e8 57 fa ff ff       	call   f0103878 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e21:	83 c4 08             	add    $0x8,%esp
f0103e24:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e27:	68 30 77 10 f0       	push   $0xf0107730
f0103e2c:	e8 47 fa ff ff       	call   f0103878 <cprintf>
}
f0103e31:	83 c4 10             	add    $0x10,%esp
f0103e34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e37:	c9                   	leave  
f0103e38:	c3                   	ret    

f0103e39 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103e39:	55                   	push   %ebp
f0103e3a:	89 e5                	mov    %esp,%ebp
f0103e3c:	56                   	push   %esi
f0103e3d:	53                   	push   %ebx
f0103e3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e41:	e8 ac 1d 00 00       	call   f0105bf2 <cpunum>
f0103e46:	83 ec 04             	sub    $0x4,%esp
f0103e49:	50                   	push   %eax
f0103e4a:	53                   	push   %ebx
f0103e4b:	68 94 77 10 f0       	push   $0xf0107794
f0103e50:	e8 23 fa ff ff       	call   f0103878 <cprintf>
	print_regs(&tf->tf_regs);
f0103e55:	89 1c 24             	mov    %ebx,(%esp)
f0103e58:	e8 4e ff ff ff       	call   f0103dab <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103e5d:	83 c4 08             	add    $0x8,%esp
f0103e60:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103e64:	50                   	push   %eax
f0103e65:	68 b2 77 10 f0       	push   $0xf01077b2
f0103e6a:	e8 09 fa ff ff       	call   f0103878 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e6f:	83 c4 08             	add    $0x8,%esp
f0103e72:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103e76:	50                   	push   %eax
f0103e77:	68 c5 77 10 f0       	push   $0xf01077c5
f0103e7c:	e8 f7 f9 ff ff       	call   f0103878 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e81:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103e84:	83 c4 10             	add    $0x10,%esp
f0103e87:	83 f8 13             	cmp    $0x13,%eax
f0103e8a:	77 09                	ja     f0103e95 <print_trapframe+0x5c>
		return excnames[trapno];
f0103e8c:	8b 14 85 40 7a 10 f0 	mov    -0xfef85c0(,%eax,4),%edx
f0103e93:	eb 1f                	jmp    f0103eb4 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103e95:	83 f8 30             	cmp    $0x30,%eax
f0103e98:	74 15                	je     f0103eaf <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103e9a:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103e9d:	83 fa 10             	cmp    $0x10,%edx
f0103ea0:	b9 5e 77 10 f0       	mov    $0xf010775e,%ecx
f0103ea5:	ba 4b 77 10 f0       	mov    $0xf010774b,%edx
f0103eaa:	0f 43 d1             	cmovae %ecx,%edx
f0103ead:	eb 05                	jmp    f0103eb4 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103eaf:	ba 3f 77 10 f0       	mov    $0xf010773f,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103eb4:	83 ec 04             	sub    $0x4,%esp
f0103eb7:	52                   	push   %edx
f0103eb8:	50                   	push   %eax
f0103eb9:	68 d8 77 10 f0       	push   $0xf01077d8
f0103ebe:	e8 b5 f9 ff ff       	call   f0103878 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103ec3:	83 c4 10             	add    $0x10,%esp
f0103ec6:	3b 1d 60 fa 20 f0    	cmp    0xf020fa60,%ebx
f0103ecc:	75 1a                	jne    f0103ee8 <print_trapframe+0xaf>
f0103ece:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ed2:	75 14                	jne    f0103ee8 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103ed4:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103ed7:	83 ec 08             	sub    $0x8,%esp
f0103eda:	50                   	push   %eax
f0103edb:	68 ea 77 10 f0       	push   $0xf01077ea
f0103ee0:	e8 93 f9 ff ff       	call   f0103878 <cprintf>
f0103ee5:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103ee8:	83 ec 08             	sub    $0x8,%esp
f0103eeb:	ff 73 2c             	pushl  0x2c(%ebx)
f0103eee:	68 f9 77 10 f0       	push   $0xf01077f9
f0103ef3:	e8 80 f9 ff ff       	call   f0103878 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103ef8:	83 c4 10             	add    $0x10,%esp
f0103efb:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103eff:	75 49                	jne    f0103f4a <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f01:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103f04:	89 c2                	mov    %eax,%edx
f0103f06:	83 e2 01             	and    $0x1,%edx
f0103f09:	ba 78 77 10 f0       	mov    $0xf0107778,%edx
f0103f0e:	b9 6d 77 10 f0       	mov    $0xf010776d,%ecx
f0103f13:	0f 44 ca             	cmove  %edx,%ecx
f0103f16:	89 c2                	mov    %eax,%edx
f0103f18:	83 e2 02             	and    $0x2,%edx
f0103f1b:	ba 8a 77 10 f0       	mov    $0xf010778a,%edx
f0103f20:	be 84 77 10 f0       	mov    $0xf0107784,%esi
f0103f25:	0f 45 d6             	cmovne %esi,%edx
f0103f28:	83 e0 04             	and    $0x4,%eax
f0103f2b:	be d1 78 10 f0       	mov    $0xf01078d1,%esi
f0103f30:	b8 8f 77 10 f0       	mov    $0xf010778f,%eax
f0103f35:	0f 44 c6             	cmove  %esi,%eax
f0103f38:	51                   	push   %ecx
f0103f39:	52                   	push   %edx
f0103f3a:	50                   	push   %eax
f0103f3b:	68 07 78 10 f0       	push   $0xf0107807
f0103f40:	e8 33 f9 ff ff       	call   f0103878 <cprintf>
f0103f45:	83 c4 10             	add    $0x10,%esp
f0103f48:	eb 10                	jmp    f0103f5a <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103f4a:	83 ec 0c             	sub    $0xc,%esp
f0103f4d:	68 60 6b 10 f0       	push   $0xf0106b60
f0103f52:	e8 21 f9 ff ff       	call   f0103878 <cprintf>
f0103f57:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f5a:	83 ec 08             	sub    $0x8,%esp
f0103f5d:	ff 73 30             	pushl  0x30(%ebx)
f0103f60:	68 16 78 10 f0       	push   $0xf0107816
f0103f65:	e8 0e f9 ff ff       	call   f0103878 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f6a:	83 c4 08             	add    $0x8,%esp
f0103f6d:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103f71:	50                   	push   %eax
f0103f72:	68 25 78 10 f0       	push   $0xf0107825
f0103f77:	e8 fc f8 ff ff       	call   f0103878 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f7c:	83 c4 08             	add    $0x8,%esp
f0103f7f:	ff 73 38             	pushl  0x38(%ebx)
f0103f82:	68 38 78 10 f0       	push   $0xf0107838
f0103f87:	e8 ec f8 ff ff       	call   f0103878 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f8c:	83 c4 10             	add    $0x10,%esp
f0103f8f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f93:	74 25                	je     f0103fba <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f95:	83 ec 08             	sub    $0x8,%esp
f0103f98:	ff 73 3c             	pushl  0x3c(%ebx)
f0103f9b:	68 47 78 10 f0       	push   $0xf0107847
f0103fa0:	e8 d3 f8 ff ff       	call   f0103878 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103fa5:	83 c4 08             	add    $0x8,%esp
f0103fa8:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103fac:	50                   	push   %eax
f0103fad:	68 56 78 10 f0       	push   $0xf0107856
f0103fb2:	e8 c1 f8 ff ff       	call   f0103878 <cprintf>
f0103fb7:	83 c4 10             	add    $0x10,%esp
	}
}
f0103fba:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103fbd:	5b                   	pop    %ebx
f0103fbe:	5e                   	pop    %esi
f0103fbf:	5d                   	pop    %ebp
f0103fc0:	c3                   	ret    

f0103fc1 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103fc1:	55                   	push   %ebp
f0103fc2:	89 e5                	mov    %esp,%ebp
f0103fc4:	57                   	push   %edi
f0103fc5:	56                   	push   %esi
f0103fc6:	53                   	push   %ebx
f0103fc7:	83 ec 1c             	sub    $0x1c,%esp
f0103fca:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103fcd:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f0103fd0:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103fd4:	75 15                	jne    f0103feb <page_fault_handler+0x2a>
		panic("page fault in kernel at %x!", fault_va);
f0103fd6:	56                   	push   %esi
f0103fd7:	68 69 78 10 f0       	push   $0xf0107869
f0103fdc:	68 5b 01 00 00       	push   $0x15b
f0103fe1:	68 85 78 10 f0       	push   $0xf0107885
f0103fe6:	e8 55 c0 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f0103feb:	e8 02 1c 00 00       	call   f0105bf2 <cpunum>
f0103ff0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff3:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f0103ff9:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103ffd:	0f 84 af 00 00 00    	je     f01040b2 <page_fault_handler+0xf1>
		uint32_t estack_top = UXSTACKTOP;

		// if pgfault happens in user exception stack
		// as mentioned above, we push things right after the previous exception stack 
		// started with dummy 4 bytes
		if (tf->tf_esp < UXSTACKTOP && tf->tf_esp >= UXSTACKTOP - PGSIZE)
f0104003:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104006:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			estack_top = tf->tf_esp - 4;
f010400c:	83 e8 04             	sub    $0x4,%eax
f010400f:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104015:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f010401a:	0f 46 f8             	cmovbe %eax,%edi

		// char* utrapframe = (char *)(estack_top - sizeof(struct UTrapframe));
		struct UTrapframe *utf = (struct UTrapframe *)(estack_top - sizeof(struct UTrapframe));
f010401d:	8d 47 cc             	lea    -0x34(%edi),%eax
f0104020:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// do a memory check
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_W | PTE_P);
f0104023:	e8 ca 1b 00 00       	call   f0105bf2 <cpunum>
f0104028:	6a 03                	push   $0x3
f010402a:	6a 34                	push   $0x34
f010402c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010402f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104032:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f0104038:	e8 17 ef ff ff       	call   f0102f54 <user_mem_assert>

		// copy context to utrapframe 
		// memcpy(utrapframe, (char *)tf, sizeof(struct UTrapframe));
		// *(uint32_t *)utrapframe = fault_va;
		utf->utf_fault_va = fault_va;
f010403d:	89 77 cc             	mov    %esi,-0x34(%edi)
        utf->utf_err      = tf->tf_trapno;
f0104040:	8b 43 28             	mov    0x28(%ebx),%eax
f0104043:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104046:	89 42 04             	mov    %eax,0x4(%edx)
        utf->utf_regs     = tf->tf_regs;
f0104049:	83 ef 2c             	sub    $0x2c,%edi
f010404c:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104051:	89 de                	mov    %ebx,%esi
f0104053:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        utf->utf_eflags   = tf->tf_eflags;
f0104055:	8b 43 38             	mov    0x38(%ebx),%eax
f0104058:	89 42 2c             	mov    %eax,0x2c(%edx)
        utf->utf_eip      = tf->tf_eip;
f010405b:	8b 43 30             	mov    0x30(%ebx),%eax
f010405e:	89 d6                	mov    %edx,%esi
f0104060:	89 42 28             	mov    %eax,0x28(%edx)
        utf->utf_esp      = tf->tf_esp;
f0104063:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104066:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_esp = (uint32_t)utf;
f0104069:	e8 84 1b 00 00       	call   f0105bf2 <cpunum>
f010406e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104071:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f0104077:	89 70 3c             	mov    %esi,0x3c(%eax)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f010407a:	e8 73 1b 00 00       	call   f0105bf2 <cpunum>
f010407f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104082:	8b 98 28 00 21 f0    	mov    -0xfdeffd8(%eax),%ebx
f0104088:	e8 65 1b 00 00       	call   f0105bf2 <cpunum>
f010408d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104090:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f0104096:	8b 40 64             	mov    0x64(%eax),%eax
f0104099:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f010409c:	e8 51 1b 00 00       	call   f0105bf2 <cpunum>
f01040a1:	83 c4 04             	add    $0x4,%esp
f01040a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01040a7:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f01040ad:	e8 64 f5 ff ff       	call   f0103616 <env_run>

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040b2:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01040b5:	e8 38 1b 00 00       	call   f0105bf2 <cpunum>
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040ba:	57                   	push   %edi
f01040bb:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01040bc:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);

	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040bf:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01040c5:	ff 70 48             	pushl  0x48(%eax)
f01040c8:	68 1c 7a 10 f0       	push   $0xf0107a1c
f01040cd:	e8 a6 f7 ff ff       	call   f0103878 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01040d2:	89 1c 24             	mov    %ebx,(%esp)
f01040d5:	e8 5f fd ff ff       	call   f0103e39 <print_trapframe>
	env_destroy(curenv);
f01040da:	e8 13 1b 00 00       	call   f0105bf2 <cpunum>
f01040df:	83 c4 04             	add    $0x4,%esp
f01040e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e5:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f01040eb:	e8 87 f4 ff ff       	call   f0103577 <env_destroy>
}
f01040f0:	83 c4 10             	add    $0x10,%esp
f01040f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040f6:	5b                   	pop    %ebx
f01040f7:	5e                   	pop    %esi
f01040f8:	5f                   	pop    %edi
f01040f9:	5d                   	pop    %ebp
f01040fa:	c3                   	ret    

f01040fb <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01040fb:	55                   	push   %ebp
f01040fc:	89 e5                	mov    %esp,%ebp
f01040fe:	57                   	push   %edi
f01040ff:	56                   	push   %esi
f0104100:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104103:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104104:	83 3d 80 fe 20 f0 00 	cmpl   $0x0,0xf020fe80
f010410b:	74 01                	je     f010410e <trap+0x13>
		asm volatile("hlt");
f010410d:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010410e:	e8 df 1a 00 00       	call   f0105bf2 <cpunum>
f0104113:	6b d0 74             	imul   $0x74,%eax,%edx
f0104116:	81 c2 20 00 21 f0    	add    $0xf0210020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010411c:	b8 01 00 00 00       	mov    $0x1,%eax
f0104121:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104125:	83 f8 02             	cmp    $0x2,%eax
f0104128:	75 10                	jne    f010413a <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010412a:	83 ec 0c             	sub    $0xc,%esp
f010412d:	68 c0 03 12 f0       	push   $0xf01203c0
f0104132:	e8 29 1d 00 00       	call   f0105e60 <spin_lock>
f0104137:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010413a:	9c                   	pushf  
f010413b:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010413c:	f6 c4 02             	test   $0x2,%ah
f010413f:	74 19                	je     f010415a <trap+0x5f>
f0104141:	68 91 78 10 f0       	push   $0xf0107891
f0104146:	68 85 68 10 f0       	push   $0xf0106885
f010414b:	68 23 01 00 00       	push   $0x123
f0104150:	68 85 78 10 f0       	push   $0xf0107885
f0104155:	e8 e6 be ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010415a:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010415e:	83 e0 03             	and    $0x3,%eax
f0104161:	66 83 f8 03          	cmp    $0x3,%ax
f0104165:	0f 85 a0 00 00 00    	jne    f010420b <trap+0x110>
f010416b:	83 ec 0c             	sub    $0xc,%esp
f010416e:	68 c0 03 12 f0       	push   $0xf01203c0
f0104173:	e8 e8 1c 00 00       	call   f0105e60 <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f0104178:	e8 75 1a 00 00       	call   f0105bf2 <cpunum>
f010417d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104180:	83 c4 10             	add    $0x10,%esp
f0104183:	83 b8 28 00 21 f0 00 	cmpl   $0x0,-0xfdeffd8(%eax)
f010418a:	75 19                	jne    f01041a5 <trap+0xaa>
f010418c:	68 aa 78 10 f0       	push   $0xf01078aa
f0104191:	68 85 68 10 f0       	push   $0xf0106885
f0104196:	68 2d 01 00 00       	push   $0x12d
f010419b:	68 85 78 10 f0       	push   $0xf0107885
f01041a0:	e8 9b be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01041a5:	e8 48 1a 00 00       	call   f0105bf2 <cpunum>
f01041aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01041ad:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01041b3:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01041b7:	75 2d                	jne    f01041e6 <trap+0xeb>
			env_free(curenv);
f01041b9:	e8 34 1a 00 00       	call   f0105bf2 <cpunum>
f01041be:	83 ec 0c             	sub    $0xc,%esp
f01041c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01041c4:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f01041ca:	e8 02 f2 ff ff       	call   f01033d1 <env_free>
			curenv = NULL;
f01041cf:	e8 1e 1a 00 00       	call   f0105bf2 <cpunum>
f01041d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01041d7:	c7 80 28 00 21 f0 00 	movl   $0x0,-0xfdeffd8(%eax)
f01041de:	00 00 00 
			sched_yield();
f01041e1:	e8 98 02 00 00       	call   f010447e <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01041e6:	e8 07 1a 00 00       	call   f0105bf2 <cpunum>
f01041eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01041ee:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01041f4:	b9 11 00 00 00       	mov    $0x11,%ecx
f01041f9:	89 c7                	mov    %eax,%edi
f01041fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01041fd:	e8 f0 19 00 00       	call   f0105bf2 <cpunum>
f0104202:	6b c0 74             	imul   $0x74,%eax,%eax
f0104205:	8b b0 28 00 21 f0    	mov    -0xfdeffd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010420b:	89 35 60 fa 20 f0    	mov    %esi,0xf020fa60
 
	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	struct PushRegs* r = &tf->tf_regs;

	switch(tf->tf_trapno) {
f0104211:	8b 46 28             	mov    0x28(%esi),%eax
f0104214:	83 f8 0e             	cmp    $0xe,%eax
f0104217:	74 18                	je     f0104231 <trap+0x136>
f0104219:	83 f8 0e             	cmp    $0xe,%eax
f010421c:	77 07                	ja     f0104225 <trap+0x12a>
f010421e:	83 f8 03             	cmp    $0x3,%eax
f0104221:	74 1f                	je     f0104242 <trap+0x147>
f0104223:	eb 56                	jmp    f010427b <trap+0x180>
f0104225:	83 f8 20             	cmp    $0x20,%eax
f0104228:	74 47                	je     f0104271 <trap+0x176>
f010422a:	83 f8 30             	cmp    $0x30,%eax
f010422d:	74 21                	je     f0104250 <trap+0x155>
f010422f:	eb 4a                	jmp    f010427b <trap+0x180>
		case (T_PGFLT):
			page_fault_handler(tf);
f0104231:	83 ec 0c             	sub    $0xc,%esp
f0104234:	56                   	push   %esi
f0104235:	e8 87 fd ff ff       	call   f0103fc1 <page_fault_handler>
f010423a:	83 c4 10             	add    $0x10,%esp
f010423d:	e9 89 00 00 00       	jmp    f01042cb <trap+0x1d0>
			break;
		case (T_BRKPT):
			monitor(tf);	// open a JOS monitor
f0104242:	83 ec 0c             	sub    $0xc,%esp
f0104245:	56                   	push   %esi
f0104246:	e8 5c c7 ff ff       	call   f01009a7 <monitor>
f010424b:	83 c4 10             	add    $0x10,%esp
f010424e:	eb 7b                	jmp    f01042cb <trap+0x1d0>
			break;
		case (T_SYSCALL):
			// call syscall in kern/syscall.c
			r->reg_eax = syscall(r->reg_eax, r->reg_edx, r->reg_ecx, r->reg_ebx, r->reg_edi, r->reg_esi);
f0104250:	83 ec 08             	sub    $0x8,%esp
f0104253:	ff 76 04             	pushl  0x4(%esi)
f0104256:	ff 36                	pushl  (%esi)
f0104258:	ff 76 10             	pushl  0x10(%esi)
f010425b:	ff 76 18             	pushl  0x18(%esi)
f010425e:	ff 76 14             	pushl  0x14(%esi)
f0104261:	ff 76 1c             	pushl  0x1c(%esi)
f0104264:	e8 9e 02 00 00       	call   f0104507 <syscall>
f0104269:	89 46 1c             	mov    %eax,0x1c(%esi)
f010426c:	83 c4 20             	add    $0x20,%esp
f010426f:	eb 5a                	jmp    f01042cb <trap+0x1d0>
			break;
		case (IRQ_OFFSET + IRQ_TIMER):
			lapic_eoi();	// Acknowledge interrupt.
f0104271:	e8 c7 1a 00 00       	call   f0105d3d <lapic_eoi>
			sched_yield();
f0104276:	e8 03 02 00 00       	call   f010447e <sched_yield>
			break;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			cprintf("[trapno: %x]\n", tf->tf_trapno);
f010427b:	83 ec 08             	sub    $0x8,%esp
f010427e:	50                   	push   %eax
f010427f:	68 b1 78 10 f0       	push   $0xf01078b1
f0104284:	e8 ef f5 ff ff       	call   f0103878 <cprintf>
			print_trapframe(tf);
f0104289:	89 34 24             	mov    %esi,(%esp)
f010428c:	e8 a8 fb ff ff       	call   f0103e39 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0104291:	83 c4 10             	add    $0x10,%esp
f0104294:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104299:	75 17                	jne    f01042b2 <trap+0x1b7>
				panic("unhandled trap in kernel");
f010429b:	83 ec 04             	sub    $0x4,%esp
f010429e:	68 bf 78 10 f0       	push   $0xf01078bf
f01042a3:	68 08 01 00 00       	push   $0x108
f01042a8:	68 85 78 10 f0       	push   $0xf0107885
f01042ad:	e8 8e bd ff ff       	call   f0100040 <_panic>
			else {
				env_destroy(curenv);
f01042b2:	e8 3b 19 00 00       	call   f0105bf2 <cpunum>
f01042b7:	83 ec 0c             	sub    $0xc,%esp
f01042ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01042bd:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f01042c3:	e8 af f2 ff ff       	call   f0103577 <env_destroy>
f01042c8:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01042cb:	e8 22 19 00 00       	call   f0105bf2 <cpunum>
f01042d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01042d3:	83 b8 28 00 21 f0 00 	cmpl   $0x0,-0xfdeffd8(%eax)
f01042da:	74 2a                	je     f0104306 <trap+0x20b>
f01042dc:	e8 11 19 00 00       	call   f0105bf2 <cpunum>
f01042e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01042e4:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01042ea:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042ee:	75 16                	jne    f0104306 <trap+0x20b>
		env_run(curenv);
f01042f0:	e8 fd 18 00 00       	call   f0105bf2 <cpunum>
f01042f5:	83 ec 0c             	sub    $0xc,%esp
f01042f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01042fb:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f0104301:	e8 10 f3 ff ff       	call   f0103616 <env_run>
	else
		sched_yield();
f0104306:	e8 73 01 00 00       	call   f010447e <sched_yield>
f010430b:	90                   	nop

f010430c <_T_DIVIDE_handler>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */


TRAPHANDLER_NOEC(_T_DIVIDE_handler, T_DIVIDE)
f010430c:	6a 00                	push   $0x0
f010430e:	6a 00                	push   $0x0
f0104310:	e9 83 00 00 00       	jmp    f0104398 <_alltraps>
f0104315:	90                   	nop

f0104316 <_T_DEBUG_handler>:
TRAPHANDLER_NOEC(_T_DEBUG_handler, T_DEBUG)
f0104316:	6a 00                	push   $0x0
f0104318:	6a 01                	push   $0x1
f010431a:	eb 7c                	jmp    f0104398 <_alltraps>

f010431c <_T_NMI_handler>:
TRAPHANDLER_NOEC(_T_NMI_handler, T_NMI)
f010431c:	6a 00                	push   $0x0
f010431e:	6a 02                	push   $0x2
f0104320:	eb 76                	jmp    f0104398 <_alltraps>

f0104322 <_T_BRKPT_handler>:
TRAPHANDLER_NOEC(_T_BRKPT_handler, T_BRKPT)
f0104322:	6a 00                	push   $0x0
f0104324:	6a 03                	push   $0x3
f0104326:	eb 70                	jmp    f0104398 <_alltraps>

f0104328 <_T_OFLOW_handler>:
TRAPHANDLER_NOEC(_T_OFLOW_handler, T_OFLOW)
f0104328:	6a 00                	push   $0x0
f010432a:	6a 04                	push   $0x4
f010432c:	eb 6a                	jmp    f0104398 <_alltraps>

f010432e <_T_BOUND_handler>:
TRAPHANDLER_NOEC(_T_BOUND_handler, T_BOUND)
f010432e:	6a 00                	push   $0x0
f0104330:	6a 05                	push   $0x5
f0104332:	eb 64                	jmp    f0104398 <_alltraps>

f0104334 <_T_ILLOP_handler>:
TRAPHANDLER_NOEC(_T_ILLOP_handler, T_ILLOP)
f0104334:	6a 00                	push   $0x0
f0104336:	6a 06                	push   $0x6
f0104338:	eb 5e                	jmp    f0104398 <_alltraps>

f010433a <_T_DEVICE_handler>:
TRAPHANDLER_NOEC(_T_DEVICE_handler, T_DEVICE)
f010433a:	6a 00                	push   $0x0
f010433c:	6a 07                	push   $0x7
f010433e:	eb 58                	jmp    f0104398 <_alltraps>

f0104340 <_T_DBLFLT_handler>:
TRAPHANDLER(_T_DBLFLT_handler, T_DBLFLT)
f0104340:	6a 08                	push   $0x8
f0104342:	eb 54                	jmp    f0104398 <_alltraps>

f0104344 <_T_TSS_handler>:
TRAPHANDLER(_T_TSS_handler, T_TSS)
f0104344:	6a 0a                	push   $0xa
f0104346:	eb 50                	jmp    f0104398 <_alltraps>

f0104348 <_T_SEGNP_handler>:
TRAPHANDLER(_T_SEGNP_handler, T_SEGNP)
f0104348:	6a 0b                	push   $0xb
f010434a:	eb 4c                	jmp    f0104398 <_alltraps>

f010434c <_T_STACK_handler>:
TRAPHANDLER(_T_STACK_handler, T_STACK)
f010434c:	6a 0c                	push   $0xc
f010434e:	eb 48                	jmp    f0104398 <_alltraps>

f0104350 <_T_GPFLT_handler>:
TRAPHANDLER(_T_GPFLT_handler, T_GPFLT)
f0104350:	6a 0d                	push   $0xd
f0104352:	eb 44                	jmp    f0104398 <_alltraps>

f0104354 <_T_PGFLT_handler>:
TRAPHANDLER(_T_PGFLT_handler, T_PGFLT)
f0104354:	6a 0e                	push   $0xe
f0104356:	eb 40                	jmp    f0104398 <_alltraps>

f0104358 <_T_FPERR_handler>:
TRAPHANDLER_NOEC(_T_FPERR_handler, T_FPERR)
f0104358:	6a 00                	push   $0x0
f010435a:	6a 10                	push   $0x10
f010435c:	eb 3a                	jmp    f0104398 <_alltraps>

f010435e <_T_ALIGN_handler>:
TRAPHANDLER(_T_ALIGN_handler, T_ALIGN)
f010435e:	6a 11                	push   $0x11
f0104360:	eb 36                	jmp    f0104398 <_alltraps>

f0104362 <_T_MCHK_handler>:
TRAPHANDLER_NOEC(_T_MCHK_handler, T_MCHK)
f0104362:	6a 00                	push   $0x0
f0104364:	6a 12                	push   $0x12
f0104366:	eb 30                	jmp    f0104398 <_alltraps>

f0104368 <_T_SIMDERR_handler>:
TRAPHANDLER_NOEC(_T_SIMDERR_handler, T_SIMDERR)
f0104368:	6a 00                	push   $0x0
f010436a:	6a 13                	push   $0x13
f010436c:	eb 2a                	jmp    f0104398 <_alltraps>

f010436e <_T_SYSCALL_handler>:
TRAPHANDLER_NOEC(_T_SYSCALL_handler, T_SYSCALL)
f010436e:	6a 00                	push   $0x0
f0104370:	6a 30                	push   $0x30
f0104372:	eb 24                	jmp    f0104398 <_alltraps>

f0104374 <_IRQ_TIMER_handler>:

TRAPHANDLER_NOEC(_IRQ_TIMER_handler, IRQ_TIMER + IRQ_OFFSET)
f0104374:	6a 00                	push   $0x0
f0104376:	6a 20                	push   $0x20
f0104378:	eb 1e                	jmp    f0104398 <_alltraps>

f010437a <_IRQ_KBD_handler>:
TRAPHANDLER_NOEC(_IRQ_KBD_handler, IRQ_KBD + IRQ_OFFSET)
f010437a:	6a 00                	push   $0x0
f010437c:	6a 21                	push   $0x21
f010437e:	eb 18                	jmp    f0104398 <_alltraps>

f0104380 <_IRQ_SERIAL_handler>:
TRAPHANDLER_NOEC(_IRQ_SERIAL_handler, IRQ_SERIAL + IRQ_OFFSET)
f0104380:	6a 00                	push   $0x0
f0104382:	6a 24                	push   $0x24
f0104384:	eb 12                	jmp    f0104398 <_alltraps>

f0104386 <_IRQ_SPURIOUS_handler>:
TRAPHANDLER_NOEC(_IRQ_SPURIOUS_handler, IRQ_SPURIOUS + IRQ_OFFSET)
f0104386:	6a 00                	push   $0x0
f0104388:	6a 27                	push   $0x27
f010438a:	eb 0c                	jmp    f0104398 <_alltraps>

f010438c <_IRQ_IDE_handler>:
TRAPHANDLER_NOEC(_IRQ_IDE_handler, IRQ_IDE + IRQ_OFFSET)
f010438c:	6a 00                	push   $0x0
f010438e:	6a 2e                	push   $0x2e
f0104390:	eb 06                	jmp    f0104398 <_alltraps>

f0104392 <_IRQ_ERROR_handler>:
TRAPHANDLER_NOEC(_IRQ_ERROR_handler, IRQ_ERROR + IRQ_OFFSET)
f0104392:	6a 00                	push   $0x0
f0104394:	6a 33                	push   $0x33
f0104396:	eb 00                	jmp    f0104398 <_alltraps>

f0104398 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
f0104398:	1e                   	push   %ds
	pushl %es
f0104399:	06                   	push   %es
	pushal	/* push all general registers */
f010439a:	60                   	pusha  

	movl $GD_KD, %eax
f010439b:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f01043a0:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f01043a2:	8e c0                	mov    %eax,%es

	push %esp
f01043a4:	54                   	push   %esp
f01043a5:	e8 51 fd ff ff       	call   f01040fb <trap>

f01043aa <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01043aa:	55                   	push   %ebp
f01043ab:	89 e5                	mov    %esp,%ebp
f01043ad:	83 ec 08             	sub    $0x8,%esp
f01043b0:	a1 48 f2 20 f0       	mov    0xf020f248,%eax
f01043b5:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01043b8:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01043bd:	8b 02                	mov    (%edx),%eax
f01043bf:	83 e8 01             	sub    $0x1,%eax
f01043c2:	83 f8 02             	cmp    $0x2,%eax
f01043c5:	76 10                	jbe    f01043d7 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01043c7:	83 c1 01             	add    $0x1,%ecx
f01043ca:	83 c2 7c             	add    $0x7c,%edx
f01043cd:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01043d3:	75 e8                	jne    f01043bd <sched_halt+0x13>
f01043d5:	eb 08                	jmp    f01043df <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01043d7:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01043dd:	75 1f                	jne    f01043fe <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01043df:	83 ec 0c             	sub    $0xc,%esp
f01043e2:	68 90 7a 10 f0       	push   $0xf0107a90
f01043e7:	e8 8c f4 ff ff       	call   f0103878 <cprintf>
f01043ec:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01043ef:	83 ec 0c             	sub    $0xc,%esp
f01043f2:	6a 00                	push   $0x0
f01043f4:	e8 ae c5 ff ff       	call   f01009a7 <monitor>
f01043f9:	83 c4 10             	add    $0x10,%esp
f01043fc:	eb f1                	jmp    f01043ef <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01043fe:	e8 ef 17 00 00       	call   f0105bf2 <cpunum>
f0104403:	6b c0 74             	imul   $0x74,%eax,%eax
f0104406:	c7 80 28 00 21 f0 00 	movl   $0x0,-0xfdeffd8(%eax)
f010440d:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104410:	a1 8c fe 20 f0       	mov    0xf020fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104415:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010441a:	77 12                	ja     f010442e <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010441c:	50                   	push   %eax
f010441d:	68 c8 62 10 f0       	push   $0xf01062c8
f0104422:	6a 52                	push   $0x52
f0104424:	68 b9 7a 10 f0       	push   $0xf0107ab9
f0104429:	e8 12 bc ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010442e:	05 00 00 00 10       	add    $0x10000000,%eax
f0104433:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104436:	e8 b7 17 00 00       	call   f0105bf2 <cpunum>
f010443b:	6b d0 74             	imul   $0x74,%eax,%edx
f010443e:	81 c2 20 00 21 f0    	add    $0xf0210020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104444:	b8 02 00 00 00       	mov    $0x2,%eax
f0104449:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010444d:	83 ec 0c             	sub    $0xc,%esp
f0104450:	68 c0 03 12 f0       	push   $0xf01203c0
f0104455:	e8 a3 1a 00 00       	call   f0105efd <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010445a:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010445c:	e8 91 17 00 00       	call   f0105bf2 <cpunum>
f0104461:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104464:	8b 80 30 00 21 f0    	mov    -0xfdeffd0(%eax),%eax
f010446a:	bd 00 00 00 00       	mov    $0x0,%ebp
f010446f:	89 c4                	mov    %eax,%esp
f0104471:	6a 00                	push   $0x0
f0104473:	6a 00                	push   $0x0
f0104475:	fb                   	sti    
f0104476:	f4                   	hlt    
f0104477:	eb fd                	jmp    f0104476 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104479:	83 c4 10             	add    $0x10,%esp
f010447c:	c9                   	leave  
f010447d:	c3                   	ret    

f010447e <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010447e:	55                   	push   %ebp
f010447f:	89 e5                	mov    %esp,%ebp
f0104481:	56                   	push   %esi
f0104482:	53                   	push   %ebx
	// below to halt the cpu.

	// LAB 4: Your code here.
	// cprintf("[yield]\n");

	struct Env *now = thiscpu->cpu_env;
f0104483:	e8 6a 17 00 00       	call   f0105bf2 <cpunum>
f0104488:	6b c0 74             	imul   $0x74,%eax,%eax
f010448b:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
    int32_t startid = (now) ? ENVX(now->env_id): 0;
f0104491:	85 c0                	test   %eax,%eax
f0104493:	74 0b                	je     f01044a0 <sched_yield+0x22>
f0104495:	8b 50 48             	mov    0x48(%eax),%edx
f0104498:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010449e:	eb 05                	jmp    f01044a5 <sched_yield+0x27>
f01044a0:	ba 00 00 00 00       	mov    $0x0,%edx
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
        nextid = (startid+i)%NENV;
        if(envs[nextid].env_status == ENV_RUNNABLE) {
f01044a5:	8b 0d 48 f2 20 f0    	mov    0xf020f248,%ecx
f01044ab:	89 d6                	mov    %edx,%esi
f01044ad:	8d 9a 00 04 00 00    	lea    0x400(%edx),%ebx
f01044b3:	89 d0                	mov    %edx,%eax
f01044b5:	25 ff 03 00 00       	and    $0x3ff,%eax
f01044ba:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01044bd:	01 c8                	add    %ecx,%eax
f01044bf:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01044c3:	75 09                	jne    f01044ce <sched_yield+0x50>
                env_run(&envs[nextid]);
f01044c5:	83 ec 0c             	sub    $0xc,%esp
f01044c8:	50                   	push   %eax
f01044c9:	e8 48 f1 ff ff       	call   f0103616 <env_run>
f01044ce:	83 c2 01             	add    $0x1,%edx
	struct Env *now = thiscpu->cpu_env;
    int32_t startid = (now) ? ENVX(now->env_id): 0;
    int32_t nextid;
    size_t i;

    for(i = 0; i < NENV; i++) {
f01044d1:	39 da                	cmp    %ebx,%edx
f01044d3:	75 de                	jne    f01044b3 <sched_yield+0x35>
                env_run(&envs[nextid]);
                return;
            }
    }
    
    if(envs[startid].env_status == ENV_RUNNING && envs[startid].env_cpunum == cpunum()) {
f01044d5:	6b f6 7c             	imul   $0x7c,%esi,%esi
f01044d8:	01 f1                	add    %esi,%ecx
f01044da:	83 79 54 03          	cmpl   $0x3,0x54(%ecx)
f01044de:	75 1b                	jne    f01044fb <sched_yield+0x7d>
f01044e0:	8b 59 5c             	mov    0x5c(%ecx),%ebx
f01044e3:	e8 0a 17 00 00       	call   f0105bf2 <cpunum>
f01044e8:	39 c3                	cmp    %eax,%ebx
f01044ea:	75 0f                	jne    f01044fb <sched_yield+0x7d>
        env_run(&envs[startid]);
f01044ec:	83 ec 0c             	sub    $0xc,%esp
f01044ef:	03 35 48 f2 20 f0    	add    0xf020f248,%esi
f01044f5:	56                   	push   %esi
f01044f6:	e8 1b f1 ff ff       	call   f0103616 <env_run>
    }

	// cprintf("[halt]\n");

	// sched_halt never returns
	sched_halt();
f01044fb:	e8 aa fe ff ff       	call   f01043aa <sched_halt>
}
f0104500:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104503:	5b                   	pop    %ebx
f0104504:	5e                   	pop    %esi
f0104505:	5d                   	pop    %ebp
f0104506:	c3                   	ret    

f0104507 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104507:	55                   	push   %ebp
f0104508:	89 e5                	mov    %esp,%ebp
f010450a:	57                   	push   %edi
f010450b:	56                   	push   %esi
f010450c:	53                   	push   %ebx
f010450d:	83 ec 1c             	sub    $0x1c,%esp
f0104510:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f0104513:	83 f8 0d             	cmp    $0xd,%eax
f0104516:	0f 87 18 05 00 00    	ja     f0104a34 <syscall+0x52d>
f010451c:	ff 24 85 cc 7a 10 f0 	jmp    *-0xfef8534(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);		// just check if PTE_U is set
f0104523:	e8 ca 16 00 00       	call   f0105bf2 <cpunum>
f0104528:	6a 00                	push   $0x0
f010452a:	ff 75 10             	pushl  0x10(%ebp)
f010452d:	ff 75 0c             	pushl  0xc(%ebp)
f0104530:	6b c0 74             	imul   $0x74,%eax,%eax
f0104533:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f0104539:	e8 16 ea ff ff       	call   f0102f54 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010453e:	83 c4 0c             	add    $0xc,%esp
f0104541:	ff 75 0c             	pushl  0xc(%ebp)
f0104544:	ff 75 10             	pushl  0x10(%ebp)
f0104547:	68 c6 7a 10 f0       	push   $0xf0107ac6
f010454c:	e8 27 f3 ff ff       	call   f0103878 <cprintf>
f0104551:	83 c4 10             	add    $0x10,%esp
	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
f0104554:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104559:	e9 e2 04 00 00       	jmp    f0104a40 <syscall+0x539>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010455e:	e8 8f c0 ff ff       	call   f01005f2 <cons_getc>
f0104563:	89 c3                	mov    %eax,%ebx
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f0104565:	e9 d6 04 00 00       	jmp    f0104a40 <syscall+0x539>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010456a:	e8 83 16 00 00       	call   f0105bf2 <cpunum>
f010456f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104572:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f0104578:	8b 58 48             	mov    0x48(%eax),%ebx
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f010457b:	e9 c0 04 00 00       	jmp    f0104a40 <syscall+0x539>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104580:	83 ec 04             	sub    $0x4,%esp
f0104583:	6a 01                	push   $0x1
f0104585:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104588:	50                   	push   %eax
f0104589:	ff 75 0c             	pushl  0xc(%ebp)
f010458c:	e8 91 ea ff ff       	call   f0103022 <envid2env>
f0104591:	83 c4 10             	add    $0x10,%esp
		return r;
f0104594:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104596:	85 c0                	test   %eax,%eax
f0104598:	0f 88 a2 04 00 00    	js     f0104a40 <syscall+0x539>
		return r;
	env_destroy(e);
f010459e:	83 ec 0c             	sub    $0xc,%esp
f01045a1:	ff 75 e4             	pushl  -0x1c(%ebp)
f01045a4:	e8 ce ef ff ff       	call   f0103577 <env_destroy>
f01045a9:	83 c4 10             	add    $0x10,%esp
	return 0;
f01045ac:	bb 00 00 00 00       	mov    $0x0,%ebx
f01045b1:	e9 8a 04 00 00       	jmp    f0104a40 <syscall+0x539>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01045b6:	e8 c3 fe ff ff       	call   f010447e <sched_yield>
	// LAB 4: Your code here.
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
f01045bb:	e8 32 16 00 00       	call   f0105bf2 <cpunum>
f01045c0:	83 ec 08             	sub    $0x8,%esp
f01045c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c6:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01045cc:	ff 70 48             	pushl  0x48(%eax)
f01045cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045d2:	50                   	push   %eax
f01045d3:	e8 55 eb ff ff       	call   f010312d <env_alloc>
	if (err < 0)
f01045d8:	83 c4 10             	add    $0x10,%esp
		return err;
f01045db:	89 c3                	mov    %eax,%ebx
	// panic("sys_exofork not implemented");

	struct Env *newenv;

	int err = env_alloc(&newenv , curenv->env_id);
	if (err < 0)
f01045dd:	85 c0                	test   %eax,%eax
f01045df:	0f 88 5b 04 00 00    	js     f0104a40 <syscall+0x539>
		return err;

	// memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
	newenv->env_tf = curenv->env_tf;
f01045e5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01045e8:	e8 05 16 00 00       	call   f0105bf2 <cpunum>
f01045ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01045f0:	8b b0 28 00 21 f0    	mov    -0xfdeffd8(%eax),%esi
f01045f6:	b9 11 00 00 00       	mov    $0x11,%ecx
f01045fb:	89 df                	mov    %ebx,%edi
f01045fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_status = ENV_NOT_RUNNABLE;
f01045ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104602:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	// tweak newenv, to make it appear to return 0
	newenv->env_tf.tf_regs.reg_eax = 0;
f0104609:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return newenv->env_id;
f0104610:	8b 58 48             	mov    0x48(%eax),%ebx
f0104613:	e9 28 04 00 00       	jmp    f0104a40 <syscall+0x539>

	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104618:	83 ec 04             	sub    $0x4,%esp
f010461b:	6a 01                	push   $0x1
f010461d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104620:	50                   	push   %eax
f0104621:	ff 75 0c             	pushl  0xc(%ebp)
f0104624:	e8 f9 e9 ff ff       	call   f0103022 <envid2env>
	if (err < 0)
f0104629:	83 c4 10             	add    $0x10,%esp
f010462c:	85 c0                	test   %eax,%eax
f010462e:	78 20                	js     f0104650 <syscall+0x149>
		return err;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104630:	8b 45 10             	mov    0x10(%ebp),%eax
f0104633:	83 e8 02             	sub    $0x2,%eax
f0104636:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f010463b:	75 1a                	jne    f0104657 <syscall+0x150>
		return -E_INVAL;

	env_store->env_status = status;
f010463d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104640:	8b 55 10             	mov    0x10(%ebp),%edx
f0104643:	89 50 54             	mov    %edx,0x54(%eax)

	return 0;
f0104646:	bb 00 00 00 00       	mov    $0x0,%ebx
f010464b:	e9 f0 03 00 00       	jmp    f0104a40 <syscall+0x539>
	// panic("sys_env_set_status not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f0104650:	89 c3                	mov    %eax,%ebx
f0104652:	e9 e9 03 00 00       	jmp    f0104a40 <syscall+0x539>

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f0104657:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
f010465c:	e9 df 03 00 00       	jmp    f0104a40 <syscall+0x539>

	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104661:	83 ec 04             	sub    $0x4,%esp
f0104664:	6a 01                	push   $0x1
f0104666:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104669:	50                   	push   %eax
f010466a:	ff 75 0c             	pushl  0xc(%ebp)
f010466d:	e8 b0 e9 ff ff       	call   f0103022 <envid2env>
	if (err < 0)
f0104672:	83 c4 10             	add    $0x10,%esp
f0104675:	85 c0                	test   %eax,%eax
f0104677:	78 6b                	js     f01046e4 <syscall+0x1dd>
		return err;	// E_BAD_ENV

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f0104679:	8b 45 14             	mov    0x14(%ebp),%eax
f010467c:	0d 02 0e 00 00       	or     $0xe02,%eax
f0104681:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104686:	75 63                	jne    f01046eb <syscall+0x1e4>
f0104688:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010468f:	77 5a                	ja     f01046eb <syscall+0x1e4>
f0104691:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104698:	75 5b                	jne    f01046f5 <syscall+0x1ee>
		return -E_INVAL;
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
f010469a:	83 ec 0c             	sub    $0xc,%esp
f010469d:	6a 01                	push   $0x1
f010469f:	e8 f4 c9 ff ff       	call   f0101098 <page_alloc>
f01046a4:	89 c6                	mov    %eax,%esi
	if (pp == NULL)
f01046a6:	83 c4 10             	add    $0x10,%esp
f01046a9:	85 c0                	test   %eax,%eax
f01046ab:	74 52                	je     f01046ff <syscall+0x1f8>
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
f01046ad:	ff 75 14             	pushl  0x14(%ebp)
f01046b0:	ff 75 10             	pushl  0x10(%ebp)
f01046b3:	50                   	push   %eax
f01046b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046b7:	ff 70 60             	pushl  0x60(%eax)
f01046ba:	e8 07 cd ff ff       	call   f01013c6 <page_insert>
f01046bf:	89 c7                	mov    %eax,%edi
	if (err < 0) {
f01046c1:	83 c4 10             	add    $0x10,%esp
		page_free(pp);
		return err; // E_NO_MEM
	}

	return 0;
f01046c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
	
	err = page_insert(env_store->env_pgdir, pp, va, perm);
	if (err < 0) {
f01046c9:	85 c0                	test   %eax,%eax
f01046cb:	0f 89 6f 03 00 00    	jns    f0104a40 <syscall+0x539>
		page_free(pp);
f01046d1:	83 ec 0c             	sub    $0xc,%esp
f01046d4:	56                   	push   %esi
f01046d5:	e8 2f ca ff ff       	call   f0101109 <page_free>
f01046da:	83 c4 10             	add    $0x10,%esp
		return err; // E_NO_MEM
f01046dd:	89 fb                	mov    %edi,%ebx
f01046df:	e9 5c 03 00 00       	jmp    f0104a40 <syscall+0x539>
	// panic("sys_page_alloc not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;	// E_BAD_ENV
f01046e4:	89 c3                	mov    %eax,%ebx
f01046e6:	e9 55 03 00 00       	jmp    f0104a40 <syscall+0x539>

	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f01046eb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046f0:	e9 4b 03 00 00       	jmp    f0104a40 <syscall+0x539>
f01046f5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046fa:	e9 41 03 00 00       	jmp    f0104a40 <syscall+0x539>
	
	struct PageInfo * pp = page_alloc(ALLOC_ZERO);
	if (pp == NULL)
		return -E_NO_MEM;
f01046ff:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104704:	e9 37 03 00 00       	jmp    f0104a40 <syscall+0x539>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
f0104709:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104710:	0f 87 c2 00 00 00    	ja     f01047d8 <syscall+0x2d1>
f0104716:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010471d:	0f 85 bf 00 00 00    	jne    f01047e2 <syscall+0x2db>
f0104723:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010472a:	0f 87 b2 00 00 00    	ja     f01047e2 <syscall+0x2db>
f0104730:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104737:	0f 85 af 00 00 00    	jne    f01047ec <syscall+0x2e5>
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
f010473d:	83 ec 04             	sub    $0x4,%esp
f0104740:	6a 01                	push   $0x1
f0104742:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104745:	50                   	push   %eax
f0104746:	ff 75 0c             	pushl  0xc(%ebp)
f0104749:	e8 d4 e8 ff ff       	call   f0103022 <envid2env>
	if(err < 0)
f010474e:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f0104751:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
	
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
f0104753:	85 c0                	test   %eax,%eax
f0104755:	0f 88 e5 02 00 00    	js     f0104a40 <syscall+0x539>
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
f010475b:	83 ec 04             	sub    $0x4,%esp
f010475e:	6a 01                	push   $0x1
f0104760:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104763:	50                   	push   %eax
f0104764:	ff 75 14             	pushl  0x14(%ebp)
f0104767:	e8 b6 e8 ff ff       	call   f0103022 <envid2env>
	if(err < 0)
f010476c:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f010476f:	89 c3                	mov    %eax,%ebx
	struct Env *srcenv, *dstenv;
	int err = envid2env(srcenvid, &srcenv, 1);
	if(err < 0)
		return err;	// E_BAD_ENV
	err = envid2env(dstenvid, &dstenv, 1);
	if(err < 0)
f0104771:	85 c0                	test   %eax,%eax
f0104773:	0f 88 c7 02 00 00    	js     f0104a40 <syscall+0x539>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
f0104779:	83 ec 04             	sub    $0x4,%esp
f010477c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010477f:	50                   	push   %eax
f0104780:	ff 75 10             	pushl  0x10(%ebp)
f0104783:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104786:	ff 70 60             	pushl  0x60(%eax)
f0104789:	e8 50 cb ff ff       	call   f01012de <page_lookup>
	if (pp == NULL) 
f010478e:	83 c4 10             	add    $0x10,%esp
f0104791:	85 c0                	test   %eax,%eax
f0104793:	74 61                	je     f01047f6 <syscall+0x2ef>
		return -E_INVAL;	// not mapped
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
f0104795:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104798:	f6 02 02             	testb  $0x2,(%edx)
f010479b:	75 06                	jne    f01047a3 <syscall+0x29c>
f010479d:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01047a1:	75 5d                	jne    f0104800 <syscall+0x2f9>
		return -E_INVAL;	// read-only page

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
f01047a3:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01047a6:	81 ca 02 0e 00 00    	or     $0xe02,%edx
f01047ac:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f01047b2:	75 56                	jne    f010480a <syscall+0x303>
		return -E_INVAL;

	err = page_insert(dstenv->env_pgdir, pp, dstva, perm);
f01047b4:	ff 75 1c             	pushl  0x1c(%ebp)
f01047b7:	ff 75 18             	pushl  0x18(%ebp)
f01047ba:	50                   	push   %eax
f01047bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01047be:	ff 70 60             	pushl  0x60(%eax)
f01047c1:	e8 00 cc ff ff       	call   f01013c6 <page_insert>
f01047c6:	83 c4 10             	add    $0x10,%esp
f01047c9:	85 c0                	test   %eax,%eax
f01047cb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01047d0:	0f 4e d8             	cmovle %eax,%ebx
f01047d3:	e9 68 02 00 00       	jmp    f0104a40 <syscall+0x539>

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ((uint32_t)srcva % PGSIZE) != 0 || (uint32_t)dstva >= UTOP || ((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
f01047d8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047dd:	e9 5e 02 00 00       	jmp    f0104a40 <syscall+0x539>
f01047e2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047e7:	e9 54 02 00 00       	jmp    f0104a40 <syscall+0x539>
f01047ec:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047f1:	e9 4a 02 00 00       	jmp    f0104a40 <syscall+0x539>
		return err;	// E_BAD_ENV

	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (pp == NULL) 
		return -E_INVAL;	// not mapped
f01047f6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047fb:	e9 40 02 00 00       	jmp    f0104a40 <syscall+0x539>
	
	if ( ((*pte) & PTE_W) == 0 && (perm & PTE_W) != 0)
		return -E_INVAL;	// read-only page
f0104800:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104805:	e9 36 02 00 00       	jmp    f0104a40 <syscall+0x539>

	// same perm restrictions as in sys_page_alloc
	if ((perm | PTE_AVAIL | PTE_W) != (PTE_AVAIL | PTE_W | PTE_U | PTE_P))
		return -E_INVAL;
f010480a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
f010480f:	e9 2c 02 00 00       	jmp    f0104a40 <syscall+0x539>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
f0104814:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010481b:	77 45                	ja     f0104862 <syscall+0x35b>
f010481d:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104824:	75 46                	jne    f010486c <syscall+0x365>
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104826:	83 ec 04             	sub    $0x4,%esp
f0104829:	6a 01                	push   $0x1
f010482b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010482e:	50                   	push   %eax
f010482f:	ff 75 0c             	pushl  0xc(%ebp)
f0104832:	e8 eb e7 ff ff       	call   f0103022 <envid2env>
	if (err < 0)
f0104837:	83 c4 10             	add    $0x10,%esp
		return err;	// E_BAD_ENV
f010483a:	89 c3                	mov    %eax,%ebx
	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
f010483c:	85 c0                	test   %eax,%eax
f010483e:	0f 88 fc 01 00 00    	js     f0104a40 <syscall+0x539>
		return err;	// E_BAD_ENV

	page_remove(env_store->env_pgdir, va);
f0104844:	83 ec 08             	sub    $0x8,%esp
f0104847:	ff 75 10             	pushl  0x10(%ebp)
f010484a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010484d:	ff 70 60             	pushl  0x60(%eax)
f0104850:	e8 24 cb ff ff       	call   f0101379 <page_remove>
f0104855:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104858:	bb 00 00 00 00       	mov    $0x0,%ebx
f010485d:	e9 de 01 00 00       	jmp    f0104a40 <syscall+0x539>

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ((uint32_t) va % PGSIZE) != 0)
		return -E_INVAL;
f0104862:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104867:	e9 d4 01 00 00       	jmp    f0104a40 <syscall+0x539>
f010486c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104871:	e9 ca 01 00 00       	jmp    f0104a40 <syscall+0x539>
{
	// LAB 4: Your code here.
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
f0104876:	83 ec 04             	sub    $0x4,%esp
f0104879:	6a 01                	push   $0x1
f010487b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010487e:	50                   	push   %eax
f010487f:	ff 75 0c             	pushl  0xc(%ebp)
f0104882:	e8 9b e7 ff ff       	call   f0103022 <envid2env>
	if (err < 0)
f0104887:	83 c4 10             	add    $0x10,%esp
f010488a:	85 c0                	test   %eax,%eax
f010488c:	78 13                	js     f01048a1 <syscall+0x39a>
		return err;

	env_store->env_pgfault_upcall = func;
f010488e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104891:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104894:	89 48 64             	mov    %ecx,0x64(%eax)

	return 0;
f0104897:	bb 00 00 00 00       	mov    $0x0,%ebx
f010489c:	e9 9f 01 00 00       	jmp    f0104a40 <syscall+0x539>
	// panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *env_store;
	int err = envid2env(envid, &env_store, 1);
	if (err < 0)
		return err;
f01048a1:	89 c3                	mov    %eax,%ebx
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f01048a3:	e9 98 01 00 00       	jmp    f0104a40 <syscall+0x539>
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// panic("sys_ipc_recv not implemented");

	if ((uint32_t)dstva < UTOP) {
f01048a8:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01048af:	77 21                	ja     f01048d2 <syscall+0x3cb>
		if ((uint32_t)dstva % PGSIZE != 0)
f01048b1:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01048b8:	0f 85 7d 01 00 00    	jne    f0104a3b <syscall+0x534>
			return -E_INVAL;
		curenv->env_ipc_dstva = dstva;
f01048be:	e8 2f 13 00 00       	call   f0105bf2 <cpunum>
f01048c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01048c6:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01048cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01048cf:	89 48 6c             	mov    %ecx,0x6c(%eax)
	}

	// set recving flags
	curenv->env_ipc_recving = true;
f01048d2:	e8 1b 13 00 00       	call   f0105bf2 <cpunum>
f01048d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01048da:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01048e0:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f01048e4:	e8 09 13 00 00       	call   f0105bf2 <cpunum>
f01048e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01048ec:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01048f2:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)

	// mark yourself not runnable, and then give up the CPU.
	curenv->env_status = ENV_NOT_RUNNABLE;
f01048f9:	e8 f4 12 00 00       	call   f0105bf2 <cpunum>
f01048fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104901:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f0104907:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f010490e:	e8 6b fb ff ff       	call   f010447e <sched_yield>
{
	// LAB 4: Your code here.
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
f0104913:	83 ec 04             	sub    $0x4,%esp
f0104916:	6a 00                	push   $0x0
f0104918:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010491b:	50                   	push   %eax
f010491c:	ff 75 0c             	pushl  0xc(%ebp)
f010491f:	e8 fe e6 ff ff       	call   f0103022 <envid2env>
	if(err < 0)
f0104924:	83 c4 10             	add    $0x10,%esp
f0104927:	85 c0                	test   %eax,%eax
f0104929:	0f 88 f3 00 00 00    	js     f0104a22 <syscall+0x51b>
		return err;	// E_BAD_ENV
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
f010492f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104932:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104936:	0f 84 ea 00 00 00    	je     f0104a26 <syscall+0x51f>
f010493c:	8b 58 74             	mov    0x74(%eax),%ebx
f010493f:	85 db                	test   %ebx,%ebx
f0104941:	0f 85 e6 00 00 00    	jne    f0104a2d <syscall+0x526>

	// first check if the recver is willing to recv a page
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
f0104947:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f010494b:	0f 84 9d 00 00 00    	je     f01049ee <syscall+0x4e7>
f0104951:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104958:	0f 87 90 00 00 00    	ja     f01049ee <syscall+0x4e7>
			if ((uint32_t)srcva % PGSIZE != 0)
f010495e:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104965:	75 64                	jne    f01049cb <syscall+0x4c4>
				return -E_INVAL;
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
f0104967:	8b 45 18             	mov    0x18(%ebp),%eax
f010496a:	83 e0 05             	and    $0x5,%eax
f010496d:	83 f8 05             	cmp    $0x5,%eax
f0104970:	75 60                	jne    f01049d2 <syscall+0x4cb>
            	return -E_INVAL;

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104972:	e8 7b 12 00 00       	call   f0105bf2 <cpunum>
f0104977:	83 ec 04             	sub    $0x4,%esp
f010497a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010497d:	52                   	push   %edx
f010497e:	ff 75 14             	pushl  0x14(%ebp)
f0104981:	6b c0 74             	imul   $0x74,%eax,%eax
f0104984:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f010498a:	ff 70 60             	pushl  0x60(%eax)
f010498d:	e8 4c c9 ff ff       	call   f01012de <page_lookup>
			if (!pp) 
f0104992:	83 c4 10             	add    $0x10,%esp
f0104995:	85 c0                	test   %eax,%eax
f0104997:	74 40                	je     f01049d9 <syscall+0x4d2>
				return -E_INVAL;  
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
f0104999:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f010499d:	74 08                	je     f01049a7 <syscall+0x4a0>
f010499f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01049a2:	f6 02 02             	testb  $0x2,(%edx)
f01049a5:	74 39                	je     f01049e0 <syscall+0x4d9>
				return -E_INVAL;

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
f01049a7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01049aa:	ff 75 18             	pushl  0x18(%ebp)
f01049ad:	ff 72 6c             	pushl  0x6c(%edx)
f01049b0:	50                   	push   %eax
f01049b1:	ff 72 60             	pushl  0x60(%edx)
f01049b4:	e8 0d ca ff ff       	call   f01013c6 <page_insert>
f01049b9:	83 c4 10             	add    $0x10,%esp
f01049bc:	85 c0                	test   %eax,%eax
f01049be:	78 27                	js     f01049e7 <syscall+0x4e0>
				return -E_NO_MEM;
			
			env->env_ipc_perm = perm;
f01049c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049c3:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01049c6:	89 48 78             	mov    %ecx,0x78(%eax)
f01049c9:	eb 23                	jmp    f01049ee <syscall+0x4e7>
	// any error happens, fall fast
	if (env->env_ipc_dstva != 0) {
		
		if ((uint32_t)srcva < UTOP) {
			if ((uint32_t)srcva % PGSIZE != 0)
				return -E_INVAL;
f01049cb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049d0:	eb 6e                	jmp    f0104a40 <syscall+0x539>
			if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
            	return -E_INVAL;
f01049d2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049d7:	eb 67                	jmp    f0104a40 <syscall+0x539>

			pte_t *pte;
			struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
			if (!pp) 
				return -E_INVAL;  
f01049d9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049de:	eb 60                	jmp    f0104a40 <syscall+0x539>
			
			if ((perm & PTE_W) && ((size_t) *pte & PTE_W) != PTE_W) 
				return -E_INVAL;
f01049e0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049e5:	eb 59                	jmp    f0104a40 <syscall+0x539>

			if (page_insert(env->env_pgdir, pp, env->env_ipc_dstva, perm) < 0) 
				return -E_NO_MEM;
f01049e7:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01049ec:	eb 52                	jmp    f0104a40 <syscall+0x539>
			env->env_ipc_perm = perm;
		}

	}

	env->env_ipc_from = curenv->env_id;
f01049ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01049f1:	e8 fc 11 00 00       	call   f0105bf2 <cpunum>
f01049f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f9:	8b 80 28 00 21 f0    	mov    -0xfdeffd8(%eax),%eax
f01049ff:	8b 40 48             	mov    0x48(%eax),%eax
f0104a02:	89 46 74             	mov    %eax,0x74(%esi)
	env->env_ipc_recving = false;
f0104a05:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a08:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_ipc_value = value;
f0104a0c:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104a0f:	89 78 70             	mov    %edi,0x70(%eax)
	env->env_status = ENV_RUNNABLE;
f0104a12:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	// make the recver return 0
	env->env_tf.tf_regs.reg_eax = 0;
f0104a19:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104a20:	eb 1e                	jmp    f0104a40 <syscall+0x539>
	// panic("sys_ipc_try_send not implemented");

	struct Env *env;
	int err = envid2env(envid, &env, 0);
	if(err < 0)
		return err;	// E_BAD_ENV
f0104a22:	89 c3                	mov    %eax,%ebx
f0104a24:	eb 1a                	jmp    f0104a40 <syscall+0x539>
	
	// not recving, or already recving
	if (env->env_ipc_recving != true || env->env_ipc_from != 0)
		return -E_IPC_NOT_RECV;
f0104a26:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104a2b:	eb 13                	jmp    f0104a40 <syscall+0x539>
f0104a2d:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f0104a32:	eb 0c                	jmp    f0104a40 <syscall+0x539>
		default:
			return -E_INVAL;
f0104a34:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a39:	eb 05                	jmp    f0104a40 <syscall+0x539>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f0104a3b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
		default:
			return -E_INVAL;
	}
}
f0104a40:	89 d8                	mov    %ebx,%eax
f0104a42:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104a45:	5b                   	pop    %ebx
f0104a46:	5e                   	pop    %esi
f0104a47:	5f                   	pop    %edi
f0104a48:	5d                   	pop    %ebp
f0104a49:	c3                   	ret    

f0104a4a <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104a4a:	55                   	push   %ebp
f0104a4b:	89 e5                	mov    %esp,%ebp
f0104a4d:	57                   	push   %edi
f0104a4e:	56                   	push   %esi
f0104a4f:	53                   	push   %ebx
f0104a50:	83 ec 14             	sub    $0x14,%esp
f0104a53:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104a56:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104a59:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104a5c:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104a5f:	8b 1a                	mov    (%edx),%ebx
f0104a61:	8b 01                	mov    (%ecx),%eax
f0104a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104a66:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104a6d:	eb 7f                	jmp    f0104aee <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104a72:	01 d8                	add    %ebx,%eax
f0104a74:	89 c6                	mov    %eax,%esi
f0104a76:	c1 ee 1f             	shr    $0x1f,%esi
f0104a79:	01 c6                	add    %eax,%esi
f0104a7b:	d1 fe                	sar    %esi
f0104a7d:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104a80:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104a83:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104a86:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104a88:	eb 03                	jmp    f0104a8d <stab_binsearch+0x43>
			m--;
f0104a8a:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104a8d:	39 c3                	cmp    %eax,%ebx
f0104a8f:	7f 0d                	jg     f0104a9e <stab_binsearch+0x54>
f0104a91:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104a95:	83 ea 0c             	sub    $0xc,%edx
f0104a98:	39 f9                	cmp    %edi,%ecx
f0104a9a:	75 ee                	jne    f0104a8a <stab_binsearch+0x40>
f0104a9c:	eb 05                	jmp    f0104aa3 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104a9e:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104aa1:	eb 4b                	jmp    f0104aee <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104aa3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104aa6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104aa9:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104aad:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104ab0:	76 11                	jbe    f0104ac3 <stab_binsearch+0x79>
			*region_left = m;
f0104ab2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104ab5:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104ab7:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104aba:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ac1:	eb 2b                	jmp    f0104aee <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104ac3:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104ac6:	73 14                	jae    f0104adc <stab_binsearch+0x92>
			*region_right = m - 1;
f0104ac8:	83 e8 01             	sub    $0x1,%eax
f0104acb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ace:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104ad1:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104ad3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ada:	eb 12                	jmp    f0104aee <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104adc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104adf:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104ae1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104ae5:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104ae7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104aee:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104af1:	0f 8e 78 ff ff ff    	jle    f0104a6f <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104af7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104afb:	75 0f                	jne    f0104b0c <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104afd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b00:	8b 00                	mov    (%eax),%eax
f0104b02:	83 e8 01             	sub    $0x1,%eax
f0104b05:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b08:	89 06                	mov    %eax,(%esi)
f0104b0a:	eb 2c                	jmp    f0104b38 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b0f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104b11:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b14:	8b 0e                	mov    (%esi),%ecx
f0104b16:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b19:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104b1c:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b1f:	eb 03                	jmp    f0104b24 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104b21:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b24:	39 c8                	cmp    %ecx,%eax
f0104b26:	7e 0b                	jle    f0104b33 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104b28:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104b2c:	83 ea 0c             	sub    $0xc,%edx
f0104b2f:	39 df                	cmp    %ebx,%edi
f0104b31:	75 ee                	jne    f0104b21 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104b33:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b36:	89 06                	mov    %eax,(%esi)
	}
}
f0104b38:	83 c4 14             	add    $0x14,%esp
f0104b3b:	5b                   	pop    %ebx
f0104b3c:	5e                   	pop    %esi
f0104b3d:	5f                   	pop    %edi
f0104b3e:	5d                   	pop    %ebp
f0104b3f:	c3                   	ret    

f0104b40 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104b40:	55                   	push   %ebp
f0104b41:	89 e5                	mov    %esp,%ebp
f0104b43:	57                   	push   %edi
f0104b44:	56                   	push   %esi
f0104b45:	53                   	push   %ebx
f0104b46:	83 ec 3c             	sub    $0x3c,%esp
f0104b49:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104b4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104b4f:	c7 03 04 7b 10 f0    	movl   $0xf0107b04,(%ebx)
	info->eip_line = 0;
f0104b55:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104b5c:	c7 43 08 04 7b 10 f0 	movl   $0xf0107b04,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104b63:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104b6a:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104b6d:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104b74:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104b7a:	0f 87 a3 00 00 00    	ja     f0104c23 <debuginfo_eip+0xe3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104b80:	a1 00 00 20 00       	mov    0x200000,%eax
f0104b85:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104b88:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104b8e:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104b94:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104b97:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104b9c:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104b9f:	e8 4e 10 00 00       	call   f0105bf2 <cpunum>
f0104ba4:	6a 04                	push   $0x4
f0104ba6:	6a 10                	push   $0x10
f0104ba8:	68 00 00 20 00       	push   $0x200000
f0104bad:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bb0:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f0104bb6:	e8 e7 e2 ff ff       	call   f0102ea2 <user_mem_check>
f0104bbb:	83 c4 10             	add    $0x10,%esp
f0104bbe:	85 c0                	test   %eax,%eax
f0104bc0:	0f 88 27 02 00 00    	js     f0104ded <debuginfo_eip+0x2ad>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104bc6:	e8 27 10 00 00       	call   f0105bf2 <cpunum>
f0104bcb:	6a 04                	push   $0x4
f0104bcd:	89 f2                	mov    %esi,%edx
f0104bcf:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104bd2:	29 ca                	sub    %ecx,%edx
f0104bd4:	c1 fa 02             	sar    $0x2,%edx
f0104bd7:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104bdd:	52                   	push   %edx
f0104bde:	51                   	push   %ecx
f0104bdf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104be2:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f0104be8:	e8 b5 e2 ff ff       	call   f0102ea2 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f0104bed:	83 c4 10             	add    $0x10,%esp
f0104bf0:	85 c0                	test   %eax,%eax
f0104bf2:	0f 88 fc 01 00 00    	js     f0104df4 <debuginfo_eip+0x2b4>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
f0104bf8:	e8 f5 0f 00 00       	call   f0105bf2 <cpunum>
f0104bfd:	6a 04                	push   $0x4
f0104bff:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104c02:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104c05:	29 ca                	sub    %ecx,%edx
f0104c07:	52                   	push   %edx
f0104c08:	51                   	push   %ecx
f0104c09:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c0c:	ff b0 28 00 21 f0    	pushl  -0xfdeffd8(%eax)
f0104c12:	e8 8b e2 ff ff       	call   f0102ea2 <user_mem_check>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0104c17:	83 c4 10             	add    $0x10,%esp
f0104c1a:	85 c0                	test   %eax,%eax
f0104c1c:	79 1f                	jns    f0104c3d <debuginfo_eip+0xfd>
f0104c1e:	e9 d8 01 00 00       	jmp    f0104dfb <debuginfo_eip+0x2bb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104c23:	c7 45 bc 84 5b 11 f0 	movl   $0xf0115b84,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104c2a:	c7 45 b8 e9 23 11 f0 	movl   $0xf01123e9,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104c31:	be e8 23 11 f0       	mov    $0xf01123e8,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104c36:	c7 45 c0 b0 80 10 f0 	movl   $0xf01080b0,-0x40(%ebp)
		)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104c3d:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104c40:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104c43:	0f 83 b9 01 00 00    	jae    f0104e02 <debuginfo_eip+0x2c2>
f0104c49:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104c4d:	0f 85 b6 01 00 00    	jne    f0104e09 <debuginfo_eip+0x2c9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104c53:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104c5a:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104c5d:	c1 fe 02             	sar    $0x2,%esi
f0104c60:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104c66:	83 e8 01             	sub    $0x1,%eax
f0104c69:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104c6c:	83 ec 08             	sub    $0x8,%esp
f0104c6f:	57                   	push   %edi
f0104c70:	6a 64                	push   $0x64
f0104c72:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104c75:	89 d1                	mov    %edx,%ecx
f0104c77:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104c7a:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104c7d:	89 f0                	mov    %esi,%eax
f0104c7f:	e8 c6 fd ff ff       	call   f0104a4a <stab_binsearch>
	if (lfile == 0)
f0104c84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c87:	83 c4 10             	add    $0x10,%esp
f0104c8a:	85 c0                	test   %eax,%eax
f0104c8c:	0f 84 7e 01 00 00    	je     f0104e10 <debuginfo_eip+0x2d0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104c92:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104c95:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c98:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104c9b:	83 ec 08             	sub    $0x8,%esp
f0104c9e:	57                   	push   %edi
f0104c9f:	6a 24                	push   $0x24
f0104ca1:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104ca4:	89 d1                	mov    %edx,%ecx
f0104ca6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104ca9:	89 f0                	mov    %esi,%eax
f0104cab:	e8 9a fd ff ff       	call   f0104a4a <stab_binsearch>

	if (lfun <= rfun) {
f0104cb0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104cb3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104cb6:	83 c4 10             	add    $0x10,%esp
f0104cb9:	39 d0                	cmp    %edx,%eax
f0104cbb:	7f 2e                	jg     f0104ceb <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104cbd:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104cc0:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104cc3:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104cc6:	8b 36                	mov    (%esi),%esi
f0104cc8:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104ccb:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104cce:	39 ce                	cmp    %ecx,%esi
f0104cd0:	73 06                	jae    f0104cd8 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104cd2:	03 75 b8             	add    -0x48(%ebp),%esi
f0104cd5:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104cd8:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104cdb:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104cde:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104ce1:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104ce3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104ce6:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104ce9:	eb 0f                	jmp    f0104cfa <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104ceb:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104cee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cf1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104cf4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cf7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104cfa:	83 ec 08             	sub    $0x8,%esp
f0104cfd:	6a 3a                	push   $0x3a
f0104cff:	ff 73 08             	pushl  0x8(%ebx)
f0104d02:	e8 af 08 00 00       	call   f01055b6 <strfind>
f0104d07:	2b 43 08             	sub    0x8(%ebx),%eax
f0104d0a:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104d0d:	83 c4 08             	add    $0x8,%esp
f0104d10:	57                   	push   %edi
f0104d11:	6a 44                	push   $0x44
f0104d13:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104d16:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104d19:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104d1c:	89 f0                	mov    %esi,%eax
f0104d1e:	e8 27 fd ff ff       	call   f0104a4a <stab_binsearch>
	if (lline == 0)
f0104d23:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104d26:	83 c4 10             	add    $0x10,%esp
f0104d29:	85 d2                	test   %edx,%edx
f0104d2b:	0f 84 e6 00 00 00    	je     f0104e17 <debuginfo_eip+0x2d7>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0104d31:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104d34:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104d37:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104d3c:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104d3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d42:	89 d0                	mov    %edx,%eax
f0104d44:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104d47:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104d4a:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104d4e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104d51:	eb 0a                	jmp    f0104d5d <debuginfo_eip+0x21d>
f0104d53:	83 e8 01             	sub    $0x1,%eax
f0104d56:	83 ea 0c             	sub    $0xc,%edx
f0104d59:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104d5d:	39 c7                	cmp    %eax,%edi
f0104d5f:	7e 05                	jle    f0104d66 <debuginfo_eip+0x226>
f0104d61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d64:	eb 47                	jmp    f0104dad <debuginfo_eip+0x26d>
	       && stabs[lline].n_type != N_SOL
f0104d66:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104d6a:	80 f9 84             	cmp    $0x84,%cl
f0104d6d:	75 0e                	jne    f0104d7d <debuginfo_eip+0x23d>
f0104d6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d72:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d76:	74 1c                	je     f0104d94 <debuginfo_eip+0x254>
f0104d78:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104d7b:	eb 17                	jmp    f0104d94 <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104d7d:	80 f9 64             	cmp    $0x64,%cl
f0104d80:	75 d1                	jne    f0104d53 <debuginfo_eip+0x213>
f0104d82:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104d86:	74 cb                	je     f0104d53 <debuginfo_eip+0x213>
f0104d88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d8b:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d8f:	74 03                	je     f0104d94 <debuginfo_eip+0x254>
f0104d91:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104d94:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104d97:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104d9a:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104d9d:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104da0:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104da3:	29 f8                	sub    %edi,%eax
f0104da5:	39 c2                	cmp    %eax,%edx
f0104da7:	73 04                	jae    f0104dad <debuginfo_eip+0x26d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104da9:	01 fa                	add    %edi,%edx
f0104dab:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104dad:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104db0:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104db3:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104db8:	39 f2                	cmp    %esi,%edx
f0104dba:	7d 67                	jge    f0104e23 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
f0104dbc:	83 c2 01             	add    $0x1,%edx
f0104dbf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104dc2:	89 d0                	mov    %edx,%eax
f0104dc4:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104dc7:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104dca:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104dcd:	eb 04                	jmp    f0104dd3 <debuginfo_eip+0x293>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104dcf:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104dd3:	39 c6                	cmp    %eax,%esi
f0104dd5:	7e 47                	jle    f0104e1e <debuginfo_eip+0x2de>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104dd7:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104ddb:	83 c0 01             	add    $0x1,%eax
f0104dde:	83 c2 0c             	add    $0xc,%edx
f0104de1:	80 f9 a0             	cmp    $0xa0,%cl
f0104de4:	74 e9                	je     f0104dcf <debuginfo_eip+0x28f>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104de6:	b8 00 00 00 00       	mov    $0x0,%eax
f0104deb:	eb 36                	jmp    f0104e23 <debuginfo_eip+0x2e3>
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
		)
			return -1;
f0104ded:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104df2:	eb 2f                	jmp    f0104e23 <debuginfo_eip+0x2e3>
f0104df4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104df9:	eb 28                	jmp    f0104e23 <debuginfo_eip+0x2e3>
f0104dfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e00:	eb 21                	jmp    f0104e23 <debuginfo_eip+0x2e3>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104e02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e07:	eb 1a                	jmp    f0104e23 <debuginfo_eip+0x2e3>
f0104e09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e0e:	eb 13                	jmp    f0104e23 <debuginfo_eip+0x2e3>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e15:	eb 0c                	jmp    f0104e23 <debuginfo_eip+0x2e3>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0104e17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e1c:	eb 05                	jmp    f0104e23 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104e1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104e23:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e26:	5b                   	pop    %ebx
f0104e27:	5e                   	pop    %esi
f0104e28:	5f                   	pop    %edi
f0104e29:	5d                   	pop    %ebp
f0104e2a:	c3                   	ret    

f0104e2b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104e2b:	55                   	push   %ebp
f0104e2c:	89 e5                	mov    %esp,%ebp
f0104e2e:	57                   	push   %edi
f0104e2f:	56                   	push   %esi
f0104e30:	53                   	push   %ebx
f0104e31:	83 ec 1c             	sub    $0x1c,%esp
f0104e34:	89 c7                	mov    %eax,%edi
f0104e36:	89 d6                	mov    %edx,%esi
f0104e38:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e3b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e3e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e41:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104e44:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e47:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e4c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104e4f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104e52:	39 d3                	cmp    %edx,%ebx
f0104e54:	72 05                	jb     f0104e5b <printnum+0x30>
f0104e56:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104e59:	77 45                	ja     f0104ea0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104e5b:	83 ec 0c             	sub    $0xc,%esp
f0104e5e:	ff 75 18             	pushl  0x18(%ebp)
f0104e61:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e64:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104e67:	53                   	push   %ebx
f0104e68:	ff 75 10             	pushl  0x10(%ebp)
f0104e6b:	83 ec 08             	sub    $0x8,%esp
f0104e6e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e71:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e74:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e77:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e7a:	e8 71 11 00 00       	call   f0105ff0 <__udivdi3>
f0104e7f:	83 c4 18             	add    $0x18,%esp
f0104e82:	52                   	push   %edx
f0104e83:	50                   	push   %eax
f0104e84:	89 f2                	mov    %esi,%edx
f0104e86:	89 f8                	mov    %edi,%eax
f0104e88:	e8 9e ff ff ff       	call   f0104e2b <printnum>
f0104e8d:	83 c4 20             	add    $0x20,%esp
f0104e90:	eb 18                	jmp    f0104eaa <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104e92:	83 ec 08             	sub    $0x8,%esp
f0104e95:	56                   	push   %esi
f0104e96:	ff 75 18             	pushl  0x18(%ebp)
f0104e99:	ff d7                	call   *%edi
f0104e9b:	83 c4 10             	add    $0x10,%esp
f0104e9e:	eb 03                	jmp    f0104ea3 <printnum+0x78>
f0104ea0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104ea3:	83 eb 01             	sub    $0x1,%ebx
f0104ea6:	85 db                	test   %ebx,%ebx
f0104ea8:	7f e8                	jg     f0104e92 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104eaa:	83 ec 08             	sub    $0x8,%esp
f0104ead:	56                   	push   %esi
f0104eae:	83 ec 04             	sub    $0x4,%esp
f0104eb1:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104eb4:	ff 75 e0             	pushl  -0x20(%ebp)
f0104eb7:	ff 75 dc             	pushl  -0x24(%ebp)
f0104eba:	ff 75 d8             	pushl  -0x28(%ebp)
f0104ebd:	e8 5e 12 00 00       	call   f0106120 <__umoddi3>
f0104ec2:	83 c4 14             	add    $0x14,%esp
f0104ec5:	0f be 80 0e 7b 10 f0 	movsbl -0xfef84f2(%eax),%eax
f0104ecc:	50                   	push   %eax
f0104ecd:	ff d7                	call   *%edi
}
f0104ecf:	83 c4 10             	add    $0x10,%esp
f0104ed2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ed5:	5b                   	pop    %ebx
f0104ed6:	5e                   	pop    %esi
f0104ed7:	5f                   	pop    %edi
f0104ed8:	5d                   	pop    %ebp
f0104ed9:	c3                   	ret    

f0104eda <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104eda:	55                   	push   %ebp
f0104edb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104edd:	83 fa 01             	cmp    $0x1,%edx
f0104ee0:	7e 0e                	jle    f0104ef0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104ee2:	8b 10                	mov    (%eax),%edx
f0104ee4:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104ee7:	89 08                	mov    %ecx,(%eax)
f0104ee9:	8b 02                	mov    (%edx),%eax
f0104eeb:	8b 52 04             	mov    0x4(%edx),%edx
f0104eee:	eb 22                	jmp    f0104f12 <getuint+0x38>
	else if (lflag)
f0104ef0:	85 d2                	test   %edx,%edx
f0104ef2:	74 10                	je     f0104f04 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104ef4:	8b 10                	mov    (%eax),%edx
f0104ef6:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104ef9:	89 08                	mov    %ecx,(%eax)
f0104efb:	8b 02                	mov    (%edx),%eax
f0104efd:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f02:	eb 0e                	jmp    f0104f12 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104f04:	8b 10                	mov    (%eax),%edx
f0104f06:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104f09:	89 08                	mov    %ecx,(%eax)
f0104f0b:	8b 02                	mov    (%edx),%eax
f0104f0d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104f12:	5d                   	pop    %ebp
f0104f13:	c3                   	ret    

f0104f14 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104f14:	55                   	push   %ebp
f0104f15:	89 e5                	mov    %esp,%ebp
f0104f17:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104f1a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104f1e:	8b 10                	mov    (%eax),%edx
f0104f20:	3b 50 04             	cmp    0x4(%eax),%edx
f0104f23:	73 0a                	jae    f0104f2f <sprintputch+0x1b>
		*b->buf++ = ch;
f0104f25:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104f28:	89 08                	mov    %ecx,(%eax)
f0104f2a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f2d:	88 02                	mov    %al,(%edx)
}
f0104f2f:	5d                   	pop    %ebp
f0104f30:	c3                   	ret    

f0104f31 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104f31:	55                   	push   %ebp
f0104f32:	89 e5                	mov    %esp,%ebp
f0104f34:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104f37:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104f3a:	50                   	push   %eax
f0104f3b:	ff 75 10             	pushl  0x10(%ebp)
f0104f3e:	ff 75 0c             	pushl  0xc(%ebp)
f0104f41:	ff 75 08             	pushl  0x8(%ebp)
f0104f44:	e8 05 00 00 00       	call   f0104f4e <vprintfmt>
	va_end(ap);
}
f0104f49:	83 c4 10             	add    $0x10,%esp
f0104f4c:	c9                   	leave  
f0104f4d:	c3                   	ret    

f0104f4e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104f4e:	55                   	push   %ebp
f0104f4f:	89 e5                	mov    %esp,%ebp
f0104f51:	57                   	push   %edi
f0104f52:	56                   	push   %esi
f0104f53:	53                   	push   %ebx
f0104f54:	83 ec 2c             	sub    $0x2c,%esp
f0104f57:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f5d:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f60:	eb 12                	jmp    f0104f74 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104f62:	85 c0                	test   %eax,%eax
f0104f64:	0f 84 89 03 00 00    	je     f01052f3 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104f6a:	83 ec 08             	sub    $0x8,%esp
f0104f6d:	53                   	push   %ebx
f0104f6e:	50                   	push   %eax
f0104f6f:	ff d6                	call   *%esi
f0104f71:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104f74:	83 c7 01             	add    $0x1,%edi
f0104f77:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104f7b:	83 f8 25             	cmp    $0x25,%eax
f0104f7e:	75 e2                	jne    f0104f62 <vprintfmt+0x14>
f0104f80:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104f84:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104f8b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104f92:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104f99:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f9e:	eb 07                	jmp    f0104fa7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fa0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104fa3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fa7:	8d 47 01             	lea    0x1(%edi),%eax
f0104faa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104fad:	0f b6 07             	movzbl (%edi),%eax
f0104fb0:	0f b6 c8             	movzbl %al,%ecx
f0104fb3:	83 e8 23             	sub    $0x23,%eax
f0104fb6:	3c 55                	cmp    $0x55,%al
f0104fb8:	0f 87 1a 03 00 00    	ja     f01052d8 <vprintfmt+0x38a>
f0104fbe:	0f b6 c0             	movzbl %al,%eax
f0104fc1:	ff 24 85 60 7c 10 f0 	jmp    *-0xfef83a0(,%eax,4)
f0104fc8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104fcb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104fcf:	eb d6                	jmp    f0104fa7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fd1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fd4:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fd9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104fdc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104fdf:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104fe3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104fe6:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104fe9:	83 fa 09             	cmp    $0x9,%edx
f0104fec:	77 39                	ja     f0105027 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104fee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104ff1:	eb e9                	jmp    f0104fdc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104ff3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ff6:	8d 48 04             	lea    0x4(%eax),%ecx
f0104ff9:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104ffc:	8b 00                	mov    (%eax),%eax
f0104ffe:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105001:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105004:	eb 27                	jmp    f010502d <vprintfmt+0xdf>
f0105006:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105009:	85 c0                	test   %eax,%eax
f010500b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105010:	0f 49 c8             	cmovns %eax,%ecx
f0105013:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105016:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105019:	eb 8c                	jmp    f0104fa7 <vprintfmt+0x59>
f010501b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010501e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105025:	eb 80                	jmp    f0104fa7 <vprintfmt+0x59>
f0105027:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010502a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010502d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105031:	0f 89 70 ff ff ff    	jns    f0104fa7 <vprintfmt+0x59>
				width = precision, precision = -1;
f0105037:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010503a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010503d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105044:	e9 5e ff ff ff       	jmp    f0104fa7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105049:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010504c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010504f:	e9 53 ff ff ff       	jmp    f0104fa7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105054:	8b 45 14             	mov    0x14(%ebp),%eax
f0105057:	8d 50 04             	lea    0x4(%eax),%edx
f010505a:	89 55 14             	mov    %edx,0x14(%ebp)
f010505d:	83 ec 08             	sub    $0x8,%esp
f0105060:	53                   	push   %ebx
f0105061:	ff 30                	pushl  (%eax)
f0105063:	ff d6                	call   *%esi
			break;
f0105065:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105068:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010506b:	e9 04 ff ff ff       	jmp    f0104f74 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105070:	8b 45 14             	mov    0x14(%ebp),%eax
f0105073:	8d 50 04             	lea    0x4(%eax),%edx
f0105076:	89 55 14             	mov    %edx,0x14(%ebp)
f0105079:	8b 00                	mov    (%eax),%eax
f010507b:	99                   	cltd   
f010507c:	31 d0                	xor    %edx,%eax
f010507e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105080:	83 f8 0f             	cmp    $0xf,%eax
f0105083:	7f 0b                	jg     f0105090 <vprintfmt+0x142>
f0105085:	8b 14 85 c0 7d 10 f0 	mov    -0xfef8240(,%eax,4),%edx
f010508c:	85 d2                	test   %edx,%edx
f010508e:	75 18                	jne    f01050a8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0105090:	50                   	push   %eax
f0105091:	68 26 7b 10 f0       	push   $0xf0107b26
f0105096:	53                   	push   %ebx
f0105097:	56                   	push   %esi
f0105098:	e8 94 fe ff ff       	call   f0104f31 <printfmt>
f010509d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01050a3:	e9 cc fe ff ff       	jmp    f0104f74 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01050a8:	52                   	push   %edx
f01050a9:	68 97 68 10 f0       	push   $0xf0106897
f01050ae:	53                   	push   %ebx
f01050af:	56                   	push   %esi
f01050b0:	e8 7c fe ff ff       	call   f0104f31 <printfmt>
f01050b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050bb:	e9 b4 fe ff ff       	jmp    f0104f74 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01050c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01050c3:	8d 50 04             	lea    0x4(%eax),%edx
f01050c6:	89 55 14             	mov    %edx,0x14(%ebp)
f01050c9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01050cb:	85 ff                	test   %edi,%edi
f01050cd:	b8 1f 7b 10 f0       	mov    $0xf0107b1f,%eax
f01050d2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01050d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01050d9:	0f 8e 94 00 00 00    	jle    f0105173 <vprintfmt+0x225>
f01050df:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01050e3:	0f 84 98 00 00 00    	je     f0105181 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f01050e9:	83 ec 08             	sub    $0x8,%esp
f01050ec:	ff 75 d0             	pushl  -0x30(%ebp)
f01050ef:	57                   	push   %edi
f01050f0:	e8 77 03 00 00       	call   f010546c <strnlen>
f01050f5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01050f8:	29 c1                	sub    %eax,%ecx
f01050fa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01050fd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105100:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105104:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105107:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010510a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010510c:	eb 0f                	jmp    f010511d <vprintfmt+0x1cf>
					putch(padc, putdat);
f010510e:	83 ec 08             	sub    $0x8,%esp
f0105111:	53                   	push   %ebx
f0105112:	ff 75 e0             	pushl  -0x20(%ebp)
f0105115:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105117:	83 ef 01             	sub    $0x1,%edi
f010511a:	83 c4 10             	add    $0x10,%esp
f010511d:	85 ff                	test   %edi,%edi
f010511f:	7f ed                	jg     f010510e <vprintfmt+0x1c0>
f0105121:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105124:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105127:	85 c9                	test   %ecx,%ecx
f0105129:	b8 00 00 00 00       	mov    $0x0,%eax
f010512e:	0f 49 c1             	cmovns %ecx,%eax
f0105131:	29 c1                	sub    %eax,%ecx
f0105133:	89 75 08             	mov    %esi,0x8(%ebp)
f0105136:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105139:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010513c:	89 cb                	mov    %ecx,%ebx
f010513e:	eb 4d                	jmp    f010518d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105140:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105144:	74 1b                	je     f0105161 <vprintfmt+0x213>
f0105146:	0f be c0             	movsbl %al,%eax
f0105149:	83 e8 20             	sub    $0x20,%eax
f010514c:	83 f8 5e             	cmp    $0x5e,%eax
f010514f:	76 10                	jbe    f0105161 <vprintfmt+0x213>
					putch('?', putdat);
f0105151:	83 ec 08             	sub    $0x8,%esp
f0105154:	ff 75 0c             	pushl  0xc(%ebp)
f0105157:	6a 3f                	push   $0x3f
f0105159:	ff 55 08             	call   *0x8(%ebp)
f010515c:	83 c4 10             	add    $0x10,%esp
f010515f:	eb 0d                	jmp    f010516e <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0105161:	83 ec 08             	sub    $0x8,%esp
f0105164:	ff 75 0c             	pushl  0xc(%ebp)
f0105167:	52                   	push   %edx
f0105168:	ff 55 08             	call   *0x8(%ebp)
f010516b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010516e:	83 eb 01             	sub    $0x1,%ebx
f0105171:	eb 1a                	jmp    f010518d <vprintfmt+0x23f>
f0105173:	89 75 08             	mov    %esi,0x8(%ebp)
f0105176:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105179:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010517c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010517f:	eb 0c                	jmp    f010518d <vprintfmt+0x23f>
f0105181:	89 75 08             	mov    %esi,0x8(%ebp)
f0105184:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105187:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010518a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010518d:	83 c7 01             	add    $0x1,%edi
f0105190:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105194:	0f be d0             	movsbl %al,%edx
f0105197:	85 d2                	test   %edx,%edx
f0105199:	74 23                	je     f01051be <vprintfmt+0x270>
f010519b:	85 f6                	test   %esi,%esi
f010519d:	78 a1                	js     f0105140 <vprintfmt+0x1f2>
f010519f:	83 ee 01             	sub    $0x1,%esi
f01051a2:	79 9c                	jns    f0105140 <vprintfmt+0x1f2>
f01051a4:	89 df                	mov    %ebx,%edi
f01051a6:	8b 75 08             	mov    0x8(%ebp),%esi
f01051a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051ac:	eb 18                	jmp    f01051c6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01051ae:	83 ec 08             	sub    $0x8,%esp
f01051b1:	53                   	push   %ebx
f01051b2:	6a 20                	push   $0x20
f01051b4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01051b6:	83 ef 01             	sub    $0x1,%edi
f01051b9:	83 c4 10             	add    $0x10,%esp
f01051bc:	eb 08                	jmp    f01051c6 <vprintfmt+0x278>
f01051be:	89 df                	mov    %ebx,%edi
f01051c0:	8b 75 08             	mov    0x8(%ebp),%esi
f01051c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051c6:	85 ff                	test   %edi,%edi
f01051c8:	7f e4                	jg     f01051ae <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051cd:	e9 a2 fd ff ff       	jmp    f0104f74 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01051d2:	83 fa 01             	cmp    $0x1,%edx
f01051d5:	7e 16                	jle    f01051ed <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01051d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01051da:	8d 50 08             	lea    0x8(%eax),%edx
f01051dd:	89 55 14             	mov    %edx,0x14(%ebp)
f01051e0:	8b 50 04             	mov    0x4(%eax),%edx
f01051e3:	8b 00                	mov    (%eax),%eax
f01051e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01051eb:	eb 32                	jmp    f010521f <vprintfmt+0x2d1>
	else if (lflag)
f01051ed:	85 d2                	test   %edx,%edx
f01051ef:	74 18                	je     f0105209 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01051f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01051f4:	8d 50 04             	lea    0x4(%eax),%edx
f01051f7:	89 55 14             	mov    %edx,0x14(%ebp)
f01051fa:	8b 00                	mov    (%eax),%eax
f01051fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051ff:	89 c1                	mov    %eax,%ecx
f0105201:	c1 f9 1f             	sar    $0x1f,%ecx
f0105204:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105207:	eb 16                	jmp    f010521f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105209:	8b 45 14             	mov    0x14(%ebp),%eax
f010520c:	8d 50 04             	lea    0x4(%eax),%edx
f010520f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105212:	8b 00                	mov    (%eax),%eax
f0105214:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105217:	89 c1                	mov    %eax,%ecx
f0105219:	c1 f9 1f             	sar    $0x1f,%ecx
f010521c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010521f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105222:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105225:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010522a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010522e:	79 74                	jns    f01052a4 <vprintfmt+0x356>
				putch('-', putdat);
f0105230:	83 ec 08             	sub    $0x8,%esp
f0105233:	53                   	push   %ebx
f0105234:	6a 2d                	push   $0x2d
f0105236:	ff d6                	call   *%esi
				num = -(long long) num;
f0105238:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010523b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010523e:	f7 d8                	neg    %eax
f0105240:	83 d2 00             	adc    $0x0,%edx
f0105243:	f7 da                	neg    %edx
f0105245:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105248:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010524d:	eb 55                	jmp    f01052a4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010524f:	8d 45 14             	lea    0x14(%ebp),%eax
f0105252:	e8 83 fc ff ff       	call   f0104eda <getuint>
			base = 10;
f0105257:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010525c:	eb 46                	jmp    f01052a4 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f010525e:	8d 45 14             	lea    0x14(%ebp),%eax
f0105261:	e8 74 fc ff ff       	call   f0104eda <getuint>
			base = 8;
f0105266:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f010526b:	eb 37                	jmp    f01052a4 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f010526d:	83 ec 08             	sub    $0x8,%esp
f0105270:	53                   	push   %ebx
f0105271:	6a 30                	push   $0x30
f0105273:	ff d6                	call   *%esi
			putch('x', putdat);
f0105275:	83 c4 08             	add    $0x8,%esp
f0105278:	53                   	push   %ebx
f0105279:	6a 78                	push   $0x78
f010527b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010527d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105280:	8d 50 04             	lea    0x4(%eax),%edx
f0105283:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105286:	8b 00                	mov    (%eax),%eax
f0105288:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010528d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105290:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105295:	eb 0d                	jmp    f01052a4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105297:	8d 45 14             	lea    0x14(%ebp),%eax
f010529a:	e8 3b fc ff ff       	call   f0104eda <getuint>
			base = 16;
f010529f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01052a4:	83 ec 0c             	sub    $0xc,%esp
f01052a7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01052ab:	57                   	push   %edi
f01052ac:	ff 75 e0             	pushl  -0x20(%ebp)
f01052af:	51                   	push   %ecx
f01052b0:	52                   	push   %edx
f01052b1:	50                   	push   %eax
f01052b2:	89 da                	mov    %ebx,%edx
f01052b4:	89 f0                	mov    %esi,%eax
f01052b6:	e8 70 fb ff ff       	call   f0104e2b <printnum>
			break;
f01052bb:	83 c4 20             	add    $0x20,%esp
f01052be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052c1:	e9 ae fc ff ff       	jmp    f0104f74 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01052c6:	83 ec 08             	sub    $0x8,%esp
f01052c9:	53                   	push   %ebx
f01052ca:	51                   	push   %ecx
f01052cb:	ff d6                	call   *%esi
			break;
f01052cd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01052d3:	e9 9c fc ff ff       	jmp    f0104f74 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01052d8:	83 ec 08             	sub    $0x8,%esp
f01052db:	53                   	push   %ebx
f01052dc:	6a 25                	push   $0x25
f01052de:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01052e0:	83 c4 10             	add    $0x10,%esp
f01052e3:	eb 03                	jmp    f01052e8 <vprintfmt+0x39a>
f01052e5:	83 ef 01             	sub    $0x1,%edi
f01052e8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01052ec:	75 f7                	jne    f01052e5 <vprintfmt+0x397>
f01052ee:	e9 81 fc ff ff       	jmp    f0104f74 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01052f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01052f6:	5b                   	pop    %ebx
f01052f7:	5e                   	pop    %esi
f01052f8:	5f                   	pop    %edi
f01052f9:	5d                   	pop    %ebp
f01052fa:	c3                   	ret    

f01052fb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01052fb:	55                   	push   %ebp
f01052fc:	89 e5                	mov    %esp,%ebp
f01052fe:	83 ec 18             	sub    $0x18,%esp
f0105301:	8b 45 08             	mov    0x8(%ebp),%eax
f0105304:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105307:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010530a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010530e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105311:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105318:	85 c0                	test   %eax,%eax
f010531a:	74 26                	je     f0105342 <vsnprintf+0x47>
f010531c:	85 d2                	test   %edx,%edx
f010531e:	7e 22                	jle    f0105342 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105320:	ff 75 14             	pushl  0x14(%ebp)
f0105323:	ff 75 10             	pushl  0x10(%ebp)
f0105326:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105329:	50                   	push   %eax
f010532a:	68 14 4f 10 f0       	push   $0xf0104f14
f010532f:	e8 1a fc ff ff       	call   f0104f4e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105334:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105337:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010533a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010533d:	83 c4 10             	add    $0x10,%esp
f0105340:	eb 05                	jmp    f0105347 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105342:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105347:	c9                   	leave  
f0105348:	c3                   	ret    

f0105349 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105349:	55                   	push   %ebp
f010534a:	89 e5                	mov    %esp,%ebp
f010534c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010534f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105352:	50                   	push   %eax
f0105353:	ff 75 10             	pushl  0x10(%ebp)
f0105356:	ff 75 0c             	pushl  0xc(%ebp)
f0105359:	ff 75 08             	pushl  0x8(%ebp)
f010535c:	e8 9a ff ff ff       	call   f01052fb <vsnprintf>
	va_end(ap);

	return rc;
}
f0105361:	c9                   	leave  
f0105362:	c3                   	ret    

f0105363 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105363:	55                   	push   %ebp
f0105364:	89 e5                	mov    %esp,%ebp
f0105366:	57                   	push   %edi
f0105367:	56                   	push   %esi
f0105368:	53                   	push   %ebx
f0105369:	83 ec 0c             	sub    $0xc,%esp
f010536c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f010536f:	85 c0                	test   %eax,%eax
f0105371:	74 11                	je     f0105384 <readline+0x21>
		cprintf("%s", prompt);
f0105373:	83 ec 08             	sub    $0x8,%esp
f0105376:	50                   	push   %eax
f0105377:	68 97 68 10 f0       	push   $0xf0106897
f010537c:	e8 f7 e4 ff ff       	call   f0103878 <cprintf>
f0105381:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105384:	83 ec 0c             	sub    $0xc,%esp
f0105387:	6a 00                	push   $0x0
f0105389:	e8 15 b4 ff ff       	call   f01007a3 <iscons>
f010538e:	89 c7                	mov    %eax,%edi
f0105390:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105393:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105398:	e8 f5 b3 ff ff       	call   f0100792 <getchar>
f010539d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010539f:	85 c0                	test   %eax,%eax
f01053a1:	79 29                	jns    f01053cc <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01053a3:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f01053a8:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01053ab:	0f 84 9b 00 00 00    	je     f010544c <readline+0xe9>
				cprintf("read error: %e\n", c);
f01053b1:	83 ec 08             	sub    $0x8,%esp
f01053b4:	53                   	push   %ebx
f01053b5:	68 1f 7e 10 f0       	push   $0xf0107e1f
f01053ba:	e8 b9 e4 ff ff       	call   f0103878 <cprintf>
f01053bf:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01053c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01053c7:	e9 80 00 00 00       	jmp    f010544c <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01053cc:	83 f8 08             	cmp    $0x8,%eax
f01053cf:	0f 94 c2             	sete   %dl
f01053d2:	83 f8 7f             	cmp    $0x7f,%eax
f01053d5:	0f 94 c0             	sete   %al
f01053d8:	08 c2                	or     %al,%dl
f01053da:	74 1a                	je     f01053f6 <readline+0x93>
f01053dc:	85 f6                	test   %esi,%esi
f01053de:	7e 16                	jle    f01053f6 <readline+0x93>
			if (echoing)
f01053e0:	85 ff                	test   %edi,%edi
f01053e2:	74 0d                	je     f01053f1 <readline+0x8e>
				cputchar('\b');
f01053e4:	83 ec 0c             	sub    $0xc,%esp
f01053e7:	6a 08                	push   $0x8
f01053e9:	e8 94 b3 ff ff       	call   f0100782 <cputchar>
f01053ee:	83 c4 10             	add    $0x10,%esp
			i--;
f01053f1:	83 ee 01             	sub    $0x1,%esi
f01053f4:	eb a2                	jmp    f0105398 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01053f6:	83 fb 1f             	cmp    $0x1f,%ebx
f01053f9:	7e 26                	jle    f0105421 <readline+0xbe>
f01053fb:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105401:	7f 1e                	jg     f0105421 <readline+0xbe>
			if (echoing)
f0105403:	85 ff                	test   %edi,%edi
f0105405:	74 0c                	je     f0105413 <readline+0xb0>
				cputchar(c);
f0105407:	83 ec 0c             	sub    $0xc,%esp
f010540a:	53                   	push   %ebx
f010540b:	e8 72 b3 ff ff       	call   f0100782 <cputchar>
f0105410:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105413:	88 9e 80 fa 20 f0    	mov    %bl,-0xfdf0580(%esi)
f0105419:	8d 76 01             	lea    0x1(%esi),%esi
f010541c:	e9 77 ff ff ff       	jmp    f0105398 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105421:	83 fb 0a             	cmp    $0xa,%ebx
f0105424:	74 09                	je     f010542f <readline+0xcc>
f0105426:	83 fb 0d             	cmp    $0xd,%ebx
f0105429:	0f 85 69 ff ff ff    	jne    f0105398 <readline+0x35>
			if (echoing)
f010542f:	85 ff                	test   %edi,%edi
f0105431:	74 0d                	je     f0105440 <readline+0xdd>
				cputchar('\n');
f0105433:	83 ec 0c             	sub    $0xc,%esp
f0105436:	6a 0a                	push   $0xa
f0105438:	e8 45 b3 ff ff       	call   f0100782 <cputchar>
f010543d:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105440:	c6 86 80 fa 20 f0 00 	movb   $0x0,-0xfdf0580(%esi)
			return buf;
f0105447:	b8 80 fa 20 f0       	mov    $0xf020fa80,%eax
		}
	}
}
f010544c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010544f:	5b                   	pop    %ebx
f0105450:	5e                   	pop    %esi
f0105451:	5f                   	pop    %edi
f0105452:	5d                   	pop    %ebp
f0105453:	c3                   	ret    

f0105454 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105454:	55                   	push   %ebp
f0105455:	89 e5                	mov    %esp,%ebp
f0105457:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010545a:	b8 00 00 00 00       	mov    $0x0,%eax
f010545f:	eb 03                	jmp    f0105464 <strlen+0x10>
		n++;
f0105461:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105464:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105468:	75 f7                	jne    f0105461 <strlen+0xd>
		n++;
	return n;
}
f010546a:	5d                   	pop    %ebp
f010546b:	c3                   	ret    

f010546c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010546c:	55                   	push   %ebp
f010546d:	89 e5                	mov    %esp,%ebp
f010546f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105472:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105475:	ba 00 00 00 00       	mov    $0x0,%edx
f010547a:	eb 03                	jmp    f010547f <strnlen+0x13>
		n++;
f010547c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010547f:	39 c2                	cmp    %eax,%edx
f0105481:	74 08                	je     f010548b <strnlen+0x1f>
f0105483:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105487:	75 f3                	jne    f010547c <strnlen+0x10>
f0105489:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010548b:	5d                   	pop    %ebp
f010548c:	c3                   	ret    

f010548d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010548d:	55                   	push   %ebp
f010548e:	89 e5                	mov    %esp,%ebp
f0105490:	53                   	push   %ebx
f0105491:	8b 45 08             	mov    0x8(%ebp),%eax
f0105494:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105497:	89 c2                	mov    %eax,%edx
f0105499:	83 c2 01             	add    $0x1,%edx
f010549c:	83 c1 01             	add    $0x1,%ecx
f010549f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01054a3:	88 5a ff             	mov    %bl,-0x1(%edx)
f01054a6:	84 db                	test   %bl,%bl
f01054a8:	75 ef                	jne    f0105499 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01054aa:	5b                   	pop    %ebx
f01054ab:	5d                   	pop    %ebp
f01054ac:	c3                   	ret    

f01054ad <strcat>:

char *
strcat(char *dst, const char *src)
{
f01054ad:	55                   	push   %ebp
f01054ae:	89 e5                	mov    %esp,%ebp
f01054b0:	53                   	push   %ebx
f01054b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01054b4:	53                   	push   %ebx
f01054b5:	e8 9a ff ff ff       	call   f0105454 <strlen>
f01054ba:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01054bd:	ff 75 0c             	pushl  0xc(%ebp)
f01054c0:	01 d8                	add    %ebx,%eax
f01054c2:	50                   	push   %eax
f01054c3:	e8 c5 ff ff ff       	call   f010548d <strcpy>
	return dst;
}
f01054c8:	89 d8                	mov    %ebx,%eax
f01054ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01054cd:	c9                   	leave  
f01054ce:	c3                   	ret    

f01054cf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01054cf:	55                   	push   %ebp
f01054d0:	89 e5                	mov    %esp,%ebp
f01054d2:	56                   	push   %esi
f01054d3:	53                   	push   %ebx
f01054d4:	8b 75 08             	mov    0x8(%ebp),%esi
f01054d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01054da:	89 f3                	mov    %esi,%ebx
f01054dc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01054df:	89 f2                	mov    %esi,%edx
f01054e1:	eb 0f                	jmp    f01054f2 <strncpy+0x23>
		*dst++ = *src;
f01054e3:	83 c2 01             	add    $0x1,%edx
f01054e6:	0f b6 01             	movzbl (%ecx),%eax
f01054e9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01054ec:	80 39 01             	cmpb   $0x1,(%ecx)
f01054ef:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01054f2:	39 da                	cmp    %ebx,%edx
f01054f4:	75 ed                	jne    f01054e3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01054f6:	89 f0                	mov    %esi,%eax
f01054f8:	5b                   	pop    %ebx
f01054f9:	5e                   	pop    %esi
f01054fa:	5d                   	pop    %ebp
f01054fb:	c3                   	ret    

f01054fc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01054fc:	55                   	push   %ebp
f01054fd:	89 e5                	mov    %esp,%ebp
f01054ff:	56                   	push   %esi
f0105500:	53                   	push   %ebx
f0105501:	8b 75 08             	mov    0x8(%ebp),%esi
f0105504:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105507:	8b 55 10             	mov    0x10(%ebp),%edx
f010550a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010550c:	85 d2                	test   %edx,%edx
f010550e:	74 21                	je     f0105531 <strlcpy+0x35>
f0105510:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105514:	89 f2                	mov    %esi,%edx
f0105516:	eb 09                	jmp    f0105521 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105518:	83 c2 01             	add    $0x1,%edx
f010551b:	83 c1 01             	add    $0x1,%ecx
f010551e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105521:	39 c2                	cmp    %eax,%edx
f0105523:	74 09                	je     f010552e <strlcpy+0x32>
f0105525:	0f b6 19             	movzbl (%ecx),%ebx
f0105528:	84 db                	test   %bl,%bl
f010552a:	75 ec                	jne    f0105518 <strlcpy+0x1c>
f010552c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010552e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105531:	29 f0                	sub    %esi,%eax
}
f0105533:	5b                   	pop    %ebx
f0105534:	5e                   	pop    %esi
f0105535:	5d                   	pop    %ebp
f0105536:	c3                   	ret    

f0105537 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105537:	55                   	push   %ebp
f0105538:	89 e5                	mov    %esp,%ebp
f010553a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010553d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105540:	eb 06                	jmp    f0105548 <strcmp+0x11>
		p++, q++;
f0105542:	83 c1 01             	add    $0x1,%ecx
f0105545:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105548:	0f b6 01             	movzbl (%ecx),%eax
f010554b:	84 c0                	test   %al,%al
f010554d:	74 04                	je     f0105553 <strcmp+0x1c>
f010554f:	3a 02                	cmp    (%edx),%al
f0105551:	74 ef                	je     f0105542 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105553:	0f b6 c0             	movzbl %al,%eax
f0105556:	0f b6 12             	movzbl (%edx),%edx
f0105559:	29 d0                	sub    %edx,%eax
}
f010555b:	5d                   	pop    %ebp
f010555c:	c3                   	ret    

f010555d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010555d:	55                   	push   %ebp
f010555e:	89 e5                	mov    %esp,%ebp
f0105560:	53                   	push   %ebx
f0105561:	8b 45 08             	mov    0x8(%ebp),%eax
f0105564:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105567:	89 c3                	mov    %eax,%ebx
f0105569:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010556c:	eb 06                	jmp    f0105574 <strncmp+0x17>
		n--, p++, q++;
f010556e:	83 c0 01             	add    $0x1,%eax
f0105571:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105574:	39 d8                	cmp    %ebx,%eax
f0105576:	74 15                	je     f010558d <strncmp+0x30>
f0105578:	0f b6 08             	movzbl (%eax),%ecx
f010557b:	84 c9                	test   %cl,%cl
f010557d:	74 04                	je     f0105583 <strncmp+0x26>
f010557f:	3a 0a                	cmp    (%edx),%cl
f0105581:	74 eb                	je     f010556e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105583:	0f b6 00             	movzbl (%eax),%eax
f0105586:	0f b6 12             	movzbl (%edx),%edx
f0105589:	29 d0                	sub    %edx,%eax
f010558b:	eb 05                	jmp    f0105592 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010558d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105592:	5b                   	pop    %ebx
f0105593:	5d                   	pop    %ebp
f0105594:	c3                   	ret    

f0105595 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105595:	55                   	push   %ebp
f0105596:	89 e5                	mov    %esp,%ebp
f0105598:	8b 45 08             	mov    0x8(%ebp),%eax
f010559b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010559f:	eb 07                	jmp    f01055a8 <strchr+0x13>
		if (*s == c)
f01055a1:	38 ca                	cmp    %cl,%dl
f01055a3:	74 0f                	je     f01055b4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01055a5:	83 c0 01             	add    $0x1,%eax
f01055a8:	0f b6 10             	movzbl (%eax),%edx
f01055ab:	84 d2                	test   %dl,%dl
f01055ad:	75 f2                	jne    f01055a1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01055af:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01055b4:	5d                   	pop    %ebp
f01055b5:	c3                   	ret    

f01055b6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01055b6:	55                   	push   %ebp
f01055b7:	89 e5                	mov    %esp,%ebp
f01055b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01055bc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01055c0:	eb 03                	jmp    f01055c5 <strfind+0xf>
f01055c2:	83 c0 01             	add    $0x1,%eax
f01055c5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01055c8:	38 ca                	cmp    %cl,%dl
f01055ca:	74 04                	je     f01055d0 <strfind+0x1a>
f01055cc:	84 d2                	test   %dl,%dl
f01055ce:	75 f2                	jne    f01055c2 <strfind+0xc>
			break;
	return (char *) s;
}
f01055d0:	5d                   	pop    %ebp
f01055d1:	c3                   	ret    

f01055d2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01055d2:	55                   	push   %ebp
f01055d3:	89 e5                	mov    %esp,%ebp
f01055d5:	57                   	push   %edi
f01055d6:	56                   	push   %esi
f01055d7:	53                   	push   %ebx
f01055d8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01055db:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01055de:	85 c9                	test   %ecx,%ecx
f01055e0:	74 36                	je     f0105618 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01055e2:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01055e8:	75 28                	jne    f0105612 <memset+0x40>
f01055ea:	f6 c1 03             	test   $0x3,%cl
f01055ed:	75 23                	jne    f0105612 <memset+0x40>
		c &= 0xFF;
f01055ef:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01055f3:	89 d3                	mov    %edx,%ebx
f01055f5:	c1 e3 08             	shl    $0x8,%ebx
f01055f8:	89 d6                	mov    %edx,%esi
f01055fa:	c1 e6 18             	shl    $0x18,%esi
f01055fd:	89 d0                	mov    %edx,%eax
f01055ff:	c1 e0 10             	shl    $0x10,%eax
f0105602:	09 f0                	or     %esi,%eax
f0105604:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105606:	89 d8                	mov    %ebx,%eax
f0105608:	09 d0                	or     %edx,%eax
f010560a:	c1 e9 02             	shr    $0x2,%ecx
f010560d:	fc                   	cld    
f010560e:	f3 ab                	rep stos %eax,%es:(%edi)
f0105610:	eb 06                	jmp    f0105618 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105612:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105615:	fc                   	cld    
f0105616:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105618:	89 f8                	mov    %edi,%eax
f010561a:	5b                   	pop    %ebx
f010561b:	5e                   	pop    %esi
f010561c:	5f                   	pop    %edi
f010561d:	5d                   	pop    %ebp
f010561e:	c3                   	ret    

f010561f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010561f:	55                   	push   %ebp
f0105620:	89 e5                	mov    %esp,%ebp
f0105622:	57                   	push   %edi
f0105623:	56                   	push   %esi
f0105624:	8b 45 08             	mov    0x8(%ebp),%eax
f0105627:	8b 75 0c             	mov    0xc(%ebp),%esi
f010562a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010562d:	39 c6                	cmp    %eax,%esi
f010562f:	73 35                	jae    f0105666 <memmove+0x47>
f0105631:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105634:	39 d0                	cmp    %edx,%eax
f0105636:	73 2e                	jae    f0105666 <memmove+0x47>
		s += n;
		d += n;
f0105638:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010563b:	89 d6                	mov    %edx,%esi
f010563d:	09 fe                	or     %edi,%esi
f010563f:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105645:	75 13                	jne    f010565a <memmove+0x3b>
f0105647:	f6 c1 03             	test   $0x3,%cl
f010564a:	75 0e                	jne    f010565a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f010564c:	83 ef 04             	sub    $0x4,%edi
f010564f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105652:	c1 e9 02             	shr    $0x2,%ecx
f0105655:	fd                   	std    
f0105656:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105658:	eb 09                	jmp    f0105663 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010565a:	83 ef 01             	sub    $0x1,%edi
f010565d:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105660:	fd                   	std    
f0105661:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105663:	fc                   	cld    
f0105664:	eb 1d                	jmp    f0105683 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105666:	89 f2                	mov    %esi,%edx
f0105668:	09 c2                	or     %eax,%edx
f010566a:	f6 c2 03             	test   $0x3,%dl
f010566d:	75 0f                	jne    f010567e <memmove+0x5f>
f010566f:	f6 c1 03             	test   $0x3,%cl
f0105672:	75 0a                	jne    f010567e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105674:	c1 e9 02             	shr    $0x2,%ecx
f0105677:	89 c7                	mov    %eax,%edi
f0105679:	fc                   	cld    
f010567a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010567c:	eb 05                	jmp    f0105683 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010567e:	89 c7                	mov    %eax,%edi
f0105680:	fc                   	cld    
f0105681:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105683:	5e                   	pop    %esi
f0105684:	5f                   	pop    %edi
f0105685:	5d                   	pop    %ebp
f0105686:	c3                   	ret    

f0105687 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105687:	55                   	push   %ebp
f0105688:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010568a:	ff 75 10             	pushl  0x10(%ebp)
f010568d:	ff 75 0c             	pushl  0xc(%ebp)
f0105690:	ff 75 08             	pushl  0x8(%ebp)
f0105693:	e8 87 ff ff ff       	call   f010561f <memmove>
}
f0105698:	c9                   	leave  
f0105699:	c3                   	ret    

f010569a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010569a:	55                   	push   %ebp
f010569b:	89 e5                	mov    %esp,%ebp
f010569d:	56                   	push   %esi
f010569e:	53                   	push   %ebx
f010569f:	8b 45 08             	mov    0x8(%ebp),%eax
f01056a2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056a5:	89 c6                	mov    %eax,%esi
f01056a7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056aa:	eb 1a                	jmp    f01056c6 <memcmp+0x2c>
		if (*s1 != *s2)
f01056ac:	0f b6 08             	movzbl (%eax),%ecx
f01056af:	0f b6 1a             	movzbl (%edx),%ebx
f01056b2:	38 d9                	cmp    %bl,%cl
f01056b4:	74 0a                	je     f01056c0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01056b6:	0f b6 c1             	movzbl %cl,%eax
f01056b9:	0f b6 db             	movzbl %bl,%ebx
f01056bc:	29 d8                	sub    %ebx,%eax
f01056be:	eb 0f                	jmp    f01056cf <memcmp+0x35>
		s1++, s2++;
f01056c0:	83 c0 01             	add    $0x1,%eax
f01056c3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056c6:	39 f0                	cmp    %esi,%eax
f01056c8:	75 e2                	jne    f01056ac <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01056ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01056cf:	5b                   	pop    %ebx
f01056d0:	5e                   	pop    %esi
f01056d1:	5d                   	pop    %ebp
f01056d2:	c3                   	ret    

f01056d3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01056d3:	55                   	push   %ebp
f01056d4:	89 e5                	mov    %esp,%ebp
f01056d6:	53                   	push   %ebx
f01056d7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01056da:	89 c1                	mov    %eax,%ecx
f01056dc:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01056df:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01056e3:	eb 0a                	jmp    f01056ef <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01056e5:	0f b6 10             	movzbl (%eax),%edx
f01056e8:	39 da                	cmp    %ebx,%edx
f01056ea:	74 07                	je     f01056f3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01056ec:	83 c0 01             	add    $0x1,%eax
f01056ef:	39 c8                	cmp    %ecx,%eax
f01056f1:	72 f2                	jb     f01056e5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01056f3:	5b                   	pop    %ebx
f01056f4:	5d                   	pop    %ebp
f01056f5:	c3                   	ret    

f01056f6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01056f6:	55                   	push   %ebp
f01056f7:	89 e5                	mov    %esp,%ebp
f01056f9:	57                   	push   %edi
f01056fa:	56                   	push   %esi
f01056fb:	53                   	push   %ebx
f01056fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105702:	eb 03                	jmp    f0105707 <strtol+0x11>
		s++;
f0105704:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105707:	0f b6 01             	movzbl (%ecx),%eax
f010570a:	3c 20                	cmp    $0x20,%al
f010570c:	74 f6                	je     f0105704 <strtol+0xe>
f010570e:	3c 09                	cmp    $0x9,%al
f0105710:	74 f2                	je     f0105704 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105712:	3c 2b                	cmp    $0x2b,%al
f0105714:	75 0a                	jne    f0105720 <strtol+0x2a>
		s++;
f0105716:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105719:	bf 00 00 00 00       	mov    $0x0,%edi
f010571e:	eb 11                	jmp    f0105731 <strtol+0x3b>
f0105720:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105725:	3c 2d                	cmp    $0x2d,%al
f0105727:	75 08                	jne    f0105731 <strtol+0x3b>
		s++, neg = 1;
f0105729:	83 c1 01             	add    $0x1,%ecx
f010572c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105731:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105737:	75 15                	jne    f010574e <strtol+0x58>
f0105739:	80 39 30             	cmpb   $0x30,(%ecx)
f010573c:	75 10                	jne    f010574e <strtol+0x58>
f010573e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105742:	75 7c                	jne    f01057c0 <strtol+0xca>
		s += 2, base = 16;
f0105744:	83 c1 02             	add    $0x2,%ecx
f0105747:	bb 10 00 00 00       	mov    $0x10,%ebx
f010574c:	eb 16                	jmp    f0105764 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010574e:	85 db                	test   %ebx,%ebx
f0105750:	75 12                	jne    f0105764 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105752:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105757:	80 39 30             	cmpb   $0x30,(%ecx)
f010575a:	75 08                	jne    f0105764 <strtol+0x6e>
		s++, base = 8;
f010575c:	83 c1 01             	add    $0x1,%ecx
f010575f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105764:	b8 00 00 00 00       	mov    $0x0,%eax
f0105769:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010576c:	0f b6 11             	movzbl (%ecx),%edx
f010576f:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105772:	89 f3                	mov    %esi,%ebx
f0105774:	80 fb 09             	cmp    $0x9,%bl
f0105777:	77 08                	ja     f0105781 <strtol+0x8b>
			dig = *s - '0';
f0105779:	0f be d2             	movsbl %dl,%edx
f010577c:	83 ea 30             	sub    $0x30,%edx
f010577f:	eb 22                	jmp    f01057a3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105781:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105784:	89 f3                	mov    %esi,%ebx
f0105786:	80 fb 19             	cmp    $0x19,%bl
f0105789:	77 08                	ja     f0105793 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010578b:	0f be d2             	movsbl %dl,%edx
f010578e:	83 ea 57             	sub    $0x57,%edx
f0105791:	eb 10                	jmp    f01057a3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105793:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105796:	89 f3                	mov    %esi,%ebx
f0105798:	80 fb 19             	cmp    $0x19,%bl
f010579b:	77 16                	ja     f01057b3 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010579d:	0f be d2             	movsbl %dl,%edx
f01057a0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01057a3:	3b 55 10             	cmp    0x10(%ebp),%edx
f01057a6:	7d 0b                	jge    f01057b3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01057a8:	83 c1 01             	add    $0x1,%ecx
f01057ab:	0f af 45 10          	imul   0x10(%ebp),%eax
f01057af:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01057b1:	eb b9                	jmp    f010576c <strtol+0x76>

	if (endptr)
f01057b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01057b7:	74 0d                	je     f01057c6 <strtol+0xd0>
		*endptr = (char *) s;
f01057b9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057bc:	89 0e                	mov    %ecx,(%esi)
f01057be:	eb 06                	jmp    f01057c6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01057c0:	85 db                	test   %ebx,%ebx
f01057c2:	74 98                	je     f010575c <strtol+0x66>
f01057c4:	eb 9e                	jmp    f0105764 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01057c6:	89 c2                	mov    %eax,%edx
f01057c8:	f7 da                	neg    %edx
f01057ca:	85 ff                	test   %edi,%edi
f01057cc:	0f 45 c2             	cmovne %edx,%eax
}
f01057cf:	5b                   	pop    %ebx
f01057d0:	5e                   	pop    %esi
f01057d1:	5f                   	pop    %edi
f01057d2:	5d                   	pop    %ebp
f01057d3:	c3                   	ret    

f01057d4 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01057d4:	fa                   	cli    

	xorw    %ax, %ax
f01057d5:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01057d7:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01057d9:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01057db:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01057dd:	0f 01 16             	lgdtl  (%esi)
f01057e0:	74 70                	je     f0105852 <mpsearch1+0x3>
	movl    %cr0, %eax
f01057e2:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01057e5:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01057e9:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01057ec:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01057f2:	08 00                	or     %al,(%eax)

f01057f4 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01057f4:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01057f8:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01057fa:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01057fc:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01057fe:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105802:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105804:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105806:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f010580b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010580e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105811:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105816:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105819:	8b 25 84 fe 20 f0    	mov    0xf020fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010581f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105824:	b8 b0 01 10 f0       	mov    $0xf01001b0,%eax
	call    *%eax
f0105829:	ff d0                	call   *%eax

f010582b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010582b:	eb fe                	jmp    f010582b <spin>
f010582d:	8d 76 00             	lea    0x0(%esi),%esi

f0105830 <gdt>:
	...
f0105838:	ff                   	(bad)  
f0105839:	ff 00                	incl   (%eax)
f010583b:	00 00                	add    %al,(%eax)
f010583d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105844:	00                   	.byte 0x0
f0105845:	92                   	xchg   %eax,%edx
f0105846:	cf                   	iret   
	...

f0105848 <gdtdesc>:
f0105848:	17                   	pop    %ss
f0105849:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010584e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010584e:	90                   	nop

f010584f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010584f:	55                   	push   %ebp
f0105850:	89 e5                	mov    %esp,%ebp
f0105852:	57                   	push   %edi
f0105853:	56                   	push   %esi
f0105854:	53                   	push   %ebx
f0105855:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105858:	8b 0d 88 fe 20 f0    	mov    0xf020fe88,%ecx
f010585e:	89 c3                	mov    %eax,%ebx
f0105860:	c1 eb 0c             	shr    $0xc,%ebx
f0105863:	39 cb                	cmp    %ecx,%ebx
f0105865:	72 12                	jb     f0105879 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105867:	50                   	push   %eax
f0105868:	68 a4 62 10 f0       	push   $0xf01062a4
f010586d:	6a 57                	push   $0x57
f010586f:	68 bd 7f 10 f0       	push   $0xf0107fbd
f0105874:	e8 c7 a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105879:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010587f:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105881:	89 c2                	mov    %eax,%edx
f0105883:	c1 ea 0c             	shr    $0xc,%edx
f0105886:	39 ca                	cmp    %ecx,%edx
f0105888:	72 12                	jb     f010589c <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010588a:	50                   	push   %eax
f010588b:	68 a4 62 10 f0       	push   $0xf01062a4
f0105890:	6a 57                	push   $0x57
f0105892:	68 bd 7f 10 f0       	push   $0xf0107fbd
f0105897:	e8 a4 a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010589c:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01058a2:	eb 2f                	jmp    f01058d3 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01058a4:	83 ec 04             	sub    $0x4,%esp
f01058a7:	6a 04                	push   $0x4
f01058a9:	68 cd 7f 10 f0       	push   $0xf0107fcd
f01058ae:	53                   	push   %ebx
f01058af:	e8 e6 fd ff ff       	call   f010569a <memcmp>
f01058b4:	83 c4 10             	add    $0x10,%esp
f01058b7:	85 c0                	test   %eax,%eax
f01058b9:	75 15                	jne    f01058d0 <mpsearch1+0x81>
f01058bb:	89 da                	mov    %ebx,%edx
f01058bd:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01058c0:	0f b6 0a             	movzbl (%edx),%ecx
f01058c3:	01 c8                	add    %ecx,%eax
f01058c5:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01058c8:	39 d7                	cmp    %edx,%edi
f01058ca:	75 f4                	jne    f01058c0 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01058cc:	84 c0                	test   %al,%al
f01058ce:	74 0e                	je     f01058de <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01058d0:	83 c3 10             	add    $0x10,%ebx
f01058d3:	39 f3                	cmp    %esi,%ebx
f01058d5:	72 cd                	jb     f01058a4 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01058d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01058dc:	eb 02                	jmp    f01058e0 <mpsearch1+0x91>
f01058de:	89 d8                	mov    %ebx,%eax
}
f01058e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058e3:	5b                   	pop    %ebx
f01058e4:	5e                   	pop    %esi
f01058e5:	5f                   	pop    %edi
f01058e6:	5d                   	pop    %ebp
f01058e7:	c3                   	ret    

f01058e8 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01058e8:	55                   	push   %ebp
f01058e9:	89 e5                	mov    %esp,%ebp
f01058eb:	57                   	push   %edi
f01058ec:	56                   	push   %esi
f01058ed:	53                   	push   %ebx
f01058ee:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01058f1:	c7 05 c0 03 21 f0 20 	movl   $0xf0210020,0xf02103c0
f01058f8:	00 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01058fb:	83 3d 88 fe 20 f0 00 	cmpl   $0x0,0xf020fe88
f0105902:	75 16                	jne    f010591a <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105904:	68 00 04 00 00       	push   $0x400
f0105909:	68 a4 62 10 f0       	push   $0xf01062a4
f010590e:	6a 6f                	push   $0x6f
f0105910:	68 bd 7f 10 f0       	push   $0xf0107fbd
f0105915:	e8 26 a7 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010591a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105921:	85 c0                	test   %eax,%eax
f0105923:	74 16                	je     f010593b <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105925:	c1 e0 04             	shl    $0x4,%eax
f0105928:	ba 00 04 00 00       	mov    $0x400,%edx
f010592d:	e8 1d ff ff ff       	call   f010584f <mpsearch1>
f0105932:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105935:	85 c0                	test   %eax,%eax
f0105937:	75 3c                	jne    f0105975 <mp_init+0x8d>
f0105939:	eb 20                	jmp    f010595b <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010593b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105942:	c1 e0 0a             	shl    $0xa,%eax
f0105945:	2d 00 04 00 00       	sub    $0x400,%eax
f010594a:	ba 00 04 00 00       	mov    $0x400,%edx
f010594f:	e8 fb fe ff ff       	call   f010584f <mpsearch1>
f0105954:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105957:	85 c0                	test   %eax,%eax
f0105959:	75 1a                	jne    f0105975 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010595b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105960:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105965:	e8 e5 fe ff ff       	call   f010584f <mpsearch1>
f010596a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010596d:	85 c0                	test   %eax,%eax
f010596f:	0f 84 5d 02 00 00    	je     f0105bd2 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105975:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105978:	8b 70 04             	mov    0x4(%eax),%esi
f010597b:	85 f6                	test   %esi,%esi
f010597d:	74 06                	je     f0105985 <mp_init+0x9d>
f010597f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105983:	74 15                	je     f010599a <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105985:	83 ec 0c             	sub    $0xc,%esp
f0105988:	68 30 7e 10 f0       	push   $0xf0107e30
f010598d:	e8 e6 de ff ff       	call   f0103878 <cprintf>
f0105992:	83 c4 10             	add    $0x10,%esp
f0105995:	e9 38 02 00 00       	jmp    f0105bd2 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010599a:	89 f0                	mov    %esi,%eax
f010599c:	c1 e8 0c             	shr    $0xc,%eax
f010599f:	3b 05 88 fe 20 f0    	cmp    0xf020fe88,%eax
f01059a5:	72 15                	jb     f01059bc <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059a7:	56                   	push   %esi
f01059a8:	68 a4 62 10 f0       	push   $0xf01062a4
f01059ad:	68 90 00 00 00       	push   $0x90
f01059b2:	68 bd 7f 10 f0       	push   $0xf0107fbd
f01059b7:	e8 84 a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01059bc:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01059c2:	83 ec 04             	sub    $0x4,%esp
f01059c5:	6a 04                	push   $0x4
f01059c7:	68 d2 7f 10 f0       	push   $0xf0107fd2
f01059cc:	53                   	push   %ebx
f01059cd:	e8 c8 fc ff ff       	call   f010569a <memcmp>
f01059d2:	83 c4 10             	add    $0x10,%esp
f01059d5:	85 c0                	test   %eax,%eax
f01059d7:	74 15                	je     f01059ee <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01059d9:	83 ec 0c             	sub    $0xc,%esp
f01059dc:	68 60 7e 10 f0       	push   $0xf0107e60
f01059e1:	e8 92 de ff ff       	call   f0103878 <cprintf>
f01059e6:	83 c4 10             	add    $0x10,%esp
f01059e9:	e9 e4 01 00 00       	jmp    f0105bd2 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01059ee:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01059f2:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01059f6:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01059f9:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01059fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a03:	eb 0d                	jmp    f0105a12 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105a05:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105a0c:	f0 
f0105a0d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a0f:	83 c0 01             	add    $0x1,%eax
f0105a12:	39 c7                	cmp    %eax,%edi
f0105a14:	75 ef                	jne    f0105a05 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105a16:	84 d2                	test   %dl,%dl
f0105a18:	74 15                	je     f0105a2f <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105a1a:	83 ec 0c             	sub    $0xc,%esp
f0105a1d:	68 94 7e 10 f0       	push   $0xf0107e94
f0105a22:	e8 51 de ff ff       	call   f0103878 <cprintf>
f0105a27:	83 c4 10             	add    $0x10,%esp
f0105a2a:	e9 a3 01 00 00       	jmp    f0105bd2 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105a2f:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105a33:	3c 01                	cmp    $0x1,%al
f0105a35:	74 1d                	je     f0105a54 <mp_init+0x16c>
f0105a37:	3c 04                	cmp    $0x4,%al
f0105a39:	74 19                	je     f0105a54 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105a3b:	83 ec 08             	sub    $0x8,%esp
f0105a3e:	0f b6 c0             	movzbl %al,%eax
f0105a41:	50                   	push   %eax
f0105a42:	68 b8 7e 10 f0       	push   $0xf0107eb8
f0105a47:	e8 2c de ff ff       	call   f0103878 <cprintf>
f0105a4c:	83 c4 10             	add    $0x10,%esp
f0105a4f:	e9 7e 01 00 00       	jmp    f0105bd2 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a54:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105a58:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a5c:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105a61:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105a66:	01 ce                	add    %ecx,%esi
f0105a68:	eb 0d                	jmp    f0105a77 <mp_init+0x18f>
f0105a6a:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105a71:	f0 
f0105a72:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a74:	83 c0 01             	add    $0x1,%eax
f0105a77:	39 c7                	cmp    %eax,%edi
f0105a79:	75 ef                	jne    f0105a6a <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a7b:	89 d0                	mov    %edx,%eax
f0105a7d:	02 43 2a             	add    0x2a(%ebx),%al
f0105a80:	74 15                	je     f0105a97 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105a82:	83 ec 0c             	sub    $0xc,%esp
f0105a85:	68 d8 7e 10 f0       	push   $0xf0107ed8
f0105a8a:	e8 e9 dd ff ff       	call   f0103878 <cprintf>
f0105a8f:	83 c4 10             	add    $0x10,%esp
f0105a92:	e9 3b 01 00 00       	jmp    f0105bd2 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105a97:	85 db                	test   %ebx,%ebx
f0105a99:	0f 84 33 01 00 00    	je     f0105bd2 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105a9f:	c7 05 00 00 21 f0 01 	movl   $0x1,0xf0210000
f0105aa6:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105aa9:	8b 43 24             	mov    0x24(%ebx),%eax
f0105aac:	a3 00 10 25 f0       	mov    %eax,0xf0251000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105ab1:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105ab4:	be 00 00 00 00       	mov    $0x0,%esi
f0105ab9:	e9 85 00 00 00       	jmp    f0105b43 <mp_init+0x25b>
		switch (*p) {
f0105abe:	0f b6 07             	movzbl (%edi),%eax
f0105ac1:	84 c0                	test   %al,%al
f0105ac3:	74 06                	je     f0105acb <mp_init+0x1e3>
f0105ac5:	3c 04                	cmp    $0x4,%al
f0105ac7:	77 55                	ja     f0105b1e <mp_init+0x236>
f0105ac9:	eb 4e                	jmp    f0105b19 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105acb:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105acf:	74 11                	je     f0105ae2 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105ad1:	6b 05 c4 03 21 f0 74 	imul   $0x74,0xf02103c4,%eax
f0105ad8:	05 20 00 21 f0       	add    $0xf0210020,%eax
f0105add:	a3 c0 03 21 f0       	mov    %eax,0xf02103c0
			if (ncpu < NCPU) {
f0105ae2:	a1 c4 03 21 f0       	mov    0xf02103c4,%eax
f0105ae7:	83 f8 07             	cmp    $0x7,%eax
f0105aea:	7f 13                	jg     f0105aff <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105aec:	6b d0 74             	imul   $0x74,%eax,%edx
f0105aef:	88 82 20 00 21 f0    	mov    %al,-0xfdeffe0(%edx)
				ncpu++;
f0105af5:	83 c0 01             	add    $0x1,%eax
f0105af8:	a3 c4 03 21 f0       	mov    %eax,0xf02103c4
f0105afd:	eb 15                	jmp    f0105b14 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105aff:	83 ec 08             	sub    $0x8,%esp
f0105b02:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105b06:	50                   	push   %eax
f0105b07:	68 08 7f 10 f0       	push   $0xf0107f08
f0105b0c:	e8 67 dd ff ff       	call   f0103878 <cprintf>
f0105b11:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105b14:	83 c7 14             	add    $0x14,%edi
			continue;
f0105b17:	eb 27                	jmp    f0105b40 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105b19:	83 c7 08             	add    $0x8,%edi
			continue;
f0105b1c:	eb 22                	jmp    f0105b40 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105b1e:	83 ec 08             	sub    $0x8,%esp
f0105b21:	0f b6 c0             	movzbl %al,%eax
f0105b24:	50                   	push   %eax
f0105b25:	68 30 7f 10 f0       	push   $0xf0107f30
f0105b2a:	e8 49 dd ff ff       	call   f0103878 <cprintf>
			ismp = 0;
f0105b2f:	c7 05 00 00 21 f0 00 	movl   $0x0,0xf0210000
f0105b36:	00 00 00 
			i = conf->entry;
f0105b39:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105b3d:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105b40:	83 c6 01             	add    $0x1,%esi
f0105b43:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105b47:	39 c6                	cmp    %eax,%esi
f0105b49:	0f 82 6f ff ff ff    	jb     f0105abe <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105b4f:	a1 c0 03 21 f0       	mov    0xf02103c0,%eax
f0105b54:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105b5b:	83 3d 00 00 21 f0 00 	cmpl   $0x0,0xf0210000
f0105b62:	75 26                	jne    f0105b8a <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105b64:	c7 05 c4 03 21 f0 01 	movl   $0x1,0xf02103c4
f0105b6b:	00 00 00 
		lapicaddr = 0;
f0105b6e:	c7 05 00 10 25 f0 00 	movl   $0x0,0xf0251000
f0105b75:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105b78:	83 ec 0c             	sub    $0xc,%esp
f0105b7b:	68 50 7f 10 f0       	push   $0xf0107f50
f0105b80:	e8 f3 dc ff ff       	call   f0103878 <cprintf>
		return;
f0105b85:	83 c4 10             	add    $0x10,%esp
f0105b88:	eb 48                	jmp    f0105bd2 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105b8a:	83 ec 04             	sub    $0x4,%esp
f0105b8d:	ff 35 c4 03 21 f0    	pushl  0xf02103c4
f0105b93:	0f b6 00             	movzbl (%eax),%eax
f0105b96:	50                   	push   %eax
f0105b97:	68 d7 7f 10 f0       	push   $0xf0107fd7
f0105b9c:	e8 d7 dc ff ff       	call   f0103878 <cprintf>

	if (mp->imcrp) {
f0105ba1:	83 c4 10             	add    $0x10,%esp
f0105ba4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ba7:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105bab:	74 25                	je     f0105bd2 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105bad:	83 ec 0c             	sub    $0xc,%esp
f0105bb0:	68 7c 7f 10 f0       	push   $0xf0107f7c
f0105bb5:	e8 be dc ff ff       	call   f0103878 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bba:	ba 22 00 00 00       	mov    $0x22,%edx
f0105bbf:	b8 70 00 00 00       	mov    $0x70,%eax
f0105bc4:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105bc5:	ba 23 00 00 00       	mov    $0x23,%edx
f0105bca:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bcb:	83 c8 01             	or     $0x1,%eax
f0105bce:	ee                   	out    %al,(%dx)
f0105bcf:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105bd5:	5b                   	pop    %ebx
f0105bd6:	5e                   	pop    %esi
f0105bd7:	5f                   	pop    %edi
f0105bd8:	5d                   	pop    %ebp
f0105bd9:	c3                   	ret    

f0105bda <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105bda:	55                   	push   %ebp
f0105bdb:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105bdd:	8b 0d 04 10 25 f0    	mov    0xf0251004,%ecx
f0105be3:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105be6:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105be8:	a1 04 10 25 f0       	mov    0xf0251004,%eax
f0105bed:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105bf0:	5d                   	pop    %ebp
f0105bf1:	c3                   	ret    

f0105bf2 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105bf2:	55                   	push   %ebp
f0105bf3:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105bf5:	a1 04 10 25 f0       	mov    0xf0251004,%eax
f0105bfa:	85 c0                	test   %eax,%eax
f0105bfc:	74 08                	je     f0105c06 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105bfe:	8b 40 20             	mov    0x20(%eax),%eax
f0105c01:	c1 e8 18             	shr    $0x18,%eax
f0105c04:	eb 05                	jmp    f0105c0b <cpunum+0x19>
	return 0;
f0105c06:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c0b:	5d                   	pop    %ebp
f0105c0c:	c3                   	ret    

f0105c0d <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105c0d:	a1 00 10 25 f0       	mov    0xf0251000,%eax
f0105c12:	85 c0                	test   %eax,%eax
f0105c14:	0f 84 21 01 00 00    	je     f0105d3b <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105c1a:	55                   	push   %ebp
f0105c1b:	89 e5                	mov    %esp,%ebp
f0105c1d:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105c20:	68 00 10 00 00       	push   $0x1000
f0105c25:	50                   	push   %eax
f0105c26:	e8 22 b8 ff ff       	call   f010144d <mmio_map_region>
f0105c2b:	a3 04 10 25 f0       	mov    %eax,0xf0251004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105c30:	ba 27 01 00 00       	mov    $0x127,%edx
f0105c35:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105c3a:	e8 9b ff ff ff       	call   f0105bda <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105c3f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105c44:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105c49:	e8 8c ff ff ff       	call   f0105bda <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105c4e:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105c53:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105c58:	e8 7d ff ff ff       	call   f0105bda <lapicw>
	lapicw(TICR, 10000000); 
f0105c5d:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105c62:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105c67:	e8 6e ff ff ff       	call   f0105bda <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105c6c:	e8 81 ff ff ff       	call   f0105bf2 <cpunum>
f0105c71:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c74:	05 20 00 21 f0       	add    $0xf0210020,%eax
f0105c79:	83 c4 10             	add    $0x10,%esp
f0105c7c:	39 05 c0 03 21 f0    	cmp    %eax,0xf02103c0
f0105c82:	74 0f                	je     f0105c93 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105c84:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c89:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105c8e:	e8 47 ff ff ff       	call   f0105bda <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105c93:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c98:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105c9d:	e8 38 ff ff ff       	call   f0105bda <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105ca2:	a1 04 10 25 f0       	mov    0xf0251004,%eax
f0105ca7:	8b 40 30             	mov    0x30(%eax),%eax
f0105caa:	c1 e8 10             	shr    $0x10,%eax
f0105cad:	3c 03                	cmp    $0x3,%al
f0105caf:	76 0f                	jbe    f0105cc0 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105cb1:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cb6:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105cbb:	e8 1a ff ff ff       	call   f0105bda <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105cc0:	ba 33 00 00 00       	mov    $0x33,%edx
f0105cc5:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105cca:	e8 0b ff ff ff       	call   f0105bda <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105ccf:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cd4:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105cd9:	e8 fc fe ff ff       	call   f0105bda <lapicw>
	lapicw(ESR, 0);
f0105cde:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ce3:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ce8:	e8 ed fe ff ff       	call   f0105bda <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105ced:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cf2:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105cf7:	e8 de fe ff ff       	call   f0105bda <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105cfc:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d01:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d06:	e8 cf fe ff ff       	call   f0105bda <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105d0b:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105d10:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d15:	e8 c0 fe ff ff       	call   f0105bda <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105d1a:	8b 15 04 10 25 f0    	mov    0xf0251004,%edx
f0105d20:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105d26:	f6 c4 10             	test   $0x10,%ah
f0105d29:	75 f5                	jne    f0105d20 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105d2b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d30:	b8 20 00 00 00       	mov    $0x20,%eax
f0105d35:	e8 a0 fe ff ff       	call   f0105bda <lapicw>
}
f0105d3a:	c9                   	leave  
f0105d3b:	f3 c3                	repz ret 

f0105d3d <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105d3d:	83 3d 04 10 25 f0 00 	cmpl   $0x0,0xf0251004
f0105d44:	74 13                	je     f0105d59 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105d46:	55                   	push   %ebp
f0105d47:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105d49:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d4e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d53:	e8 82 fe ff ff       	call   f0105bda <lapicw>
}
f0105d58:	5d                   	pop    %ebp
f0105d59:	f3 c3                	repz ret 

f0105d5b <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105d5b:	55                   	push   %ebp
f0105d5c:	89 e5                	mov    %esp,%ebp
f0105d5e:	56                   	push   %esi
f0105d5f:	53                   	push   %ebx
f0105d60:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105d66:	ba 70 00 00 00       	mov    $0x70,%edx
f0105d6b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105d70:	ee                   	out    %al,(%dx)
f0105d71:	ba 71 00 00 00       	mov    $0x71,%edx
f0105d76:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105d7b:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d7c:	83 3d 88 fe 20 f0 00 	cmpl   $0x0,0xf020fe88
f0105d83:	75 19                	jne    f0105d9e <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d85:	68 67 04 00 00       	push   $0x467
f0105d8a:	68 a4 62 10 f0       	push   $0xf01062a4
f0105d8f:	68 98 00 00 00       	push   $0x98
f0105d94:	68 f4 7f 10 f0       	push   $0xf0107ff4
f0105d99:	e8 a2 a2 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105d9e:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105da5:	00 00 
	wrv[1] = addr >> 4;
f0105da7:	89 d8                	mov    %ebx,%eax
f0105da9:	c1 e8 04             	shr    $0x4,%eax
f0105dac:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105db2:	c1 e6 18             	shl    $0x18,%esi
f0105db5:	89 f2                	mov    %esi,%edx
f0105db7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105dbc:	e8 19 fe ff ff       	call   f0105bda <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105dc1:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105dc6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105dcb:	e8 0a fe ff ff       	call   f0105bda <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105dd0:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105dd5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105dda:	e8 fb fd ff ff       	call   f0105bda <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ddf:	c1 eb 0c             	shr    $0xc,%ebx
f0105de2:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105de5:	89 f2                	mov    %esi,%edx
f0105de7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105dec:	e8 e9 fd ff ff       	call   f0105bda <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105df1:	89 da                	mov    %ebx,%edx
f0105df3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105df8:	e8 dd fd ff ff       	call   f0105bda <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105dfd:	89 f2                	mov    %esi,%edx
f0105dff:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e04:	e8 d1 fd ff ff       	call   f0105bda <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e09:	89 da                	mov    %ebx,%edx
f0105e0b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e10:	e8 c5 fd ff ff       	call   f0105bda <lapicw>
		microdelay(200);
	}
}
f0105e15:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e18:	5b                   	pop    %ebx
f0105e19:	5e                   	pop    %esi
f0105e1a:	5d                   	pop    %ebp
f0105e1b:	c3                   	ret    

f0105e1c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105e1c:	55                   	push   %ebp
f0105e1d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105e1f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e22:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105e28:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e2d:	e8 a8 fd ff ff       	call   f0105bda <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105e32:	8b 15 04 10 25 f0    	mov    0xf0251004,%edx
f0105e38:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e3e:	f6 c4 10             	test   $0x10,%ah
f0105e41:	75 f5                	jne    f0105e38 <lapic_ipi+0x1c>
		;
}
f0105e43:	5d                   	pop    %ebp
f0105e44:	c3                   	ret    

f0105e45 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105e45:	55                   	push   %ebp
f0105e46:	89 e5                	mov    %esp,%ebp
f0105e48:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105e4b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105e51:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e54:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105e57:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105e5e:	5d                   	pop    %ebp
f0105e5f:	c3                   	ret    

f0105e60 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105e60:	55                   	push   %ebp
f0105e61:	89 e5                	mov    %esp,%ebp
f0105e63:	56                   	push   %esi
f0105e64:	53                   	push   %ebx
f0105e65:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105e68:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105e6b:	74 14                	je     f0105e81 <spin_lock+0x21>
f0105e6d:	8b 73 08             	mov    0x8(%ebx),%esi
f0105e70:	e8 7d fd ff ff       	call   f0105bf2 <cpunum>
f0105e75:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e78:	05 20 00 21 f0       	add    $0xf0210020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105e7d:	39 c6                	cmp    %eax,%esi
f0105e7f:	74 07                	je     f0105e88 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105e81:	ba 01 00 00 00       	mov    $0x1,%edx
f0105e86:	eb 20                	jmp    f0105ea8 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105e88:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105e8b:	e8 62 fd ff ff       	call   f0105bf2 <cpunum>
f0105e90:	83 ec 0c             	sub    $0xc,%esp
f0105e93:	53                   	push   %ebx
f0105e94:	50                   	push   %eax
f0105e95:	68 04 80 10 f0       	push   $0xf0108004
f0105e9a:	6a 41                	push   $0x41
f0105e9c:	68 68 80 10 f0       	push   $0xf0108068
f0105ea1:	e8 9a a1 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105ea6:	f3 90                	pause  
f0105ea8:	89 d0                	mov    %edx,%eax
f0105eaa:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105ead:	85 c0                	test   %eax,%eax
f0105eaf:	75 f5                	jne    f0105ea6 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105eb1:	e8 3c fd ff ff       	call   f0105bf2 <cpunum>
f0105eb6:	6b c0 74             	imul   $0x74,%eax,%eax
f0105eb9:	05 20 00 21 f0       	add    $0xf0210020,%eax
f0105ebe:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105ec1:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105ec4:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105ec6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ecb:	eb 0b                	jmp    f0105ed8 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105ecd:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105ed0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105ed3:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105ed5:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105ed8:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105ede:	76 11                	jbe    f0105ef1 <spin_lock+0x91>
f0105ee0:	83 f8 09             	cmp    $0x9,%eax
f0105ee3:	7e e8                	jle    f0105ecd <spin_lock+0x6d>
f0105ee5:	eb 0a                	jmp    f0105ef1 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105ee7:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105eee:	83 c0 01             	add    $0x1,%eax
f0105ef1:	83 f8 09             	cmp    $0x9,%eax
f0105ef4:	7e f1                	jle    f0105ee7 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105ef6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105ef9:	5b                   	pop    %ebx
f0105efa:	5e                   	pop    %esi
f0105efb:	5d                   	pop    %ebp
f0105efc:	c3                   	ret    

f0105efd <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105efd:	55                   	push   %ebp
f0105efe:	89 e5                	mov    %esp,%ebp
f0105f00:	57                   	push   %edi
f0105f01:	56                   	push   %esi
f0105f02:	53                   	push   %ebx
f0105f03:	83 ec 4c             	sub    $0x4c,%esp
f0105f06:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105f09:	83 3e 00             	cmpl   $0x0,(%esi)
f0105f0c:	74 18                	je     f0105f26 <spin_unlock+0x29>
f0105f0e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105f11:	e8 dc fc ff ff       	call   f0105bf2 <cpunum>
f0105f16:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f19:	05 20 00 21 f0       	add    $0xf0210020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105f1e:	39 c3                	cmp    %eax,%ebx
f0105f20:	0f 84 a5 00 00 00    	je     f0105fcb <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105f26:	83 ec 04             	sub    $0x4,%esp
f0105f29:	6a 28                	push   $0x28
f0105f2b:	8d 46 0c             	lea    0xc(%esi),%eax
f0105f2e:	50                   	push   %eax
f0105f2f:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105f32:	53                   	push   %ebx
f0105f33:	e8 e7 f6 ff ff       	call   f010561f <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105f38:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105f3b:	0f b6 38             	movzbl (%eax),%edi
f0105f3e:	8b 76 04             	mov    0x4(%esi),%esi
f0105f41:	e8 ac fc ff ff       	call   f0105bf2 <cpunum>
f0105f46:	57                   	push   %edi
f0105f47:	56                   	push   %esi
f0105f48:	50                   	push   %eax
f0105f49:	68 30 80 10 f0       	push   $0xf0108030
f0105f4e:	e8 25 d9 ff ff       	call   f0103878 <cprintf>
f0105f53:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105f56:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105f59:	eb 54                	jmp    f0105faf <spin_unlock+0xb2>
f0105f5b:	83 ec 08             	sub    $0x8,%esp
f0105f5e:	57                   	push   %edi
f0105f5f:	50                   	push   %eax
f0105f60:	e8 db eb ff ff       	call   f0104b40 <debuginfo_eip>
f0105f65:	83 c4 10             	add    $0x10,%esp
f0105f68:	85 c0                	test   %eax,%eax
f0105f6a:	78 27                	js     f0105f93 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105f6c:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105f6e:	83 ec 04             	sub    $0x4,%esp
f0105f71:	89 c2                	mov    %eax,%edx
f0105f73:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105f76:	52                   	push   %edx
f0105f77:	ff 75 b0             	pushl  -0x50(%ebp)
f0105f7a:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105f7d:	ff 75 ac             	pushl  -0x54(%ebp)
f0105f80:	ff 75 a8             	pushl  -0x58(%ebp)
f0105f83:	50                   	push   %eax
f0105f84:	68 78 80 10 f0       	push   $0xf0108078
f0105f89:	e8 ea d8 ff ff       	call   f0103878 <cprintf>
f0105f8e:	83 c4 20             	add    $0x20,%esp
f0105f91:	eb 12                	jmp    f0105fa5 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105f93:	83 ec 08             	sub    $0x8,%esp
f0105f96:	ff 36                	pushl  (%esi)
f0105f98:	68 8f 80 10 f0       	push   $0xf010808f
f0105f9d:	e8 d6 d8 ff ff       	call   f0103878 <cprintf>
f0105fa2:	83 c4 10             	add    $0x10,%esp
f0105fa5:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105fa8:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105fab:	39 c3                	cmp    %eax,%ebx
f0105fad:	74 08                	je     f0105fb7 <spin_unlock+0xba>
f0105faf:	89 de                	mov    %ebx,%esi
f0105fb1:	8b 03                	mov    (%ebx),%eax
f0105fb3:	85 c0                	test   %eax,%eax
f0105fb5:	75 a4                	jne    f0105f5b <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105fb7:	83 ec 04             	sub    $0x4,%esp
f0105fba:	68 97 80 10 f0       	push   $0xf0108097
f0105fbf:	6a 67                	push   $0x67
f0105fc1:	68 68 80 10 f0       	push   $0xf0108068
f0105fc6:	e8 75 a0 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105fcb:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105fd2:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105fd9:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fde:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105fe1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105fe4:	5b                   	pop    %ebx
f0105fe5:	5e                   	pop    %esi
f0105fe6:	5f                   	pop    %edi
f0105fe7:	5d                   	pop    %ebp
f0105fe8:	c3                   	ret    
f0105fe9:	66 90                	xchg   %ax,%ax
f0105feb:	66 90                	xchg   %ax,%ax
f0105fed:	66 90                	xchg   %ax,%ax
f0105fef:	90                   	nop

f0105ff0 <__udivdi3>:
f0105ff0:	55                   	push   %ebp
f0105ff1:	57                   	push   %edi
f0105ff2:	56                   	push   %esi
f0105ff3:	53                   	push   %ebx
f0105ff4:	83 ec 1c             	sub    $0x1c,%esp
f0105ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106003:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106007:	85 f6                	test   %esi,%esi
f0106009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010600d:	89 ca                	mov    %ecx,%edx
f010600f:	89 f8                	mov    %edi,%eax
f0106011:	75 3d                	jne    f0106050 <__udivdi3+0x60>
f0106013:	39 cf                	cmp    %ecx,%edi
f0106015:	0f 87 c5 00 00 00    	ja     f01060e0 <__udivdi3+0xf0>
f010601b:	85 ff                	test   %edi,%edi
f010601d:	89 fd                	mov    %edi,%ebp
f010601f:	75 0b                	jne    f010602c <__udivdi3+0x3c>
f0106021:	b8 01 00 00 00       	mov    $0x1,%eax
f0106026:	31 d2                	xor    %edx,%edx
f0106028:	f7 f7                	div    %edi
f010602a:	89 c5                	mov    %eax,%ebp
f010602c:	89 c8                	mov    %ecx,%eax
f010602e:	31 d2                	xor    %edx,%edx
f0106030:	f7 f5                	div    %ebp
f0106032:	89 c1                	mov    %eax,%ecx
f0106034:	89 d8                	mov    %ebx,%eax
f0106036:	89 cf                	mov    %ecx,%edi
f0106038:	f7 f5                	div    %ebp
f010603a:	89 c3                	mov    %eax,%ebx
f010603c:	89 d8                	mov    %ebx,%eax
f010603e:	89 fa                	mov    %edi,%edx
f0106040:	83 c4 1c             	add    $0x1c,%esp
f0106043:	5b                   	pop    %ebx
f0106044:	5e                   	pop    %esi
f0106045:	5f                   	pop    %edi
f0106046:	5d                   	pop    %ebp
f0106047:	c3                   	ret    
f0106048:	90                   	nop
f0106049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106050:	39 ce                	cmp    %ecx,%esi
f0106052:	77 74                	ja     f01060c8 <__udivdi3+0xd8>
f0106054:	0f bd fe             	bsr    %esi,%edi
f0106057:	83 f7 1f             	xor    $0x1f,%edi
f010605a:	0f 84 98 00 00 00    	je     f01060f8 <__udivdi3+0x108>
f0106060:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106065:	89 f9                	mov    %edi,%ecx
f0106067:	89 c5                	mov    %eax,%ebp
f0106069:	29 fb                	sub    %edi,%ebx
f010606b:	d3 e6                	shl    %cl,%esi
f010606d:	89 d9                	mov    %ebx,%ecx
f010606f:	d3 ed                	shr    %cl,%ebp
f0106071:	89 f9                	mov    %edi,%ecx
f0106073:	d3 e0                	shl    %cl,%eax
f0106075:	09 ee                	or     %ebp,%esi
f0106077:	89 d9                	mov    %ebx,%ecx
f0106079:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010607d:	89 d5                	mov    %edx,%ebp
f010607f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106083:	d3 ed                	shr    %cl,%ebp
f0106085:	89 f9                	mov    %edi,%ecx
f0106087:	d3 e2                	shl    %cl,%edx
f0106089:	89 d9                	mov    %ebx,%ecx
f010608b:	d3 e8                	shr    %cl,%eax
f010608d:	09 c2                	or     %eax,%edx
f010608f:	89 d0                	mov    %edx,%eax
f0106091:	89 ea                	mov    %ebp,%edx
f0106093:	f7 f6                	div    %esi
f0106095:	89 d5                	mov    %edx,%ebp
f0106097:	89 c3                	mov    %eax,%ebx
f0106099:	f7 64 24 0c          	mull   0xc(%esp)
f010609d:	39 d5                	cmp    %edx,%ebp
f010609f:	72 10                	jb     f01060b1 <__udivdi3+0xc1>
f01060a1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01060a5:	89 f9                	mov    %edi,%ecx
f01060a7:	d3 e6                	shl    %cl,%esi
f01060a9:	39 c6                	cmp    %eax,%esi
f01060ab:	73 07                	jae    f01060b4 <__udivdi3+0xc4>
f01060ad:	39 d5                	cmp    %edx,%ebp
f01060af:	75 03                	jne    f01060b4 <__udivdi3+0xc4>
f01060b1:	83 eb 01             	sub    $0x1,%ebx
f01060b4:	31 ff                	xor    %edi,%edi
f01060b6:	89 d8                	mov    %ebx,%eax
f01060b8:	89 fa                	mov    %edi,%edx
f01060ba:	83 c4 1c             	add    $0x1c,%esp
f01060bd:	5b                   	pop    %ebx
f01060be:	5e                   	pop    %esi
f01060bf:	5f                   	pop    %edi
f01060c0:	5d                   	pop    %ebp
f01060c1:	c3                   	ret    
f01060c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01060c8:	31 ff                	xor    %edi,%edi
f01060ca:	31 db                	xor    %ebx,%ebx
f01060cc:	89 d8                	mov    %ebx,%eax
f01060ce:	89 fa                	mov    %edi,%edx
f01060d0:	83 c4 1c             	add    $0x1c,%esp
f01060d3:	5b                   	pop    %ebx
f01060d4:	5e                   	pop    %esi
f01060d5:	5f                   	pop    %edi
f01060d6:	5d                   	pop    %ebp
f01060d7:	c3                   	ret    
f01060d8:	90                   	nop
f01060d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01060e0:	89 d8                	mov    %ebx,%eax
f01060e2:	f7 f7                	div    %edi
f01060e4:	31 ff                	xor    %edi,%edi
f01060e6:	89 c3                	mov    %eax,%ebx
f01060e8:	89 d8                	mov    %ebx,%eax
f01060ea:	89 fa                	mov    %edi,%edx
f01060ec:	83 c4 1c             	add    $0x1c,%esp
f01060ef:	5b                   	pop    %ebx
f01060f0:	5e                   	pop    %esi
f01060f1:	5f                   	pop    %edi
f01060f2:	5d                   	pop    %ebp
f01060f3:	c3                   	ret    
f01060f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01060f8:	39 ce                	cmp    %ecx,%esi
f01060fa:	72 0c                	jb     f0106108 <__udivdi3+0x118>
f01060fc:	31 db                	xor    %ebx,%ebx
f01060fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106102:	0f 87 34 ff ff ff    	ja     f010603c <__udivdi3+0x4c>
f0106108:	bb 01 00 00 00       	mov    $0x1,%ebx
f010610d:	e9 2a ff ff ff       	jmp    f010603c <__udivdi3+0x4c>
f0106112:	66 90                	xchg   %ax,%ax
f0106114:	66 90                	xchg   %ax,%ax
f0106116:	66 90                	xchg   %ax,%ax
f0106118:	66 90                	xchg   %ax,%ax
f010611a:	66 90                	xchg   %ax,%ax
f010611c:	66 90                	xchg   %ax,%ax
f010611e:	66 90                	xchg   %ax,%ax

f0106120 <__umoddi3>:
f0106120:	55                   	push   %ebp
f0106121:	57                   	push   %edi
f0106122:	56                   	push   %esi
f0106123:	53                   	push   %ebx
f0106124:	83 ec 1c             	sub    $0x1c,%esp
f0106127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010612b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010612f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106133:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106137:	85 d2                	test   %edx,%edx
f0106139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010613d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106141:	89 f3                	mov    %esi,%ebx
f0106143:	89 3c 24             	mov    %edi,(%esp)
f0106146:	89 74 24 04          	mov    %esi,0x4(%esp)
f010614a:	75 1c                	jne    f0106168 <__umoddi3+0x48>
f010614c:	39 f7                	cmp    %esi,%edi
f010614e:	76 50                	jbe    f01061a0 <__umoddi3+0x80>
f0106150:	89 c8                	mov    %ecx,%eax
f0106152:	89 f2                	mov    %esi,%edx
f0106154:	f7 f7                	div    %edi
f0106156:	89 d0                	mov    %edx,%eax
f0106158:	31 d2                	xor    %edx,%edx
f010615a:	83 c4 1c             	add    $0x1c,%esp
f010615d:	5b                   	pop    %ebx
f010615e:	5e                   	pop    %esi
f010615f:	5f                   	pop    %edi
f0106160:	5d                   	pop    %ebp
f0106161:	c3                   	ret    
f0106162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106168:	39 f2                	cmp    %esi,%edx
f010616a:	89 d0                	mov    %edx,%eax
f010616c:	77 52                	ja     f01061c0 <__umoddi3+0xa0>
f010616e:	0f bd ea             	bsr    %edx,%ebp
f0106171:	83 f5 1f             	xor    $0x1f,%ebp
f0106174:	75 5a                	jne    f01061d0 <__umoddi3+0xb0>
f0106176:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010617a:	0f 82 e0 00 00 00    	jb     f0106260 <__umoddi3+0x140>
f0106180:	39 0c 24             	cmp    %ecx,(%esp)
f0106183:	0f 86 d7 00 00 00    	jbe    f0106260 <__umoddi3+0x140>
f0106189:	8b 44 24 08          	mov    0x8(%esp),%eax
f010618d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106191:	83 c4 1c             	add    $0x1c,%esp
f0106194:	5b                   	pop    %ebx
f0106195:	5e                   	pop    %esi
f0106196:	5f                   	pop    %edi
f0106197:	5d                   	pop    %ebp
f0106198:	c3                   	ret    
f0106199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01061a0:	85 ff                	test   %edi,%edi
f01061a2:	89 fd                	mov    %edi,%ebp
f01061a4:	75 0b                	jne    f01061b1 <__umoddi3+0x91>
f01061a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01061ab:	31 d2                	xor    %edx,%edx
f01061ad:	f7 f7                	div    %edi
f01061af:	89 c5                	mov    %eax,%ebp
f01061b1:	89 f0                	mov    %esi,%eax
f01061b3:	31 d2                	xor    %edx,%edx
f01061b5:	f7 f5                	div    %ebp
f01061b7:	89 c8                	mov    %ecx,%eax
f01061b9:	f7 f5                	div    %ebp
f01061bb:	89 d0                	mov    %edx,%eax
f01061bd:	eb 99                	jmp    f0106158 <__umoddi3+0x38>
f01061bf:	90                   	nop
f01061c0:	89 c8                	mov    %ecx,%eax
f01061c2:	89 f2                	mov    %esi,%edx
f01061c4:	83 c4 1c             	add    $0x1c,%esp
f01061c7:	5b                   	pop    %ebx
f01061c8:	5e                   	pop    %esi
f01061c9:	5f                   	pop    %edi
f01061ca:	5d                   	pop    %ebp
f01061cb:	c3                   	ret    
f01061cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01061d0:	8b 34 24             	mov    (%esp),%esi
f01061d3:	bf 20 00 00 00       	mov    $0x20,%edi
f01061d8:	89 e9                	mov    %ebp,%ecx
f01061da:	29 ef                	sub    %ebp,%edi
f01061dc:	d3 e0                	shl    %cl,%eax
f01061de:	89 f9                	mov    %edi,%ecx
f01061e0:	89 f2                	mov    %esi,%edx
f01061e2:	d3 ea                	shr    %cl,%edx
f01061e4:	89 e9                	mov    %ebp,%ecx
f01061e6:	09 c2                	or     %eax,%edx
f01061e8:	89 d8                	mov    %ebx,%eax
f01061ea:	89 14 24             	mov    %edx,(%esp)
f01061ed:	89 f2                	mov    %esi,%edx
f01061ef:	d3 e2                	shl    %cl,%edx
f01061f1:	89 f9                	mov    %edi,%ecx
f01061f3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01061f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01061fb:	d3 e8                	shr    %cl,%eax
f01061fd:	89 e9                	mov    %ebp,%ecx
f01061ff:	89 c6                	mov    %eax,%esi
f0106201:	d3 e3                	shl    %cl,%ebx
f0106203:	89 f9                	mov    %edi,%ecx
f0106205:	89 d0                	mov    %edx,%eax
f0106207:	d3 e8                	shr    %cl,%eax
f0106209:	89 e9                	mov    %ebp,%ecx
f010620b:	09 d8                	or     %ebx,%eax
f010620d:	89 d3                	mov    %edx,%ebx
f010620f:	89 f2                	mov    %esi,%edx
f0106211:	f7 34 24             	divl   (%esp)
f0106214:	89 d6                	mov    %edx,%esi
f0106216:	d3 e3                	shl    %cl,%ebx
f0106218:	f7 64 24 04          	mull   0x4(%esp)
f010621c:	39 d6                	cmp    %edx,%esi
f010621e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106222:	89 d1                	mov    %edx,%ecx
f0106224:	89 c3                	mov    %eax,%ebx
f0106226:	72 08                	jb     f0106230 <__umoddi3+0x110>
f0106228:	75 11                	jne    f010623b <__umoddi3+0x11b>
f010622a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010622e:	73 0b                	jae    f010623b <__umoddi3+0x11b>
f0106230:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106234:	1b 14 24             	sbb    (%esp),%edx
f0106237:	89 d1                	mov    %edx,%ecx
f0106239:	89 c3                	mov    %eax,%ebx
f010623b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010623f:	29 da                	sub    %ebx,%edx
f0106241:	19 ce                	sbb    %ecx,%esi
f0106243:	89 f9                	mov    %edi,%ecx
f0106245:	89 f0                	mov    %esi,%eax
f0106247:	d3 e0                	shl    %cl,%eax
f0106249:	89 e9                	mov    %ebp,%ecx
f010624b:	d3 ea                	shr    %cl,%edx
f010624d:	89 e9                	mov    %ebp,%ecx
f010624f:	d3 ee                	shr    %cl,%esi
f0106251:	09 d0                	or     %edx,%eax
f0106253:	89 f2                	mov    %esi,%edx
f0106255:	83 c4 1c             	add    $0x1c,%esp
f0106258:	5b                   	pop    %ebx
f0106259:	5e                   	pop    %esi
f010625a:	5f                   	pop    %edi
f010625b:	5d                   	pop    %ebp
f010625c:	c3                   	ret    
f010625d:	8d 76 00             	lea    0x0(%esi),%esi
f0106260:	29 f9                	sub    %edi,%ecx
f0106262:	19 d6                	sbb    %edx,%esi
f0106264:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010626c:	e9 18 ff ff ff       	jmp    f0106189 <__umoddi3+0x69>
