
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
f0100015:	b8 00 b0 11 00       	mov    $0x11b000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

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
f0100048:	83 3d 00 8f 22 f0 00 	cmpl   $0x0,0xf0228f00
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 00 8f 22 f0    	mov    %esi,0xf0228f00

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 8d 48 00 00       	call   f01048ee <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 80 4f 10 f0       	push   $0xf0104f80
f010006d:	e8 6a 2c 00 00       	call   f0102cdc <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 3a 2c 00 00       	call   f0102cb6 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 4d 50 10 f0 	movl   $0xf010504d,(%esp)
f0100083:	e8 54 2c 00 00       	call   f0102cdc <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 c5 08 00 00       	call   f010095a <monitor>
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
f01000a1:	e8 6a 05 00 00       	call   f0100610 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a6:	83 ec 08             	sub    $0x8,%esp
f01000a9:	68 ac 1a 00 00       	push   $0x1aac
f01000ae:	68 ec 4f 10 f0       	push   $0xf0104fec
f01000b3:	e8 24 2c 00 00       	call   f0102cdc <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000b8:	e8 85 0f 00 00       	call   f0101042 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000bd:	e8 3e 24 00 00       	call   f0102500 <env_init>
	trap_init();
f01000c2:	e8 8f 2c 00 00       	call   f0102d56 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000c7:	e8 18 45 00 00       	call   f01045e4 <mp_init>
	lapic_init();
f01000cc:	e8 38 48 00 00       	call   f0104909 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 2d 2b 00 00       	call   f0102c03 <pic_init>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000d6:	83 c4 10             	add    $0x10,%esp
f01000d9:	83 3d 08 8f 22 f0 07 	cmpl   $0x7,0xf0228f08
f01000e0:	77 16                	ja     f01000f8 <i386_init+0x5e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000e2:	68 00 70 00 00       	push   $0x7000
f01000e7:	68 a4 4f 10 f0       	push   $0xf0104fa4
f01000ec:	6a 4c                	push   $0x4c
f01000ee:	68 07 50 10 f0       	push   $0xf0105007
f01000f3:	e8 48 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f8:	83 ec 04             	sub    $0x4,%esp
f01000fb:	b8 4a 45 10 f0       	mov    $0xf010454a,%eax
f0100100:	2d d0 44 10 f0       	sub    $0xf01044d0,%eax
f0100105:	50                   	push   %eax
f0100106:	68 d0 44 10 f0       	push   $0xf01044d0
f010010b:	68 00 70 00 f0       	push   $0xf0007000
f0100110:	e8 04 42 00 00       	call   f0104319 <memmove>
f0100115:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100118:	bb 20 90 22 f0       	mov    $0xf0229020,%ebx
f010011d:	eb 4d                	jmp    f010016c <i386_init+0xd2>
		if (c == cpus + cpunum())  // We've started already.
f010011f:	e8 ca 47 00 00       	call   f01048ee <cpunum>
f0100124:	6b c0 74             	imul   $0x74,%eax,%eax
f0100127:	05 20 90 22 f0       	add    $0xf0229020,%eax
f010012c:	39 c3                	cmp    %eax,%ebx
f010012e:	74 39                	je     f0100169 <i386_init+0xcf>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100130:	89 d8                	mov    %ebx,%eax
f0100132:	2d 20 90 22 f0       	sub    $0xf0229020,%eax
f0100137:	c1 f8 02             	sar    $0x2,%eax
f010013a:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100140:	c1 e0 0f             	shl    $0xf,%eax
f0100143:	05 00 20 23 f0       	add    $0xf0232000,%eax
f0100148:	a3 04 8f 22 f0       	mov    %eax,0xf0228f04
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010014d:	83 ec 08             	sub    $0x8,%esp
f0100150:	68 00 70 00 00       	push   $0x7000
f0100155:	0f b6 03             	movzbl (%ebx),%eax
f0100158:	50                   	push   %eax
f0100159:	e8 f9 48 00 00       	call   f0104a57 <lapic_startap>
f010015e:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100161:	8b 43 04             	mov    0x4(%ebx),%eax
f0100164:	83 f8 01             	cmp    $0x1,%eax
f0100167:	75 f8                	jne    f0100161 <i386_init+0xc7>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100169:	83 c3 74             	add    $0x74,%ebx
f010016c:	6b 05 c4 93 22 f0 74 	imul   $0x74,0xf02293c4,%eax
f0100173:	05 20 90 22 f0       	add    $0xf0229020,%eax
f0100178:	39 c3                	cmp    %eax,%ebx
f010017a:	72 a3                	jb     f010011f <i386_init+0x85>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f010017c:	83 ec 08             	sub    $0x8,%esp
f010017f:	6a 00                	push   $0x0
f0100181:	68 a8 eb 21 f0       	push   $0xf021eba8
f0100186:	e8 3d 25 00 00       	call   f01026c8 <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f010018b:	e8 af 34 00 00       	call   f010363f <sched_yield>

f0100190 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f0100190:	55                   	push   %ebp
f0100191:	89 e5                	mov    %esp,%ebp
f0100193:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f0100196:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010019b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001a0:	77 12                	ja     f01001b4 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001a2:	50                   	push   %eax
f01001a3:	68 c8 4f 10 f0       	push   $0xf0104fc8
f01001a8:	6a 63                	push   $0x63
f01001aa:	68 07 50 10 f0       	push   $0xf0105007
f01001af:	e8 8c fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001b4:	05 00 00 00 10       	add    $0x10000000,%eax
f01001b9:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001bc:	e8 2d 47 00 00       	call   f01048ee <cpunum>
f01001c1:	83 ec 08             	sub    $0x8,%esp
f01001c4:	50                   	push   %eax
f01001c5:	68 13 50 10 f0       	push   $0xf0105013
f01001ca:	e8 0d 2b 00 00       	call   f0102cdc <cprintf>

	lapic_init();
f01001cf:	e8 35 47 00 00       	call   f0104909 <lapic_init>
	env_init_percpu();
f01001d4:	e8 f7 22 00 00       	call   f01024d0 <env_init_percpu>
	trap_init_percpu();
f01001d9:	e8 12 2b 00 00       	call   f0102cf0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001de:	e8 0b 47 00 00       	call   f01048ee <cpunum>
f01001e3:	6b d0 74             	imul   $0x74,%eax,%edx
f01001e6:	81 c2 20 90 22 f0    	add    $0xf0229020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001ec:	b8 01 00 00 00       	mov    $0x1,%eax
f01001f1:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01001f5:	83 c4 10             	add    $0x10,%esp
f01001f8:	eb fe                	jmp    f01001f8 <mp_main+0x68>

f01001fa <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01001fa:	55                   	push   %ebp
f01001fb:	89 e5                	mov    %esp,%ebp
f01001fd:	53                   	push   %ebx
f01001fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100201:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100204:	ff 75 0c             	pushl  0xc(%ebp)
f0100207:	ff 75 08             	pushl  0x8(%ebp)
f010020a:	68 29 50 10 f0       	push   $0xf0105029
f010020f:	e8 c8 2a 00 00       	call   f0102cdc <cprintf>
	vcprintf(fmt, ap);
f0100214:	83 c4 08             	add    $0x8,%esp
f0100217:	53                   	push   %ebx
f0100218:	ff 75 10             	pushl  0x10(%ebp)
f010021b:	e8 96 2a 00 00       	call   f0102cb6 <vcprintf>
	cprintf("\n");
f0100220:	c7 04 24 4d 50 10 f0 	movl   $0xf010504d,(%esp)
f0100227:	e8 b0 2a 00 00       	call   f0102cdc <cprintf>
	va_end(ap);
}
f010022c:	83 c4 10             	add    $0x10,%esp
f010022f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100232:	c9                   	leave  
f0100233:	c3                   	ret    

f0100234 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100234:	55                   	push   %ebp
f0100235:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100237:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010023c:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010023d:	a8 01                	test   $0x1,%al
f010023f:	74 0b                	je     f010024c <serial_proc_data+0x18>
f0100241:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100246:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100247:	0f b6 c0             	movzbl %al,%eax
f010024a:	eb 05                	jmp    f0100251 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010024c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100251:	5d                   	pop    %ebp
f0100252:	c3                   	ret    

f0100253 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100253:	55                   	push   %ebp
f0100254:	89 e5                	mov    %esp,%ebp
f0100256:	53                   	push   %ebx
f0100257:	83 ec 04             	sub    $0x4,%esp
f010025a:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010025c:	eb 2b                	jmp    f0100289 <cons_intr+0x36>
		if (c == 0)
f010025e:	85 c0                	test   %eax,%eax
f0100260:	74 27                	je     f0100289 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100262:	8b 0d 24 82 22 f0    	mov    0xf0228224,%ecx
f0100268:	8d 51 01             	lea    0x1(%ecx),%edx
f010026b:	89 15 24 82 22 f0    	mov    %edx,0xf0228224
f0100271:	88 81 20 80 22 f0    	mov    %al,-0xfdd7fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100277:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010027d:	75 0a                	jne    f0100289 <cons_intr+0x36>
			cons.wpos = 0;
f010027f:	c7 05 24 82 22 f0 00 	movl   $0x0,0xf0228224
f0100286:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100289:	ff d3                	call   *%ebx
f010028b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010028e:	75 ce                	jne    f010025e <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100290:	83 c4 04             	add    $0x4,%esp
f0100293:	5b                   	pop    %ebx
f0100294:	5d                   	pop    %ebp
f0100295:	c3                   	ret    

f0100296 <kbd_proc_data>:
f0100296:	ba 64 00 00 00       	mov    $0x64,%edx
f010029b:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f010029c:	a8 01                	test   $0x1,%al
f010029e:	0f 84 f8 00 00 00    	je     f010039c <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002a4:	a8 20                	test   $0x20,%al
f01002a6:	0f 85 f6 00 00 00    	jne    f01003a2 <kbd_proc_data+0x10c>
f01002ac:	ba 60 00 00 00       	mov    $0x60,%edx
f01002b1:	ec                   	in     (%dx),%al
f01002b2:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002b4:	3c e0                	cmp    $0xe0,%al
f01002b6:	75 0d                	jne    f01002c5 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002b8:	83 0d 00 80 22 f0 40 	orl    $0x40,0xf0228000
		return 0;
f01002bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01002c4:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002c5:	55                   	push   %ebp
f01002c6:	89 e5                	mov    %esp,%ebp
f01002c8:	53                   	push   %ebx
f01002c9:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002cc:	84 c0                	test   %al,%al
f01002ce:	79 36                	jns    f0100306 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002d0:	8b 0d 00 80 22 f0    	mov    0xf0228000,%ecx
f01002d6:	89 cb                	mov    %ecx,%ebx
f01002d8:	83 e3 40             	and    $0x40,%ebx
f01002db:	83 e0 7f             	and    $0x7f,%eax
f01002de:	85 db                	test   %ebx,%ebx
f01002e0:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002e3:	0f b6 d2             	movzbl %dl,%edx
f01002e6:	0f b6 82 a0 51 10 f0 	movzbl -0xfefae60(%edx),%eax
f01002ed:	83 c8 40             	or     $0x40,%eax
f01002f0:	0f b6 c0             	movzbl %al,%eax
f01002f3:	f7 d0                	not    %eax
f01002f5:	21 c8                	and    %ecx,%eax
f01002f7:	a3 00 80 22 f0       	mov    %eax,0xf0228000
		return 0;
f01002fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100301:	e9 a4 00 00 00       	jmp    f01003aa <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100306:	8b 0d 00 80 22 f0    	mov    0xf0228000,%ecx
f010030c:	f6 c1 40             	test   $0x40,%cl
f010030f:	74 0e                	je     f010031f <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100311:	83 c8 80             	or     $0xffffff80,%eax
f0100314:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100316:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100319:	89 0d 00 80 22 f0    	mov    %ecx,0xf0228000
	}

	shift |= shiftcode[data];
f010031f:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100322:	0f b6 82 a0 51 10 f0 	movzbl -0xfefae60(%edx),%eax
f0100329:	0b 05 00 80 22 f0    	or     0xf0228000,%eax
f010032f:	0f b6 8a a0 50 10 f0 	movzbl -0xfefaf60(%edx),%ecx
f0100336:	31 c8                	xor    %ecx,%eax
f0100338:	a3 00 80 22 f0       	mov    %eax,0xf0228000

	c = charcode[shift & (CTL | SHIFT)][data];
f010033d:	89 c1                	mov    %eax,%ecx
f010033f:	83 e1 03             	and    $0x3,%ecx
f0100342:	8b 0c 8d 80 50 10 f0 	mov    -0xfefaf80(,%ecx,4),%ecx
f0100349:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010034d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100350:	a8 08                	test   $0x8,%al
f0100352:	74 1b                	je     f010036f <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100354:	89 da                	mov    %ebx,%edx
f0100356:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100359:	83 f9 19             	cmp    $0x19,%ecx
f010035c:	77 05                	ja     f0100363 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f010035e:	83 eb 20             	sub    $0x20,%ebx
f0100361:	eb 0c                	jmp    f010036f <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f0100363:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100366:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100369:	83 fa 19             	cmp    $0x19,%edx
f010036c:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010036f:	f7 d0                	not    %eax
f0100371:	a8 06                	test   $0x6,%al
f0100373:	75 33                	jne    f01003a8 <kbd_proc_data+0x112>
f0100375:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010037b:	75 2b                	jne    f01003a8 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f010037d:	83 ec 0c             	sub    $0xc,%esp
f0100380:	68 43 50 10 f0       	push   $0xf0105043
f0100385:	e8 52 29 00 00       	call   f0102cdc <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010038a:	ba 92 00 00 00       	mov    $0x92,%edx
f010038f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100394:	ee                   	out    %al,(%dx)
f0100395:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100398:	89 d8                	mov    %ebx,%eax
f010039a:	eb 0e                	jmp    f01003aa <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f010039c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003a1:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003a7:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003a8:	89 d8                	mov    %ebx,%eax
}
f01003aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003ad:	c9                   	leave  
f01003ae:	c3                   	ret    

f01003af <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003af:	55                   	push   %ebp
f01003b0:	89 e5                	mov    %esp,%ebp
f01003b2:	57                   	push   %edi
f01003b3:	56                   	push   %esi
f01003b4:	53                   	push   %ebx
f01003b5:	83 ec 1c             	sub    $0x1c,%esp
f01003b8:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003ba:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003bf:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003c4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003c9:	eb 09                	jmp    f01003d4 <cons_putc+0x25>
f01003cb:	89 ca                	mov    %ecx,%edx
f01003cd:	ec                   	in     (%dx),%al
f01003ce:	ec                   	in     (%dx),%al
f01003cf:	ec                   	in     (%dx),%al
f01003d0:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003d1:	83 c3 01             	add    $0x1,%ebx
f01003d4:	89 f2                	mov    %esi,%edx
f01003d6:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003d7:	a8 20                	test   $0x20,%al
f01003d9:	75 08                	jne    f01003e3 <cons_putc+0x34>
f01003db:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003e1:	7e e8                	jle    f01003cb <cons_putc+0x1c>
f01003e3:	89 f8                	mov    %edi,%eax
f01003e5:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003e8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003ed:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003ee:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f3:	be 79 03 00 00       	mov    $0x379,%esi
f01003f8:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003fd:	eb 09                	jmp    f0100408 <cons_putc+0x59>
f01003ff:	89 ca                	mov    %ecx,%edx
f0100401:	ec                   	in     (%dx),%al
f0100402:	ec                   	in     (%dx),%al
f0100403:	ec                   	in     (%dx),%al
f0100404:	ec                   	in     (%dx),%al
f0100405:	83 c3 01             	add    $0x1,%ebx
f0100408:	89 f2                	mov    %esi,%edx
f010040a:	ec                   	in     (%dx),%al
f010040b:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100411:	7f 04                	jg     f0100417 <cons_putc+0x68>
f0100413:	84 c0                	test   %al,%al
f0100415:	79 e8                	jns    f01003ff <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100417:	ba 78 03 00 00       	mov    $0x378,%edx
f010041c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100420:	ee                   	out    %al,(%dx)
f0100421:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100426:	b8 0d 00 00 00       	mov    $0xd,%eax
f010042b:	ee                   	out    %al,(%dx)
f010042c:	b8 08 00 00 00       	mov    $0x8,%eax
f0100431:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100432:	89 fa                	mov    %edi,%edx
f0100434:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010043a:	89 f8                	mov    %edi,%eax
f010043c:	80 cc 07             	or     $0x7,%ah
f010043f:	85 d2                	test   %edx,%edx
f0100441:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100444:	89 f8                	mov    %edi,%eax
f0100446:	0f b6 c0             	movzbl %al,%eax
f0100449:	83 f8 09             	cmp    $0x9,%eax
f010044c:	74 74                	je     f01004c2 <cons_putc+0x113>
f010044e:	83 f8 09             	cmp    $0x9,%eax
f0100451:	7f 0a                	jg     f010045d <cons_putc+0xae>
f0100453:	83 f8 08             	cmp    $0x8,%eax
f0100456:	74 14                	je     f010046c <cons_putc+0xbd>
f0100458:	e9 99 00 00 00       	jmp    f01004f6 <cons_putc+0x147>
f010045d:	83 f8 0a             	cmp    $0xa,%eax
f0100460:	74 3a                	je     f010049c <cons_putc+0xed>
f0100462:	83 f8 0d             	cmp    $0xd,%eax
f0100465:	74 3d                	je     f01004a4 <cons_putc+0xf5>
f0100467:	e9 8a 00 00 00       	jmp    f01004f6 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010046c:	0f b7 05 28 82 22 f0 	movzwl 0xf0228228,%eax
f0100473:	66 85 c0             	test   %ax,%ax
f0100476:	0f 84 e6 00 00 00    	je     f0100562 <cons_putc+0x1b3>
			crt_pos--;
f010047c:	83 e8 01             	sub    $0x1,%eax
f010047f:	66 a3 28 82 22 f0    	mov    %ax,0xf0228228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100485:	0f b7 c0             	movzwl %ax,%eax
f0100488:	66 81 e7 00 ff       	and    $0xff00,%di
f010048d:	83 cf 20             	or     $0x20,%edi
f0100490:	8b 15 2c 82 22 f0    	mov    0xf022822c,%edx
f0100496:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010049a:	eb 78                	jmp    f0100514 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010049c:	66 83 05 28 82 22 f0 	addw   $0x50,0xf0228228
f01004a3:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004a4:	0f b7 05 28 82 22 f0 	movzwl 0xf0228228,%eax
f01004ab:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004b1:	c1 e8 16             	shr    $0x16,%eax
f01004b4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004b7:	c1 e0 04             	shl    $0x4,%eax
f01004ba:	66 a3 28 82 22 f0    	mov    %ax,0xf0228228
f01004c0:	eb 52                	jmp    f0100514 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004c2:	b8 20 00 00 00       	mov    $0x20,%eax
f01004c7:	e8 e3 fe ff ff       	call   f01003af <cons_putc>
		cons_putc(' ');
f01004cc:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d1:	e8 d9 fe ff ff       	call   f01003af <cons_putc>
		cons_putc(' ');
f01004d6:	b8 20 00 00 00       	mov    $0x20,%eax
f01004db:	e8 cf fe ff ff       	call   f01003af <cons_putc>
		cons_putc(' ');
f01004e0:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e5:	e8 c5 fe ff ff       	call   f01003af <cons_putc>
		cons_putc(' ');
f01004ea:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ef:	e8 bb fe ff ff       	call   f01003af <cons_putc>
f01004f4:	eb 1e                	jmp    f0100514 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01004f6:	0f b7 05 28 82 22 f0 	movzwl 0xf0228228,%eax
f01004fd:	8d 50 01             	lea    0x1(%eax),%edx
f0100500:	66 89 15 28 82 22 f0 	mov    %dx,0xf0228228
f0100507:	0f b7 c0             	movzwl %ax,%eax
f010050a:	8b 15 2c 82 22 f0    	mov    0xf022822c,%edx
f0100510:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100514:	66 81 3d 28 82 22 f0 	cmpw   $0x7cf,0xf0228228
f010051b:	cf 07 
f010051d:	76 43                	jbe    f0100562 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010051f:	a1 2c 82 22 f0       	mov    0xf022822c,%eax
f0100524:	83 ec 04             	sub    $0x4,%esp
f0100527:	68 00 0f 00 00       	push   $0xf00
f010052c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100532:	52                   	push   %edx
f0100533:	50                   	push   %eax
f0100534:	e8 e0 3d 00 00       	call   f0104319 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100539:	8b 15 2c 82 22 f0    	mov    0xf022822c,%edx
f010053f:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100545:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010054b:	83 c4 10             	add    $0x10,%esp
f010054e:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100553:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100556:	39 d0                	cmp    %edx,%eax
f0100558:	75 f4                	jne    f010054e <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010055a:	66 83 2d 28 82 22 f0 	subw   $0x50,0xf0228228
f0100561:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100562:	8b 0d 30 82 22 f0    	mov    0xf0228230,%ecx
f0100568:	b8 0e 00 00 00       	mov    $0xe,%eax
f010056d:	89 ca                	mov    %ecx,%edx
f010056f:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100570:	0f b7 1d 28 82 22 f0 	movzwl 0xf0228228,%ebx
f0100577:	8d 71 01             	lea    0x1(%ecx),%esi
f010057a:	89 d8                	mov    %ebx,%eax
f010057c:	66 c1 e8 08          	shr    $0x8,%ax
f0100580:	89 f2                	mov    %esi,%edx
f0100582:	ee                   	out    %al,(%dx)
f0100583:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100588:	89 ca                	mov    %ecx,%edx
f010058a:	ee                   	out    %al,(%dx)
f010058b:	89 d8                	mov    %ebx,%eax
f010058d:	89 f2                	mov    %esi,%edx
f010058f:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100590:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100593:	5b                   	pop    %ebx
f0100594:	5e                   	pop    %esi
f0100595:	5f                   	pop    %edi
f0100596:	5d                   	pop    %ebp
f0100597:	c3                   	ret    

f0100598 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100598:	80 3d 34 82 22 f0 00 	cmpb   $0x0,0xf0228234
f010059f:	74 11                	je     f01005b2 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005a1:	55                   	push   %ebp
f01005a2:	89 e5                	mov    %esp,%ebp
f01005a4:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005a7:	b8 34 02 10 f0       	mov    $0xf0100234,%eax
f01005ac:	e8 a2 fc ff ff       	call   f0100253 <cons_intr>
}
f01005b1:	c9                   	leave  
f01005b2:	f3 c3                	repz ret 

f01005b4 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005b4:	55                   	push   %ebp
f01005b5:	89 e5                	mov    %esp,%ebp
f01005b7:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005ba:	b8 96 02 10 f0       	mov    $0xf0100296,%eax
f01005bf:	e8 8f fc ff ff       	call   f0100253 <cons_intr>
}
f01005c4:	c9                   	leave  
f01005c5:	c3                   	ret    

f01005c6 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005c6:	55                   	push   %ebp
f01005c7:	89 e5                	mov    %esp,%ebp
f01005c9:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005cc:	e8 c7 ff ff ff       	call   f0100598 <serial_intr>
	kbd_intr();
f01005d1:	e8 de ff ff ff       	call   f01005b4 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005d6:	a1 20 82 22 f0       	mov    0xf0228220,%eax
f01005db:	3b 05 24 82 22 f0    	cmp    0xf0228224,%eax
f01005e1:	74 26                	je     f0100609 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01005e3:	8d 50 01             	lea    0x1(%eax),%edx
f01005e6:	89 15 20 82 22 f0    	mov    %edx,0xf0228220
f01005ec:	0f b6 88 20 80 22 f0 	movzbl -0xfdd7fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01005f3:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01005f5:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01005fb:	75 11                	jne    f010060e <cons_getc+0x48>
			cons.rpos = 0;
f01005fd:	c7 05 20 82 22 f0 00 	movl   $0x0,0xf0228220
f0100604:	00 00 00 
f0100607:	eb 05                	jmp    f010060e <cons_getc+0x48>
		return c;
	}
	return 0;
f0100609:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010060e:	c9                   	leave  
f010060f:	c3                   	ret    

f0100610 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	57                   	push   %edi
f0100614:	56                   	push   %esi
f0100615:	53                   	push   %ebx
f0100616:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100619:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100620:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100627:	5a a5 
	if (*cp != 0xA55A) {
f0100629:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100630:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100634:	74 11                	je     f0100647 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100636:	c7 05 30 82 22 f0 b4 	movl   $0x3b4,0xf0228230
f010063d:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100640:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100645:	eb 16                	jmp    f010065d <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100647:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010064e:	c7 05 30 82 22 f0 d4 	movl   $0x3d4,0xf0228230
f0100655:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100658:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010065d:	8b 3d 30 82 22 f0    	mov    0xf0228230,%edi
f0100663:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100668:	89 fa                	mov    %edi,%edx
f010066a:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010066b:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010066e:	89 da                	mov    %ebx,%edx
f0100670:	ec                   	in     (%dx),%al
f0100671:	0f b6 c8             	movzbl %al,%ecx
f0100674:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100677:	b8 0f 00 00 00       	mov    $0xf,%eax
f010067c:	89 fa                	mov    %edi,%edx
f010067e:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010067f:	89 da                	mov    %ebx,%edx
f0100681:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100682:	89 35 2c 82 22 f0    	mov    %esi,0xf022822c
	crt_pos = pos;
f0100688:	0f b6 c0             	movzbl %al,%eax
f010068b:	09 c8                	or     %ecx,%eax
f010068d:	66 a3 28 82 22 f0    	mov    %ax,0xf0228228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100693:	e8 1c ff ff ff       	call   f01005b4 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100698:	83 ec 0c             	sub    $0xc,%esp
f010069b:	0f b7 05 88 d3 11 f0 	movzwl 0xf011d388,%eax
f01006a2:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006a7:	50                   	push   %eax
f01006a8:	e8 de 24 00 00       	call   f0102b8b <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ad:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01006b7:	89 f2                	mov    %esi,%edx
f01006b9:	ee                   	out    %al,(%dx)
f01006ba:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006bf:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006c4:	ee                   	out    %al,(%dx)
f01006c5:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006ca:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006cf:	89 da                	mov    %ebx,%edx
f01006d1:	ee                   	out    %al,(%dx)
f01006d2:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01006dc:	ee                   	out    %al,(%dx)
f01006dd:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006e2:	b8 03 00 00 00       	mov    $0x3,%eax
f01006e7:	ee                   	out    %al,(%dx)
f01006e8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01006f2:	ee                   	out    %al,(%dx)
f01006f3:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006f8:	b8 01 00 00 00       	mov    $0x1,%eax
f01006fd:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fe:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100703:	ec                   	in     (%dx),%al
f0100704:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100706:	83 c4 10             	add    $0x10,%esp
f0100709:	3c ff                	cmp    $0xff,%al
f010070b:	0f 95 05 34 82 22 f0 	setne  0xf0228234
f0100712:	89 f2                	mov    %esi,%edx
f0100714:	ec                   	in     (%dx),%al
f0100715:	89 da                	mov    %ebx,%edx
f0100717:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100718:	80 f9 ff             	cmp    $0xff,%cl
f010071b:	75 10                	jne    f010072d <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f010071d:	83 ec 0c             	sub    $0xc,%esp
f0100720:	68 4f 50 10 f0       	push   $0xf010504f
f0100725:	e8 b2 25 00 00       	call   f0102cdc <cprintf>
f010072a:	83 c4 10             	add    $0x10,%esp
}
f010072d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100730:	5b                   	pop    %ebx
f0100731:	5e                   	pop    %esi
f0100732:	5f                   	pop    %edi
f0100733:	5d                   	pop    %ebp
f0100734:	c3                   	ret    

f0100735 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100735:	55                   	push   %ebp
f0100736:	89 e5                	mov    %esp,%ebp
f0100738:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010073b:	8b 45 08             	mov    0x8(%ebp),%eax
f010073e:	e8 6c fc ff ff       	call   f01003af <cons_putc>
}
f0100743:	c9                   	leave  
f0100744:	c3                   	ret    

f0100745 <getchar>:

int
getchar(void)
{
f0100745:	55                   	push   %ebp
f0100746:	89 e5                	mov    %esp,%ebp
f0100748:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010074b:	e8 76 fe ff ff       	call   f01005c6 <cons_getc>
f0100750:	85 c0                	test   %eax,%eax
f0100752:	74 f7                	je     f010074b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100754:	c9                   	leave  
f0100755:	c3                   	ret    

f0100756 <iscons>:

int
iscons(int fdnum)
{
f0100756:	55                   	push   %ebp
f0100757:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100759:	b8 01 00 00 00       	mov    $0x1,%eax
f010075e:	5d                   	pop    %ebp
f010075f:	c3                   	ret    

f0100760 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100760:	55                   	push   %ebp
f0100761:	89 e5                	mov    %esp,%ebp
f0100763:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100766:	68 a0 52 10 f0       	push   $0xf01052a0
f010076b:	68 be 52 10 f0       	push   $0xf01052be
f0100770:	68 c3 52 10 f0       	push   $0xf01052c3
f0100775:	e8 62 25 00 00       	call   f0102cdc <cprintf>
f010077a:	83 c4 0c             	add    $0xc,%esp
f010077d:	68 7c 53 10 f0       	push   $0xf010537c
f0100782:	68 cc 52 10 f0       	push   $0xf01052cc
f0100787:	68 c3 52 10 f0       	push   $0xf01052c3
f010078c:	e8 4b 25 00 00       	call   f0102cdc <cprintf>
f0100791:	83 c4 0c             	add    $0xc,%esp
f0100794:	68 d5 52 10 f0       	push   $0xf01052d5
f0100799:	68 f3 52 10 f0       	push   $0xf01052f3
f010079e:	68 c3 52 10 f0       	push   $0xf01052c3
f01007a3:	e8 34 25 00 00       	call   f0102cdc <cprintf>
	return 0;
}
f01007a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ad:	c9                   	leave  
f01007ae:	c3                   	ret    

f01007af <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007af:	55                   	push   %ebp
f01007b0:	89 e5                	mov    %esp,%ebp
f01007b2:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007b5:	68 fd 52 10 f0       	push   $0xf01052fd
f01007ba:	e8 1d 25 00 00       	call   f0102cdc <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007bf:	83 c4 08             	add    $0x8,%esp
f01007c2:	68 0c 00 10 00       	push   $0x10000c
f01007c7:	68 a4 53 10 f0       	push   $0xf01053a4
f01007cc:	e8 0b 25 00 00       	call   f0102cdc <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007d1:	83 c4 0c             	add    $0xc,%esp
f01007d4:	68 0c 00 10 00       	push   $0x10000c
f01007d9:	68 0c 00 10 f0       	push   $0xf010000c
f01007de:	68 cc 53 10 f0       	push   $0xf01053cc
f01007e3:	e8 f4 24 00 00       	call   f0102cdc <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007e8:	83 c4 0c             	add    $0xc,%esp
f01007eb:	68 71 4f 10 00       	push   $0x104f71
f01007f0:	68 71 4f 10 f0       	push   $0xf0104f71
f01007f5:	68 f0 53 10 f0       	push   $0xf01053f0
f01007fa:	e8 dd 24 00 00       	call   f0102cdc <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007ff:	83 c4 0c             	add    $0xc,%esp
f0100802:	68 00 80 22 00       	push   $0x228000
f0100807:	68 00 80 22 f0       	push   $0xf0228000
f010080c:	68 14 54 10 f0       	push   $0xf0105414
f0100811:	e8 c6 24 00 00       	call   f0102cdc <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100816:	83 c4 0c             	add    $0xc,%esp
f0100819:	68 08 a0 26 00       	push   $0x26a008
f010081e:	68 08 a0 26 f0       	push   $0xf026a008
f0100823:	68 38 54 10 f0       	push   $0xf0105438
f0100828:	e8 af 24 00 00       	call   f0102cdc <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010082d:	b8 07 a4 26 f0       	mov    $0xf026a407,%eax
f0100832:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100837:	83 c4 08             	add    $0x8,%esp
f010083a:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010083f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100845:	85 c0                	test   %eax,%eax
f0100847:	0f 48 c2             	cmovs  %edx,%eax
f010084a:	c1 f8 0a             	sar    $0xa,%eax
f010084d:	50                   	push   %eax
f010084e:	68 5c 54 10 f0       	push   $0xf010545c
f0100853:	e8 84 24 00 00       	call   f0102cdc <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100858:	b8 00 00 00 00       	mov    $0x0,%eax
f010085d:	c9                   	leave  
f010085e:	c3                   	ret    

f010085f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010085f:	55                   	push   %ebp
f0100860:	89 e5                	mov    %esp,%ebp
f0100862:	57                   	push   %edi
f0100863:	56                   	push   %esi
f0100864:	53                   	push   %ebx
f0100865:	83 ec 78             	sub    $0x78,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100868:	89 eb                	mov    %ebp,%ebx

	uint32_t _ebp, _eip;
	// _esp = read_esp();
	_ebp = read_ebp();

	uint32_t args[5] = {0, 0, 0, 0, 0};
f010086a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100871:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100878:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010087f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100886:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");
f010088d:	68 16 53 10 f0       	push   $0xf0105316
f0100892:	e8 45 24 00 00       	call   f0102cdc <cprintf>

	while (_ebp != 0) {
f0100897:	83 c4 10             	add    $0x10,%esp
f010089a:	e9 a6 00 00 00       	jmp    f0100945 <mon_backtrace+0xe6>
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr
f010089f:	8b 73 04             	mov    0x4(%ebx),%esi

		for (int i=0; i<5; i++) {
f01008a2:	b8 00 00 00 00       	mov    $0x0,%eax
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
f01008a7:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f01008ab:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)

	while (_ebp != 0) {
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr

		for (int i=0; i<5; i++) {
f01008af:	83 c0 01             	add    $0x1,%eax
f01008b2:	83 f8 05             	cmp    $0x5,%eax
f01008b5:	75 f0                	jne    f01008a7 <mon_backtrace+0x48>
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
		}

		debuginfo_eip((uintptr_t)_eip, &context);
f01008b7:	83 ec 08             	sub    $0x8,%esp
f01008ba:	8d 45 bc             	lea    -0x44(%ebp),%eax
f01008bd:	50                   	push   %eax
f01008be:	56                   	push   %esi
f01008bf:	e8 8e 2f 00 00       	call   f0103852 <debuginfo_eip>

		char function_name[50] = {0};
f01008c4:	c7 45 8a 00 00 00 00 	movl   $0x0,-0x76(%ebp)
f01008cb:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
f01008d2:	8d 7d 8c             	lea    -0x74(%ebp),%edi
f01008d5:	b9 0c 00 00 00       	mov    $0xc,%ecx
f01008da:	b8 00 00 00 00       	mov    $0x0,%eax
f01008df:	f3 ab                	rep stos %eax,%es:(%edi)
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f01008e1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
			function_name[i] = context.eip_fn_name[i];
f01008e4:	8b 7d c4             	mov    -0x3c(%ebp),%edi

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f01008e7:	83 c4 10             	add    $0x10,%esp
f01008ea:	eb 0b                	jmp    f01008f7 <mon_backtrace+0x98>
			function_name[i] = context.eip_fn_name[i];
f01008ec:	0f b6 14 07          	movzbl (%edi,%eax,1),%edx
f01008f0:	88 54 05 8a          	mov    %dl,-0x76(%ebp,%eax,1)

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f01008f4:	83 c0 01             	add    $0x1,%eax
f01008f7:	39 c8                	cmp    %ecx,%eax
f01008f9:	7c f1                	jl     f01008ec <mon_backtrace+0x8d>
			function_name[i] = context.eip_fn_name[i];
		}
		function_name[i] = '\0';
f01008fb:	85 c9                	test   %ecx,%ecx
f01008fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100902:	0f 48 c8             	cmovs  %eax,%ecx
f0100905:	c6 44 0d 8a 00       	movb   $0x0,-0x76(%ebp,%ecx,1)

		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", _ebp, _eip, args[0], args[1], args[2], args[3], args[4]);
f010090a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010090d:	ff 75 e0             	pushl  -0x20(%ebp)
f0100910:	ff 75 dc             	pushl  -0x24(%ebp)
f0100913:	ff 75 d8             	pushl  -0x28(%ebp)
f0100916:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100919:	56                   	push   %esi
f010091a:	53                   	push   %ebx
f010091b:	68 88 54 10 f0       	push   $0xf0105488
f0100920:	e8 b7 23 00 00       	call   f0102cdc <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f0100925:	83 c4 14             	add    $0x14,%esp
f0100928:	2b 75 cc             	sub    -0x34(%ebp),%esi
f010092b:	56                   	push   %esi
f010092c:	8d 45 8a             	lea    -0x76(%ebp),%eax
f010092f:	50                   	push   %eax
f0100930:	ff 75 c0             	pushl  -0x40(%ebp)
f0100933:	ff 75 bc             	pushl  -0x44(%ebp)
f0100936:	68 28 53 10 f0       	push   $0xf0105328
f010093b:	e8 9c 23 00 00       	call   f0102cdc <cprintf>

		// _rsp = _ebp + 8;			// old_rsp
		_ebp = *(uint32_t *)_ebp;	// old_ebp
f0100940:	8b 1b                	mov    (%ebx),%ebx
f0100942:	83 c4 20             	add    $0x20,%esp

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");

	while (_ebp != 0) {
f0100945:	85 db                	test   %ebx,%ebx
f0100947:	0f 85 52 ff ff ff    	jne    f010089f <mon_backtrace+0x40>
		_ebp = *(uint32_t *)_ebp;	// old_ebp

	} 

	return 0;
}
f010094d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100952:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100955:	5b                   	pop    %ebx
f0100956:	5e                   	pop    %esi
f0100957:	5f                   	pop    %edi
f0100958:	5d                   	pop    %ebp
f0100959:	c3                   	ret    

f010095a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010095a:	55                   	push   %ebp
f010095b:	89 e5                	mov    %esp,%ebp
f010095d:	57                   	push   %edi
f010095e:	56                   	push   %esi
f010095f:	53                   	push   %ebx
f0100960:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100963:	68 c0 54 10 f0       	push   $0xf01054c0
f0100968:	e8 6f 23 00 00       	call   f0102cdc <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010096d:	c7 04 24 e4 54 10 f0 	movl   $0xf01054e4,(%esp)
f0100974:	e8 63 23 00 00       	call   f0102cdc <cprintf>

	if (tf != NULL)
f0100979:	83 c4 10             	add    $0x10,%esp
f010097c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100980:	74 0e                	je     f0100990 <monitor+0x36>
		print_trapframe(tf);
f0100982:	83 ec 0c             	sub    $0xc,%esp
f0100985:	ff 75 08             	pushl  0x8(%ebp)
f0100988:	e8 92 27 00 00       	call   f010311f <print_trapframe>
f010098d:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100990:	83 ec 0c             	sub    $0xc,%esp
f0100993:	68 3f 53 10 f0       	push   $0xf010533f
f0100998:	e8 d8 36 00 00       	call   f0104075 <readline>
f010099d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010099f:	83 c4 10             	add    $0x10,%esp
f01009a2:	85 c0                	test   %eax,%eax
f01009a4:	74 ea                	je     f0100990 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009a6:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009ad:	be 00 00 00 00       	mov    $0x0,%esi
f01009b2:	eb 0a                	jmp    f01009be <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009b4:	c6 03 00             	movb   $0x0,(%ebx)
f01009b7:	89 f7                	mov    %esi,%edi
f01009b9:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009bc:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009be:	0f b6 03             	movzbl (%ebx),%eax
f01009c1:	84 c0                	test   %al,%al
f01009c3:	74 63                	je     f0100a28 <monitor+0xce>
f01009c5:	83 ec 08             	sub    $0x8,%esp
f01009c8:	0f be c0             	movsbl %al,%eax
f01009cb:	50                   	push   %eax
f01009cc:	68 43 53 10 f0       	push   $0xf0105343
f01009d1:	e8 b9 38 00 00       	call   f010428f <strchr>
f01009d6:	83 c4 10             	add    $0x10,%esp
f01009d9:	85 c0                	test   %eax,%eax
f01009db:	75 d7                	jne    f01009b4 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009dd:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009e0:	74 46                	je     f0100a28 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009e2:	83 fe 0f             	cmp    $0xf,%esi
f01009e5:	75 14                	jne    f01009fb <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009e7:	83 ec 08             	sub    $0x8,%esp
f01009ea:	6a 10                	push   $0x10
f01009ec:	68 48 53 10 f0       	push   $0xf0105348
f01009f1:	e8 e6 22 00 00       	call   f0102cdc <cprintf>
f01009f6:	83 c4 10             	add    $0x10,%esp
f01009f9:	eb 95                	jmp    f0100990 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01009fb:	8d 7e 01             	lea    0x1(%esi),%edi
f01009fe:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a02:	eb 03                	jmp    f0100a07 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a04:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a07:	0f b6 03             	movzbl (%ebx),%eax
f0100a0a:	84 c0                	test   %al,%al
f0100a0c:	74 ae                	je     f01009bc <monitor+0x62>
f0100a0e:	83 ec 08             	sub    $0x8,%esp
f0100a11:	0f be c0             	movsbl %al,%eax
f0100a14:	50                   	push   %eax
f0100a15:	68 43 53 10 f0       	push   $0xf0105343
f0100a1a:	e8 70 38 00 00       	call   f010428f <strchr>
f0100a1f:	83 c4 10             	add    $0x10,%esp
f0100a22:	85 c0                	test   %eax,%eax
f0100a24:	74 de                	je     f0100a04 <monitor+0xaa>
f0100a26:	eb 94                	jmp    f01009bc <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a28:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a2f:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a30:	85 f6                	test   %esi,%esi
f0100a32:	0f 84 58 ff ff ff    	je     f0100990 <monitor+0x36>
f0100a38:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a3d:	83 ec 08             	sub    $0x8,%esp
f0100a40:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a43:	ff 34 85 20 55 10 f0 	pushl  -0xfefaae0(,%eax,4)
f0100a4a:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a4d:	e8 df 37 00 00       	call   f0104231 <strcmp>
f0100a52:	83 c4 10             	add    $0x10,%esp
f0100a55:	85 c0                	test   %eax,%eax
f0100a57:	75 21                	jne    f0100a7a <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100a59:	83 ec 04             	sub    $0x4,%esp
f0100a5c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a5f:	ff 75 08             	pushl  0x8(%ebp)
f0100a62:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a65:	52                   	push   %edx
f0100a66:	56                   	push   %esi
f0100a67:	ff 14 85 28 55 10 f0 	call   *-0xfefaad8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a6e:	83 c4 10             	add    $0x10,%esp
f0100a71:	85 c0                	test   %eax,%eax
f0100a73:	78 25                	js     f0100a9a <monitor+0x140>
f0100a75:	e9 16 ff ff ff       	jmp    f0100990 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a7a:	83 c3 01             	add    $0x1,%ebx
f0100a7d:	83 fb 03             	cmp    $0x3,%ebx
f0100a80:	75 bb                	jne    f0100a3d <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a82:	83 ec 08             	sub    $0x8,%esp
f0100a85:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a88:	68 65 53 10 f0       	push   $0xf0105365
f0100a8d:	e8 4a 22 00 00       	call   f0102cdc <cprintf>
f0100a92:	83 c4 10             	add    $0x10,%esp
f0100a95:	e9 f6 fe ff ff       	jmp    f0100990 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a9d:	5b                   	pop    %ebx
f0100a9e:	5e                   	pop    %esi
f0100a9f:	5f                   	pop    %edi
f0100aa0:	5d                   	pop    %ebp
f0100aa1:	c3                   	ret    

f0100aa2 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100aa2:	55                   	push   %ebp
f0100aa3:	89 e5                	mov    %esp,%ebp
f0100aa5:	56                   	push   %esi
f0100aa6:	53                   	push   %ebx
f0100aa7:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100aa9:	83 ec 0c             	sub    $0xc,%esp
f0100aac:	50                   	push   %eax
f0100aad:	e8 ab 20 00 00       	call   f0102b5d <mc146818_read>
f0100ab2:	89 c6                	mov    %eax,%esi
f0100ab4:	83 c3 01             	add    $0x1,%ebx
f0100ab7:	89 1c 24             	mov    %ebx,(%esp)
f0100aba:	e8 9e 20 00 00       	call   f0102b5d <mc146818_read>
f0100abf:	c1 e0 08             	shl    $0x8,%eax
f0100ac2:	09 f0                	or     %esi,%eax
}
f0100ac4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ac7:	5b                   	pop    %ebx
f0100ac8:	5e                   	pop    %esi
f0100ac9:	5d                   	pop    %ebp
f0100aca:	c3                   	ret    

f0100acb <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100acb:	83 3d 38 82 22 f0 00 	cmpl   $0x0,0xf0228238
f0100ad2:	75 11                	jne    f0100ae5 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ad4:	ba 07 b0 26 f0       	mov    $0xf026b007,%edx
f0100ad9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100adf:	89 15 38 82 22 f0    	mov    %edx,0xf0228238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f0100ae5:	8b 15 38 82 22 f0    	mov    0xf0228238,%edx
f0100aeb:	89 c1                	mov    %eax,%ecx
f0100aed:	f7 d1                	not    %ecx
f0100aef:	39 ca                	cmp    %ecx,%edx
f0100af1:	76 17                	jbe    f0100b0a <boot_alloc+0x3f>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100af3:	55                   	push   %ebp
f0100af4:	89 e5                	mov    %esp,%ebp
f0100af6:	83 ec 0c             	sub    $0xc,%esp
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
		panic("boot_alloc: out of memory\n");
f0100af9:	68 44 55 10 f0       	push   $0xf0105544
f0100afe:	6a 6e                	push   $0x6e
f0100b00:	68 5f 55 10 f0       	push   $0xf010555f
f0100b05:	e8 36 f5 ff ff       	call   f0100040 <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f0100b0a:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b16:	a3 38 82 22 f0       	mov    %eax,0xf0228238

	return result;
}
f0100b1b:	89 d0                	mov    %edx,%eax
f0100b1d:	c3                   	ret    

f0100b1e <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b1e:	2b 05 10 8f 22 f0    	sub    0xf0228f10,%eax
f0100b24:	c1 f8 03             	sar    $0x3,%eax
f0100b27:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b2a:	89 c2                	mov    %eax,%edx
f0100b2c:	c1 ea 0c             	shr    $0xc,%edx
f0100b2f:	39 15 08 8f 22 f0    	cmp    %edx,0xf0228f08
f0100b35:	77 18                	ja     f0100b4f <page2kva+0x31>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100b37:	55                   	push   %ebp
f0100b38:	89 e5                	mov    %esp,%ebp
f0100b3a:	83 ec 08             	sub    $0x8,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b3d:	50                   	push   %eax
f0100b3e:	68 a4 4f 10 f0       	push   $0xf0104fa4
f0100b43:	6a 58                	push   $0x58
f0100b45:	68 6b 55 10 f0       	push   $0xf010556b
f0100b4a:	e8 f1 f4 ff ff       	call   f0100040 <_panic>
}

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
f0100b4f:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0100b54:	c3                   	ret    

f0100b55 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b55:	89 d1                	mov    %edx,%ecx
f0100b57:	c1 e9 16             	shr    $0x16,%ecx
f0100b5a:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b5d:	a8 01                	test   $0x1,%al
f0100b5f:	74 52                	je     f0100bb3 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b61:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b66:	89 c1                	mov    %eax,%ecx
f0100b68:	c1 e9 0c             	shr    $0xc,%ecx
f0100b6b:	3b 0d 08 8f 22 f0    	cmp    0xf0228f08,%ecx
f0100b71:	72 1b                	jb     f0100b8e <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b73:	55                   	push   %ebp
f0100b74:	89 e5                	mov    %esp,%ebp
f0100b76:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b79:	50                   	push   %eax
f0100b7a:	68 a4 4f 10 f0       	push   $0xf0104fa4
f0100b7f:	68 0e 04 00 00       	push   $0x40e
f0100b84:	68 5f 55 10 f0       	push   $0xf010555f
f0100b89:	e8 b2 f4 ff ff       	call   f0100040 <_panic>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));

	// cprintf("[?] In check_va2pa\n");
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
f0100b8e:	c1 ea 0c             	shr    $0xc,%edx
f0100b91:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b97:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b9e:	89 c2                	mov    %eax,%edx
f0100ba0:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ba3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ba8:	85 d2                	test   %edx,%edx
f0100baa:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100baf:	0f 44 c2             	cmove  %edx,%eax
f0100bb2:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100bb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100bb8:	c3                   	ret    

f0100bb9 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100bb9:	55                   	push   %ebp
f0100bba:	89 e5                	mov    %esp,%ebp
f0100bbc:	56                   	push   %esi
f0100bbd:	53                   	push   %ebx
	// 	pages[i].pp_link = page_free_list;
	// 	page_free_list = &pages[i];
	// }

	// 1)	first page in use
	pages[0].pp_ref = 1;
f0100bbe:	a1 10 8f 22 f0       	mov    0xf0228f10,%eax
f0100bc3:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100bc9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100bcf:	8b 35 44 82 22 f0    	mov    0xf0228244,%esi
f0100bd5:	8b 0d 40 82 22 f0    	mov    0xf0228240,%ecx
f0100bdb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100be0:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100be5:	eb 27                	jmp    f0100c0e <page_init+0x55>
		pages[i].pp_ref = 0;
f0100be7:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100bee:	89 c2                	mov    %eax,%edx
f0100bf0:	03 15 10 8f 22 f0    	add    0xf0228f10,%edx
f0100bf6:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100bfc:	89 0a                	mov    %ecx,(%edx)
	// 1)	first page in use
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100bfe:	83 c3 01             	add    $0x1,%ebx
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100c01:	03 05 10 8f 22 f0    	add    0xf0228f10,%eax
f0100c07:	89 c1                	mov    %eax,%ecx
f0100c09:	b8 01 00 00 00       	mov    $0x1,%eax
	// 1)	first page in use
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100c0e:	39 f3                	cmp    %esi,%ebx
f0100c10:	72 d5                	jb     f0100be7 <page_init+0x2e>
f0100c12:	84 c0                	test   %al,%al
f0100c14:	74 06                	je     f0100c1c <page_init+0x63>
f0100c16:	89 0d 40 82 22 f0    	mov    %ecx,0xf0228240
f0100c1c:	8b 0d 40 82 22 f0    	mov    0xf0228240,%ecx
f0100c22:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100c29:	ba 00 00 00 00       	mov    $0x0,%edx
f0100c2e:	eb 23                	jmp    f0100c53 <page_init+0x9a>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100c30:	89 c2                	mov    %eax,%edx
f0100c32:	03 15 10 8f 22 f0    	add    0xf0228f10,%edx
f0100c38:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100c3e:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100c40:	89 c1                	mov    %eax,%ecx
f0100c42:	03 0d 10 8f 22 f0    	add    0xf0228f10,%ecx
		page_free_list = &pages[i];
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
f0100c48:	83 c3 01             	add    $0x1,%ebx
f0100c4b:	83 c0 08             	add    $0x8,%eax
f0100c4e:	ba 01 00 00 00       	mov    $0x1,%edx
f0100c53:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100c59:	76 d5                	jbe    f0100c30 <page_init+0x77>
f0100c5b:	84 d2                	test   %dl,%dl
f0100c5d:	74 06                	je     f0100c65 <page_init+0xac>
f0100c5f:	89 0d 40 82 22 f0    	mov    %ecx,0xf0228240
f0100c65:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100c6c:	eb 1a                	jmp    f0100c88 <page_init+0xcf>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100c6e:	89 c2                	mov    %eax,%edx
f0100c70:	03 15 10 8f 22 f0    	add    0xf0228f10,%edx
f0100c76:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = 0;
f0100c7c:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
f0100c82:	83 c3 01             	add    $0x1,%ebx
f0100c85:	83 c0 08             	add    $0x8,%eax
f0100c88:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100c8e:	76 de                	jbe    f0100c6e <page_init+0xb5>
f0100c90:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f0100c97:	eb 1a                	jmp    f0100cb3 <page_init+0xfa>


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100c99:	89 f0                	mov    %esi,%eax
f0100c9b:	03 05 10 8f 22 f0    	add    0xf0228f10,%eax
f0100ca1:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = 0;
f0100ca7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
f0100cad:	83 c3 01             	add    $0x1,%ebx
f0100cb0:	83 c6 08             	add    $0x8,%esi
f0100cb3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cb8:	e8 0e fe ff ff       	call   f0100acb <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100cbd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100cc2:	77 15                	ja     f0100cd9 <page_init+0x120>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100cc4:	50                   	push   %eax
f0100cc5:	68 c8 4f 10 f0       	push   $0xf0104fc8
f0100cca:	68 69 01 00 00       	push   $0x169
f0100ccf:	68 5f 55 10 f0       	push   $0xf010555f
f0100cd4:	e8 67 f3 ff ff       	call   f0100040 <_panic>
f0100cd9:	05 00 00 00 10       	add    $0x10000000,%eax
f0100cde:	c1 e8 0c             	shr    $0xc,%eax
f0100ce1:	39 c3                	cmp    %eax,%ebx
f0100ce3:	72 b4                	jb     f0100c99 <page_init+0xe0>
f0100ce5:	8b 0d 40 82 22 f0    	mov    0xf0228240,%ecx
f0100ceb:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100cf2:	ba 00 00 00 00       	mov    $0x0,%edx
f0100cf7:	eb 23                	jmp    f0100d1c <page_init+0x163>
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f0100cf9:	89 c2                	mov    %eax,%edx
f0100cfb:	03 15 10 8f 22 f0    	add    0xf0228f10,%edx
f0100d01:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100d07:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100d09:	89 c1                	mov    %eax,%ecx
f0100d0b:	03 0d 10 8f 22 f0    	add    0xf0228f10,%ecx
		pages[i].pp_link = 0;
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
f0100d11:	83 c3 01             	add    $0x1,%ebx
f0100d14:	83 c0 08             	add    $0x8,%eax
f0100d17:	ba 01 00 00 00       	mov    $0x1,%edx
f0100d1c:	3b 1d 08 8f 22 f0    	cmp    0xf0228f08,%ebx
f0100d22:	72 d5                	jb     f0100cf9 <page_init+0x140>
f0100d24:	84 d2                	test   %dl,%dl
f0100d26:	74 06                	je     f0100d2e <page_init+0x175>
f0100d28:	89 0d 40 82 22 f0    	mov    %ecx,0xf0228240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

}
f0100d2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100d31:	5b                   	pop    %ebx
f0100d32:	5e                   	pop    %esi
f0100d33:	5d                   	pop    %ebp
f0100d34:	c3                   	ret    

f0100d35 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100d35:	55                   	push   %ebp
f0100d36:	89 e5                	mov    %esp,%ebp
f0100d38:	56                   	push   %esi
f0100d39:	53                   	push   %ebx
	// Fill this function in

	// no more page in free list, we run out of free memory
	if (page_free_list == 0)
f0100d3a:	8b 1d 40 82 22 f0    	mov    0xf0228240,%ebx
f0100d40:	85 db                	test   %ebx,%ebx
f0100d42:	74 59                	je     f0100d9d <page_alloc+0x68>
		return 0;

	// get the previous page in free link
	struct PageInfo* last_free = page_free_list->pp_link;
f0100d44:	8b 33                	mov    (%ebx),%esi
	struct PageInfo* result = page_free_list;

	// get a free page from the list
	page_free_list->pp_link = 0;
f0100d46:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) {
f0100d4c:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100d50:	74 45                	je     f0100d97 <page_alloc+0x62>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d52:	89 d8                	mov    %ebx,%eax
f0100d54:	2b 05 10 8f 22 f0    	sub    0xf0228f10,%eax
f0100d5a:	c1 f8 03             	sar    $0x3,%eax
f0100d5d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d60:	89 c2                	mov    %eax,%edx
f0100d62:	c1 ea 0c             	shr    $0xc,%edx
f0100d65:	3b 15 08 8f 22 f0    	cmp    0xf0228f08,%edx
f0100d6b:	72 12                	jb     f0100d7f <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d6d:	50                   	push   %eax
f0100d6e:	68 a4 4f 10 f0       	push   $0xf0104fa4
f0100d73:	6a 58                	push   $0x58
f0100d75:	68 6b 55 10 f0       	push   $0xf010556b
f0100d7a:	e8 c1 f2 ff ff       	call   f0100040 <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f0100d7f:	83 ec 04             	sub    $0x4,%esp
f0100d82:	68 00 10 00 00       	push   $0x1000
f0100d87:	6a 00                	push   $0x0
f0100d89:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d8e:	50                   	push   %eax
f0100d8f:	e8 38 35 00 00       	call   f01042cc <memset>
f0100d94:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f0100d97:	89 35 40 82 22 f0    	mov    %esi,0xf0228240

	return result;
}
f0100d9d:	89 d8                	mov    %ebx,%eax
f0100d9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100da2:	5b                   	pop    %ebx
f0100da3:	5e                   	pop    %esi
f0100da4:	5d                   	pop    %ebp
f0100da5:	c3                   	ret    

f0100da6 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100da6:	55                   	push   %ebp
f0100da7:	89 e5                	mov    %esp,%ebp
f0100da9:	83 ec 08             	sub    $0x8,%esp
f0100dac:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.

	if (pp == 0)
f0100daf:	85 c0                	test   %eax,%eax
f0100db1:	74 47                	je     f0100dfa <page_free+0x54>
		return;
	if (pp->pp_link != 0)
f0100db3:	83 38 00             	cmpl   $0x0,(%eax)
f0100db6:	74 17                	je     f0100dcf <page_free+0x29>
		panic("page_free: double free or corrupted\n");
f0100db8:	83 ec 04             	sub    $0x4,%esp
f0100dbb:	68 18 58 10 f0       	push   $0xf0105818
f0100dc0:	68 ae 01 00 00       	push   $0x1ae
f0100dc5:	68 5f 55 10 f0       	push   $0xf010555f
f0100dca:	e8 71 f2 ff ff       	call   f0100040 <_panic>
	if (pp->pp_ref != 0)
f0100dcf:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100dd4:	74 17                	je     f0100ded <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0100dd6:	83 ec 04             	sub    $0x4,%esp
f0100dd9:	68 40 58 10 f0       	push   $0xf0105840
f0100dde:	68 b0 01 00 00       	push   $0x1b0
f0100de3:	68 5f 55 10 f0       	push   $0xf010555f
f0100de8:	e8 53 f2 ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f0100ded:	8b 15 40 82 22 f0    	mov    0xf0228240,%edx
f0100df3:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100df5:	a3 40 82 22 f0       	mov    %eax,0xf0228240

}
f0100dfa:	c9                   	leave  
f0100dfb:	c3                   	ret    

f0100dfc <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100dfc:	55                   	push   %ebp
f0100dfd:	89 e5                	mov    %esp,%ebp
f0100dff:	83 ec 08             	sub    $0x8,%esp
f0100e02:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100e05:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100e09:	83 e8 01             	sub    $0x1,%eax
f0100e0c:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100e10:	66 85 c0             	test   %ax,%ax
f0100e13:	75 0c                	jne    f0100e21 <page_decref+0x25>
		page_free(pp);
f0100e15:	83 ec 0c             	sub    $0xc,%esp
f0100e18:	52                   	push   %edx
f0100e19:	e8 88 ff ff ff       	call   f0100da6 <page_free>
f0100e1e:	83 c4 10             	add    $0x10,%esp
}
f0100e21:	c9                   	leave  
f0100e22:	c3                   	ret    

f0100e23 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e23:	55                   	push   %ebp
f0100e24:	89 e5                	mov    %esp,%ebp
f0100e26:	56                   	push   %esi
f0100e27:	53                   	push   %ebx
f0100e28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	// we have virtual address
	// cprintf("[?] %x\n", va);
	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f0100e2b:	89 de                	mov    %ebx,%esi
f0100e2d:	c1 ee 0c             	shr    $0xc,%esi
f0100e30:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
f0100e36:	c1 eb 16             	shr    $0x16,%ebx
f0100e39:	c1 e3 02             	shl    $0x2,%ebx
f0100e3c:	03 5d 08             	add    0x8(%ebp),%ebx
f0100e3f:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100e42:	75 30                	jne    f0100e74 <pgdir_walk+0x51>
		if (create == 0)
f0100e44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e48:	74 5c                	je     f0100ea6 <pgdir_walk+0x83>
			return NULL;
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f0100e4a:	83 ec 0c             	sub    $0xc,%esp
f0100e4d:	6a 01                	push   $0x1
f0100e4f:	e8 e1 fe ff ff       	call   f0100d35 <page_alloc>
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
f0100e54:	83 c4 10             	add    $0x10,%esp
f0100e57:	85 c0                	test   %eax,%eax
f0100e59:	74 52                	je     f0100ead <pgdir_walk+0x8a>
		// set level 1 page table entry to this new level 2 page table
		// this new page is for level2 PT, so flags are:
		// 	PTE_P: this page is present
		//	PTE_U: user process can use this page
		//	PTE_W: this page can be edit
		pgdir[Page_Directory_Index] = page2pa(new_page) | PTE_P | PTE_U | PTE_W;
f0100e5b:	89 c2                	mov    %eax,%edx
f0100e5d:	2b 15 10 8f 22 f0    	sub    0xf0228f10,%edx
f0100e63:	c1 fa 03             	sar    $0x3,%edx
f0100e66:	c1 e2 0c             	shl    $0xc,%edx
f0100e69:	83 ca 07             	or     $0x7,%edx
f0100e6c:	89 13                	mov    %edx,(%ebx)
		new_page->pp_ref = 1;
f0100e6e:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	// cprintf("[?] %x\n", KADDR(PTE_ADDR(pgdir[Page_Directory_Index])));
	
	// remember each entry is 4 byte long
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));
f0100e74:	8b 03                	mov    (%ebx),%eax
f0100e76:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e7b:	89 c2                	mov    %eax,%edx
f0100e7d:	c1 ea 0c             	shr    $0xc,%edx
f0100e80:	3b 15 08 8f 22 f0    	cmp    0xf0228f08,%edx
f0100e86:	72 15                	jb     f0100e9d <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e88:	50                   	push   %eax
f0100e89:	68 a4 4f 10 f0       	push   $0xf0104fa4
f0100e8e:	68 fd 01 00 00       	push   $0x1fd
f0100e93:	68 5f 55 10 f0       	push   $0xf010555f
f0100e98:	e8 a3 f1 ff ff       	call   f0100040 <_panic>

	return &p[Page_Table_Index];
f0100e9d:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0100ea4:	eb 0c                	jmp    f0100eb2 <pgdir_walk+0x8f>
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
		if (create == 0)
			return NULL;
f0100ea6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eab:	eb 05                	jmp    f0100eb2 <pgdir_walk+0x8f>
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
			return NULL;
f0100ead:	b8 00 00 00 00       	mov    $0x0,%eax
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));

	return &p[Page_Table_Index];
}
f0100eb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100eb5:	5b                   	pop    %ebx
f0100eb6:	5e                   	pop    %esi
f0100eb7:	5d                   	pop    %ebp
f0100eb8:	c3                   	ret    

f0100eb9 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100eb9:	55                   	push   %ebp
f0100eba:	89 e5                	mov    %esp,%ebp
f0100ebc:	53                   	push   %ebx
f0100ebd:	83 ec 08             	sub    $0x8,%esp
f0100ec0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in

	// do a page table walk to find real PTE
	pte_t * pte = pgdir_walk(pgdir, va, 0);
f0100ec3:	6a 00                	push   $0x0
f0100ec5:	ff 75 0c             	pushl  0xc(%ebp)
f0100ec8:	ff 75 08             	pushl  0x8(%ebp)
f0100ecb:	e8 53 ff ff ff       	call   f0100e23 <pgdir_walk>

	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
f0100ed0:	83 c4 10             	add    $0x10,%esp
f0100ed3:	85 c0                	test   %eax,%eax
f0100ed5:	74 37                	je     f0100f0e <page_lookup+0x55>
f0100ed7:	83 38 00             	cmpl   $0x0,(%eax)
f0100eda:	74 39                	je     f0100f15 <page_lookup+0x5c>
		return NULL;
	
	// store pte
	if (pte_store != 0)
f0100edc:	85 db                	test   %ebx,%ebx
f0100ede:	74 02                	je     f0100ee2 <page_lookup+0x29>
		*pte_store = pte;
f0100ee0:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ee2:	8b 00                	mov    (%eax),%eax
f0100ee4:	c1 e8 0c             	shr    $0xc,%eax
f0100ee7:	3b 05 08 8f 22 f0    	cmp    0xf0228f08,%eax
f0100eed:	72 14                	jb     f0100f03 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0100eef:	83 ec 04             	sub    $0x4,%esp
f0100ef2:	68 84 58 10 f0       	push   $0xf0105884
f0100ef7:	6a 51                	push   $0x51
f0100ef9:	68 6b 55 10 f0       	push   $0xf010556b
f0100efe:	e8 3d f1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0100f03:	8b 15 10 8f 22 f0    	mov    0xf0228f10,%edx
f0100f09:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte)) ;
f0100f0c:	eb 0c                	jmp    f0100f1a <page_lookup+0x61>
	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
		return NULL;
f0100f0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f13:	eb 05                	jmp    f0100f1a <page_lookup+0x61>
f0100f15:	b8 00 00 00 00       	mov    $0x0,%eax
	// store pte
	if (pte_store != 0)
		*pte_store = pte;

	return pa2page(PTE_ADDR(*pte)) ;
}
f0100f1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f1d:	c9                   	leave  
f0100f1e:	c3                   	ret    

f0100f1f <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100f1f:	55                   	push   %ebp
f0100f20:	89 e5                	mov    %esp,%ebp
f0100f22:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0100f25:	e8 c4 39 00 00       	call   f01048ee <cpunum>
f0100f2a:	6b c0 74             	imul   $0x74,%eax,%eax
f0100f2d:	83 b8 28 90 22 f0 00 	cmpl   $0x0,-0xfdd6fd8(%eax)
f0100f34:	74 16                	je     f0100f4c <tlb_invalidate+0x2d>
f0100f36:	e8 b3 39 00 00       	call   f01048ee <cpunum>
f0100f3b:	6b c0 74             	imul   $0x74,%eax,%eax
f0100f3e:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f0100f44:	8b 55 08             	mov    0x8(%ebp),%edx
f0100f47:	39 50 60             	cmp    %edx,0x60(%eax)
f0100f4a:	75 06                	jne    f0100f52 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100f4c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f4f:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0100f52:	c9                   	leave  
f0100f53:	c3                   	ret    

f0100f54 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f54:	55                   	push   %ebp
f0100f55:	89 e5                	mov    %esp,%ebp
f0100f57:	56                   	push   %esi
f0100f58:	53                   	push   %ebx
f0100f59:	83 ec 14             	sub    $0x14,%esp
f0100f5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100f5f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in

	// pte_t *tmp;
	pte_t *pte_store = NULL;
f0100f62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * pp = page_lookup(pgdir, va, &pte_store);
f0100f69:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f6c:	50                   	push   %eax
f0100f6d:	56                   	push   %esi
f0100f6e:	53                   	push   %ebx
f0100f6f:	e8 45 ff ff ff       	call   f0100eb9 <page_lookup>

	// if not present, silently return
	if (pp == NULL)
f0100f74:	83 c4 10             	add    $0x10,%esp
f0100f77:	85 c0                	test   %eax,%eax
f0100f79:	74 1f                	je     f0100f9a <page_remove+0x46>
		return;

	// decrement ref count, and if reaches 0, free it
	page_decref(pp);
f0100f7b:	83 ec 0c             	sub    $0xc,%esp
f0100f7e:	50                   	push   %eax
f0100f7f:	e8 78 fe ff ff       	call   f0100dfc <page_decref>

	// null the real PTE pointer 
	*pte_store = 0;
f0100f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f87:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// cprintf("[?] In page_remove\n");
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", *pte_store, **pte_store);

	// tlb invalidate
	tlb_invalidate(pgdir, va);
f0100f8d:	83 c4 08             	add    $0x8,%esp
f0100f90:	56                   	push   %esi
f0100f91:	53                   	push   %ebx
f0100f92:	e8 88 ff ff ff       	call   f0100f1f <tlb_invalidate>
f0100f97:	83 c4 10             	add    $0x10,%esp

}
f0100f9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f9d:	5b                   	pop    %ebx
f0100f9e:	5e                   	pop    %esi
f0100f9f:	5d                   	pop    %ebp
f0100fa0:	c3                   	ret    

f0100fa1 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100fa1:	55                   	push   %ebp
f0100fa2:	89 e5                	mov    %esp,%ebp
f0100fa4:	57                   	push   %edi
f0100fa5:	56                   	push   %esi
f0100fa6:	53                   	push   %ebx
f0100fa7:	83 ec 10             	sub    $0x10,%esp
f0100faa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100fad:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	
f0100fb0:	6a 01                	push   $0x1
f0100fb2:	57                   	push   %edi
f0100fb3:	ff 75 08             	pushl  0x8(%ebp)
f0100fb6:	e8 68 fe ff ff       	call   f0100e23 <pgdir_walk>

	if (pte == 0)
f0100fbb:	83 c4 10             	add    $0x10,%esp
f0100fbe:	85 c0                	test   %eax,%eax
f0100fc0:	74 59                	je     f010101b <page_insert+0x7a>
f0100fc2:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;

	// already have a page
	// remove it and invalidate tlb
	if (*pte != 0) {
f0100fc4:	8b 00                	mov    (%eax),%eax
f0100fc6:	85 c0                	test   %eax,%eax
f0100fc8:	74 2d                	je     f0100ff7 <page_insert+0x56>
		// corner case
		if (page2pa(pp) == PTE_ADDR(*pte))
f0100fca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fcf:	89 da                	mov    %ebx,%edx
f0100fd1:	2b 15 10 8f 22 f0    	sub    0xf0228f10,%edx
f0100fd7:	c1 fa 03             	sar    $0x3,%edx
f0100fda:	c1 e2 0c             	shl    $0xc,%edx
f0100fdd:	39 d0                	cmp    %edx,%eax
f0100fdf:	75 07                	jne    f0100fe8 <page_insert+0x47>
			pp->pp_ref--;	// keep pp_ref consistent, in the meantime change perm potentially.
f0100fe1:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f0100fe6:	eb 0f                	jmp    f0100ff7 <page_insert+0x56>
		else
			page_remove(pgdir, va);
f0100fe8:	83 ec 08             	sub    $0x8,%esp
f0100feb:	57                   	push   %edi
f0100fec:	ff 75 08             	pushl  0x8(%ebp)
f0100fef:	e8 60 ff ff ff       	call   f0100f54 <page_remove>
f0100ff4:	83 c4 10             	add    $0x10,%esp

	// set the real PTE to pa, zero out least 12 bits
	*pte = PTE_ADDR(page2pa(pp));
	
	// set flags
	*pte |= (perm | PTE_P);
f0100ff7:	89 d8                	mov    %ebx,%eax
f0100ff9:	2b 05 10 8f 22 f0    	sub    0xf0228f10,%eax
f0100fff:	c1 f8 03             	sar    $0x3,%eax
f0101002:	c1 e0 0c             	shl    $0xc,%eax
f0101005:	8b 55 14             	mov    0x14(%ebp),%edx
f0101008:	83 ca 01             	or     $0x1,%edx
f010100b:	09 d0                	or     %edx,%eax
f010100d:	89 06                	mov    %eax,(%esi)

	// increment ref cnt
	pp->pp_ref++;
f010100f:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	return 0;
f0101014:	b8 00 00 00 00       	mov    $0x0,%eax
f0101019:	eb 05                	jmp    f0101020 <page_insert+0x7f>
	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	

	if (pte == 0)
		return -E_NO_MEM;
f010101b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	// increment ref cnt
	pp->pp_ref++;

	return 0;
}
f0101020:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101023:	5b                   	pop    %ebx
f0101024:	5e                   	pop    %esi
f0101025:	5f                   	pop    %edi
f0101026:	5d                   	pop    %ebp
f0101027:	c3                   	ret    

f0101028 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101028:	55                   	push   %ebp
f0101029:	89 e5                	mov    %esp,%ebp
f010102b:	83 ec 0c             	sub    $0xc,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	panic("mmio_map_region not implemented");
f010102e:	68 a4 58 10 f0       	push   $0xf01058a4
f0101033:	68 e2 02 00 00       	push   $0x2e2
f0101038:	68 5f 55 10 f0       	push   $0xf010555f
f010103d:	e8 fe ef ff ff       	call   f0100040 <_panic>

f0101042 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101042:	55                   	push   %ebp
f0101043:	89 e5                	mov    %esp,%ebp
f0101045:	57                   	push   %edi
f0101046:	56                   	push   %esi
f0101047:	53                   	push   %ebx
f0101048:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f010104b:	b8 15 00 00 00       	mov    $0x15,%eax
f0101050:	e8 4d fa ff ff       	call   f0100aa2 <nvram_read>
f0101055:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101057:	b8 17 00 00 00       	mov    $0x17,%eax
f010105c:	e8 41 fa ff ff       	call   f0100aa2 <nvram_read>
f0101061:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101063:	b8 34 00 00 00       	mov    $0x34,%eax
f0101068:	e8 35 fa ff ff       	call   f0100aa2 <nvram_read>
f010106d:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101070:	85 c0                	test   %eax,%eax
f0101072:	74 07                	je     f010107b <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0101074:	05 00 40 00 00       	add    $0x4000,%eax
f0101079:	eb 0b                	jmp    f0101086 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f010107b:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101081:	85 f6                	test   %esi,%esi
f0101083:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0101086:	89 c2                	mov    %eax,%edx
f0101088:	c1 ea 02             	shr    $0x2,%edx
f010108b:	89 15 08 8f 22 f0    	mov    %edx,0xf0228f08
	npages_basemem = basemem / (PGSIZE / 1024);
f0101091:	89 da                	mov    %ebx,%edx
f0101093:	c1 ea 02             	shr    $0x2,%edx
f0101096:	89 15 44 82 22 f0    	mov    %edx,0xf0228244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010109c:	89 c2                	mov    %eax,%edx
f010109e:	29 da                	sub    %ebx,%edx
f01010a0:	52                   	push   %edx
f01010a1:	53                   	push   %ebx
f01010a2:	50                   	push   %eax
f01010a3:	68 c4 58 10 f0       	push   $0xf01058c4
f01010a8:	e8 2f 1c 00 00       	call   f0102cdc <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01010ad:	b8 00 10 00 00       	mov    $0x1000,%eax
f01010b2:	e8 14 fa ff ff       	call   f0100acb <boot_alloc>
f01010b7:	a3 0c 8f 22 f0       	mov    %eax,0xf0228f0c
	memset(kern_pgdir, 0, PGSIZE);
f01010bc:	83 c4 0c             	add    $0xc,%esp
f01010bf:	68 00 10 00 00       	push   $0x1000
f01010c4:	6a 00                	push   $0x0
f01010c6:	50                   	push   %eax
f01010c7:	e8 00 32 00 00       	call   f01042cc <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01010cc:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01010d1:	83 c4 10             	add    $0x10,%esp
f01010d4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010d9:	77 15                	ja     f01010f0 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010db:	50                   	push   %eax
f01010dc:	68 c8 4f 10 f0       	push   $0xf0104fc8
f01010e1:	68 99 00 00 00       	push   $0x99
f01010e6:	68 5f 55 10 f0       	push   $0xf010555f
f01010eb:	e8 50 ef ff ff       	call   f0100040 <_panic>
f01010f0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01010f6:	83 ca 05             	or     $0x5,%edx
f01010f9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f01010ff:	a1 08 8f 22 f0       	mov    0xf0228f08,%eax
f0101104:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f010110b:	89 d8                	mov    %ebx,%eax
f010110d:	e8 b9 f9 ff ff       	call   f0100acb <boot_alloc>
f0101112:	a3 10 8f 22 f0       	mov    %eax,0xf0228f10
	memset(pages, 0, n);
f0101117:	83 ec 04             	sub    $0x4,%esp
f010111a:	53                   	push   %ebx
f010111b:	6a 00                	push   $0x0
f010111d:	50                   	push   %eax
f010111e:	e8 a9 31 00 00       	call   f01042cc <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	n = NENV * sizeof(struct Env);
	envs = (struct Env *) boot_alloc(n);
f0101123:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101128:	e8 9e f9 ff ff       	call   f0100acb <boot_alloc>
f010112d:	a3 48 82 22 f0       	mov    %eax,0xf0228248
	memset(envs, 0, n);
f0101132:	83 c4 0c             	add    $0xc,%esp
f0101135:	68 00 f0 01 00       	push   $0x1f000
f010113a:	6a 00                	push   $0x0
f010113c:	50                   	push   %eax
f010113d:	e8 8a 31 00 00       	call   f01042cc <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101142:	e8 72 fa ff ff       	call   f0100bb9 <page_init>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101147:	a1 40 82 22 f0       	mov    0xf0228240,%eax
f010114c:	83 c4 10             	add    $0x10,%esp
f010114f:	85 c0                	test   %eax,%eax
f0101151:	75 17                	jne    f010116a <mem_init+0x128>
		panic("'page_free_list' is a null pointer!");
f0101153:	83 ec 04             	sub    $0x4,%esp
f0101156:	68 00 59 10 f0       	push   $0xf0105900
f010115b:	68 3f 03 00 00       	push   $0x33f
f0101160:	68 5f 55 10 f0       	push   $0xf010555f
f0101165:	e8 d6 ee ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010116a:	8d 55 d8             	lea    -0x28(%ebp),%edx
f010116d:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101170:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101173:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101176:	89 c2                	mov    %eax,%edx
f0101178:	2b 15 10 8f 22 f0    	sub    0xf0228f10,%edx
f010117e:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0101184:	0f 95 c2             	setne  %dl
f0101187:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f010118a:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f010118e:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101190:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101194:	8b 00                	mov    (%eax),%eax
f0101196:	85 c0                	test   %eax,%eax
f0101198:	75 dc                	jne    f0101176 <mem_init+0x134>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f010119a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010119d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01011a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01011a9:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01011ab:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01011ae:	89 1d 40 82 22 f0    	mov    %ebx,0xf0228240
f01011b4:	eb 54                	jmp    f010120a <mem_init+0x1c8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011b6:	89 d8                	mov    %ebx,%eax
f01011b8:	2b 05 10 8f 22 f0    	sub    0xf0228f10,%eax
f01011be:	c1 f8 03             	sar    $0x3,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
f01011c1:	89 c2                	mov    %eax,%edx
f01011c3:	c1 e2 0c             	shl    $0xc,%edx
f01011c6:	a9 00 fc 0f 00       	test   $0xffc00,%eax
f01011cb:	75 3b                	jne    f0101208 <mem_init+0x1c6>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011cd:	89 d0                	mov    %edx,%eax
f01011cf:	c1 e8 0c             	shr    $0xc,%eax
f01011d2:	3b 05 08 8f 22 f0    	cmp    0xf0228f08,%eax
f01011d8:	72 12                	jb     f01011ec <mem_init+0x1aa>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011da:	52                   	push   %edx
f01011db:	68 a4 4f 10 f0       	push   $0xf0104fa4
f01011e0:	6a 58                	push   $0x58
f01011e2:	68 6b 55 10 f0       	push   $0xf010556b
f01011e7:	e8 54 ee ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01011ec:	83 ec 04             	sub    $0x4,%esp
f01011ef:	68 80 00 00 00       	push   $0x80
f01011f4:	68 97 00 00 00       	push   $0x97
f01011f9:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01011ff:	52                   	push   %edx
f0101200:	e8 c7 30 00 00       	call   f01042cc <memset>
f0101205:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101208:	8b 1b                	mov    (%ebx),%ebx
f010120a:	85 db                	test   %ebx,%ebx
f010120c:	75 a8                	jne    f01011b6 <mem_init+0x174>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f010120e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101213:	e8 b3 f8 ff ff       	call   f0100acb <boot_alloc>
f0101218:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010121b:	8b 15 40 82 22 f0    	mov    0xf0228240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101221:	8b 0d 10 8f 22 f0    	mov    0xf0228f10,%ecx
		assert(pp < pages + npages);
f0101227:	a1 08 8f 22 f0       	mov    0xf0228f08,%eax
f010122c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010122f:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101232:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101235:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f010123c:	e9 52 01 00 00       	jmp    f0101393 <mem_init+0x351>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101241:	39 d1                	cmp    %edx,%ecx
f0101243:	76 19                	jbe    f010125e <mem_init+0x21c>
f0101245:	68 79 55 10 f0       	push   $0xf0105579
f010124a:	68 85 55 10 f0       	push   $0xf0105585
f010124f:	68 59 03 00 00       	push   $0x359
f0101254:	68 5f 55 10 f0       	push   $0xf010555f
f0101259:	e8 e2 ed ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f010125e:	39 f2                	cmp    %esi,%edx
f0101260:	72 19                	jb     f010127b <mem_init+0x239>
f0101262:	68 9a 55 10 f0       	push   $0xf010559a
f0101267:	68 85 55 10 f0       	push   $0xf0105585
f010126c:	68 5a 03 00 00       	push   $0x35a
f0101271:	68 5f 55 10 f0       	push   $0xf010555f
f0101276:	e8 c5 ed ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010127b:	89 d0                	mov    %edx,%eax
f010127d:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0101280:	a8 07                	test   $0x7,%al
f0101282:	74 19                	je     f010129d <mem_init+0x25b>
f0101284:	68 24 59 10 f0       	push   $0xf0105924
f0101289:	68 85 55 10 f0       	push   $0xf0105585
f010128e:	68 5b 03 00 00       	push   $0x35b
f0101293:	68 5f 55 10 f0       	push   $0xf010555f
f0101298:	e8 a3 ed ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010129d:	c1 f8 03             	sar    $0x3,%eax
f01012a0:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01012a3:	85 c0                	test   %eax,%eax
f01012a5:	75 19                	jne    f01012c0 <mem_init+0x27e>
f01012a7:	68 ae 55 10 f0       	push   $0xf01055ae
f01012ac:	68 85 55 10 f0       	push   $0xf0105585
f01012b1:	68 5e 03 00 00       	push   $0x35e
f01012b6:	68 5f 55 10 f0       	push   $0xf010555f
f01012bb:	e8 80 ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01012c0:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01012c5:	75 19                	jne    f01012e0 <mem_init+0x29e>
f01012c7:	68 bf 55 10 f0       	push   $0xf01055bf
f01012cc:	68 85 55 10 f0       	push   $0xf0105585
f01012d1:	68 5f 03 00 00       	push   $0x35f
f01012d6:	68 5f 55 10 f0       	push   $0xf010555f
f01012db:	e8 60 ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01012e0:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01012e5:	75 19                	jne    f0101300 <mem_init+0x2be>
f01012e7:	68 58 59 10 f0       	push   $0xf0105958
f01012ec:	68 85 55 10 f0       	push   $0xf0105585
f01012f1:	68 60 03 00 00       	push   $0x360
f01012f6:	68 5f 55 10 f0       	push   $0xf010555f
f01012fb:	e8 40 ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101300:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101305:	75 19                	jne    f0101320 <mem_init+0x2de>
f0101307:	68 d8 55 10 f0       	push   $0xf01055d8
f010130c:	68 85 55 10 f0       	push   $0xf0105585
f0101311:	68 61 03 00 00       	push   $0x361
f0101316:	68 5f 55 10 f0       	push   $0xf010555f
f010131b:	e8 20 ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101320:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101325:	0f 86 77 0f 00 00    	jbe    f01022a2 <mem_init+0x1260>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010132b:	89 c7                	mov    %eax,%edi
f010132d:	c1 ef 0c             	shr    $0xc,%edi
f0101330:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0101333:	77 12                	ja     f0101347 <mem_init+0x305>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101335:	50                   	push   %eax
f0101336:	68 a4 4f 10 f0       	push   $0xf0104fa4
f010133b:	6a 58                	push   $0x58
f010133d:	68 6b 55 10 f0       	push   $0xf010556b
f0101342:	e8 f9 ec ff ff       	call   f0100040 <_panic>
f0101347:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f010134d:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0101350:	0f 86 5c 0f 00 00    	jbe    f01022b2 <mem_init+0x1270>
f0101356:	68 7c 59 10 f0       	push   $0xf010597c
f010135b:	68 85 55 10 f0       	push   $0xf0105585
f0101360:	68 62 03 00 00       	push   $0x362
f0101365:	68 5f 55 10 f0       	push   $0xf010555f
f010136a:	e8 d1 ec ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010136f:	68 f2 55 10 f0       	push   $0xf01055f2
f0101374:	68 85 55 10 f0       	push   $0xf0105585
f0101379:	68 64 03 00 00       	push   $0x364
f010137e:	68 5f 55 10 f0       	push   $0xf010555f
f0101383:	e8 b8 ec ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101388:	83 c3 01             	add    $0x1,%ebx
f010138b:	eb 04                	jmp    f0101391 <mem_init+0x34f>
		else
			++nfree_extmem;
f010138d:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101391:	8b 12                	mov    (%edx),%edx
f0101393:	85 d2                	test   %edx,%edx
f0101395:	0f 85 a6 fe ff ff    	jne    f0101241 <mem_init+0x1ff>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010139b:	85 db                	test   %ebx,%ebx
f010139d:	7f 19                	jg     f01013b8 <mem_init+0x376>
f010139f:	68 0f 56 10 f0       	push   $0xf010560f
f01013a4:	68 85 55 10 f0       	push   $0xf0105585
f01013a9:	68 6c 03 00 00       	push   $0x36c
f01013ae:	68 5f 55 10 f0       	push   $0xf010555f
f01013b3:	e8 88 ec ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f01013b8:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01013bc:	7f 19                	jg     f01013d7 <mem_init+0x395>
f01013be:	68 21 56 10 f0       	push   $0xf0105621
f01013c3:	68 85 55 10 f0       	push   $0xf0105585
f01013c8:	68 6d 03 00 00       	push   $0x36d
f01013cd:	68 5f 55 10 f0       	push   $0xf010555f
f01013d2:	e8 69 ec ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f01013d7:	83 ec 0c             	sub    $0xc,%esp
f01013da:	68 c4 59 10 f0       	push   $0xf01059c4
f01013df:	e8 f8 18 00 00       	call   f0102cdc <cprintf>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01013e4:	83 c4 10             	add    $0x10,%esp
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013e7:	a1 40 82 22 f0       	mov    0xf0228240,%eax
f01013ec:	bb 00 00 00 00       	mov    $0x0,%ebx
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01013f1:	83 3d 10 8f 22 f0 00 	cmpl   $0x0,0xf0228f10
f01013f8:	75 1c                	jne    f0101416 <mem_init+0x3d4>
		panic("'pages' is a null pointer!");
f01013fa:	83 ec 04             	sub    $0x4,%esp
f01013fd:	68 32 56 10 f0       	push   $0xf0105632
f0101402:	68 80 03 00 00       	push   $0x380
f0101407:	68 5f 55 10 f0       	push   $0xf010555f
f010140c:	e8 2f ec ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
		++nfree;
f0101411:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101414:	8b 00                	mov    (%eax),%eax
f0101416:	85 c0                	test   %eax,%eax
f0101418:	75 f7                	jne    f0101411 <mem_init+0x3cf>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010141a:	83 ec 0c             	sub    $0xc,%esp
f010141d:	6a 00                	push   $0x0
f010141f:	e8 11 f9 ff ff       	call   f0100d35 <page_alloc>
f0101424:	89 c7                	mov    %eax,%edi
f0101426:	83 c4 10             	add    $0x10,%esp
f0101429:	85 c0                	test   %eax,%eax
f010142b:	75 19                	jne    f0101446 <mem_init+0x404>
f010142d:	68 4d 56 10 f0       	push   $0xf010564d
f0101432:	68 85 55 10 f0       	push   $0xf0105585
f0101437:	68 88 03 00 00       	push   $0x388
f010143c:	68 5f 55 10 f0       	push   $0xf010555f
f0101441:	e8 fa eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101446:	83 ec 0c             	sub    $0xc,%esp
f0101449:	6a 00                	push   $0x0
f010144b:	e8 e5 f8 ff ff       	call   f0100d35 <page_alloc>
f0101450:	89 c6                	mov    %eax,%esi
f0101452:	83 c4 10             	add    $0x10,%esp
f0101455:	85 c0                	test   %eax,%eax
f0101457:	75 19                	jne    f0101472 <mem_init+0x430>
f0101459:	68 63 56 10 f0       	push   $0xf0105663
f010145e:	68 85 55 10 f0       	push   $0xf0105585
f0101463:	68 89 03 00 00       	push   $0x389
f0101468:	68 5f 55 10 f0       	push   $0xf010555f
f010146d:	e8 ce eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101472:	83 ec 0c             	sub    $0xc,%esp
f0101475:	6a 00                	push   $0x0
f0101477:	e8 b9 f8 ff ff       	call   f0100d35 <page_alloc>
f010147c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010147f:	83 c4 10             	add    $0x10,%esp
f0101482:	85 c0                	test   %eax,%eax
f0101484:	75 19                	jne    f010149f <mem_init+0x45d>
f0101486:	68 79 56 10 f0       	push   $0xf0105679
f010148b:	68 85 55 10 f0       	push   $0xf0105585
f0101490:	68 8a 03 00 00       	push   $0x38a
f0101495:	68 5f 55 10 f0       	push   $0xf010555f
f010149a:	e8 a1 eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010149f:	39 f7                	cmp    %esi,%edi
f01014a1:	75 19                	jne    f01014bc <mem_init+0x47a>
f01014a3:	68 8f 56 10 f0       	push   $0xf010568f
f01014a8:	68 85 55 10 f0       	push   $0xf0105585
f01014ad:	68 8d 03 00 00       	push   $0x38d
f01014b2:	68 5f 55 10 f0       	push   $0xf010555f
f01014b7:	e8 84 eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014bf:	39 c6                	cmp    %eax,%esi
f01014c1:	74 04                	je     f01014c7 <mem_init+0x485>
f01014c3:	39 c7                	cmp    %eax,%edi
f01014c5:	75 19                	jne    f01014e0 <mem_init+0x49e>
f01014c7:	68 e8 59 10 f0       	push   $0xf01059e8
f01014cc:	68 85 55 10 f0       	push   $0xf0105585
f01014d1:	68 8e 03 00 00       	push   $0x38e
f01014d6:	68 5f 55 10 f0       	push   $0xf010555f
f01014db:	e8 60 eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014e0:	8b 0d 10 8f 22 f0    	mov    0xf0228f10,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014e6:	8b 15 08 8f 22 f0    	mov    0xf0228f08,%edx
f01014ec:	c1 e2 0c             	shl    $0xc,%edx
f01014ef:	89 f8                	mov    %edi,%eax
f01014f1:	29 c8                	sub    %ecx,%eax
f01014f3:	c1 f8 03             	sar    $0x3,%eax
f01014f6:	c1 e0 0c             	shl    $0xc,%eax
f01014f9:	39 d0                	cmp    %edx,%eax
f01014fb:	72 19                	jb     f0101516 <mem_init+0x4d4>
f01014fd:	68 a1 56 10 f0       	push   $0xf01056a1
f0101502:	68 85 55 10 f0       	push   $0xf0105585
f0101507:	68 8f 03 00 00       	push   $0x38f
f010150c:	68 5f 55 10 f0       	push   $0xf010555f
f0101511:	e8 2a eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101516:	89 f0                	mov    %esi,%eax
f0101518:	29 c8                	sub    %ecx,%eax
f010151a:	c1 f8 03             	sar    $0x3,%eax
f010151d:	c1 e0 0c             	shl    $0xc,%eax
f0101520:	39 c2                	cmp    %eax,%edx
f0101522:	77 19                	ja     f010153d <mem_init+0x4fb>
f0101524:	68 be 56 10 f0       	push   $0xf01056be
f0101529:	68 85 55 10 f0       	push   $0xf0105585
f010152e:	68 90 03 00 00       	push   $0x390
f0101533:	68 5f 55 10 f0       	push   $0xf010555f
f0101538:	e8 03 eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010153d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101540:	29 c8                	sub    %ecx,%eax
f0101542:	c1 f8 03             	sar    $0x3,%eax
f0101545:	c1 e0 0c             	shl    $0xc,%eax
f0101548:	39 c2                	cmp    %eax,%edx
f010154a:	77 19                	ja     f0101565 <mem_init+0x523>
f010154c:	68 db 56 10 f0       	push   $0xf01056db
f0101551:	68 85 55 10 f0       	push   $0xf0105585
f0101556:	68 91 03 00 00       	push   $0x391
f010155b:	68 5f 55 10 f0       	push   $0xf010555f
f0101560:	e8 db ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101565:	a1 40 82 22 f0       	mov    0xf0228240,%eax
f010156a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010156d:	c7 05 40 82 22 f0 00 	movl   $0x0,0xf0228240
f0101574:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101577:	83 ec 0c             	sub    $0xc,%esp
f010157a:	6a 00                	push   $0x0
f010157c:	e8 b4 f7 ff ff       	call   f0100d35 <page_alloc>
f0101581:	83 c4 10             	add    $0x10,%esp
f0101584:	85 c0                	test   %eax,%eax
f0101586:	74 19                	je     f01015a1 <mem_init+0x55f>
f0101588:	68 f8 56 10 f0       	push   $0xf01056f8
f010158d:	68 85 55 10 f0       	push   $0xf0105585
f0101592:	68 98 03 00 00       	push   $0x398
f0101597:	68 5f 55 10 f0       	push   $0xf010555f
f010159c:	e8 9f ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01015a1:	83 ec 0c             	sub    $0xc,%esp
f01015a4:	57                   	push   %edi
f01015a5:	e8 fc f7 ff ff       	call   f0100da6 <page_free>
	page_free(pp1);
f01015aa:	89 34 24             	mov    %esi,(%esp)
f01015ad:	e8 f4 f7 ff ff       	call   f0100da6 <page_free>
	page_free(pp2);
f01015b2:	83 c4 04             	add    $0x4,%esp
f01015b5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015b8:	e8 e9 f7 ff ff       	call   f0100da6 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015c4:	e8 6c f7 ff ff       	call   f0100d35 <page_alloc>
f01015c9:	89 c6                	mov    %eax,%esi
f01015cb:	83 c4 10             	add    $0x10,%esp
f01015ce:	85 c0                	test   %eax,%eax
f01015d0:	75 19                	jne    f01015eb <mem_init+0x5a9>
f01015d2:	68 4d 56 10 f0       	push   $0xf010564d
f01015d7:	68 85 55 10 f0       	push   $0xf0105585
f01015dc:	68 9f 03 00 00       	push   $0x39f
f01015e1:	68 5f 55 10 f0       	push   $0xf010555f
f01015e6:	e8 55 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015eb:	83 ec 0c             	sub    $0xc,%esp
f01015ee:	6a 00                	push   $0x0
f01015f0:	e8 40 f7 ff ff       	call   f0100d35 <page_alloc>
f01015f5:	89 c7                	mov    %eax,%edi
f01015f7:	83 c4 10             	add    $0x10,%esp
f01015fa:	85 c0                	test   %eax,%eax
f01015fc:	75 19                	jne    f0101617 <mem_init+0x5d5>
f01015fe:	68 63 56 10 f0       	push   $0xf0105663
f0101603:	68 85 55 10 f0       	push   $0xf0105585
f0101608:	68 a0 03 00 00       	push   $0x3a0
f010160d:	68 5f 55 10 f0       	push   $0xf010555f
f0101612:	e8 29 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101617:	83 ec 0c             	sub    $0xc,%esp
f010161a:	6a 00                	push   $0x0
f010161c:	e8 14 f7 ff ff       	call   f0100d35 <page_alloc>
f0101621:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101624:	83 c4 10             	add    $0x10,%esp
f0101627:	85 c0                	test   %eax,%eax
f0101629:	75 19                	jne    f0101644 <mem_init+0x602>
f010162b:	68 79 56 10 f0       	push   $0xf0105679
f0101630:	68 85 55 10 f0       	push   $0xf0105585
f0101635:	68 a1 03 00 00       	push   $0x3a1
f010163a:	68 5f 55 10 f0       	push   $0xf010555f
f010163f:	e8 fc e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101644:	39 fe                	cmp    %edi,%esi
f0101646:	75 19                	jne    f0101661 <mem_init+0x61f>
f0101648:	68 8f 56 10 f0       	push   $0xf010568f
f010164d:	68 85 55 10 f0       	push   $0xf0105585
f0101652:	68 a3 03 00 00       	push   $0x3a3
f0101657:	68 5f 55 10 f0       	push   $0xf010555f
f010165c:	e8 df e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101661:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101664:	39 c7                	cmp    %eax,%edi
f0101666:	74 04                	je     f010166c <mem_init+0x62a>
f0101668:	39 c6                	cmp    %eax,%esi
f010166a:	75 19                	jne    f0101685 <mem_init+0x643>
f010166c:	68 e8 59 10 f0       	push   $0xf01059e8
f0101671:	68 85 55 10 f0       	push   $0xf0105585
f0101676:	68 a4 03 00 00       	push   $0x3a4
f010167b:	68 5f 55 10 f0       	push   $0xf010555f
f0101680:	e8 bb e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101685:	83 ec 0c             	sub    $0xc,%esp
f0101688:	6a 00                	push   $0x0
f010168a:	e8 a6 f6 ff ff       	call   f0100d35 <page_alloc>
f010168f:	83 c4 10             	add    $0x10,%esp
f0101692:	85 c0                	test   %eax,%eax
f0101694:	74 19                	je     f01016af <mem_init+0x66d>
f0101696:	68 f8 56 10 f0       	push   $0xf01056f8
f010169b:	68 85 55 10 f0       	push   $0xf0105585
f01016a0:	68 a5 03 00 00       	push   $0x3a5
f01016a5:	68 5f 55 10 f0       	push   $0xf010555f
f01016aa:	e8 91 e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01016af:	89 f0                	mov    %esi,%eax
f01016b1:	e8 68 f4 ff ff       	call   f0100b1e <page2kva>
f01016b6:	83 ec 04             	sub    $0x4,%esp
f01016b9:	68 00 10 00 00       	push   $0x1000
f01016be:	6a 01                	push   $0x1
f01016c0:	50                   	push   %eax
f01016c1:	e8 06 2c 00 00       	call   f01042cc <memset>
	page_free(pp0);
f01016c6:	89 34 24             	mov    %esi,(%esp)
f01016c9:	e8 d8 f6 ff ff       	call   f0100da6 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01016d5:	e8 5b f6 ff ff       	call   f0100d35 <page_alloc>
f01016da:	83 c4 10             	add    $0x10,%esp
f01016dd:	85 c0                	test   %eax,%eax
f01016df:	75 19                	jne    f01016fa <mem_init+0x6b8>
f01016e1:	68 07 57 10 f0       	push   $0xf0105707
f01016e6:	68 85 55 10 f0       	push   $0xf0105585
f01016eb:	68 aa 03 00 00       	push   $0x3aa
f01016f0:	68 5f 55 10 f0       	push   $0xf010555f
f01016f5:	e8 46 e9 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01016fa:	39 c6                	cmp    %eax,%esi
f01016fc:	74 19                	je     f0101717 <mem_init+0x6d5>
f01016fe:	68 25 57 10 f0       	push   $0xf0105725
f0101703:	68 85 55 10 f0       	push   $0xf0105585
f0101708:	68 ab 03 00 00       	push   $0x3ab
f010170d:	68 5f 55 10 f0       	push   $0xf010555f
f0101712:	e8 29 e9 ff ff       	call   f0100040 <_panic>
	c = page2kva(pp);
f0101717:	89 f0                	mov    %esi,%eax
f0101719:	e8 00 f4 ff ff       	call   f0100b1e <page2kva>
f010171e:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
	for (i = 0; i < PGSIZE; i++) {
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
f0101724:	80 38 00             	cmpb   $0x0,(%eax)
f0101727:	74 19                	je     f0101742 <mem_init+0x700>
f0101729:	68 35 57 10 f0       	push   $0xf0105735
f010172e:	68 85 55 10 f0       	push   $0xf0105585
f0101733:	68 af 03 00 00       	push   $0x3af
f0101738:	68 5f 55 10 f0       	push   $0xf010555f
f010173d:	e8 fe e8 ff ff       	call   f0100040 <_panic>
f0101742:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
f0101745:	39 d0                	cmp    %edx,%eax
f0101747:	75 db                	jne    f0101724 <mem_init+0x6e2>
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
	}

	// give free list back
	page_free_list = fl;
f0101749:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010174c:	a3 40 82 22 f0       	mov    %eax,0xf0228240

	// free the pages we took
	page_free(pp0);
f0101751:	83 ec 0c             	sub    $0xc,%esp
f0101754:	56                   	push   %esi
f0101755:	e8 4c f6 ff ff       	call   f0100da6 <page_free>
	page_free(pp1);
f010175a:	89 3c 24             	mov    %edi,(%esp)
f010175d:	e8 44 f6 ff ff       	call   f0100da6 <page_free>
	page_free(pp2);
f0101762:	83 c4 04             	add    $0x4,%esp
f0101765:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101768:	e8 39 f6 ff ff       	call   f0100da6 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010176d:	a1 40 82 22 f0       	mov    0xf0228240,%eax
f0101772:	83 c4 10             	add    $0x10,%esp
f0101775:	eb 05                	jmp    f010177c <mem_init+0x73a>
		--nfree;
f0101777:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010177a:	8b 00                	mov    (%eax),%eax
f010177c:	85 c0                	test   %eax,%eax
f010177e:	75 f7                	jne    f0101777 <mem_init+0x735>
		--nfree;
	assert(nfree == 0);
f0101780:	85 db                	test   %ebx,%ebx
f0101782:	74 19                	je     f010179d <mem_init+0x75b>
f0101784:	68 3f 57 10 f0       	push   $0xf010573f
f0101789:	68 85 55 10 f0       	push   $0xf0105585
f010178e:	68 bd 03 00 00       	push   $0x3bd
f0101793:	68 5f 55 10 f0       	push   $0xf010555f
f0101798:	e8 a3 e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010179d:	83 ec 0c             	sub    $0xc,%esp
f01017a0:	68 08 5a 10 f0       	push   $0xf0105a08
f01017a5:	e8 32 15 00 00       	call   f0102cdc <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017b1:	e8 7f f5 ff ff       	call   f0100d35 <page_alloc>
f01017b6:	89 c3                	mov    %eax,%ebx
f01017b8:	83 c4 10             	add    $0x10,%esp
f01017bb:	85 c0                	test   %eax,%eax
f01017bd:	75 19                	jne    f01017d8 <mem_init+0x796>
f01017bf:	68 4d 56 10 f0       	push   $0xf010564d
f01017c4:	68 85 55 10 f0       	push   $0xf0105585
f01017c9:	68 27 04 00 00       	push   $0x427
f01017ce:	68 5f 55 10 f0       	push   $0xf010555f
f01017d3:	e8 68 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017d8:	83 ec 0c             	sub    $0xc,%esp
f01017db:	6a 00                	push   $0x0
f01017dd:	e8 53 f5 ff ff       	call   f0100d35 <page_alloc>
f01017e2:	89 c6                	mov    %eax,%esi
f01017e4:	83 c4 10             	add    $0x10,%esp
f01017e7:	85 c0                	test   %eax,%eax
f01017e9:	75 19                	jne    f0101804 <mem_init+0x7c2>
f01017eb:	68 63 56 10 f0       	push   $0xf0105663
f01017f0:	68 85 55 10 f0       	push   $0xf0105585
f01017f5:	68 28 04 00 00       	push   $0x428
f01017fa:	68 5f 55 10 f0       	push   $0xf010555f
f01017ff:	e8 3c e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101804:	83 ec 0c             	sub    $0xc,%esp
f0101807:	6a 00                	push   $0x0
f0101809:	e8 27 f5 ff ff       	call   f0100d35 <page_alloc>
f010180e:	89 c7                	mov    %eax,%edi
f0101810:	83 c4 10             	add    $0x10,%esp
f0101813:	85 c0                	test   %eax,%eax
f0101815:	75 19                	jne    f0101830 <mem_init+0x7ee>
f0101817:	68 79 56 10 f0       	push   $0xf0105679
f010181c:	68 85 55 10 f0       	push   $0xf0105585
f0101821:	68 29 04 00 00       	push   $0x429
f0101826:	68 5f 55 10 f0       	push   $0xf010555f
f010182b:	e8 10 e8 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101830:	39 f3                	cmp    %esi,%ebx
f0101832:	75 19                	jne    f010184d <mem_init+0x80b>
f0101834:	68 8f 56 10 f0       	push   $0xf010568f
f0101839:	68 85 55 10 f0       	push   $0xf0105585
f010183e:	68 2c 04 00 00       	push   $0x42c
f0101843:	68 5f 55 10 f0       	push   $0xf010555f
f0101848:	e8 f3 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010184d:	39 c6                	cmp    %eax,%esi
f010184f:	74 04                	je     f0101855 <mem_init+0x813>
f0101851:	39 c3                	cmp    %eax,%ebx
f0101853:	75 19                	jne    f010186e <mem_init+0x82c>
f0101855:	68 e8 59 10 f0       	push   $0xf01059e8
f010185a:	68 85 55 10 f0       	push   $0xf0105585
f010185f:	68 2d 04 00 00       	push   $0x42d
f0101864:	68 5f 55 10 f0       	push   $0xf010555f
f0101869:	e8 d2 e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010186e:	a1 40 82 22 f0       	mov    0xf0228240,%eax
f0101873:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	page_free_list = 0;
f0101876:	c7 05 40 82 22 f0 00 	movl   $0x0,0xf0228240
f010187d:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101880:	83 ec 0c             	sub    $0xc,%esp
f0101883:	6a 00                	push   $0x0
f0101885:	e8 ab f4 ff ff       	call   f0100d35 <page_alloc>
f010188a:	83 c4 10             	add    $0x10,%esp
f010188d:	85 c0                	test   %eax,%eax
f010188f:	74 19                	je     f01018aa <mem_init+0x868>
f0101891:	68 f8 56 10 f0       	push   $0xf01056f8
f0101896:	68 85 55 10 f0       	push   $0xf0105585
f010189b:	68 34 04 00 00       	push   $0x434
f01018a0:	68 5f 55 10 f0       	push   $0xf010555f
f01018a5:	e8 96 e7 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018aa:	83 ec 04             	sub    $0x4,%esp
f01018ad:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01018b0:	50                   	push   %eax
f01018b1:	6a 00                	push   $0x0
f01018b3:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f01018b9:	e8 fb f5 ff ff       	call   f0100eb9 <page_lookup>
f01018be:	83 c4 10             	add    $0x10,%esp
f01018c1:	85 c0                	test   %eax,%eax
f01018c3:	74 19                	je     f01018de <mem_init+0x89c>
f01018c5:	68 28 5a 10 f0       	push   $0xf0105a28
f01018ca:	68 85 55 10 f0       	push   $0xf0105585
f01018cf:	68 37 04 00 00       	push   $0x437
f01018d4:	68 5f 55 10 f0       	push   $0xf010555f
f01018d9:	e8 62 e7 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018de:	6a 02                	push   $0x2
f01018e0:	6a 00                	push   $0x0
f01018e2:	56                   	push   %esi
f01018e3:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f01018e9:	e8 b3 f6 ff ff       	call   f0100fa1 <page_insert>
f01018ee:	83 c4 10             	add    $0x10,%esp
f01018f1:	85 c0                	test   %eax,%eax
f01018f3:	78 19                	js     f010190e <mem_init+0x8cc>
f01018f5:	68 60 5a 10 f0       	push   $0xf0105a60
f01018fa:	68 85 55 10 f0       	push   $0xf0105585
f01018ff:	68 3a 04 00 00       	push   $0x43a
f0101904:	68 5f 55 10 f0       	push   $0xf010555f
f0101909:	e8 32 e7 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010190e:	83 ec 0c             	sub    $0xc,%esp
f0101911:	53                   	push   %ebx
f0101912:	e8 8f f4 ff ff       	call   f0100da6 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101917:	6a 02                	push   $0x2
f0101919:	6a 00                	push   $0x0
f010191b:	56                   	push   %esi
f010191c:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f0101922:	e8 7a f6 ff ff       	call   f0100fa1 <page_insert>
f0101927:	83 c4 20             	add    $0x20,%esp
f010192a:	85 c0                	test   %eax,%eax
f010192c:	74 19                	je     f0101947 <mem_init+0x905>
f010192e:	68 90 5a 10 f0       	push   $0xf0105a90
f0101933:	68 85 55 10 f0       	push   $0xf0105585
f0101938:	68 3e 04 00 00       	push   $0x43e
f010193d:	68 5f 55 10 f0       	push   $0xf010555f
f0101942:	e8 f9 e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101947:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
f010194c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010194f:	8b 0d 10 8f 22 f0    	mov    0xf0228f10,%ecx
f0101955:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101958:	8b 00                	mov    (%eax),%eax
f010195a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010195d:	89 c2                	mov    %eax,%edx
f010195f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101965:	89 d8                	mov    %ebx,%eax
f0101967:	29 c8                	sub    %ecx,%eax
f0101969:	c1 f8 03             	sar    $0x3,%eax
f010196c:	c1 e0 0c             	shl    $0xc,%eax
f010196f:	39 c2                	cmp    %eax,%edx
f0101971:	74 19                	je     f010198c <mem_init+0x94a>
f0101973:	68 c0 5a 10 f0       	push   $0xf0105ac0
f0101978:	68 85 55 10 f0       	push   $0xf0105585
f010197d:	68 3f 04 00 00       	push   $0x43f
f0101982:	68 5f 55 10 f0       	push   $0xf010555f
f0101987:	e8 b4 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010198c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101991:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101994:	e8 bc f1 ff ff       	call   f0100b55 <check_va2pa>
f0101999:	89 f2                	mov    %esi,%edx
f010199b:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010199e:	c1 fa 03             	sar    $0x3,%edx
f01019a1:	c1 e2 0c             	shl    $0xc,%edx
f01019a4:	39 d0                	cmp    %edx,%eax
f01019a6:	74 19                	je     f01019c1 <mem_init+0x97f>
f01019a8:	68 e8 5a 10 f0       	push   $0xf0105ae8
f01019ad:	68 85 55 10 f0       	push   $0xf0105585
f01019b2:	68 40 04 00 00       	push   $0x440
f01019b7:	68 5f 55 10 f0       	push   $0xf010555f
f01019bc:	e8 7f e6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01019c1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019c6:	74 19                	je     f01019e1 <mem_init+0x99f>
f01019c8:	68 4a 57 10 f0       	push   $0xf010574a
f01019cd:	68 85 55 10 f0       	push   $0xf0105585
f01019d2:	68 41 04 00 00       	push   $0x441
f01019d7:	68 5f 55 10 f0       	push   $0xf010555f
f01019dc:	e8 5f e6 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01019e1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019e6:	74 19                	je     f0101a01 <mem_init+0x9bf>
f01019e8:	68 5b 57 10 f0       	push   $0xf010575b
f01019ed:	68 85 55 10 f0       	push   $0xf0105585
f01019f2:	68 42 04 00 00       	push   $0x442
f01019f7:	68 5f 55 10 f0       	push   $0xf010555f
f01019fc:	e8 3f e6 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a01:	6a 02                	push   $0x2
f0101a03:	68 00 10 00 00       	push   $0x1000
f0101a08:	57                   	push   %edi
f0101a09:	ff 75 d0             	pushl  -0x30(%ebp)
f0101a0c:	e8 90 f5 ff ff       	call   f0100fa1 <page_insert>
f0101a11:	83 c4 10             	add    $0x10,%esp
f0101a14:	85 c0                	test   %eax,%eax
f0101a16:	74 19                	je     f0101a31 <mem_init+0x9ef>
f0101a18:	68 18 5b 10 f0       	push   $0xf0105b18
f0101a1d:	68 85 55 10 f0       	push   $0xf0105585
f0101a22:	68 45 04 00 00       	push   $0x445
f0101a27:	68 5f 55 10 f0       	push   $0xf010555f
f0101a2c:	e8 0f e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a31:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a36:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
f0101a3b:	e8 15 f1 ff ff       	call   f0100b55 <check_va2pa>
f0101a40:	89 fa                	mov    %edi,%edx
f0101a42:	2b 15 10 8f 22 f0    	sub    0xf0228f10,%edx
f0101a48:	c1 fa 03             	sar    $0x3,%edx
f0101a4b:	c1 e2 0c             	shl    $0xc,%edx
f0101a4e:	39 d0                	cmp    %edx,%eax
f0101a50:	74 19                	je     f0101a6b <mem_init+0xa29>
f0101a52:	68 54 5b 10 f0       	push   $0xf0105b54
f0101a57:	68 85 55 10 f0       	push   $0xf0105585
f0101a5c:	68 46 04 00 00       	push   $0x446
f0101a61:	68 5f 55 10 f0       	push   $0xf010555f
f0101a66:	e8 d5 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101a6b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a70:	74 19                	je     f0101a8b <mem_init+0xa49>
f0101a72:	68 6c 57 10 f0       	push   $0xf010576c
f0101a77:	68 85 55 10 f0       	push   $0xf0105585
f0101a7c:	68 47 04 00 00       	push   $0x447
f0101a81:	68 5f 55 10 f0       	push   $0xf010555f
f0101a86:	e8 b5 e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101a8b:	83 ec 0c             	sub    $0xc,%esp
f0101a8e:	6a 00                	push   $0x0
f0101a90:	e8 a0 f2 ff ff       	call   f0100d35 <page_alloc>
f0101a95:	83 c4 10             	add    $0x10,%esp
f0101a98:	85 c0                	test   %eax,%eax
f0101a9a:	74 19                	je     f0101ab5 <mem_init+0xa73>
f0101a9c:	68 f8 56 10 f0       	push   $0xf01056f8
f0101aa1:	68 85 55 10 f0       	push   $0xf0105585
f0101aa6:	68 4a 04 00 00       	push   $0x44a
f0101aab:	68 5f 55 10 f0       	push   $0xf010555f
f0101ab0:	e8 8b e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ab5:	6a 02                	push   $0x2
f0101ab7:	68 00 10 00 00       	push   $0x1000
f0101abc:	57                   	push   %edi
f0101abd:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f0101ac3:	e8 d9 f4 ff ff       	call   f0100fa1 <page_insert>
f0101ac8:	83 c4 10             	add    $0x10,%esp
f0101acb:	85 c0                	test   %eax,%eax
f0101acd:	74 19                	je     f0101ae8 <mem_init+0xaa6>
f0101acf:	68 18 5b 10 f0       	push   $0xf0105b18
f0101ad4:	68 85 55 10 f0       	push   $0xf0105585
f0101ad9:	68 4d 04 00 00       	push   $0x44d
f0101ade:	68 5f 55 10 f0       	push   $0xf010555f
f0101ae3:	e8 58 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ae8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aed:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
f0101af2:	e8 5e f0 ff ff       	call   f0100b55 <check_va2pa>
f0101af7:	89 fa                	mov    %edi,%edx
f0101af9:	2b 15 10 8f 22 f0    	sub    0xf0228f10,%edx
f0101aff:	c1 fa 03             	sar    $0x3,%edx
f0101b02:	c1 e2 0c             	shl    $0xc,%edx
f0101b05:	39 d0                	cmp    %edx,%eax
f0101b07:	74 19                	je     f0101b22 <mem_init+0xae0>
f0101b09:	68 54 5b 10 f0       	push   $0xf0105b54
f0101b0e:	68 85 55 10 f0       	push   $0xf0105585
f0101b13:	68 4e 04 00 00       	push   $0x44e
f0101b18:	68 5f 55 10 f0       	push   $0xf010555f
f0101b1d:	e8 1e e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b22:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b27:	74 19                	je     f0101b42 <mem_init+0xb00>
f0101b29:	68 6c 57 10 f0       	push   $0xf010576c
f0101b2e:	68 85 55 10 f0       	push   $0xf0105585
f0101b33:	68 4f 04 00 00       	push   $0x44f
f0101b38:	68 5f 55 10 f0       	push   $0xf010555f
f0101b3d:	e8 fe e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b42:	83 ec 0c             	sub    $0xc,%esp
f0101b45:	6a 00                	push   $0x0
f0101b47:	e8 e9 f1 ff ff       	call   f0100d35 <page_alloc>
f0101b4c:	83 c4 10             	add    $0x10,%esp
f0101b4f:	85 c0                	test   %eax,%eax
f0101b51:	74 19                	je     f0101b6c <mem_init+0xb2a>
f0101b53:	68 f8 56 10 f0       	push   $0xf01056f8
f0101b58:	68 85 55 10 f0       	push   $0xf0105585
f0101b5d:	68 53 04 00 00       	push   $0x453
f0101b62:	68 5f 55 10 f0       	push   $0xf010555f
f0101b67:	e8 d4 e4 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b6c:	8b 15 0c 8f 22 f0    	mov    0xf0228f0c,%edx
f0101b72:	8b 02                	mov    (%edx),%eax
f0101b74:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b79:	89 c1                	mov    %eax,%ecx
f0101b7b:	c1 e9 0c             	shr    $0xc,%ecx
f0101b7e:	3b 0d 08 8f 22 f0    	cmp    0xf0228f08,%ecx
f0101b84:	72 15                	jb     f0101b9b <mem_init+0xb59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b86:	50                   	push   %eax
f0101b87:	68 a4 4f 10 f0       	push   $0xf0104fa4
f0101b8c:	68 56 04 00 00       	push   $0x456
f0101b91:	68 5f 55 10 f0       	push   $0xf010555f
f0101b96:	e8 a5 e4 ff ff       	call   f0100040 <_panic>
f0101b9b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ba0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ba3:	83 ec 04             	sub    $0x4,%esp
f0101ba6:	6a 00                	push   $0x0
f0101ba8:	68 00 10 00 00       	push   $0x1000
f0101bad:	52                   	push   %edx
f0101bae:	e8 70 f2 ff ff       	call   f0100e23 <pgdir_walk>
f0101bb3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101bb6:	8d 51 04             	lea    0x4(%ecx),%edx
f0101bb9:	83 c4 10             	add    $0x10,%esp
f0101bbc:	39 d0                	cmp    %edx,%eax
f0101bbe:	74 19                	je     f0101bd9 <mem_init+0xb97>
f0101bc0:	68 84 5b 10 f0       	push   $0xf0105b84
f0101bc5:	68 85 55 10 f0       	push   $0xf0105585
f0101bca:	68 57 04 00 00       	push   $0x457
f0101bcf:	68 5f 55 10 f0       	push   $0xf010555f
f0101bd4:	e8 67 e4 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101bd9:	6a 06                	push   $0x6
f0101bdb:	68 00 10 00 00       	push   $0x1000
f0101be0:	57                   	push   %edi
f0101be1:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f0101be7:	e8 b5 f3 ff ff       	call   f0100fa1 <page_insert>
f0101bec:	83 c4 10             	add    $0x10,%esp
f0101bef:	85 c0                	test   %eax,%eax
f0101bf1:	74 19                	je     f0101c0c <mem_init+0xbca>
f0101bf3:	68 c4 5b 10 f0       	push   $0xf0105bc4
f0101bf8:	68 85 55 10 f0       	push   $0xf0105585
f0101bfd:	68 5a 04 00 00       	push   $0x45a
f0101c02:	68 5f 55 10 f0       	push   $0xf010555f
f0101c07:	e8 34 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c0c:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
f0101c11:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c14:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c19:	e8 37 ef ff ff       	call   f0100b55 <check_va2pa>
f0101c1e:	89 fa                	mov    %edi,%edx
f0101c20:	2b 15 10 8f 22 f0    	sub    0xf0228f10,%edx
f0101c26:	c1 fa 03             	sar    $0x3,%edx
f0101c29:	c1 e2 0c             	shl    $0xc,%edx
f0101c2c:	39 d0                	cmp    %edx,%eax
f0101c2e:	74 19                	je     f0101c49 <mem_init+0xc07>
f0101c30:	68 54 5b 10 f0       	push   $0xf0105b54
f0101c35:	68 85 55 10 f0       	push   $0xf0105585
f0101c3a:	68 5b 04 00 00       	push   $0x45b
f0101c3f:	68 5f 55 10 f0       	push   $0xf010555f
f0101c44:	e8 f7 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c49:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c4e:	74 19                	je     f0101c69 <mem_init+0xc27>
f0101c50:	68 6c 57 10 f0       	push   $0xf010576c
f0101c55:	68 85 55 10 f0       	push   $0xf0105585
f0101c5a:	68 5c 04 00 00       	push   $0x45c
f0101c5f:	68 5f 55 10 f0       	push   $0xf010555f
f0101c64:	e8 d7 e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101c69:	83 ec 04             	sub    $0x4,%esp
f0101c6c:	6a 00                	push   $0x0
f0101c6e:	68 00 10 00 00       	push   $0x1000
f0101c73:	ff 75 d0             	pushl  -0x30(%ebp)
f0101c76:	e8 a8 f1 ff ff       	call   f0100e23 <pgdir_walk>
f0101c7b:	83 c4 10             	add    $0x10,%esp
f0101c7e:	f6 00 04             	testb  $0x4,(%eax)
f0101c81:	75 19                	jne    f0101c9c <mem_init+0xc5a>
f0101c83:	68 04 5c 10 f0       	push   $0xf0105c04
f0101c88:	68 85 55 10 f0       	push   $0xf0105585
f0101c8d:	68 5d 04 00 00       	push   $0x45d
f0101c92:	68 5f 55 10 f0       	push   $0xf010555f
f0101c97:	e8 a4 e3 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101c9c:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
f0101ca1:	f6 00 04             	testb  $0x4,(%eax)
f0101ca4:	75 19                	jne    f0101cbf <mem_init+0xc7d>
f0101ca6:	68 7d 57 10 f0       	push   $0xf010577d
f0101cab:	68 85 55 10 f0       	push   $0xf0105585
f0101cb0:	68 5e 04 00 00       	push   $0x45e
f0101cb5:	68 5f 55 10 f0       	push   $0xf010555f
f0101cba:	e8 81 e3 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cbf:	6a 02                	push   $0x2
f0101cc1:	68 00 10 00 00       	push   $0x1000
f0101cc6:	57                   	push   %edi
f0101cc7:	50                   	push   %eax
f0101cc8:	e8 d4 f2 ff ff       	call   f0100fa1 <page_insert>
f0101ccd:	83 c4 10             	add    $0x10,%esp
f0101cd0:	85 c0                	test   %eax,%eax
f0101cd2:	74 19                	je     f0101ced <mem_init+0xcab>
f0101cd4:	68 18 5b 10 f0       	push   $0xf0105b18
f0101cd9:	68 85 55 10 f0       	push   $0xf0105585
f0101cde:	68 61 04 00 00       	push   $0x461
f0101ce3:	68 5f 55 10 f0       	push   $0xf010555f
f0101ce8:	e8 53 e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ced:	83 ec 04             	sub    $0x4,%esp
f0101cf0:	6a 00                	push   $0x0
f0101cf2:	68 00 10 00 00       	push   $0x1000
f0101cf7:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f0101cfd:	e8 21 f1 ff ff       	call   f0100e23 <pgdir_walk>
f0101d02:	83 c4 10             	add    $0x10,%esp
f0101d05:	f6 00 02             	testb  $0x2,(%eax)
f0101d08:	75 19                	jne    f0101d23 <mem_init+0xce1>
f0101d0a:	68 38 5c 10 f0       	push   $0xf0105c38
f0101d0f:	68 85 55 10 f0       	push   $0xf0105585
f0101d14:	68 62 04 00 00       	push   $0x462
f0101d19:	68 5f 55 10 f0       	push   $0xf010555f
f0101d1e:	e8 1d e3 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d23:	83 ec 04             	sub    $0x4,%esp
f0101d26:	6a 00                	push   $0x0
f0101d28:	68 00 10 00 00       	push   $0x1000
f0101d2d:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f0101d33:	e8 eb f0 ff ff       	call   f0100e23 <pgdir_walk>
f0101d38:	83 c4 10             	add    $0x10,%esp
f0101d3b:	f6 00 04             	testb  $0x4,(%eax)
f0101d3e:	74 19                	je     f0101d59 <mem_init+0xd17>
f0101d40:	68 6c 5c 10 f0       	push   $0xf0105c6c
f0101d45:	68 85 55 10 f0       	push   $0xf0105585
f0101d4a:	68 63 04 00 00       	push   $0x463
f0101d4f:	68 5f 55 10 f0       	push   $0xf010555f
f0101d54:	e8 e7 e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101d59:	6a 02                	push   $0x2
f0101d5b:	68 00 00 40 00       	push   $0x400000
f0101d60:	53                   	push   %ebx
f0101d61:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f0101d67:	e8 35 f2 ff ff       	call   f0100fa1 <page_insert>
f0101d6c:	83 c4 10             	add    $0x10,%esp
f0101d6f:	85 c0                	test   %eax,%eax
f0101d71:	78 19                	js     f0101d8c <mem_init+0xd4a>
f0101d73:	68 a4 5c 10 f0       	push   $0xf0105ca4
f0101d78:	68 85 55 10 f0       	push   $0xf0105585
f0101d7d:	68 66 04 00 00       	push   $0x466
f0101d82:	68 5f 55 10 f0       	push   $0xf010555f
f0101d87:	e8 b4 e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101d8c:	6a 02                	push   $0x2
f0101d8e:	68 00 10 00 00       	push   $0x1000
f0101d93:	56                   	push   %esi
f0101d94:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f0101d9a:	e8 02 f2 ff ff       	call   f0100fa1 <page_insert>
f0101d9f:	83 c4 10             	add    $0x10,%esp
f0101da2:	85 c0                	test   %eax,%eax
f0101da4:	74 19                	je     f0101dbf <mem_init+0xd7d>
f0101da6:	68 dc 5c 10 f0       	push   $0xf0105cdc
f0101dab:	68 85 55 10 f0       	push   $0xf0105585
f0101db0:	68 69 04 00 00       	push   $0x469
f0101db5:	68 5f 55 10 f0       	push   $0xf010555f
f0101dba:	e8 81 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101dbf:	83 ec 04             	sub    $0x4,%esp
f0101dc2:	6a 00                	push   $0x0
f0101dc4:	68 00 10 00 00       	push   $0x1000
f0101dc9:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f0101dcf:	e8 4f f0 ff ff       	call   f0100e23 <pgdir_walk>
f0101dd4:	83 c4 10             	add    $0x10,%esp
f0101dd7:	f6 00 04             	testb  $0x4,(%eax)
f0101dda:	74 19                	je     f0101df5 <mem_init+0xdb3>
f0101ddc:	68 6c 5c 10 f0       	push   $0xf0105c6c
f0101de1:	68 85 55 10 f0       	push   $0xf0105585
f0101de6:	68 6a 04 00 00       	push   $0x46a
f0101deb:	68 5f 55 10 f0       	push   $0xf010555f
f0101df0:	e8 4b e2 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101df5:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
f0101dfa:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101dfd:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e02:	e8 4e ed ff ff       	call   f0100b55 <check_va2pa>
f0101e07:	89 c1                	mov    %eax,%ecx
f0101e09:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e0c:	89 f0                	mov    %esi,%eax
f0101e0e:	2b 05 10 8f 22 f0    	sub    0xf0228f10,%eax
f0101e14:	c1 f8 03             	sar    $0x3,%eax
f0101e17:	c1 e0 0c             	shl    $0xc,%eax
f0101e1a:	39 c1                	cmp    %eax,%ecx
f0101e1c:	74 19                	je     f0101e37 <mem_init+0xdf5>
f0101e1e:	68 18 5d 10 f0       	push   $0xf0105d18
f0101e23:	68 85 55 10 f0       	push   $0xf0105585
f0101e28:	68 6d 04 00 00       	push   $0x46d
f0101e2d:	68 5f 55 10 f0       	push   $0xf010555f
f0101e32:	e8 09 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e37:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e3c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e3f:	e8 11 ed ff ff       	call   f0100b55 <check_va2pa>
f0101e44:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101e47:	74 19                	je     f0101e62 <mem_init+0xe20>
f0101e49:	68 44 5d 10 f0       	push   $0xf0105d44
f0101e4e:	68 85 55 10 f0       	push   $0xf0105585
f0101e53:	68 6e 04 00 00       	push   $0x46e
f0101e58:	68 5f 55 10 f0       	push   $0xf010555f
f0101e5d:	e8 de e1 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e62:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0101e67:	74 19                	je     f0101e82 <mem_init+0xe40>
f0101e69:	68 93 57 10 f0       	push   $0xf0105793
f0101e6e:	68 85 55 10 f0       	push   $0xf0105585
f0101e73:	68 70 04 00 00       	push   $0x470
f0101e78:	68 5f 55 10 f0       	push   $0xf010555f
f0101e7d:	e8 be e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101e82:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101e87:	74 19                	je     f0101ea2 <mem_init+0xe60>
f0101e89:	68 a4 57 10 f0       	push   $0xf01057a4
f0101e8e:	68 85 55 10 f0       	push   $0xf0105585
f0101e93:	68 71 04 00 00       	push   $0x471
f0101e98:	68 5f 55 10 f0       	push   $0xf010555f
f0101e9d:	e8 9e e1 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ea2:	83 ec 0c             	sub    $0xc,%esp
f0101ea5:	6a 00                	push   $0x0
f0101ea7:	e8 89 ee ff ff       	call   f0100d35 <page_alloc>
f0101eac:	83 c4 10             	add    $0x10,%esp
f0101eaf:	39 c7                	cmp    %eax,%edi
f0101eb1:	75 04                	jne    f0101eb7 <mem_init+0xe75>
f0101eb3:	85 c0                	test   %eax,%eax
f0101eb5:	75 19                	jne    f0101ed0 <mem_init+0xe8e>
f0101eb7:	68 74 5d 10 f0       	push   $0xf0105d74
f0101ebc:	68 85 55 10 f0       	push   $0xf0105585
f0101ec1:	68 74 04 00 00       	push   $0x474
f0101ec6:	68 5f 55 10 f0       	push   $0xf010555f
f0101ecb:	e8 70 e1 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ed0:	83 ec 08             	sub    $0x8,%esp
f0101ed3:	6a 00                	push   $0x0
f0101ed5:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f0101edb:	e8 74 f0 ff ff       	call   f0100f54 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ee0:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
f0101ee5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ee8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eed:	e8 63 ec ff ff       	call   f0100b55 <check_va2pa>
f0101ef2:	83 c4 10             	add    $0x10,%esp
f0101ef5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ef8:	74 19                	je     f0101f13 <mem_init+0xed1>
f0101efa:	68 98 5d 10 f0       	push   $0xf0105d98
f0101eff:	68 85 55 10 f0       	push   $0xf0105585
f0101f04:	68 78 04 00 00       	push   $0x478
f0101f09:	68 5f 55 10 f0       	push   $0xf010555f
f0101f0e:	e8 2d e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f13:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f18:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f1b:	e8 35 ec ff ff       	call   f0100b55 <check_va2pa>
f0101f20:	89 f2                	mov    %esi,%edx
f0101f22:	2b 15 10 8f 22 f0    	sub    0xf0228f10,%edx
f0101f28:	c1 fa 03             	sar    $0x3,%edx
f0101f2b:	c1 e2 0c             	shl    $0xc,%edx
f0101f2e:	39 d0                	cmp    %edx,%eax
f0101f30:	74 19                	je     f0101f4b <mem_init+0xf09>
f0101f32:	68 44 5d 10 f0       	push   $0xf0105d44
f0101f37:	68 85 55 10 f0       	push   $0xf0105585
f0101f3c:	68 79 04 00 00       	push   $0x479
f0101f41:	68 5f 55 10 f0       	push   $0xf010555f
f0101f46:	e8 f5 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101f4b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f50:	74 19                	je     f0101f6b <mem_init+0xf29>
f0101f52:	68 4a 57 10 f0       	push   $0xf010574a
f0101f57:	68 85 55 10 f0       	push   $0xf0105585
f0101f5c:	68 7a 04 00 00       	push   $0x47a
f0101f61:	68 5f 55 10 f0       	push   $0xf010555f
f0101f66:	e8 d5 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f6b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f70:	74 19                	je     f0101f8b <mem_init+0xf49>
f0101f72:	68 a4 57 10 f0       	push   $0xf01057a4
f0101f77:	68 85 55 10 f0       	push   $0xf0105585
f0101f7c:	68 7b 04 00 00       	push   $0x47b
f0101f81:	68 5f 55 10 f0       	push   $0xf010555f
f0101f86:	e8 b5 e0 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f8b:	6a 00                	push   $0x0
f0101f8d:	68 00 10 00 00       	push   $0x1000
f0101f92:	56                   	push   %esi
f0101f93:	ff 75 d0             	pushl  -0x30(%ebp)
f0101f96:	e8 06 f0 ff ff       	call   f0100fa1 <page_insert>
f0101f9b:	83 c4 10             	add    $0x10,%esp
f0101f9e:	85 c0                	test   %eax,%eax
f0101fa0:	74 19                	je     f0101fbb <mem_init+0xf79>
f0101fa2:	68 bc 5d 10 f0       	push   $0xf0105dbc
f0101fa7:	68 85 55 10 f0       	push   $0xf0105585
f0101fac:	68 7e 04 00 00       	push   $0x47e
f0101fb1:	68 5f 55 10 f0       	push   $0xf010555f
f0101fb6:	e8 85 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0101fbb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fc0:	75 19                	jne    f0101fdb <mem_init+0xf99>
f0101fc2:	68 b5 57 10 f0       	push   $0xf01057b5
f0101fc7:	68 85 55 10 f0       	push   $0xf0105585
f0101fcc:	68 7f 04 00 00       	push   $0x47f
f0101fd1:	68 5f 55 10 f0       	push   $0xf010555f
f0101fd6:	e8 65 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0101fdb:	83 3e 00             	cmpl   $0x0,(%esi)
f0101fde:	74 19                	je     f0101ff9 <mem_init+0xfb7>
f0101fe0:	68 c1 57 10 f0       	push   $0xf01057c1
f0101fe5:	68 85 55 10 f0       	push   $0xf0105585
f0101fea:	68 80 04 00 00       	push   $0x480
f0101fef:	68 5f 55 10 f0       	push   $0xf010555f
f0101ff4:	e8 47 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101ff9:	83 ec 08             	sub    $0x8,%esp
f0101ffc:	68 00 10 00 00       	push   $0x1000
f0102001:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f0102007:	e8 48 ef ff ff       	call   f0100f54 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010200c:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
f0102011:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102014:	ba 00 00 00 00       	mov    $0x0,%edx
f0102019:	e8 37 eb ff ff       	call   f0100b55 <check_va2pa>
f010201e:	83 c4 10             	add    $0x10,%esp
f0102021:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102024:	74 19                	je     f010203f <mem_init+0xffd>
f0102026:	68 98 5d 10 f0       	push   $0xf0105d98
f010202b:	68 85 55 10 f0       	push   $0xf0105585
f0102030:	68 84 04 00 00       	push   $0x484
f0102035:	68 5f 55 10 f0       	push   $0xf010555f
f010203a:	e8 01 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010203f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102044:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102047:	e8 09 eb ff ff       	call   f0100b55 <check_va2pa>
f010204c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010204f:	74 19                	je     f010206a <mem_init+0x1028>
f0102051:	68 f4 5d 10 f0       	push   $0xf0105df4
f0102056:	68 85 55 10 f0       	push   $0xf0105585
f010205b:	68 85 04 00 00       	push   $0x485
f0102060:	68 5f 55 10 f0       	push   $0xf010555f
f0102065:	e8 d6 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010206a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010206f:	74 19                	je     f010208a <mem_init+0x1048>
f0102071:	68 d6 57 10 f0       	push   $0xf01057d6
f0102076:	68 85 55 10 f0       	push   $0xf0105585
f010207b:	68 86 04 00 00       	push   $0x486
f0102080:	68 5f 55 10 f0       	push   $0xf010555f
f0102085:	e8 b6 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010208a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010208f:	74 19                	je     f01020aa <mem_init+0x1068>
f0102091:	68 a4 57 10 f0       	push   $0xf01057a4
f0102096:	68 85 55 10 f0       	push   $0xf0105585
f010209b:	68 87 04 00 00       	push   $0x487
f01020a0:	68 5f 55 10 f0       	push   $0xf010555f
f01020a5:	e8 96 df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01020aa:	83 ec 0c             	sub    $0xc,%esp
f01020ad:	6a 00                	push   $0x0
f01020af:	e8 81 ec ff ff       	call   f0100d35 <page_alloc>
f01020b4:	83 c4 10             	add    $0x10,%esp
f01020b7:	39 c6                	cmp    %eax,%esi
f01020b9:	75 04                	jne    f01020bf <mem_init+0x107d>
f01020bb:	85 c0                	test   %eax,%eax
f01020bd:	75 19                	jne    f01020d8 <mem_init+0x1096>
f01020bf:	68 1c 5e 10 f0       	push   $0xf0105e1c
f01020c4:	68 85 55 10 f0       	push   $0xf0105585
f01020c9:	68 8a 04 00 00       	push   $0x48a
f01020ce:	68 5f 55 10 f0       	push   $0xf010555f
f01020d3:	e8 68 df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01020d8:	83 ec 0c             	sub    $0xc,%esp
f01020db:	6a 00                	push   $0x0
f01020dd:	e8 53 ec ff ff       	call   f0100d35 <page_alloc>
f01020e2:	83 c4 10             	add    $0x10,%esp
f01020e5:	85 c0                	test   %eax,%eax
f01020e7:	74 19                	je     f0102102 <mem_init+0x10c0>
f01020e9:	68 f8 56 10 f0       	push   $0xf01056f8
f01020ee:	68 85 55 10 f0       	push   $0xf0105585
f01020f3:	68 8d 04 00 00       	push   $0x48d
f01020f8:	68 5f 55 10 f0       	push   $0xf010555f
f01020fd:	e8 3e df ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102102:	8b 0d 0c 8f 22 f0    	mov    0xf0228f0c,%ecx
f0102108:	8b 11                	mov    (%ecx),%edx
f010210a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102110:	89 d8                	mov    %ebx,%eax
f0102112:	2b 05 10 8f 22 f0    	sub    0xf0228f10,%eax
f0102118:	c1 f8 03             	sar    $0x3,%eax
f010211b:	c1 e0 0c             	shl    $0xc,%eax
f010211e:	39 c2                	cmp    %eax,%edx
f0102120:	74 19                	je     f010213b <mem_init+0x10f9>
f0102122:	68 c0 5a 10 f0       	push   $0xf0105ac0
f0102127:	68 85 55 10 f0       	push   $0xf0105585
f010212c:	68 90 04 00 00       	push   $0x490
f0102131:	68 5f 55 10 f0       	push   $0xf010555f
f0102136:	e8 05 df ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010213b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102141:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102146:	74 19                	je     f0102161 <mem_init+0x111f>
f0102148:	68 5b 57 10 f0       	push   $0xf010575b
f010214d:	68 85 55 10 f0       	push   $0xf0105585
f0102152:	68 92 04 00 00       	push   $0x492
f0102157:	68 5f 55 10 f0       	push   $0xf010555f
f010215c:	e8 df de ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102161:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102167:	83 ec 0c             	sub    $0xc,%esp
f010216a:	53                   	push   %ebx
f010216b:	e8 36 ec ff ff       	call   f0100da6 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102170:	83 c4 0c             	add    $0xc,%esp
f0102173:	6a 01                	push   $0x1
f0102175:	68 00 10 40 00       	push   $0x401000
f010217a:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f0102180:	e8 9e ec ff ff       	call   f0100e23 <pgdir_walk>
f0102185:	89 c1                	mov    %eax,%ecx
f0102187:	89 45 e0             	mov    %eax,-0x20(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010218a:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
f010218f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102192:	8b 40 04             	mov    0x4(%eax),%eax
f0102195:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010219a:	89 c2                	mov    %eax,%edx
f010219c:	c1 ea 0c             	shr    $0xc,%edx
f010219f:	83 c4 10             	add    $0x10,%esp
f01021a2:	3b 15 08 8f 22 f0    	cmp    0xf0228f08,%edx
f01021a8:	72 15                	jb     f01021bf <mem_init+0x117d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021aa:	50                   	push   %eax
f01021ab:	68 a4 4f 10 f0       	push   $0xf0104fa4
f01021b0:	68 99 04 00 00       	push   $0x499
f01021b5:	68 5f 55 10 f0       	push   $0xf010555f
f01021ba:	e8 81 de ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01021bf:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01021c4:	39 c1                	cmp    %eax,%ecx
f01021c6:	74 19                	je     f01021e1 <mem_init+0x119f>
f01021c8:	68 e7 57 10 f0       	push   $0xf01057e7
f01021cd:	68 85 55 10 f0       	push   $0xf0105585
f01021d2:	68 9a 04 00 00       	push   $0x49a
f01021d7:	68 5f 55 10 f0       	push   $0xf010555f
f01021dc:	e8 5f de ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01021e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01021e4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01021eb:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01021f1:	89 d8                	mov    %ebx,%eax
f01021f3:	e8 26 e9 ff ff       	call   f0100b1e <page2kva>
f01021f8:	83 ec 04             	sub    $0x4,%esp
f01021fb:	68 00 10 00 00       	push   $0x1000
f0102200:	68 ff 00 00 00       	push   $0xff
f0102205:	50                   	push   %eax
f0102206:	e8 c1 20 00 00       	call   f01042cc <memset>
	page_free(pp0);
f010220b:	89 1c 24             	mov    %ebx,(%esp)
f010220e:	e8 93 eb ff ff       	call   f0100da6 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102213:	83 c4 0c             	add    $0xc,%esp
f0102216:	6a 01                	push   $0x1
f0102218:	6a 00                	push   $0x0
f010221a:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f0102220:	e8 fe eb ff ff       	call   f0100e23 <pgdir_walk>
	ptep = (pte_t *) page2kva(pp0);
f0102225:	89 d8                	mov    %ebx,%eax
f0102227:	e8 f2 e8 ff ff       	call   f0100b1e <page2kva>
f010222c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010222f:	83 c4 10             	add    $0x10,%esp
	for(i=0; i<NPTENTRIES; i++)
f0102232:	ba 00 00 00 00       	mov    $0x0,%edx
		assert((ptep[i] & PTE_P) == 0);
f0102237:	f6 04 90 01          	testb  $0x1,(%eax,%edx,4)
f010223b:	74 19                	je     f0102256 <mem_init+0x1214>
f010223d:	68 ff 57 10 f0       	push   $0xf01057ff
f0102242:	68 85 55 10 f0       	push   $0xf0105585
f0102247:	68 a4 04 00 00       	push   $0x4a4
f010224c:	68 5f 55 10 f0       	push   $0xf010555f
f0102251:	e8 ea dd ff ff       	call   f0100040 <_panic>
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102256:	83 c2 01             	add    $0x1,%edx
f0102259:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f010225f:	75 d6                	jne    f0102237 <mem_init+0x11f5>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102261:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
f0102266:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010226c:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// give free list back
	page_free_list = fl;
f0102272:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102275:	a3 40 82 22 f0       	mov    %eax,0xf0228240

	// free the pages we took
	page_free(pp0);
f010227a:	83 ec 0c             	sub    $0xc,%esp
f010227d:	53                   	push   %ebx
f010227e:	e8 23 eb ff ff       	call   f0100da6 <page_free>
	page_free(pp1);
f0102283:	89 34 24             	mov    %esi,(%esp)
f0102286:	e8 1b eb ff ff       	call   f0100da6 <page_free>
	page_free(pp2);
f010228b:	89 3c 24             	mov    %edi,(%esp)
f010228e:	e8 13 eb ff ff       	call   f0100da6 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102293:	83 c4 08             	add    $0x8,%esp
f0102296:	68 01 10 00 00       	push   $0x1001
f010229b:	6a 00                	push   $0x0
f010229d:	e8 86 ed ff ff       	call   f0101028 <mmio_map_region>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01022a2:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01022a7:	0f 85 db f0 ff ff    	jne    f0101388 <mem_init+0x346>
f01022ad:	e9 bd f0 ff ff       	jmp    f010136f <mem_init+0x32d>
f01022b2:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01022b7:	0f 85 d0 f0 ff ff    	jne    f010138d <mem_init+0x34b>
f01022bd:	e9 ad f0 ff ff       	jmp    f010136f <mem_init+0x32d>

f01022c2 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01022c2:	55                   	push   %ebp
f01022c3:	89 e5                	mov    %esp,%ebp
f01022c5:	57                   	push   %edi
f01022c6:	56                   	push   %esi
f01022c7:	53                   	push   %ebx
f01022c8:	83 ec 1c             	sub    $0x1c,%esp
f01022cb:	8b 7d 08             	mov    0x8(%ebp),%edi
f01022ce:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.

	pte_t* pte;

	// for every page in this region
	for (void* i=ROUNDDOWN((void *)va, PGSIZE); i<ROUNDUP((void *)(va+len), PGSIZE); i+=PGSIZE) {
f01022d1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01022d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01022d9:	89 c3                	mov    %eax,%ebx
f01022db:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01022de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01022e1:	03 45 10             	add    0x10(%ebp),%eax
f01022e4:	05 ff 0f 00 00       	add    $0xfff,%eax
f01022e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01022ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01022f1:	eb 60                	jmp    f0102353 <user_mem_check+0x91>

		if ((uintptr_t)i >= ULIM) {
f01022f3:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f01022f6:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01022fc:	76 0d                	jbe    f010230b <user_mem_check+0x49>
			user_mem_check_addr = (uintptr_t)i;
f01022fe:	89 1d 3c 82 22 f0    	mov    %ebx,0xf022823c
			return -E_FAULT;
f0102304:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102309:	eb 52                	jmp    f010235d <user_mem_check+0x9b>
		}

		//  get this page
		pte = pgdir_walk(env->env_pgdir, i, 0);
f010230b:	83 ec 04             	sub    $0x4,%esp
f010230e:	6a 00                	push   $0x0
f0102310:	53                   	push   %ebx
f0102311:	ff 77 60             	pushl  0x60(%edi)
f0102314:	e8 0a eb ff ff       	call   f0100e23 <pgdir_walk>

		if (pte == NULL) {
f0102319:	83 c4 10             	add    $0x10,%esp
f010231c:	85 c0                	test   %eax,%eax
f010231e:	75 0f                	jne    f010232f <user_mem_check+0x6d>
			user_mem_check_addr = (uintptr_t)i;
f0102320:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102323:	a3 3c 82 22 f0       	mov    %eax,0xf022823c
			return -E_FAULT;
f0102328:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010232d:	eb 2e                	jmp    f010235d <user_mem_check+0x9b>
		}

		// perm wrong
		if (((uint32_t)(*pte) & perm) != perm) {
f010232f:	89 f2                	mov    %esi,%edx
f0102331:	23 10                	and    (%eax),%edx
f0102333:	39 d6                	cmp    %edx,%esi
f0102335:	74 16                	je     f010234d <user_mem_check+0x8b>
			// if happens at first page, we return va instead of ROUNDDOWN(va, PGSIZE)
			// just to make it more precise 
			user_mem_check_addr = i == ROUNDDOWN(va, PGSIZE)? (uintptr_t)va:(uintptr_t)i;
f0102337:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f010233a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010233d:	0f 44 45 0c          	cmove  0xc(%ebp),%eax
f0102341:	a3 3c 82 22 f0       	mov    %eax,0xf022823c
			return -E_FAULT;
f0102346:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010234b:	eb 10                	jmp    f010235d <user_mem_check+0x9b>
	// LAB 3: Your code here.

	pte_t* pte;

	// for every page in this region
	for (void* i=ROUNDDOWN((void *)va, PGSIZE); i<ROUNDUP((void *)(va+len), PGSIZE); i+=PGSIZE) {
f010234d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102353:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102356:	72 9b                	jb     f01022f3 <user_mem_check+0x31>
			return -E_FAULT;
		}

	}

	return 0;
f0102358:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010235d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102360:	5b                   	pop    %ebx
f0102361:	5e                   	pop    %esi
f0102362:	5f                   	pop    %edi
f0102363:	5d                   	pop    %ebp
f0102364:	c3                   	ret    

f0102365 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102365:	55                   	push   %ebp
f0102366:	89 e5                	mov    %esp,%ebp
f0102368:	53                   	push   %ebx
f0102369:	83 ec 04             	sub    $0x4,%esp
f010236c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010236f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102372:	83 c8 04             	or     $0x4,%eax
f0102375:	50                   	push   %eax
f0102376:	ff 75 10             	pushl  0x10(%ebp)
f0102379:	ff 75 0c             	pushl  0xc(%ebp)
f010237c:	53                   	push   %ebx
f010237d:	e8 40 ff ff ff       	call   f01022c2 <user_mem_check>
f0102382:	83 c4 10             	add    $0x10,%esp
f0102385:	85 c0                	test   %eax,%eax
f0102387:	79 21                	jns    f01023aa <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102389:	83 ec 04             	sub    $0x4,%esp
f010238c:	ff 35 3c 82 22 f0    	pushl  0xf022823c
f0102392:	ff 73 48             	pushl  0x48(%ebx)
f0102395:	68 40 5e 10 f0       	push   $0xf0105e40
f010239a:	e8 3d 09 00 00       	call   f0102cdc <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010239f:	89 1c 24             	mov    %ebx,(%esp)
f01023a2:	e8 3f 06 00 00       	call   f01029e6 <env_destroy>
f01023a7:	83 c4 10             	add    $0x10,%esp
	}
}
f01023aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01023ad:	c9                   	leave  
f01023ae:	c3                   	ret    

f01023af <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01023af:	55                   	push   %ebp
f01023b0:	89 e5                	mov    %esp,%ebp
f01023b2:	57                   	push   %edi
f01023b3:	56                   	push   %esi
f01023b4:	53                   	push   %ebx
f01023b5:	83 ec 0c             	sub    $0xc,%esp
f01023b8:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f01023ba:	89 d3                	mov    %edx,%ebx
f01023bc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01023c2:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f01023c9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f01023cf:	eb 56                	jmp    f0102427 <region_alloc+0x78>

		struct PageInfo* pp = page_alloc(ALLOC_ZERO);
f01023d1:	83 ec 0c             	sub    $0xc,%esp
f01023d4:	6a 01                	push   $0x1
f01023d6:	e8 5a e9 ff ff       	call   f0100d35 <page_alloc>
		if (pp == 0) {
f01023db:	83 c4 10             	add    $0x10,%esp
f01023de:	85 c0                	test   %eax,%eax
f01023e0:	75 17                	jne    f01023f9 <region_alloc+0x4a>
			panic("region_alloc: page_alloc return 0");
f01023e2:	83 ec 04             	sub    $0x4,%esp
f01023e5:	68 78 5e 10 f0       	push   $0xf0105e78
f01023ea:	68 2b 01 00 00       	push   $0x12b
f01023ef:	68 3c 5f 10 f0       	push   $0xf0105f3c
f01023f4:	e8 47 dc ff ff       	call   f0100040 <_panic>
		}

		int err = page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
f01023f9:	6a 06                	push   $0x6
f01023fb:	53                   	push   %ebx
f01023fc:	50                   	push   %eax
f01023fd:	ff 77 60             	pushl  0x60(%edi)
f0102400:	e8 9c eb ff ff       	call   f0100fa1 <page_insert>
		if (err < 0) {
f0102405:	83 c4 10             	add    $0x10,%esp
f0102408:	85 c0                	test   %eax,%eax
f010240a:	79 15                	jns    f0102421 <region_alloc+0x72>
			panic("region_alloc: page_insert failed: %e", err);
f010240c:	50                   	push   %eax
f010240d:	68 9c 5e 10 f0       	push   $0xf0105e9c
f0102412:	68 30 01 00 00       	push   $0x130
f0102417:	68 3c 5f 10 f0       	push   $0xf0105f3c
f010241c:	e8 1f dc ff ff       	call   f0100040 <_panic>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f0102421:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102427:	39 f3                	cmp    %esi,%ebx
f0102429:	72 a6                	jb     f01023d1 <region_alloc+0x22>
		}

	}

	
}
f010242b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010242e:	5b                   	pop    %ebx
f010242f:	5e                   	pop    %esi
f0102430:	5f                   	pop    %edi
f0102431:	5d                   	pop    %ebp
f0102432:	c3                   	ret    

f0102433 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102433:	55                   	push   %ebp
f0102434:	89 e5                	mov    %esp,%ebp
f0102436:	56                   	push   %esi
f0102437:	53                   	push   %ebx
f0102438:	8b 45 08             	mov    0x8(%ebp),%eax
f010243b:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010243e:	85 c0                	test   %eax,%eax
f0102440:	75 1a                	jne    f010245c <envid2env+0x29>
		*env_store = curenv;
f0102442:	e8 a7 24 00 00       	call   f01048ee <cpunum>
f0102447:	6b c0 74             	imul   $0x74,%eax,%eax
f010244a:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f0102450:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102453:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102455:	b8 00 00 00 00       	mov    $0x0,%eax
f010245a:	eb 70                	jmp    f01024cc <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010245c:	89 c3                	mov    %eax,%ebx
f010245e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102464:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102467:	03 1d 48 82 22 f0    	add    0xf0228248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010246d:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102471:	74 05                	je     f0102478 <envid2env+0x45>
f0102473:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102476:	74 10                	je     f0102488 <envid2env+0x55>
		*env_store = 0;
f0102478:	8b 45 0c             	mov    0xc(%ebp),%eax
f010247b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102481:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102486:	eb 44                	jmp    f01024cc <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102488:	84 d2                	test   %dl,%dl
f010248a:	74 36                	je     f01024c2 <envid2env+0x8f>
f010248c:	e8 5d 24 00 00       	call   f01048ee <cpunum>
f0102491:	6b c0 74             	imul   $0x74,%eax,%eax
f0102494:	3b 98 28 90 22 f0    	cmp    -0xfdd6fd8(%eax),%ebx
f010249a:	74 26                	je     f01024c2 <envid2env+0x8f>
f010249c:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010249f:	e8 4a 24 00 00       	call   f01048ee <cpunum>
f01024a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01024a7:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f01024ad:	3b 70 48             	cmp    0x48(%eax),%esi
f01024b0:	74 10                	je     f01024c2 <envid2env+0x8f>
		*env_store = 0;
f01024b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01024b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01024bb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01024c0:	eb 0a                	jmp    f01024cc <envid2env+0x99>
	}

	*env_store = e;
f01024c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01024c5:	89 18                	mov    %ebx,(%eax)
	return 0;
f01024c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01024cc:	5b                   	pop    %ebx
f01024cd:	5e                   	pop    %esi
f01024ce:	5d                   	pop    %ebp
f01024cf:	c3                   	ret    

f01024d0 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01024d0:	55                   	push   %ebp
f01024d1:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01024d3:	b8 00 d3 11 f0       	mov    $0xf011d300,%eax
f01024d8:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01024db:	b8 23 00 00 00       	mov    $0x23,%eax
f01024e0:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01024e2:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01024e4:	b8 10 00 00 00       	mov    $0x10,%eax
f01024e9:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01024eb:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01024ed:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01024ef:	ea f6 24 10 f0 08 00 	ljmp   $0x8,$0xf01024f6
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f01024f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01024fb:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01024fe:	5d                   	pop    %ebp
f01024ff:	c3                   	ret    

f0102500 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102500:	55                   	push   %ebp
f0102501:	89 e5                	mov    %esp,%ebp
f0102503:	56                   	push   %esi
f0102504:	53                   	push   %ebx
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
		envs[i].env_id = 0;
f0102505:	8b 35 48 82 22 f0    	mov    0xf0228248,%esi
f010250b:	8b 15 4c 82 22 f0    	mov    0xf022824c,%edx
f0102511:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102517:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f010251a:	89 c1                	mov    %eax,%ecx
f010251c:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102523:	89 50 44             	mov    %edx,0x44(%eax)
f0102526:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0102529:	89 ca                	mov    %ecx,%edx
	// Set up envs array
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
f010252b:	39 d8                	cmp    %ebx,%eax
f010252d:	75 eb                	jne    f010251a <env_init+0x1a>
f010252f:	89 35 4c 82 22 f0    	mov    %esi,0xf022824c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0102535:	e8 96 ff ff ff       	call   f01024d0 <env_init_percpu>
}
f010253a:	5b                   	pop    %ebx
f010253b:	5e                   	pop    %esi
f010253c:	5d                   	pop    %ebp
f010253d:	c3                   	ret    

f010253e <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010253e:	55                   	push   %ebp
f010253f:	89 e5                	mov    %esp,%ebp
f0102541:	56                   	push   %esi
f0102542:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102543:	8b 1d 4c 82 22 f0    	mov    0xf022824c,%ebx
f0102549:	85 db                	test   %ebx,%ebx
f010254b:	0f 84 64 01 00 00    	je     f01026b5 <env_alloc+0x177>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102551:	83 ec 0c             	sub    $0xc,%esp
f0102554:	6a 01                	push   $0x1
f0102556:	e8 da e7 ff ff       	call   f0100d35 <page_alloc>
f010255b:	89 c6                	mov    %eax,%esi
f010255d:	83 c4 10             	add    $0x10,%esp
f0102560:	85 c0                	test   %eax,%eax
f0102562:	0f 84 54 01 00 00    	je     f01026bc <env_alloc+0x17e>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102568:	2b 05 10 8f 22 f0    	sub    0xf0228f10,%eax
f010256e:	c1 f8 03             	sar    $0x3,%eax
f0102571:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102574:	89 c2                	mov    %eax,%edx
f0102576:	c1 ea 0c             	shr    $0xc,%edx
f0102579:	3b 15 08 8f 22 f0    	cmp    0xf0228f08,%edx
f010257f:	72 12                	jb     f0102593 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102581:	50                   	push   %eax
f0102582:	68 a4 4f 10 f0       	push   $0xf0104fa4
f0102587:	6a 58                	push   $0x58
f0102589:	68 6b 55 10 f0       	push   $0xf010556b
f010258e:	e8 ad da ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102593:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	e->env_pgdir = page2kva(p);
f0102598:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f010259b:	83 ec 04             	sub    $0x4,%esp
f010259e:	68 00 10 00 00       	push   $0x1000
f01025a3:	ff 35 0c 8f 22 f0    	pushl  0xf0228f0c
f01025a9:	50                   	push   %eax
f01025aa:	e8 d2 1d 00 00       	call   f0104381 <memcpy>
	p->pp_ref++;
f01025af:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01025b4:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025b7:	83 c4 10             	add    $0x10,%esp
f01025ba:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025bf:	77 15                	ja     f01025d6 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025c1:	50                   	push   %eax
f01025c2:	68 c8 4f 10 f0       	push   $0xf0104fc8
f01025c7:	68 c8 00 00 00       	push   $0xc8
f01025cc:	68 3c 5f 10 f0       	push   $0xf0105f3c
f01025d1:	e8 6a da ff ff       	call   f0100040 <_panic>
f01025d6:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01025dc:	83 ca 05             	or     $0x5,%edx
f01025df:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01025e5:	8b 43 48             	mov    0x48(%ebx),%eax
f01025e8:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01025ed:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01025f2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025f7:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01025fa:	89 da                	mov    %ebx,%edx
f01025fc:	2b 15 48 82 22 f0    	sub    0xf0228248,%edx
f0102602:	c1 fa 02             	sar    $0x2,%edx
f0102605:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010260b:	09 d0                	or     %edx,%eax
f010260d:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102610:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102613:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102616:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010261d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102624:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010262b:	83 ec 04             	sub    $0x4,%esp
f010262e:	6a 44                	push   $0x44
f0102630:	6a 00                	push   $0x0
f0102632:	53                   	push   %ebx
f0102633:	e8 94 1c 00 00       	call   f01042cc <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102638:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010263e:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102644:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010264a:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102651:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0102657:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010265e:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0102662:	8b 43 44             	mov    0x44(%ebx),%eax
f0102665:	a3 4c 82 22 f0       	mov    %eax,0xf022824c
	*newenv_store = e;
f010266a:	8b 45 08             	mov    0x8(%ebp),%eax
f010266d:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010266f:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0102672:	e8 77 22 00 00       	call   f01048ee <cpunum>
f0102677:	6b c0 74             	imul   $0x74,%eax,%eax
f010267a:	83 c4 10             	add    $0x10,%esp
f010267d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102682:	83 b8 28 90 22 f0 00 	cmpl   $0x0,-0xfdd6fd8(%eax)
f0102689:	74 11                	je     f010269c <env_alloc+0x15e>
f010268b:	e8 5e 22 00 00       	call   f01048ee <cpunum>
f0102690:	6b c0 74             	imul   $0x74,%eax,%eax
f0102693:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f0102699:	8b 50 48             	mov    0x48(%eax),%edx
f010269c:	83 ec 04             	sub    $0x4,%esp
f010269f:	53                   	push   %ebx
f01026a0:	52                   	push   %edx
f01026a1:	68 47 5f 10 f0       	push   $0xf0105f47
f01026a6:	e8 31 06 00 00       	call   f0102cdc <cprintf>
	return 0;
f01026ab:	83 c4 10             	add    $0x10,%esp
f01026ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01026b3:	eb 0c                	jmp    f01026c1 <env_alloc+0x183>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01026b5:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01026ba:	eb 05                	jmp    f01026c1 <env_alloc+0x183>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01026bc:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01026c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01026c4:	5b                   	pop    %ebx
f01026c5:	5e                   	pop    %esi
f01026c6:	5d                   	pop    %ebp
f01026c7:	c3                   	ret    

f01026c8 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01026c8:	55                   	push   %ebp
f01026c9:	89 e5                	mov    %esp,%ebp
f01026cb:	57                   	push   %edi
f01026cc:	56                   	push   %esi
f01026cd:	53                   	push   %ebx
f01026ce:	83 ec 34             	sub    $0x34,%esp
f01026d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.

	struct Env *newenv_store;
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
f01026d4:	6a 00                	push   $0x0
f01026d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01026d9:	50                   	push   %eax
f01026da:	e8 5f fe ff ff       	call   f010253e <env_alloc>
	if (err < 0) 
f01026df:	83 c4 10             	add    $0x10,%esp
f01026e2:	85 c0                	test   %eax,%eax
f01026e4:	79 15                	jns    f01026fb <env_create+0x33>
		panic("env_create: env_alloc failed: %e", err);
f01026e6:	50                   	push   %eax
f01026e7:	68 c4 5e 10 f0       	push   $0xf0105ec4
f01026ec:	68 b7 01 00 00       	push   $0x1b7
f01026f1:	68 3c 5f 10 f0       	push   $0xf0105f3c
f01026f6:	e8 45 d9 ff ff       	call   f0100040 <_panic>
	load_icode(newenv_store, binary);
f01026fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01026fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.

	// read and check ELF property, inspired by boot/main.c
	struct Elf* elf = (struct Elf*) binary;

	if (elf->e_magic != ELF_MAGIC)
f0102701:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102707:	74 17                	je     f0102720 <env_create+0x58>
		panic("load_icode: not a valid ELF format file");
f0102709:	83 ec 04             	sub    $0x4,%esp
f010270c:	68 e8 5e 10 f0       	push   $0xf0105ee8
f0102711:	68 73 01 00 00       	push   $0x173
f0102716:	68 3c 5f 10 f0       	push   $0xf0105f3c
f010271b:	e8 20 d9 ff ff       	call   f0100040 <_panic>

	struct Proghdr *ph, *eph;
	
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0102720:	89 fb                	mov    %edi,%ebx
f0102722:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f0102725:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102729:	c1 e6 05             	shl    $0x5,%esi
f010272c:	01 de                	add    %ebx,%esi

	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	
f010272e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102731:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102734:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102739:	77 15                	ja     f0102750 <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010273b:	50                   	push   %eax
f010273c:	68 c8 4f 10 f0       	push   $0xf0104fc8
f0102741:	68 7c 01 00 00       	push   $0x17c
f0102746:	68 3c 5f 10 f0       	push   $0xf0105f3c
f010274b:	e8 f0 d8 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102750:	05 00 00 00 10       	add    $0x10000000,%eax
f0102755:	0f 22 d8             	mov    %eax,%cr3
f0102758:	eb 59                	jmp    f01027b3 <env_create+0xeb>

	// for every segment
	for (; ph < eph; ph++) {

		// only load this type of segment
		if (ph->p_type == ELF_PROG_LOAD) {
f010275a:	83 3b 01             	cmpl   $0x1,(%ebx)
f010275d:	75 51                	jne    f01027b0 <env_create+0xe8>

			if (ph->p_filesz > ph->p_memsz)
f010275f:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102762:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0102765:	76 17                	jbe    f010277e <env_create+0xb6>
				panic("load_icode: not a valid ELF format file (2)");
f0102767:	83 ec 04             	sub    $0x4,%esp
f010276a:	68 10 5f 10 f0       	push   $0xf0105f10
f010276f:	68 85 01 00 00       	push   $0x185
f0102774:	68 3c 5f 10 f0       	push   $0xf0105f3c
f0102779:	e8 c2 d8 ff ff       	call   f0100040 <_panic>

			// allocate and map each segment
			// this function needs e->env_pgdir
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010277e:	8b 53 08             	mov    0x8(%ebx),%edx
f0102781:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102784:	e8 26 fc ff ff       	call   f01023af <region_alloc>

			// all clear to 0
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0102789:	83 ec 04             	sub    $0x4,%esp
f010278c:	ff 73 14             	pushl  0x14(%ebx)
f010278f:	6a 00                	push   $0x0
f0102791:	ff 73 08             	pushl  0x8(%ebx)
f0102794:	e8 33 1b 00 00       	call   f01042cc <memset>

			// copy [binary + ph->p_offset, binary + ph->p_offset + ph->p_filesz) to ph->p_va
			// binary is of type uint8_t *, remember not use elf cuz its type is struct Elf*
			// making elf + ph->p_offset pointing to nowhere
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0102799:	83 c4 0c             	add    $0xc,%esp
f010279c:	ff 73 10             	pushl  0x10(%ebx)
f010279f:	89 f8                	mov    %edi,%eax
f01027a1:	03 43 04             	add    0x4(%ebx),%eax
f01027a4:	50                   	push   %eax
f01027a5:	ff 73 08             	pushl  0x8(%ebx)
f01027a8:	e8 d4 1b 00 00       	call   f0104381 <memcpy>
f01027ad:	83 c4 10             	add    $0x10,%esp
	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	

	// for every segment
	for (; ph < eph; ph++) {
f01027b0:	83 c3 20             	add    $0x20,%ebx
f01027b3:	39 de                	cmp    %ebx,%esi
f01027b5:	77 a3                	ja     f010275a <env_create+0x92>
		}

	}

	// load program entry point to eip
	e->env_tf.tf_eip = elf->e_entry;
f01027b7:	8b 47 18             	mov    0x18(%edi),%eax
f01027ba:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01027bd:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.

	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f01027c0:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01027c5:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01027ca:	89 f8                	mov    %edi,%eax
f01027cc:	e8 de fb ff ff       	call   f01023af <region_alloc>

	// after loading things from elf, restore cr3 in kernel
	lcr3(PADDR(kern_pgdir));
f01027d1:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027d6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027db:	77 15                	ja     f01027f2 <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027dd:	50                   	push   %eax
f01027de:	68 c8 4f 10 f0       	push   $0xf0104fc8
f01027e3:	68 a3 01 00 00       	push   $0x1a3
f01027e8:	68 3c 5f 10 f0       	push   $0xf0105f3c
f01027ed:	e8 4e d8 ff ff       	call   f0100040 <_panic>
f01027f2:	05 00 00 00 10       	add    $0x10000000,%eax
f01027f7:	0f 22 d8             	mov    %eax,%cr3
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
	if (err < 0) 
		panic("env_create: env_alloc failed: %e", err);
	load_icode(newenv_store, binary);
	newenv_store->env_type = type;
f01027fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01027fd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102800:	89 50 50             	mov    %edx,0x50(%eax)

}
f0102803:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102806:	5b                   	pop    %ebx
f0102807:	5e                   	pop    %esi
f0102808:	5f                   	pop    %edi
f0102809:	5d                   	pop    %ebp
f010280a:	c3                   	ret    

f010280b <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010280b:	55                   	push   %ebp
f010280c:	89 e5                	mov    %esp,%ebp
f010280e:	57                   	push   %edi
f010280f:	56                   	push   %esi
f0102810:	53                   	push   %ebx
f0102811:	83 ec 1c             	sub    $0x1c,%esp
f0102814:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102817:	e8 d2 20 00 00       	call   f01048ee <cpunum>
f010281c:	6b c0 74             	imul   $0x74,%eax,%eax
f010281f:	39 b8 28 90 22 f0    	cmp    %edi,-0xfdd6fd8(%eax)
f0102825:	75 29                	jne    f0102850 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f0102827:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010282c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102831:	77 15                	ja     f0102848 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102833:	50                   	push   %eax
f0102834:	68 c8 4f 10 f0       	push   $0xf0104fc8
f0102839:	68 cb 01 00 00       	push   $0x1cb
f010283e:	68 3c 5f 10 f0       	push   $0xf0105f3c
f0102843:	e8 f8 d7 ff ff       	call   f0100040 <_panic>
f0102848:	05 00 00 00 10       	add    $0x10000000,%eax
f010284d:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102850:	8b 5f 48             	mov    0x48(%edi),%ebx
f0102853:	e8 96 20 00 00       	call   f01048ee <cpunum>
f0102858:	6b c0 74             	imul   $0x74,%eax,%eax
f010285b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102860:	83 b8 28 90 22 f0 00 	cmpl   $0x0,-0xfdd6fd8(%eax)
f0102867:	74 11                	je     f010287a <env_free+0x6f>
f0102869:	e8 80 20 00 00       	call   f01048ee <cpunum>
f010286e:	6b c0 74             	imul   $0x74,%eax,%eax
f0102871:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f0102877:	8b 50 48             	mov    0x48(%eax),%edx
f010287a:	83 ec 04             	sub    $0x4,%esp
f010287d:	53                   	push   %ebx
f010287e:	52                   	push   %edx
f010287f:	68 5c 5f 10 f0       	push   $0xf0105f5c
f0102884:	e8 53 04 00 00       	call   f0102cdc <cprintf>
f0102889:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010288c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102893:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102896:	89 d0                	mov    %edx,%eax
f0102898:	c1 e0 02             	shl    $0x2,%eax
f010289b:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010289e:	8b 47 60             	mov    0x60(%edi),%eax
f01028a1:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01028a4:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01028aa:	0f 84 a8 00 00 00    	je     f0102958 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01028b0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028b6:	89 f0                	mov    %esi,%eax
f01028b8:	c1 e8 0c             	shr    $0xc,%eax
f01028bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01028be:	39 05 08 8f 22 f0    	cmp    %eax,0xf0228f08
f01028c4:	77 15                	ja     f01028db <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028c6:	56                   	push   %esi
f01028c7:	68 a4 4f 10 f0       	push   $0xf0104fa4
f01028cc:	68 da 01 00 00       	push   $0x1da
f01028d1:	68 3c 5f 10 f0       	push   $0xf0105f3c
f01028d6:	e8 65 d7 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01028db:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01028de:	c1 e0 16             	shl    $0x16,%eax
f01028e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01028e4:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01028e9:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01028f0:	01 
f01028f1:	74 17                	je     f010290a <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01028f3:	83 ec 08             	sub    $0x8,%esp
f01028f6:	89 d8                	mov    %ebx,%eax
f01028f8:	c1 e0 0c             	shl    $0xc,%eax
f01028fb:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01028fe:	50                   	push   %eax
f01028ff:	ff 77 60             	pushl  0x60(%edi)
f0102902:	e8 4d e6 ff ff       	call   f0100f54 <page_remove>
f0102907:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010290a:	83 c3 01             	add    $0x1,%ebx
f010290d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102913:	75 d4                	jne    f01028e9 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102915:	8b 47 60             	mov    0x60(%edi),%eax
f0102918:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010291b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102922:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102925:	3b 05 08 8f 22 f0    	cmp    0xf0228f08,%eax
f010292b:	72 14                	jb     f0102941 <env_free+0x136>
		panic("pa2page called with invalid pa");
f010292d:	83 ec 04             	sub    $0x4,%esp
f0102930:	68 84 58 10 f0       	push   $0xf0105884
f0102935:	6a 51                	push   $0x51
f0102937:	68 6b 55 10 f0       	push   $0xf010556b
f010293c:	e8 ff d6 ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0102941:	83 ec 0c             	sub    $0xc,%esp
f0102944:	a1 10 8f 22 f0       	mov    0xf0228f10,%eax
f0102949:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010294c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010294f:	50                   	push   %eax
f0102950:	e8 a7 e4 ff ff       	call   f0100dfc <page_decref>
f0102955:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102958:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010295c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010295f:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102964:	0f 85 29 ff ff ff    	jne    f0102893 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010296a:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010296d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102972:	77 15                	ja     f0102989 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102974:	50                   	push   %eax
f0102975:	68 c8 4f 10 f0       	push   $0xf0104fc8
f010297a:	68 e8 01 00 00       	push   $0x1e8
f010297f:	68 3c 5f 10 f0       	push   $0xf0105f3c
f0102984:	e8 b7 d6 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0102989:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102990:	05 00 00 00 10       	add    $0x10000000,%eax
f0102995:	c1 e8 0c             	shr    $0xc,%eax
f0102998:	3b 05 08 8f 22 f0    	cmp    0xf0228f08,%eax
f010299e:	72 14                	jb     f01029b4 <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f01029a0:	83 ec 04             	sub    $0x4,%esp
f01029a3:	68 84 58 10 f0       	push   $0xf0105884
f01029a8:	6a 51                	push   $0x51
f01029aa:	68 6b 55 10 f0       	push   $0xf010556b
f01029af:	e8 8c d6 ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01029b4:	83 ec 0c             	sub    $0xc,%esp
f01029b7:	8b 15 10 8f 22 f0    	mov    0xf0228f10,%edx
f01029bd:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01029c0:	50                   	push   %eax
f01029c1:	e8 36 e4 ff ff       	call   f0100dfc <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01029c6:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01029cd:	a1 4c 82 22 f0       	mov    0xf022824c,%eax
f01029d2:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01029d5:	89 3d 4c 82 22 f0    	mov    %edi,0xf022824c
}
f01029db:	83 c4 10             	add    $0x10,%esp
f01029de:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01029e1:	5b                   	pop    %ebx
f01029e2:	5e                   	pop    %esi
f01029e3:	5f                   	pop    %edi
f01029e4:	5d                   	pop    %ebp
f01029e5:	c3                   	ret    

f01029e6 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01029e6:	55                   	push   %ebp
f01029e7:	89 e5                	mov    %esp,%ebp
f01029e9:	53                   	push   %ebx
f01029ea:	83 ec 04             	sub    $0x4,%esp
f01029ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01029f0:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01029f4:	75 19                	jne    f0102a0f <env_destroy+0x29>
f01029f6:	e8 f3 1e 00 00       	call   f01048ee <cpunum>
f01029fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01029fe:	3b 98 28 90 22 f0    	cmp    -0xfdd6fd8(%eax),%ebx
f0102a04:	74 09                	je     f0102a0f <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0102a06:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0102a0d:	eb 33                	jmp    f0102a42 <env_destroy+0x5c>
	}

	env_free(e);
f0102a0f:	83 ec 0c             	sub    $0xc,%esp
f0102a12:	53                   	push   %ebx
f0102a13:	e8 f3 fd ff ff       	call   f010280b <env_free>

	if (curenv == e) {
f0102a18:	e8 d1 1e 00 00       	call   f01048ee <cpunum>
f0102a1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0102a20:	83 c4 10             	add    $0x10,%esp
f0102a23:	3b 98 28 90 22 f0    	cmp    -0xfdd6fd8(%eax),%ebx
f0102a29:	75 17                	jne    f0102a42 <env_destroy+0x5c>
		curenv = NULL;
f0102a2b:	e8 be 1e 00 00       	call   f01048ee <cpunum>
f0102a30:	6b c0 74             	imul   $0x74,%eax,%eax
f0102a33:	c7 80 28 90 22 f0 00 	movl   $0x0,-0xfdd6fd8(%eax)
f0102a3a:	00 00 00 
		sched_yield();
f0102a3d:	e8 fd 0b 00 00       	call   f010363f <sched_yield>
	}
}
f0102a42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102a45:	c9                   	leave  
f0102a46:	c3                   	ret    

f0102a47 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102a47:	55                   	push   %ebp
f0102a48:	89 e5                	mov    %esp,%ebp
f0102a4a:	53                   	push   %ebx
f0102a4b:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0102a4e:	e8 9b 1e 00 00       	call   f01048ee <cpunum>
f0102a53:	6b c0 74             	imul   $0x74,%eax,%eax
f0102a56:	8b 98 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%ebx
f0102a5c:	e8 8d 1e 00 00       	call   f01048ee <cpunum>
f0102a61:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0102a64:	8b 65 08             	mov    0x8(%ebp),%esp
f0102a67:	61                   	popa   
f0102a68:	07                   	pop    %es
f0102a69:	1f                   	pop    %ds
f0102a6a:	83 c4 08             	add    $0x8,%esp
f0102a6d:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102a6e:	83 ec 04             	sub    $0x4,%esp
f0102a71:	68 72 5f 10 f0       	push   $0xf0105f72
f0102a76:	68 1f 02 00 00       	push   $0x21f
f0102a7b:	68 3c 5f 10 f0       	push   $0xf0105f3c
f0102a80:	e8 bb d5 ff ff       	call   f0100040 <_panic>

f0102a85 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102a85:	55                   	push   %ebp
f0102a86:	89 e5                	mov    %esp,%ebp
f0102a88:	53                   	push   %ebx
f0102a89:	83 ec 04             	sub    $0x4,%esp
f0102a8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	// context switch
	if (curenv != e) {
f0102a8f:	e8 5a 1e 00 00       	call   f01048ee <cpunum>
f0102a94:	6b c0 74             	imul   $0x74,%eax,%eax
f0102a97:	39 98 28 90 22 f0    	cmp    %ebx,-0xfdd6fd8(%eax)
f0102a9d:	0f 84 a4 00 00 00    	je     f0102b47 <env_run+0xc2>

		if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0102aa3:	e8 46 1e 00 00       	call   f01048ee <cpunum>
f0102aa8:	6b c0 74             	imul   $0x74,%eax,%eax
f0102aab:	83 b8 28 90 22 f0 00 	cmpl   $0x0,-0xfdd6fd8(%eax)
f0102ab2:	74 29                	je     f0102add <env_run+0x58>
f0102ab4:	e8 35 1e 00 00       	call   f01048ee <cpunum>
f0102ab9:	6b c0 74             	imul   $0x74,%eax,%eax
f0102abc:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f0102ac2:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0102ac6:	75 15                	jne    f0102add <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f0102ac8:	e8 21 1e 00 00       	call   f01048ee <cpunum>
f0102acd:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ad0:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f0102ad6:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		
		curenv = e;
f0102add:	e8 0c 1e 00 00       	call   f01048ee <cpunum>
f0102ae2:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ae5:	89 98 28 90 22 f0    	mov    %ebx,-0xfdd6fd8(%eax)
		curenv->env_status = ENV_RUNNING;
f0102aeb:	e8 fe 1d 00 00       	call   f01048ee <cpunum>
f0102af0:	6b c0 74             	imul   $0x74,%eax,%eax
f0102af3:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f0102af9:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0102b00:	e8 e9 1d 00 00       	call   f01048ee <cpunum>
f0102b05:	6b c0 74             	imul   $0x74,%eax,%eax
f0102b08:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f0102b0e:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f0102b12:	e8 d7 1d 00 00       	call   f01048ee <cpunum>
f0102b17:	6b c0 74             	imul   $0x74,%eax,%eax
f0102b1a:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f0102b20:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b23:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b28:	77 15                	ja     f0102b3f <env_run+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b2a:	50                   	push   %eax
f0102b2b:	68 c8 4f 10 f0       	push   $0xf0104fc8
f0102b30:	68 47 02 00 00       	push   $0x247
f0102b35:	68 3c 5f 10 f0       	push   $0xf0105f3c
f0102b3a:	e8 01 d5 ff ff       	call   f0100040 <_panic>
f0102b3f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b44:	0f 22 d8             	mov    %eax,%cr3
	}

	// iret to execute entry point stored in tf_eip
	// cprintf("[?] try to execute at entry point: %x\n", curenv->env_tf.tf_eip);
	env_pop_tf(&curenv->env_tf);
f0102b47:	e8 a2 1d 00 00       	call   f01048ee <cpunum>
f0102b4c:	83 ec 0c             	sub    $0xc,%esp
f0102b4f:	6b c0 74             	imul   $0x74,%eax,%eax
f0102b52:	ff b0 28 90 22 f0    	pushl  -0xfdd6fd8(%eax)
f0102b58:	e8 ea fe ff ff       	call   f0102a47 <env_pop_tf>

f0102b5d <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102b5d:	55                   	push   %ebp
f0102b5e:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102b60:	ba 70 00 00 00       	mov    $0x70,%edx
f0102b65:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b68:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102b69:	ba 71 00 00 00       	mov    $0x71,%edx
f0102b6e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102b6f:	0f b6 c0             	movzbl %al,%eax
}
f0102b72:	5d                   	pop    %ebp
f0102b73:	c3                   	ret    

f0102b74 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102b74:	55                   	push   %ebp
f0102b75:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102b77:	ba 70 00 00 00       	mov    $0x70,%edx
f0102b7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b7f:	ee                   	out    %al,(%dx)
f0102b80:	ba 71 00 00 00       	mov    $0x71,%edx
f0102b85:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b88:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102b89:	5d                   	pop    %ebp
f0102b8a:	c3                   	ret    

f0102b8b <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0102b8b:	55                   	push   %ebp
f0102b8c:	89 e5                	mov    %esp,%ebp
f0102b8e:	56                   	push   %esi
f0102b8f:	53                   	push   %ebx
f0102b90:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0102b93:	66 a3 88 d3 11 f0    	mov    %ax,0xf011d388
	if (!didinit)
f0102b99:	80 3d 50 82 22 f0 00 	cmpb   $0x0,0xf0228250
f0102ba0:	74 5a                	je     f0102bfc <irq_setmask_8259A+0x71>
f0102ba2:	89 c6                	mov    %eax,%esi
f0102ba4:	ba 21 00 00 00       	mov    $0x21,%edx
f0102ba9:	ee                   	out    %al,(%dx)
f0102baa:	66 c1 e8 08          	shr    $0x8,%ax
f0102bae:	ba a1 00 00 00       	mov    $0xa1,%edx
f0102bb3:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0102bb4:	83 ec 0c             	sub    $0xc,%esp
f0102bb7:	68 7e 5f 10 f0       	push   $0xf0105f7e
f0102bbc:	e8 1b 01 00 00       	call   f0102cdc <cprintf>
f0102bc1:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0102bc4:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0102bc9:	0f b7 f6             	movzwl %si,%esi
f0102bcc:	f7 d6                	not    %esi
f0102bce:	0f a3 de             	bt     %ebx,%esi
f0102bd1:	73 11                	jae    f0102be4 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0102bd3:	83 ec 08             	sub    $0x8,%esp
f0102bd6:	53                   	push   %ebx
f0102bd7:	68 e5 63 10 f0       	push   $0xf01063e5
f0102bdc:	e8 fb 00 00 00       	call   f0102cdc <cprintf>
f0102be1:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0102be4:	83 c3 01             	add    $0x1,%ebx
f0102be7:	83 fb 10             	cmp    $0x10,%ebx
f0102bea:	75 e2                	jne    f0102bce <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0102bec:	83 ec 0c             	sub    $0xc,%esp
f0102bef:	68 4d 50 10 f0       	push   $0xf010504d
f0102bf4:	e8 e3 00 00 00       	call   f0102cdc <cprintf>
f0102bf9:	83 c4 10             	add    $0x10,%esp
}
f0102bfc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102bff:	5b                   	pop    %ebx
f0102c00:	5e                   	pop    %esi
f0102c01:	5d                   	pop    %ebp
f0102c02:	c3                   	ret    

f0102c03 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0102c03:	c6 05 50 82 22 f0 01 	movb   $0x1,0xf0228250
f0102c0a:	ba 21 00 00 00       	mov    $0x21,%edx
f0102c0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102c14:	ee                   	out    %al,(%dx)
f0102c15:	ba a1 00 00 00       	mov    $0xa1,%edx
f0102c1a:	ee                   	out    %al,(%dx)
f0102c1b:	ba 20 00 00 00       	mov    $0x20,%edx
f0102c20:	b8 11 00 00 00       	mov    $0x11,%eax
f0102c25:	ee                   	out    %al,(%dx)
f0102c26:	ba 21 00 00 00       	mov    $0x21,%edx
f0102c2b:	b8 20 00 00 00       	mov    $0x20,%eax
f0102c30:	ee                   	out    %al,(%dx)
f0102c31:	b8 04 00 00 00       	mov    $0x4,%eax
f0102c36:	ee                   	out    %al,(%dx)
f0102c37:	b8 03 00 00 00       	mov    $0x3,%eax
f0102c3c:	ee                   	out    %al,(%dx)
f0102c3d:	ba a0 00 00 00       	mov    $0xa0,%edx
f0102c42:	b8 11 00 00 00       	mov    $0x11,%eax
f0102c47:	ee                   	out    %al,(%dx)
f0102c48:	ba a1 00 00 00       	mov    $0xa1,%edx
f0102c4d:	b8 28 00 00 00       	mov    $0x28,%eax
f0102c52:	ee                   	out    %al,(%dx)
f0102c53:	b8 02 00 00 00       	mov    $0x2,%eax
f0102c58:	ee                   	out    %al,(%dx)
f0102c59:	b8 01 00 00 00       	mov    $0x1,%eax
f0102c5e:	ee                   	out    %al,(%dx)
f0102c5f:	ba 20 00 00 00       	mov    $0x20,%edx
f0102c64:	b8 68 00 00 00       	mov    $0x68,%eax
f0102c69:	ee                   	out    %al,(%dx)
f0102c6a:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102c6f:	ee                   	out    %al,(%dx)
f0102c70:	ba a0 00 00 00       	mov    $0xa0,%edx
f0102c75:	b8 68 00 00 00       	mov    $0x68,%eax
f0102c7a:	ee                   	out    %al,(%dx)
f0102c7b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102c80:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0102c81:	0f b7 05 88 d3 11 f0 	movzwl 0xf011d388,%eax
f0102c88:	66 83 f8 ff          	cmp    $0xffff,%ax
f0102c8c:	74 13                	je     f0102ca1 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0102c8e:	55                   	push   %ebp
f0102c8f:	89 e5                	mov    %esp,%ebp
f0102c91:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0102c94:	0f b7 c0             	movzwl %ax,%eax
f0102c97:	50                   	push   %eax
f0102c98:	e8 ee fe ff ff       	call   f0102b8b <irq_setmask_8259A>
f0102c9d:	83 c4 10             	add    $0x10,%esp
}
f0102ca0:	c9                   	leave  
f0102ca1:	f3 c3                	repz ret 

f0102ca3 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102ca3:	55                   	push   %ebp
f0102ca4:	89 e5                	mov    %esp,%ebp
f0102ca6:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102ca9:	ff 75 08             	pushl  0x8(%ebp)
f0102cac:	e8 84 da ff ff       	call   f0100735 <cputchar>
	*cnt++;
}
f0102cb1:	83 c4 10             	add    $0x10,%esp
f0102cb4:	c9                   	leave  
f0102cb5:	c3                   	ret    

f0102cb6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102cb6:	55                   	push   %ebp
f0102cb7:	89 e5                	mov    %esp,%ebp
f0102cb9:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102cbc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102cc3:	ff 75 0c             	pushl  0xc(%ebp)
f0102cc6:	ff 75 08             	pushl  0x8(%ebp)
f0102cc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102ccc:	50                   	push   %eax
f0102ccd:	68 a3 2c 10 f0       	push   $0xf0102ca3
f0102cd2:	e8 89 0f 00 00       	call   f0103c60 <vprintfmt>
	return cnt;
}
f0102cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102cda:	c9                   	leave  
f0102cdb:	c3                   	ret    

f0102cdc <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102cdc:	55                   	push   %ebp
f0102cdd:	89 e5                	mov    %esp,%ebp
f0102cdf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102ce2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102ce5:	50                   	push   %eax
f0102ce6:	ff 75 08             	pushl  0x8(%ebp)
f0102ce9:	e8 c8 ff ff ff       	call   f0102cb6 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102cee:	c9                   	leave  
f0102cef:	c3                   	ret    

f0102cf0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0102cf0:	55                   	push   %ebp
f0102cf1:	89 e5                	mov    %esp,%ebp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102cf3:	b8 80 8a 22 f0       	mov    $0xf0228a80,%eax
f0102cf8:	c7 05 84 8a 22 f0 00 	movl   $0xf0000000,0xf0228a84
f0102cff:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0102d02:	66 c7 05 88 8a 22 f0 	movw   $0x10,0xf0228a88
f0102d09:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0102d0b:	66 c7 05 e6 8a 22 f0 	movw   $0x68,0xf0228ae6
f0102d12:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102d14:	66 c7 05 48 d3 11 f0 	movw   $0x67,0xf011d348
f0102d1b:	67 00 
f0102d1d:	66 a3 4a d3 11 f0    	mov    %ax,0xf011d34a
f0102d23:	89 c2                	mov    %eax,%edx
f0102d25:	c1 ea 10             	shr    $0x10,%edx
f0102d28:	88 15 4c d3 11 f0    	mov    %dl,0xf011d34c
f0102d2e:	c6 05 4e d3 11 f0 40 	movb   $0x40,0xf011d34e
f0102d35:	c1 e8 18             	shr    $0x18,%eax
f0102d38:	a2 4f d3 11 f0       	mov    %al,0xf011d34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0102d3d:	c6 05 4d d3 11 f0 89 	movb   $0x89,0xf011d34d
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0102d44:	b8 28 00 00 00       	mov    $0x28,%eax
f0102d49:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0102d4c:	b8 8c d3 11 f0       	mov    $0xf011d38c,%eax
f0102d51:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0102d54:	5d                   	pop    %ebp
f0102d55:	c3                   	ret    

f0102d56 <trap_init>:
}


void
trap_init(void)
{
f0102d56:	55                   	push   %ebp
f0102d57:	89 e5                	mov    %esp,%ebp
	void _T_MCHK_handler();
	void _T_SIMDERR_handler();
	void _T_SYSCALL_handler();

	// SETGATE(gate, istrap, sel, off, dpl);
	SETGATE(idt[T_DIVIDE], 0, GD_KT, _T_DIVIDE_handler, 0);
f0102d59:	b8 f6 34 10 f0       	mov    $0xf01034f6,%eax
f0102d5e:	66 a3 60 82 22 f0    	mov    %ax,0xf0228260
f0102d64:	66 c7 05 62 82 22 f0 	movw   $0x8,0xf0228262
f0102d6b:	08 00 
f0102d6d:	c6 05 64 82 22 f0 00 	movb   $0x0,0xf0228264
f0102d74:	c6 05 65 82 22 f0 8e 	movb   $0x8e,0xf0228265
f0102d7b:	c1 e8 10             	shr    $0x10,%eax
f0102d7e:	66 a3 66 82 22 f0    	mov    %ax,0xf0228266
	SETGATE(idt[T_DEBUG], 0, GD_KT, _T_DEBUG_handler, 0);
f0102d84:	b8 fc 34 10 f0       	mov    $0xf01034fc,%eax
f0102d89:	66 a3 68 82 22 f0    	mov    %ax,0xf0228268
f0102d8f:	66 c7 05 6a 82 22 f0 	movw   $0x8,0xf022826a
f0102d96:	08 00 
f0102d98:	c6 05 6c 82 22 f0 00 	movb   $0x0,0xf022826c
f0102d9f:	c6 05 6d 82 22 f0 8e 	movb   $0x8e,0xf022826d
f0102da6:	c1 e8 10             	shr    $0x10,%eax
f0102da9:	66 a3 6e 82 22 f0    	mov    %ax,0xf022826e
	SETGATE(idt[T_NMI], 0, GD_KT, _T_NMI_handler, 0);
f0102daf:	b8 02 35 10 f0       	mov    $0xf0103502,%eax
f0102db4:	66 a3 70 82 22 f0    	mov    %ax,0xf0228270
f0102dba:	66 c7 05 72 82 22 f0 	movw   $0x8,0xf0228272
f0102dc1:	08 00 
f0102dc3:	c6 05 74 82 22 f0 00 	movb   $0x0,0xf0228274
f0102dca:	c6 05 75 82 22 f0 8e 	movb   $0x8e,0xf0228275
f0102dd1:	c1 e8 10             	shr    $0x10,%eax
f0102dd4:	66 a3 76 82 22 f0    	mov    %ax,0xf0228276
	SETGATE(idt[T_BRKPT], 0, GD_KT, _T_BRKPT_handler, 3);
f0102dda:	b8 08 35 10 f0       	mov    $0xf0103508,%eax
f0102ddf:	66 a3 78 82 22 f0    	mov    %ax,0xf0228278
f0102de5:	66 c7 05 7a 82 22 f0 	movw   $0x8,0xf022827a
f0102dec:	08 00 
f0102dee:	c6 05 7c 82 22 f0 00 	movb   $0x0,0xf022827c
f0102df5:	c6 05 7d 82 22 f0 ee 	movb   $0xee,0xf022827d
f0102dfc:	c1 e8 10             	shr    $0x10,%eax
f0102dff:	66 a3 7e 82 22 f0    	mov    %ax,0xf022827e
	SETGATE(idt[T_OFLOW], 0, GD_KT, _T_OFLOW_handler, 0);
f0102e05:	b8 0e 35 10 f0       	mov    $0xf010350e,%eax
f0102e0a:	66 a3 80 82 22 f0    	mov    %ax,0xf0228280
f0102e10:	66 c7 05 82 82 22 f0 	movw   $0x8,0xf0228282
f0102e17:	08 00 
f0102e19:	c6 05 84 82 22 f0 00 	movb   $0x0,0xf0228284
f0102e20:	c6 05 85 82 22 f0 8e 	movb   $0x8e,0xf0228285
f0102e27:	c1 e8 10             	shr    $0x10,%eax
f0102e2a:	66 a3 86 82 22 f0    	mov    %ax,0xf0228286
	SETGATE(idt[T_BOUND], 0, GD_KT, _T_BOUND_handler, 0);
f0102e30:	b8 14 35 10 f0       	mov    $0xf0103514,%eax
f0102e35:	66 a3 88 82 22 f0    	mov    %ax,0xf0228288
f0102e3b:	66 c7 05 8a 82 22 f0 	movw   $0x8,0xf022828a
f0102e42:	08 00 
f0102e44:	c6 05 8c 82 22 f0 00 	movb   $0x0,0xf022828c
f0102e4b:	c6 05 8d 82 22 f0 8e 	movb   $0x8e,0xf022828d
f0102e52:	c1 e8 10             	shr    $0x10,%eax
f0102e55:	66 a3 8e 82 22 f0    	mov    %ax,0xf022828e
	SETGATE(idt[T_ILLOP], 0, GD_KT, _T_ILLOP_handler, 0);
f0102e5b:	b8 1a 35 10 f0       	mov    $0xf010351a,%eax
f0102e60:	66 a3 90 82 22 f0    	mov    %ax,0xf0228290
f0102e66:	66 c7 05 92 82 22 f0 	movw   $0x8,0xf0228292
f0102e6d:	08 00 
f0102e6f:	c6 05 94 82 22 f0 00 	movb   $0x0,0xf0228294
f0102e76:	c6 05 95 82 22 f0 8e 	movb   $0x8e,0xf0228295
f0102e7d:	c1 e8 10             	shr    $0x10,%eax
f0102e80:	66 a3 96 82 22 f0    	mov    %ax,0xf0228296
	SETGATE(idt[T_DEVICE], 0, GD_KT, _T_DEVICE_handler, 0);
f0102e86:	b8 20 35 10 f0       	mov    $0xf0103520,%eax
f0102e8b:	66 a3 98 82 22 f0    	mov    %ax,0xf0228298
f0102e91:	66 c7 05 9a 82 22 f0 	movw   $0x8,0xf022829a
f0102e98:	08 00 
f0102e9a:	c6 05 9c 82 22 f0 00 	movb   $0x0,0xf022829c
f0102ea1:	c6 05 9d 82 22 f0 8e 	movb   $0x8e,0xf022829d
f0102ea8:	c1 e8 10             	shr    $0x10,%eax
f0102eab:	66 a3 9e 82 22 f0    	mov    %ax,0xf022829e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, _T_DBLFLT_handler, 0);
f0102eb1:	b8 26 35 10 f0       	mov    $0xf0103526,%eax
f0102eb6:	66 a3 a0 82 22 f0    	mov    %ax,0xf02282a0
f0102ebc:	66 c7 05 a2 82 22 f0 	movw   $0x8,0xf02282a2
f0102ec3:	08 00 
f0102ec5:	c6 05 a4 82 22 f0 00 	movb   $0x0,0xf02282a4
f0102ecc:	c6 05 a5 82 22 f0 8e 	movb   $0x8e,0xf02282a5
f0102ed3:	c1 e8 10             	shr    $0x10,%eax
f0102ed6:	66 a3 a6 82 22 f0    	mov    %ax,0xf02282a6
	SETGATE(idt[T_TSS], 0, GD_KT, _T_TSS_handler, 0);
f0102edc:	b8 2a 35 10 f0       	mov    $0xf010352a,%eax
f0102ee1:	66 a3 b0 82 22 f0    	mov    %ax,0xf02282b0
f0102ee7:	66 c7 05 b2 82 22 f0 	movw   $0x8,0xf02282b2
f0102eee:	08 00 
f0102ef0:	c6 05 b4 82 22 f0 00 	movb   $0x0,0xf02282b4
f0102ef7:	c6 05 b5 82 22 f0 8e 	movb   $0x8e,0xf02282b5
f0102efe:	c1 e8 10             	shr    $0x10,%eax
f0102f01:	66 a3 b6 82 22 f0    	mov    %ax,0xf02282b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, _T_SEGNP_handler, 0);
f0102f07:	b8 2e 35 10 f0       	mov    $0xf010352e,%eax
f0102f0c:	66 a3 b8 82 22 f0    	mov    %ax,0xf02282b8
f0102f12:	66 c7 05 ba 82 22 f0 	movw   $0x8,0xf02282ba
f0102f19:	08 00 
f0102f1b:	c6 05 bc 82 22 f0 00 	movb   $0x0,0xf02282bc
f0102f22:	c6 05 bd 82 22 f0 8e 	movb   $0x8e,0xf02282bd
f0102f29:	c1 e8 10             	shr    $0x10,%eax
f0102f2c:	66 a3 be 82 22 f0    	mov    %ax,0xf02282be
	SETGATE(idt[T_STACK], 0, GD_KT, _T_STACK_handler, 0);
f0102f32:	b8 32 35 10 f0       	mov    $0xf0103532,%eax
f0102f37:	66 a3 c0 82 22 f0    	mov    %ax,0xf02282c0
f0102f3d:	66 c7 05 c2 82 22 f0 	movw   $0x8,0xf02282c2
f0102f44:	08 00 
f0102f46:	c6 05 c4 82 22 f0 00 	movb   $0x0,0xf02282c4
f0102f4d:	c6 05 c5 82 22 f0 8e 	movb   $0x8e,0xf02282c5
f0102f54:	c1 e8 10             	shr    $0x10,%eax
f0102f57:	66 a3 c6 82 22 f0    	mov    %ax,0xf02282c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, _T_GPFLT_handler, 0);
f0102f5d:	b8 36 35 10 f0       	mov    $0xf0103536,%eax
f0102f62:	66 a3 c8 82 22 f0    	mov    %ax,0xf02282c8
f0102f68:	66 c7 05 ca 82 22 f0 	movw   $0x8,0xf02282ca
f0102f6f:	08 00 
f0102f71:	c6 05 cc 82 22 f0 00 	movb   $0x0,0xf02282cc
f0102f78:	c6 05 cd 82 22 f0 8e 	movb   $0x8e,0xf02282cd
f0102f7f:	c1 e8 10             	shr    $0x10,%eax
f0102f82:	66 a3 ce 82 22 f0    	mov    %ax,0xf02282ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, _T_PGFLT_handler, 0);
f0102f88:	b8 3a 35 10 f0       	mov    $0xf010353a,%eax
f0102f8d:	66 a3 d0 82 22 f0    	mov    %ax,0xf02282d0
f0102f93:	66 c7 05 d2 82 22 f0 	movw   $0x8,0xf02282d2
f0102f9a:	08 00 
f0102f9c:	c6 05 d4 82 22 f0 00 	movb   $0x0,0xf02282d4
f0102fa3:	c6 05 d5 82 22 f0 8e 	movb   $0x8e,0xf02282d5
f0102faa:	c1 e8 10             	shr    $0x10,%eax
f0102fad:	66 a3 d6 82 22 f0    	mov    %ax,0xf02282d6
	SETGATE(idt[T_FPERR], 0, GD_KT, _T_FPERR_handler, 0);
f0102fb3:	b8 3e 35 10 f0       	mov    $0xf010353e,%eax
f0102fb8:	66 a3 e0 82 22 f0    	mov    %ax,0xf02282e0
f0102fbe:	66 c7 05 e2 82 22 f0 	movw   $0x8,0xf02282e2
f0102fc5:	08 00 
f0102fc7:	c6 05 e4 82 22 f0 00 	movb   $0x0,0xf02282e4
f0102fce:	c6 05 e5 82 22 f0 8e 	movb   $0x8e,0xf02282e5
f0102fd5:	c1 e8 10             	shr    $0x10,%eax
f0102fd8:	66 a3 e6 82 22 f0    	mov    %ax,0xf02282e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, _T_ALIGN_handler, 0);
f0102fde:	b8 44 35 10 f0       	mov    $0xf0103544,%eax
f0102fe3:	66 a3 e8 82 22 f0    	mov    %ax,0xf02282e8
f0102fe9:	66 c7 05 ea 82 22 f0 	movw   $0x8,0xf02282ea
f0102ff0:	08 00 
f0102ff2:	c6 05 ec 82 22 f0 00 	movb   $0x0,0xf02282ec
f0102ff9:	c6 05 ed 82 22 f0 8e 	movb   $0x8e,0xf02282ed
f0103000:	c1 e8 10             	shr    $0x10,%eax
f0103003:	66 a3 ee 82 22 f0    	mov    %ax,0xf02282ee
	SETGATE(idt[T_MCHK], 0, GD_KT, _T_MCHK_handler, 0);
f0103009:	b8 48 35 10 f0       	mov    $0xf0103548,%eax
f010300e:	66 a3 f0 82 22 f0    	mov    %ax,0xf02282f0
f0103014:	66 c7 05 f2 82 22 f0 	movw   $0x8,0xf02282f2
f010301b:	08 00 
f010301d:	c6 05 f4 82 22 f0 00 	movb   $0x0,0xf02282f4
f0103024:	c6 05 f5 82 22 f0 8e 	movb   $0x8e,0xf02282f5
f010302b:	c1 e8 10             	shr    $0x10,%eax
f010302e:	66 a3 f6 82 22 f0    	mov    %ax,0xf02282f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, _T_SIMDERR_handler, 0);
f0103034:	b8 4e 35 10 f0       	mov    $0xf010354e,%eax
f0103039:	66 a3 f8 82 22 f0    	mov    %ax,0xf02282f8
f010303f:	66 c7 05 fa 82 22 f0 	movw   $0x8,0xf02282fa
f0103046:	08 00 
f0103048:	c6 05 fc 82 22 f0 00 	movb   $0x0,0xf02282fc
f010304f:	c6 05 fd 82 22 f0 8e 	movb   $0x8e,0xf02282fd
f0103056:	c1 e8 10             	shr    $0x10,%eax
f0103059:	66 a3 fe 82 22 f0    	mov    %ax,0xf02282fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, _T_SYSCALL_handler, 3);
f010305f:	b8 54 35 10 f0       	mov    $0xf0103554,%eax
f0103064:	66 a3 e0 83 22 f0    	mov    %ax,0xf02283e0
f010306a:	66 c7 05 e2 83 22 f0 	movw   $0x8,0xf02283e2
f0103071:	08 00 
f0103073:	c6 05 e4 83 22 f0 00 	movb   $0x0,0xf02283e4
f010307a:	c6 05 e5 83 22 f0 ee 	movb   $0xee,0xf02283e5
f0103081:	c1 e8 10             	shr    $0x10,%eax
f0103084:	66 a3 e6 83 22 f0    	mov    %ax,0xf02283e6

	// Per-CPU setup 
	trap_init_percpu();
f010308a:	e8 61 fc ff ff       	call   f0102cf0 <trap_init_percpu>
}
f010308f:	5d                   	pop    %ebp
f0103090:	c3                   	ret    

f0103091 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103091:	55                   	push   %ebp
f0103092:	89 e5                	mov    %esp,%ebp
f0103094:	53                   	push   %ebx
f0103095:	83 ec 0c             	sub    $0xc,%esp
f0103098:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010309b:	ff 33                	pushl  (%ebx)
f010309d:	68 92 5f 10 f0       	push   $0xf0105f92
f01030a2:	e8 35 fc ff ff       	call   f0102cdc <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01030a7:	83 c4 08             	add    $0x8,%esp
f01030aa:	ff 73 04             	pushl  0x4(%ebx)
f01030ad:	68 a1 5f 10 f0       	push   $0xf0105fa1
f01030b2:	e8 25 fc ff ff       	call   f0102cdc <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01030b7:	83 c4 08             	add    $0x8,%esp
f01030ba:	ff 73 08             	pushl  0x8(%ebx)
f01030bd:	68 b0 5f 10 f0       	push   $0xf0105fb0
f01030c2:	e8 15 fc ff ff       	call   f0102cdc <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01030c7:	83 c4 08             	add    $0x8,%esp
f01030ca:	ff 73 0c             	pushl  0xc(%ebx)
f01030cd:	68 bf 5f 10 f0       	push   $0xf0105fbf
f01030d2:	e8 05 fc ff ff       	call   f0102cdc <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01030d7:	83 c4 08             	add    $0x8,%esp
f01030da:	ff 73 10             	pushl  0x10(%ebx)
f01030dd:	68 ce 5f 10 f0       	push   $0xf0105fce
f01030e2:	e8 f5 fb ff ff       	call   f0102cdc <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01030e7:	83 c4 08             	add    $0x8,%esp
f01030ea:	ff 73 14             	pushl  0x14(%ebx)
f01030ed:	68 dd 5f 10 f0       	push   $0xf0105fdd
f01030f2:	e8 e5 fb ff ff       	call   f0102cdc <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01030f7:	83 c4 08             	add    $0x8,%esp
f01030fa:	ff 73 18             	pushl  0x18(%ebx)
f01030fd:	68 ec 5f 10 f0       	push   $0xf0105fec
f0103102:	e8 d5 fb ff ff       	call   f0102cdc <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103107:	83 c4 08             	add    $0x8,%esp
f010310a:	ff 73 1c             	pushl  0x1c(%ebx)
f010310d:	68 fb 5f 10 f0       	push   $0xf0105ffb
f0103112:	e8 c5 fb ff ff       	call   f0102cdc <cprintf>
}
f0103117:	83 c4 10             	add    $0x10,%esp
f010311a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010311d:	c9                   	leave  
f010311e:	c3                   	ret    

f010311f <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010311f:	55                   	push   %ebp
f0103120:	89 e5                	mov    %esp,%ebp
f0103122:	56                   	push   %esi
f0103123:	53                   	push   %ebx
f0103124:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103127:	e8 c2 17 00 00       	call   f01048ee <cpunum>
f010312c:	83 ec 04             	sub    $0x4,%esp
f010312f:	50                   	push   %eax
f0103130:	53                   	push   %ebx
f0103131:	68 5f 60 10 f0       	push   $0xf010605f
f0103136:	e8 a1 fb ff ff       	call   f0102cdc <cprintf>
	print_regs(&tf->tf_regs);
f010313b:	89 1c 24             	mov    %ebx,(%esp)
f010313e:	e8 4e ff ff ff       	call   f0103091 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103143:	83 c4 08             	add    $0x8,%esp
f0103146:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010314a:	50                   	push   %eax
f010314b:	68 7d 60 10 f0       	push   $0xf010607d
f0103150:	e8 87 fb ff ff       	call   f0102cdc <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103155:	83 c4 08             	add    $0x8,%esp
f0103158:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010315c:	50                   	push   %eax
f010315d:	68 90 60 10 f0       	push   $0xf0106090
f0103162:	e8 75 fb ff ff       	call   f0102cdc <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103167:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f010316a:	83 c4 10             	add    $0x10,%esp
f010316d:	83 f8 13             	cmp    $0x13,%eax
f0103170:	77 09                	ja     f010317b <print_trapframe+0x5c>
		return excnames[trapno];
f0103172:	8b 14 85 00 63 10 f0 	mov    -0xfef9d00(,%eax,4),%edx
f0103179:	eb 1f                	jmp    f010319a <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f010317b:	83 f8 30             	cmp    $0x30,%eax
f010317e:	74 15                	je     f0103195 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103180:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103183:	83 fa 10             	cmp    $0x10,%edx
f0103186:	b9 29 60 10 f0       	mov    $0xf0106029,%ecx
f010318b:	ba 16 60 10 f0       	mov    $0xf0106016,%edx
f0103190:	0f 43 d1             	cmovae %ecx,%edx
f0103193:	eb 05                	jmp    f010319a <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103195:	ba 0a 60 10 f0       	mov    $0xf010600a,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010319a:	83 ec 04             	sub    $0x4,%esp
f010319d:	52                   	push   %edx
f010319e:	50                   	push   %eax
f010319f:	68 a3 60 10 f0       	push   $0xf01060a3
f01031a4:	e8 33 fb ff ff       	call   f0102cdc <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01031a9:	83 c4 10             	add    $0x10,%esp
f01031ac:	3b 1d 60 8a 22 f0    	cmp    0xf0228a60,%ebx
f01031b2:	75 1a                	jne    f01031ce <print_trapframe+0xaf>
f01031b4:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01031b8:	75 14                	jne    f01031ce <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01031ba:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01031bd:	83 ec 08             	sub    $0x8,%esp
f01031c0:	50                   	push   %eax
f01031c1:	68 b5 60 10 f0       	push   $0xf01060b5
f01031c6:	e8 11 fb ff ff       	call   f0102cdc <cprintf>
f01031cb:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01031ce:	83 ec 08             	sub    $0x8,%esp
f01031d1:	ff 73 2c             	pushl  0x2c(%ebx)
f01031d4:	68 c4 60 10 f0       	push   $0xf01060c4
f01031d9:	e8 fe fa ff ff       	call   f0102cdc <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01031de:	83 c4 10             	add    $0x10,%esp
f01031e1:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01031e5:	75 49                	jne    f0103230 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01031e7:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01031ea:	89 c2                	mov    %eax,%edx
f01031ec:	83 e2 01             	and    $0x1,%edx
f01031ef:	ba 43 60 10 f0       	mov    $0xf0106043,%edx
f01031f4:	b9 38 60 10 f0       	mov    $0xf0106038,%ecx
f01031f9:	0f 44 ca             	cmove  %edx,%ecx
f01031fc:	89 c2                	mov    %eax,%edx
f01031fe:	83 e2 02             	and    $0x2,%edx
f0103201:	ba 55 60 10 f0       	mov    $0xf0106055,%edx
f0103206:	be 4f 60 10 f0       	mov    $0xf010604f,%esi
f010320b:	0f 45 d6             	cmovne %esi,%edx
f010320e:	83 e0 04             	and    $0x4,%eax
f0103211:	be 88 61 10 f0       	mov    $0xf0106188,%esi
f0103216:	b8 5a 60 10 f0       	mov    $0xf010605a,%eax
f010321b:	0f 44 c6             	cmove  %esi,%eax
f010321e:	51                   	push   %ecx
f010321f:	52                   	push   %edx
f0103220:	50                   	push   %eax
f0103221:	68 d2 60 10 f0       	push   $0xf01060d2
f0103226:	e8 b1 fa ff ff       	call   f0102cdc <cprintf>
f010322b:	83 c4 10             	add    $0x10,%esp
f010322e:	eb 10                	jmp    f0103240 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103230:	83 ec 0c             	sub    $0xc,%esp
f0103233:	68 4d 50 10 f0       	push   $0xf010504d
f0103238:	e8 9f fa ff ff       	call   f0102cdc <cprintf>
f010323d:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103240:	83 ec 08             	sub    $0x8,%esp
f0103243:	ff 73 30             	pushl  0x30(%ebx)
f0103246:	68 e1 60 10 f0       	push   $0xf01060e1
f010324b:	e8 8c fa ff ff       	call   f0102cdc <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103250:	83 c4 08             	add    $0x8,%esp
f0103253:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103257:	50                   	push   %eax
f0103258:	68 f0 60 10 f0       	push   $0xf01060f0
f010325d:	e8 7a fa ff ff       	call   f0102cdc <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103262:	83 c4 08             	add    $0x8,%esp
f0103265:	ff 73 38             	pushl  0x38(%ebx)
f0103268:	68 03 61 10 f0       	push   $0xf0106103
f010326d:	e8 6a fa ff ff       	call   f0102cdc <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103272:	83 c4 10             	add    $0x10,%esp
f0103275:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103279:	74 25                	je     f01032a0 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010327b:	83 ec 08             	sub    $0x8,%esp
f010327e:	ff 73 3c             	pushl  0x3c(%ebx)
f0103281:	68 12 61 10 f0       	push   $0xf0106112
f0103286:	e8 51 fa ff ff       	call   f0102cdc <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010328b:	83 c4 08             	add    $0x8,%esp
f010328e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103292:	50                   	push   %eax
f0103293:	68 21 61 10 f0       	push   $0xf0106121
f0103298:	e8 3f fa ff ff       	call   f0102cdc <cprintf>
f010329d:	83 c4 10             	add    $0x10,%esp
	}
}
f01032a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01032a3:	5b                   	pop    %ebx
f01032a4:	5e                   	pop    %esi
f01032a5:	5d                   	pop    %ebp
f01032a6:	c3                   	ret    

f01032a7 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01032a7:	55                   	push   %ebp
f01032a8:	89 e5                	mov    %esp,%ebp
f01032aa:	57                   	push   %edi
f01032ab:	56                   	push   %esi
f01032ac:	53                   	push   %ebx
f01032ad:	83 ec 0c             	sub    $0xc,%esp
f01032b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01032b3:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f01032b6:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01032ba:	75 17                	jne    f01032d3 <page_fault_handler+0x2c>
		panic("page fault in kernel!");
f01032bc:	83 ec 04             	sub    $0x4,%esp
f01032bf:	68 34 61 10 f0       	push   $0xf0106134
f01032c4:	68 3d 01 00 00       	push   $0x13d
f01032c9:	68 4a 61 10 f0       	push   $0xf010614a
f01032ce:	e8 6d cd ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01032d3:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01032d6:	e8 13 16 00 00       	call   f01048ee <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01032db:	57                   	push   %edi
f01032dc:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01032dd:	6b c0 74             	imul   $0x74,%eax,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01032e0:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f01032e6:	ff 70 48             	pushl  0x48(%eax)
f01032e9:	68 d4 62 10 f0       	push   $0xf01062d4
f01032ee:	e8 e9 f9 ff ff       	call   f0102cdc <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01032f3:	89 1c 24             	mov    %ebx,(%esp)
f01032f6:	e8 24 fe ff ff       	call   f010311f <print_trapframe>
	env_destroy(curenv);
f01032fb:	e8 ee 15 00 00       	call   f01048ee <cpunum>
f0103300:	83 c4 04             	add    $0x4,%esp
f0103303:	6b c0 74             	imul   $0x74,%eax,%eax
f0103306:	ff b0 28 90 22 f0    	pushl  -0xfdd6fd8(%eax)
f010330c:	e8 d5 f6 ff ff       	call   f01029e6 <env_destroy>
}
f0103311:	83 c4 10             	add    $0x10,%esp
f0103314:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103317:	5b                   	pop    %ebx
f0103318:	5e                   	pop    %esi
f0103319:	5f                   	pop    %edi
f010331a:	5d                   	pop    %ebp
f010331b:	c3                   	ret    

f010331c <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010331c:	55                   	push   %ebp
f010331d:	89 e5                	mov    %esp,%ebp
f010331f:	57                   	push   %edi
f0103320:	56                   	push   %esi
f0103321:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103324:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103325:	83 3d 00 8f 22 f0 00 	cmpl   $0x0,0xf0228f00
f010332c:	74 01                	je     f010332f <trap+0x13>
		asm volatile("hlt");
f010332e:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010332f:	e8 ba 15 00 00       	call   f01048ee <cpunum>
f0103334:	6b d0 74             	imul   $0x74,%eax,%edx
f0103337:	81 c2 20 90 22 f0    	add    $0xf0229020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010333d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103342:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103346:	83 f8 02             	cmp    $0x2,%eax
f0103349:	75 10                	jne    f010335b <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010334b:	83 ec 0c             	sub    $0xc,%esp
f010334e:	68 a0 d3 11 f0       	push   $0xf011d3a0
f0103353:	e8 04 18 00 00       	call   f0104b5c <spin_lock>
f0103358:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010335b:	9c                   	pushf  
f010335c:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010335d:	f6 c4 02             	test   $0x2,%ah
f0103360:	74 19                	je     f010337b <trap+0x5f>
f0103362:	68 56 61 10 f0       	push   $0xf0106156
f0103367:	68 85 55 10 f0       	push   $0xf0105585
f010336c:	68 08 01 00 00       	push   $0x108
f0103371:	68 4a 61 10 f0       	push   $0xf010614a
f0103376:	e8 c5 cc ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010337b:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010337f:	83 e0 03             	and    $0x3,%eax
f0103382:	66 83 f8 03          	cmp    $0x3,%ax
f0103386:	0f 85 90 00 00 00    	jne    f010341c <trap+0x100>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f010338c:	e8 5d 15 00 00       	call   f01048ee <cpunum>
f0103391:	6b c0 74             	imul   $0x74,%eax,%eax
f0103394:	83 b8 28 90 22 f0 00 	cmpl   $0x0,-0xfdd6fd8(%eax)
f010339b:	75 19                	jne    f01033b6 <trap+0x9a>
f010339d:	68 6f 61 10 f0       	push   $0xf010616f
f01033a2:	68 85 55 10 f0       	push   $0xf0105585
f01033a7:	68 0f 01 00 00       	push   $0x10f
f01033ac:	68 4a 61 10 f0       	push   $0xf010614a
f01033b1:	e8 8a cc ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01033b6:	e8 33 15 00 00       	call   f01048ee <cpunum>
f01033bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01033be:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f01033c4:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01033c8:	75 2d                	jne    f01033f7 <trap+0xdb>
			env_free(curenv);
f01033ca:	e8 1f 15 00 00       	call   f01048ee <cpunum>
f01033cf:	83 ec 0c             	sub    $0xc,%esp
f01033d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01033d5:	ff b0 28 90 22 f0    	pushl  -0xfdd6fd8(%eax)
f01033db:	e8 2b f4 ff ff       	call   f010280b <env_free>
			curenv = NULL;
f01033e0:	e8 09 15 00 00       	call   f01048ee <cpunum>
f01033e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01033e8:	c7 80 28 90 22 f0 00 	movl   $0x0,-0xfdd6fd8(%eax)
f01033ef:	00 00 00 
			sched_yield();
f01033f2:	e8 48 02 00 00       	call   f010363f <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01033f7:	e8 f2 14 00 00       	call   f01048ee <cpunum>
f01033fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01033ff:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f0103405:	b9 11 00 00 00       	mov    $0x11,%ecx
f010340a:	89 c7                	mov    %eax,%edi
f010340c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010340e:	e8 db 14 00 00       	call   f01048ee <cpunum>
f0103413:	6b c0 74             	imul   $0x74,%eax,%eax
f0103416:	8b b0 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010341c:	89 35 60 8a 22 f0    	mov    %esi,0xf0228a60
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	struct PushRegs* r = &tf->tf_regs;

	switch(tf->tf_trapno) {
f0103422:	8b 46 28             	mov    0x28(%esi),%eax
f0103425:	83 f8 0e             	cmp    $0xe,%eax
f0103428:	74 0c                	je     f0103436 <trap+0x11a>
f010342a:	83 f8 30             	cmp    $0x30,%eax
f010342d:	74 23                	je     f0103452 <trap+0x136>
f010342f:	83 f8 03             	cmp    $0x3,%eax
f0103432:	75 3f                	jne    f0103473 <trap+0x157>
f0103434:	eb 0e                	jmp    f0103444 <trap+0x128>
		case (T_PGFLT):
			page_fault_handler(tf);
f0103436:	83 ec 0c             	sub    $0xc,%esp
f0103439:	56                   	push   %esi
f010343a:	e8 68 fe ff ff       	call   f01032a7 <page_fault_handler>
f010343f:	83 c4 10             	add    $0x10,%esp
f0103442:	eb 72                	jmp    f01034b6 <trap+0x19a>
			break;
		case (T_BRKPT):
			monitor(tf);	// open a JOS monitor
f0103444:	83 ec 0c             	sub    $0xc,%esp
f0103447:	56                   	push   %esi
f0103448:	e8 0d d5 ff ff       	call   f010095a <monitor>
f010344d:	83 c4 10             	add    $0x10,%esp
f0103450:	eb 64                	jmp    f01034b6 <trap+0x19a>
			break;
		case (T_SYSCALL):
			// call syscall in kern/syscall.c
			r->reg_eax = syscall(r->reg_eax, r->reg_edx, r->reg_ecx, r->reg_ebx, r->reg_edi, r->reg_esi);
f0103452:	83 ec 08             	sub    $0x8,%esp
f0103455:	ff 76 04             	pushl  0x4(%esi)
f0103458:	ff 36                	pushl  (%esi)
f010345a:	ff 76 10             	pushl  0x10(%esi)
f010345d:	ff 76 18             	pushl  0x18(%esi)
f0103460:	ff 76 14             	pushl  0x14(%esi)
f0103463:	ff 76 1c             	pushl  0x1c(%esi)
f0103466:	e8 e1 01 00 00       	call   f010364c <syscall>
f010346b:	89 46 1c             	mov    %eax,0x1c(%esi)
f010346e:	83 c4 20             	add    $0x20,%esp
f0103471:	eb 43                	jmp    f01034b6 <trap+0x19a>
			break;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			print_trapframe(tf);
f0103473:	83 ec 0c             	sub    $0xc,%esp
f0103476:	56                   	push   %esi
f0103477:	e8 a3 fc ff ff       	call   f010311f <print_trapframe>
			if (tf->tf_cs == GD_KT)
f010347c:	83 c4 10             	add    $0x10,%esp
f010347f:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103484:	75 17                	jne    f010349d <trap+0x181>
				panic("unhandled trap in kernel");
f0103486:	83 ec 04             	sub    $0x4,%esp
f0103489:	68 76 61 10 f0       	push   $0xf0106176
f010348e:	68 ed 00 00 00       	push   $0xed
f0103493:	68 4a 61 10 f0       	push   $0xf010614a
f0103498:	e8 a3 cb ff ff       	call   f0100040 <_panic>
			else {
				env_destroy(curenv);
f010349d:	e8 4c 14 00 00       	call   f01048ee <cpunum>
f01034a2:	83 ec 0c             	sub    $0xc,%esp
f01034a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01034a8:	ff b0 28 90 22 f0    	pushl  -0xfdd6fd8(%eax)
f01034ae:	e8 33 f5 ff ff       	call   f01029e6 <env_destroy>
f01034b3:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01034b6:	e8 33 14 00 00       	call   f01048ee <cpunum>
f01034bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01034be:	83 b8 28 90 22 f0 00 	cmpl   $0x0,-0xfdd6fd8(%eax)
f01034c5:	74 2a                	je     f01034f1 <trap+0x1d5>
f01034c7:	e8 22 14 00 00       	call   f01048ee <cpunum>
f01034cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01034cf:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f01034d5:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01034d9:	75 16                	jne    f01034f1 <trap+0x1d5>
		env_run(curenv);
f01034db:	e8 0e 14 00 00       	call   f01048ee <cpunum>
f01034e0:	83 ec 0c             	sub    $0xc,%esp
f01034e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01034e6:	ff b0 28 90 22 f0    	pushl  -0xfdd6fd8(%eax)
f01034ec:	e8 94 f5 ff ff       	call   f0102a85 <env_run>
	else
		sched_yield();
f01034f1:	e8 49 01 00 00       	call   f010363f <sched_yield>

f01034f6 <_T_DIVIDE_handler>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */


TRAPHANDLER_NOEC(_T_DIVIDE_handler, T_DIVIDE)
f01034f6:	6a 00                	push   $0x0
f01034f8:	6a 00                	push   $0x0
f01034fa:	eb 5e                	jmp    f010355a <_alltraps>

f01034fc <_T_DEBUG_handler>:
TRAPHANDLER_NOEC(_T_DEBUG_handler, T_DEBUG)
f01034fc:	6a 00                	push   $0x0
f01034fe:	6a 01                	push   $0x1
f0103500:	eb 58                	jmp    f010355a <_alltraps>

f0103502 <_T_NMI_handler>:
TRAPHANDLER_NOEC(_T_NMI_handler, T_NMI)
f0103502:	6a 00                	push   $0x0
f0103504:	6a 02                	push   $0x2
f0103506:	eb 52                	jmp    f010355a <_alltraps>

f0103508 <_T_BRKPT_handler>:
TRAPHANDLER_NOEC(_T_BRKPT_handler, T_BRKPT)
f0103508:	6a 00                	push   $0x0
f010350a:	6a 03                	push   $0x3
f010350c:	eb 4c                	jmp    f010355a <_alltraps>

f010350e <_T_OFLOW_handler>:
TRAPHANDLER_NOEC(_T_OFLOW_handler, T_OFLOW)
f010350e:	6a 00                	push   $0x0
f0103510:	6a 04                	push   $0x4
f0103512:	eb 46                	jmp    f010355a <_alltraps>

f0103514 <_T_BOUND_handler>:
TRAPHANDLER_NOEC(_T_BOUND_handler, T_BOUND)
f0103514:	6a 00                	push   $0x0
f0103516:	6a 05                	push   $0x5
f0103518:	eb 40                	jmp    f010355a <_alltraps>

f010351a <_T_ILLOP_handler>:
TRAPHANDLER_NOEC(_T_ILLOP_handler, T_ILLOP)
f010351a:	6a 00                	push   $0x0
f010351c:	6a 06                	push   $0x6
f010351e:	eb 3a                	jmp    f010355a <_alltraps>

f0103520 <_T_DEVICE_handler>:
TRAPHANDLER_NOEC(_T_DEVICE_handler, T_DEVICE)
f0103520:	6a 00                	push   $0x0
f0103522:	6a 07                	push   $0x7
f0103524:	eb 34                	jmp    f010355a <_alltraps>

f0103526 <_T_DBLFLT_handler>:
TRAPHANDLER(_T_DBLFLT_handler, T_DBLFLT)
f0103526:	6a 08                	push   $0x8
f0103528:	eb 30                	jmp    f010355a <_alltraps>

f010352a <_T_TSS_handler>:
TRAPHANDLER(_T_TSS_handler, T_TSS)
f010352a:	6a 0a                	push   $0xa
f010352c:	eb 2c                	jmp    f010355a <_alltraps>

f010352e <_T_SEGNP_handler>:
TRAPHANDLER(_T_SEGNP_handler, T_SEGNP)
f010352e:	6a 0b                	push   $0xb
f0103530:	eb 28                	jmp    f010355a <_alltraps>

f0103532 <_T_STACK_handler>:
TRAPHANDLER(_T_STACK_handler, T_STACK)
f0103532:	6a 0c                	push   $0xc
f0103534:	eb 24                	jmp    f010355a <_alltraps>

f0103536 <_T_GPFLT_handler>:
TRAPHANDLER(_T_GPFLT_handler, T_GPFLT)
f0103536:	6a 0d                	push   $0xd
f0103538:	eb 20                	jmp    f010355a <_alltraps>

f010353a <_T_PGFLT_handler>:
TRAPHANDLER(_T_PGFLT_handler, T_PGFLT)
f010353a:	6a 0e                	push   $0xe
f010353c:	eb 1c                	jmp    f010355a <_alltraps>

f010353e <_T_FPERR_handler>:
TRAPHANDLER_NOEC(_T_FPERR_handler, T_FPERR)
f010353e:	6a 00                	push   $0x0
f0103540:	6a 10                	push   $0x10
f0103542:	eb 16                	jmp    f010355a <_alltraps>

f0103544 <_T_ALIGN_handler>:
TRAPHANDLER(_T_ALIGN_handler, T_ALIGN)
f0103544:	6a 11                	push   $0x11
f0103546:	eb 12                	jmp    f010355a <_alltraps>

f0103548 <_T_MCHK_handler>:
TRAPHANDLER_NOEC(_T_MCHK_handler, T_MCHK)
f0103548:	6a 00                	push   $0x0
f010354a:	6a 12                	push   $0x12
f010354c:	eb 0c                	jmp    f010355a <_alltraps>

f010354e <_T_SIMDERR_handler>:
TRAPHANDLER_NOEC(_T_SIMDERR_handler, T_SIMDERR)
f010354e:	6a 00                	push   $0x0
f0103550:	6a 13                	push   $0x13
f0103552:	eb 06                	jmp    f010355a <_alltraps>

f0103554 <_T_SYSCALL_handler>:
TRAPHANDLER_NOEC(_T_SYSCALL_handler, T_SYSCALL)
f0103554:	6a 00                	push   $0x0
f0103556:	6a 30                	push   $0x30
f0103558:	eb 00                	jmp    f010355a <_alltraps>

f010355a <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
f010355a:	1e                   	push   %ds
	pushl %es
f010355b:	06                   	push   %es
	pushal	/* push all general registers */
f010355c:	60                   	pusha  

	movl $GD_KD, %eax
f010355d:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f0103562:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f0103564:	8e c0                	mov    %eax,%es

	push %esp
f0103566:	54                   	push   %esp
f0103567:	e8 b0 fd ff ff       	call   f010331c <trap>

f010356c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010356c:	55                   	push   %ebp
f010356d:	89 e5                	mov    %esp,%ebp
f010356f:	83 ec 08             	sub    $0x8,%esp
f0103572:	a1 48 82 22 f0       	mov    0xf0228248,%eax
f0103577:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010357a:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010357f:	8b 02                	mov    (%edx),%eax
f0103581:	83 e8 01             	sub    $0x1,%eax
f0103584:	83 f8 02             	cmp    $0x2,%eax
f0103587:	76 10                	jbe    f0103599 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103589:	83 c1 01             	add    $0x1,%ecx
f010358c:	83 c2 7c             	add    $0x7c,%edx
f010358f:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103595:	75 e8                	jne    f010357f <sched_halt+0x13>
f0103597:	eb 08                	jmp    f01035a1 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0103599:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010359f:	75 1f                	jne    f01035c0 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01035a1:	83 ec 0c             	sub    $0xc,%esp
f01035a4:	68 50 63 10 f0       	push   $0xf0106350
f01035a9:	e8 2e f7 ff ff       	call   f0102cdc <cprintf>
f01035ae:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01035b1:	83 ec 0c             	sub    $0xc,%esp
f01035b4:	6a 00                	push   $0x0
f01035b6:	e8 9f d3 ff ff       	call   f010095a <monitor>
f01035bb:	83 c4 10             	add    $0x10,%esp
f01035be:	eb f1                	jmp    f01035b1 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01035c0:	e8 29 13 00 00       	call   f01048ee <cpunum>
f01035c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01035c8:	c7 80 28 90 22 f0 00 	movl   $0x0,-0xfdd6fd8(%eax)
f01035cf:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01035d2:	a1 0c 8f 22 f0       	mov    0xf0228f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035d7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035dc:	77 12                	ja     f01035f0 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035de:	50                   	push   %eax
f01035df:	68 c8 4f 10 f0       	push   $0xf0104fc8
f01035e4:	6a 3d                	push   $0x3d
f01035e6:	68 79 63 10 f0       	push   $0xf0106379
f01035eb:	e8 50 ca ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01035f0:	05 00 00 00 10       	add    $0x10000000,%eax
f01035f5:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01035f8:	e8 f1 12 00 00       	call   f01048ee <cpunum>
f01035fd:	6b d0 74             	imul   $0x74,%eax,%edx
f0103600:	81 c2 20 90 22 f0    	add    $0xf0229020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0103606:	b8 02 00 00 00       	mov    $0x2,%eax
f010360b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010360f:	83 ec 0c             	sub    $0xc,%esp
f0103612:	68 a0 d3 11 f0       	push   $0xf011d3a0
f0103617:	e8 dd 15 00 00       	call   f0104bf9 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010361c:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010361e:	e8 cb 12 00 00       	call   f01048ee <cpunum>
f0103623:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0103626:	8b 80 30 90 22 f0    	mov    -0xfdd6fd0(%eax),%eax
f010362c:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103631:	89 c4                	mov    %eax,%esp
f0103633:	6a 00                	push   $0x0
f0103635:	6a 00                	push   $0x0
f0103637:	f4                   	hlt    
f0103638:	eb fd                	jmp    f0103637 <sched_halt+0xcb>
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010363a:	83 c4 10             	add    $0x10,%esp
f010363d:	c9                   	leave  
f010363e:	c3                   	ret    

f010363f <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010363f:	55                   	push   %ebp
f0103640:	89 e5                	mov    %esp,%ebp
f0103642:	83 ec 08             	sub    $0x8,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.

	// sched_halt never returns
	sched_halt();
f0103645:	e8 22 ff ff ff       	call   f010356c <sched_halt>
}
f010364a:	c9                   	leave  
f010364b:	c3                   	ret    

f010364c <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010364c:	55                   	push   %ebp
f010364d:	89 e5                	mov    %esp,%ebp
f010364f:	53                   	push   %ebx
f0103650:	83 ec 14             	sub    $0x14,%esp
f0103653:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f0103656:	83 f8 01             	cmp    $0x1,%eax
f0103659:	74 4f                	je     f01036aa <syscall+0x5e>
f010365b:	83 f8 01             	cmp    $0x1,%eax
f010365e:	72 0f                	jb     f010366f <syscall+0x23>
f0103660:	83 f8 02             	cmp    $0x2,%eax
f0103663:	74 4f                	je     f01036b4 <syscall+0x68>
f0103665:	83 f8 03             	cmp    $0x3,%eax
f0103668:	74 60                	je     f01036ca <syscall+0x7e>
f010366a:	e9 e3 00 00 00       	jmp    f0103752 <syscall+0x106>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);		// just check if PTE_U is set
f010366f:	e8 7a 12 00 00       	call   f01048ee <cpunum>
f0103674:	6a 00                	push   $0x0
f0103676:	ff 75 10             	pushl  0x10(%ebp)
f0103679:	ff 75 0c             	pushl  0xc(%ebp)
f010367c:	6b c0 74             	imul   $0x74,%eax,%eax
f010367f:	ff b0 28 90 22 f0    	pushl  -0xfdd6fd8(%eax)
f0103685:	e8 db ec ff ff       	call   f0102365 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010368a:	83 c4 0c             	add    $0xc,%esp
f010368d:	ff 75 0c             	pushl  0xc(%ebp)
f0103690:	ff 75 10             	pushl  0x10(%ebp)
f0103693:	68 86 63 10 f0       	push   $0xf0106386
f0103698:	e8 3f f6 ff ff       	call   f0102cdc <cprintf>
f010369d:	83 c4 10             	add    $0x10,%esp
	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
f01036a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01036a5:	e9 ad 00 00 00       	jmp    f0103757 <syscall+0x10b>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01036aa:	e8 17 cf ff ff       	call   f01005c6 <cons_getc>
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f01036af:	e9 a3 00 00 00       	jmp    f0103757 <syscall+0x10b>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01036b4:	e8 35 12 00 00       	call   f01048ee <cpunum>
f01036b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01036bc:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f01036c2:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs((char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f01036c5:	e9 8d 00 00 00       	jmp    f0103757 <syscall+0x10b>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01036ca:	83 ec 04             	sub    $0x4,%esp
f01036cd:	6a 01                	push   $0x1
f01036cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01036d2:	50                   	push   %eax
f01036d3:	ff 75 0c             	pushl  0xc(%ebp)
f01036d6:	e8 58 ed ff ff       	call   f0102433 <envid2env>
f01036db:	83 c4 10             	add    $0x10,%esp
f01036de:	85 c0                	test   %eax,%eax
f01036e0:	78 75                	js     f0103757 <syscall+0x10b>
		return r;
	if (e == curenv)
f01036e2:	e8 07 12 00 00       	call   f01048ee <cpunum>
f01036e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01036ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ed:	39 90 28 90 22 f0    	cmp    %edx,-0xfdd6fd8(%eax)
f01036f3:	75 23                	jne    f0103718 <syscall+0xcc>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01036f5:	e8 f4 11 00 00       	call   f01048ee <cpunum>
f01036fa:	83 ec 08             	sub    $0x8,%esp
f01036fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103700:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f0103706:	ff 70 48             	pushl  0x48(%eax)
f0103709:	68 8b 63 10 f0       	push   $0xf010638b
f010370e:	e8 c9 f5 ff ff       	call   f0102cdc <cprintf>
f0103713:	83 c4 10             	add    $0x10,%esp
f0103716:	eb 25                	jmp    f010373d <syscall+0xf1>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103718:	8b 5a 48             	mov    0x48(%edx),%ebx
f010371b:	e8 ce 11 00 00       	call   f01048ee <cpunum>
f0103720:	83 ec 04             	sub    $0x4,%esp
f0103723:	53                   	push   %ebx
f0103724:	6b c0 74             	imul   $0x74,%eax,%eax
f0103727:	8b 80 28 90 22 f0    	mov    -0xfdd6fd8(%eax),%eax
f010372d:	ff 70 48             	pushl  0x48(%eax)
f0103730:	68 a6 63 10 f0       	push   $0xf01063a6
f0103735:	e8 a2 f5 ff ff       	call   f0102cdc <cprintf>
f010373a:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f010373d:	83 ec 0c             	sub    $0xc,%esp
f0103740:	ff 75 f4             	pushl  -0xc(%ebp)
f0103743:	e8 9e f2 ff ff       	call   f01029e6 <env_destroy>
f0103748:	83 c4 10             	add    $0x10,%esp
	return 0;
f010374b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103750:	eb 05                	jmp    f0103757 <syscall+0x10b>
		case SYS_getenvid:
			return sys_getenvid();
		case SYS_env_destroy:
			return sys_env_destroy((envid_t)a1);
		default:
			return -E_INVAL;
f0103752:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f0103757:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010375a:	c9                   	leave  
f010375b:	c3                   	ret    

f010375c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010375c:	55                   	push   %ebp
f010375d:	89 e5                	mov    %esp,%ebp
f010375f:	57                   	push   %edi
f0103760:	56                   	push   %esi
f0103761:	53                   	push   %ebx
f0103762:	83 ec 14             	sub    $0x14,%esp
f0103765:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103768:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010376b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010376e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103771:	8b 1a                	mov    (%edx),%ebx
f0103773:	8b 01                	mov    (%ecx),%eax
f0103775:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103778:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010377f:	eb 7f                	jmp    f0103800 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0103781:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103784:	01 d8                	add    %ebx,%eax
f0103786:	89 c6                	mov    %eax,%esi
f0103788:	c1 ee 1f             	shr    $0x1f,%esi
f010378b:	01 c6                	add    %eax,%esi
f010378d:	d1 fe                	sar    %esi
f010378f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103792:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103795:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0103798:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010379a:	eb 03                	jmp    f010379f <stab_binsearch+0x43>
			m--;
f010379c:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010379f:	39 c3                	cmp    %eax,%ebx
f01037a1:	7f 0d                	jg     f01037b0 <stab_binsearch+0x54>
f01037a3:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01037a7:	83 ea 0c             	sub    $0xc,%edx
f01037aa:	39 f9                	cmp    %edi,%ecx
f01037ac:	75 ee                	jne    f010379c <stab_binsearch+0x40>
f01037ae:	eb 05                	jmp    f01037b5 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01037b0:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01037b3:	eb 4b                	jmp    f0103800 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01037b5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01037b8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01037bb:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01037bf:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01037c2:	76 11                	jbe    f01037d5 <stab_binsearch+0x79>
			*region_left = m;
f01037c4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01037c7:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01037c9:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01037cc:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01037d3:	eb 2b                	jmp    f0103800 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01037d5:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01037d8:	73 14                	jae    f01037ee <stab_binsearch+0x92>
			*region_right = m - 1;
f01037da:	83 e8 01             	sub    $0x1,%eax
f01037dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01037e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01037e3:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01037e5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01037ec:	eb 12                	jmp    f0103800 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01037ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01037f1:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01037f3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01037f7:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01037f9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103800:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103803:	0f 8e 78 ff ff ff    	jle    f0103781 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103809:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010380d:	75 0f                	jne    f010381e <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010380f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103812:	8b 00                	mov    (%eax),%eax
f0103814:	83 e8 01             	sub    $0x1,%eax
f0103817:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010381a:	89 06                	mov    %eax,(%esi)
f010381c:	eb 2c                	jmp    f010384a <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010381e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103821:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103823:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103826:	8b 0e                	mov    (%esi),%ecx
f0103828:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010382b:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010382e:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103831:	eb 03                	jmp    f0103836 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103833:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103836:	39 c8                	cmp    %ecx,%eax
f0103838:	7e 0b                	jle    f0103845 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010383a:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010383e:	83 ea 0c             	sub    $0xc,%edx
f0103841:	39 df                	cmp    %ebx,%edi
f0103843:	75 ee                	jne    f0103833 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103845:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103848:	89 06                	mov    %eax,(%esi)
	}
}
f010384a:	83 c4 14             	add    $0x14,%esp
f010384d:	5b                   	pop    %ebx
f010384e:	5e                   	pop    %esi
f010384f:	5f                   	pop    %edi
f0103850:	5d                   	pop    %ebp
f0103851:	c3                   	ret    

f0103852 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103852:	55                   	push   %ebp
f0103853:	89 e5                	mov    %esp,%ebp
f0103855:	57                   	push   %edi
f0103856:	56                   	push   %esi
f0103857:	53                   	push   %ebx
f0103858:	83 ec 3c             	sub    $0x3c,%esp
f010385b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010385e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103861:	c7 03 be 63 10 f0    	movl   $0xf01063be,(%ebx)
	info->eip_line = 0;
f0103867:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010386e:	c7 43 08 be 63 10 f0 	movl   $0xf01063be,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103875:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010387c:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010387f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103886:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010388c:	0f 87 a3 00 00 00    	ja     f0103935 <debuginfo_eip+0xe3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103892:	a1 00 00 20 00       	mov    0x200000,%eax
f0103897:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f010389a:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f01038a0:	8b 15 08 00 20 00    	mov    0x200008,%edx
f01038a6:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f01038a9:	a1 0c 00 20 00       	mov    0x20000c,%eax
f01038ae:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f01038b1:	e8 38 10 00 00       	call   f01048ee <cpunum>
f01038b6:	6a 04                	push   $0x4
f01038b8:	6a 10                	push   $0x10
f01038ba:	68 00 00 20 00       	push   $0x200000
f01038bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01038c2:	ff b0 28 90 22 f0    	pushl  -0xfdd6fd8(%eax)
f01038c8:	e8 f5 e9 ff ff       	call   f01022c2 <user_mem_check>
f01038cd:	83 c4 10             	add    $0x10,%esp
f01038d0:	85 c0                	test   %eax,%eax
f01038d2:	0f 88 27 02 00 00    	js     f0103aff <debuginfo_eip+0x2ad>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f01038d8:	e8 11 10 00 00       	call   f01048ee <cpunum>
f01038dd:	6a 04                	push   $0x4
f01038df:	89 f2                	mov    %esi,%edx
f01038e1:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01038e4:	29 ca                	sub    %ecx,%edx
f01038e6:	c1 fa 02             	sar    $0x2,%edx
f01038e9:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01038ef:	52                   	push   %edx
f01038f0:	51                   	push   %ecx
f01038f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01038f4:	ff b0 28 90 22 f0    	pushl  -0xfdd6fd8(%eax)
f01038fa:	e8 c3 e9 ff ff       	call   f01022c2 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
f01038ff:	83 c4 10             	add    $0x10,%esp
f0103902:	85 c0                	test   %eax,%eax
f0103904:	0f 88 fc 01 00 00    	js     f0103b06 <debuginfo_eip+0x2b4>
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
f010390a:	e8 df 0f 00 00       	call   f01048ee <cpunum>
f010390f:	6a 04                	push   $0x4
f0103911:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0103914:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0103917:	29 ca                	sub    %ecx,%edx
f0103919:	52                   	push   %edx
f010391a:	51                   	push   %ecx
f010391b:	6b c0 74             	imul   $0x74,%eax,%eax
f010391e:	ff b0 28 90 22 f0    	pushl  -0xfdd6fd8(%eax)
f0103924:	e8 99 e9 ff ff       	call   f01022c2 <user_mem_check>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
f0103929:	83 c4 10             	add    $0x10,%esp
f010392c:	85 c0                	test   %eax,%eax
f010392e:	79 1f                	jns    f010394f <debuginfo_eip+0xfd>
f0103930:	e9 d8 01 00 00       	jmp    f0103b0d <debuginfo_eip+0x2bb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103935:	c7 45 bc db 2d 11 f0 	movl   $0xf0112ddb,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010393c:	c7 45 b8 c9 f7 10 f0 	movl   $0xf010f7c9,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103943:	be c8 f7 10 f0       	mov    $0xf010f7c8,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103948:	c7 45 c0 94 68 10 f0 	movl   $0xf0106894,-0x40(%ebp)
		)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010394f:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103952:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0103955:	0f 83 b9 01 00 00    	jae    f0103b14 <debuginfo_eip+0x2c2>
f010395b:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010395f:	0f 85 b6 01 00 00    	jne    f0103b1b <debuginfo_eip+0x2c9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103965:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010396c:	2b 75 c0             	sub    -0x40(%ebp),%esi
f010396f:	c1 fe 02             	sar    $0x2,%esi
f0103972:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0103978:	83 e8 01             	sub    $0x1,%eax
f010397b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010397e:	83 ec 08             	sub    $0x8,%esp
f0103981:	57                   	push   %edi
f0103982:	6a 64                	push   $0x64
f0103984:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0103987:	89 d1                	mov    %edx,%ecx
f0103989:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010398c:	8b 75 c0             	mov    -0x40(%ebp),%esi
f010398f:	89 f0                	mov    %esi,%eax
f0103991:	e8 c6 fd ff ff       	call   f010375c <stab_binsearch>
	if (lfile == 0)
f0103996:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103999:	83 c4 10             	add    $0x10,%esp
f010399c:	85 c0                	test   %eax,%eax
f010399e:	0f 84 7e 01 00 00    	je     f0103b22 <debuginfo_eip+0x2d0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01039a4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01039a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01039aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01039ad:	83 ec 08             	sub    $0x8,%esp
f01039b0:	57                   	push   %edi
f01039b1:	6a 24                	push   $0x24
f01039b3:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01039b6:	89 d1                	mov    %edx,%ecx
f01039b8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01039bb:	89 f0                	mov    %esi,%eax
f01039bd:	e8 9a fd ff ff       	call   f010375c <stab_binsearch>

	if (lfun <= rfun) {
f01039c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01039c5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01039c8:	83 c4 10             	add    $0x10,%esp
f01039cb:	39 d0                	cmp    %edx,%eax
f01039cd:	7f 2e                	jg     f01039fd <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01039cf:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01039d2:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f01039d5:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f01039d8:	8b 36                	mov    (%esi),%esi
f01039da:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f01039dd:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f01039e0:	39 ce                	cmp    %ecx,%esi
f01039e2:	73 06                	jae    f01039ea <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01039e4:	03 75 b8             	add    -0x48(%ebp),%esi
f01039e7:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01039ea:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01039ed:	8b 4e 08             	mov    0x8(%esi),%ecx
f01039f0:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01039f3:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f01039f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01039f8:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01039fb:	eb 0f                	jmp    f0103a0c <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01039fd:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0103a00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a03:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103a06:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a09:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103a0c:	83 ec 08             	sub    $0x8,%esp
f0103a0f:	6a 3a                	push   $0x3a
f0103a11:	ff 73 08             	pushl  0x8(%ebx)
f0103a14:	e8 97 08 00 00       	call   f01042b0 <strfind>
f0103a19:	2b 43 08             	sub    0x8(%ebx),%eax
f0103a1c:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103a1f:	83 c4 08             	add    $0x8,%esp
f0103a22:	57                   	push   %edi
f0103a23:	6a 44                	push   $0x44
f0103a25:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103a28:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103a2b:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0103a2e:	89 f0                	mov    %esi,%eax
f0103a30:	e8 27 fd ff ff       	call   f010375c <stab_binsearch>
	if (lline == 0)
f0103a35:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a38:	83 c4 10             	add    $0x10,%esp
f0103a3b:	85 d2                	test   %edx,%edx
f0103a3d:	0f 84 e6 00 00 00    	je     f0103b29 <debuginfo_eip+0x2d7>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0103a43:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103a46:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103a49:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0103a4e:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103a51:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103a54:	89 d0                	mov    %edx,%eax
f0103a56:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103a59:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0103a5c:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0103a60:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103a63:	eb 0a                	jmp    f0103a6f <debuginfo_eip+0x21d>
f0103a65:	83 e8 01             	sub    $0x1,%eax
f0103a68:	83 ea 0c             	sub    $0xc,%edx
f0103a6b:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0103a6f:	39 c7                	cmp    %eax,%edi
f0103a71:	7e 05                	jle    f0103a78 <debuginfo_eip+0x226>
f0103a73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a76:	eb 47                	jmp    f0103abf <debuginfo_eip+0x26d>
	       && stabs[lline].n_type != N_SOL
f0103a78:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103a7c:	80 f9 84             	cmp    $0x84,%cl
f0103a7f:	75 0e                	jne    f0103a8f <debuginfo_eip+0x23d>
f0103a81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a84:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103a88:	74 1c                	je     f0103aa6 <debuginfo_eip+0x254>
f0103a8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103a8d:	eb 17                	jmp    f0103aa6 <debuginfo_eip+0x254>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103a8f:	80 f9 64             	cmp    $0x64,%cl
f0103a92:	75 d1                	jne    f0103a65 <debuginfo_eip+0x213>
f0103a94:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0103a98:	74 cb                	je     f0103a65 <debuginfo_eip+0x213>
f0103a9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a9d:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103aa1:	74 03                	je     f0103aa6 <debuginfo_eip+0x254>
f0103aa3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103aa6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103aa9:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103aac:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103aaf:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103ab2:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0103ab5:	29 f8                	sub    %edi,%eax
f0103ab7:	39 c2                	cmp    %eax,%edx
f0103ab9:	73 04                	jae    f0103abf <debuginfo_eip+0x26d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103abb:	01 fa                	add    %edi,%edx
f0103abd:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103abf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103ac2:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103ac5:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103aca:	39 f2                	cmp    %esi,%edx
f0103acc:	7d 67                	jge    f0103b35 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
f0103ace:	83 c2 01             	add    $0x1,%edx
f0103ad1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103ad4:	89 d0                	mov    %edx,%eax
f0103ad6:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103ad9:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103adc:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103adf:	eb 04                	jmp    f0103ae5 <debuginfo_eip+0x293>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103ae1:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103ae5:	39 c6                	cmp    %eax,%esi
f0103ae7:	7e 47                	jle    f0103b30 <debuginfo_eip+0x2de>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103ae9:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103aed:	83 c0 01             	add    $0x1,%eax
f0103af0:	83 c2 0c             	add    $0xc,%edx
f0103af3:	80 f9 a0             	cmp    $0xa0,%cl
f0103af6:	74 e9                	je     f0103ae1 <debuginfo_eip+0x28f>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103af8:	b8 00 00 00 00       	mov    $0x0,%eax
f0103afd:	eb 36                	jmp    f0103b35 <debuginfo_eip+0x2e3>
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ||
			user_mem_check(curenv, stabs, stab_end-stabs, PTE_U) < 0 ||
			user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0
		)
			return -1;
f0103aff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103b04:	eb 2f                	jmp    f0103b35 <debuginfo_eip+0x2e3>
f0103b06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103b0b:	eb 28                	jmp    f0103b35 <debuginfo_eip+0x2e3>
f0103b0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103b12:	eb 21                	jmp    f0103b35 <debuginfo_eip+0x2e3>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103b14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103b19:	eb 1a                	jmp    f0103b35 <debuginfo_eip+0x2e3>
f0103b1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103b20:	eb 13                	jmp    f0103b35 <debuginfo_eip+0x2e3>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103b22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103b27:	eb 0c                	jmp    f0103b35 <debuginfo_eip+0x2e3>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0103b29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103b2e:	eb 05                	jmp    f0103b35 <debuginfo_eip+0x2e3>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103b30:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103b35:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b38:	5b                   	pop    %ebx
f0103b39:	5e                   	pop    %esi
f0103b3a:	5f                   	pop    %edi
f0103b3b:	5d                   	pop    %ebp
f0103b3c:	c3                   	ret    

f0103b3d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103b3d:	55                   	push   %ebp
f0103b3e:	89 e5                	mov    %esp,%ebp
f0103b40:	57                   	push   %edi
f0103b41:	56                   	push   %esi
f0103b42:	53                   	push   %ebx
f0103b43:	83 ec 1c             	sub    $0x1c,%esp
f0103b46:	89 c7                	mov    %eax,%edi
f0103b48:	89 d6                	mov    %edx,%esi
f0103b4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b4d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b50:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b53:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103b56:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103b59:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103b5e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103b61:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103b64:	39 d3                	cmp    %edx,%ebx
f0103b66:	72 05                	jb     f0103b6d <printnum+0x30>
f0103b68:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103b6b:	77 45                	ja     f0103bb2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103b6d:	83 ec 0c             	sub    $0xc,%esp
f0103b70:	ff 75 18             	pushl  0x18(%ebp)
f0103b73:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b76:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103b79:	53                   	push   %ebx
f0103b7a:	ff 75 10             	pushl  0x10(%ebp)
f0103b7d:	83 ec 08             	sub    $0x8,%esp
f0103b80:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103b83:	ff 75 e0             	pushl  -0x20(%ebp)
f0103b86:	ff 75 dc             	pushl  -0x24(%ebp)
f0103b89:	ff 75 d8             	pushl  -0x28(%ebp)
f0103b8c:	e8 5f 11 00 00       	call   f0104cf0 <__udivdi3>
f0103b91:	83 c4 18             	add    $0x18,%esp
f0103b94:	52                   	push   %edx
f0103b95:	50                   	push   %eax
f0103b96:	89 f2                	mov    %esi,%edx
f0103b98:	89 f8                	mov    %edi,%eax
f0103b9a:	e8 9e ff ff ff       	call   f0103b3d <printnum>
f0103b9f:	83 c4 20             	add    $0x20,%esp
f0103ba2:	eb 18                	jmp    f0103bbc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103ba4:	83 ec 08             	sub    $0x8,%esp
f0103ba7:	56                   	push   %esi
f0103ba8:	ff 75 18             	pushl  0x18(%ebp)
f0103bab:	ff d7                	call   *%edi
f0103bad:	83 c4 10             	add    $0x10,%esp
f0103bb0:	eb 03                	jmp    f0103bb5 <printnum+0x78>
f0103bb2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103bb5:	83 eb 01             	sub    $0x1,%ebx
f0103bb8:	85 db                	test   %ebx,%ebx
f0103bba:	7f e8                	jg     f0103ba4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103bbc:	83 ec 08             	sub    $0x8,%esp
f0103bbf:	56                   	push   %esi
f0103bc0:	83 ec 04             	sub    $0x4,%esp
f0103bc3:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103bc6:	ff 75 e0             	pushl  -0x20(%ebp)
f0103bc9:	ff 75 dc             	pushl  -0x24(%ebp)
f0103bcc:	ff 75 d8             	pushl  -0x28(%ebp)
f0103bcf:	e8 4c 12 00 00       	call   f0104e20 <__umoddi3>
f0103bd4:	83 c4 14             	add    $0x14,%esp
f0103bd7:	0f be 80 c8 63 10 f0 	movsbl -0xfef9c38(%eax),%eax
f0103bde:	50                   	push   %eax
f0103bdf:	ff d7                	call   *%edi
}
f0103be1:	83 c4 10             	add    $0x10,%esp
f0103be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103be7:	5b                   	pop    %ebx
f0103be8:	5e                   	pop    %esi
f0103be9:	5f                   	pop    %edi
f0103bea:	5d                   	pop    %ebp
f0103beb:	c3                   	ret    

f0103bec <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103bec:	55                   	push   %ebp
f0103bed:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103bef:	83 fa 01             	cmp    $0x1,%edx
f0103bf2:	7e 0e                	jle    f0103c02 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103bf4:	8b 10                	mov    (%eax),%edx
f0103bf6:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103bf9:	89 08                	mov    %ecx,(%eax)
f0103bfb:	8b 02                	mov    (%edx),%eax
f0103bfd:	8b 52 04             	mov    0x4(%edx),%edx
f0103c00:	eb 22                	jmp    f0103c24 <getuint+0x38>
	else if (lflag)
f0103c02:	85 d2                	test   %edx,%edx
f0103c04:	74 10                	je     f0103c16 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103c06:	8b 10                	mov    (%eax),%edx
f0103c08:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103c0b:	89 08                	mov    %ecx,(%eax)
f0103c0d:	8b 02                	mov    (%edx),%eax
f0103c0f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103c14:	eb 0e                	jmp    f0103c24 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103c16:	8b 10                	mov    (%eax),%edx
f0103c18:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103c1b:	89 08                	mov    %ecx,(%eax)
f0103c1d:	8b 02                	mov    (%edx),%eax
f0103c1f:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103c24:	5d                   	pop    %ebp
f0103c25:	c3                   	ret    

f0103c26 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103c26:	55                   	push   %ebp
f0103c27:	89 e5                	mov    %esp,%ebp
f0103c29:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103c2c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103c30:	8b 10                	mov    (%eax),%edx
f0103c32:	3b 50 04             	cmp    0x4(%eax),%edx
f0103c35:	73 0a                	jae    f0103c41 <sprintputch+0x1b>
		*b->buf++ = ch;
f0103c37:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103c3a:	89 08                	mov    %ecx,(%eax)
f0103c3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c3f:	88 02                	mov    %al,(%edx)
}
f0103c41:	5d                   	pop    %ebp
f0103c42:	c3                   	ret    

f0103c43 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103c43:	55                   	push   %ebp
f0103c44:	89 e5                	mov    %esp,%ebp
f0103c46:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103c49:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103c4c:	50                   	push   %eax
f0103c4d:	ff 75 10             	pushl  0x10(%ebp)
f0103c50:	ff 75 0c             	pushl  0xc(%ebp)
f0103c53:	ff 75 08             	pushl  0x8(%ebp)
f0103c56:	e8 05 00 00 00       	call   f0103c60 <vprintfmt>
	va_end(ap);
}
f0103c5b:	83 c4 10             	add    $0x10,%esp
f0103c5e:	c9                   	leave  
f0103c5f:	c3                   	ret    

f0103c60 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103c60:	55                   	push   %ebp
f0103c61:	89 e5                	mov    %esp,%ebp
f0103c63:	57                   	push   %edi
f0103c64:	56                   	push   %esi
f0103c65:	53                   	push   %ebx
f0103c66:	83 ec 2c             	sub    $0x2c,%esp
f0103c69:	8b 75 08             	mov    0x8(%ebp),%esi
f0103c6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103c6f:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103c72:	eb 12                	jmp    f0103c86 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103c74:	85 c0                	test   %eax,%eax
f0103c76:	0f 84 89 03 00 00    	je     f0104005 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0103c7c:	83 ec 08             	sub    $0x8,%esp
f0103c7f:	53                   	push   %ebx
f0103c80:	50                   	push   %eax
f0103c81:	ff d6                	call   *%esi
f0103c83:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103c86:	83 c7 01             	add    $0x1,%edi
f0103c89:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103c8d:	83 f8 25             	cmp    $0x25,%eax
f0103c90:	75 e2                	jne    f0103c74 <vprintfmt+0x14>
f0103c92:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103c96:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103c9d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103ca4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103cab:	ba 00 00 00 00       	mov    $0x0,%edx
f0103cb0:	eb 07                	jmp    f0103cb9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cb2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103cb5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cb9:	8d 47 01             	lea    0x1(%edi),%eax
f0103cbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103cbf:	0f b6 07             	movzbl (%edi),%eax
f0103cc2:	0f b6 c8             	movzbl %al,%ecx
f0103cc5:	83 e8 23             	sub    $0x23,%eax
f0103cc8:	3c 55                	cmp    $0x55,%al
f0103cca:	0f 87 1a 03 00 00    	ja     f0103fea <vprintfmt+0x38a>
f0103cd0:	0f b6 c0             	movzbl %al,%eax
f0103cd3:	ff 24 85 80 64 10 f0 	jmp    *-0xfef9b80(,%eax,4)
f0103cda:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103cdd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103ce1:	eb d6                	jmp    f0103cb9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ce3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103ce6:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ceb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103cee:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103cf1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0103cf5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0103cf8:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0103cfb:	83 fa 09             	cmp    $0x9,%edx
f0103cfe:	77 39                	ja     f0103d39 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103d00:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103d03:	eb e9                	jmp    f0103cee <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103d05:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d08:	8d 48 04             	lea    0x4(%eax),%ecx
f0103d0b:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103d0e:	8b 00                	mov    (%eax),%eax
f0103d10:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103d16:	eb 27                	jmp    f0103d3f <vprintfmt+0xdf>
f0103d18:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d1b:	85 c0                	test   %eax,%eax
f0103d1d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103d22:	0f 49 c8             	cmovns %eax,%ecx
f0103d25:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103d2b:	eb 8c                	jmp    f0103cb9 <vprintfmt+0x59>
f0103d2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103d30:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103d37:	eb 80                	jmp    f0103cb9 <vprintfmt+0x59>
f0103d39:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103d3c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0103d3f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103d43:	0f 89 70 ff ff ff    	jns    f0103cb9 <vprintfmt+0x59>
				width = precision, precision = -1;
f0103d49:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103d4c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103d4f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103d56:	e9 5e ff ff ff       	jmp    f0103cb9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103d5b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103d61:	e9 53 ff ff ff       	jmp    f0103cb9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103d66:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d69:	8d 50 04             	lea    0x4(%eax),%edx
f0103d6c:	89 55 14             	mov    %edx,0x14(%ebp)
f0103d6f:	83 ec 08             	sub    $0x8,%esp
f0103d72:	53                   	push   %ebx
f0103d73:	ff 30                	pushl  (%eax)
f0103d75:	ff d6                	call   *%esi
			break;
f0103d77:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103d7d:	e9 04 ff ff ff       	jmp    f0103c86 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103d82:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d85:	8d 50 04             	lea    0x4(%eax),%edx
f0103d88:	89 55 14             	mov    %edx,0x14(%ebp)
f0103d8b:	8b 00                	mov    (%eax),%eax
f0103d8d:	99                   	cltd   
f0103d8e:	31 d0                	xor    %edx,%eax
f0103d90:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103d92:	83 f8 08             	cmp    $0x8,%eax
f0103d95:	7f 0b                	jg     f0103da2 <vprintfmt+0x142>
f0103d97:	8b 14 85 e0 65 10 f0 	mov    -0xfef9a20(,%eax,4),%edx
f0103d9e:	85 d2                	test   %edx,%edx
f0103da0:	75 18                	jne    f0103dba <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0103da2:	50                   	push   %eax
f0103da3:	68 e0 63 10 f0       	push   $0xf01063e0
f0103da8:	53                   	push   %ebx
f0103da9:	56                   	push   %esi
f0103daa:	e8 94 fe ff ff       	call   f0103c43 <printfmt>
f0103daf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103db2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103db5:	e9 cc fe ff ff       	jmp    f0103c86 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0103dba:	52                   	push   %edx
f0103dbb:	68 97 55 10 f0       	push   $0xf0105597
f0103dc0:	53                   	push   %ebx
f0103dc1:	56                   	push   %esi
f0103dc2:	e8 7c fe ff ff       	call   f0103c43 <printfmt>
f0103dc7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103dca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103dcd:	e9 b4 fe ff ff       	jmp    f0103c86 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103dd2:	8b 45 14             	mov    0x14(%ebp),%eax
f0103dd5:	8d 50 04             	lea    0x4(%eax),%edx
f0103dd8:	89 55 14             	mov    %edx,0x14(%ebp)
f0103ddb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103ddd:	85 ff                	test   %edi,%edi
f0103ddf:	b8 d9 63 10 f0       	mov    $0xf01063d9,%eax
f0103de4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103de7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103deb:	0f 8e 94 00 00 00    	jle    f0103e85 <vprintfmt+0x225>
f0103df1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103df5:	0f 84 98 00 00 00    	je     f0103e93 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103dfb:	83 ec 08             	sub    $0x8,%esp
f0103dfe:	ff 75 d0             	pushl  -0x30(%ebp)
f0103e01:	57                   	push   %edi
f0103e02:	e8 5f 03 00 00       	call   f0104166 <strnlen>
f0103e07:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103e0a:	29 c1                	sub    %eax,%ecx
f0103e0c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0103e0f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103e12:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103e16:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103e19:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103e1c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103e1e:	eb 0f                	jmp    f0103e2f <vprintfmt+0x1cf>
					putch(padc, putdat);
f0103e20:	83 ec 08             	sub    $0x8,%esp
f0103e23:	53                   	push   %ebx
f0103e24:	ff 75 e0             	pushl  -0x20(%ebp)
f0103e27:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103e29:	83 ef 01             	sub    $0x1,%edi
f0103e2c:	83 c4 10             	add    $0x10,%esp
f0103e2f:	85 ff                	test   %edi,%edi
f0103e31:	7f ed                	jg     f0103e20 <vprintfmt+0x1c0>
f0103e33:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103e36:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103e39:	85 c9                	test   %ecx,%ecx
f0103e3b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e40:	0f 49 c1             	cmovns %ecx,%eax
f0103e43:	29 c1                	sub    %eax,%ecx
f0103e45:	89 75 08             	mov    %esi,0x8(%ebp)
f0103e48:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103e4b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103e4e:	89 cb                	mov    %ecx,%ebx
f0103e50:	eb 4d                	jmp    f0103e9f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103e52:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103e56:	74 1b                	je     f0103e73 <vprintfmt+0x213>
f0103e58:	0f be c0             	movsbl %al,%eax
f0103e5b:	83 e8 20             	sub    $0x20,%eax
f0103e5e:	83 f8 5e             	cmp    $0x5e,%eax
f0103e61:	76 10                	jbe    f0103e73 <vprintfmt+0x213>
					putch('?', putdat);
f0103e63:	83 ec 08             	sub    $0x8,%esp
f0103e66:	ff 75 0c             	pushl  0xc(%ebp)
f0103e69:	6a 3f                	push   $0x3f
f0103e6b:	ff 55 08             	call   *0x8(%ebp)
f0103e6e:	83 c4 10             	add    $0x10,%esp
f0103e71:	eb 0d                	jmp    f0103e80 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0103e73:	83 ec 08             	sub    $0x8,%esp
f0103e76:	ff 75 0c             	pushl  0xc(%ebp)
f0103e79:	52                   	push   %edx
f0103e7a:	ff 55 08             	call   *0x8(%ebp)
f0103e7d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103e80:	83 eb 01             	sub    $0x1,%ebx
f0103e83:	eb 1a                	jmp    f0103e9f <vprintfmt+0x23f>
f0103e85:	89 75 08             	mov    %esi,0x8(%ebp)
f0103e88:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103e8b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103e8e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103e91:	eb 0c                	jmp    f0103e9f <vprintfmt+0x23f>
f0103e93:	89 75 08             	mov    %esi,0x8(%ebp)
f0103e96:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103e99:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103e9c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103e9f:	83 c7 01             	add    $0x1,%edi
f0103ea2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103ea6:	0f be d0             	movsbl %al,%edx
f0103ea9:	85 d2                	test   %edx,%edx
f0103eab:	74 23                	je     f0103ed0 <vprintfmt+0x270>
f0103ead:	85 f6                	test   %esi,%esi
f0103eaf:	78 a1                	js     f0103e52 <vprintfmt+0x1f2>
f0103eb1:	83 ee 01             	sub    $0x1,%esi
f0103eb4:	79 9c                	jns    f0103e52 <vprintfmt+0x1f2>
f0103eb6:	89 df                	mov    %ebx,%edi
f0103eb8:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ebb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103ebe:	eb 18                	jmp    f0103ed8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103ec0:	83 ec 08             	sub    $0x8,%esp
f0103ec3:	53                   	push   %ebx
f0103ec4:	6a 20                	push   $0x20
f0103ec6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103ec8:	83 ef 01             	sub    $0x1,%edi
f0103ecb:	83 c4 10             	add    $0x10,%esp
f0103ece:	eb 08                	jmp    f0103ed8 <vprintfmt+0x278>
f0103ed0:	89 df                	mov    %ebx,%edi
f0103ed2:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ed5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103ed8:	85 ff                	test   %edi,%edi
f0103eda:	7f e4                	jg     f0103ec0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103edc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103edf:	e9 a2 fd ff ff       	jmp    f0103c86 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103ee4:	83 fa 01             	cmp    $0x1,%edx
f0103ee7:	7e 16                	jle    f0103eff <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0103ee9:	8b 45 14             	mov    0x14(%ebp),%eax
f0103eec:	8d 50 08             	lea    0x8(%eax),%edx
f0103eef:	89 55 14             	mov    %edx,0x14(%ebp)
f0103ef2:	8b 50 04             	mov    0x4(%eax),%edx
f0103ef5:	8b 00                	mov    (%eax),%eax
f0103ef7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103efa:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103efd:	eb 32                	jmp    f0103f31 <vprintfmt+0x2d1>
	else if (lflag)
f0103eff:	85 d2                	test   %edx,%edx
f0103f01:	74 18                	je     f0103f1b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0103f03:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f06:	8d 50 04             	lea    0x4(%eax),%edx
f0103f09:	89 55 14             	mov    %edx,0x14(%ebp)
f0103f0c:	8b 00                	mov    (%eax),%eax
f0103f0e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103f11:	89 c1                	mov    %eax,%ecx
f0103f13:	c1 f9 1f             	sar    $0x1f,%ecx
f0103f16:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103f19:	eb 16                	jmp    f0103f31 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0103f1b:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f1e:	8d 50 04             	lea    0x4(%eax),%edx
f0103f21:	89 55 14             	mov    %edx,0x14(%ebp)
f0103f24:	8b 00                	mov    (%eax),%eax
f0103f26:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103f29:	89 c1                	mov    %eax,%ecx
f0103f2b:	c1 f9 1f             	sar    $0x1f,%ecx
f0103f2e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103f31:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103f34:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103f37:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103f3c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103f40:	79 74                	jns    f0103fb6 <vprintfmt+0x356>
				putch('-', putdat);
f0103f42:	83 ec 08             	sub    $0x8,%esp
f0103f45:	53                   	push   %ebx
f0103f46:	6a 2d                	push   $0x2d
f0103f48:	ff d6                	call   *%esi
				num = -(long long) num;
f0103f4a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103f4d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103f50:	f7 d8                	neg    %eax
f0103f52:	83 d2 00             	adc    $0x0,%edx
f0103f55:	f7 da                	neg    %edx
f0103f57:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103f5a:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103f5f:	eb 55                	jmp    f0103fb6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103f61:	8d 45 14             	lea    0x14(%ebp),%eax
f0103f64:	e8 83 fc ff ff       	call   f0103bec <getuint>
			base = 10;
f0103f69:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0103f6e:	eb 46                	jmp    f0103fb6 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0103f70:	8d 45 14             	lea    0x14(%ebp),%eax
f0103f73:	e8 74 fc ff ff       	call   f0103bec <getuint>
			base = 8;
f0103f78:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0103f7d:	eb 37                	jmp    f0103fb6 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0103f7f:	83 ec 08             	sub    $0x8,%esp
f0103f82:	53                   	push   %ebx
f0103f83:	6a 30                	push   $0x30
f0103f85:	ff d6                	call   *%esi
			putch('x', putdat);
f0103f87:	83 c4 08             	add    $0x8,%esp
f0103f8a:	53                   	push   %ebx
f0103f8b:	6a 78                	push   $0x78
f0103f8d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103f8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f92:	8d 50 04             	lea    0x4(%eax),%edx
f0103f95:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103f98:	8b 00                	mov    (%eax),%eax
f0103f9a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103f9f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103fa2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0103fa7:	eb 0d                	jmp    f0103fb6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103fa9:	8d 45 14             	lea    0x14(%ebp),%eax
f0103fac:	e8 3b fc ff ff       	call   f0103bec <getuint>
			base = 16;
f0103fb1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103fb6:	83 ec 0c             	sub    $0xc,%esp
f0103fb9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103fbd:	57                   	push   %edi
f0103fbe:	ff 75 e0             	pushl  -0x20(%ebp)
f0103fc1:	51                   	push   %ecx
f0103fc2:	52                   	push   %edx
f0103fc3:	50                   	push   %eax
f0103fc4:	89 da                	mov    %ebx,%edx
f0103fc6:	89 f0                	mov    %esi,%eax
f0103fc8:	e8 70 fb ff ff       	call   f0103b3d <printnum>
			break;
f0103fcd:	83 c4 20             	add    $0x20,%esp
f0103fd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103fd3:	e9 ae fc ff ff       	jmp    f0103c86 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103fd8:	83 ec 08             	sub    $0x8,%esp
f0103fdb:	53                   	push   %ebx
f0103fdc:	51                   	push   %ecx
f0103fdd:	ff d6                	call   *%esi
			break;
f0103fdf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103fe2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103fe5:	e9 9c fc ff ff       	jmp    f0103c86 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103fea:	83 ec 08             	sub    $0x8,%esp
f0103fed:	53                   	push   %ebx
f0103fee:	6a 25                	push   $0x25
f0103ff0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103ff2:	83 c4 10             	add    $0x10,%esp
f0103ff5:	eb 03                	jmp    f0103ffa <vprintfmt+0x39a>
f0103ff7:	83 ef 01             	sub    $0x1,%edi
f0103ffa:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103ffe:	75 f7                	jne    f0103ff7 <vprintfmt+0x397>
f0104000:	e9 81 fc ff ff       	jmp    f0103c86 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0104005:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104008:	5b                   	pop    %ebx
f0104009:	5e                   	pop    %esi
f010400a:	5f                   	pop    %edi
f010400b:	5d                   	pop    %ebp
f010400c:	c3                   	ret    

f010400d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010400d:	55                   	push   %ebp
f010400e:	89 e5                	mov    %esp,%ebp
f0104010:	83 ec 18             	sub    $0x18,%esp
f0104013:	8b 45 08             	mov    0x8(%ebp),%eax
f0104016:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104019:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010401c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104020:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104023:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010402a:	85 c0                	test   %eax,%eax
f010402c:	74 26                	je     f0104054 <vsnprintf+0x47>
f010402e:	85 d2                	test   %edx,%edx
f0104030:	7e 22                	jle    f0104054 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104032:	ff 75 14             	pushl  0x14(%ebp)
f0104035:	ff 75 10             	pushl  0x10(%ebp)
f0104038:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010403b:	50                   	push   %eax
f010403c:	68 26 3c 10 f0       	push   $0xf0103c26
f0104041:	e8 1a fc ff ff       	call   f0103c60 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104046:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104049:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010404c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010404f:	83 c4 10             	add    $0x10,%esp
f0104052:	eb 05                	jmp    f0104059 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104054:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104059:	c9                   	leave  
f010405a:	c3                   	ret    

f010405b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010405b:	55                   	push   %ebp
f010405c:	89 e5                	mov    %esp,%ebp
f010405e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104061:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104064:	50                   	push   %eax
f0104065:	ff 75 10             	pushl  0x10(%ebp)
f0104068:	ff 75 0c             	pushl  0xc(%ebp)
f010406b:	ff 75 08             	pushl  0x8(%ebp)
f010406e:	e8 9a ff ff ff       	call   f010400d <vsnprintf>
	va_end(ap);

	return rc;
}
f0104073:	c9                   	leave  
f0104074:	c3                   	ret    

f0104075 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104075:	55                   	push   %ebp
f0104076:	89 e5                	mov    %esp,%ebp
f0104078:	57                   	push   %edi
f0104079:	56                   	push   %esi
f010407a:	53                   	push   %ebx
f010407b:	83 ec 0c             	sub    $0xc,%esp
f010407e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104081:	85 c0                	test   %eax,%eax
f0104083:	74 11                	je     f0104096 <readline+0x21>
		cprintf("%s", prompt);
f0104085:	83 ec 08             	sub    $0x8,%esp
f0104088:	50                   	push   %eax
f0104089:	68 97 55 10 f0       	push   $0xf0105597
f010408e:	e8 49 ec ff ff       	call   f0102cdc <cprintf>
f0104093:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104096:	83 ec 0c             	sub    $0xc,%esp
f0104099:	6a 00                	push   $0x0
f010409b:	e8 b6 c6 ff ff       	call   f0100756 <iscons>
f01040a0:	89 c7                	mov    %eax,%edi
f01040a2:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01040a5:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01040aa:	e8 96 c6 ff ff       	call   f0100745 <getchar>
f01040af:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01040b1:	85 c0                	test   %eax,%eax
f01040b3:	79 18                	jns    f01040cd <readline+0x58>
			cprintf("read error: %e\n", c);
f01040b5:	83 ec 08             	sub    $0x8,%esp
f01040b8:	50                   	push   %eax
f01040b9:	68 04 66 10 f0       	push   $0xf0106604
f01040be:	e8 19 ec ff ff       	call   f0102cdc <cprintf>
			return NULL;
f01040c3:	83 c4 10             	add    $0x10,%esp
f01040c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01040cb:	eb 79                	jmp    f0104146 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01040cd:	83 f8 08             	cmp    $0x8,%eax
f01040d0:	0f 94 c2             	sete   %dl
f01040d3:	83 f8 7f             	cmp    $0x7f,%eax
f01040d6:	0f 94 c0             	sete   %al
f01040d9:	08 c2                	or     %al,%dl
f01040db:	74 1a                	je     f01040f7 <readline+0x82>
f01040dd:	85 f6                	test   %esi,%esi
f01040df:	7e 16                	jle    f01040f7 <readline+0x82>
			if (echoing)
f01040e1:	85 ff                	test   %edi,%edi
f01040e3:	74 0d                	je     f01040f2 <readline+0x7d>
				cputchar('\b');
f01040e5:	83 ec 0c             	sub    $0xc,%esp
f01040e8:	6a 08                	push   $0x8
f01040ea:	e8 46 c6 ff ff       	call   f0100735 <cputchar>
f01040ef:	83 c4 10             	add    $0x10,%esp
			i--;
f01040f2:	83 ee 01             	sub    $0x1,%esi
f01040f5:	eb b3                	jmp    f01040aa <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01040f7:	83 fb 1f             	cmp    $0x1f,%ebx
f01040fa:	7e 23                	jle    f010411f <readline+0xaa>
f01040fc:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104102:	7f 1b                	jg     f010411f <readline+0xaa>
			if (echoing)
f0104104:	85 ff                	test   %edi,%edi
f0104106:	74 0c                	je     f0104114 <readline+0x9f>
				cputchar(c);
f0104108:	83 ec 0c             	sub    $0xc,%esp
f010410b:	53                   	push   %ebx
f010410c:	e8 24 c6 ff ff       	call   f0100735 <cputchar>
f0104111:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104114:	88 9e 00 8b 22 f0    	mov    %bl,-0xfdd7500(%esi)
f010411a:	8d 76 01             	lea    0x1(%esi),%esi
f010411d:	eb 8b                	jmp    f01040aa <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010411f:	83 fb 0a             	cmp    $0xa,%ebx
f0104122:	74 05                	je     f0104129 <readline+0xb4>
f0104124:	83 fb 0d             	cmp    $0xd,%ebx
f0104127:	75 81                	jne    f01040aa <readline+0x35>
			if (echoing)
f0104129:	85 ff                	test   %edi,%edi
f010412b:	74 0d                	je     f010413a <readline+0xc5>
				cputchar('\n');
f010412d:	83 ec 0c             	sub    $0xc,%esp
f0104130:	6a 0a                	push   $0xa
f0104132:	e8 fe c5 ff ff       	call   f0100735 <cputchar>
f0104137:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010413a:	c6 86 00 8b 22 f0 00 	movb   $0x0,-0xfdd7500(%esi)
			return buf;
f0104141:	b8 00 8b 22 f0       	mov    $0xf0228b00,%eax
		}
	}
}
f0104146:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104149:	5b                   	pop    %ebx
f010414a:	5e                   	pop    %esi
f010414b:	5f                   	pop    %edi
f010414c:	5d                   	pop    %ebp
f010414d:	c3                   	ret    

f010414e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010414e:	55                   	push   %ebp
f010414f:	89 e5                	mov    %esp,%ebp
f0104151:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104154:	b8 00 00 00 00       	mov    $0x0,%eax
f0104159:	eb 03                	jmp    f010415e <strlen+0x10>
		n++;
f010415b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010415e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104162:	75 f7                	jne    f010415b <strlen+0xd>
		n++;
	return n;
}
f0104164:	5d                   	pop    %ebp
f0104165:	c3                   	ret    

f0104166 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104166:	55                   	push   %ebp
f0104167:	89 e5                	mov    %esp,%ebp
f0104169:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010416c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010416f:	ba 00 00 00 00       	mov    $0x0,%edx
f0104174:	eb 03                	jmp    f0104179 <strnlen+0x13>
		n++;
f0104176:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104179:	39 c2                	cmp    %eax,%edx
f010417b:	74 08                	je     f0104185 <strnlen+0x1f>
f010417d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0104181:	75 f3                	jne    f0104176 <strnlen+0x10>
f0104183:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0104185:	5d                   	pop    %ebp
f0104186:	c3                   	ret    

f0104187 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104187:	55                   	push   %ebp
f0104188:	89 e5                	mov    %esp,%ebp
f010418a:	53                   	push   %ebx
f010418b:	8b 45 08             	mov    0x8(%ebp),%eax
f010418e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104191:	89 c2                	mov    %eax,%edx
f0104193:	83 c2 01             	add    $0x1,%edx
f0104196:	83 c1 01             	add    $0x1,%ecx
f0104199:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010419d:	88 5a ff             	mov    %bl,-0x1(%edx)
f01041a0:	84 db                	test   %bl,%bl
f01041a2:	75 ef                	jne    f0104193 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01041a4:	5b                   	pop    %ebx
f01041a5:	5d                   	pop    %ebp
f01041a6:	c3                   	ret    

f01041a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01041a7:	55                   	push   %ebp
f01041a8:	89 e5                	mov    %esp,%ebp
f01041aa:	53                   	push   %ebx
f01041ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01041ae:	53                   	push   %ebx
f01041af:	e8 9a ff ff ff       	call   f010414e <strlen>
f01041b4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01041b7:	ff 75 0c             	pushl  0xc(%ebp)
f01041ba:	01 d8                	add    %ebx,%eax
f01041bc:	50                   	push   %eax
f01041bd:	e8 c5 ff ff ff       	call   f0104187 <strcpy>
	return dst;
}
f01041c2:	89 d8                	mov    %ebx,%eax
f01041c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01041c7:	c9                   	leave  
f01041c8:	c3                   	ret    

f01041c9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01041c9:	55                   	push   %ebp
f01041ca:	89 e5                	mov    %esp,%ebp
f01041cc:	56                   	push   %esi
f01041cd:	53                   	push   %ebx
f01041ce:	8b 75 08             	mov    0x8(%ebp),%esi
f01041d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01041d4:	89 f3                	mov    %esi,%ebx
f01041d6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01041d9:	89 f2                	mov    %esi,%edx
f01041db:	eb 0f                	jmp    f01041ec <strncpy+0x23>
		*dst++ = *src;
f01041dd:	83 c2 01             	add    $0x1,%edx
f01041e0:	0f b6 01             	movzbl (%ecx),%eax
f01041e3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01041e6:	80 39 01             	cmpb   $0x1,(%ecx)
f01041e9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01041ec:	39 da                	cmp    %ebx,%edx
f01041ee:	75 ed                	jne    f01041dd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01041f0:	89 f0                	mov    %esi,%eax
f01041f2:	5b                   	pop    %ebx
f01041f3:	5e                   	pop    %esi
f01041f4:	5d                   	pop    %ebp
f01041f5:	c3                   	ret    

f01041f6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01041f6:	55                   	push   %ebp
f01041f7:	89 e5                	mov    %esp,%ebp
f01041f9:	56                   	push   %esi
f01041fa:	53                   	push   %ebx
f01041fb:	8b 75 08             	mov    0x8(%ebp),%esi
f01041fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104201:	8b 55 10             	mov    0x10(%ebp),%edx
f0104204:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104206:	85 d2                	test   %edx,%edx
f0104208:	74 21                	je     f010422b <strlcpy+0x35>
f010420a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010420e:	89 f2                	mov    %esi,%edx
f0104210:	eb 09                	jmp    f010421b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104212:	83 c2 01             	add    $0x1,%edx
f0104215:	83 c1 01             	add    $0x1,%ecx
f0104218:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010421b:	39 c2                	cmp    %eax,%edx
f010421d:	74 09                	je     f0104228 <strlcpy+0x32>
f010421f:	0f b6 19             	movzbl (%ecx),%ebx
f0104222:	84 db                	test   %bl,%bl
f0104224:	75 ec                	jne    f0104212 <strlcpy+0x1c>
f0104226:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104228:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010422b:	29 f0                	sub    %esi,%eax
}
f010422d:	5b                   	pop    %ebx
f010422e:	5e                   	pop    %esi
f010422f:	5d                   	pop    %ebp
f0104230:	c3                   	ret    

f0104231 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104231:	55                   	push   %ebp
f0104232:	89 e5                	mov    %esp,%ebp
f0104234:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104237:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010423a:	eb 06                	jmp    f0104242 <strcmp+0x11>
		p++, q++;
f010423c:	83 c1 01             	add    $0x1,%ecx
f010423f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104242:	0f b6 01             	movzbl (%ecx),%eax
f0104245:	84 c0                	test   %al,%al
f0104247:	74 04                	je     f010424d <strcmp+0x1c>
f0104249:	3a 02                	cmp    (%edx),%al
f010424b:	74 ef                	je     f010423c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010424d:	0f b6 c0             	movzbl %al,%eax
f0104250:	0f b6 12             	movzbl (%edx),%edx
f0104253:	29 d0                	sub    %edx,%eax
}
f0104255:	5d                   	pop    %ebp
f0104256:	c3                   	ret    

f0104257 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104257:	55                   	push   %ebp
f0104258:	89 e5                	mov    %esp,%ebp
f010425a:	53                   	push   %ebx
f010425b:	8b 45 08             	mov    0x8(%ebp),%eax
f010425e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104261:	89 c3                	mov    %eax,%ebx
f0104263:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104266:	eb 06                	jmp    f010426e <strncmp+0x17>
		n--, p++, q++;
f0104268:	83 c0 01             	add    $0x1,%eax
f010426b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010426e:	39 d8                	cmp    %ebx,%eax
f0104270:	74 15                	je     f0104287 <strncmp+0x30>
f0104272:	0f b6 08             	movzbl (%eax),%ecx
f0104275:	84 c9                	test   %cl,%cl
f0104277:	74 04                	je     f010427d <strncmp+0x26>
f0104279:	3a 0a                	cmp    (%edx),%cl
f010427b:	74 eb                	je     f0104268 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010427d:	0f b6 00             	movzbl (%eax),%eax
f0104280:	0f b6 12             	movzbl (%edx),%edx
f0104283:	29 d0                	sub    %edx,%eax
f0104285:	eb 05                	jmp    f010428c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104287:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010428c:	5b                   	pop    %ebx
f010428d:	5d                   	pop    %ebp
f010428e:	c3                   	ret    

f010428f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010428f:	55                   	push   %ebp
f0104290:	89 e5                	mov    %esp,%ebp
f0104292:	8b 45 08             	mov    0x8(%ebp),%eax
f0104295:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104299:	eb 07                	jmp    f01042a2 <strchr+0x13>
		if (*s == c)
f010429b:	38 ca                	cmp    %cl,%dl
f010429d:	74 0f                	je     f01042ae <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010429f:	83 c0 01             	add    $0x1,%eax
f01042a2:	0f b6 10             	movzbl (%eax),%edx
f01042a5:	84 d2                	test   %dl,%dl
f01042a7:	75 f2                	jne    f010429b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01042a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01042ae:	5d                   	pop    %ebp
f01042af:	c3                   	ret    

f01042b0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01042b0:	55                   	push   %ebp
f01042b1:	89 e5                	mov    %esp,%ebp
f01042b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01042b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01042ba:	eb 03                	jmp    f01042bf <strfind+0xf>
f01042bc:	83 c0 01             	add    $0x1,%eax
f01042bf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01042c2:	38 ca                	cmp    %cl,%dl
f01042c4:	74 04                	je     f01042ca <strfind+0x1a>
f01042c6:	84 d2                	test   %dl,%dl
f01042c8:	75 f2                	jne    f01042bc <strfind+0xc>
			break;
	return (char *) s;
}
f01042ca:	5d                   	pop    %ebp
f01042cb:	c3                   	ret    

f01042cc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01042cc:	55                   	push   %ebp
f01042cd:	89 e5                	mov    %esp,%ebp
f01042cf:	57                   	push   %edi
f01042d0:	56                   	push   %esi
f01042d1:	53                   	push   %ebx
f01042d2:	8b 7d 08             	mov    0x8(%ebp),%edi
f01042d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01042d8:	85 c9                	test   %ecx,%ecx
f01042da:	74 36                	je     f0104312 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01042dc:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01042e2:	75 28                	jne    f010430c <memset+0x40>
f01042e4:	f6 c1 03             	test   $0x3,%cl
f01042e7:	75 23                	jne    f010430c <memset+0x40>
		c &= 0xFF;
f01042e9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01042ed:	89 d3                	mov    %edx,%ebx
f01042ef:	c1 e3 08             	shl    $0x8,%ebx
f01042f2:	89 d6                	mov    %edx,%esi
f01042f4:	c1 e6 18             	shl    $0x18,%esi
f01042f7:	89 d0                	mov    %edx,%eax
f01042f9:	c1 e0 10             	shl    $0x10,%eax
f01042fc:	09 f0                	or     %esi,%eax
f01042fe:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0104300:	89 d8                	mov    %ebx,%eax
f0104302:	09 d0                	or     %edx,%eax
f0104304:	c1 e9 02             	shr    $0x2,%ecx
f0104307:	fc                   	cld    
f0104308:	f3 ab                	rep stos %eax,%es:(%edi)
f010430a:	eb 06                	jmp    f0104312 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010430c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010430f:	fc                   	cld    
f0104310:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104312:	89 f8                	mov    %edi,%eax
f0104314:	5b                   	pop    %ebx
f0104315:	5e                   	pop    %esi
f0104316:	5f                   	pop    %edi
f0104317:	5d                   	pop    %ebp
f0104318:	c3                   	ret    

f0104319 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104319:	55                   	push   %ebp
f010431a:	89 e5                	mov    %esp,%ebp
f010431c:	57                   	push   %edi
f010431d:	56                   	push   %esi
f010431e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104321:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104324:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104327:	39 c6                	cmp    %eax,%esi
f0104329:	73 35                	jae    f0104360 <memmove+0x47>
f010432b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010432e:	39 d0                	cmp    %edx,%eax
f0104330:	73 2e                	jae    f0104360 <memmove+0x47>
		s += n;
		d += n;
f0104332:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104335:	89 d6                	mov    %edx,%esi
f0104337:	09 fe                	or     %edi,%esi
f0104339:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010433f:	75 13                	jne    f0104354 <memmove+0x3b>
f0104341:	f6 c1 03             	test   $0x3,%cl
f0104344:	75 0e                	jne    f0104354 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0104346:	83 ef 04             	sub    $0x4,%edi
f0104349:	8d 72 fc             	lea    -0x4(%edx),%esi
f010434c:	c1 e9 02             	shr    $0x2,%ecx
f010434f:	fd                   	std    
f0104350:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104352:	eb 09                	jmp    f010435d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104354:	83 ef 01             	sub    $0x1,%edi
f0104357:	8d 72 ff             	lea    -0x1(%edx),%esi
f010435a:	fd                   	std    
f010435b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010435d:	fc                   	cld    
f010435e:	eb 1d                	jmp    f010437d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104360:	89 f2                	mov    %esi,%edx
f0104362:	09 c2                	or     %eax,%edx
f0104364:	f6 c2 03             	test   $0x3,%dl
f0104367:	75 0f                	jne    f0104378 <memmove+0x5f>
f0104369:	f6 c1 03             	test   $0x3,%cl
f010436c:	75 0a                	jne    f0104378 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010436e:	c1 e9 02             	shr    $0x2,%ecx
f0104371:	89 c7                	mov    %eax,%edi
f0104373:	fc                   	cld    
f0104374:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104376:	eb 05                	jmp    f010437d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104378:	89 c7                	mov    %eax,%edi
f010437a:	fc                   	cld    
f010437b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010437d:	5e                   	pop    %esi
f010437e:	5f                   	pop    %edi
f010437f:	5d                   	pop    %ebp
f0104380:	c3                   	ret    

f0104381 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104381:	55                   	push   %ebp
f0104382:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104384:	ff 75 10             	pushl  0x10(%ebp)
f0104387:	ff 75 0c             	pushl  0xc(%ebp)
f010438a:	ff 75 08             	pushl  0x8(%ebp)
f010438d:	e8 87 ff ff ff       	call   f0104319 <memmove>
}
f0104392:	c9                   	leave  
f0104393:	c3                   	ret    

f0104394 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104394:	55                   	push   %ebp
f0104395:	89 e5                	mov    %esp,%ebp
f0104397:	56                   	push   %esi
f0104398:	53                   	push   %ebx
f0104399:	8b 45 08             	mov    0x8(%ebp),%eax
f010439c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010439f:	89 c6                	mov    %eax,%esi
f01043a1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01043a4:	eb 1a                	jmp    f01043c0 <memcmp+0x2c>
		if (*s1 != *s2)
f01043a6:	0f b6 08             	movzbl (%eax),%ecx
f01043a9:	0f b6 1a             	movzbl (%edx),%ebx
f01043ac:	38 d9                	cmp    %bl,%cl
f01043ae:	74 0a                	je     f01043ba <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01043b0:	0f b6 c1             	movzbl %cl,%eax
f01043b3:	0f b6 db             	movzbl %bl,%ebx
f01043b6:	29 d8                	sub    %ebx,%eax
f01043b8:	eb 0f                	jmp    f01043c9 <memcmp+0x35>
		s1++, s2++;
f01043ba:	83 c0 01             	add    $0x1,%eax
f01043bd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01043c0:	39 f0                	cmp    %esi,%eax
f01043c2:	75 e2                	jne    f01043a6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01043c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01043c9:	5b                   	pop    %ebx
f01043ca:	5e                   	pop    %esi
f01043cb:	5d                   	pop    %ebp
f01043cc:	c3                   	ret    

f01043cd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01043cd:	55                   	push   %ebp
f01043ce:	89 e5                	mov    %esp,%ebp
f01043d0:	53                   	push   %ebx
f01043d1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01043d4:	89 c1                	mov    %eax,%ecx
f01043d6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01043d9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01043dd:	eb 0a                	jmp    f01043e9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01043df:	0f b6 10             	movzbl (%eax),%edx
f01043e2:	39 da                	cmp    %ebx,%edx
f01043e4:	74 07                	je     f01043ed <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01043e6:	83 c0 01             	add    $0x1,%eax
f01043e9:	39 c8                	cmp    %ecx,%eax
f01043eb:	72 f2                	jb     f01043df <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01043ed:	5b                   	pop    %ebx
f01043ee:	5d                   	pop    %ebp
f01043ef:	c3                   	ret    

f01043f0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01043f0:	55                   	push   %ebp
f01043f1:	89 e5                	mov    %esp,%ebp
f01043f3:	57                   	push   %edi
f01043f4:	56                   	push   %esi
f01043f5:	53                   	push   %ebx
f01043f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01043f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01043fc:	eb 03                	jmp    f0104401 <strtol+0x11>
		s++;
f01043fe:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104401:	0f b6 01             	movzbl (%ecx),%eax
f0104404:	3c 20                	cmp    $0x20,%al
f0104406:	74 f6                	je     f01043fe <strtol+0xe>
f0104408:	3c 09                	cmp    $0x9,%al
f010440a:	74 f2                	je     f01043fe <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010440c:	3c 2b                	cmp    $0x2b,%al
f010440e:	75 0a                	jne    f010441a <strtol+0x2a>
		s++;
f0104410:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104413:	bf 00 00 00 00       	mov    $0x0,%edi
f0104418:	eb 11                	jmp    f010442b <strtol+0x3b>
f010441a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010441f:	3c 2d                	cmp    $0x2d,%al
f0104421:	75 08                	jne    f010442b <strtol+0x3b>
		s++, neg = 1;
f0104423:	83 c1 01             	add    $0x1,%ecx
f0104426:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010442b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104431:	75 15                	jne    f0104448 <strtol+0x58>
f0104433:	80 39 30             	cmpb   $0x30,(%ecx)
f0104436:	75 10                	jne    f0104448 <strtol+0x58>
f0104438:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010443c:	75 7c                	jne    f01044ba <strtol+0xca>
		s += 2, base = 16;
f010443e:	83 c1 02             	add    $0x2,%ecx
f0104441:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104446:	eb 16                	jmp    f010445e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0104448:	85 db                	test   %ebx,%ebx
f010444a:	75 12                	jne    f010445e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010444c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104451:	80 39 30             	cmpb   $0x30,(%ecx)
f0104454:	75 08                	jne    f010445e <strtol+0x6e>
		s++, base = 8;
f0104456:	83 c1 01             	add    $0x1,%ecx
f0104459:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010445e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104463:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104466:	0f b6 11             	movzbl (%ecx),%edx
f0104469:	8d 72 d0             	lea    -0x30(%edx),%esi
f010446c:	89 f3                	mov    %esi,%ebx
f010446e:	80 fb 09             	cmp    $0x9,%bl
f0104471:	77 08                	ja     f010447b <strtol+0x8b>
			dig = *s - '0';
f0104473:	0f be d2             	movsbl %dl,%edx
f0104476:	83 ea 30             	sub    $0x30,%edx
f0104479:	eb 22                	jmp    f010449d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010447b:	8d 72 9f             	lea    -0x61(%edx),%esi
f010447e:	89 f3                	mov    %esi,%ebx
f0104480:	80 fb 19             	cmp    $0x19,%bl
f0104483:	77 08                	ja     f010448d <strtol+0x9d>
			dig = *s - 'a' + 10;
f0104485:	0f be d2             	movsbl %dl,%edx
f0104488:	83 ea 57             	sub    $0x57,%edx
f010448b:	eb 10                	jmp    f010449d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010448d:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104490:	89 f3                	mov    %esi,%ebx
f0104492:	80 fb 19             	cmp    $0x19,%bl
f0104495:	77 16                	ja     f01044ad <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104497:	0f be d2             	movsbl %dl,%edx
f010449a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010449d:	3b 55 10             	cmp    0x10(%ebp),%edx
f01044a0:	7d 0b                	jge    f01044ad <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01044a2:	83 c1 01             	add    $0x1,%ecx
f01044a5:	0f af 45 10          	imul   0x10(%ebp),%eax
f01044a9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01044ab:	eb b9                	jmp    f0104466 <strtol+0x76>

	if (endptr)
f01044ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01044b1:	74 0d                	je     f01044c0 <strtol+0xd0>
		*endptr = (char *) s;
f01044b3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01044b6:	89 0e                	mov    %ecx,(%esi)
f01044b8:	eb 06                	jmp    f01044c0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01044ba:	85 db                	test   %ebx,%ebx
f01044bc:	74 98                	je     f0104456 <strtol+0x66>
f01044be:	eb 9e                	jmp    f010445e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01044c0:	89 c2                	mov    %eax,%edx
f01044c2:	f7 da                	neg    %edx
f01044c4:	85 ff                	test   %edi,%edi
f01044c6:	0f 45 c2             	cmovne %edx,%eax
}
f01044c9:	5b                   	pop    %ebx
f01044ca:	5e                   	pop    %esi
f01044cb:	5f                   	pop    %edi
f01044cc:	5d                   	pop    %ebp
f01044cd:	c3                   	ret    
f01044ce:	66 90                	xchg   %ax,%ax

f01044d0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01044d0:	fa                   	cli    

	xorw    %ax, %ax
f01044d1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01044d3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01044d5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01044d7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01044d9:	0f 01 16             	lgdtl  (%esi)
f01044dc:	74 70                	je     f010454e <mpsearch1+0x3>
	movl    %cr0, %eax
f01044de:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01044e1:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01044e5:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01044e8:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01044ee:	08 00                	or     %al,(%eax)

f01044f0 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01044f0:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01044f4:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01044f6:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01044f8:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01044fa:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01044fe:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0104500:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0104502:	b8 00 b0 11 00       	mov    $0x11b000,%eax
	movl    %eax, %cr3
f0104507:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010450a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f010450d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0104512:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0104515:	8b 25 04 8f 22 f0    	mov    0xf0228f04,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010451b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0104520:	b8 90 01 10 f0       	mov    $0xf0100190,%eax
	call    *%eax
f0104525:	ff d0                	call   *%eax

f0104527 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0104527:	eb fe                	jmp    f0104527 <spin>
f0104529:	8d 76 00             	lea    0x0(%esi),%esi

f010452c <gdt>:
	...
f0104534:	ff                   	(bad)  
f0104535:	ff 00                	incl   (%eax)
f0104537:	00 00                	add    %al,(%eax)
f0104539:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0104540:	00                   	.byte 0x0
f0104541:	92                   	xchg   %eax,%edx
f0104542:	cf                   	iret   
	...

f0104544 <gdtdesc>:
f0104544:	17                   	pop    %ss
f0104545:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010454a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010454a:	90                   	nop

f010454b <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010454b:	55                   	push   %ebp
f010454c:	89 e5                	mov    %esp,%ebp
f010454e:	57                   	push   %edi
f010454f:	56                   	push   %esi
f0104550:	53                   	push   %ebx
f0104551:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104554:	8b 0d 08 8f 22 f0    	mov    0xf0228f08,%ecx
f010455a:	89 c3                	mov    %eax,%ebx
f010455c:	c1 eb 0c             	shr    $0xc,%ebx
f010455f:	39 cb                	cmp    %ecx,%ebx
f0104561:	72 12                	jb     f0104575 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104563:	50                   	push   %eax
f0104564:	68 a4 4f 10 f0       	push   $0xf0104fa4
f0104569:	6a 57                	push   $0x57
f010456b:	68 a1 67 10 f0       	push   $0xf01067a1
f0104570:	e8 cb ba ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0104575:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010457b:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010457d:	89 c2                	mov    %eax,%edx
f010457f:	c1 ea 0c             	shr    $0xc,%edx
f0104582:	39 ca                	cmp    %ecx,%edx
f0104584:	72 12                	jb     f0104598 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104586:	50                   	push   %eax
f0104587:	68 a4 4f 10 f0       	push   $0xf0104fa4
f010458c:	6a 57                	push   $0x57
f010458e:	68 a1 67 10 f0       	push   $0xf01067a1
f0104593:	e8 a8 ba ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0104598:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010459e:	eb 2f                	jmp    f01045cf <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01045a0:	83 ec 04             	sub    $0x4,%esp
f01045a3:	6a 04                	push   $0x4
f01045a5:	68 b1 67 10 f0       	push   $0xf01067b1
f01045aa:	53                   	push   %ebx
f01045ab:	e8 e4 fd ff ff       	call   f0104394 <memcmp>
f01045b0:	83 c4 10             	add    $0x10,%esp
f01045b3:	85 c0                	test   %eax,%eax
f01045b5:	75 15                	jne    f01045cc <mpsearch1+0x81>
f01045b7:	89 da                	mov    %ebx,%edx
f01045b9:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01045bc:	0f b6 0a             	movzbl (%edx),%ecx
f01045bf:	01 c8                	add    %ecx,%eax
f01045c1:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01045c4:	39 d7                	cmp    %edx,%edi
f01045c6:	75 f4                	jne    f01045bc <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01045c8:	84 c0                	test   %al,%al
f01045ca:	74 0e                	je     f01045da <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01045cc:	83 c3 10             	add    $0x10,%ebx
f01045cf:	39 f3                	cmp    %esi,%ebx
f01045d1:	72 cd                	jb     f01045a0 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01045d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01045d8:	eb 02                	jmp    f01045dc <mpsearch1+0x91>
f01045da:	89 d8                	mov    %ebx,%eax
}
f01045dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01045df:	5b                   	pop    %ebx
f01045e0:	5e                   	pop    %esi
f01045e1:	5f                   	pop    %edi
f01045e2:	5d                   	pop    %ebp
f01045e3:	c3                   	ret    

f01045e4 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01045e4:	55                   	push   %ebp
f01045e5:	89 e5                	mov    %esp,%ebp
f01045e7:	57                   	push   %edi
f01045e8:	56                   	push   %esi
f01045e9:	53                   	push   %ebx
f01045ea:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01045ed:	c7 05 c0 93 22 f0 20 	movl   $0xf0229020,0xf02293c0
f01045f4:	90 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01045f7:	83 3d 08 8f 22 f0 00 	cmpl   $0x0,0xf0228f08
f01045fe:	75 16                	jne    f0104616 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104600:	68 00 04 00 00       	push   $0x400
f0104605:	68 a4 4f 10 f0       	push   $0xf0104fa4
f010460a:	6a 6f                	push   $0x6f
f010460c:	68 a1 67 10 f0       	push   $0xf01067a1
f0104611:	e8 2a ba ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0104616:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f010461d:	85 c0                	test   %eax,%eax
f010461f:	74 16                	je     f0104637 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0104621:	c1 e0 04             	shl    $0x4,%eax
f0104624:	ba 00 04 00 00       	mov    $0x400,%edx
f0104629:	e8 1d ff ff ff       	call   f010454b <mpsearch1>
f010462e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104631:	85 c0                	test   %eax,%eax
f0104633:	75 3c                	jne    f0104671 <mp_init+0x8d>
f0104635:	eb 20                	jmp    f0104657 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0104637:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010463e:	c1 e0 0a             	shl    $0xa,%eax
f0104641:	2d 00 04 00 00       	sub    $0x400,%eax
f0104646:	ba 00 04 00 00       	mov    $0x400,%edx
f010464b:	e8 fb fe ff ff       	call   f010454b <mpsearch1>
f0104650:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104653:	85 c0                	test   %eax,%eax
f0104655:	75 1a                	jne    f0104671 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0104657:	ba 00 00 01 00       	mov    $0x10000,%edx
f010465c:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0104661:	e8 e5 fe ff ff       	call   f010454b <mpsearch1>
f0104666:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0104669:	85 c0                	test   %eax,%eax
f010466b:	0f 84 5d 02 00 00    	je     f01048ce <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0104671:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104674:	8b 70 04             	mov    0x4(%eax),%esi
f0104677:	85 f6                	test   %esi,%esi
f0104679:	74 06                	je     f0104681 <mp_init+0x9d>
f010467b:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010467f:	74 15                	je     f0104696 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0104681:	83 ec 0c             	sub    $0xc,%esp
f0104684:	68 14 66 10 f0       	push   $0xf0106614
f0104689:	e8 4e e6 ff ff       	call   f0102cdc <cprintf>
f010468e:	83 c4 10             	add    $0x10,%esp
f0104691:	e9 38 02 00 00       	jmp    f01048ce <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104696:	89 f0                	mov    %esi,%eax
f0104698:	c1 e8 0c             	shr    $0xc,%eax
f010469b:	3b 05 08 8f 22 f0    	cmp    0xf0228f08,%eax
f01046a1:	72 15                	jb     f01046b8 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01046a3:	56                   	push   %esi
f01046a4:	68 a4 4f 10 f0       	push   $0xf0104fa4
f01046a9:	68 90 00 00 00       	push   $0x90
f01046ae:	68 a1 67 10 f0       	push   $0xf01067a1
f01046b3:	e8 88 b9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01046b8:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01046be:	83 ec 04             	sub    $0x4,%esp
f01046c1:	6a 04                	push   $0x4
f01046c3:	68 b6 67 10 f0       	push   $0xf01067b6
f01046c8:	53                   	push   %ebx
f01046c9:	e8 c6 fc ff ff       	call   f0104394 <memcmp>
f01046ce:	83 c4 10             	add    $0x10,%esp
f01046d1:	85 c0                	test   %eax,%eax
f01046d3:	74 15                	je     f01046ea <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01046d5:	83 ec 0c             	sub    $0xc,%esp
f01046d8:	68 44 66 10 f0       	push   $0xf0106644
f01046dd:	e8 fa e5 ff ff       	call   f0102cdc <cprintf>
f01046e2:	83 c4 10             	add    $0x10,%esp
f01046e5:	e9 e4 01 00 00       	jmp    f01048ce <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01046ea:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01046ee:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01046f2:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01046f5:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01046fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01046ff:	eb 0d                	jmp    f010470e <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0104701:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0104708:	f0 
f0104709:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010470b:	83 c0 01             	add    $0x1,%eax
f010470e:	39 c7                	cmp    %eax,%edi
f0104710:	75 ef                	jne    f0104701 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0104712:	84 d2                	test   %dl,%dl
f0104714:	74 15                	je     f010472b <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0104716:	83 ec 0c             	sub    $0xc,%esp
f0104719:	68 78 66 10 f0       	push   $0xf0106678
f010471e:	e8 b9 e5 ff ff       	call   f0102cdc <cprintf>
f0104723:	83 c4 10             	add    $0x10,%esp
f0104726:	e9 a3 01 00 00       	jmp    f01048ce <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010472b:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f010472f:	3c 01                	cmp    $0x1,%al
f0104731:	74 1d                	je     f0104750 <mp_init+0x16c>
f0104733:	3c 04                	cmp    $0x4,%al
f0104735:	74 19                	je     f0104750 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0104737:	83 ec 08             	sub    $0x8,%esp
f010473a:	0f b6 c0             	movzbl %al,%eax
f010473d:	50                   	push   %eax
f010473e:	68 9c 66 10 f0       	push   $0xf010669c
f0104743:	e8 94 e5 ff ff       	call   f0102cdc <cprintf>
f0104748:	83 c4 10             	add    $0x10,%esp
f010474b:	e9 7e 01 00 00       	jmp    f01048ce <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0104750:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0104754:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0104758:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f010475d:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0104762:	01 ce                	add    %ecx,%esi
f0104764:	eb 0d                	jmp    f0104773 <mp_init+0x18f>
f0104766:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f010476d:	f0 
f010476e:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0104770:	83 c0 01             	add    $0x1,%eax
f0104773:	39 c7                	cmp    %eax,%edi
f0104775:	75 ef                	jne    f0104766 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0104777:	89 d0                	mov    %edx,%eax
f0104779:	02 43 2a             	add    0x2a(%ebx),%al
f010477c:	74 15                	je     f0104793 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010477e:	83 ec 0c             	sub    $0xc,%esp
f0104781:	68 bc 66 10 f0       	push   $0xf01066bc
f0104786:	e8 51 e5 ff ff       	call   f0102cdc <cprintf>
f010478b:	83 c4 10             	add    $0x10,%esp
f010478e:	e9 3b 01 00 00       	jmp    f01048ce <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0104793:	85 db                	test   %ebx,%ebx
f0104795:	0f 84 33 01 00 00    	je     f01048ce <mp_init+0x2ea>
		return;
	ismp = 1;
f010479b:	c7 05 00 90 22 f0 01 	movl   $0x1,0xf0229000
f01047a2:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01047a5:	8b 43 24             	mov    0x24(%ebx),%eax
f01047a8:	a3 00 a0 26 f0       	mov    %eax,0xf026a000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01047ad:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f01047b0:	be 00 00 00 00       	mov    $0x0,%esi
f01047b5:	e9 85 00 00 00       	jmp    f010483f <mp_init+0x25b>
		switch (*p) {
f01047ba:	0f b6 07             	movzbl (%edi),%eax
f01047bd:	84 c0                	test   %al,%al
f01047bf:	74 06                	je     f01047c7 <mp_init+0x1e3>
f01047c1:	3c 04                	cmp    $0x4,%al
f01047c3:	77 55                	ja     f010481a <mp_init+0x236>
f01047c5:	eb 4e                	jmp    f0104815 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01047c7:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01047cb:	74 11                	je     f01047de <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f01047cd:	6b 05 c4 93 22 f0 74 	imul   $0x74,0xf02293c4,%eax
f01047d4:	05 20 90 22 f0       	add    $0xf0229020,%eax
f01047d9:	a3 c0 93 22 f0       	mov    %eax,0xf02293c0
			if (ncpu < NCPU) {
f01047de:	a1 c4 93 22 f0       	mov    0xf02293c4,%eax
f01047e3:	83 f8 07             	cmp    $0x7,%eax
f01047e6:	7f 13                	jg     f01047fb <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f01047e8:	6b d0 74             	imul   $0x74,%eax,%edx
f01047eb:	88 82 20 90 22 f0    	mov    %al,-0xfdd6fe0(%edx)
				ncpu++;
f01047f1:	83 c0 01             	add    $0x1,%eax
f01047f4:	a3 c4 93 22 f0       	mov    %eax,0xf02293c4
f01047f9:	eb 15                	jmp    f0104810 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01047fb:	83 ec 08             	sub    $0x8,%esp
f01047fe:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0104802:	50                   	push   %eax
f0104803:	68 ec 66 10 f0       	push   $0xf01066ec
f0104808:	e8 cf e4 ff ff       	call   f0102cdc <cprintf>
f010480d:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0104810:	83 c7 14             	add    $0x14,%edi
			continue;
f0104813:	eb 27                	jmp    f010483c <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0104815:	83 c7 08             	add    $0x8,%edi
			continue;
f0104818:	eb 22                	jmp    f010483c <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010481a:	83 ec 08             	sub    $0x8,%esp
f010481d:	0f b6 c0             	movzbl %al,%eax
f0104820:	50                   	push   %eax
f0104821:	68 14 67 10 f0       	push   $0xf0106714
f0104826:	e8 b1 e4 ff ff       	call   f0102cdc <cprintf>
			ismp = 0;
f010482b:	c7 05 00 90 22 f0 00 	movl   $0x0,0xf0229000
f0104832:	00 00 00 
			i = conf->entry;
f0104835:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0104839:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010483c:	83 c6 01             	add    $0x1,%esi
f010483f:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0104843:	39 c6                	cmp    %eax,%esi
f0104845:	0f 82 6f ff ff ff    	jb     f01047ba <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010484b:	a1 c0 93 22 f0       	mov    0xf02293c0,%eax
f0104850:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0104857:	83 3d 00 90 22 f0 00 	cmpl   $0x0,0xf0229000
f010485e:	75 26                	jne    f0104886 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0104860:	c7 05 c4 93 22 f0 01 	movl   $0x1,0xf02293c4
f0104867:	00 00 00 
		lapicaddr = 0;
f010486a:	c7 05 00 a0 26 f0 00 	movl   $0x0,0xf026a000
f0104871:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0104874:	83 ec 0c             	sub    $0xc,%esp
f0104877:	68 34 67 10 f0       	push   $0xf0106734
f010487c:	e8 5b e4 ff ff       	call   f0102cdc <cprintf>
		return;
f0104881:	83 c4 10             	add    $0x10,%esp
f0104884:	eb 48                	jmp    f01048ce <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0104886:	83 ec 04             	sub    $0x4,%esp
f0104889:	ff 35 c4 93 22 f0    	pushl  0xf02293c4
f010488f:	0f b6 00             	movzbl (%eax),%eax
f0104892:	50                   	push   %eax
f0104893:	68 bb 67 10 f0       	push   $0xf01067bb
f0104898:	e8 3f e4 ff ff       	call   f0102cdc <cprintf>

	if (mp->imcrp) {
f010489d:	83 c4 10             	add    $0x10,%esp
f01048a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048a3:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01048a7:	74 25                	je     f01048ce <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01048a9:	83 ec 0c             	sub    $0xc,%esp
f01048ac:	68 60 67 10 f0       	push   $0xf0106760
f01048b1:	e8 26 e4 ff ff       	call   f0102cdc <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01048b6:	ba 22 00 00 00       	mov    $0x22,%edx
f01048bb:	b8 70 00 00 00       	mov    $0x70,%eax
f01048c0:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01048c1:	ba 23 00 00 00       	mov    $0x23,%edx
f01048c6:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01048c7:	83 c8 01             	or     $0x1,%eax
f01048ca:	ee                   	out    %al,(%dx)
f01048cb:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01048ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01048d1:	5b                   	pop    %ebx
f01048d2:	5e                   	pop    %esi
f01048d3:	5f                   	pop    %edi
f01048d4:	5d                   	pop    %ebp
f01048d5:	c3                   	ret    

f01048d6 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01048d6:	55                   	push   %ebp
f01048d7:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01048d9:	8b 0d 04 a0 26 f0    	mov    0xf026a004,%ecx
f01048df:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01048e2:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01048e4:	a1 04 a0 26 f0       	mov    0xf026a004,%eax
f01048e9:	8b 40 20             	mov    0x20(%eax),%eax
}
f01048ec:	5d                   	pop    %ebp
f01048ed:	c3                   	ret    

f01048ee <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01048ee:	55                   	push   %ebp
f01048ef:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01048f1:	a1 04 a0 26 f0       	mov    0xf026a004,%eax
f01048f6:	85 c0                	test   %eax,%eax
f01048f8:	74 08                	je     f0104902 <cpunum+0x14>
		return lapic[ID] >> 24;
f01048fa:	8b 40 20             	mov    0x20(%eax),%eax
f01048fd:	c1 e8 18             	shr    $0x18,%eax
f0104900:	eb 05                	jmp    f0104907 <cpunum+0x19>
	return 0;
f0104902:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104907:	5d                   	pop    %ebp
f0104908:	c3                   	ret    

f0104909 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0104909:	a1 00 a0 26 f0       	mov    0xf026a000,%eax
f010490e:	85 c0                	test   %eax,%eax
f0104910:	0f 84 21 01 00 00    	je     f0104a37 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0104916:	55                   	push   %ebp
f0104917:	89 e5                	mov    %esp,%ebp
f0104919:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f010491c:	68 00 10 00 00       	push   $0x1000
f0104921:	50                   	push   %eax
f0104922:	e8 01 c7 ff ff       	call   f0101028 <mmio_map_region>
f0104927:	a3 04 a0 26 f0       	mov    %eax,0xf026a004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010492c:	ba 27 01 00 00       	mov    $0x127,%edx
f0104931:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0104936:	e8 9b ff ff ff       	call   f01048d6 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010493b:	ba 0b 00 00 00       	mov    $0xb,%edx
f0104940:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0104945:	e8 8c ff ff ff       	call   f01048d6 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010494a:	ba 20 00 02 00       	mov    $0x20020,%edx
f010494f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0104954:	e8 7d ff ff ff       	call   f01048d6 <lapicw>
	lapicw(TICR, 10000000); 
f0104959:	ba 80 96 98 00       	mov    $0x989680,%edx
f010495e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0104963:	e8 6e ff ff ff       	call   f01048d6 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0104968:	e8 81 ff ff ff       	call   f01048ee <cpunum>
f010496d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104970:	05 20 90 22 f0       	add    $0xf0229020,%eax
f0104975:	83 c4 10             	add    $0x10,%esp
f0104978:	39 05 c0 93 22 f0    	cmp    %eax,0xf02293c0
f010497e:	74 0f                	je     f010498f <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0104980:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104985:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010498a:	e8 47 ff ff ff       	call   f01048d6 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010498f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0104994:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0104999:	e8 38 ff ff ff       	call   f01048d6 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010499e:	a1 04 a0 26 f0       	mov    0xf026a004,%eax
f01049a3:	8b 40 30             	mov    0x30(%eax),%eax
f01049a6:	c1 e8 10             	shr    $0x10,%eax
f01049a9:	3c 03                	cmp    $0x3,%al
f01049ab:	76 0f                	jbe    f01049bc <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f01049ad:	ba 00 00 01 00       	mov    $0x10000,%edx
f01049b2:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01049b7:	e8 1a ff ff ff       	call   f01048d6 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01049bc:	ba 33 00 00 00       	mov    $0x33,%edx
f01049c1:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01049c6:	e8 0b ff ff ff       	call   f01048d6 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01049cb:	ba 00 00 00 00       	mov    $0x0,%edx
f01049d0:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01049d5:	e8 fc fe ff ff       	call   f01048d6 <lapicw>
	lapicw(ESR, 0);
f01049da:	ba 00 00 00 00       	mov    $0x0,%edx
f01049df:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01049e4:	e8 ed fe ff ff       	call   f01048d6 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01049e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01049ee:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01049f3:	e8 de fe ff ff       	call   f01048d6 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01049f8:	ba 00 00 00 00       	mov    $0x0,%edx
f01049fd:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0104a02:	e8 cf fe ff ff       	call   f01048d6 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0104a07:	ba 00 85 08 00       	mov    $0x88500,%edx
f0104a0c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0104a11:	e8 c0 fe ff ff       	call   f01048d6 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0104a16:	8b 15 04 a0 26 f0    	mov    0xf026a004,%edx
f0104a1c:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0104a22:	f6 c4 10             	test   $0x10,%ah
f0104a25:	75 f5                	jne    f0104a1c <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0104a27:	ba 00 00 00 00       	mov    $0x0,%edx
f0104a2c:	b8 20 00 00 00       	mov    $0x20,%eax
f0104a31:	e8 a0 fe ff ff       	call   f01048d6 <lapicw>
}
f0104a36:	c9                   	leave  
f0104a37:	f3 c3                	repz ret 

f0104a39 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0104a39:	83 3d 04 a0 26 f0 00 	cmpl   $0x0,0xf026a004
f0104a40:	74 13                	je     f0104a55 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0104a42:	55                   	push   %ebp
f0104a43:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0104a45:	ba 00 00 00 00       	mov    $0x0,%edx
f0104a4a:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0104a4f:	e8 82 fe ff ff       	call   f01048d6 <lapicw>
}
f0104a54:	5d                   	pop    %ebp
f0104a55:	f3 c3                	repz ret 

f0104a57 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0104a57:	55                   	push   %ebp
f0104a58:	89 e5                	mov    %esp,%ebp
f0104a5a:	56                   	push   %esi
f0104a5b:	53                   	push   %ebx
f0104a5c:	8b 75 08             	mov    0x8(%ebp),%esi
f0104a5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104a62:	ba 70 00 00 00       	mov    $0x70,%edx
f0104a67:	b8 0f 00 00 00       	mov    $0xf,%eax
f0104a6c:	ee                   	out    %al,(%dx)
f0104a6d:	ba 71 00 00 00       	mov    $0x71,%edx
f0104a72:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104a77:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104a78:	83 3d 08 8f 22 f0 00 	cmpl   $0x0,0xf0228f08
f0104a7f:	75 19                	jne    f0104a9a <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104a81:	68 67 04 00 00       	push   $0x467
f0104a86:	68 a4 4f 10 f0       	push   $0xf0104fa4
f0104a8b:	68 98 00 00 00       	push   $0x98
f0104a90:	68 d8 67 10 f0       	push   $0xf01067d8
f0104a95:	e8 a6 b5 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0104a9a:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0104aa1:	00 00 
	wrv[1] = addr >> 4;
f0104aa3:	89 d8                	mov    %ebx,%eax
f0104aa5:	c1 e8 04             	shr    $0x4,%eax
f0104aa8:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0104aae:	c1 e6 18             	shl    $0x18,%esi
f0104ab1:	89 f2                	mov    %esi,%edx
f0104ab3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0104ab8:	e8 19 fe ff ff       	call   f01048d6 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0104abd:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0104ac2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0104ac7:	e8 0a fe ff ff       	call   f01048d6 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0104acc:	ba 00 85 00 00       	mov    $0x8500,%edx
f0104ad1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0104ad6:	e8 fb fd ff ff       	call   f01048d6 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0104adb:	c1 eb 0c             	shr    $0xc,%ebx
f0104ade:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0104ae1:	89 f2                	mov    %esi,%edx
f0104ae3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0104ae8:	e8 e9 fd ff ff       	call   f01048d6 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0104aed:	89 da                	mov    %ebx,%edx
f0104aef:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0104af4:	e8 dd fd ff ff       	call   f01048d6 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0104af9:	89 f2                	mov    %esi,%edx
f0104afb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0104b00:	e8 d1 fd ff ff       	call   f01048d6 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0104b05:	89 da                	mov    %ebx,%edx
f0104b07:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0104b0c:	e8 c5 fd ff ff       	call   f01048d6 <lapicw>
		microdelay(200);
	}
}
f0104b11:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104b14:	5b                   	pop    %ebx
f0104b15:	5e                   	pop    %esi
f0104b16:	5d                   	pop    %ebp
f0104b17:	c3                   	ret    

f0104b18 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0104b18:	55                   	push   %ebp
f0104b19:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0104b1b:	8b 55 08             	mov    0x8(%ebp),%edx
f0104b1e:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0104b24:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0104b29:	e8 a8 fd ff ff       	call   f01048d6 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0104b2e:	8b 15 04 a0 26 f0    	mov    0xf026a004,%edx
f0104b34:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0104b3a:	f6 c4 10             	test   $0x10,%ah
f0104b3d:	75 f5                	jne    f0104b34 <lapic_ipi+0x1c>
		;
}
f0104b3f:	5d                   	pop    %ebp
f0104b40:	c3                   	ret    

f0104b41 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0104b41:	55                   	push   %ebp
f0104b42:	89 e5                	mov    %esp,%ebp
f0104b44:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0104b47:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0104b4d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104b50:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0104b53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0104b5a:	5d                   	pop    %ebp
f0104b5b:	c3                   	ret    

f0104b5c <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0104b5c:	55                   	push   %ebp
f0104b5d:	89 e5                	mov    %esp,%ebp
f0104b5f:	56                   	push   %esi
f0104b60:	53                   	push   %ebx
f0104b61:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0104b64:	83 3b 00             	cmpl   $0x0,(%ebx)
f0104b67:	74 14                	je     f0104b7d <spin_lock+0x21>
f0104b69:	8b 73 08             	mov    0x8(%ebx),%esi
f0104b6c:	e8 7d fd ff ff       	call   f01048ee <cpunum>
f0104b71:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b74:	05 20 90 22 f0       	add    $0xf0229020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0104b79:	39 c6                	cmp    %eax,%esi
f0104b7b:	74 07                	je     f0104b84 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104b7d:	ba 01 00 00 00       	mov    $0x1,%edx
f0104b82:	eb 20                	jmp    f0104ba4 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0104b84:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0104b87:	e8 62 fd ff ff       	call   f01048ee <cpunum>
f0104b8c:	83 ec 0c             	sub    $0xc,%esp
f0104b8f:	53                   	push   %ebx
f0104b90:	50                   	push   %eax
f0104b91:	68 e8 67 10 f0       	push   $0xf01067e8
f0104b96:	6a 41                	push   $0x41
f0104b98:	68 4c 68 10 f0       	push   $0xf010684c
f0104b9d:	e8 9e b4 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0104ba2:	f3 90                	pause  
f0104ba4:	89 d0                	mov    %edx,%eax
f0104ba6:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0104ba9:	85 c0                	test   %eax,%eax
f0104bab:	75 f5                	jne    f0104ba2 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0104bad:	e8 3c fd ff ff       	call   f01048ee <cpunum>
f0104bb2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bb5:	05 20 90 22 f0       	add    $0xf0229020,%eax
f0104bba:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0104bbd:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0104bc0:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0104bc2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104bc7:	eb 0b                	jmp    f0104bd4 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0104bc9:	8b 4a 04             	mov    0x4(%edx),%ecx
f0104bcc:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0104bcf:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0104bd1:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0104bd4:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0104bda:	76 11                	jbe    f0104bed <spin_lock+0x91>
f0104bdc:	83 f8 09             	cmp    $0x9,%eax
f0104bdf:	7e e8                	jle    f0104bc9 <spin_lock+0x6d>
f0104be1:	eb 0a                	jmp    f0104bed <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0104be3:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0104bea:	83 c0 01             	add    $0x1,%eax
f0104bed:	83 f8 09             	cmp    $0x9,%eax
f0104bf0:	7e f1                	jle    f0104be3 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0104bf2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104bf5:	5b                   	pop    %ebx
f0104bf6:	5e                   	pop    %esi
f0104bf7:	5d                   	pop    %ebp
f0104bf8:	c3                   	ret    

f0104bf9 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0104bf9:	55                   	push   %ebp
f0104bfa:	89 e5                	mov    %esp,%ebp
f0104bfc:	57                   	push   %edi
f0104bfd:	56                   	push   %esi
f0104bfe:	53                   	push   %ebx
f0104bff:	83 ec 4c             	sub    $0x4c,%esp
f0104c02:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0104c05:	83 3e 00             	cmpl   $0x0,(%esi)
f0104c08:	74 18                	je     f0104c22 <spin_unlock+0x29>
f0104c0a:	8b 5e 08             	mov    0x8(%esi),%ebx
f0104c0d:	e8 dc fc ff ff       	call   f01048ee <cpunum>
f0104c12:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c15:	05 20 90 22 f0       	add    $0xf0229020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0104c1a:	39 c3                	cmp    %eax,%ebx
f0104c1c:	0f 84 a5 00 00 00    	je     f0104cc7 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0104c22:	83 ec 04             	sub    $0x4,%esp
f0104c25:	6a 28                	push   $0x28
f0104c27:	8d 46 0c             	lea    0xc(%esi),%eax
f0104c2a:	50                   	push   %eax
f0104c2b:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0104c2e:	53                   	push   %ebx
f0104c2f:	e8 e5 f6 ff ff       	call   f0104319 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0104c34:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0104c37:	0f b6 38             	movzbl (%eax),%edi
f0104c3a:	8b 76 04             	mov    0x4(%esi),%esi
f0104c3d:	e8 ac fc ff ff       	call   f01048ee <cpunum>
f0104c42:	57                   	push   %edi
f0104c43:	56                   	push   %esi
f0104c44:	50                   	push   %eax
f0104c45:	68 14 68 10 f0       	push   $0xf0106814
f0104c4a:	e8 8d e0 ff ff       	call   f0102cdc <cprintf>
f0104c4f:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0104c52:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0104c55:	eb 54                	jmp    f0104cab <spin_unlock+0xb2>
f0104c57:	83 ec 08             	sub    $0x8,%esp
f0104c5a:	57                   	push   %edi
f0104c5b:	50                   	push   %eax
f0104c5c:	e8 f1 eb ff ff       	call   f0103852 <debuginfo_eip>
f0104c61:	83 c4 10             	add    $0x10,%esp
f0104c64:	85 c0                	test   %eax,%eax
f0104c66:	78 27                	js     f0104c8f <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0104c68:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0104c6a:	83 ec 04             	sub    $0x4,%esp
f0104c6d:	89 c2                	mov    %eax,%edx
f0104c6f:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0104c72:	52                   	push   %edx
f0104c73:	ff 75 b0             	pushl  -0x50(%ebp)
f0104c76:	ff 75 b4             	pushl  -0x4c(%ebp)
f0104c79:	ff 75 ac             	pushl  -0x54(%ebp)
f0104c7c:	ff 75 a8             	pushl  -0x58(%ebp)
f0104c7f:	50                   	push   %eax
f0104c80:	68 5c 68 10 f0       	push   $0xf010685c
f0104c85:	e8 52 e0 ff ff       	call   f0102cdc <cprintf>
f0104c8a:	83 c4 20             	add    $0x20,%esp
f0104c8d:	eb 12                	jmp    f0104ca1 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0104c8f:	83 ec 08             	sub    $0x8,%esp
f0104c92:	ff 36                	pushl  (%esi)
f0104c94:	68 73 68 10 f0       	push   $0xf0106873
f0104c99:	e8 3e e0 ff ff       	call   f0102cdc <cprintf>
f0104c9e:	83 c4 10             	add    $0x10,%esp
f0104ca1:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0104ca4:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0104ca7:	39 c3                	cmp    %eax,%ebx
f0104ca9:	74 08                	je     f0104cb3 <spin_unlock+0xba>
f0104cab:	89 de                	mov    %ebx,%esi
f0104cad:	8b 03                	mov    (%ebx),%eax
f0104caf:	85 c0                	test   %eax,%eax
f0104cb1:	75 a4                	jne    f0104c57 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0104cb3:	83 ec 04             	sub    $0x4,%esp
f0104cb6:	68 7b 68 10 f0       	push   $0xf010687b
f0104cbb:	6a 67                	push   $0x67
f0104cbd:	68 4c 68 10 f0       	push   $0xf010684c
f0104cc2:	e8 79 b3 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0104cc7:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0104cce:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104cd5:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cda:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0104cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ce0:	5b                   	pop    %ebx
f0104ce1:	5e                   	pop    %esi
f0104ce2:	5f                   	pop    %edi
f0104ce3:	5d                   	pop    %ebp
f0104ce4:	c3                   	ret    
f0104ce5:	66 90                	xchg   %ax,%ax
f0104ce7:	66 90                	xchg   %ax,%ax
f0104ce9:	66 90                	xchg   %ax,%ax
f0104ceb:	66 90                	xchg   %ax,%ax
f0104ced:	66 90                	xchg   %ax,%ax
f0104cef:	90                   	nop

f0104cf0 <__udivdi3>:
f0104cf0:	55                   	push   %ebp
f0104cf1:	57                   	push   %edi
f0104cf2:	56                   	push   %esi
f0104cf3:	53                   	push   %ebx
f0104cf4:	83 ec 1c             	sub    $0x1c,%esp
f0104cf7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0104cfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0104cff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0104d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104d07:	85 f6                	test   %esi,%esi
f0104d09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104d0d:	89 ca                	mov    %ecx,%edx
f0104d0f:	89 f8                	mov    %edi,%eax
f0104d11:	75 3d                	jne    f0104d50 <__udivdi3+0x60>
f0104d13:	39 cf                	cmp    %ecx,%edi
f0104d15:	0f 87 c5 00 00 00    	ja     f0104de0 <__udivdi3+0xf0>
f0104d1b:	85 ff                	test   %edi,%edi
f0104d1d:	89 fd                	mov    %edi,%ebp
f0104d1f:	75 0b                	jne    f0104d2c <__udivdi3+0x3c>
f0104d21:	b8 01 00 00 00       	mov    $0x1,%eax
f0104d26:	31 d2                	xor    %edx,%edx
f0104d28:	f7 f7                	div    %edi
f0104d2a:	89 c5                	mov    %eax,%ebp
f0104d2c:	89 c8                	mov    %ecx,%eax
f0104d2e:	31 d2                	xor    %edx,%edx
f0104d30:	f7 f5                	div    %ebp
f0104d32:	89 c1                	mov    %eax,%ecx
f0104d34:	89 d8                	mov    %ebx,%eax
f0104d36:	89 cf                	mov    %ecx,%edi
f0104d38:	f7 f5                	div    %ebp
f0104d3a:	89 c3                	mov    %eax,%ebx
f0104d3c:	89 d8                	mov    %ebx,%eax
f0104d3e:	89 fa                	mov    %edi,%edx
f0104d40:	83 c4 1c             	add    $0x1c,%esp
f0104d43:	5b                   	pop    %ebx
f0104d44:	5e                   	pop    %esi
f0104d45:	5f                   	pop    %edi
f0104d46:	5d                   	pop    %ebp
f0104d47:	c3                   	ret    
f0104d48:	90                   	nop
f0104d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104d50:	39 ce                	cmp    %ecx,%esi
f0104d52:	77 74                	ja     f0104dc8 <__udivdi3+0xd8>
f0104d54:	0f bd fe             	bsr    %esi,%edi
f0104d57:	83 f7 1f             	xor    $0x1f,%edi
f0104d5a:	0f 84 98 00 00 00    	je     f0104df8 <__udivdi3+0x108>
f0104d60:	bb 20 00 00 00       	mov    $0x20,%ebx
f0104d65:	89 f9                	mov    %edi,%ecx
f0104d67:	89 c5                	mov    %eax,%ebp
f0104d69:	29 fb                	sub    %edi,%ebx
f0104d6b:	d3 e6                	shl    %cl,%esi
f0104d6d:	89 d9                	mov    %ebx,%ecx
f0104d6f:	d3 ed                	shr    %cl,%ebp
f0104d71:	89 f9                	mov    %edi,%ecx
f0104d73:	d3 e0                	shl    %cl,%eax
f0104d75:	09 ee                	or     %ebp,%esi
f0104d77:	89 d9                	mov    %ebx,%ecx
f0104d79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104d7d:	89 d5                	mov    %edx,%ebp
f0104d7f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104d83:	d3 ed                	shr    %cl,%ebp
f0104d85:	89 f9                	mov    %edi,%ecx
f0104d87:	d3 e2                	shl    %cl,%edx
f0104d89:	89 d9                	mov    %ebx,%ecx
f0104d8b:	d3 e8                	shr    %cl,%eax
f0104d8d:	09 c2                	or     %eax,%edx
f0104d8f:	89 d0                	mov    %edx,%eax
f0104d91:	89 ea                	mov    %ebp,%edx
f0104d93:	f7 f6                	div    %esi
f0104d95:	89 d5                	mov    %edx,%ebp
f0104d97:	89 c3                	mov    %eax,%ebx
f0104d99:	f7 64 24 0c          	mull   0xc(%esp)
f0104d9d:	39 d5                	cmp    %edx,%ebp
f0104d9f:	72 10                	jb     f0104db1 <__udivdi3+0xc1>
f0104da1:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104da5:	89 f9                	mov    %edi,%ecx
f0104da7:	d3 e6                	shl    %cl,%esi
f0104da9:	39 c6                	cmp    %eax,%esi
f0104dab:	73 07                	jae    f0104db4 <__udivdi3+0xc4>
f0104dad:	39 d5                	cmp    %edx,%ebp
f0104daf:	75 03                	jne    f0104db4 <__udivdi3+0xc4>
f0104db1:	83 eb 01             	sub    $0x1,%ebx
f0104db4:	31 ff                	xor    %edi,%edi
f0104db6:	89 d8                	mov    %ebx,%eax
f0104db8:	89 fa                	mov    %edi,%edx
f0104dba:	83 c4 1c             	add    $0x1c,%esp
f0104dbd:	5b                   	pop    %ebx
f0104dbe:	5e                   	pop    %esi
f0104dbf:	5f                   	pop    %edi
f0104dc0:	5d                   	pop    %ebp
f0104dc1:	c3                   	ret    
f0104dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104dc8:	31 ff                	xor    %edi,%edi
f0104dca:	31 db                	xor    %ebx,%ebx
f0104dcc:	89 d8                	mov    %ebx,%eax
f0104dce:	89 fa                	mov    %edi,%edx
f0104dd0:	83 c4 1c             	add    $0x1c,%esp
f0104dd3:	5b                   	pop    %ebx
f0104dd4:	5e                   	pop    %esi
f0104dd5:	5f                   	pop    %edi
f0104dd6:	5d                   	pop    %ebp
f0104dd7:	c3                   	ret    
f0104dd8:	90                   	nop
f0104dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104de0:	89 d8                	mov    %ebx,%eax
f0104de2:	f7 f7                	div    %edi
f0104de4:	31 ff                	xor    %edi,%edi
f0104de6:	89 c3                	mov    %eax,%ebx
f0104de8:	89 d8                	mov    %ebx,%eax
f0104dea:	89 fa                	mov    %edi,%edx
f0104dec:	83 c4 1c             	add    $0x1c,%esp
f0104def:	5b                   	pop    %ebx
f0104df0:	5e                   	pop    %esi
f0104df1:	5f                   	pop    %edi
f0104df2:	5d                   	pop    %ebp
f0104df3:	c3                   	ret    
f0104df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104df8:	39 ce                	cmp    %ecx,%esi
f0104dfa:	72 0c                	jb     f0104e08 <__udivdi3+0x118>
f0104dfc:	31 db                	xor    %ebx,%ebx
f0104dfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0104e02:	0f 87 34 ff ff ff    	ja     f0104d3c <__udivdi3+0x4c>
f0104e08:	bb 01 00 00 00       	mov    $0x1,%ebx
f0104e0d:	e9 2a ff ff ff       	jmp    f0104d3c <__udivdi3+0x4c>
f0104e12:	66 90                	xchg   %ax,%ax
f0104e14:	66 90                	xchg   %ax,%ax
f0104e16:	66 90                	xchg   %ax,%ax
f0104e18:	66 90                	xchg   %ax,%ax
f0104e1a:	66 90                	xchg   %ax,%ax
f0104e1c:	66 90                	xchg   %ax,%ax
f0104e1e:	66 90                	xchg   %ax,%ax

f0104e20 <__umoddi3>:
f0104e20:	55                   	push   %ebp
f0104e21:	57                   	push   %edi
f0104e22:	56                   	push   %esi
f0104e23:	53                   	push   %ebx
f0104e24:	83 ec 1c             	sub    $0x1c,%esp
f0104e27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0104e2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0104e2f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104e33:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104e37:	85 d2                	test   %edx,%edx
f0104e39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104e41:	89 f3                	mov    %esi,%ebx
f0104e43:	89 3c 24             	mov    %edi,(%esp)
f0104e46:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104e4a:	75 1c                	jne    f0104e68 <__umoddi3+0x48>
f0104e4c:	39 f7                	cmp    %esi,%edi
f0104e4e:	76 50                	jbe    f0104ea0 <__umoddi3+0x80>
f0104e50:	89 c8                	mov    %ecx,%eax
f0104e52:	89 f2                	mov    %esi,%edx
f0104e54:	f7 f7                	div    %edi
f0104e56:	89 d0                	mov    %edx,%eax
f0104e58:	31 d2                	xor    %edx,%edx
f0104e5a:	83 c4 1c             	add    $0x1c,%esp
f0104e5d:	5b                   	pop    %ebx
f0104e5e:	5e                   	pop    %esi
f0104e5f:	5f                   	pop    %edi
f0104e60:	5d                   	pop    %ebp
f0104e61:	c3                   	ret    
f0104e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104e68:	39 f2                	cmp    %esi,%edx
f0104e6a:	89 d0                	mov    %edx,%eax
f0104e6c:	77 52                	ja     f0104ec0 <__umoddi3+0xa0>
f0104e6e:	0f bd ea             	bsr    %edx,%ebp
f0104e71:	83 f5 1f             	xor    $0x1f,%ebp
f0104e74:	75 5a                	jne    f0104ed0 <__umoddi3+0xb0>
f0104e76:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0104e7a:	0f 82 e0 00 00 00    	jb     f0104f60 <__umoddi3+0x140>
f0104e80:	39 0c 24             	cmp    %ecx,(%esp)
f0104e83:	0f 86 d7 00 00 00    	jbe    f0104f60 <__umoddi3+0x140>
f0104e89:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104e8d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104e91:	83 c4 1c             	add    $0x1c,%esp
f0104e94:	5b                   	pop    %ebx
f0104e95:	5e                   	pop    %esi
f0104e96:	5f                   	pop    %edi
f0104e97:	5d                   	pop    %ebp
f0104e98:	c3                   	ret    
f0104e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104ea0:	85 ff                	test   %edi,%edi
f0104ea2:	89 fd                	mov    %edi,%ebp
f0104ea4:	75 0b                	jne    f0104eb1 <__umoddi3+0x91>
f0104ea6:	b8 01 00 00 00       	mov    $0x1,%eax
f0104eab:	31 d2                	xor    %edx,%edx
f0104ead:	f7 f7                	div    %edi
f0104eaf:	89 c5                	mov    %eax,%ebp
f0104eb1:	89 f0                	mov    %esi,%eax
f0104eb3:	31 d2                	xor    %edx,%edx
f0104eb5:	f7 f5                	div    %ebp
f0104eb7:	89 c8                	mov    %ecx,%eax
f0104eb9:	f7 f5                	div    %ebp
f0104ebb:	89 d0                	mov    %edx,%eax
f0104ebd:	eb 99                	jmp    f0104e58 <__umoddi3+0x38>
f0104ebf:	90                   	nop
f0104ec0:	89 c8                	mov    %ecx,%eax
f0104ec2:	89 f2                	mov    %esi,%edx
f0104ec4:	83 c4 1c             	add    $0x1c,%esp
f0104ec7:	5b                   	pop    %ebx
f0104ec8:	5e                   	pop    %esi
f0104ec9:	5f                   	pop    %edi
f0104eca:	5d                   	pop    %ebp
f0104ecb:	c3                   	ret    
f0104ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104ed0:	8b 34 24             	mov    (%esp),%esi
f0104ed3:	bf 20 00 00 00       	mov    $0x20,%edi
f0104ed8:	89 e9                	mov    %ebp,%ecx
f0104eda:	29 ef                	sub    %ebp,%edi
f0104edc:	d3 e0                	shl    %cl,%eax
f0104ede:	89 f9                	mov    %edi,%ecx
f0104ee0:	89 f2                	mov    %esi,%edx
f0104ee2:	d3 ea                	shr    %cl,%edx
f0104ee4:	89 e9                	mov    %ebp,%ecx
f0104ee6:	09 c2                	or     %eax,%edx
f0104ee8:	89 d8                	mov    %ebx,%eax
f0104eea:	89 14 24             	mov    %edx,(%esp)
f0104eed:	89 f2                	mov    %esi,%edx
f0104eef:	d3 e2                	shl    %cl,%edx
f0104ef1:	89 f9                	mov    %edi,%ecx
f0104ef3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104ef7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104efb:	d3 e8                	shr    %cl,%eax
f0104efd:	89 e9                	mov    %ebp,%ecx
f0104eff:	89 c6                	mov    %eax,%esi
f0104f01:	d3 e3                	shl    %cl,%ebx
f0104f03:	89 f9                	mov    %edi,%ecx
f0104f05:	89 d0                	mov    %edx,%eax
f0104f07:	d3 e8                	shr    %cl,%eax
f0104f09:	89 e9                	mov    %ebp,%ecx
f0104f0b:	09 d8                	or     %ebx,%eax
f0104f0d:	89 d3                	mov    %edx,%ebx
f0104f0f:	89 f2                	mov    %esi,%edx
f0104f11:	f7 34 24             	divl   (%esp)
f0104f14:	89 d6                	mov    %edx,%esi
f0104f16:	d3 e3                	shl    %cl,%ebx
f0104f18:	f7 64 24 04          	mull   0x4(%esp)
f0104f1c:	39 d6                	cmp    %edx,%esi
f0104f1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104f22:	89 d1                	mov    %edx,%ecx
f0104f24:	89 c3                	mov    %eax,%ebx
f0104f26:	72 08                	jb     f0104f30 <__umoddi3+0x110>
f0104f28:	75 11                	jne    f0104f3b <__umoddi3+0x11b>
f0104f2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0104f2e:	73 0b                	jae    f0104f3b <__umoddi3+0x11b>
f0104f30:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104f34:	1b 14 24             	sbb    (%esp),%edx
f0104f37:	89 d1                	mov    %edx,%ecx
f0104f39:	89 c3                	mov    %eax,%ebx
f0104f3b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0104f3f:	29 da                	sub    %ebx,%edx
f0104f41:	19 ce                	sbb    %ecx,%esi
f0104f43:	89 f9                	mov    %edi,%ecx
f0104f45:	89 f0                	mov    %esi,%eax
f0104f47:	d3 e0                	shl    %cl,%eax
f0104f49:	89 e9                	mov    %ebp,%ecx
f0104f4b:	d3 ea                	shr    %cl,%edx
f0104f4d:	89 e9                	mov    %ebp,%ecx
f0104f4f:	d3 ee                	shr    %cl,%esi
f0104f51:	09 d0                	or     %edx,%eax
f0104f53:	89 f2                	mov    %esi,%edx
f0104f55:	83 c4 1c             	add    $0x1c,%esp
f0104f58:	5b                   	pop    %ebx
f0104f59:	5e                   	pop    %esi
f0104f5a:	5f                   	pop    %edi
f0104f5b:	5d                   	pop    %ebp
f0104f5c:	c3                   	ret    
f0104f5d:	8d 76 00             	lea    0x0(%esi),%esi
f0104f60:	29 f9                	sub    %edi,%ecx
f0104f62:	19 d6                	sbb    %edx,%esi
f0104f64:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104f68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104f6c:	e9 18 ff ff ff       	jmp    f0104e89 <__umoddi3+0x69>
