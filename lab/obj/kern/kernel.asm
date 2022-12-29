
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 40 0c 17 f0       	mov    $0xf0170c40,%eax
f010004b:	2d 40 fd 16 f0       	sub    $0xf016fd40,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 40 fd 16 f0       	push   $0xf016fd40
f0100058:	e8 cd 3b 00 00       	call   f0103c2a <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 ab 04 00 00       	call   f010050d <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 c0 40 10 f0       	push   $0xf01040c0
f010006f:	e8 21 2d 00 00       	call   f0102d95 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 9d 11 00 00       	call   f0101216 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 61 29 00 00       	call   f01029df <env_init>
	trap_init();
f010007e:	e8 8c 2d 00 00       	call   f0102e0f <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 56 a3 11 f0       	push   $0xf011a356
f010008d:	e8 71 2a 00 00       	call   f0102b03 <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100092:	83 c4 04             	add    $0x4,%esp
f0100095:	ff 35 88 ff 16 f0    	pushl  0xf016ff88
f010009b:	e8 74 2c 00 00       	call   f0102d14 <env_run>

f01000a0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a0:	55                   	push   %ebp
f01000a1:	89 e5                	mov    %esp,%ebp
f01000a3:	56                   	push   %esi
f01000a4:	53                   	push   %ebx
f01000a5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000a8:	83 3d 44 0c 17 f0 00 	cmpl   $0x0,0xf0170c44
f01000af:	75 37                	jne    f01000e8 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000b1:	89 35 44 0c 17 f0    	mov    %esi,0xf0170c44

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000b7:	fa                   	cli    
f01000b8:	fc                   	cld    

	va_start(ap, fmt);
f01000b9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000bc:	83 ec 04             	sub    $0x4,%esp
f01000bf:	ff 75 0c             	pushl  0xc(%ebp)
f01000c2:	ff 75 08             	pushl  0x8(%ebp)
f01000c5:	68 db 40 10 f0       	push   $0xf01040db
f01000ca:	e8 c6 2c 00 00       	call   f0102d95 <cprintf>
	vcprintf(fmt, ap);
f01000cf:	83 c4 08             	add    $0x8,%esp
f01000d2:	53                   	push   %ebx
f01000d3:	56                   	push   %esi
f01000d4:	e8 96 2c 00 00       	call   f0102d6f <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 d0 48 10 f0 	movl   $0xf01048d0,(%esp)
f01000e0:	e8 b0 2c 00 00       	call   f0102d95 <cprintf>
	va_end(ap);
f01000e5:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e8:	83 ec 0c             	sub    $0xc,%esp
f01000eb:	6a 00                	push   $0x0
f01000ed:	e8 48 07 00 00       	call   f010083a <monitor>
f01000f2:	83 c4 10             	add    $0x10,%esp
f01000f5:	eb f1                	jmp    f01000e8 <_panic+0x48>

f01000f7 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f7:	55                   	push   %ebp
f01000f8:	89 e5                	mov    %esp,%ebp
f01000fa:	53                   	push   %ebx
f01000fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fe:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100101:	ff 75 0c             	pushl  0xc(%ebp)
f0100104:	ff 75 08             	pushl  0x8(%ebp)
f0100107:	68 f3 40 10 f0       	push   $0xf01040f3
f010010c:	e8 84 2c 00 00       	call   f0102d95 <cprintf>
	vcprintf(fmt, ap);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	53                   	push   %ebx
f0100115:	ff 75 10             	pushl  0x10(%ebp)
f0100118:	e8 52 2c 00 00       	call   f0102d6f <vcprintf>
	cprintf("\n");
f010011d:	c7 04 24 d0 48 10 f0 	movl   $0xf01048d0,(%esp)
f0100124:	e8 6c 2c 00 00       	call   f0102d95 <cprintf>
	va_end(ap);
}
f0100129:	83 c4 10             	add    $0x10,%esp
f010012c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010012f:	c9                   	leave  
f0100130:	c3                   	ret    

f0100131 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100131:	55                   	push   %ebp
f0100132:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100134:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100139:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010013a:	a8 01                	test   $0x1,%al
f010013c:	74 0b                	je     f0100149 <serial_proc_data+0x18>
f010013e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100143:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100144:	0f b6 c0             	movzbl %al,%eax
f0100147:	eb 05                	jmp    f010014e <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100149:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010014e:	5d                   	pop    %ebp
f010014f:	c3                   	ret    

f0100150 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100150:	55                   	push   %ebp
f0100151:	89 e5                	mov    %esp,%ebp
f0100153:	53                   	push   %ebx
f0100154:	83 ec 04             	sub    $0x4,%esp
f0100157:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100159:	eb 2b                	jmp    f0100186 <cons_intr+0x36>
		if (c == 0)
f010015b:	85 c0                	test   %eax,%eax
f010015d:	74 27                	je     f0100186 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010015f:	8b 0d 64 ff 16 f0    	mov    0xf016ff64,%ecx
f0100165:	8d 51 01             	lea    0x1(%ecx),%edx
f0100168:	89 15 64 ff 16 f0    	mov    %edx,0xf016ff64
f010016e:	88 81 60 fd 16 f0    	mov    %al,-0xfe902a0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100174:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010017a:	75 0a                	jne    f0100186 <cons_intr+0x36>
			cons.wpos = 0;
f010017c:	c7 05 64 ff 16 f0 00 	movl   $0x0,0xf016ff64
f0100183:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100186:	ff d3                	call   *%ebx
f0100188:	83 f8 ff             	cmp    $0xffffffff,%eax
f010018b:	75 ce                	jne    f010015b <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010018d:	83 c4 04             	add    $0x4,%esp
f0100190:	5b                   	pop    %ebx
f0100191:	5d                   	pop    %ebp
f0100192:	c3                   	ret    

f0100193 <kbd_proc_data>:
f0100193:	ba 64 00 00 00       	mov    $0x64,%edx
f0100198:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100199:	a8 01                	test   $0x1,%al
f010019b:	0f 84 f8 00 00 00    	je     f0100299 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001a1:	a8 20                	test   $0x20,%al
f01001a3:	0f 85 f6 00 00 00    	jne    f010029f <kbd_proc_data+0x10c>
f01001a9:	ba 60 00 00 00       	mov    $0x60,%edx
f01001ae:	ec                   	in     (%dx),%al
f01001af:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001b1:	3c e0                	cmp    $0xe0,%al
f01001b3:	75 0d                	jne    f01001c2 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001b5:	83 0d 40 fd 16 f0 40 	orl    $0x40,0xf016fd40
		return 0;
f01001bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01001c1:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001c2:	55                   	push   %ebp
f01001c3:	89 e5                	mov    %esp,%ebp
f01001c5:	53                   	push   %ebx
f01001c6:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001c9:	84 c0                	test   %al,%al
f01001cb:	79 36                	jns    f0100203 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001cd:	8b 0d 40 fd 16 f0    	mov    0xf016fd40,%ecx
f01001d3:	89 cb                	mov    %ecx,%ebx
f01001d5:	83 e3 40             	and    $0x40,%ebx
f01001d8:	83 e0 7f             	and    $0x7f,%eax
f01001db:	85 db                	test   %ebx,%ebx
f01001dd:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001e0:	0f b6 d2             	movzbl %dl,%edx
f01001e3:	0f b6 82 60 42 10 f0 	movzbl -0xfefbda0(%edx),%eax
f01001ea:	83 c8 40             	or     $0x40,%eax
f01001ed:	0f b6 c0             	movzbl %al,%eax
f01001f0:	f7 d0                	not    %eax
f01001f2:	21 c8                	and    %ecx,%eax
f01001f4:	a3 40 fd 16 f0       	mov    %eax,0xf016fd40
		return 0;
f01001f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01001fe:	e9 a4 00 00 00       	jmp    f01002a7 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100203:	8b 0d 40 fd 16 f0    	mov    0xf016fd40,%ecx
f0100209:	f6 c1 40             	test   $0x40,%cl
f010020c:	74 0e                	je     f010021c <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010020e:	83 c8 80             	or     $0xffffff80,%eax
f0100211:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100213:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100216:	89 0d 40 fd 16 f0    	mov    %ecx,0xf016fd40
	}

	shift |= shiftcode[data];
f010021c:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010021f:	0f b6 82 60 42 10 f0 	movzbl -0xfefbda0(%edx),%eax
f0100226:	0b 05 40 fd 16 f0    	or     0xf016fd40,%eax
f010022c:	0f b6 8a 60 41 10 f0 	movzbl -0xfefbea0(%edx),%ecx
f0100233:	31 c8                	xor    %ecx,%eax
f0100235:	a3 40 fd 16 f0       	mov    %eax,0xf016fd40

	c = charcode[shift & (CTL | SHIFT)][data];
f010023a:	89 c1                	mov    %eax,%ecx
f010023c:	83 e1 03             	and    $0x3,%ecx
f010023f:	8b 0c 8d 40 41 10 f0 	mov    -0xfefbec0(,%ecx,4),%ecx
f0100246:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010024a:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010024d:	a8 08                	test   $0x8,%al
f010024f:	74 1b                	je     f010026c <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100251:	89 da                	mov    %ebx,%edx
f0100253:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100256:	83 f9 19             	cmp    $0x19,%ecx
f0100259:	77 05                	ja     f0100260 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f010025b:	83 eb 20             	sub    $0x20,%ebx
f010025e:	eb 0c                	jmp    f010026c <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f0100260:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100263:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100266:	83 fa 19             	cmp    $0x19,%edx
f0100269:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010026c:	f7 d0                	not    %eax
f010026e:	a8 06                	test   $0x6,%al
f0100270:	75 33                	jne    f01002a5 <kbd_proc_data+0x112>
f0100272:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100278:	75 2b                	jne    f01002a5 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f010027a:	83 ec 0c             	sub    $0xc,%esp
f010027d:	68 0d 41 10 f0       	push   $0xf010410d
f0100282:	e8 0e 2b 00 00       	call   f0102d95 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100287:	ba 92 00 00 00       	mov    $0x92,%edx
f010028c:	b8 03 00 00 00       	mov    $0x3,%eax
f0100291:	ee                   	out    %al,(%dx)
f0100292:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100295:	89 d8                	mov    %ebx,%eax
f0100297:	eb 0e                	jmp    f01002a7 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100299:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010029e:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010029f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002a4:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002a5:	89 d8                	mov    %ebx,%eax
}
f01002a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002aa:	c9                   	leave  
f01002ab:	c3                   	ret    

f01002ac <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002ac:	55                   	push   %ebp
f01002ad:	89 e5                	mov    %esp,%ebp
f01002af:	57                   	push   %edi
f01002b0:	56                   	push   %esi
f01002b1:	53                   	push   %ebx
f01002b2:	83 ec 1c             	sub    $0x1c,%esp
f01002b5:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002b7:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002bc:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002c1:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002c6:	eb 09                	jmp    f01002d1 <cons_putc+0x25>
f01002c8:	89 ca                	mov    %ecx,%edx
f01002ca:	ec                   	in     (%dx),%al
f01002cb:	ec                   	in     (%dx),%al
f01002cc:	ec                   	in     (%dx),%al
f01002cd:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002ce:	83 c3 01             	add    $0x1,%ebx
f01002d1:	89 f2                	mov    %esi,%edx
f01002d3:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002d4:	a8 20                	test   $0x20,%al
f01002d6:	75 08                	jne    f01002e0 <cons_putc+0x34>
f01002d8:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002de:	7e e8                	jle    f01002c8 <cons_putc+0x1c>
f01002e0:	89 f8                	mov    %edi,%eax
f01002e2:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002ea:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002eb:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f0:	be 79 03 00 00       	mov    $0x379,%esi
f01002f5:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002fa:	eb 09                	jmp    f0100305 <cons_putc+0x59>
f01002fc:	89 ca                	mov    %ecx,%edx
f01002fe:	ec                   	in     (%dx),%al
f01002ff:	ec                   	in     (%dx),%al
f0100300:	ec                   	in     (%dx),%al
f0100301:	ec                   	in     (%dx),%al
f0100302:	83 c3 01             	add    $0x1,%ebx
f0100305:	89 f2                	mov    %esi,%edx
f0100307:	ec                   	in     (%dx),%al
f0100308:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010030e:	7f 04                	jg     f0100314 <cons_putc+0x68>
f0100310:	84 c0                	test   %al,%al
f0100312:	79 e8                	jns    f01002fc <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100314:	ba 78 03 00 00       	mov    $0x378,%edx
f0100319:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010031d:	ee                   	out    %al,(%dx)
f010031e:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100323:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100328:	ee                   	out    %al,(%dx)
f0100329:	b8 08 00 00 00       	mov    $0x8,%eax
f010032e:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010032f:	89 fa                	mov    %edi,%edx
f0100331:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100337:	89 f8                	mov    %edi,%eax
f0100339:	80 cc 07             	or     $0x7,%ah
f010033c:	85 d2                	test   %edx,%edx
f010033e:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100341:	89 f8                	mov    %edi,%eax
f0100343:	0f b6 c0             	movzbl %al,%eax
f0100346:	83 f8 09             	cmp    $0x9,%eax
f0100349:	74 74                	je     f01003bf <cons_putc+0x113>
f010034b:	83 f8 09             	cmp    $0x9,%eax
f010034e:	7f 0a                	jg     f010035a <cons_putc+0xae>
f0100350:	83 f8 08             	cmp    $0x8,%eax
f0100353:	74 14                	je     f0100369 <cons_putc+0xbd>
f0100355:	e9 99 00 00 00       	jmp    f01003f3 <cons_putc+0x147>
f010035a:	83 f8 0a             	cmp    $0xa,%eax
f010035d:	74 3a                	je     f0100399 <cons_putc+0xed>
f010035f:	83 f8 0d             	cmp    $0xd,%eax
f0100362:	74 3d                	je     f01003a1 <cons_putc+0xf5>
f0100364:	e9 8a 00 00 00       	jmp    f01003f3 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100369:	0f b7 05 68 ff 16 f0 	movzwl 0xf016ff68,%eax
f0100370:	66 85 c0             	test   %ax,%ax
f0100373:	0f 84 e6 00 00 00    	je     f010045f <cons_putc+0x1b3>
			crt_pos--;
f0100379:	83 e8 01             	sub    $0x1,%eax
f010037c:	66 a3 68 ff 16 f0    	mov    %ax,0xf016ff68
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100382:	0f b7 c0             	movzwl %ax,%eax
f0100385:	66 81 e7 00 ff       	and    $0xff00,%di
f010038a:	83 cf 20             	or     $0x20,%edi
f010038d:	8b 15 6c ff 16 f0    	mov    0xf016ff6c,%edx
f0100393:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100397:	eb 78                	jmp    f0100411 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100399:	66 83 05 68 ff 16 f0 	addw   $0x50,0xf016ff68
f01003a0:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003a1:	0f b7 05 68 ff 16 f0 	movzwl 0xf016ff68,%eax
f01003a8:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003ae:	c1 e8 16             	shr    $0x16,%eax
f01003b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003b4:	c1 e0 04             	shl    $0x4,%eax
f01003b7:	66 a3 68 ff 16 f0    	mov    %ax,0xf016ff68
f01003bd:	eb 52                	jmp    f0100411 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003bf:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c4:	e8 e3 fe ff ff       	call   f01002ac <cons_putc>
		cons_putc(' ');
f01003c9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ce:	e8 d9 fe ff ff       	call   f01002ac <cons_putc>
		cons_putc(' ');
f01003d3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d8:	e8 cf fe ff ff       	call   f01002ac <cons_putc>
		cons_putc(' ');
f01003dd:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e2:	e8 c5 fe ff ff       	call   f01002ac <cons_putc>
		cons_putc(' ');
f01003e7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ec:	e8 bb fe ff ff       	call   f01002ac <cons_putc>
f01003f1:	eb 1e                	jmp    f0100411 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003f3:	0f b7 05 68 ff 16 f0 	movzwl 0xf016ff68,%eax
f01003fa:	8d 50 01             	lea    0x1(%eax),%edx
f01003fd:	66 89 15 68 ff 16 f0 	mov    %dx,0xf016ff68
f0100404:	0f b7 c0             	movzwl %ax,%eax
f0100407:	8b 15 6c ff 16 f0    	mov    0xf016ff6c,%edx
f010040d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100411:	66 81 3d 68 ff 16 f0 	cmpw   $0x7cf,0xf016ff68
f0100418:	cf 07 
f010041a:	76 43                	jbe    f010045f <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010041c:	a1 6c ff 16 f0       	mov    0xf016ff6c,%eax
f0100421:	83 ec 04             	sub    $0x4,%esp
f0100424:	68 00 0f 00 00       	push   $0xf00
f0100429:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010042f:	52                   	push   %edx
f0100430:	50                   	push   %eax
f0100431:	e8 41 38 00 00       	call   f0103c77 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100436:	8b 15 6c ff 16 f0    	mov    0xf016ff6c,%edx
f010043c:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100442:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100448:	83 c4 10             	add    $0x10,%esp
f010044b:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100450:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100453:	39 d0                	cmp    %edx,%eax
f0100455:	75 f4                	jne    f010044b <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100457:	66 83 2d 68 ff 16 f0 	subw   $0x50,0xf016ff68
f010045e:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010045f:	8b 0d 70 ff 16 f0    	mov    0xf016ff70,%ecx
f0100465:	b8 0e 00 00 00       	mov    $0xe,%eax
f010046a:	89 ca                	mov    %ecx,%edx
f010046c:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010046d:	0f b7 1d 68 ff 16 f0 	movzwl 0xf016ff68,%ebx
f0100474:	8d 71 01             	lea    0x1(%ecx),%esi
f0100477:	89 d8                	mov    %ebx,%eax
f0100479:	66 c1 e8 08          	shr    $0x8,%ax
f010047d:	89 f2                	mov    %esi,%edx
f010047f:	ee                   	out    %al,(%dx)
f0100480:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100485:	89 ca                	mov    %ecx,%edx
f0100487:	ee                   	out    %al,(%dx)
f0100488:	89 d8                	mov    %ebx,%eax
f010048a:	89 f2                	mov    %esi,%edx
f010048c:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010048d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100490:	5b                   	pop    %ebx
f0100491:	5e                   	pop    %esi
f0100492:	5f                   	pop    %edi
f0100493:	5d                   	pop    %ebp
f0100494:	c3                   	ret    

f0100495 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100495:	80 3d 74 ff 16 f0 00 	cmpb   $0x0,0xf016ff74
f010049c:	74 11                	je     f01004af <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010049e:	55                   	push   %ebp
f010049f:	89 e5                	mov    %esp,%ebp
f01004a1:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004a4:	b8 31 01 10 f0       	mov    $0xf0100131,%eax
f01004a9:	e8 a2 fc ff ff       	call   f0100150 <cons_intr>
}
f01004ae:	c9                   	leave  
f01004af:	f3 c3                	repz ret 

f01004b1 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004b1:	55                   	push   %ebp
f01004b2:	89 e5                	mov    %esp,%ebp
f01004b4:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004b7:	b8 93 01 10 f0       	mov    $0xf0100193,%eax
f01004bc:	e8 8f fc ff ff       	call   f0100150 <cons_intr>
}
f01004c1:	c9                   	leave  
f01004c2:	c3                   	ret    

f01004c3 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004c3:	55                   	push   %ebp
f01004c4:	89 e5                	mov    %esp,%ebp
f01004c6:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004c9:	e8 c7 ff ff ff       	call   f0100495 <serial_intr>
	kbd_intr();
f01004ce:	e8 de ff ff ff       	call   f01004b1 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004d3:	a1 60 ff 16 f0       	mov    0xf016ff60,%eax
f01004d8:	3b 05 64 ff 16 f0    	cmp    0xf016ff64,%eax
f01004de:	74 26                	je     f0100506 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004e0:	8d 50 01             	lea    0x1(%eax),%edx
f01004e3:	89 15 60 ff 16 f0    	mov    %edx,0xf016ff60
f01004e9:	0f b6 88 60 fd 16 f0 	movzbl -0xfe902a0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004f0:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004f2:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004f8:	75 11                	jne    f010050b <cons_getc+0x48>
			cons.rpos = 0;
f01004fa:	c7 05 60 ff 16 f0 00 	movl   $0x0,0xf016ff60
f0100501:	00 00 00 
f0100504:	eb 05                	jmp    f010050b <cons_getc+0x48>
		return c;
	}
	return 0;
f0100506:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010050b:	c9                   	leave  
f010050c:	c3                   	ret    

f010050d <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010050d:	55                   	push   %ebp
f010050e:	89 e5                	mov    %esp,%ebp
f0100510:	57                   	push   %edi
f0100511:	56                   	push   %esi
f0100512:	53                   	push   %ebx
f0100513:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100516:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010051d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100524:	5a a5 
	if (*cp != 0xA55A) {
f0100526:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010052d:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100531:	74 11                	je     f0100544 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100533:	c7 05 70 ff 16 f0 b4 	movl   $0x3b4,0xf016ff70
f010053a:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010053d:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100542:	eb 16                	jmp    f010055a <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100544:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010054b:	c7 05 70 ff 16 f0 d4 	movl   $0x3d4,0xf016ff70
f0100552:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100555:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010055a:	8b 3d 70 ff 16 f0    	mov    0xf016ff70,%edi
f0100560:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100565:	89 fa                	mov    %edi,%edx
f0100567:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100568:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056b:	89 da                	mov    %ebx,%edx
f010056d:	ec                   	in     (%dx),%al
f010056e:	0f b6 c8             	movzbl %al,%ecx
f0100571:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100574:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100579:	89 fa                	mov    %edi,%edx
f010057b:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010057c:	89 da                	mov    %ebx,%edx
f010057e:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010057f:	89 35 6c ff 16 f0    	mov    %esi,0xf016ff6c
	crt_pos = pos;
f0100585:	0f b6 c0             	movzbl %al,%eax
f0100588:	09 c8                	or     %ecx,%eax
f010058a:	66 a3 68 ff 16 f0    	mov    %ax,0xf016ff68
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100590:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100595:	b8 00 00 00 00       	mov    $0x0,%eax
f010059a:	89 f2                	mov    %esi,%edx
f010059c:	ee                   	out    %al,(%dx)
f010059d:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005a2:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005a7:	ee                   	out    %al,(%dx)
f01005a8:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005ad:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005b2:	89 da                	mov    %ebx,%edx
f01005b4:	ee                   	out    %al,(%dx)
f01005b5:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01005bf:	ee                   	out    %al,(%dx)
f01005c0:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005c5:	b8 03 00 00 00       	mov    $0x3,%eax
f01005ca:	ee                   	out    %al,(%dx)
f01005cb:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01005d5:	ee                   	out    %al,(%dx)
f01005d6:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005db:	b8 01 00 00 00       	mov    $0x1,%eax
f01005e0:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005e6:	ec                   	in     (%dx),%al
f01005e7:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005e9:	3c ff                	cmp    $0xff,%al
f01005eb:	0f 95 05 74 ff 16 f0 	setne  0xf016ff74
f01005f2:	89 f2                	mov    %esi,%edx
f01005f4:	ec                   	in     (%dx),%al
f01005f5:	89 da                	mov    %ebx,%edx
f01005f7:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005f8:	80 f9 ff             	cmp    $0xff,%cl
f01005fb:	75 10                	jne    f010060d <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005fd:	83 ec 0c             	sub    $0xc,%esp
f0100600:	68 19 41 10 f0       	push   $0xf0104119
f0100605:	e8 8b 27 00 00       	call   f0102d95 <cprintf>
f010060a:	83 c4 10             	add    $0x10,%esp
}
f010060d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100610:	5b                   	pop    %ebx
f0100611:	5e                   	pop    %esi
f0100612:	5f                   	pop    %edi
f0100613:	5d                   	pop    %ebp
f0100614:	c3                   	ret    

f0100615 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100615:	55                   	push   %ebp
f0100616:	89 e5                	mov    %esp,%ebp
f0100618:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010061b:	8b 45 08             	mov    0x8(%ebp),%eax
f010061e:	e8 89 fc ff ff       	call   f01002ac <cons_putc>
}
f0100623:	c9                   	leave  
f0100624:	c3                   	ret    

f0100625 <getchar>:

int
getchar(void)
{
f0100625:	55                   	push   %ebp
f0100626:	89 e5                	mov    %esp,%ebp
f0100628:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010062b:	e8 93 fe ff ff       	call   f01004c3 <cons_getc>
f0100630:	85 c0                	test   %eax,%eax
f0100632:	74 f7                	je     f010062b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100634:	c9                   	leave  
f0100635:	c3                   	ret    

f0100636 <iscons>:

int
iscons(int fdnum)
{
f0100636:	55                   	push   %ebp
f0100637:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100639:	b8 01 00 00 00       	mov    $0x1,%eax
f010063e:	5d                   	pop    %ebp
f010063f:	c3                   	ret    

f0100640 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100640:	55                   	push   %ebp
f0100641:	89 e5                	mov    %esp,%ebp
f0100643:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100646:	68 60 43 10 f0       	push   $0xf0104360
f010064b:	68 7e 43 10 f0       	push   $0xf010437e
f0100650:	68 83 43 10 f0       	push   $0xf0104383
f0100655:	e8 3b 27 00 00       	call   f0102d95 <cprintf>
f010065a:	83 c4 0c             	add    $0xc,%esp
f010065d:	68 3c 44 10 f0       	push   $0xf010443c
f0100662:	68 8c 43 10 f0       	push   $0xf010438c
f0100667:	68 83 43 10 f0       	push   $0xf0104383
f010066c:	e8 24 27 00 00       	call   f0102d95 <cprintf>
f0100671:	83 c4 0c             	add    $0xc,%esp
f0100674:	68 95 43 10 f0       	push   $0xf0104395
f0100679:	68 b3 43 10 f0       	push   $0xf01043b3
f010067e:	68 83 43 10 f0       	push   $0xf0104383
f0100683:	e8 0d 27 00 00       	call   f0102d95 <cprintf>
	return 0;
}
f0100688:	b8 00 00 00 00       	mov    $0x0,%eax
f010068d:	c9                   	leave  
f010068e:	c3                   	ret    

f010068f <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010068f:	55                   	push   %ebp
f0100690:	89 e5                	mov    %esp,%ebp
f0100692:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100695:	68 bd 43 10 f0       	push   $0xf01043bd
f010069a:	e8 f6 26 00 00       	call   f0102d95 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010069f:	83 c4 08             	add    $0x8,%esp
f01006a2:	68 0c 00 10 00       	push   $0x10000c
f01006a7:	68 64 44 10 f0       	push   $0xf0104464
f01006ac:	e8 e4 26 00 00       	call   f0102d95 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006b1:	83 c4 0c             	add    $0xc,%esp
f01006b4:	68 0c 00 10 00       	push   $0x10000c
f01006b9:	68 0c 00 10 f0       	push   $0xf010000c
f01006be:	68 8c 44 10 f0       	push   $0xf010448c
f01006c3:	e8 cd 26 00 00       	call   f0102d95 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006c8:	83 c4 0c             	add    $0xc,%esp
f01006cb:	68 b1 40 10 00       	push   $0x1040b1
f01006d0:	68 b1 40 10 f0       	push   $0xf01040b1
f01006d5:	68 b0 44 10 f0       	push   $0xf01044b0
f01006da:	e8 b6 26 00 00       	call   f0102d95 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006df:	83 c4 0c             	add    $0xc,%esp
f01006e2:	68 40 fd 16 00       	push   $0x16fd40
f01006e7:	68 40 fd 16 f0       	push   $0xf016fd40
f01006ec:	68 d4 44 10 f0       	push   $0xf01044d4
f01006f1:	e8 9f 26 00 00       	call   f0102d95 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006f6:	83 c4 0c             	add    $0xc,%esp
f01006f9:	68 40 0c 17 00       	push   $0x170c40
f01006fe:	68 40 0c 17 f0       	push   $0xf0170c40
f0100703:	68 f8 44 10 f0       	push   $0xf01044f8
f0100708:	e8 88 26 00 00       	call   f0102d95 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010070d:	b8 3f 10 17 f0       	mov    $0xf017103f,%eax
f0100712:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100717:	83 c4 08             	add    $0x8,%esp
f010071a:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010071f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100725:	85 c0                	test   %eax,%eax
f0100727:	0f 48 c2             	cmovs  %edx,%eax
f010072a:	c1 f8 0a             	sar    $0xa,%eax
f010072d:	50                   	push   %eax
f010072e:	68 1c 45 10 f0       	push   $0xf010451c
f0100733:	e8 5d 26 00 00       	call   f0102d95 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100738:	b8 00 00 00 00       	mov    $0x0,%eax
f010073d:	c9                   	leave  
f010073e:	c3                   	ret    

f010073f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010073f:	55                   	push   %ebp
f0100740:	89 e5                	mov    %esp,%ebp
f0100742:	57                   	push   %edi
f0100743:	56                   	push   %esi
f0100744:	53                   	push   %ebx
f0100745:	83 ec 78             	sub    $0x78,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100748:	89 eb                	mov    %ebp,%ebx

	uint32_t _ebp, _eip;
	// _esp = read_esp();
	_ebp = read_ebp();

	uint32_t args[5] = {0, 0, 0, 0, 0};
f010074a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100751:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100758:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010075f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100766:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");
f010076d:	68 d6 43 10 f0       	push   $0xf01043d6
f0100772:	e8 1e 26 00 00       	call   f0102d95 <cprintf>

	while (_ebp != 0) {
f0100777:	83 c4 10             	add    $0x10,%esp
f010077a:	e9 a6 00 00 00       	jmp    f0100825 <mon_backtrace+0xe6>
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr
f010077f:	8b 73 04             	mov    0x4(%ebx),%esi

		for (int i=0; i<5; i++) {
f0100782:	b8 00 00 00 00       	mov    $0x0,%eax
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
f0100787:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f010078b:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)

	while (_ebp != 0) {
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr

		for (int i=0; i<5; i++) {
f010078f:	83 c0 01             	add    $0x1,%eax
f0100792:	83 f8 05             	cmp    $0x5,%eax
f0100795:	75 f0                	jne    f0100787 <mon_backtrace+0x48>
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
		}

		debuginfo_eip((uintptr_t)_eip, &context);
f0100797:	83 ec 08             	sub    $0x8,%esp
f010079a:	8d 45 bc             	lea    -0x44(%ebp),%eax
f010079d:	50                   	push   %eax
f010079e:	56                   	push   %esi
f010079f:	e8 ae 2a 00 00       	call   f0103252 <debuginfo_eip>

		char function_name[50] = {0};
f01007a4:	c7 45 8a 00 00 00 00 	movl   $0x0,-0x76(%ebp)
f01007ab:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
f01007b2:	8d 7d 8c             	lea    -0x74(%ebp),%edi
f01007b5:	b9 0c 00 00 00       	mov    $0xc,%ecx
f01007ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01007bf:	f3 ab                	rep stos %eax,%es:(%edi)
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f01007c1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
			function_name[i] = context.eip_fn_name[i];
f01007c4:	8b 7d c4             	mov    -0x3c(%ebp),%edi

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f01007c7:	83 c4 10             	add    $0x10,%esp
f01007ca:	eb 0b                	jmp    f01007d7 <mon_backtrace+0x98>
			function_name[i] = context.eip_fn_name[i];
f01007cc:	0f b6 14 07          	movzbl (%edi,%eax,1),%edx
f01007d0:	88 54 05 8a          	mov    %dl,-0x76(%ebp,%eax,1)

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f01007d4:	83 c0 01             	add    $0x1,%eax
f01007d7:	39 c8                	cmp    %ecx,%eax
f01007d9:	7c f1                	jl     f01007cc <mon_backtrace+0x8d>
			function_name[i] = context.eip_fn_name[i];
		}
		function_name[i] = '\0';
f01007db:	85 c9                	test   %ecx,%ecx
f01007dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e2:	0f 48 c8             	cmovs  %eax,%ecx
f01007e5:	c6 44 0d 8a 00       	movb   $0x0,-0x76(%ebp,%ecx,1)

		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", _ebp, _eip, args[0], args[1], args[2], args[3], args[4]);
f01007ea:	ff 75 e4             	pushl  -0x1c(%ebp)
f01007ed:	ff 75 e0             	pushl  -0x20(%ebp)
f01007f0:	ff 75 dc             	pushl  -0x24(%ebp)
f01007f3:	ff 75 d8             	pushl  -0x28(%ebp)
f01007f6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007f9:	56                   	push   %esi
f01007fa:	53                   	push   %ebx
f01007fb:	68 48 45 10 f0       	push   $0xf0104548
f0100800:	e8 90 25 00 00       	call   f0102d95 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f0100805:	83 c4 14             	add    $0x14,%esp
f0100808:	2b 75 cc             	sub    -0x34(%ebp),%esi
f010080b:	56                   	push   %esi
f010080c:	8d 45 8a             	lea    -0x76(%ebp),%eax
f010080f:	50                   	push   %eax
f0100810:	ff 75 c0             	pushl  -0x40(%ebp)
f0100813:	ff 75 bc             	pushl  -0x44(%ebp)
f0100816:	68 e8 43 10 f0       	push   $0xf01043e8
f010081b:	e8 75 25 00 00       	call   f0102d95 <cprintf>

		// _rsp = _ebp + 8;			// old_rsp
		_ebp = *(uint32_t *)_ebp;	// old_ebp
f0100820:	8b 1b                	mov    (%ebx),%ebx
f0100822:	83 c4 20             	add    $0x20,%esp

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");

	while (_ebp != 0) {
f0100825:	85 db                	test   %ebx,%ebx
f0100827:	0f 85 52 ff ff ff    	jne    f010077f <mon_backtrace+0x40>
		_ebp = *(uint32_t *)_ebp;	// old_ebp

	} 

	return 0;
}
f010082d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100832:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100835:	5b                   	pop    %ebx
f0100836:	5e                   	pop    %esi
f0100837:	5f                   	pop    %edi
f0100838:	5d                   	pop    %ebp
f0100839:	c3                   	ret    

f010083a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010083a:	55                   	push   %ebp
f010083b:	89 e5                	mov    %esp,%ebp
f010083d:	57                   	push   %edi
f010083e:	56                   	push   %esi
f010083f:	53                   	push   %ebx
f0100840:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100843:	68 80 45 10 f0       	push   $0xf0104580
f0100848:	e8 48 25 00 00       	call   f0102d95 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010084d:	c7 04 24 a4 45 10 f0 	movl   $0xf01045a4,(%esp)
f0100854:	e8 3c 25 00 00       	call   f0102d95 <cprintf>

	if (tf != NULL)
f0100859:	83 c4 10             	add    $0x10,%esp
f010085c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100860:	74 0e                	je     f0100870 <monitor+0x36>
		print_trapframe(tf);
f0100862:	83 ec 0c             	sub    $0xc,%esp
f0100865:	ff 75 08             	pushl  0x8(%ebp)
f0100868:	e8 3a 26 00 00       	call   f0102ea7 <print_trapframe>
f010086d:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100870:	83 ec 0c             	sub    $0xc,%esp
f0100873:	68 ff 43 10 f0       	push   $0xf01043ff
f0100878:	e8 56 31 00 00       	call   f01039d3 <readline>
f010087d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010087f:	83 c4 10             	add    $0x10,%esp
f0100882:	85 c0                	test   %eax,%eax
f0100884:	74 ea                	je     f0100870 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100886:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010088d:	be 00 00 00 00       	mov    $0x0,%esi
f0100892:	eb 0a                	jmp    f010089e <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100894:	c6 03 00             	movb   $0x0,(%ebx)
f0100897:	89 f7                	mov    %esi,%edi
f0100899:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010089c:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010089e:	0f b6 03             	movzbl (%ebx),%eax
f01008a1:	84 c0                	test   %al,%al
f01008a3:	74 63                	je     f0100908 <monitor+0xce>
f01008a5:	83 ec 08             	sub    $0x8,%esp
f01008a8:	0f be c0             	movsbl %al,%eax
f01008ab:	50                   	push   %eax
f01008ac:	68 03 44 10 f0       	push   $0xf0104403
f01008b1:	e8 37 33 00 00       	call   f0103bed <strchr>
f01008b6:	83 c4 10             	add    $0x10,%esp
f01008b9:	85 c0                	test   %eax,%eax
f01008bb:	75 d7                	jne    f0100894 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01008bd:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008c0:	74 46                	je     f0100908 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008c2:	83 fe 0f             	cmp    $0xf,%esi
f01008c5:	75 14                	jne    f01008db <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008c7:	83 ec 08             	sub    $0x8,%esp
f01008ca:	6a 10                	push   $0x10
f01008cc:	68 08 44 10 f0       	push   $0xf0104408
f01008d1:	e8 bf 24 00 00       	call   f0102d95 <cprintf>
f01008d6:	83 c4 10             	add    $0x10,%esp
f01008d9:	eb 95                	jmp    f0100870 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01008db:	8d 7e 01             	lea    0x1(%esi),%edi
f01008de:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008e2:	eb 03                	jmp    f01008e7 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008e4:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008e7:	0f b6 03             	movzbl (%ebx),%eax
f01008ea:	84 c0                	test   %al,%al
f01008ec:	74 ae                	je     f010089c <monitor+0x62>
f01008ee:	83 ec 08             	sub    $0x8,%esp
f01008f1:	0f be c0             	movsbl %al,%eax
f01008f4:	50                   	push   %eax
f01008f5:	68 03 44 10 f0       	push   $0xf0104403
f01008fa:	e8 ee 32 00 00       	call   f0103bed <strchr>
f01008ff:	83 c4 10             	add    $0x10,%esp
f0100902:	85 c0                	test   %eax,%eax
f0100904:	74 de                	je     f01008e4 <monitor+0xaa>
f0100906:	eb 94                	jmp    f010089c <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100908:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010090f:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100910:	85 f6                	test   %esi,%esi
f0100912:	0f 84 58 ff ff ff    	je     f0100870 <monitor+0x36>
f0100918:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010091d:	83 ec 08             	sub    $0x8,%esp
f0100920:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100923:	ff 34 85 e0 45 10 f0 	pushl  -0xfefba20(,%eax,4)
f010092a:	ff 75 a8             	pushl  -0x58(%ebp)
f010092d:	e8 5d 32 00 00       	call   f0103b8f <strcmp>
f0100932:	83 c4 10             	add    $0x10,%esp
f0100935:	85 c0                	test   %eax,%eax
f0100937:	75 21                	jne    f010095a <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100939:	83 ec 04             	sub    $0x4,%esp
f010093c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010093f:	ff 75 08             	pushl  0x8(%ebp)
f0100942:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100945:	52                   	push   %edx
f0100946:	56                   	push   %esi
f0100947:	ff 14 85 e8 45 10 f0 	call   *-0xfefba18(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010094e:	83 c4 10             	add    $0x10,%esp
f0100951:	85 c0                	test   %eax,%eax
f0100953:	78 25                	js     f010097a <monitor+0x140>
f0100955:	e9 16 ff ff ff       	jmp    f0100870 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010095a:	83 c3 01             	add    $0x1,%ebx
f010095d:	83 fb 03             	cmp    $0x3,%ebx
f0100960:	75 bb                	jne    f010091d <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100962:	83 ec 08             	sub    $0x8,%esp
f0100965:	ff 75 a8             	pushl  -0x58(%ebp)
f0100968:	68 25 44 10 f0       	push   $0xf0104425
f010096d:	e8 23 24 00 00       	call   f0102d95 <cprintf>
f0100972:	83 c4 10             	add    $0x10,%esp
f0100975:	e9 f6 fe ff ff       	jmp    f0100870 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010097a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010097d:	5b                   	pop    %ebx
f010097e:	5e                   	pop    %esi
f010097f:	5f                   	pop    %edi
f0100980:	5d                   	pop    %ebp
f0100981:	c3                   	ret    

f0100982 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100982:	55                   	push   %ebp
f0100983:	89 e5                	mov    %esp,%ebp
f0100985:	56                   	push   %esi
f0100986:	53                   	push   %ebx
f0100987:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100989:	83 ec 0c             	sub    $0xc,%esp
f010098c:	50                   	push   %eax
f010098d:	e8 9c 23 00 00       	call   f0102d2e <mc146818_read>
f0100992:	89 c6                	mov    %eax,%esi
f0100994:	83 c3 01             	add    $0x1,%ebx
f0100997:	89 1c 24             	mov    %ebx,(%esp)
f010099a:	e8 8f 23 00 00       	call   f0102d2e <mc146818_read>
f010099f:	c1 e0 08             	shl    $0x8,%eax
f01009a2:	09 f0                	or     %esi,%eax
}
f01009a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009a7:	5b                   	pop    %ebx
f01009a8:	5e                   	pop    %esi
f01009a9:	5d                   	pop    %ebp
f01009aa:	c3                   	ret    

f01009ab <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01009ab:	83 3d 78 ff 16 f0 00 	cmpl   $0x0,0xf016ff78
f01009b2:	75 11                	jne    f01009c5 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01009b4:	ba 3f 1c 17 f0       	mov    $0xf0171c3f,%edx
f01009b9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01009bf:	89 15 78 ff 16 f0    	mov    %edx,0xf016ff78
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f01009c5:	8b 15 78 ff 16 f0    	mov    0xf016ff78,%edx
f01009cb:	89 c1                	mov    %eax,%ecx
f01009cd:	f7 d1                	not    %ecx
f01009cf:	39 ca                	cmp    %ecx,%edx
f01009d1:	76 17                	jbe    f01009ea <boot_alloc+0x3f>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01009d3:	55                   	push   %ebp
f01009d4:	89 e5                	mov    %esp,%ebp
f01009d6:	83 ec 0c             	sub    $0xc,%esp
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
		panic("boot_alloc: out of memory\n");
f01009d9:	68 04 46 10 f0       	push   $0xf0104604
f01009de:	6a 6c                	push   $0x6c
f01009e0:	68 1f 46 10 f0       	push   $0xf010461f
f01009e5:	e8 b6 f6 ff ff       	call   f01000a0 <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f01009ea:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f01009f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009f6:	a3 78 ff 16 f0       	mov    %eax,0xf016ff78

	return result;
}
f01009fb:	89 d0                	mov    %edx,%eax
f01009fd:	c3                   	ret    

f01009fe <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01009fe:	89 d1                	mov    %edx,%ecx
f0100a00:	c1 e9 16             	shr    $0x16,%ecx
f0100a03:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a06:	a8 01                	test   $0x1,%al
f0100a08:	74 52                	je     f0100a5c <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a0a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a0f:	89 c1                	mov    %eax,%ecx
f0100a11:	c1 e9 0c             	shr    $0xc,%ecx
f0100a14:	3b 0d 48 0c 17 f0    	cmp    0xf0170c48,%ecx
f0100a1a:	72 1b                	jb     f0100a37 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a1c:	55                   	push   %ebp
f0100a1d:	89 e5                	mov    %esp,%ebp
f0100a1f:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a22:	50                   	push   %eax
f0100a23:	68 04 49 10 f0       	push   $0xf0104904
f0100a28:	68 a4 03 00 00       	push   $0x3a4
f0100a2d:	68 1f 46 10 f0       	push   $0xf010461f
f0100a32:	e8 69 f6 ff ff       	call   f01000a0 <_panic>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));

	// cprintf("[?] In check_va2pa\n");
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
f0100a37:	c1 ea 0c             	shr    $0xc,%edx
f0100a3a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a40:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a47:	89 c2                	mov    %eax,%edx
f0100a49:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a51:	85 d2                	test   %edx,%edx
f0100a53:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a58:	0f 44 c2             	cmove  %edx,%eax
f0100a5b:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a61:	c3                   	ret    

f0100a62 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a62:	55                   	push   %ebp
f0100a63:	89 e5                	mov    %esp,%ebp
f0100a65:	57                   	push   %edi
f0100a66:	56                   	push   %esi
f0100a67:	53                   	push   %ebx
f0100a68:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a6b:	84 c0                	test   %al,%al
f0100a6d:	0f 85 81 02 00 00    	jne    f0100cf4 <check_page_free_list+0x292>
f0100a73:	e9 8e 02 00 00       	jmp    f0100d06 <check_page_free_list+0x2a4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a78:	83 ec 04             	sub    $0x4,%esp
f0100a7b:	68 28 49 10 f0       	push   $0xf0104928
f0100a80:	68 de 02 00 00       	push   $0x2de
f0100a85:	68 1f 46 10 f0       	push   $0xf010461f
f0100a8a:	e8 11 f6 ff ff       	call   f01000a0 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a8f:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a92:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a95:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a98:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a9b:	89 c2                	mov    %eax,%edx
f0100a9d:	2b 15 50 0c 17 f0    	sub    0xf0170c50,%edx
f0100aa3:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100aa9:	0f 95 c2             	setne  %dl
f0100aac:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100aaf:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ab3:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ab5:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ab9:	8b 00                	mov    (%eax),%eax
f0100abb:	85 c0                	test   %eax,%eax
f0100abd:	75 dc                	jne    f0100a9b <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100abf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ac2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ac8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100acb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ace:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ad0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ad3:	a3 7c ff 16 f0       	mov    %eax,0xf016ff7c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ad8:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100add:	8b 1d 7c ff 16 f0    	mov    0xf016ff7c,%ebx
f0100ae3:	eb 53                	jmp    f0100b38 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ae5:	89 d8                	mov    %ebx,%eax
f0100ae7:	2b 05 50 0c 17 f0    	sub    0xf0170c50,%eax
f0100aed:	c1 f8 03             	sar    $0x3,%eax
f0100af0:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100af3:	89 c2                	mov    %eax,%edx
f0100af5:	c1 ea 16             	shr    $0x16,%edx
f0100af8:	39 f2                	cmp    %esi,%edx
f0100afa:	73 3a                	jae    f0100b36 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100afc:	89 c2                	mov    %eax,%edx
f0100afe:	c1 ea 0c             	shr    $0xc,%edx
f0100b01:	3b 15 48 0c 17 f0    	cmp    0xf0170c48,%edx
f0100b07:	72 12                	jb     f0100b1b <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b09:	50                   	push   %eax
f0100b0a:	68 04 49 10 f0       	push   $0xf0104904
f0100b0f:	6a 56                	push   $0x56
f0100b11:	68 2b 46 10 f0       	push   $0xf010462b
f0100b16:	e8 85 f5 ff ff       	call   f01000a0 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b1b:	83 ec 04             	sub    $0x4,%esp
f0100b1e:	68 80 00 00 00       	push   $0x80
f0100b23:	68 97 00 00 00       	push   $0x97
f0100b28:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b2d:	50                   	push   %eax
f0100b2e:	e8 f7 30 00 00       	call   f0103c2a <memset>
f0100b33:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b36:	8b 1b                	mov    (%ebx),%ebx
f0100b38:	85 db                	test   %ebx,%ebx
f0100b3a:	75 a9                	jne    f0100ae5 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b3c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b41:	e8 65 fe ff ff       	call   f01009ab <boot_alloc>
f0100b46:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b49:	8b 15 7c ff 16 f0    	mov    0xf016ff7c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b4f:	8b 0d 50 0c 17 f0    	mov    0xf0170c50,%ecx
		assert(pp < pages + npages);
f0100b55:	a1 48 0c 17 f0       	mov    0xf0170c48,%eax
f0100b5a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b5d:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b60:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b63:	be 00 00 00 00       	mov    $0x0,%esi
f0100b68:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b6b:	e9 30 01 00 00       	jmp    f0100ca0 <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b70:	39 ca                	cmp    %ecx,%edx
f0100b72:	73 19                	jae    f0100b8d <check_page_free_list+0x12b>
f0100b74:	68 39 46 10 f0       	push   $0xf0104639
f0100b79:	68 45 46 10 f0       	push   $0xf0104645
f0100b7e:	68 f8 02 00 00       	push   $0x2f8
f0100b83:	68 1f 46 10 f0       	push   $0xf010461f
f0100b88:	e8 13 f5 ff ff       	call   f01000a0 <_panic>
		assert(pp < pages + npages);
f0100b8d:	39 fa                	cmp    %edi,%edx
f0100b8f:	72 19                	jb     f0100baa <check_page_free_list+0x148>
f0100b91:	68 5a 46 10 f0       	push   $0xf010465a
f0100b96:	68 45 46 10 f0       	push   $0xf0104645
f0100b9b:	68 f9 02 00 00       	push   $0x2f9
f0100ba0:	68 1f 46 10 f0       	push   $0xf010461f
f0100ba5:	e8 f6 f4 ff ff       	call   f01000a0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100baa:	89 d0                	mov    %edx,%eax
f0100bac:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100baf:	a8 07                	test   $0x7,%al
f0100bb1:	74 19                	je     f0100bcc <check_page_free_list+0x16a>
f0100bb3:	68 4c 49 10 f0       	push   $0xf010494c
f0100bb8:	68 45 46 10 f0       	push   $0xf0104645
f0100bbd:	68 fa 02 00 00       	push   $0x2fa
f0100bc2:	68 1f 46 10 f0       	push   $0xf010461f
f0100bc7:	e8 d4 f4 ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bcc:	c1 f8 03             	sar    $0x3,%eax
f0100bcf:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100bd2:	85 c0                	test   %eax,%eax
f0100bd4:	75 19                	jne    f0100bef <check_page_free_list+0x18d>
f0100bd6:	68 6e 46 10 f0       	push   $0xf010466e
f0100bdb:	68 45 46 10 f0       	push   $0xf0104645
f0100be0:	68 fd 02 00 00       	push   $0x2fd
f0100be5:	68 1f 46 10 f0       	push   $0xf010461f
f0100bea:	e8 b1 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bef:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bf4:	75 19                	jne    f0100c0f <check_page_free_list+0x1ad>
f0100bf6:	68 7f 46 10 f0       	push   $0xf010467f
f0100bfb:	68 45 46 10 f0       	push   $0xf0104645
f0100c00:	68 fe 02 00 00       	push   $0x2fe
f0100c05:	68 1f 46 10 f0       	push   $0xf010461f
f0100c0a:	e8 91 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c0f:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c14:	75 19                	jne    f0100c2f <check_page_free_list+0x1cd>
f0100c16:	68 80 49 10 f0       	push   $0xf0104980
f0100c1b:	68 45 46 10 f0       	push   $0xf0104645
f0100c20:	68 ff 02 00 00       	push   $0x2ff
f0100c25:	68 1f 46 10 f0       	push   $0xf010461f
f0100c2a:	e8 71 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c2f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c34:	75 19                	jne    f0100c4f <check_page_free_list+0x1ed>
f0100c36:	68 98 46 10 f0       	push   $0xf0104698
f0100c3b:	68 45 46 10 f0       	push   $0xf0104645
f0100c40:	68 00 03 00 00       	push   $0x300
f0100c45:	68 1f 46 10 f0       	push   $0xf010461f
f0100c4a:	e8 51 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c4f:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c54:	76 3f                	jbe    f0100c95 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c56:	89 c3                	mov    %eax,%ebx
f0100c58:	c1 eb 0c             	shr    $0xc,%ebx
f0100c5b:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100c5e:	77 12                	ja     f0100c72 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c60:	50                   	push   %eax
f0100c61:	68 04 49 10 f0       	push   $0xf0104904
f0100c66:	6a 56                	push   $0x56
f0100c68:	68 2b 46 10 f0       	push   $0xf010462b
f0100c6d:	e8 2e f4 ff ff       	call   f01000a0 <_panic>
f0100c72:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c77:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c7a:	76 1e                	jbe    f0100c9a <check_page_free_list+0x238>
f0100c7c:	68 a4 49 10 f0       	push   $0xf01049a4
f0100c81:	68 45 46 10 f0       	push   $0xf0104645
f0100c86:	68 01 03 00 00       	push   $0x301
f0100c8b:	68 1f 46 10 f0       	push   $0xf010461f
f0100c90:	e8 0b f4 ff ff       	call   f01000a0 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c95:	83 c6 01             	add    $0x1,%esi
f0100c98:	eb 04                	jmp    f0100c9e <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100c9a:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c9e:	8b 12                	mov    (%edx),%edx
f0100ca0:	85 d2                	test   %edx,%edx
f0100ca2:	0f 85 c8 fe ff ff    	jne    f0100b70 <check_page_free_list+0x10e>
f0100ca8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100cab:	85 f6                	test   %esi,%esi
f0100cad:	7f 19                	jg     f0100cc8 <check_page_free_list+0x266>
f0100caf:	68 b2 46 10 f0       	push   $0xf01046b2
f0100cb4:	68 45 46 10 f0       	push   $0xf0104645
f0100cb9:	68 09 03 00 00       	push   $0x309
f0100cbe:	68 1f 46 10 f0       	push   $0xf010461f
f0100cc3:	e8 d8 f3 ff ff       	call   f01000a0 <_panic>
	assert(nfree_extmem > 0);
f0100cc8:	85 db                	test   %ebx,%ebx
f0100cca:	7f 19                	jg     f0100ce5 <check_page_free_list+0x283>
f0100ccc:	68 c4 46 10 f0       	push   $0xf01046c4
f0100cd1:	68 45 46 10 f0       	push   $0xf0104645
f0100cd6:	68 0a 03 00 00       	push   $0x30a
f0100cdb:	68 1f 46 10 f0       	push   $0xf010461f
f0100ce0:	e8 bb f3 ff ff       	call   f01000a0 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100ce5:	83 ec 0c             	sub    $0xc,%esp
f0100ce8:	68 ec 49 10 f0       	push   $0xf01049ec
f0100ced:	e8 a3 20 00 00       	call   f0102d95 <cprintf>
}
f0100cf2:	eb 29                	jmp    f0100d1d <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100cf4:	a1 7c ff 16 f0       	mov    0xf016ff7c,%eax
f0100cf9:	85 c0                	test   %eax,%eax
f0100cfb:	0f 85 8e fd ff ff    	jne    f0100a8f <check_page_free_list+0x2d>
f0100d01:	e9 72 fd ff ff       	jmp    f0100a78 <check_page_free_list+0x16>
f0100d06:	83 3d 7c ff 16 f0 00 	cmpl   $0x0,0xf016ff7c
f0100d0d:	0f 84 65 fd ff ff    	je     f0100a78 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d13:	be 00 04 00 00       	mov    $0x400,%esi
f0100d18:	e9 c0 fd ff ff       	jmp    f0100add <check_page_free_list+0x7b>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d20:	5b                   	pop    %ebx
f0100d21:	5e                   	pop    %esi
f0100d22:	5f                   	pop    %edi
f0100d23:	5d                   	pop    %ebp
f0100d24:	c3                   	ret    

f0100d25 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d25:	55                   	push   %ebp
f0100d26:	89 e5                	mov    %esp,%ebp
f0100d28:	56                   	push   %esi
f0100d29:	53                   	push   %ebx
	// 	pages[i].pp_link = page_free_list;
	// 	page_free_list = &pages[i];
	// }

	// 1)	first page in use
	pages[0].pp_ref = 1;
f0100d2a:	a1 50 0c 17 f0       	mov    0xf0170c50,%eax
f0100d2f:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100d35:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100d3b:	8b 35 80 ff 16 f0    	mov    0xf016ff80,%esi
f0100d41:	8b 0d 7c ff 16 f0    	mov    0xf016ff7c,%ecx
f0100d47:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d4c:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100d51:	eb 27                	jmp    f0100d7a <page_init+0x55>
		pages[i].pp_ref = 0;
f0100d53:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100d5a:	89 c2                	mov    %eax,%edx
f0100d5c:	03 15 50 0c 17 f0    	add    0xf0170c50,%edx
f0100d62:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100d68:	89 0a                	mov    %ecx,(%edx)
	// 1)	first page in use
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100d6a:	83 c3 01             	add    $0x1,%ebx
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100d6d:	03 05 50 0c 17 f0    	add    0xf0170c50,%eax
f0100d73:	89 c1                	mov    %eax,%ecx
f0100d75:	b8 01 00 00 00       	mov    $0x1,%eax
	// 1)	first page in use
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100d7a:	39 f3                	cmp    %esi,%ebx
f0100d7c:	72 d5                	jb     f0100d53 <page_init+0x2e>
f0100d7e:	84 c0                	test   %al,%al
f0100d80:	74 06                	je     f0100d88 <page_init+0x63>
f0100d82:	89 0d 7c ff 16 f0    	mov    %ecx,0xf016ff7c
f0100d88:	8b 0d 7c ff 16 f0    	mov    0xf016ff7c,%ecx
f0100d8e:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100d95:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d9a:	eb 23                	jmp    f0100dbf <page_init+0x9a>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100d9c:	89 c2                	mov    %eax,%edx
f0100d9e:	03 15 50 0c 17 f0    	add    0xf0170c50,%edx
f0100da4:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100daa:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100dac:	89 c1                	mov    %eax,%ecx
f0100dae:	03 0d 50 0c 17 f0    	add    0xf0170c50,%ecx
		page_free_list = &pages[i];
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
f0100db4:	83 c3 01             	add    $0x1,%ebx
f0100db7:	83 c0 08             	add    $0x8,%eax
f0100dba:	ba 01 00 00 00       	mov    $0x1,%edx
f0100dbf:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100dc5:	76 d5                	jbe    f0100d9c <page_init+0x77>
f0100dc7:	84 d2                	test   %dl,%dl
f0100dc9:	74 06                	je     f0100dd1 <page_init+0xac>
f0100dcb:	89 0d 7c ff 16 f0    	mov    %ecx,0xf016ff7c
f0100dd1:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100dd8:	eb 1a                	jmp    f0100df4 <page_init+0xcf>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100dda:	89 c2                	mov    %eax,%edx
f0100ddc:	03 15 50 0c 17 f0    	add    0xf0170c50,%edx
f0100de2:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = 0;
f0100de8:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
f0100dee:	83 c3 01             	add    $0x1,%ebx
f0100df1:	83 c0 08             	add    $0x8,%eax
f0100df4:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100dfa:	76 de                	jbe    f0100dda <page_init+0xb5>
f0100dfc:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f0100e03:	eb 1a                	jmp    f0100e1f <page_init+0xfa>


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100e05:	89 f0                	mov    %esi,%eax
f0100e07:	03 05 50 0c 17 f0    	add    0xf0170c50,%eax
f0100e0d:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = 0;
f0100e13:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
f0100e19:	83 c3 01             	add    $0x1,%ebx
f0100e1c:	83 c6 08             	add    $0x8,%esi
f0100e1f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e24:	e8 82 fb ff ff       	call   f01009ab <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e29:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e2e:	77 15                	ja     f0100e45 <page_init+0x120>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e30:	50                   	push   %eax
f0100e31:	68 10 4a 10 f0       	push   $0xf0104a10
f0100e36:	68 47 01 00 00       	push   $0x147
f0100e3b:	68 1f 46 10 f0       	push   $0xf010461f
f0100e40:	e8 5b f2 ff ff       	call   f01000a0 <_panic>
f0100e45:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e4a:	c1 e8 0c             	shr    $0xc,%eax
f0100e4d:	39 c3                	cmp    %eax,%ebx
f0100e4f:	72 b4                	jb     f0100e05 <page_init+0xe0>
f0100e51:	8b 0d 7c ff 16 f0    	mov    0xf016ff7c,%ecx
f0100e57:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100e5e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e63:	eb 23                	jmp    f0100e88 <page_init+0x163>
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f0100e65:	89 c2                	mov    %eax,%edx
f0100e67:	03 15 50 0c 17 f0    	add    0xf0170c50,%edx
f0100e6d:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100e73:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100e75:	89 c1                	mov    %eax,%ecx
f0100e77:	03 0d 50 0c 17 f0    	add    0xf0170c50,%ecx
		pages[i].pp_link = 0;
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
f0100e7d:	83 c3 01             	add    $0x1,%ebx
f0100e80:	83 c0 08             	add    $0x8,%eax
f0100e83:	ba 01 00 00 00       	mov    $0x1,%edx
f0100e88:	3b 1d 48 0c 17 f0    	cmp    0xf0170c48,%ebx
f0100e8e:	72 d5                	jb     f0100e65 <page_init+0x140>
f0100e90:	84 d2                	test   %dl,%dl
f0100e92:	74 06                	je     f0100e9a <page_init+0x175>
f0100e94:	89 0d 7c ff 16 f0    	mov    %ecx,0xf016ff7c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

}
f0100e9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e9d:	5b                   	pop    %ebx
f0100e9e:	5e                   	pop    %esi
f0100e9f:	5d                   	pop    %ebp
f0100ea0:	c3                   	ret    

f0100ea1 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100ea1:	55                   	push   %ebp
f0100ea2:	89 e5                	mov    %esp,%ebp
f0100ea4:	56                   	push   %esi
f0100ea5:	53                   	push   %ebx
	// Fill this function in

	// no more page in free list, we run out of free memory
	if (page_free_list == 0)
f0100ea6:	8b 1d 7c ff 16 f0    	mov    0xf016ff7c,%ebx
f0100eac:	85 db                	test   %ebx,%ebx
f0100eae:	74 59                	je     f0100f09 <page_alloc+0x68>
		return 0;

	// get the previous page in free link
	struct PageInfo* last_free = page_free_list->pp_link;
f0100eb0:	8b 33                	mov    (%ebx),%esi
	struct PageInfo* result = page_free_list;

	// get a free page from the list
	page_free_list->pp_link = 0;
f0100eb2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) {
f0100eb8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100ebc:	74 45                	je     f0100f03 <page_alloc+0x62>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ebe:	89 d8                	mov    %ebx,%eax
f0100ec0:	2b 05 50 0c 17 f0    	sub    0xf0170c50,%eax
f0100ec6:	c1 f8 03             	sar    $0x3,%eax
f0100ec9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ecc:	89 c2                	mov    %eax,%edx
f0100ece:	c1 ea 0c             	shr    $0xc,%edx
f0100ed1:	3b 15 48 0c 17 f0    	cmp    0xf0170c48,%edx
f0100ed7:	72 12                	jb     f0100eeb <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ed9:	50                   	push   %eax
f0100eda:	68 04 49 10 f0       	push   $0xf0104904
f0100edf:	6a 56                	push   $0x56
f0100ee1:	68 2b 46 10 f0       	push   $0xf010462b
f0100ee6:	e8 b5 f1 ff ff       	call   f01000a0 <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f0100eeb:	83 ec 04             	sub    $0x4,%esp
f0100eee:	68 00 10 00 00       	push   $0x1000
f0100ef3:	6a 00                	push   $0x0
f0100ef5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100efa:	50                   	push   %eax
f0100efb:	e8 2a 2d 00 00       	call   f0103c2a <memset>
f0100f00:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f0100f03:	89 35 7c ff 16 f0    	mov    %esi,0xf016ff7c

	return result;
}
f0100f09:	89 d8                	mov    %ebx,%eax
f0100f0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f0e:	5b                   	pop    %ebx
f0100f0f:	5e                   	pop    %esi
f0100f10:	5d                   	pop    %ebp
f0100f11:	c3                   	ret    

f0100f12 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f12:	55                   	push   %ebp
f0100f13:	89 e5                	mov    %esp,%ebp
f0100f15:	83 ec 08             	sub    $0x8,%esp
f0100f18:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.

	if (pp == 0)
f0100f1b:	85 c0                	test   %eax,%eax
f0100f1d:	74 47                	je     f0100f66 <page_free+0x54>
		return;
	if (pp->pp_link != 0)
f0100f1f:	83 38 00             	cmpl   $0x0,(%eax)
f0100f22:	74 17                	je     f0100f3b <page_free+0x29>
		panic("page_free: double free or corrupted\n");
f0100f24:	83 ec 04             	sub    $0x4,%esp
f0100f27:	68 34 4a 10 f0       	push   $0xf0104a34
f0100f2c:	68 8c 01 00 00       	push   $0x18c
f0100f31:	68 1f 46 10 f0       	push   $0xf010461f
f0100f36:	e8 65 f1 ff ff       	call   f01000a0 <_panic>
	if (pp->pp_ref != 0)
f0100f3b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f40:	74 17                	je     f0100f59 <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0100f42:	83 ec 04             	sub    $0x4,%esp
f0100f45:	68 5c 4a 10 f0       	push   $0xf0104a5c
f0100f4a:	68 8e 01 00 00       	push   $0x18e
f0100f4f:	68 1f 46 10 f0       	push   $0xf010461f
f0100f54:	e8 47 f1 ff ff       	call   f01000a0 <_panic>

	pp->pp_link = page_free_list;
f0100f59:	8b 15 7c ff 16 f0    	mov    0xf016ff7c,%edx
f0100f5f:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f61:	a3 7c ff 16 f0       	mov    %eax,0xf016ff7c

}
f0100f66:	c9                   	leave  
f0100f67:	c3                   	ret    

f0100f68 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f68:	55                   	push   %ebp
f0100f69:	89 e5                	mov    %esp,%ebp
f0100f6b:	83 ec 08             	sub    $0x8,%esp
f0100f6e:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f71:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f75:	83 e8 01             	sub    $0x1,%eax
f0100f78:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f7c:	66 85 c0             	test   %ax,%ax
f0100f7f:	75 0c                	jne    f0100f8d <page_decref+0x25>
		page_free(pp);
f0100f81:	83 ec 0c             	sub    $0xc,%esp
f0100f84:	52                   	push   %edx
f0100f85:	e8 88 ff ff ff       	call   f0100f12 <page_free>
f0100f8a:	83 c4 10             	add    $0x10,%esp
}
f0100f8d:	c9                   	leave  
f0100f8e:	c3                   	ret    

f0100f8f <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f8f:	55                   	push   %ebp
f0100f90:	89 e5                	mov    %esp,%ebp
f0100f92:	56                   	push   %esi
f0100f93:	53                   	push   %ebx
f0100f94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	// we have virtual address
	// cprintf("[?] %x\n", va);
	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f0100f97:	89 de                	mov    %ebx,%esi
f0100f99:	c1 ee 0c             	shr    $0xc,%esi
f0100f9c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
f0100fa2:	c1 eb 16             	shr    $0x16,%ebx
f0100fa5:	c1 e3 02             	shl    $0x2,%ebx
f0100fa8:	03 5d 08             	add    0x8(%ebp),%ebx
f0100fab:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100fae:	75 30                	jne    f0100fe0 <pgdir_walk+0x51>
		if (create == 0)
f0100fb0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100fb4:	74 5c                	je     f0101012 <pgdir_walk+0x83>
			return NULL;
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f0100fb6:	83 ec 0c             	sub    $0xc,%esp
f0100fb9:	6a 01                	push   $0x1
f0100fbb:	e8 e1 fe ff ff       	call   f0100ea1 <page_alloc>
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
f0100fc0:	83 c4 10             	add    $0x10,%esp
f0100fc3:	85 c0                	test   %eax,%eax
f0100fc5:	74 52                	je     f0101019 <pgdir_walk+0x8a>
		// set level 1 page table entry to this new level 2 page table
		// this new page is for level2 PT, so flags are:
		// 	PTE_P: this page is present
		//	PTE_U: user process can use this page
		//	PTE_W: this page can be edit
		pgdir[Page_Directory_Index] = page2pa(new_page) | PTE_P | PTE_U | PTE_W;
f0100fc7:	89 c2                	mov    %eax,%edx
f0100fc9:	2b 15 50 0c 17 f0    	sub    0xf0170c50,%edx
f0100fcf:	c1 fa 03             	sar    $0x3,%edx
f0100fd2:	c1 e2 0c             	shl    $0xc,%edx
f0100fd5:	83 ca 07             	or     $0x7,%edx
f0100fd8:	89 13                	mov    %edx,(%ebx)
		new_page->pp_ref = 1;
f0100fda:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	// cprintf("[?] %x\n", KADDR(PTE_ADDR(pgdir[Page_Directory_Index])));
	
	// remember each entry is 4 byte long
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));
f0100fe0:	8b 03                	mov    (%ebx),%eax
f0100fe2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fe7:	89 c2                	mov    %eax,%edx
f0100fe9:	c1 ea 0c             	shr    $0xc,%edx
f0100fec:	3b 15 48 0c 17 f0    	cmp    0xf0170c48,%edx
f0100ff2:	72 15                	jb     f0101009 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff4:	50                   	push   %eax
f0100ff5:	68 04 49 10 f0       	push   $0xf0104904
f0100ffa:	68 db 01 00 00       	push   $0x1db
f0100fff:	68 1f 46 10 f0       	push   $0xf010461f
f0101004:	e8 97 f0 ff ff       	call   f01000a0 <_panic>

	return &p[Page_Table_Index];
f0101009:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0101010:	eb 0c                	jmp    f010101e <pgdir_walk+0x8f>
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
		if (create == 0)
			return NULL;
f0101012:	b8 00 00 00 00       	mov    $0x0,%eax
f0101017:	eb 05                	jmp    f010101e <pgdir_walk+0x8f>
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
			return NULL;
f0101019:	b8 00 00 00 00       	mov    $0x0,%eax
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));

	return &p[Page_Table_Index];
}
f010101e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101021:	5b                   	pop    %ebx
f0101022:	5e                   	pop    %esi
f0101023:	5d                   	pop    %ebp
f0101024:	c3                   	ret    

f0101025 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101025:	55                   	push   %ebp
f0101026:	89 e5                	mov    %esp,%ebp
f0101028:	57                   	push   %edi
f0101029:	56                   	push   %esi
f010102a:	53                   	push   %ebx
f010102b:	83 ec 1c             	sub    $0x1c,%esp
f010102e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101031:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in	
	if (size % PGSIZE != 0)
f0101034:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
f010103a:	74 17                	je     f0101053 <boot_map_region+0x2e>
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
f010103c:	83 ec 04             	sub    $0x4,%esp
f010103f:	68 a0 4a 10 f0       	push   $0xf0104aa0
f0101044:	68 f0 01 00 00       	push   $0x1f0
f0101049:	68 1f 46 10 f0       	push   $0xf010461f
f010104e:	e8 4d f0 ff ff       	call   f01000a0 <_panic>
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
f0101053:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101059:	75 23                	jne    f010107e <boot_map_region+0x59>
f010105b:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0101060:	75 1c                	jne    f010107e <boot_map_region+0x59>
f0101062:	c1 e9 0c             	shr    $0xc,%ecx
f0101065:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f0101068:	89 c3                	mov    %eax,%ebx
f010106a:	be 00 00 00 00       	mov    $0x0,%esi

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f010106f:	89 d7                	mov    %edx,%edi
f0101071:	29 c7                	sub    %eax,%edi

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f0101073:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101076:	83 c8 01             	or     $0x1,%eax
f0101079:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010107c:	eb 5c                	jmp    f01010da <boot_map_region+0xb5>
	// Fill this function in	
	if (size % PGSIZE != 0)
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");
f010107e:	83 ec 04             	sub    $0x4,%esp
f0101081:	68 d4 4a 10 f0       	push   $0xf0104ad4
f0101086:	68 f3 01 00 00       	push   $0x1f3
f010108b:	68 1f 46 10 f0       	push   $0xf010461f
f0101090:	e8 0b f0 ff ff       	call   f01000a0 <_panic>
	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f0101095:	83 ec 04             	sub    $0x4,%esp
f0101098:	6a 01                	push   $0x1
f010109a:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f010109d:	50                   	push   %eax
f010109e:	ff 75 e0             	pushl  -0x20(%ebp)
f01010a1:	e8 e9 fe ff ff       	call   f0100f8f <pgdir_walk>

		if (pte == 0)
f01010a6:	83 c4 10             	add    $0x10,%esp
f01010a9:	85 c0                	test   %eax,%eax
f01010ab:	75 17                	jne    f01010c4 <boot_map_region+0x9f>
			panic("boot_map_region: pgdir_walk return NULL\n");
f01010ad:	83 ec 04             	sub    $0x4,%esp
f01010b0:	68 04 4b 10 f0       	push   $0xf0104b04
f01010b5:	68 fe 01 00 00       	push   $0x1fe
f01010ba:	68 1f 46 10 f0       	push   $0xf010461f
f01010bf:	e8 dc ef ff ff       	call   f01000a0 <_panic>

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f01010c4:	89 da                	mov    %ebx,%edx
f01010c6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01010cc:	0b 55 dc             	or     -0x24(%ebp),%edx
f01010cf:	89 10                	mov    %edx,(%eax)

		// deal with next page
		va += PGSIZE;
		pa += PGSIZE;
f01010d1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f01010d7:	83 c6 01             	add    $0x1,%esi
f01010da:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01010dd:	75 b6                	jne    f0101095 <boot_map_region+0x70>
		va += PGSIZE;
		pa += PGSIZE;

	}

}
f01010df:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010e2:	5b                   	pop    %ebx
f01010e3:	5e                   	pop    %esi
f01010e4:	5f                   	pop    %edi
f01010e5:	5d                   	pop    %ebp
f01010e6:	c3                   	ret    

f01010e7 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01010e7:	55                   	push   %ebp
f01010e8:	89 e5                	mov    %esp,%ebp
f01010ea:	53                   	push   %ebx
f01010eb:	83 ec 08             	sub    $0x8,%esp
f01010ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in

	// do a page table walk to find real PTE
	pte_t * pte = pgdir_walk(pgdir, va, 0);
f01010f1:	6a 00                	push   $0x0
f01010f3:	ff 75 0c             	pushl  0xc(%ebp)
f01010f6:	ff 75 08             	pushl  0x8(%ebp)
f01010f9:	e8 91 fe ff ff       	call   f0100f8f <pgdir_walk>

	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
f01010fe:	83 c4 10             	add    $0x10,%esp
f0101101:	85 c0                	test   %eax,%eax
f0101103:	74 37                	je     f010113c <page_lookup+0x55>
f0101105:	83 38 00             	cmpl   $0x0,(%eax)
f0101108:	74 39                	je     f0101143 <page_lookup+0x5c>
		return NULL;
	
	// store pte
	if (pte_store != 0)
f010110a:	85 db                	test   %ebx,%ebx
f010110c:	74 02                	je     f0101110 <page_lookup+0x29>
		*pte_store = pte;
f010110e:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101110:	8b 00                	mov    (%eax),%eax
f0101112:	c1 e8 0c             	shr    $0xc,%eax
f0101115:	3b 05 48 0c 17 f0    	cmp    0xf0170c48,%eax
f010111b:	72 14                	jb     f0101131 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f010111d:	83 ec 04             	sub    $0x4,%esp
f0101120:	68 30 4b 10 f0       	push   $0xf0104b30
f0101125:	6a 4f                	push   $0x4f
f0101127:	68 2b 46 10 f0       	push   $0xf010462b
f010112c:	e8 6f ef ff ff       	call   f01000a0 <_panic>
	return &pages[PGNUM(pa)];
f0101131:	8b 15 50 0c 17 f0    	mov    0xf0170c50,%edx
f0101137:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte)) ;
f010113a:	eb 0c                	jmp    f0101148 <page_lookup+0x61>
	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
		return NULL;
f010113c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101141:	eb 05                	jmp    f0101148 <page_lookup+0x61>
f0101143:	b8 00 00 00 00       	mov    $0x0,%eax
	// store pte
	if (pte_store != 0)
		*pte_store = pte;

	return pa2page(PTE_ADDR(*pte)) ;
}
f0101148:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010114b:	c9                   	leave  
f010114c:	c3                   	ret    

f010114d <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010114d:	55                   	push   %ebp
f010114e:	89 e5                	mov    %esp,%ebp
f0101150:	53                   	push   %ebx
f0101151:	83 ec 18             	sub    $0x18,%esp
f0101154:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	// pte_t *tmp;
	pte_t *pte_store = NULL;
f0101157:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * pp = page_lookup(pgdir, va, &pte_store);
f010115e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101161:	50                   	push   %eax
f0101162:	53                   	push   %ebx
f0101163:	ff 75 08             	pushl  0x8(%ebp)
f0101166:	e8 7c ff ff ff       	call   f01010e7 <page_lookup>

	// if not present, silently return
	if (pp == NULL)
f010116b:	83 c4 10             	add    $0x10,%esp
f010116e:	85 c0                	test   %eax,%eax
f0101170:	74 18                	je     f010118a <page_remove+0x3d>
		return;

	// decrement ref count, and if reaches 0, free it
	page_decref(pp);
f0101172:	83 ec 0c             	sub    $0xc,%esp
f0101175:	50                   	push   %eax
f0101176:	e8 ed fd ff ff       	call   f0100f68 <page_decref>

	// null the real PTE pointer 
	*pte_store = 0;
f010117b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010117e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101184:	0f 01 3b             	invlpg (%ebx)
f0101187:	83 c4 10             	add    $0x10,%esp
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", *pte_store, **pte_store);

	// tlb invalidate
	tlb_invalidate(pgdir, va);

}
f010118a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010118d:	c9                   	leave  
f010118e:	c3                   	ret    

f010118f <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010118f:	55                   	push   %ebp
f0101190:	89 e5                	mov    %esp,%ebp
f0101192:	57                   	push   %edi
f0101193:	56                   	push   %esi
f0101194:	53                   	push   %ebx
f0101195:	83 ec 10             	sub    $0x10,%esp
f0101198:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010119b:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	
f010119e:	6a 01                	push   $0x1
f01011a0:	57                   	push   %edi
f01011a1:	ff 75 08             	pushl  0x8(%ebp)
f01011a4:	e8 e6 fd ff ff       	call   f0100f8f <pgdir_walk>

	if (pte == 0)
f01011a9:	83 c4 10             	add    $0x10,%esp
f01011ac:	85 c0                	test   %eax,%eax
f01011ae:	74 59                	je     f0101209 <page_insert+0x7a>
f01011b0:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;

	// already have a page
	// remove it and invalidate tlb
	if (*pte != 0) {
f01011b2:	8b 00                	mov    (%eax),%eax
f01011b4:	85 c0                	test   %eax,%eax
f01011b6:	74 2d                	je     f01011e5 <page_insert+0x56>
		// corner case
		if (page2pa(pp) == PTE_ADDR(*pte))
f01011b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011bd:	89 da                	mov    %ebx,%edx
f01011bf:	2b 15 50 0c 17 f0    	sub    0xf0170c50,%edx
f01011c5:	c1 fa 03             	sar    $0x3,%edx
f01011c8:	c1 e2 0c             	shl    $0xc,%edx
f01011cb:	39 d0                	cmp    %edx,%eax
f01011cd:	75 07                	jne    f01011d6 <page_insert+0x47>
			pp->pp_ref--;	// keep pp_ref consistent, in the meantime change perm potentially.
f01011cf:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01011d4:	eb 0f                	jmp    f01011e5 <page_insert+0x56>
		else
			page_remove(pgdir, va);
f01011d6:	83 ec 08             	sub    $0x8,%esp
f01011d9:	57                   	push   %edi
f01011da:	ff 75 08             	pushl  0x8(%ebp)
f01011dd:	e8 6b ff ff ff       	call   f010114d <page_remove>
f01011e2:	83 c4 10             	add    $0x10,%esp

	// set the real PTE to pa, zero out least 12 bits
	*pte = PTE_ADDR(page2pa(pp));
	
	// set flags
	*pte |= (perm | PTE_P);
f01011e5:	89 d8                	mov    %ebx,%eax
f01011e7:	2b 05 50 0c 17 f0    	sub    0xf0170c50,%eax
f01011ed:	c1 f8 03             	sar    $0x3,%eax
f01011f0:	c1 e0 0c             	shl    $0xc,%eax
f01011f3:	8b 55 14             	mov    0x14(%ebp),%edx
f01011f6:	83 ca 01             	or     $0x1,%edx
f01011f9:	09 d0                	or     %edx,%eax
f01011fb:	89 06                	mov    %eax,(%esi)

	// increment ref cnt
	pp->pp_ref++;
f01011fd:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	return 0;
f0101202:	b8 00 00 00 00       	mov    $0x0,%eax
f0101207:	eb 05                	jmp    f010120e <page_insert+0x7f>
	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	

	if (pte == 0)
		return -E_NO_MEM;
f0101209:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	// increment ref cnt
	pp->pp_ref++;

	return 0;
}
f010120e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101211:	5b                   	pop    %ebx
f0101212:	5e                   	pop    %esi
f0101213:	5f                   	pop    %edi
f0101214:	5d                   	pop    %ebp
f0101215:	c3                   	ret    

f0101216 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101216:	55                   	push   %ebp
f0101217:	89 e5                	mov    %esp,%ebp
f0101219:	57                   	push   %edi
f010121a:	56                   	push   %esi
f010121b:	53                   	push   %ebx
f010121c:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f010121f:	b8 15 00 00 00       	mov    $0x15,%eax
f0101224:	e8 59 f7 ff ff       	call   f0100982 <nvram_read>
f0101229:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010122b:	b8 17 00 00 00       	mov    $0x17,%eax
f0101230:	e8 4d f7 ff ff       	call   f0100982 <nvram_read>
f0101235:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101237:	b8 34 00 00 00       	mov    $0x34,%eax
f010123c:	e8 41 f7 ff ff       	call   f0100982 <nvram_read>
f0101241:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101244:	85 c0                	test   %eax,%eax
f0101246:	74 07                	je     f010124f <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0101248:	05 00 40 00 00       	add    $0x4000,%eax
f010124d:	eb 0b                	jmp    f010125a <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f010124f:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101255:	85 f6                	test   %esi,%esi
f0101257:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f010125a:	89 c2                	mov    %eax,%edx
f010125c:	c1 ea 02             	shr    $0x2,%edx
f010125f:	89 15 48 0c 17 f0    	mov    %edx,0xf0170c48
	npages_basemem = basemem / (PGSIZE / 1024);
f0101265:	89 da                	mov    %ebx,%edx
f0101267:	c1 ea 02             	shr    $0x2,%edx
f010126a:	89 15 80 ff 16 f0    	mov    %edx,0xf016ff80

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101270:	89 c2                	mov    %eax,%edx
f0101272:	29 da                	sub    %ebx,%edx
f0101274:	52                   	push   %edx
f0101275:	53                   	push   %ebx
f0101276:	50                   	push   %eax
f0101277:	68 50 4b 10 f0       	push   $0xf0104b50
f010127c:	e8 14 1b 00 00       	call   f0102d95 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101281:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101286:	e8 20 f7 ff ff       	call   f01009ab <boot_alloc>
f010128b:	a3 4c 0c 17 f0       	mov    %eax,0xf0170c4c
	memset(kern_pgdir, 0, PGSIZE);
f0101290:	83 c4 0c             	add    $0xc,%esp
f0101293:	68 00 10 00 00       	push   $0x1000
f0101298:	6a 00                	push   $0x0
f010129a:	50                   	push   %eax
f010129b:	e8 8a 29 00 00       	call   f0103c2a <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01012a0:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01012a5:	83 c4 10             	add    $0x10,%esp
f01012a8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01012ad:	77 15                	ja     f01012c4 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012af:	50                   	push   %eax
f01012b0:	68 10 4a 10 f0       	push   $0xf0104a10
f01012b5:	68 97 00 00 00       	push   $0x97
f01012ba:	68 1f 46 10 f0       	push   $0xf010461f
f01012bf:	e8 dc ed ff ff       	call   f01000a0 <_panic>
f01012c4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01012ca:	83 ca 05             	or     $0x5,%edx
f01012cd:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f01012d3:	a1 48 0c 17 f0       	mov    0xf0170c48,%eax
f01012d8:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f01012df:	89 d8                	mov    %ebx,%eax
f01012e1:	e8 c5 f6 ff ff       	call   f01009ab <boot_alloc>
f01012e6:	a3 50 0c 17 f0       	mov    %eax,0xf0170c50
	memset(pages, 0, n);
f01012eb:	83 ec 04             	sub    $0x4,%esp
f01012ee:	53                   	push   %ebx
f01012ef:	6a 00                	push   $0x0
f01012f1:	50                   	push   %eax
f01012f2:	e8 33 29 00 00       	call   f0103c2a <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	n = NENV * sizeof(struct Env);
	envs = (struct Env *) boot_alloc(n);
f01012f7:	b8 00 80 01 00       	mov    $0x18000,%eax
f01012fc:	e8 aa f6 ff ff       	call   f01009ab <boot_alloc>
f0101301:	a3 88 ff 16 f0       	mov    %eax,0xf016ff88
	memset(envs, 0, n);
f0101306:	83 c4 0c             	add    $0xc,%esp
f0101309:	68 00 80 01 00       	push   $0x18000
f010130e:	6a 00                	push   $0x0
f0101310:	50                   	push   %eax
f0101311:	e8 14 29 00 00       	call   f0103c2a <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101316:	e8 0a fa ff ff       	call   f0100d25 <page_init>

	check_page_free_list(1);
f010131b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101320:	e8 3d f7 ff ff       	call   f0100a62 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101325:	83 c4 10             	add    $0x10,%esp
f0101328:	83 3d 50 0c 17 f0 00 	cmpl   $0x0,0xf0170c50
f010132f:	75 17                	jne    f0101348 <mem_init+0x132>
		panic("'pages' is a null pointer!");
f0101331:	83 ec 04             	sub    $0x4,%esp
f0101334:	68 d5 46 10 f0       	push   $0xf01046d5
f0101339:	68 1d 03 00 00       	push   $0x31d
f010133e:	68 1f 46 10 f0       	push   $0xf010461f
f0101343:	e8 58 ed ff ff       	call   f01000a0 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101348:	a1 7c ff 16 f0       	mov    0xf016ff7c,%eax
f010134d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101352:	eb 05                	jmp    f0101359 <mem_init+0x143>
		++nfree;
f0101354:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101357:	8b 00                	mov    (%eax),%eax
f0101359:	85 c0                	test   %eax,%eax
f010135b:	75 f7                	jne    f0101354 <mem_init+0x13e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010135d:	83 ec 0c             	sub    $0xc,%esp
f0101360:	6a 00                	push   $0x0
f0101362:	e8 3a fb ff ff       	call   f0100ea1 <page_alloc>
f0101367:	89 c7                	mov    %eax,%edi
f0101369:	83 c4 10             	add    $0x10,%esp
f010136c:	85 c0                	test   %eax,%eax
f010136e:	75 19                	jne    f0101389 <mem_init+0x173>
f0101370:	68 f0 46 10 f0       	push   $0xf01046f0
f0101375:	68 45 46 10 f0       	push   $0xf0104645
f010137a:	68 25 03 00 00       	push   $0x325
f010137f:	68 1f 46 10 f0       	push   $0xf010461f
f0101384:	e8 17 ed ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101389:	83 ec 0c             	sub    $0xc,%esp
f010138c:	6a 00                	push   $0x0
f010138e:	e8 0e fb ff ff       	call   f0100ea1 <page_alloc>
f0101393:	89 c6                	mov    %eax,%esi
f0101395:	83 c4 10             	add    $0x10,%esp
f0101398:	85 c0                	test   %eax,%eax
f010139a:	75 19                	jne    f01013b5 <mem_init+0x19f>
f010139c:	68 06 47 10 f0       	push   $0xf0104706
f01013a1:	68 45 46 10 f0       	push   $0xf0104645
f01013a6:	68 26 03 00 00       	push   $0x326
f01013ab:	68 1f 46 10 f0       	push   $0xf010461f
f01013b0:	e8 eb ec ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01013b5:	83 ec 0c             	sub    $0xc,%esp
f01013b8:	6a 00                	push   $0x0
f01013ba:	e8 e2 fa ff ff       	call   f0100ea1 <page_alloc>
f01013bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013c2:	83 c4 10             	add    $0x10,%esp
f01013c5:	85 c0                	test   %eax,%eax
f01013c7:	75 19                	jne    f01013e2 <mem_init+0x1cc>
f01013c9:	68 1c 47 10 f0       	push   $0xf010471c
f01013ce:	68 45 46 10 f0       	push   $0xf0104645
f01013d3:	68 27 03 00 00       	push   $0x327
f01013d8:	68 1f 46 10 f0       	push   $0xf010461f
f01013dd:	e8 be ec ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013e2:	39 f7                	cmp    %esi,%edi
f01013e4:	75 19                	jne    f01013ff <mem_init+0x1e9>
f01013e6:	68 32 47 10 f0       	push   $0xf0104732
f01013eb:	68 45 46 10 f0       	push   $0xf0104645
f01013f0:	68 2a 03 00 00       	push   $0x32a
f01013f5:	68 1f 46 10 f0       	push   $0xf010461f
f01013fa:	e8 a1 ec ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101402:	39 c6                	cmp    %eax,%esi
f0101404:	74 04                	je     f010140a <mem_init+0x1f4>
f0101406:	39 c7                	cmp    %eax,%edi
f0101408:	75 19                	jne    f0101423 <mem_init+0x20d>
f010140a:	68 8c 4b 10 f0       	push   $0xf0104b8c
f010140f:	68 45 46 10 f0       	push   $0xf0104645
f0101414:	68 2b 03 00 00       	push   $0x32b
f0101419:	68 1f 46 10 f0       	push   $0xf010461f
f010141e:	e8 7d ec ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101423:	8b 0d 50 0c 17 f0    	mov    0xf0170c50,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101429:	8b 15 48 0c 17 f0    	mov    0xf0170c48,%edx
f010142f:	c1 e2 0c             	shl    $0xc,%edx
f0101432:	89 f8                	mov    %edi,%eax
f0101434:	29 c8                	sub    %ecx,%eax
f0101436:	c1 f8 03             	sar    $0x3,%eax
f0101439:	c1 e0 0c             	shl    $0xc,%eax
f010143c:	39 d0                	cmp    %edx,%eax
f010143e:	72 19                	jb     f0101459 <mem_init+0x243>
f0101440:	68 44 47 10 f0       	push   $0xf0104744
f0101445:	68 45 46 10 f0       	push   $0xf0104645
f010144a:	68 2c 03 00 00       	push   $0x32c
f010144f:	68 1f 46 10 f0       	push   $0xf010461f
f0101454:	e8 47 ec ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101459:	89 f0                	mov    %esi,%eax
f010145b:	29 c8                	sub    %ecx,%eax
f010145d:	c1 f8 03             	sar    $0x3,%eax
f0101460:	c1 e0 0c             	shl    $0xc,%eax
f0101463:	39 c2                	cmp    %eax,%edx
f0101465:	77 19                	ja     f0101480 <mem_init+0x26a>
f0101467:	68 61 47 10 f0       	push   $0xf0104761
f010146c:	68 45 46 10 f0       	push   $0xf0104645
f0101471:	68 2d 03 00 00       	push   $0x32d
f0101476:	68 1f 46 10 f0       	push   $0xf010461f
f010147b:	e8 20 ec ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101480:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101483:	29 c8                	sub    %ecx,%eax
f0101485:	c1 f8 03             	sar    $0x3,%eax
f0101488:	c1 e0 0c             	shl    $0xc,%eax
f010148b:	39 c2                	cmp    %eax,%edx
f010148d:	77 19                	ja     f01014a8 <mem_init+0x292>
f010148f:	68 7e 47 10 f0       	push   $0xf010477e
f0101494:	68 45 46 10 f0       	push   $0xf0104645
f0101499:	68 2e 03 00 00       	push   $0x32e
f010149e:	68 1f 46 10 f0       	push   $0xf010461f
f01014a3:	e8 f8 eb ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01014a8:	a1 7c ff 16 f0       	mov    0xf016ff7c,%eax
f01014ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014b0:	c7 05 7c ff 16 f0 00 	movl   $0x0,0xf016ff7c
f01014b7:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01014ba:	83 ec 0c             	sub    $0xc,%esp
f01014bd:	6a 00                	push   $0x0
f01014bf:	e8 dd f9 ff ff       	call   f0100ea1 <page_alloc>
f01014c4:	83 c4 10             	add    $0x10,%esp
f01014c7:	85 c0                	test   %eax,%eax
f01014c9:	74 19                	je     f01014e4 <mem_init+0x2ce>
f01014cb:	68 9b 47 10 f0       	push   $0xf010479b
f01014d0:	68 45 46 10 f0       	push   $0xf0104645
f01014d5:	68 35 03 00 00       	push   $0x335
f01014da:	68 1f 46 10 f0       	push   $0xf010461f
f01014df:	e8 bc eb ff ff       	call   f01000a0 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01014e4:	83 ec 0c             	sub    $0xc,%esp
f01014e7:	57                   	push   %edi
f01014e8:	e8 25 fa ff ff       	call   f0100f12 <page_free>
	page_free(pp1);
f01014ed:	89 34 24             	mov    %esi,(%esp)
f01014f0:	e8 1d fa ff ff       	call   f0100f12 <page_free>
	page_free(pp2);
f01014f5:	83 c4 04             	add    $0x4,%esp
f01014f8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014fb:	e8 12 fa ff ff       	call   f0100f12 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101500:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101507:	e8 95 f9 ff ff       	call   f0100ea1 <page_alloc>
f010150c:	89 c6                	mov    %eax,%esi
f010150e:	83 c4 10             	add    $0x10,%esp
f0101511:	85 c0                	test   %eax,%eax
f0101513:	75 19                	jne    f010152e <mem_init+0x318>
f0101515:	68 f0 46 10 f0       	push   $0xf01046f0
f010151a:	68 45 46 10 f0       	push   $0xf0104645
f010151f:	68 3c 03 00 00       	push   $0x33c
f0101524:	68 1f 46 10 f0       	push   $0xf010461f
f0101529:	e8 72 eb ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f010152e:	83 ec 0c             	sub    $0xc,%esp
f0101531:	6a 00                	push   $0x0
f0101533:	e8 69 f9 ff ff       	call   f0100ea1 <page_alloc>
f0101538:	89 c7                	mov    %eax,%edi
f010153a:	83 c4 10             	add    $0x10,%esp
f010153d:	85 c0                	test   %eax,%eax
f010153f:	75 19                	jne    f010155a <mem_init+0x344>
f0101541:	68 06 47 10 f0       	push   $0xf0104706
f0101546:	68 45 46 10 f0       	push   $0xf0104645
f010154b:	68 3d 03 00 00       	push   $0x33d
f0101550:	68 1f 46 10 f0       	push   $0xf010461f
f0101555:	e8 46 eb ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f010155a:	83 ec 0c             	sub    $0xc,%esp
f010155d:	6a 00                	push   $0x0
f010155f:	e8 3d f9 ff ff       	call   f0100ea1 <page_alloc>
f0101564:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101567:	83 c4 10             	add    $0x10,%esp
f010156a:	85 c0                	test   %eax,%eax
f010156c:	75 19                	jne    f0101587 <mem_init+0x371>
f010156e:	68 1c 47 10 f0       	push   $0xf010471c
f0101573:	68 45 46 10 f0       	push   $0xf0104645
f0101578:	68 3e 03 00 00       	push   $0x33e
f010157d:	68 1f 46 10 f0       	push   $0xf010461f
f0101582:	e8 19 eb ff ff       	call   f01000a0 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101587:	39 fe                	cmp    %edi,%esi
f0101589:	75 19                	jne    f01015a4 <mem_init+0x38e>
f010158b:	68 32 47 10 f0       	push   $0xf0104732
f0101590:	68 45 46 10 f0       	push   $0xf0104645
f0101595:	68 40 03 00 00       	push   $0x340
f010159a:	68 1f 46 10 f0       	push   $0xf010461f
f010159f:	e8 fc ea ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015a7:	39 c7                	cmp    %eax,%edi
f01015a9:	74 04                	je     f01015af <mem_init+0x399>
f01015ab:	39 c6                	cmp    %eax,%esi
f01015ad:	75 19                	jne    f01015c8 <mem_init+0x3b2>
f01015af:	68 8c 4b 10 f0       	push   $0xf0104b8c
f01015b4:	68 45 46 10 f0       	push   $0xf0104645
f01015b9:	68 41 03 00 00       	push   $0x341
f01015be:	68 1f 46 10 f0       	push   $0xf010461f
f01015c3:	e8 d8 ea ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f01015c8:	83 ec 0c             	sub    $0xc,%esp
f01015cb:	6a 00                	push   $0x0
f01015cd:	e8 cf f8 ff ff       	call   f0100ea1 <page_alloc>
f01015d2:	83 c4 10             	add    $0x10,%esp
f01015d5:	85 c0                	test   %eax,%eax
f01015d7:	74 19                	je     f01015f2 <mem_init+0x3dc>
f01015d9:	68 9b 47 10 f0       	push   $0xf010479b
f01015de:	68 45 46 10 f0       	push   $0xf0104645
f01015e3:	68 42 03 00 00       	push   $0x342
f01015e8:	68 1f 46 10 f0       	push   $0xf010461f
f01015ed:	e8 ae ea ff ff       	call   f01000a0 <_panic>
f01015f2:	89 f0                	mov    %esi,%eax
f01015f4:	2b 05 50 0c 17 f0    	sub    0xf0170c50,%eax
f01015fa:	c1 f8 03             	sar    $0x3,%eax
f01015fd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101600:	89 c2                	mov    %eax,%edx
f0101602:	c1 ea 0c             	shr    $0xc,%edx
f0101605:	3b 15 48 0c 17 f0    	cmp    0xf0170c48,%edx
f010160b:	72 12                	jb     f010161f <mem_init+0x409>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010160d:	50                   	push   %eax
f010160e:	68 04 49 10 f0       	push   $0xf0104904
f0101613:	6a 56                	push   $0x56
f0101615:	68 2b 46 10 f0       	push   $0xf010462b
f010161a:	e8 81 ea ff ff       	call   f01000a0 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010161f:	83 ec 04             	sub    $0x4,%esp
f0101622:	68 00 10 00 00       	push   $0x1000
f0101627:	6a 01                	push   $0x1
f0101629:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010162e:	50                   	push   %eax
f010162f:	e8 f6 25 00 00       	call   f0103c2a <memset>
	page_free(pp0);
f0101634:	89 34 24             	mov    %esi,(%esp)
f0101637:	e8 d6 f8 ff ff       	call   f0100f12 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010163c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101643:	e8 59 f8 ff ff       	call   f0100ea1 <page_alloc>
f0101648:	83 c4 10             	add    $0x10,%esp
f010164b:	85 c0                	test   %eax,%eax
f010164d:	75 19                	jne    f0101668 <mem_init+0x452>
f010164f:	68 aa 47 10 f0       	push   $0xf01047aa
f0101654:	68 45 46 10 f0       	push   $0xf0104645
f0101659:	68 47 03 00 00       	push   $0x347
f010165e:	68 1f 46 10 f0       	push   $0xf010461f
f0101663:	e8 38 ea ff ff       	call   f01000a0 <_panic>
	assert(pp && pp0 == pp);
f0101668:	39 c6                	cmp    %eax,%esi
f010166a:	74 19                	je     f0101685 <mem_init+0x46f>
f010166c:	68 c8 47 10 f0       	push   $0xf01047c8
f0101671:	68 45 46 10 f0       	push   $0xf0104645
f0101676:	68 48 03 00 00       	push   $0x348
f010167b:	68 1f 46 10 f0       	push   $0xf010461f
f0101680:	e8 1b ea ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101685:	89 f0                	mov    %esi,%eax
f0101687:	2b 05 50 0c 17 f0    	sub    0xf0170c50,%eax
f010168d:	c1 f8 03             	sar    $0x3,%eax
f0101690:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101693:	89 c2                	mov    %eax,%edx
f0101695:	c1 ea 0c             	shr    $0xc,%edx
f0101698:	3b 15 48 0c 17 f0    	cmp    0xf0170c48,%edx
f010169e:	72 12                	jb     f01016b2 <mem_init+0x49c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016a0:	50                   	push   %eax
f01016a1:	68 04 49 10 f0       	push   $0xf0104904
f01016a6:	6a 56                	push   $0x56
f01016a8:	68 2b 46 10 f0       	push   $0xf010462b
f01016ad:	e8 ee e9 ff ff       	call   f01000a0 <_panic>
f01016b2:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01016b8:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
f01016be:	80 38 00             	cmpb   $0x0,(%eax)
f01016c1:	74 19                	je     f01016dc <mem_init+0x4c6>
f01016c3:	68 d8 47 10 f0       	push   $0xf01047d8
f01016c8:	68 45 46 10 f0       	push   $0xf0104645
f01016cd:	68 4c 03 00 00       	push   $0x34c
f01016d2:	68 1f 46 10 f0       	push   $0xf010461f
f01016d7:	e8 c4 e9 ff ff       	call   f01000a0 <_panic>
f01016dc:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
f01016df:	39 d0                	cmp    %edx,%eax
f01016e1:	75 db                	jne    f01016be <mem_init+0x4a8>
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
	}

	// give free list back
	page_free_list = fl;
f01016e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016e6:	a3 7c ff 16 f0       	mov    %eax,0xf016ff7c

	// free the pages we took
	page_free(pp0);
f01016eb:	83 ec 0c             	sub    $0xc,%esp
f01016ee:	56                   	push   %esi
f01016ef:	e8 1e f8 ff ff       	call   f0100f12 <page_free>
	page_free(pp1);
f01016f4:	89 3c 24             	mov    %edi,(%esp)
f01016f7:	e8 16 f8 ff ff       	call   f0100f12 <page_free>
	page_free(pp2);
f01016fc:	83 c4 04             	add    $0x4,%esp
f01016ff:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101702:	e8 0b f8 ff ff       	call   f0100f12 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101707:	a1 7c ff 16 f0       	mov    0xf016ff7c,%eax
f010170c:	83 c4 10             	add    $0x10,%esp
f010170f:	eb 05                	jmp    f0101716 <mem_init+0x500>
		--nfree;
f0101711:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101714:	8b 00                	mov    (%eax),%eax
f0101716:	85 c0                	test   %eax,%eax
f0101718:	75 f7                	jne    f0101711 <mem_init+0x4fb>
		--nfree;
	assert(nfree == 0);
f010171a:	85 db                	test   %ebx,%ebx
f010171c:	74 19                	je     f0101737 <mem_init+0x521>
f010171e:	68 e2 47 10 f0       	push   $0xf01047e2
f0101723:	68 45 46 10 f0       	push   $0xf0104645
f0101728:	68 5a 03 00 00       	push   $0x35a
f010172d:	68 1f 46 10 f0       	push   $0xf010461f
f0101732:	e8 69 e9 ff ff       	call   f01000a0 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101737:	83 ec 0c             	sub    $0xc,%esp
f010173a:	68 ac 4b 10 f0       	push   $0xf0104bac
f010173f:	e8 51 16 00 00       	call   f0102d95 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101744:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010174b:	e8 51 f7 ff ff       	call   f0100ea1 <page_alloc>
f0101750:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101753:	83 c4 10             	add    $0x10,%esp
f0101756:	85 c0                	test   %eax,%eax
f0101758:	75 19                	jne    f0101773 <mem_init+0x55d>
f010175a:	68 f0 46 10 f0       	push   $0xf01046f0
f010175f:	68 45 46 10 f0       	push   $0xf0104645
f0101764:	68 bc 03 00 00       	push   $0x3bc
f0101769:	68 1f 46 10 f0       	push   $0xf010461f
f010176e:	e8 2d e9 ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101773:	83 ec 0c             	sub    $0xc,%esp
f0101776:	6a 00                	push   $0x0
f0101778:	e8 24 f7 ff ff       	call   f0100ea1 <page_alloc>
f010177d:	89 c3                	mov    %eax,%ebx
f010177f:	83 c4 10             	add    $0x10,%esp
f0101782:	85 c0                	test   %eax,%eax
f0101784:	75 19                	jne    f010179f <mem_init+0x589>
f0101786:	68 06 47 10 f0       	push   $0xf0104706
f010178b:	68 45 46 10 f0       	push   $0xf0104645
f0101790:	68 bd 03 00 00       	push   $0x3bd
f0101795:	68 1f 46 10 f0       	push   $0xf010461f
f010179a:	e8 01 e9 ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f010179f:	83 ec 0c             	sub    $0xc,%esp
f01017a2:	6a 00                	push   $0x0
f01017a4:	e8 f8 f6 ff ff       	call   f0100ea1 <page_alloc>
f01017a9:	89 c6                	mov    %eax,%esi
f01017ab:	83 c4 10             	add    $0x10,%esp
f01017ae:	85 c0                	test   %eax,%eax
f01017b0:	75 19                	jne    f01017cb <mem_init+0x5b5>
f01017b2:	68 1c 47 10 f0       	push   $0xf010471c
f01017b7:	68 45 46 10 f0       	push   $0xf0104645
f01017bc:	68 be 03 00 00       	push   $0x3be
f01017c1:	68 1f 46 10 f0       	push   $0xf010461f
f01017c6:	e8 d5 e8 ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017cb:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01017ce:	75 19                	jne    f01017e9 <mem_init+0x5d3>
f01017d0:	68 32 47 10 f0       	push   $0xf0104732
f01017d5:	68 45 46 10 f0       	push   $0xf0104645
f01017da:	68 c1 03 00 00       	push   $0x3c1
f01017df:	68 1f 46 10 f0       	push   $0xf010461f
f01017e4:	e8 b7 e8 ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017e9:	39 c3                	cmp    %eax,%ebx
f01017eb:	74 05                	je     f01017f2 <mem_init+0x5dc>
f01017ed:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01017f0:	75 19                	jne    f010180b <mem_init+0x5f5>
f01017f2:	68 8c 4b 10 f0       	push   $0xf0104b8c
f01017f7:	68 45 46 10 f0       	push   $0xf0104645
f01017fc:	68 c2 03 00 00       	push   $0x3c2
f0101801:	68 1f 46 10 f0       	push   $0xf010461f
f0101806:	e8 95 e8 ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010180b:	a1 7c ff 16 f0       	mov    0xf016ff7c,%eax
f0101810:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101813:	c7 05 7c ff 16 f0 00 	movl   $0x0,0xf016ff7c
f010181a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010181d:	83 ec 0c             	sub    $0xc,%esp
f0101820:	6a 00                	push   $0x0
f0101822:	e8 7a f6 ff ff       	call   f0100ea1 <page_alloc>
f0101827:	83 c4 10             	add    $0x10,%esp
f010182a:	85 c0                	test   %eax,%eax
f010182c:	74 19                	je     f0101847 <mem_init+0x631>
f010182e:	68 9b 47 10 f0       	push   $0xf010479b
f0101833:	68 45 46 10 f0       	push   $0xf0104645
f0101838:	68 c9 03 00 00       	push   $0x3c9
f010183d:	68 1f 46 10 f0       	push   $0xf010461f
f0101842:	e8 59 e8 ff ff       	call   f01000a0 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101847:	83 ec 04             	sub    $0x4,%esp
f010184a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010184d:	50                   	push   %eax
f010184e:	6a 00                	push   $0x0
f0101850:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0101856:	e8 8c f8 ff ff       	call   f01010e7 <page_lookup>
f010185b:	83 c4 10             	add    $0x10,%esp
f010185e:	85 c0                	test   %eax,%eax
f0101860:	74 19                	je     f010187b <mem_init+0x665>
f0101862:	68 cc 4b 10 f0       	push   $0xf0104bcc
f0101867:	68 45 46 10 f0       	push   $0xf0104645
f010186c:	68 cc 03 00 00       	push   $0x3cc
f0101871:	68 1f 46 10 f0       	push   $0xf010461f
f0101876:	e8 25 e8 ff ff       	call   f01000a0 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010187b:	6a 02                	push   $0x2
f010187d:	6a 00                	push   $0x0
f010187f:	53                   	push   %ebx
f0101880:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0101886:	e8 04 f9 ff ff       	call   f010118f <page_insert>
f010188b:	83 c4 10             	add    $0x10,%esp
f010188e:	85 c0                	test   %eax,%eax
f0101890:	78 19                	js     f01018ab <mem_init+0x695>
f0101892:	68 04 4c 10 f0       	push   $0xf0104c04
f0101897:	68 45 46 10 f0       	push   $0xf0104645
f010189c:	68 cf 03 00 00       	push   $0x3cf
f01018a1:	68 1f 46 10 f0       	push   $0xf010461f
f01018a6:	e8 f5 e7 ff ff       	call   f01000a0 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01018ab:	83 ec 0c             	sub    $0xc,%esp
f01018ae:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018b1:	e8 5c f6 ff ff       	call   f0100f12 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01018b6:	6a 02                	push   $0x2
f01018b8:	6a 00                	push   $0x0
f01018ba:	53                   	push   %ebx
f01018bb:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f01018c1:	e8 c9 f8 ff ff       	call   f010118f <page_insert>
f01018c6:	83 c4 20             	add    $0x20,%esp
f01018c9:	85 c0                	test   %eax,%eax
f01018cb:	74 19                	je     f01018e6 <mem_init+0x6d0>
f01018cd:	68 34 4c 10 f0       	push   $0xf0104c34
f01018d2:	68 45 46 10 f0       	push   $0xf0104645
f01018d7:	68 d3 03 00 00       	push   $0x3d3
f01018dc:	68 1f 46 10 f0       	push   $0xf010461f
f01018e1:	e8 ba e7 ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01018e6:	8b 3d 4c 0c 17 f0    	mov    0xf0170c4c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018ec:	a1 50 0c 17 f0       	mov    0xf0170c50,%eax
f01018f1:	89 c1                	mov    %eax,%ecx
f01018f3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01018f6:	8b 17                	mov    (%edi),%edx
f01018f8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101901:	29 c8                	sub    %ecx,%eax
f0101903:	c1 f8 03             	sar    $0x3,%eax
f0101906:	c1 e0 0c             	shl    $0xc,%eax
f0101909:	39 c2                	cmp    %eax,%edx
f010190b:	74 19                	je     f0101926 <mem_init+0x710>
f010190d:	68 64 4c 10 f0       	push   $0xf0104c64
f0101912:	68 45 46 10 f0       	push   $0xf0104645
f0101917:	68 d4 03 00 00       	push   $0x3d4
f010191c:	68 1f 46 10 f0       	push   $0xf010461f
f0101921:	e8 7a e7 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101926:	ba 00 00 00 00       	mov    $0x0,%edx
f010192b:	89 f8                	mov    %edi,%eax
f010192d:	e8 cc f0 ff ff       	call   f01009fe <check_va2pa>
f0101932:	89 da                	mov    %ebx,%edx
f0101934:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101937:	c1 fa 03             	sar    $0x3,%edx
f010193a:	c1 e2 0c             	shl    $0xc,%edx
f010193d:	39 d0                	cmp    %edx,%eax
f010193f:	74 19                	je     f010195a <mem_init+0x744>
f0101941:	68 8c 4c 10 f0       	push   $0xf0104c8c
f0101946:	68 45 46 10 f0       	push   $0xf0104645
f010194b:	68 d5 03 00 00       	push   $0x3d5
f0101950:	68 1f 46 10 f0       	push   $0xf010461f
f0101955:	e8 46 e7 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f010195a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010195f:	74 19                	je     f010197a <mem_init+0x764>
f0101961:	68 ed 47 10 f0       	push   $0xf01047ed
f0101966:	68 45 46 10 f0       	push   $0xf0104645
f010196b:	68 d6 03 00 00       	push   $0x3d6
f0101970:	68 1f 46 10 f0       	push   $0xf010461f
f0101975:	e8 26 e7 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f010197a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010197d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101982:	74 19                	je     f010199d <mem_init+0x787>
f0101984:	68 fe 47 10 f0       	push   $0xf01047fe
f0101989:	68 45 46 10 f0       	push   $0xf0104645
f010198e:	68 d7 03 00 00       	push   $0x3d7
f0101993:	68 1f 46 10 f0       	push   $0xf010461f
f0101998:	e8 03 e7 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010199d:	6a 02                	push   $0x2
f010199f:	68 00 10 00 00       	push   $0x1000
f01019a4:	56                   	push   %esi
f01019a5:	57                   	push   %edi
f01019a6:	e8 e4 f7 ff ff       	call   f010118f <page_insert>
f01019ab:	83 c4 10             	add    $0x10,%esp
f01019ae:	85 c0                	test   %eax,%eax
f01019b0:	74 19                	je     f01019cb <mem_init+0x7b5>
f01019b2:	68 bc 4c 10 f0       	push   $0xf0104cbc
f01019b7:	68 45 46 10 f0       	push   $0xf0104645
f01019bc:	68 da 03 00 00       	push   $0x3da
f01019c1:	68 1f 46 10 f0       	push   $0xf010461f
f01019c6:	e8 d5 e6 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019cb:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019d0:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
f01019d5:	e8 24 f0 ff ff       	call   f01009fe <check_va2pa>
f01019da:	89 f2                	mov    %esi,%edx
f01019dc:	2b 15 50 0c 17 f0    	sub    0xf0170c50,%edx
f01019e2:	c1 fa 03             	sar    $0x3,%edx
f01019e5:	c1 e2 0c             	shl    $0xc,%edx
f01019e8:	39 d0                	cmp    %edx,%eax
f01019ea:	74 19                	je     f0101a05 <mem_init+0x7ef>
f01019ec:	68 f8 4c 10 f0       	push   $0xf0104cf8
f01019f1:	68 45 46 10 f0       	push   $0xf0104645
f01019f6:	68 db 03 00 00       	push   $0x3db
f01019fb:	68 1f 46 10 f0       	push   $0xf010461f
f0101a00:	e8 9b e6 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101a05:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a0a:	74 19                	je     f0101a25 <mem_init+0x80f>
f0101a0c:	68 0f 48 10 f0       	push   $0xf010480f
f0101a11:	68 45 46 10 f0       	push   $0xf0104645
f0101a16:	68 dc 03 00 00       	push   $0x3dc
f0101a1b:	68 1f 46 10 f0       	push   $0xf010461f
f0101a20:	e8 7b e6 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101a25:	83 ec 0c             	sub    $0xc,%esp
f0101a28:	6a 00                	push   $0x0
f0101a2a:	e8 72 f4 ff ff       	call   f0100ea1 <page_alloc>
f0101a2f:	83 c4 10             	add    $0x10,%esp
f0101a32:	85 c0                	test   %eax,%eax
f0101a34:	74 19                	je     f0101a4f <mem_init+0x839>
f0101a36:	68 9b 47 10 f0       	push   $0xf010479b
f0101a3b:	68 45 46 10 f0       	push   $0xf0104645
f0101a40:	68 df 03 00 00       	push   $0x3df
f0101a45:	68 1f 46 10 f0       	push   $0xf010461f
f0101a4a:	e8 51 e6 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a4f:	6a 02                	push   $0x2
f0101a51:	68 00 10 00 00       	push   $0x1000
f0101a56:	56                   	push   %esi
f0101a57:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0101a5d:	e8 2d f7 ff ff       	call   f010118f <page_insert>
f0101a62:	83 c4 10             	add    $0x10,%esp
f0101a65:	85 c0                	test   %eax,%eax
f0101a67:	74 19                	je     f0101a82 <mem_init+0x86c>
f0101a69:	68 bc 4c 10 f0       	push   $0xf0104cbc
f0101a6e:	68 45 46 10 f0       	push   $0xf0104645
f0101a73:	68 e2 03 00 00       	push   $0x3e2
f0101a78:	68 1f 46 10 f0       	push   $0xf010461f
f0101a7d:	e8 1e e6 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a82:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a87:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
f0101a8c:	e8 6d ef ff ff       	call   f01009fe <check_va2pa>
f0101a91:	89 f2                	mov    %esi,%edx
f0101a93:	2b 15 50 0c 17 f0    	sub    0xf0170c50,%edx
f0101a99:	c1 fa 03             	sar    $0x3,%edx
f0101a9c:	c1 e2 0c             	shl    $0xc,%edx
f0101a9f:	39 d0                	cmp    %edx,%eax
f0101aa1:	74 19                	je     f0101abc <mem_init+0x8a6>
f0101aa3:	68 f8 4c 10 f0       	push   $0xf0104cf8
f0101aa8:	68 45 46 10 f0       	push   $0xf0104645
f0101aad:	68 e3 03 00 00       	push   $0x3e3
f0101ab2:	68 1f 46 10 f0       	push   $0xf010461f
f0101ab7:	e8 e4 e5 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101abc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ac1:	74 19                	je     f0101adc <mem_init+0x8c6>
f0101ac3:	68 0f 48 10 f0       	push   $0xf010480f
f0101ac8:	68 45 46 10 f0       	push   $0xf0104645
f0101acd:	68 e4 03 00 00       	push   $0x3e4
f0101ad2:	68 1f 46 10 f0       	push   $0xf010461f
f0101ad7:	e8 c4 e5 ff ff       	call   f01000a0 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101adc:	83 ec 0c             	sub    $0xc,%esp
f0101adf:	6a 00                	push   $0x0
f0101ae1:	e8 bb f3 ff ff       	call   f0100ea1 <page_alloc>
f0101ae6:	83 c4 10             	add    $0x10,%esp
f0101ae9:	85 c0                	test   %eax,%eax
f0101aeb:	74 19                	je     f0101b06 <mem_init+0x8f0>
f0101aed:	68 9b 47 10 f0       	push   $0xf010479b
f0101af2:	68 45 46 10 f0       	push   $0xf0104645
f0101af7:	68 e8 03 00 00       	push   $0x3e8
f0101afc:	68 1f 46 10 f0       	push   $0xf010461f
f0101b01:	e8 9a e5 ff ff       	call   f01000a0 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b06:	8b 15 4c 0c 17 f0    	mov    0xf0170c4c,%edx
f0101b0c:	8b 02                	mov    (%edx),%eax
f0101b0e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b13:	89 c1                	mov    %eax,%ecx
f0101b15:	c1 e9 0c             	shr    $0xc,%ecx
f0101b18:	3b 0d 48 0c 17 f0    	cmp    0xf0170c48,%ecx
f0101b1e:	72 15                	jb     f0101b35 <mem_init+0x91f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b20:	50                   	push   %eax
f0101b21:	68 04 49 10 f0       	push   $0xf0104904
f0101b26:	68 eb 03 00 00       	push   $0x3eb
f0101b2b:	68 1f 46 10 f0       	push   $0xf010461f
f0101b30:	e8 6b e5 ff ff       	call   f01000a0 <_panic>
f0101b35:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b3d:	83 ec 04             	sub    $0x4,%esp
f0101b40:	6a 00                	push   $0x0
f0101b42:	68 00 10 00 00       	push   $0x1000
f0101b47:	52                   	push   %edx
f0101b48:	e8 42 f4 ff ff       	call   f0100f8f <pgdir_walk>
f0101b4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101b50:	8d 57 04             	lea    0x4(%edi),%edx
f0101b53:	83 c4 10             	add    $0x10,%esp
f0101b56:	39 d0                	cmp    %edx,%eax
f0101b58:	74 19                	je     f0101b73 <mem_init+0x95d>
f0101b5a:	68 28 4d 10 f0       	push   $0xf0104d28
f0101b5f:	68 45 46 10 f0       	push   $0xf0104645
f0101b64:	68 ec 03 00 00       	push   $0x3ec
f0101b69:	68 1f 46 10 f0       	push   $0xf010461f
f0101b6e:	e8 2d e5 ff ff       	call   f01000a0 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b73:	6a 06                	push   $0x6
f0101b75:	68 00 10 00 00       	push   $0x1000
f0101b7a:	56                   	push   %esi
f0101b7b:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0101b81:	e8 09 f6 ff ff       	call   f010118f <page_insert>
f0101b86:	83 c4 10             	add    $0x10,%esp
f0101b89:	85 c0                	test   %eax,%eax
f0101b8b:	74 19                	je     f0101ba6 <mem_init+0x990>
f0101b8d:	68 68 4d 10 f0       	push   $0xf0104d68
f0101b92:	68 45 46 10 f0       	push   $0xf0104645
f0101b97:	68 ef 03 00 00       	push   $0x3ef
f0101b9c:	68 1f 46 10 f0       	push   $0xf010461f
f0101ba1:	e8 fa e4 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ba6:	8b 3d 4c 0c 17 f0    	mov    0xf0170c4c,%edi
f0101bac:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bb1:	89 f8                	mov    %edi,%eax
f0101bb3:	e8 46 ee ff ff       	call   f01009fe <check_va2pa>
f0101bb8:	89 f2                	mov    %esi,%edx
f0101bba:	2b 15 50 0c 17 f0    	sub    0xf0170c50,%edx
f0101bc0:	c1 fa 03             	sar    $0x3,%edx
f0101bc3:	c1 e2 0c             	shl    $0xc,%edx
f0101bc6:	39 d0                	cmp    %edx,%eax
f0101bc8:	74 19                	je     f0101be3 <mem_init+0x9cd>
f0101bca:	68 f8 4c 10 f0       	push   $0xf0104cf8
f0101bcf:	68 45 46 10 f0       	push   $0xf0104645
f0101bd4:	68 f0 03 00 00       	push   $0x3f0
f0101bd9:	68 1f 46 10 f0       	push   $0xf010461f
f0101bde:	e8 bd e4 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101be3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101be8:	74 19                	je     f0101c03 <mem_init+0x9ed>
f0101bea:	68 0f 48 10 f0       	push   $0xf010480f
f0101bef:	68 45 46 10 f0       	push   $0xf0104645
f0101bf4:	68 f1 03 00 00       	push   $0x3f1
f0101bf9:	68 1f 46 10 f0       	push   $0xf010461f
f0101bfe:	e8 9d e4 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101c03:	83 ec 04             	sub    $0x4,%esp
f0101c06:	6a 00                	push   $0x0
f0101c08:	68 00 10 00 00       	push   $0x1000
f0101c0d:	57                   	push   %edi
f0101c0e:	e8 7c f3 ff ff       	call   f0100f8f <pgdir_walk>
f0101c13:	83 c4 10             	add    $0x10,%esp
f0101c16:	f6 00 04             	testb  $0x4,(%eax)
f0101c19:	75 19                	jne    f0101c34 <mem_init+0xa1e>
f0101c1b:	68 a8 4d 10 f0       	push   $0xf0104da8
f0101c20:	68 45 46 10 f0       	push   $0xf0104645
f0101c25:	68 f2 03 00 00       	push   $0x3f2
f0101c2a:	68 1f 46 10 f0       	push   $0xf010461f
f0101c2f:	e8 6c e4 ff ff       	call   f01000a0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101c34:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
f0101c39:	f6 00 04             	testb  $0x4,(%eax)
f0101c3c:	75 19                	jne    f0101c57 <mem_init+0xa41>
f0101c3e:	68 20 48 10 f0       	push   $0xf0104820
f0101c43:	68 45 46 10 f0       	push   $0xf0104645
f0101c48:	68 f3 03 00 00       	push   $0x3f3
f0101c4d:	68 1f 46 10 f0       	push   $0xf010461f
f0101c52:	e8 49 e4 ff ff       	call   f01000a0 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c57:	6a 02                	push   $0x2
f0101c59:	68 00 10 00 00       	push   $0x1000
f0101c5e:	56                   	push   %esi
f0101c5f:	50                   	push   %eax
f0101c60:	e8 2a f5 ff ff       	call   f010118f <page_insert>
f0101c65:	83 c4 10             	add    $0x10,%esp
f0101c68:	85 c0                	test   %eax,%eax
f0101c6a:	74 19                	je     f0101c85 <mem_init+0xa6f>
f0101c6c:	68 bc 4c 10 f0       	push   $0xf0104cbc
f0101c71:	68 45 46 10 f0       	push   $0xf0104645
f0101c76:	68 f6 03 00 00       	push   $0x3f6
f0101c7b:	68 1f 46 10 f0       	push   $0xf010461f
f0101c80:	e8 1b e4 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c85:	83 ec 04             	sub    $0x4,%esp
f0101c88:	6a 00                	push   $0x0
f0101c8a:	68 00 10 00 00       	push   $0x1000
f0101c8f:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0101c95:	e8 f5 f2 ff ff       	call   f0100f8f <pgdir_walk>
f0101c9a:	83 c4 10             	add    $0x10,%esp
f0101c9d:	f6 00 02             	testb  $0x2,(%eax)
f0101ca0:	75 19                	jne    f0101cbb <mem_init+0xaa5>
f0101ca2:	68 dc 4d 10 f0       	push   $0xf0104ddc
f0101ca7:	68 45 46 10 f0       	push   $0xf0104645
f0101cac:	68 f7 03 00 00       	push   $0x3f7
f0101cb1:	68 1f 46 10 f0       	push   $0xf010461f
f0101cb6:	e8 e5 e3 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101cbb:	83 ec 04             	sub    $0x4,%esp
f0101cbe:	6a 00                	push   $0x0
f0101cc0:	68 00 10 00 00       	push   $0x1000
f0101cc5:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0101ccb:	e8 bf f2 ff ff       	call   f0100f8f <pgdir_walk>
f0101cd0:	83 c4 10             	add    $0x10,%esp
f0101cd3:	f6 00 04             	testb  $0x4,(%eax)
f0101cd6:	74 19                	je     f0101cf1 <mem_init+0xadb>
f0101cd8:	68 10 4e 10 f0       	push   $0xf0104e10
f0101cdd:	68 45 46 10 f0       	push   $0xf0104645
f0101ce2:	68 f8 03 00 00       	push   $0x3f8
f0101ce7:	68 1f 46 10 f0       	push   $0xf010461f
f0101cec:	e8 af e3 ff ff       	call   f01000a0 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101cf1:	6a 02                	push   $0x2
f0101cf3:	68 00 00 40 00       	push   $0x400000
f0101cf8:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101cfb:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0101d01:	e8 89 f4 ff ff       	call   f010118f <page_insert>
f0101d06:	83 c4 10             	add    $0x10,%esp
f0101d09:	85 c0                	test   %eax,%eax
f0101d0b:	78 19                	js     f0101d26 <mem_init+0xb10>
f0101d0d:	68 48 4e 10 f0       	push   $0xf0104e48
f0101d12:	68 45 46 10 f0       	push   $0xf0104645
f0101d17:	68 fb 03 00 00       	push   $0x3fb
f0101d1c:	68 1f 46 10 f0       	push   $0xf010461f
f0101d21:	e8 7a e3 ff ff       	call   f01000a0 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101d26:	6a 02                	push   $0x2
f0101d28:	68 00 10 00 00       	push   $0x1000
f0101d2d:	53                   	push   %ebx
f0101d2e:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0101d34:	e8 56 f4 ff ff       	call   f010118f <page_insert>
f0101d39:	83 c4 10             	add    $0x10,%esp
f0101d3c:	85 c0                	test   %eax,%eax
f0101d3e:	74 19                	je     f0101d59 <mem_init+0xb43>
f0101d40:	68 80 4e 10 f0       	push   $0xf0104e80
f0101d45:	68 45 46 10 f0       	push   $0xf0104645
f0101d4a:	68 fe 03 00 00       	push   $0x3fe
f0101d4f:	68 1f 46 10 f0       	push   $0xf010461f
f0101d54:	e8 47 e3 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d59:	83 ec 04             	sub    $0x4,%esp
f0101d5c:	6a 00                	push   $0x0
f0101d5e:	68 00 10 00 00       	push   $0x1000
f0101d63:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0101d69:	e8 21 f2 ff ff       	call   f0100f8f <pgdir_walk>
f0101d6e:	83 c4 10             	add    $0x10,%esp
f0101d71:	f6 00 04             	testb  $0x4,(%eax)
f0101d74:	74 19                	je     f0101d8f <mem_init+0xb79>
f0101d76:	68 10 4e 10 f0       	push   $0xf0104e10
f0101d7b:	68 45 46 10 f0       	push   $0xf0104645
f0101d80:	68 ff 03 00 00       	push   $0x3ff
f0101d85:	68 1f 46 10 f0       	push   $0xf010461f
f0101d8a:	e8 11 e3 ff ff       	call   f01000a0 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d8f:	8b 3d 4c 0c 17 f0    	mov    0xf0170c4c,%edi
f0101d95:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d9a:	89 f8                	mov    %edi,%eax
f0101d9c:	e8 5d ec ff ff       	call   f01009fe <check_va2pa>
f0101da1:	89 c1                	mov    %eax,%ecx
f0101da3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101da6:	89 d8                	mov    %ebx,%eax
f0101da8:	2b 05 50 0c 17 f0    	sub    0xf0170c50,%eax
f0101dae:	c1 f8 03             	sar    $0x3,%eax
f0101db1:	c1 e0 0c             	shl    $0xc,%eax
f0101db4:	39 c1                	cmp    %eax,%ecx
f0101db6:	74 19                	je     f0101dd1 <mem_init+0xbbb>
f0101db8:	68 bc 4e 10 f0       	push   $0xf0104ebc
f0101dbd:	68 45 46 10 f0       	push   $0xf0104645
f0101dc2:	68 02 04 00 00       	push   $0x402
f0101dc7:	68 1f 46 10 f0       	push   $0xf010461f
f0101dcc:	e8 cf e2 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dd1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dd6:	89 f8                	mov    %edi,%eax
f0101dd8:	e8 21 ec ff ff       	call   f01009fe <check_va2pa>
f0101ddd:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101de0:	74 19                	je     f0101dfb <mem_init+0xbe5>
f0101de2:	68 e8 4e 10 f0       	push   $0xf0104ee8
f0101de7:	68 45 46 10 f0       	push   $0xf0104645
f0101dec:	68 03 04 00 00       	push   $0x403
f0101df1:	68 1f 46 10 f0       	push   $0xf010461f
f0101df6:	e8 a5 e2 ff ff       	call   f01000a0 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101dfb:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101e00:	74 19                	je     f0101e1b <mem_init+0xc05>
f0101e02:	68 36 48 10 f0       	push   $0xf0104836
f0101e07:	68 45 46 10 f0       	push   $0xf0104645
f0101e0c:	68 05 04 00 00       	push   $0x405
f0101e11:	68 1f 46 10 f0       	push   $0xf010461f
f0101e16:	e8 85 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101e1b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e20:	74 19                	je     f0101e3b <mem_init+0xc25>
f0101e22:	68 47 48 10 f0       	push   $0xf0104847
f0101e27:	68 45 46 10 f0       	push   $0xf0104645
f0101e2c:	68 06 04 00 00       	push   $0x406
f0101e31:	68 1f 46 10 f0       	push   $0xf010461f
f0101e36:	e8 65 e2 ff ff       	call   f01000a0 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e3b:	83 ec 0c             	sub    $0xc,%esp
f0101e3e:	6a 00                	push   $0x0
f0101e40:	e8 5c f0 ff ff       	call   f0100ea1 <page_alloc>
f0101e45:	83 c4 10             	add    $0x10,%esp
f0101e48:	85 c0                	test   %eax,%eax
f0101e4a:	74 04                	je     f0101e50 <mem_init+0xc3a>
f0101e4c:	39 c6                	cmp    %eax,%esi
f0101e4e:	74 19                	je     f0101e69 <mem_init+0xc53>
f0101e50:	68 18 4f 10 f0       	push   $0xf0104f18
f0101e55:	68 45 46 10 f0       	push   $0xf0104645
f0101e5a:	68 09 04 00 00       	push   $0x409
f0101e5f:	68 1f 46 10 f0       	push   $0xf010461f
f0101e64:	e8 37 e2 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e69:	83 ec 08             	sub    $0x8,%esp
f0101e6c:	6a 00                	push   $0x0
f0101e6e:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0101e74:	e8 d4 f2 ff ff       	call   f010114d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e79:	8b 3d 4c 0c 17 f0    	mov    0xf0170c4c,%edi
f0101e7f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e84:	89 f8                	mov    %edi,%eax
f0101e86:	e8 73 eb ff ff       	call   f01009fe <check_va2pa>
f0101e8b:	83 c4 10             	add    $0x10,%esp
f0101e8e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e91:	74 19                	je     f0101eac <mem_init+0xc96>
f0101e93:	68 3c 4f 10 f0       	push   $0xf0104f3c
f0101e98:	68 45 46 10 f0       	push   $0xf0104645
f0101e9d:	68 0d 04 00 00       	push   $0x40d
f0101ea2:	68 1f 46 10 f0       	push   $0xf010461f
f0101ea7:	e8 f4 e1 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101eac:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101eb1:	89 f8                	mov    %edi,%eax
f0101eb3:	e8 46 eb ff ff       	call   f01009fe <check_va2pa>
f0101eb8:	89 da                	mov    %ebx,%edx
f0101eba:	2b 15 50 0c 17 f0    	sub    0xf0170c50,%edx
f0101ec0:	c1 fa 03             	sar    $0x3,%edx
f0101ec3:	c1 e2 0c             	shl    $0xc,%edx
f0101ec6:	39 d0                	cmp    %edx,%eax
f0101ec8:	74 19                	je     f0101ee3 <mem_init+0xccd>
f0101eca:	68 e8 4e 10 f0       	push   $0xf0104ee8
f0101ecf:	68 45 46 10 f0       	push   $0xf0104645
f0101ed4:	68 0e 04 00 00       	push   $0x40e
f0101ed9:	68 1f 46 10 f0       	push   $0xf010461f
f0101ede:	e8 bd e1 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101ee3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ee8:	74 19                	je     f0101f03 <mem_init+0xced>
f0101eea:	68 ed 47 10 f0       	push   $0xf01047ed
f0101eef:	68 45 46 10 f0       	push   $0xf0104645
f0101ef4:	68 0f 04 00 00       	push   $0x40f
f0101ef9:	68 1f 46 10 f0       	push   $0xf010461f
f0101efe:	e8 9d e1 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101f03:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f08:	74 19                	je     f0101f23 <mem_init+0xd0d>
f0101f0a:	68 47 48 10 f0       	push   $0xf0104847
f0101f0f:	68 45 46 10 f0       	push   $0xf0104645
f0101f14:	68 10 04 00 00       	push   $0x410
f0101f19:	68 1f 46 10 f0       	push   $0xf010461f
f0101f1e:	e8 7d e1 ff ff       	call   f01000a0 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f23:	6a 00                	push   $0x0
f0101f25:	68 00 10 00 00       	push   $0x1000
f0101f2a:	53                   	push   %ebx
f0101f2b:	57                   	push   %edi
f0101f2c:	e8 5e f2 ff ff       	call   f010118f <page_insert>
f0101f31:	83 c4 10             	add    $0x10,%esp
f0101f34:	85 c0                	test   %eax,%eax
f0101f36:	74 19                	je     f0101f51 <mem_init+0xd3b>
f0101f38:	68 60 4f 10 f0       	push   $0xf0104f60
f0101f3d:	68 45 46 10 f0       	push   $0xf0104645
f0101f42:	68 13 04 00 00       	push   $0x413
f0101f47:	68 1f 46 10 f0       	push   $0xf010461f
f0101f4c:	e8 4f e1 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref);
f0101f51:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f56:	75 19                	jne    f0101f71 <mem_init+0xd5b>
f0101f58:	68 58 48 10 f0       	push   $0xf0104858
f0101f5d:	68 45 46 10 f0       	push   $0xf0104645
f0101f62:	68 14 04 00 00       	push   $0x414
f0101f67:	68 1f 46 10 f0       	push   $0xf010461f
f0101f6c:	e8 2f e1 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_link == NULL);
f0101f71:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101f74:	74 19                	je     f0101f8f <mem_init+0xd79>
f0101f76:	68 64 48 10 f0       	push   $0xf0104864
f0101f7b:	68 45 46 10 f0       	push   $0xf0104645
f0101f80:	68 15 04 00 00       	push   $0x415
f0101f85:	68 1f 46 10 f0       	push   $0xf010461f
f0101f8a:	e8 11 e1 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f8f:	83 ec 08             	sub    $0x8,%esp
f0101f92:	68 00 10 00 00       	push   $0x1000
f0101f97:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0101f9d:	e8 ab f1 ff ff       	call   f010114d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101fa2:	8b 3d 4c 0c 17 f0    	mov    0xf0170c4c,%edi
f0101fa8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fad:	89 f8                	mov    %edi,%eax
f0101faf:	e8 4a ea ff ff       	call   f01009fe <check_va2pa>
f0101fb4:	83 c4 10             	add    $0x10,%esp
f0101fb7:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fba:	74 19                	je     f0101fd5 <mem_init+0xdbf>
f0101fbc:	68 3c 4f 10 f0       	push   $0xf0104f3c
f0101fc1:	68 45 46 10 f0       	push   $0xf0104645
f0101fc6:	68 19 04 00 00       	push   $0x419
f0101fcb:	68 1f 46 10 f0       	push   $0xf010461f
f0101fd0:	e8 cb e0 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101fd5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fda:	89 f8                	mov    %edi,%eax
f0101fdc:	e8 1d ea ff ff       	call   f01009fe <check_va2pa>
f0101fe1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fe4:	74 19                	je     f0101fff <mem_init+0xde9>
f0101fe6:	68 98 4f 10 f0       	push   $0xf0104f98
f0101feb:	68 45 46 10 f0       	push   $0xf0104645
f0101ff0:	68 1a 04 00 00       	push   $0x41a
f0101ff5:	68 1f 46 10 f0       	push   $0xf010461f
f0101ffa:	e8 a1 e0 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0101fff:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102004:	74 19                	je     f010201f <mem_init+0xe09>
f0102006:	68 79 48 10 f0       	push   $0xf0104879
f010200b:	68 45 46 10 f0       	push   $0xf0104645
f0102010:	68 1b 04 00 00       	push   $0x41b
f0102015:	68 1f 46 10 f0       	push   $0xf010461f
f010201a:	e8 81 e0 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f010201f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102024:	74 19                	je     f010203f <mem_init+0xe29>
f0102026:	68 47 48 10 f0       	push   $0xf0104847
f010202b:	68 45 46 10 f0       	push   $0xf0104645
f0102030:	68 1c 04 00 00       	push   $0x41c
f0102035:	68 1f 46 10 f0       	push   $0xf010461f
f010203a:	e8 61 e0 ff ff       	call   f01000a0 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010203f:	83 ec 0c             	sub    $0xc,%esp
f0102042:	6a 00                	push   $0x0
f0102044:	e8 58 ee ff ff       	call   f0100ea1 <page_alloc>
f0102049:	83 c4 10             	add    $0x10,%esp
f010204c:	39 c3                	cmp    %eax,%ebx
f010204e:	75 04                	jne    f0102054 <mem_init+0xe3e>
f0102050:	85 c0                	test   %eax,%eax
f0102052:	75 19                	jne    f010206d <mem_init+0xe57>
f0102054:	68 c0 4f 10 f0       	push   $0xf0104fc0
f0102059:	68 45 46 10 f0       	push   $0xf0104645
f010205e:	68 1f 04 00 00       	push   $0x41f
f0102063:	68 1f 46 10 f0       	push   $0xf010461f
f0102068:	e8 33 e0 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010206d:	83 ec 0c             	sub    $0xc,%esp
f0102070:	6a 00                	push   $0x0
f0102072:	e8 2a ee ff ff       	call   f0100ea1 <page_alloc>
f0102077:	83 c4 10             	add    $0x10,%esp
f010207a:	85 c0                	test   %eax,%eax
f010207c:	74 19                	je     f0102097 <mem_init+0xe81>
f010207e:	68 9b 47 10 f0       	push   $0xf010479b
f0102083:	68 45 46 10 f0       	push   $0xf0104645
f0102088:	68 22 04 00 00       	push   $0x422
f010208d:	68 1f 46 10 f0       	push   $0xf010461f
f0102092:	e8 09 e0 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102097:	8b 0d 4c 0c 17 f0    	mov    0xf0170c4c,%ecx
f010209d:	8b 11                	mov    (%ecx),%edx
f010209f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01020a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020a8:	2b 05 50 0c 17 f0    	sub    0xf0170c50,%eax
f01020ae:	c1 f8 03             	sar    $0x3,%eax
f01020b1:	c1 e0 0c             	shl    $0xc,%eax
f01020b4:	39 c2                	cmp    %eax,%edx
f01020b6:	74 19                	je     f01020d1 <mem_init+0xebb>
f01020b8:	68 64 4c 10 f0       	push   $0xf0104c64
f01020bd:	68 45 46 10 f0       	push   $0xf0104645
f01020c2:	68 25 04 00 00       	push   $0x425
f01020c7:	68 1f 46 10 f0       	push   $0xf010461f
f01020cc:	e8 cf df ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f01020d1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01020d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020da:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01020df:	74 19                	je     f01020fa <mem_init+0xee4>
f01020e1:	68 fe 47 10 f0       	push   $0xf01047fe
f01020e6:	68 45 46 10 f0       	push   $0xf0104645
f01020eb:	68 27 04 00 00       	push   $0x427
f01020f0:	68 1f 46 10 f0       	push   $0xf010461f
f01020f5:	e8 a6 df ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f01020fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020fd:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102103:	83 ec 0c             	sub    $0xc,%esp
f0102106:	50                   	push   %eax
f0102107:	e8 06 ee ff ff       	call   f0100f12 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010210c:	83 c4 0c             	add    $0xc,%esp
f010210f:	6a 01                	push   $0x1
f0102111:	68 00 10 40 00       	push   $0x401000
f0102116:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f010211c:	e8 6e ee ff ff       	call   f0100f8f <pgdir_walk>
f0102121:	89 c7                	mov    %eax,%edi
f0102123:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102126:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
f010212b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010212e:	8b 40 04             	mov    0x4(%eax),%eax
f0102131:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102136:	8b 0d 48 0c 17 f0    	mov    0xf0170c48,%ecx
f010213c:	89 c2                	mov    %eax,%edx
f010213e:	c1 ea 0c             	shr    $0xc,%edx
f0102141:	83 c4 10             	add    $0x10,%esp
f0102144:	39 ca                	cmp    %ecx,%edx
f0102146:	72 15                	jb     f010215d <mem_init+0xf47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102148:	50                   	push   %eax
f0102149:	68 04 49 10 f0       	push   $0xf0104904
f010214e:	68 2e 04 00 00       	push   $0x42e
f0102153:	68 1f 46 10 f0       	push   $0xf010461f
f0102158:	e8 43 df ff ff       	call   f01000a0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010215d:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102162:	39 c7                	cmp    %eax,%edi
f0102164:	74 19                	je     f010217f <mem_init+0xf69>
f0102166:	68 8a 48 10 f0       	push   $0xf010488a
f010216b:	68 45 46 10 f0       	push   $0xf0104645
f0102170:	68 2f 04 00 00       	push   $0x42f
f0102175:	68 1f 46 10 f0       	push   $0xf010461f
f010217a:	e8 21 df ff ff       	call   f01000a0 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010217f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102182:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102189:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010218c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102192:	2b 05 50 0c 17 f0    	sub    0xf0170c50,%eax
f0102198:	c1 f8 03             	sar    $0x3,%eax
f010219b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010219e:	89 c2                	mov    %eax,%edx
f01021a0:	c1 ea 0c             	shr    $0xc,%edx
f01021a3:	39 d1                	cmp    %edx,%ecx
f01021a5:	77 12                	ja     f01021b9 <mem_init+0xfa3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021a7:	50                   	push   %eax
f01021a8:	68 04 49 10 f0       	push   $0xf0104904
f01021ad:	6a 56                	push   $0x56
f01021af:	68 2b 46 10 f0       	push   $0xf010462b
f01021b4:	e8 e7 de ff ff       	call   f01000a0 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01021b9:	83 ec 04             	sub    $0x4,%esp
f01021bc:	68 00 10 00 00       	push   $0x1000
f01021c1:	68 ff 00 00 00       	push   $0xff
f01021c6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021cb:	50                   	push   %eax
f01021cc:	e8 59 1a 00 00       	call   f0103c2a <memset>
	page_free(pp0);
f01021d1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01021d4:	89 3c 24             	mov    %edi,(%esp)
f01021d7:	e8 36 ed ff ff       	call   f0100f12 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01021dc:	83 c4 0c             	add    $0xc,%esp
f01021df:	6a 01                	push   $0x1
f01021e1:	6a 00                	push   $0x0
f01021e3:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f01021e9:	e8 a1 ed ff ff       	call   f0100f8f <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01021ee:	89 fa                	mov    %edi,%edx
f01021f0:	2b 15 50 0c 17 f0    	sub    0xf0170c50,%edx
f01021f6:	c1 fa 03             	sar    $0x3,%edx
f01021f9:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021fc:	89 d0                	mov    %edx,%eax
f01021fe:	c1 e8 0c             	shr    $0xc,%eax
f0102201:	83 c4 10             	add    $0x10,%esp
f0102204:	3b 05 48 0c 17 f0    	cmp    0xf0170c48,%eax
f010220a:	72 12                	jb     f010221e <mem_init+0x1008>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010220c:	52                   	push   %edx
f010220d:	68 04 49 10 f0       	push   $0xf0104904
f0102212:	6a 56                	push   $0x56
f0102214:	68 2b 46 10 f0       	push   $0xf010462b
f0102219:	e8 82 de ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f010221e:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102224:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102227:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010222d:	f6 00 01             	testb  $0x1,(%eax)
f0102230:	74 19                	je     f010224b <mem_init+0x1035>
f0102232:	68 a2 48 10 f0       	push   $0xf01048a2
f0102237:	68 45 46 10 f0       	push   $0xf0104645
f010223c:	68 39 04 00 00       	push   $0x439
f0102241:	68 1f 46 10 f0       	push   $0xf010461f
f0102246:	e8 55 de ff ff       	call   f01000a0 <_panic>
f010224b:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010224e:	39 c2                	cmp    %eax,%edx
f0102250:	75 db                	jne    f010222d <mem_init+0x1017>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102252:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
f0102257:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010225d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102260:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102266:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102269:	89 3d 7c ff 16 f0    	mov    %edi,0xf016ff7c

	// free the pages we took
	page_free(pp0);
f010226f:	83 ec 0c             	sub    $0xc,%esp
f0102272:	50                   	push   %eax
f0102273:	e8 9a ec ff ff       	call   f0100f12 <page_free>
	page_free(pp1);
f0102278:	89 1c 24             	mov    %ebx,(%esp)
f010227b:	e8 92 ec ff ff       	call   f0100f12 <page_free>
	page_free(pp2);
f0102280:	89 34 24             	mov    %esi,(%esp)
f0102283:	e8 8a ec ff ff       	call   f0100f12 <page_free>

	cprintf("check_page() succeeded!\n");
f0102288:	c7 04 24 b9 48 10 f0 	movl   $0xf01048b9,(%esp)
f010228f:	e8 01 0b 00 00       	call   f0102d95 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102294:	a1 50 0c 17 f0       	mov    0xf0170c50,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102299:	83 c4 10             	add    $0x10,%esp
f010229c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022a1:	77 15                	ja     f01022b8 <mem_init+0x10a2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022a3:	50                   	push   %eax
f01022a4:	68 10 4a 10 f0       	push   $0xf0104a10
f01022a9:	68 c6 00 00 00       	push   $0xc6
f01022ae:	68 1f 46 10 f0       	push   $0xf010461f
f01022b3:	e8 e8 dd ff ff       	call   f01000a0 <_panic>
f01022b8:	83 ec 08             	sub    $0x8,%esp
f01022bb:	6a 04                	push   $0x4
f01022bd:	05 00 00 00 10       	add    $0x10000000,%eax
f01022c2:	50                   	push   %eax
f01022c3:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01022c8:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01022cd:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
f01022d2:	e8 4e ed ff ff       	call   f0101025 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f01022d7:	a1 88 ff 16 f0       	mov    0xf016ff88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022dc:	83 c4 10             	add    $0x10,%esp
f01022df:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022e4:	77 15                	ja     f01022fb <mem_init+0x10e5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022e6:	50                   	push   %eax
f01022e7:	68 10 4a 10 f0       	push   $0xf0104a10
f01022ec:	68 d0 00 00 00       	push   $0xd0
f01022f1:	68 1f 46 10 f0       	push   $0xf010461f
f01022f6:	e8 a5 dd ff ff       	call   f01000a0 <_panic>
f01022fb:	83 ec 08             	sub    $0x8,%esp
f01022fe:	6a 04                	push   $0x4
f0102300:	05 00 00 00 10       	add    $0x10000000,%eax
f0102305:	50                   	push   %eax
f0102306:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010230b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102310:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
f0102315:	e8 0b ed ff ff       	call   f0101025 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010231a:	83 c4 10             	add    $0x10,%esp
f010231d:	b8 00 00 11 f0       	mov    $0xf0110000,%eax
f0102322:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102327:	77 15                	ja     f010233e <mem_init+0x1128>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102329:	50                   	push   %eax
f010232a:	68 10 4a 10 f0       	push   $0xf0104a10
f010232f:	68 de 00 00 00       	push   $0xde
f0102334:	68 1f 46 10 f0       	push   $0xf010461f
f0102339:	e8 62 dd ff ff       	call   f01000a0 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010233e:	83 ec 08             	sub    $0x8,%esp
f0102341:	6a 02                	push   $0x2
f0102343:	68 00 00 11 00       	push   $0x110000
f0102348:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010234d:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102352:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
f0102357:	e8 c9 ec ff ff       	call   f0101025 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KERNBASE, ROUNDUP(~0 - KERNBASE, PGSIZE), 0, PTE_W);
f010235c:	83 c4 08             	add    $0x8,%esp
f010235f:	6a 02                	push   $0x2
f0102361:	6a 00                	push   $0x0
f0102363:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102368:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010236d:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
f0102372:	e8 ae ec ff ff       	call   f0101025 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102377:	8b 1d 4c 0c 17 f0    	mov    0xf0170c4c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010237d:	a1 48 0c 17 f0       	mov    0xf0170c48,%eax
f0102382:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102385:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010238c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102391:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102394:	8b 3d 50 0c 17 f0    	mov    0xf0170c50,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010239a:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010239d:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01023a0:	be 00 00 00 00       	mov    $0x0,%esi
f01023a5:	eb 55                	jmp    f01023fc <mem_init+0x11e6>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01023a7:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01023ad:	89 d8                	mov    %ebx,%eax
f01023af:	e8 4a e6 ff ff       	call   f01009fe <check_va2pa>
f01023b4:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01023bb:	77 15                	ja     f01023d2 <mem_init+0x11bc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01023bd:	57                   	push   %edi
f01023be:	68 10 4a 10 f0       	push   $0xf0104a10
f01023c3:	68 72 03 00 00       	push   $0x372
f01023c8:	68 1f 46 10 f0       	push   $0xf010461f
f01023cd:	e8 ce dc ff ff       	call   f01000a0 <_panic>
f01023d2:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f01023d9:	39 d0                	cmp    %edx,%eax
f01023db:	74 19                	je     f01023f6 <mem_init+0x11e0>
f01023dd:	68 e4 4f 10 f0       	push   $0xf0104fe4
f01023e2:	68 45 46 10 f0       	push   $0xf0104645
f01023e7:	68 72 03 00 00       	push   $0x372
f01023ec:	68 1f 46 10 f0       	push   $0xf010461f
f01023f1:	e8 aa dc ff ff       	call   f01000a0 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01023f6:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01023fc:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f01023ff:	77 a6                	ja     f01023a7 <mem_init+0x1191>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102401:	8b 3d 88 ff 16 f0    	mov    0xf016ff88,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102407:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010240a:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f010240f:	89 f2                	mov    %esi,%edx
f0102411:	89 d8                	mov    %ebx,%eax
f0102413:	e8 e6 e5 ff ff       	call   f01009fe <check_va2pa>
f0102418:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f010241f:	77 15                	ja     f0102436 <mem_init+0x1220>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102421:	57                   	push   %edi
f0102422:	68 10 4a 10 f0       	push   $0xf0104a10
f0102427:	68 77 03 00 00       	push   $0x377
f010242c:	68 1f 46 10 f0       	push   $0xf010461f
f0102431:	e8 6a dc ff ff       	call   f01000a0 <_panic>
f0102436:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f010243d:	39 c2                	cmp    %eax,%edx
f010243f:	74 19                	je     f010245a <mem_init+0x1244>
f0102441:	68 18 50 10 f0       	push   $0xf0105018
f0102446:	68 45 46 10 f0       	push   $0xf0104645
f010244b:	68 77 03 00 00       	push   $0x377
f0102450:	68 1f 46 10 f0       	push   $0xf010461f
f0102455:	e8 46 dc ff ff       	call   f01000a0 <_panic>
f010245a:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102460:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f0102466:	75 a7                	jne    f010240f <mem_init+0x11f9>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102468:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010246b:	c1 e7 0c             	shl    $0xc,%edi
f010246e:	be 00 00 00 00       	mov    $0x0,%esi
f0102473:	eb 30                	jmp    f01024a5 <mem_init+0x128f>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102475:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f010247b:	89 d8                	mov    %ebx,%eax
f010247d:	e8 7c e5 ff ff       	call   f01009fe <check_va2pa>
f0102482:	39 c6                	cmp    %eax,%esi
f0102484:	74 19                	je     f010249f <mem_init+0x1289>
f0102486:	68 4c 50 10 f0       	push   $0xf010504c
f010248b:	68 45 46 10 f0       	push   $0xf0104645
f0102490:	68 7b 03 00 00       	push   $0x37b
f0102495:	68 1f 46 10 f0       	push   $0xf010461f
f010249a:	e8 01 dc ff ff       	call   f01000a0 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010249f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01024a5:	39 fe                	cmp    %edi,%esi
f01024a7:	72 cc                	jb     f0102475 <mem_init+0x125f>
f01024a9:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01024ae:	89 f2                	mov    %esi,%edx
f01024b0:	89 d8                	mov    %ebx,%eax
f01024b2:	e8 47 e5 ff ff       	call   f01009fe <check_va2pa>
f01024b7:	8d 96 00 80 11 10    	lea    0x10118000(%esi),%edx
f01024bd:	39 c2                	cmp    %eax,%edx
f01024bf:	74 19                	je     f01024da <mem_init+0x12c4>
f01024c1:	68 74 50 10 f0       	push   $0xf0105074
f01024c6:	68 45 46 10 f0       	push   $0xf0104645
f01024cb:	68 7f 03 00 00       	push   $0x37f
f01024d0:	68 1f 46 10 f0       	push   $0xf010461f
f01024d5:	e8 c6 db ff ff       	call   f01000a0 <_panic>
f01024da:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01024e0:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01024e6:	75 c6                	jne    f01024ae <mem_init+0x1298>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01024e8:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01024ed:	89 d8                	mov    %ebx,%eax
f01024ef:	e8 0a e5 ff ff       	call   f01009fe <check_va2pa>
f01024f4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024f7:	74 51                	je     f010254a <mem_init+0x1334>
f01024f9:	68 bc 50 10 f0       	push   $0xf01050bc
f01024fe:	68 45 46 10 f0       	push   $0xf0104645
f0102503:	68 80 03 00 00       	push   $0x380
f0102508:	68 1f 46 10 f0       	push   $0xf010461f
f010250d:	e8 8e db ff ff       	call   f01000a0 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102512:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102517:	72 36                	jb     f010254f <mem_init+0x1339>
f0102519:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010251e:	76 07                	jbe    f0102527 <mem_init+0x1311>
f0102520:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102525:	75 28                	jne    f010254f <mem_init+0x1339>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102527:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f010252b:	0f 85 83 00 00 00    	jne    f01025b4 <mem_init+0x139e>
f0102531:	68 d2 48 10 f0       	push   $0xf01048d2
f0102536:	68 45 46 10 f0       	push   $0xf0104645
f010253b:	68 89 03 00 00       	push   $0x389
f0102540:	68 1f 46 10 f0       	push   $0xf010461f
f0102545:	e8 56 db ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010254a:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010254f:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102554:	76 3f                	jbe    f0102595 <mem_init+0x137f>
				assert(pgdir[i] & PTE_P);
f0102556:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102559:	f6 c2 01             	test   $0x1,%dl
f010255c:	75 19                	jne    f0102577 <mem_init+0x1361>
f010255e:	68 d2 48 10 f0       	push   $0xf01048d2
f0102563:	68 45 46 10 f0       	push   $0xf0104645
f0102568:	68 8d 03 00 00       	push   $0x38d
f010256d:	68 1f 46 10 f0       	push   $0xf010461f
f0102572:	e8 29 db ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_W);
f0102577:	f6 c2 02             	test   $0x2,%dl
f010257a:	75 38                	jne    f01025b4 <mem_init+0x139e>
f010257c:	68 e3 48 10 f0       	push   $0xf01048e3
f0102581:	68 45 46 10 f0       	push   $0xf0104645
f0102586:	68 8e 03 00 00       	push   $0x38e
f010258b:	68 1f 46 10 f0       	push   $0xf010461f
f0102590:	e8 0b db ff ff       	call   f01000a0 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102595:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102599:	74 19                	je     f01025b4 <mem_init+0x139e>
f010259b:	68 f4 48 10 f0       	push   $0xf01048f4
f01025a0:	68 45 46 10 f0       	push   $0xf0104645
f01025a5:	68 90 03 00 00       	push   $0x390
f01025aa:	68 1f 46 10 f0       	push   $0xf010461f
f01025af:	e8 ec da ff ff       	call   f01000a0 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01025b4:	83 c0 01             	add    $0x1,%eax
f01025b7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01025bc:	0f 86 50 ff ff ff    	jbe    f0102512 <mem_init+0x12fc>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01025c2:	83 ec 0c             	sub    $0xc,%esp
f01025c5:	68 ec 50 10 f0       	push   $0xf01050ec
f01025ca:	e8 c6 07 00 00       	call   f0102d95 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01025cf:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025d4:	83 c4 10             	add    $0x10,%esp
f01025d7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025dc:	77 15                	ja     f01025f3 <mem_init+0x13dd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025de:	50                   	push   %eax
f01025df:	68 10 4a 10 f0       	push   $0xf0104a10
f01025e4:	68 f5 00 00 00       	push   $0xf5
f01025e9:	68 1f 46 10 f0       	push   $0xf010461f
f01025ee:	e8 ad da ff ff       	call   f01000a0 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01025f3:	05 00 00 00 10       	add    $0x10000000,%eax
f01025f8:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01025fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0102600:	e8 5d e4 ff ff       	call   f0100a62 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102605:	0f 20 c0             	mov    %cr0,%eax
f0102608:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010260b:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102610:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102613:	83 ec 0c             	sub    $0xc,%esp
f0102616:	6a 00                	push   $0x0
f0102618:	e8 84 e8 ff ff       	call   f0100ea1 <page_alloc>
f010261d:	89 c3                	mov    %eax,%ebx
f010261f:	83 c4 10             	add    $0x10,%esp
f0102622:	85 c0                	test   %eax,%eax
f0102624:	75 19                	jne    f010263f <mem_init+0x1429>
f0102626:	68 f0 46 10 f0       	push   $0xf01046f0
f010262b:	68 45 46 10 f0       	push   $0xf0104645
f0102630:	68 54 04 00 00       	push   $0x454
f0102635:	68 1f 46 10 f0       	push   $0xf010461f
f010263a:	e8 61 da ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f010263f:	83 ec 0c             	sub    $0xc,%esp
f0102642:	6a 00                	push   $0x0
f0102644:	e8 58 e8 ff ff       	call   f0100ea1 <page_alloc>
f0102649:	89 c7                	mov    %eax,%edi
f010264b:	83 c4 10             	add    $0x10,%esp
f010264e:	85 c0                	test   %eax,%eax
f0102650:	75 19                	jne    f010266b <mem_init+0x1455>
f0102652:	68 06 47 10 f0       	push   $0xf0104706
f0102657:	68 45 46 10 f0       	push   $0xf0104645
f010265c:	68 55 04 00 00       	push   $0x455
f0102661:	68 1f 46 10 f0       	push   $0xf010461f
f0102666:	e8 35 da ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f010266b:	83 ec 0c             	sub    $0xc,%esp
f010266e:	6a 00                	push   $0x0
f0102670:	e8 2c e8 ff ff       	call   f0100ea1 <page_alloc>
f0102675:	89 c6                	mov    %eax,%esi
f0102677:	83 c4 10             	add    $0x10,%esp
f010267a:	85 c0                	test   %eax,%eax
f010267c:	75 19                	jne    f0102697 <mem_init+0x1481>
f010267e:	68 1c 47 10 f0       	push   $0xf010471c
f0102683:	68 45 46 10 f0       	push   $0xf0104645
f0102688:	68 56 04 00 00       	push   $0x456
f010268d:	68 1f 46 10 f0       	push   $0xf010461f
f0102692:	e8 09 da ff ff       	call   f01000a0 <_panic>
	page_free(pp0);
f0102697:	83 ec 0c             	sub    $0xc,%esp
f010269a:	53                   	push   %ebx
f010269b:	e8 72 e8 ff ff       	call   f0100f12 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026a0:	89 f8                	mov    %edi,%eax
f01026a2:	2b 05 50 0c 17 f0    	sub    0xf0170c50,%eax
f01026a8:	c1 f8 03             	sar    $0x3,%eax
f01026ab:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026ae:	89 c2                	mov    %eax,%edx
f01026b0:	c1 ea 0c             	shr    $0xc,%edx
f01026b3:	83 c4 10             	add    $0x10,%esp
f01026b6:	3b 15 48 0c 17 f0    	cmp    0xf0170c48,%edx
f01026bc:	72 12                	jb     f01026d0 <mem_init+0x14ba>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026be:	50                   	push   %eax
f01026bf:	68 04 49 10 f0       	push   $0xf0104904
f01026c4:	6a 56                	push   $0x56
f01026c6:	68 2b 46 10 f0       	push   $0xf010462b
f01026cb:	e8 d0 d9 ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01026d0:	83 ec 04             	sub    $0x4,%esp
f01026d3:	68 00 10 00 00       	push   $0x1000
f01026d8:	6a 01                	push   $0x1
f01026da:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026df:	50                   	push   %eax
f01026e0:	e8 45 15 00 00       	call   f0103c2a <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026e5:	89 f0                	mov    %esi,%eax
f01026e7:	2b 05 50 0c 17 f0    	sub    0xf0170c50,%eax
f01026ed:	c1 f8 03             	sar    $0x3,%eax
f01026f0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026f3:	89 c2                	mov    %eax,%edx
f01026f5:	c1 ea 0c             	shr    $0xc,%edx
f01026f8:	83 c4 10             	add    $0x10,%esp
f01026fb:	3b 15 48 0c 17 f0    	cmp    0xf0170c48,%edx
f0102701:	72 12                	jb     f0102715 <mem_init+0x14ff>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102703:	50                   	push   %eax
f0102704:	68 04 49 10 f0       	push   $0xf0104904
f0102709:	6a 56                	push   $0x56
f010270b:	68 2b 46 10 f0       	push   $0xf010462b
f0102710:	e8 8b d9 ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102715:	83 ec 04             	sub    $0x4,%esp
f0102718:	68 00 10 00 00       	push   $0x1000
f010271d:	6a 02                	push   $0x2
f010271f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102724:	50                   	push   %eax
f0102725:	e8 00 15 00 00       	call   f0103c2a <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010272a:	6a 02                	push   $0x2
f010272c:	68 00 10 00 00       	push   $0x1000
f0102731:	57                   	push   %edi
f0102732:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0102738:	e8 52 ea ff ff       	call   f010118f <page_insert>
	assert(pp1->pp_ref == 1);
f010273d:	83 c4 20             	add    $0x20,%esp
f0102740:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102745:	74 19                	je     f0102760 <mem_init+0x154a>
f0102747:	68 ed 47 10 f0       	push   $0xf01047ed
f010274c:	68 45 46 10 f0       	push   $0xf0104645
f0102751:	68 5b 04 00 00       	push   $0x45b
f0102756:	68 1f 46 10 f0       	push   $0xf010461f
f010275b:	e8 40 d9 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102760:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102767:	01 01 01 
f010276a:	74 19                	je     f0102785 <mem_init+0x156f>
f010276c:	68 0c 51 10 f0       	push   $0xf010510c
f0102771:	68 45 46 10 f0       	push   $0xf0104645
f0102776:	68 5c 04 00 00       	push   $0x45c
f010277b:	68 1f 46 10 f0       	push   $0xf010461f
f0102780:	e8 1b d9 ff ff       	call   f01000a0 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102785:	6a 02                	push   $0x2
f0102787:	68 00 10 00 00       	push   $0x1000
f010278c:	56                   	push   %esi
f010278d:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0102793:	e8 f7 e9 ff ff       	call   f010118f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102798:	83 c4 10             	add    $0x10,%esp
f010279b:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01027a2:	02 02 02 
f01027a5:	74 19                	je     f01027c0 <mem_init+0x15aa>
f01027a7:	68 30 51 10 f0       	push   $0xf0105130
f01027ac:	68 45 46 10 f0       	push   $0xf0104645
f01027b1:	68 5e 04 00 00       	push   $0x45e
f01027b6:	68 1f 46 10 f0       	push   $0xf010461f
f01027bb:	e8 e0 d8 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01027c0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01027c5:	74 19                	je     f01027e0 <mem_init+0x15ca>
f01027c7:	68 0f 48 10 f0       	push   $0xf010480f
f01027cc:	68 45 46 10 f0       	push   $0xf0104645
f01027d1:	68 5f 04 00 00       	push   $0x45f
f01027d6:	68 1f 46 10 f0       	push   $0xf010461f
f01027db:	e8 c0 d8 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f01027e0:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01027e5:	74 19                	je     f0102800 <mem_init+0x15ea>
f01027e7:	68 79 48 10 f0       	push   $0xf0104879
f01027ec:	68 45 46 10 f0       	push   $0xf0104645
f01027f1:	68 60 04 00 00       	push   $0x460
f01027f6:	68 1f 46 10 f0       	push   $0xf010461f
f01027fb:	e8 a0 d8 ff ff       	call   f01000a0 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102800:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102807:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010280a:	89 f0                	mov    %esi,%eax
f010280c:	2b 05 50 0c 17 f0    	sub    0xf0170c50,%eax
f0102812:	c1 f8 03             	sar    $0x3,%eax
f0102815:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102818:	89 c2                	mov    %eax,%edx
f010281a:	c1 ea 0c             	shr    $0xc,%edx
f010281d:	3b 15 48 0c 17 f0    	cmp    0xf0170c48,%edx
f0102823:	72 12                	jb     f0102837 <mem_init+0x1621>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102825:	50                   	push   %eax
f0102826:	68 04 49 10 f0       	push   $0xf0104904
f010282b:	6a 56                	push   $0x56
f010282d:	68 2b 46 10 f0       	push   $0xf010462b
f0102832:	e8 69 d8 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102837:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010283e:	03 03 03 
f0102841:	74 19                	je     f010285c <mem_init+0x1646>
f0102843:	68 54 51 10 f0       	push   $0xf0105154
f0102848:	68 45 46 10 f0       	push   $0xf0104645
f010284d:	68 62 04 00 00       	push   $0x462
f0102852:	68 1f 46 10 f0       	push   $0xf010461f
f0102857:	e8 44 d8 ff ff       	call   f01000a0 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010285c:	83 ec 08             	sub    $0x8,%esp
f010285f:	68 00 10 00 00       	push   $0x1000
f0102864:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f010286a:	e8 de e8 ff ff       	call   f010114d <page_remove>
	assert(pp2->pp_ref == 0);
f010286f:	83 c4 10             	add    $0x10,%esp
f0102872:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102877:	74 19                	je     f0102892 <mem_init+0x167c>
f0102879:	68 47 48 10 f0       	push   $0xf0104847
f010287e:	68 45 46 10 f0       	push   $0xf0104645
f0102883:	68 64 04 00 00       	push   $0x464
f0102888:	68 1f 46 10 f0       	push   $0xf010461f
f010288d:	e8 0e d8 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102892:	8b 0d 4c 0c 17 f0    	mov    0xf0170c4c,%ecx
f0102898:	8b 11                	mov    (%ecx),%edx
f010289a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01028a0:	89 d8                	mov    %ebx,%eax
f01028a2:	2b 05 50 0c 17 f0    	sub    0xf0170c50,%eax
f01028a8:	c1 f8 03             	sar    $0x3,%eax
f01028ab:	c1 e0 0c             	shl    $0xc,%eax
f01028ae:	39 c2                	cmp    %eax,%edx
f01028b0:	74 19                	je     f01028cb <mem_init+0x16b5>
f01028b2:	68 64 4c 10 f0       	push   $0xf0104c64
f01028b7:	68 45 46 10 f0       	push   $0xf0104645
f01028bc:	68 67 04 00 00       	push   $0x467
f01028c1:	68 1f 46 10 f0       	push   $0xf010461f
f01028c6:	e8 d5 d7 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f01028cb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01028d1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01028d6:	74 19                	je     f01028f1 <mem_init+0x16db>
f01028d8:	68 fe 47 10 f0       	push   $0xf01047fe
f01028dd:	68 45 46 10 f0       	push   $0xf0104645
f01028e2:	68 69 04 00 00       	push   $0x469
f01028e7:	68 1f 46 10 f0       	push   $0xf010461f
f01028ec:	e8 af d7 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f01028f1:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01028f7:	83 ec 0c             	sub    $0xc,%esp
f01028fa:	53                   	push   %ebx
f01028fb:	e8 12 e6 ff ff       	call   f0100f12 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102900:	c7 04 24 80 51 10 f0 	movl   $0xf0105180,(%esp)
f0102907:	e8 89 04 00 00       	call   f0102d95 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010290c:	83 c4 10             	add    $0x10,%esp
f010290f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102912:	5b                   	pop    %ebx
f0102913:	5e                   	pop    %esi
f0102914:	5f                   	pop    %edi
f0102915:	5d                   	pop    %ebp
f0102916:	c3                   	ret    

f0102917 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102917:	55                   	push   %ebp
f0102918:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010291a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010291d:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102920:	5d                   	pop    %ebp
f0102921:	c3                   	ret    

f0102922 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102922:	55                   	push   %ebp
f0102923:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f0102925:	b8 00 00 00 00       	mov    $0x0,%eax
f010292a:	5d                   	pop    %ebp
f010292b:	c3                   	ret    

f010292c <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010292c:	55                   	push   %ebp
f010292d:	89 e5                	mov    %esp,%ebp
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
	}
}
f010292f:	5d                   	pop    %ebp
f0102930:	c3                   	ret    

f0102931 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102931:	55                   	push   %ebp
f0102932:	89 e5                	mov    %esp,%ebp
f0102934:	8b 55 08             	mov    0x8(%ebp),%edx
f0102937:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010293a:	85 d2                	test   %edx,%edx
f010293c:	75 11                	jne    f010294f <envid2env+0x1e>
		*env_store = curenv;
f010293e:	a1 84 ff 16 f0       	mov    0xf016ff84,%eax
f0102943:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102946:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102948:	b8 00 00 00 00       	mov    $0x0,%eax
f010294d:	eb 5e                	jmp    f01029ad <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010294f:	89 d0                	mov    %edx,%eax
f0102951:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102956:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102959:	c1 e0 05             	shl    $0x5,%eax
f010295c:	03 05 88 ff 16 f0    	add    0xf016ff88,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102962:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0102966:	74 05                	je     f010296d <envid2env+0x3c>
f0102968:	3b 50 48             	cmp    0x48(%eax),%edx
f010296b:	74 10                	je     f010297d <envid2env+0x4c>
		*env_store = 0;
f010296d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102970:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102976:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010297b:	eb 30                	jmp    f01029ad <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010297d:	84 c9                	test   %cl,%cl
f010297f:	74 22                	je     f01029a3 <envid2env+0x72>
f0102981:	8b 15 84 ff 16 f0    	mov    0xf016ff84,%edx
f0102987:	39 d0                	cmp    %edx,%eax
f0102989:	74 18                	je     f01029a3 <envid2env+0x72>
f010298b:	8b 4a 48             	mov    0x48(%edx),%ecx
f010298e:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f0102991:	74 10                	je     f01029a3 <envid2env+0x72>
		*env_store = 0;
f0102993:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102996:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010299c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01029a1:	eb 0a                	jmp    f01029ad <envid2env+0x7c>
	}

	*env_store = e;
f01029a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01029a6:	89 01                	mov    %eax,(%ecx)
	return 0;
f01029a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01029ad:	5d                   	pop    %ebp
f01029ae:	c3                   	ret    

f01029af <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01029af:	55                   	push   %ebp
f01029b0:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01029b2:	b8 00 a3 11 f0       	mov    $0xf011a300,%eax
f01029b7:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01029ba:	b8 23 00 00 00       	mov    $0x23,%eax
f01029bf:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01029c1:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01029c3:	b8 10 00 00 00       	mov    $0x10,%eax
f01029c8:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01029ca:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01029cc:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01029ce:	ea d5 29 10 f0 08 00 	ljmp   $0x8,$0xf01029d5
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f01029d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01029da:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01029dd:	5d                   	pop    %ebp
f01029de:	c3                   	ret    

f01029df <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01029df:	55                   	push   %ebp
f01029e0:	89 e5                	mov    %esp,%ebp
	// Set up envs array
	// LAB 3: Your code here.

	// Per-CPU part of the initialization
	env_init_percpu();
f01029e2:	e8 c8 ff ff ff       	call   f01029af <env_init_percpu>
}
f01029e7:	5d                   	pop    %ebp
f01029e8:	c3                   	ret    

f01029e9 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01029e9:	55                   	push   %ebp
f01029ea:	89 e5                	mov    %esp,%ebp
f01029ec:	53                   	push   %ebx
f01029ed:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01029f0:	8b 1d 8c ff 16 f0    	mov    0xf016ff8c,%ebx
f01029f6:	85 db                	test   %ebx,%ebx
f01029f8:	0f 84 f4 00 00 00    	je     f0102af2 <env_alloc+0x109>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01029fe:	83 ec 0c             	sub    $0xc,%esp
f0102a01:	6a 01                	push   $0x1
f0102a03:	e8 99 e4 ff ff       	call   f0100ea1 <page_alloc>
f0102a08:	83 c4 10             	add    $0x10,%esp
f0102a0b:	85 c0                	test   %eax,%eax
f0102a0d:	0f 84 e6 00 00 00    	je     f0102af9 <env_alloc+0x110>

	// LAB 3: Your code here.

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102a13:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a16:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a1b:	77 15                	ja     f0102a32 <env_alloc+0x49>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a1d:	50                   	push   %eax
f0102a1e:	68 10 4a 10 f0       	push   $0xf0104a10
f0102a23:	68 b9 00 00 00       	push   $0xb9
f0102a28:	68 e2 51 10 f0       	push   $0xf01051e2
f0102a2d:	e8 6e d6 ff ff       	call   f01000a0 <_panic>
f0102a32:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102a38:	83 ca 05             	or     $0x5,%edx
f0102a3b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102a41:	8b 43 48             	mov    0x48(%ebx),%eax
f0102a44:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102a49:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102a4e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a53:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102a56:	89 da                	mov    %ebx,%edx
f0102a58:	2b 15 88 ff 16 f0    	sub    0xf016ff88,%edx
f0102a5e:	c1 fa 05             	sar    $0x5,%edx
f0102a61:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102a67:	09 d0                	or     %edx,%eax
f0102a69:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a6f:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102a72:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102a79:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102a80:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102a87:	83 ec 04             	sub    $0x4,%esp
f0102a8a:	6a 44                	push   $0x44
f0102a8c:	6a 00                	push   $0x0
f0102a8e:	53                   	push   %ebx
f0102a8f:	e8 96 11 00 00       	call   f0103c2a <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102a94:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102a9a:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102aa0:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102aa6:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102aad:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102ab3:	8b 43 44             	mov    0x44(%ebx),%eax
f0102ab6:	a3 8c ff 16 f0       	mov    %eax,0xf016ff8c
	*newenv_store = e;
f0102abb:	8b 45 08             	mov    0x8(%ebp),%eax
f0102abe:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102ac0:	8b 53 48             	mov    0x48(%ebx),%edx
f0102ac3:	a1 84 ff 16 f0       	mov    0xf016ff84,%eax
f0102ac8:	83 c4 10             	add    $0x10,%esp
f0102acb:	85 c0                	test   %eax,%eax
f0102acd:	74 05                	je     f0102ad4 <env_alloc+0xeb>
f0102acf:	8b 40 48             	mov    0x48(%eax),%eax
f0102ad2:	eb 05                	jmp    f0102ad9 <env_alloc+0xf0>
f0102ad4:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ad9:	83 ec 04             	sub    $0x4,%esp
f0102adc:	52                   	push   %edx
f0102add:	50                   	push   %eax
f0102ade:	68 ed 51 10 f0       	push   $0xf01051ed
f0102ae3:	e8 ad 02 00 00       	call   f0102d95 <cprintf>
	return 0;
f0102ae8:	83 c4 10             	add    $0x10,%esp
f0102aeb:	b8 00 00 00 00       	mov    $0x0,%eax
f0102af0:	eb 0c                	jmp    f0102afe <env_alloc+0x115>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102af2:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102af7:	eb 05                	jmp    f0102afe <env_alloc+0x115>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102af9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102afe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102b01:	c9                   	leave  
f0102b02:	c3                   	ret    

f0102b03 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102b03:	55                   	push   %ebp
f0102b04:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0102b06:	5d                   	pop    %ebp
f0102b07:	c3                   	ret    

f0102b08 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102b08:	55                   	push   %ebp
f0102b09:	89 e5                	mov    %esp,%ebp
f0102b0b:	57                   	push   %edi
f0102b0c:	56                   	push   %esi
f0102b0d:	53                   	push   %ebx
f0102b0e:	83 ec 1c             	sub    $0x1c,%esp
f0102b11:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102b14:	8b 15 84 ff 16 f0    	mov    0xf016ff84,%edx
f0102b1a:	39 fa                	cmp    %edi,%edx
f0102b1c:	75 29                	jne    f0102b47 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102b1e:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b23:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b28:	77 15                	ja     f0102b3f <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b2a:	50                   	push   %eax
f0102b2b:	68 10 4a 10 f0       	push   $0xf0104a10
f0102b30:	68 68 01 00 00       	push   $0x168
f0102b35:	68 e2 51 10 f0       	push   $0xf01051e2
f0102b3a:	e8 61 d5 ff ff       	call   f01000a0 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b3f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b44:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102b47:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102b4a:	85 d2                	test   %edx,%edx
f0102b4c:	74 05                	je     f0102b53 <env_free+0x4b>
f0102b4e:	8b 42 48             	mov    0x48(%edx),%eax
f0102b51:	eb 05                	jmp    f0102b58 <env_free+0x50>
f0102b53:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b58:	83 ec 04             	sub    $0x4,%esp
f0102b5b:	51                   	push   %ecx
f0102b5c:	50                   	push   %eax
f0102b5d:	68 02 52 10 f0       	push   $0xf0105202
f0102b62:	e8 2e 02 00 00       	call   f0102d95 <cprintf>
f0102b67:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102b6a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102b71:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102b74:	89 d0                	mov    %edx,%eax
f0102b76:	c1 e0 02             	shl    $0x2,%eax
f0102b79:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102b7c:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102b7f:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102b82:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102b88:	0f 84 a8 00 00 00    	je     f0102c36 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102b8e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b94:	89 f0                	mov    %esi,%eax
f0102b96:	c1 e8 0c             	shr    $0xc,%eax
f0102b99:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102b9c:	39 05 48 0c 17 f0    	cmp    %eax,0xf0170c48
f0102ba2:	77 15                	ja     f0102bb9 <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ba4:	56                   	push   %esi
f0102ba5:	68 04 49 10 f0       	push   $0xf0104904
f0102baa:	68 77 01 00 00       	push   $0x177
f0102baf:	68 e2 51 10 f0       	push   $0xf01051e2
f0102bb4:	e8 e7 d4 ff ff       	call   f01000a0 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102bb9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102bbc:	c1 e0 16             	shl    $0x16,%eax
f0102bbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102bc2:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102bc7:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102bce:	01 
f0102bcf:	74 17                	je     f0102be8 <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102bd1:	83 ec 08             	sub    $0x8,%esp
f0102bd4:	89 d8                	mov    %ebx,%eax
f0102bd6:	c1 e0 0c             	shl    $0xc,%eax
f0102bd9:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102bdc:	50                   	push   %eax
f0102bdd:	ff 77 5c             	pushl  0x5c(%edi)
f0102be0:	e8 68 e5 ff ff       	call   f010114d <page_remove>
f0102be5:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102be8:	83 c3 01             	add    $0x1,%ebx
f0102beb:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102bf1:	75 d4                	jne    f0102bc7 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102bf3:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102bf6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102bf9:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c00:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102c03:	3b 05 48 0c 17 f0    	cmp    0xf0170c48,%eax
f0102c09:	72 14                	jb     f0102c1f <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102c0b:	83 ec 04             	sub    $0x4,%esp
f0102c0e:	68 30 4b 10 f0       	push   $0xf0104b30
f0102c13:	6a 4f                	push   $0x4f
f0102c15:	68 2b 46 10 f0       	push   $0xf010462b
f0102c1a:	e8 81 d4 ff ff       	call   f01000a0 <_panic>
		page_decref(pa2page(pa));
f0102c1f:	83 ec 0c             	sub    $0xc,%esp
f0102c22:	a1 50 0c 17 f0       	mov    0xf0170c50,%eax
f0102c27:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102c2a:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102c2d:	50                   	push   %eax
f0102c2e:	e8 35 e3 ff ff       	call   f0100f68 <page_decref>
f0102c33:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102c36:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102c3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c3d:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102c42:	0f 85 29 ff ff ff    	jne    f0102b71 <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102c48:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c4b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c50:	77 15                	ja     f0102c67 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c52:	50                   	push   %eax
f0102c53:	68 10 4a 10 f0       	push   $0xf0104a10
f0102c58:	68 85 01 00 00       	push   $0x185
f0102c5d:	68 e2 51 10 f0       	push   $0xf01051e2
f0102c62:	e8 39 d4 ff ff       	call   f01000a0 <_panic>
	e->env_pgdir = 0;
f0102c67:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c6e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c73:	c1 e8 0c             	shr    $0xc,%eax
f0102c76:	3b 05 48 0c 17 f0    	cmp    0xf0170c48,%eax
f0102c7c:	72 14                	jb     f0102c92 <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102c7e:	83 ec 04             	sub    $0x4,%esp
f0102c81:	68 30 4b 10 f0       	push   $0xf0104b30
f0102c86:	6a 4f                	push   $0x4f
f0102c88:	68 2b 46 10 f0       	push   $0xf010462b
f0102c8d:	e8 0e d4 ff ff       	call   f01000a0 <_panic>
	page_decref(pa2page(pa));
f0102c92:	83 ec 0c             	sub    $0xc,%esp
f0102c95:	8b 15 50 0c 17 f0    	mov    0xf0170c50,%edx
f0102c9b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102c9e:	50                   	push   %eax
f0102c9f:	e8 c4 e2 ff ff       	call   f0100f68 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102ca4:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102cab:	a1 8c ff 16 f0       	mov    0xf016ff8c,%eax
f0102cb0:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102cb3:	89 3d 8c ff 16 f0    	mov    %edi,0xf016ff8c
}
f0102cb9:	83 c4 10             	add    $0x10,%esp
f0102cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cbf:	5b                   	pop    %ebx
f0102cc0:	5e                   	pop    %esi
f0102cc1:	5f                   	pop    %edi
f0102cc2:	5d                   	pop    %ebp
f0102cc3:	c3                   	ret    

f0102cc4 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102cc4:	55                   	push   %ebp
f0102cc5:	89 e5                	mov    %esp,%ebp
f0102cc7:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102cca:	ff 75 08             	pushl  0x8(%ebp)
f0102ccd:	e8 36 fe ff ff       	call   f0102b08 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102cd2:	c7 04 24 ac 51 10 f0 	movl   $0xf01051ac,(%esp)
f0102cd9:	e8 b7 00 00 00       	call   f0102d95 <cprintf>
f0102cde:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102ce1:	83 ec 0c             	sub    $0xc,%esp
f0102ce4:	6a 00                	push   $0x0
f0102ce6:	e8 4f db ff ff       	call   f010083a <monitor>
f0102ceb:	83 c4 10             	add    $0x10,%esp
f0102cee:	eb f1                	jmp    f0102ce1 <env_destroy+0x1d>

f0102cf0 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102cf0:	55                   	push   %ebp
f0102cf1:	89 e5                	mov    %esp,%ebp
f0102cf3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile(
f0102cf6:	8b 65 08             	mov    0x8(%ebp),%esp
f0102cf9:	61                   	popa   
f0102cfa:	07                   	pop    %es
f0102cfb:	1f                   	pop    %ds
f0102cfc:	83 c4 08             	add    $0x8,%esp
f0102cff:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102d00:	68 18 52 10 f0       	push   $0xf0105218
f0102d05:	68 ae 01 00 00       	push   $0x1ae
f0102d0a:	68 e2 51 10 f0       	push   $0xf01051e2
f0102d0f:	e8 8c d3 ff ff       	call   f01000a0 <_panic>

f0102d14 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102d14:	55                   	push   %ebp
f0102d15:	89 e5                	mov    %esp,%ebp
f0102d17:	83 ec 0c             	sub    $0xc,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f0102d1a:	68 24 52 10 f0       	push   $0xf0105224
f0102d1f:	68 cd 01 00 00       	push   $0x1cd
f0102d24:	68 e2 51 10 f0       	push   $0xf01051e2
f0102d29:	e8 72 d3 ff ff       	call   f01000a0 <_panic>

f0102d2e <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102d2e:	55                   	push   %ebp
f0102d2f:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102d31:	ba 70 00 00 00       	mov    $0x70,%edx
f0102d36:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d39:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102d3a:	ba 71 00 00 00       	mov    $0x71,%edx
f0102d3f:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102d40:	0f b6 c0             	movzbl %al,%eax
}
f0102d43:	5d                   	pop    %ebp
f0102d44:	c3                   	ret    

f0102d45 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102d45:	55                   	push   %ebp
f0102d46:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102d48:	ba 70 00 00 00       	mov    $0x70,%edx
f0102d4d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d50:	ee                   	out    %al,(%dx)
f0102d51:	ba 71 00 00 00       	mov    $0x71,%edx
f0102d56:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d59:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102d5a:	5d                   	pop    %ebp
f0102d5b:	c3                   	ret    

f0102d5c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102d5c:	55                   	push   %ebp
f0102d5d:	89 e5                	mov    %esp,%ebp
f0102d5f:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102d62:	ff 75 08             	pushl  0x8(%ebp)
f0102d65:	e8 ab d8 ff ff       	call   f0100615 <cputchar>
	*cnt++;
}
f0102d6a:	83 c4 10             	add    $0x10,%esp
f0102d6d:	c9                   	leave  
f0102d6e:	c3                   	ret    

f0102d6f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102d6f:	55                   	push   %ebp
f0102d70:	89 e5                	mov    %esp,%ebp
f0102d72:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102d75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102d7c:	ff 75 0c             	pushl  0xc(%ebp)
f0102d7f:	ff 75 08             	pushl  0x8(%ebp)
f0102d82:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102d85:	50                   	push   %eax
f0102d86:	68 5c 2d 10 f0       	push   $0xf0102d5c
f0102d8b:	e8 2e 08 00 00       	call   f01035be <vprintfmt>
	return cnt;
}
f0102d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102d93:	c9                   	leave  
f0102d94:	c3                   	ret    

f0102d95 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102d95:	55                   	push   %ebp
f0102d96:	89 e5                	mov    %esp,%ebp
f0102d98:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102d9b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102d9e:	50                   	push   %eax
f0102d9f:	ff 75 08             	pushl  0x8(%ebp)
f0102da2:	e8 c8 ff ff ff       	call   f0102d6f <vcprintf>
	va_end(ap);

	return cnt;
}
f0102da7:	c9                   	leave  
f0102da8:	c3                   	ret    

f0102da9 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0102da9:	55                   	push   %ebp
f0102daa:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102dac:	b8 c0 07 17 f0       	mov    $0xf01707c0,%eax
f0102db1:	c7 05 c4 07 17 f0 00 	movl   $0xf0000000,0xf01707c4
f0102db8:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0102dbb:	66 c7 05 c8 07 17 f0 	movw   $0x10,0xf01707c8
f0102dc2:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0102dc4:	66 c7 05 26 08 17 f0 	movw   $0x68,0xf0170826
f0102dcb:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102dcd:	66 c7 05 48 a3 11 f0 	movw   $0x67,0xf011a348
f0102dd4:	67 00 
f0102dd6:	66 a3 4a a3 11 f0    	mov    %ax,0xf011a34a
f0102ddc:	89 c2                	mov    %eax,%edx
f0102dde:	c1 ea 10             	shr    $0x10,%edx
f0102de1:	88 15 4c a3 11 f0    	mov    %dl,0xf011a34c
f0102de7:	c6 05 4e a3 11 f0 40 	movb   $0x40,0xf011a34e
f0102dee:	c1 e8 18             	shr    $0x18,%eax
f0102df1:	a2 4f a3 11 f0       	mov    %al,0xf011a34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0102df6:	c6 05 4d a3 11 f0 89 	movb   $0x89,0xf011a34d
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0102dfd:	b8 28 00 00 00       	mov    $0x28,%eax
f0102e02:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0102e05:	b8 50 a3 11 f0       	mov    $0xf011a350,%eax
f0102e0a:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0102e0d:	5d                   	pop    %ebp
f0102e0e:	c3                   	ret    

f0102e0f <trap_init>:
}


void
trap_init(void)
{
f0102e0f:	55                   	push   %ebp
f0102e10:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f0102e12:	e8 92 ff ff ff       	call   f0102da9 <trap_init_percpu>
}
f0102e17:	5d                   	pop    %ebp
f0102e18:	c3                   	ret    

f0102e19 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0102e19:	55                   	push   %ebp
f0102e1a:	89 e5                	mov    %esp,%ebp
f0102e1c:	53                   	push   %ebx
f0102e1d:	83 ec 0c             	sub    $0xc,%esp
f0102e20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0102e23:	ff 33                	pushl  (%ebx)
f0102e25:	68 40 52 10 f0       	push   $0xf0105240
f0102e2a:	e8 66 ff ff ff       	call   f0102d95 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0102e2f:	83 c4 08             	add    $0x8,%esp
f0102e32:	ff 73 04             	pushl  0x4(%ebx)
f0102e35:	68 4f 52 10 f0       	push   $0xf010524f
f0102e3a:	e8 56 ff ff ff       	call   f0102d95 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0102e3f:	83 c4 08             	add    $0x8,%esp
f0102e42:	ff 73 08             	pushl  0x8(%ebx)
f0102e45:	68 5e 52 10 f0       	push   $0xf010525e
f0102e4a:	e8 46 ff ff ff       	call   f0102d95 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0102e4f:	83 c4 08             	add    $0x8,%esp
f0102e52:	ff 73 0c             	pushl  0xc(%ebx)
f0102e55:	68 6d 52 10 f0       	push   $0xf010526d
f0102e5a:	e8 36 ff ff ff       	call   f0102d95 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0102e5f:	83 c4 08             	add    $0x8,%esp
f0102e62:	ff 73 10             	pushl  0x10(%ebx)
f0102e65:	68 7c 52 10 f0       	push   $0xf010527c
f0102e6a:	e8 26 ff ff ff       	call   f0102d95 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0102e6f:	83 c4 08             	add    $0x8,%esp
f0102e72:	ff 73 14             	pushl  0x14(%ebx)
f0102e75:	68 8b 52 10 f0       	push   $0xf010528b
f0102e7a:	e8 16 ff ff ff       	call   f0102d95 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0102e7f:	83 c4 08             	add    $0x8,%esp
f0102e82:	ff 73 18             	pushl  0x18(%ebx)
f0102e85:	68 9a 52 10 f0       	push   $0xf010529a
f0102e8a:	e8 06 ff ff ff       	call   f0102d95 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0102e8f:	83 c4 08             	add    $0x8,%esp
f0102e92:	ff 73 1c             	pushl  0x1c(%ebx)
f0102e95:	68 a9 52 10 f0       	push   $0xf01052a9
f0102e9a:	e8 f6 fe ff ff       	call   f0102d95 <cprintf>
}
f0102e9f:	83 c4 10             	add    $0x10,%esp
f0102ea2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102ea5:	c9                   	leave  
f0102ea6:	c3                   	ret    

f0102ea7 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0102ea7:	55                   	push   %ebp
f0102ea8:	89 e5                	mov    %esp,%ebp
f0102eaa:	56                   	push   %esi
f0102eab:	53                   	push   %ebx
f0102eac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0102eaf:	83 ec 08             	sub    $0x8,%esp
f0102eb2:	53                   	push   %ebx
f0102eb3:	68 df 53 10 f0       	push   $0xf01053df
f0102eb8:	e8 d8 fe ff ff       	call   f0102d95 <cprintf>
	print_regs(&tf->tf_regs);
f0102ebd:	89 1c 24             	mov    %ebx,(%esp)
f0102ec0:	e8 54 ff ff ff       	call   f0102e19 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0102ec5:	83 c4 08             	add    $0x8,%esp
f0102ec8:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0102ecc:	50                   	push   %eax
f0102ecd:	68 fa 52 10 f0       	push   $0xf01052fa
f0102ed2:	e8 be fe ff ff       	call   f0102d95 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0102ed7:	83 c4 08             	add    $0x8,%esp
f0102eda:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0102ede:	50                   	push   %eax
f0102edf:	68 0d 53 10 f0       	push   $0xf010530d
f0102ee4:	e8 ac fe ff ff       	call   f0102d95 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0102ee9:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0102eec:	83 c4 10             	add    $0x10,%esp
f0102eef:	83 f8 13             	cmp    $0x13,%eax
f0102ef2:	77 09                	ja     f0102efd <print_trapframe+0x56>
		return excnames[trapno];
f0102ef4:	8b 14 85 c0 55 10 f0 	mov    -0xfefaa40(,%eax,4),%edx
f0102efb:	eb 10                	jmp    f0102f0d <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f0102efd:	83 f8 30             	cmp    $0x30,%eax
f0102f00:	b9 c4 52 10 f0       	mov    $0xf01052c4,%ecx
f0102f05:	ba b8 52 10 f0       	mov    $0xf01052b8,%edx
f0102f0a:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0102f0d:	83 ec 04             	sub    $0x4,%esp
f0102f10:	52                   	push   %edx
f0102f11:	50                   	push   %eax
f0102f12:	68 20 53 10 f0       	push   $0xf0105320
f0102f17:	e8 79 fe ff ff       	call   f0102d95 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0102f1c:	83 c4 10             	add    $0x10,%esp
f0102f1f:	3b 1d a0 07 17 f0    	cmp    0xf01707a0,%ebx
f0102f25:	75 1a                	jne    f0102f41 <print_trapframe+0x9a>
f0102f27:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0102f2b:	75 14                	jne    f0102f41 <print_trapframe+0x9a>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0102f2d:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0102f30:	83 ec 08             	sub    $0x8,%esp
f0102f33:	50                   	push   %eax
f0102f34:	68 32 53 10 f0       	push   $0xf0105332
f0102f39:	e8 57 fe ff ff       	call   f0102d95 <cprintf>
f0102f3e:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0102f41:	83 ec 08             	sub    $0x8,%esp
f0102f44:	ff 73 2c             	pushl  0x2c(%ebx)
f0102f47:	68 41 53 10 f0       	push   $0xf0105341
f0102f4c:	e8 44 fe ff ff       	call   f0102d95 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0102f51:	83 c4 10             	add    $0x10,%esp
f0102f54:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0102f58:	75 49                	jne    f0102fa3 <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0102f5a:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0102f5d:	89 c2                	mov    %eax,%edx
f0102f5f:	83 e2 01             	and    $0x1,%edx
f0102f62:	ba de 52 10 f0       	mov    $0xf01052de,%edx
f0102f67:	b9 d3 52 10 f0       	mov    $0xf01052d3,%ecx
f0102f6c:	0f 44 ca             	cmove  %edx,%ecx
f0102f6f:	89 c2                	mov    %eax,%edx
f0102f71:	83 e2 02             	and    $0x2,%edx
f0102f74:	ba f0 52 10 f0       	mov    $0xf01052f0,%edx
f0102f79:	be ea 52 10 f0       	mov    $0xf01052ea,%esi
f0102f7e:	0f 45 d6             	cmovne %esi,%edx
f0102f81:	83 e0 04             	and    $0x4,%eax
f0102f84:	be 0a 54 10 f0       	mov    $0xf010540a,%esi
f0102f89:	b8 f5 52 10 f0       	mov    $0xf01052f5,%eax
f0102f8e:	0f 44 c6             	cmove  %esi,%eax
f0102f91:	51                   	push   %ecx
f0102f92:	52                   	push   %edx
f0102f93:	50                   	push   %eax
f0102f94:	68 4f 53 10 f0       	push   $0xf010534f
f0102f99:	e8 f7 fd ff ff       	call   f0102d95 <cprintf>
f0102f9e:	83 c4 10             	add    $0x10,%esp
f0102fa1:	eb 10                	jmp    f0102fb3 <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0102fa3:	83 ec 0c             	sub    $0xc,%esp
f0102fa6:	68 d0 48 10 f0       	push   $0xf01048d0
f0102fab:	e8 e5 fd ff ff       	call   f0102d95 <cprintf>
f0102fb0:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0102fb3:	83 ec 08             	sub    $0x8,%esp
f0102fb6:	ff 73 30             	pushl  0x30(%ebx)
f0102fb9:	68 5e 53 10 f0       	push   $0xf010535e
f0102fbe:	e8 d2 fd ff ff       	call   f0102d95 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0102fc3:	83 c4 08             	add    $0x8,%esp
f0102fc6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0102fca:	50                   	push   %eax
f0102fcb:	68 6d 53 10 f0       	push   $0xf010536d
f0102fd0:	e8 c0 fd ff ff       	call   f0102d95 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0102fd5:	83 c4 08             	add    $0x8,%esp
f0102fd8:	ff 73 38             	pushl  0x38(%ebx)
f0102fdb:	68 80 53 10 f0       	push   $0xf0105380
f0102fe0:	e8 b0 fd ff ff       	call   f0102d95 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0102fe5:	83 c4 10             	add    $0x10,%esp
f0102fe8:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0102fec:	74 25                	je     f0103013 <print_trapframe+0x16c>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0102fee:	83 ec 08             	sub    $0x8,%esp
f0102ff1:	ff 73 3c             	pushl  0x3c(%ebx)
f0102ff4:	68 8f 53 10 f0       	push   $0xf010538f
f0102ff9:	e8 97 fd ff ff       	call   f0102d95 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0102ffe:	83 c4 08             	add    $0x8,%esp
f0103001:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103005:	50                   	push   %eax
f0103006:	68 9e 53 10 f0       	push   $0xf010539e
f010300b:	e8 85 fd ff ff       	call   f0102d95 <cprintf>
f0103010:	83 c4 10             	add    $0x10,%esp
	}
}
f0103013:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103016:	5b                   	pop    %ebx
f0103017:	5e                   	pop    %esi
f0103018:	5d                   	pop    %ebp
f0103019:	c3                   	ret    

f010301a <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010301a:	55                   	push   %ebp
f010301b:	89 e5                	mov    %esp,%ebp
f010301d:	57                   	push   %edi
f010301e:	56                   	push   %esi
f010301f:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103022:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103023:	9c                   	pushf  
f0103024:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103025:	f6 c4 02             	test   $0x2,%ah
f0103028:	74 19                	je     f0103043 <trap+0x29>
f010302a:	68 b1 53 10 f0       	push   $0xf01053b1
f010302f:	68 45 46 10 f0       	push   $0xf0104645
f0103034:	68 a8 00 00 00       	push   $0xa8
f0103039:	68 ca 53 10 f0       	push   $0xf01053ca
f010303e:	e8 5d d0 ff ff       	call   f01000a0 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103043:	83 ec 08             	sub    $0x8,%esp
f0103046:	56                   	push   %esi
f0103047:	68 d6 53 10 f0       	push   $0xf01053d6
f010304c:	e8 44 fd ff ff       	call   f0102d95 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103051:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103055:	83 e0 03             	and    $0x3,%eax
f0103058:	83 c4 10             	add    $0x10,%esp
f010305b:	66 83 f8 03          	cmp    $0x3,%ax
f010305f:	75 31                	jne    f0103092 <trap+0x78>
		// Trapped from user mode.
		assert(curenv);
f0103061:	a1 84 ff 16 f0       	mov    0xf016ff84,%eax
f0103066:	85 c0                	test   %eax,%eax
f0103068:	75 19                	jne    f0103083 <trap+0x69>
f010306a:	68 f1 53 10 f0       	push   $0xf01053f1
f010306f:	68 45 46 10 f0       	push   $0xf0104645
f0103074:	68 ae 00 00 00       	push   $0xae
f0103079:	68 ca 53 10 f0       	push   $0xf01053ca
f010307e:	e8 1d d0 ff ff       	call   f01000a0 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103083:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103088:	89 c7                	mov    %eax,%edi
f010308a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010308c:	8b 35 84 ff 16 f0    	mov    0xf016ff84,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103092:	89 35 a0 07 17 f0    	mov    %esi,0xf01707a0
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103098:	83 ec 0c             	sub    $0xc,%esp
f010309b:	56                   	push   %esi
f010309c:	e8 06 fe ff ff       	call   f0102ea7 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01030a1:	83 c4 10             	add    $0x10,%esp
f01030a4:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01030a9:	75 17                	jne    f01030c2 <trap+0xa8>
		panic("unhandled trap in kernel");
f01030ab:	83 ec 04             	sub    $0x4,%esp
f01030ae:	68 f8 53 10 f0       	push   $0xf01053f8
f01030b3:	68 97 00 00 00       	push   $0x97
f01030b8:	68 ca 53 10 f0       	push   $0xf01053ca
f01030bd:	e8 de cf ff ff       	call   f01000a0 <_panic>
	else {
		env_destroy(curenv);
f01030c2:	83 ec 0c             	sub    $0xc,%esp
f01030c5:	ff 35 84 ff 16 f0    	pushl  0xf016ff84
f01030cb:	e8 f4 fb ff ff       	call   f0102cc4 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01030d0:	a1 84 ff 16 f0       	mov    0xf016ff84,%eax
f01030d5:	83 c4 10             	add    $0x10,%esp
f01030d8:	85 c0                	test   %eax,%eax
f01030da:	74 06                	je     f01030e2 <trap+0xc8>
f01030dc:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01030e0:	74 19                	je     f01030fb <trap+0xe1>
f01030e2:	68 54 55 10 f0       	push   $0xf0105554
f01030e7:	68 45 46 10 f0       	push   $0xf0104645
f01030ec:	68 c0 00 00 00       	push   $0xc0
f01030f1:	68 ca 53 10 f0       	push   $0xf01053ca
f01030f6:	e8 a5 cf ff ff       	call   f01000a0 <_panic>
	env_run(curenv);
f01030fb:	83 ec 0c             	sub    $0xc,%esp
f01030fe:	50                   	push   %eax
f01030ff:	e8 10 fc ff ff       	call   f0102d14 <env_run>

f0103104 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103104:	55                   	push   %ebp
f0103105:	89 e5                	mov    %esp,%ebp
f0103107:	53                   	push   %ebx
f0103108:	83 ec 04             	sub    $0x4,%esp
f010310b:	8b 5d 08             	mov    0x8(%ebp),%ebx

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010310e:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103111:	ff 73 30             	pushl  0x30(%ebx)
f0103114:	50                   	push   %eax
f0103115:	a1 84 ff 16 f0       	mov    0xf016ff84,%eax
f010311a:	ff 70 48             	pushl  0x48(%eax)
f010311d:	68 80 55 10 f0       	push   $0xf0105580
f0103122:	e8 6e fc ff ff       	call   f0102d95 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103127:	89 1c 24             	mov    %ebx,(%esp)
f010312a:	e8 78 fd ff ff       	call   f0102ea7 <print_trapframe>
	env_destroy(curenv);
f010312f:	83 c4 04             	add    $0x4,%esp
f0103132:	ff 35 84 ff 16 f0    	pushl  0xf016ff84
f0103138:	e8 87 fb ff ff       	call   f0102cc4 <env_destroy>
}
f010313d:	83 c4 10             	add    $0x10,%esp
f0103140:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103143:	c9                   	leave  
f0103144:	c3                   	ret    

f0103145 <syscall>:
f0103145:	55                   	push   %ebp
f0103146:	89 e5                	mov    %esp,%ebp
f0103148:	83 ec 0c             	sub    $0xc,%esp
f010314b:	68 10 56 10 f0       	push   $0xf0105610
f0103150:	6a 49                	push   $0x49
f0103152:	68 28 56 10 f0       	push   $0xf0105628
f0103157:	e8 44 cf ff ff       	call   f01000a0 <_panic>

f010315c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010315c:	55                   	push   %ebp
f010315d:	89 e5                	mov    %esp,%ebp
f010315f:	57                   	push   %edi
f0103160:	56                   	push   %esi
f0103161:	53                   	push   %ebx
f0103162:	83 ec 14             	sub    $0x14,%esp
f0103165:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103168:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010316b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010316e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103171:	8b 1a                	mov    (%edx),%ebx
f0103173:	8b 01                	mov    (%ecx),%eax
f0103175:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103178:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010317f:	eb 7f                	jmp    f0103200 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0103181:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103184:	01 d8                	add    %ebx,%eax
f0103186:	89 c6                	mov    %eax,%esi
f0103188:	c1 ee 1f             	shr    $0x1f,%esi
f010318b:	01 c6                	add    %eax,%esi
f010318d:	d1 fe                	sar    %esi
f010318f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103192:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103195:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0103198:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010319a:	eb 03                	jmp    f010319f <stab_binsearch+0x43>
			m--;
f010319c:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010319f:	39 c3                	cmp    %eax,%ebx
f01031a1:	7f 0d                	jg     f01031b0 <stab_binsearch+0x54>
f01031a3:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01031a7:	83 ea 0c             	sub    $0xc,%edx
f01031aa:	39 f9                	cmp    %edi,%ecx
f01031ac:	75 ee                	jne    f010319c <stab_binsearch+0x40>
f01031ae:	eb 05                	jmp    f01031b5 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01031b0:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01031b3:	eb 4b                	jmp    f0103200 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01031b5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01031b8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01031bb:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01031bf:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01031c2:	76 11                	jbe    f01031d5 <stab_binsearch+0x79>
			*region_left = m;
f01031c4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01031c7:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01031c9:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01031cc:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01031d3:	eb 2b                	jmp    f0103200 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01031d5:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01031d8:	73 14                	jae    f01031ee <stab_binsearch+0x92>
			*region_right = m - 1;
f01031da:	83 e8 01             	sub    $0x1,%eax
f01031dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01031e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01031e3:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01031e5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01031ec:	eb 12                	jmp    f0103200 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01031ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01031f1:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01031f3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01031f7:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01031f9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103200:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103203:	0f 8e 78 ff ff ff    	jle    f0103181 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103209:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010320d:	75 0f                	jne    f010321e <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010320f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103212:	8b 00                	mov    (%eax),%eax
f0103214:	83 e8 01             	sub    $0x1,%eax
f0103217:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010321a:	89 06                	mov    %eax,(%esi)
f010321c:	eb 2c                	jmp    f010324a <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010321e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103221:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103223:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103226:	8b 0e                	mov    (%esi),%ecx
f0103228:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010322b:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010322e:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103231:	eb 03                	jmp    f0103236 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103233:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103236:	39 c8                	cmp    %ecx,%eax
f0103238:	7e 0b                	jle    f0103245 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010323a:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010323e:	83 ea 0c             	sub    $0xc,%edx
f0103241:	39 df                	cmp    %ebx,%edi
f0103243:	75 ee                	jne    f0103233 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103245:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103248:	89 06                	mov    %eax,(%esi)
	}
}
f010324a:	83 c4 14             	add    $0x14,%esp
f010324d:	5b                   	pop    %ebx
f010324e:	5e                   	pop    %esi
f010324f:	5f                   	pop    %edi
f0103250:	5d                   	pop    %ebp
f0103251:	c3                   	ret    

f0103252 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103252:	55                   	push   %ebp
f0103253:	89 e5                	mov    %esp,%ebp
f0103255:	57                   	push   %edi
f0103256:	56                   	push   %esi
f0103257:	53                   	push   %ebx
f0103258:	83 ec 3c             	sub    $0x3c,%esp
f010325b:	8b 75 08             	mov    0x8(%ebp),%esi
f010325e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103261:	c7 03 37 56 10 f0    	movl   $0xf0105637,(%ebx)
	info->eip_line = 0;
f0103267:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010326e:	c7 43 08 37 56 10 f0 	movl   $0xf0105637,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103275:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010327c:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010327f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103286:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010328c:	77 21                	ja     f01032af <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010328e:	a1 00 00 20 00       	mov    0x200000,%eax
f0103293:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f0103296:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010329b:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f01032a1:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f01032a4:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f01032aa:	89 7d c0             	mov    %edi,-0x40(%ebp)
f01032ad:	eb 1a                	jmp    f01032c9 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01032af:	c7 45 c0 79 f3 10 f0 	movl   $0xf010f379,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01032b6:	c7 45 b8 b5 c9 10 f0 	movl   $0xf010c9b5,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01032bd:	b8 b4 c9 10 f0       	mov    $0xf010c9b4,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01032c2:	c7 45 bc 50 58 10 f0 	movl   $0xf0105850,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01032c9:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01032cc:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f01032cf:	0f 83 9d 01 00 00    	jae    f0103472 <debuginfo_eip+0x220>
f01032d5:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f01032d9:	0f 85 9a 01 00 00    	jne    f0103479 <debuginfo_eip+0x227>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01032df:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01032e6:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01032e9:	29 f8                	sub    %edi,%eax
f01032eb:	c1 f8 02             	sar    $0x2,%eax
f01032ee:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01032f4:	83 e8 01             	sub    $0x1,%eax
f01032f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01032fa:	56                   	push   %esi
f01032fb:	6a 64                	push   $0x64
f01032fd:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0103300:	89 c1                	mov    %eax,%ecx
f0103302:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103305:	89 f8                	mov    %edi,%eax
f0103307:	e8 50 fe ff ff       	call   f010315c <stab_binsearch>
	if (lfile == 0)
f010330c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010330f:	83 c4 08             	add    $0x8,%esp
f0103312:	85 c0                	test   %eax,%eax
f0103314:	0f 84 66 01 00 00    	je     f0103480 <debuginfo_eip+0x22e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010331a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010331d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103320:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103323:	56                   	push   %esi
f0103324:	6a 24                	push   $0x24
f0103326:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0103329:	89 c1                	mov    %eax,%ecx
f010332b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010332e:	89 f8                	mov    %edi,%eax
f0103330:	e8 27 fe ff ff       	call   f010315c <stab_binsearch>

	if (lfun <= rfun) {
f0103335:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103338:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010333b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010333e:	83 c4 08             	add    $0x8,%esp
f0103341:	39 d0                	cmp    %edx,%eax
f0103343:	7f 2b                	jg     f0103370 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103345:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103348:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f010334b:	8b 11                	mov    (%ecx),%edx
f010334d:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103350:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0103353:	39 fa                	cmp    %edi,%edx
f0103355:	73 06                	jae    f010335d <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103357:	03 55 b8             	add    -0x48(%ebp),%edx
f010335a:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010335d:	8b 51 08             	mov    0x8(%ecx),%edx
f0103360:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103363:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103365:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103368:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010336b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010336e:	eb 0f                	jmp    f010337f <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103370:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103373:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103376:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103379:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010337c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010337f:	83 ec 08             	sub    $0x8,%esp
f0103382:	6a 3a                	push   $0x3a
f0103384:	ff 73 08             	pushl  0x8(%ebx)
f0103387:	e8 82 08 00 00       	call   f0103c0e <strfind>
f010338c:	2b 43 08             	sub    0x8(%ebx),%eax
f010338f:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103392:	83 c4 08             	add    $0x8,%esp
f0103395:	56                   	push   %esi
f0103396:	6a 44                	push   $0x44
f0103398:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010339b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010339e:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01033a1:	89 f0                	mov    %esi,%eax
f01033a3:	e8 b4 fd ff ff       	call   f010315c <stab_binsearch>
	if (lline == 0)
f01033a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01033ab:	83 c4 10             	add    $0x10,%esp
f01033ae:	85 d2                	test   %edx,%edx
f01033b0:	0f 84 d1 00 00 00    	je     f0103487 <debuginfo_eip+0x235>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f01033b6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01033b9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01033bc:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f01033c1:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01033c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01033c7:	89 d0                	mov    %edx,%eax
f01033c9:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01033cc:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01033cf:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01033d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01033d6:	eb 0a                	jmp    f01033e2 <debuginfo_eip+0x190>
f01033d8:	83 e8 01             	sub    $0x1,%eax
f01033db:	83 ea 0c             	sub    $0xc,%edx
f01033de:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01033e2:	39 c7                	cmp    %eax,%edi
f01033e4:	7e 05                	jle    f01033eb <debuginfo_eip+0x199>
f01033e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01033e9:	eb 47                	jmp    f0103432 <debuginfo_eip+0x1e0>
	       && stabs[lline].n_type != N_SOL
f01033eb:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01033ef:	80 f9 84             	cmp    $0x84,%cl
f01033f2:	75 0e                	jne    f0103402 <debuginfo_eip+0x1b0>
f01033f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01033f7:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01033fb:	74 1c                	je     f0103419 <debuginfo_eip+0x1c7>
f01033fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103400:	eb 17                	jmp    f0103419 <debuginfo_eip+0x1c7>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103402:	80 f9 64             	cmp    $0x64,%cl
f0103405:	75 d1                	jne    f01033d8 <debuginfo_eip+0x186>
f0103407:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f010340b:	74 cb                	je     f01033d8 <debuginfo_eip+0x186>
f010340d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103410:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103414:	74 03                	je     f0103419 <debuginfo_eip+0x1c7>
f0103416:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103419:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010341c:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010341f:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103422:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0103425:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0103428:	29 f8                	sub    %edi,%eax
f010342a:	39 c2                	cmp    %eax,%edx
f010342c:	73 04                	jae    f0103432 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010342e:	01 fa                	add    %edi,%edx
f0103430:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103432:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103435:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103438:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010343d:	39 f2                	cmp    %esi,%edx
f010343f:	7d 52                	jge    f0103493 <debuginfo_eip+0x241>
		for (lline = lfun + 1;
f0103441:	83 c2 01             	add    $0x1,%edx
f0103444:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103447:	89 d0                	mov    %edx,%eax
f0103449:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010344c:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010344f:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103452:	eb 04                	jmp    f0103458 <debuginfo_eip+0x206>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103454:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103458:	39 c6                	cmp    %eax,%esi
f010345a:	7e 32                	jle    f010348e <debuginfo_eip+0x23c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010345c:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103460:	83 c0 01             	add    $0x1,%eax
f0103463:	83 c2 0c             	add    $0xc,%edx
f0103466:	80 f9 a0             	cmp    $0xa0,%cl
f0103469:	74 e9                	je     f0103454 <debuginfo_eip+0x202>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010346b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103470:	eb 21                	jmp    f0103493 <debuginfo_eip+0x241>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103472:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103477:	eb 1a                	jmp    f0103493 <debuginfo_eip+0x241>
f0103479:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010347e:	eb 13                	jmp    f0103493 <debuginfo_eip+0x241>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103485:	eb 0c                	jmp    f0103493 <debuginfo_eip+0x241>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0103487:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010348c:	eb 05                	jmp    f0103493 <debuginfo_eip+0x241>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010348e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103493:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103496:	5b                   	pop    %ebx
f0103497:	5e                   	pop    %esi
f0103498:	5f                   	pop    %edi
f0103499:	5d                   	pop    %ebp
f010349a:	c3                   	ret    

f010349b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010349b:	55                   	push   %ebp
f010349c:	89 e5                	mov    %esp,%ebp
f010349e:	57                   	push   %edi
f010349f:	56                   	push   %esi
f01034a0:	53                   	push   %ebx
f01034a1:	83 ec 1c             	sub    $0x1c,%esp
f01034a4:	89 c7                	mov    %eax,%edi
f01034a6:	89 d6                	mov    %edx,%esi
f01034a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01034ab:	8b 55 0c             	mov    0xc(%ebp),%edx
f01034ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01034b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01034b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01034b7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01034bc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01034bf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01034c2:	39 d3                	cmp    %edx,%ebx
f01034c4:	72 05                	jb     f01034cb <printnum+0x30>
f01034c6:	39 45 10             	cmp    %eax,0x10(%ebp)
f01034c9:	77 45                	ja     f0103510 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01034cb:	83 ec 0c             	sub    $0xc,%esp
f01034ce:	ff 75 18             	pushl  0x18(%ebp)
f01034d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01034d4:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01034d7:	53                   	push   %ebx
f01034d8:	ff 75 10             	pushl  0x10(%ebp)
f01034db:	83 ec 08             	sub    $0x8,%esp
f01034de:	ff 75 e4             	pushl  -0x1c(%ebp)
f01034e1:	ff 75 e0             	pushl  -0x20(%ebp)
f01034e4:	ff 75 dc             	pushl  -0x24(%ebp)
f01034e7:	ff 75 d8             	pushl  -0x28(%ebp)
f01034ea:	e8 41 09 00 00       	call   f0103e30 <__udivdi3>
f01034ef:	83 c4 18             	add    $0x18,%esp
f01034f2:	52                   	push   %edx
f01034f3:	50                   	push   %eax
f01034f4:	89 f2                	mov    %esi,%edx
f01034f6:	89 f8                	mov    %edi,%eax
f01034f8:	e8 9e ff ff ff       	call   f010349b <printnum>
f01034fd:	83 c4 20             	add    $0x20,%esp
f0103500:	eb 18                	jmp    f010351a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103502:	83 ec 08             	sub    $0x8,%esp
f0103505:	56                   	push   %esi
f0103506:	ff 75 18             	pushl  0x18(%ebp)
f0103509:	ff d7                	call   *%edi
f010350b:	83 c4 10             	add    $0x10,%esp
f010350e:	eb 03                	jmp    f0103513 <printnum+0x78>
f0103510:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103513:	83 eb 01             	sub    $0x1,%ebx
f0103516:	85 db                	test   %ebx,%ebx
f0103518:	7f e8                	jg     f0103502 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010351a:	83 ec 08             	sub    $0x8,%esp
f010351d:	56                   	push   %esi
f010351e:	83 ec 04             	sub    $0x4,%esp
f0103521:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103524:	ff 75 e0             	pushl  -0x20(%ebp)
f0103527:	ff 75 dc             	pushl  -0x24(%ebp)
f010352a:	ff 75 d8             	pushl  -0x28(%ebp)
f010352d:	e8 2e 0a 00 00       	call   f0103f60 <__umoddi3>
f0103532:	83 c4 14             	add    $0x14,%esp
f0103535:	0f be 80 41 56 10 f0 	movsbl -0xfefa9bf(%eax),%eax
f010353c:	50                   	push   %eax
f010353d:	ff d7                	call   *%edi
}
f010353f:	83 c4 10             	add    $0x10,%esp
f0103542:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103545:	5b                   	pop    %ebx
f0103546:	5e                   	pop    %esi
f0103547:	5f                   	pop    %edi
f0103548:	5d                   	pop    %ebp
f0103549:	c3                   	ret    

f010354a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010354a:	55                   	push   %ebp
f010354b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010354d:	83 fa 01             	cmp    $0x1,%edx
f0103550:	7e 0e                	jle    f0103560 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103552:	8b 10                	mov    (%eax),%edx
f0103554:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103557:	89 08                	mov    %ecx,(%eax)
f0103559:	8b 02                	mov    (%edx),%eax
f010355b:	8b 52 04             	mov    0x4(%edx),%edx
f010355e:	eb 22                	jmp    f0103582 <getuint+0x38>
	else if (lflag)
f0103560:	85 d2                	test   %edx,%edx
f0103562:	74 10                	je     f0103574 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103564:	8b 10                	mov    (%eax),%edx
f0103566:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103569:	89 08                	mov    %ecx,(%eax)
f010356b:	8b 02                	mov    (%edx),%eax
f010356d:	ba 00 00 00 00       	mov    $0x0,%edx
f0103572:	eb 0e                	jmp    f0103582 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103574:	8b 10                	mov    (%eax),%edx
f0103576:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103579:	89 08                	mov    %ecx,(%eax)
f010357b:	8b 02                	mov    (%edx),%eax
f010357d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103582:	5d                   	pop    %ebp
f0103583:	c3                   	ret    

f0103584 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103584:	55                   	push   %ebp
f0103585:	89 e5                	mov    %esp,%ebp
f0103587:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010358a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010358e:	8b 10                	mov    (%eax),%edx
f0103590:	3b 50 04             	cmp    0x4(%eax),%edx
f0103593:	73 0a                	jae    f010359f <sprintputch+0x1b>
		*b->buf++ = ch;
f0103595:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103598:	89 08                	mov    %ecx,(%eax)
f010359a:	8b 45 08             	mov    0x8(%ebp),%eax
f010359d:	88 02                	mov    %al,(%edx)
}
f010359f:	5d                   	pop    %ebp
f01035a0:	c3                   	ret    

f01035a1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01035a1:	55                   	push   %ebp
f01035a2:	89 e5                	mov    %esp,%ebp
f01035a4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01035a7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01035aa:	50                   	push   %eax
f01035ab:	ff 75 10             	pushl  0x10(%ebp)
f01035ae:	ff 75 0c             	pushl  0xc(%ebp)
f01035b1:	ff 75 08             	pushl  0x8(%ebp)
f01035b4:	e8 05 00 00 00       	call   f01035be <vprintfmt>
	va_end(ap);
}
f01035b9:	83 c4 10             	add    $0x10,%esp
f01035bc:	c9                   	leave  
f01035bd:	c3                   	ret    

f01035be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01035be:	55                   	push   %ebp
f01035bf:	89 e5                	mov    %esp,%ebp
f01035c1:	57                   	push   %edi
f01035c2:	56                   	push   %esi
f01035c3:	53                   	push   %ebx
f01035c4:	83 ec 2c             	sub    $0x2c,%esp
f01035c7:	8b 75 08             	mov    0x8(%ebp),%esi
f01035ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01035cd:	8b 7d 10             	mov    0x10(%ebp),%edi
f01035d0:	eb 12                	jmp    f01035e4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01035d2:	85 c0                	test   %eax,%eax
f01035d4:	0f 84 89 03 00 00    	je     f0103963 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f01035da:	83 ec 08             	sub    $0x8,%esp
f01035dd:	53                   	push   %ebx
f01035de:	50                   	push   %eax
f01035df:	ff d6                	call   *%esi
f01035e1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01035e4:	83 c7 01             	add    $0x1,%edi
f01035e7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01035eb:	83 f8 25             	cmp    $0x25,%eax
f01035ee:	75 e2                	jne    f01035d2 <vprintfmt+0x14>
f01035f0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01035f4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01035fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103602:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103609:	ba 00 00 00 00       	mov    $0x0,%edx
f010360e:	eb 07                	jmp    f0103617 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103610:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103613:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103617:	8d 47 01             	lea    0x1(%edi),%eax
f010361a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010361d:	0f b6 07             	movzbl (%edi),%eax
f0103620:	0f b6 c8             	movzbl %al,%ecx
f0103623:	83 e8 23             	sub    $0x23,%eax
f0103626:	3c 55                	cmp    $0x55,%al
f0103628:	0f 87 1a 03 00 00    	ja     f0103948 <vprintfmt+0x38a>
f010362e:	0f b6 c0             	movzbl %al,%eax
f0103631:	ff 24 85 cc 56 10 f0 	jmp    *-0xfefa934(,%eax,4)
f0103638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010363b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010363f:	eb d6                	jmp    f0103617 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103644:	b8 00 00 00 00       	mov    $0x0,%eax
f0103649:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010364c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010364f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0103653:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0103656:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0103659:	83 fa 09             	cmp    $0x9,%edx
f010365c:	77 39                	ja     f0103697 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010365e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103661:	eb e9                	jmp    f010364c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103663:	8b 45 14             	mov    0x14(%ebp),%eax
f0103666:	8d 48 04             	lea    0x4(%eax),%ecx
f0103669:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010366c:	8b 00                	mov    (%eax),%eax
f010366e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103674:	eb 27                	jmp    f010369d <vprintfmt+0xdf>
f0103676:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103679:	85 c0                	test   %eax,%eax
f010367b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103680:	0f 49 c8             	cmovns %eax,%ecx
f0103683:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103689:	eb 8c                	jmp    f0103617 <vprintfmt+0x59>
f010368b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010368e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103695:	eb 80                	jmp    f0103617 <vprintfmt+0x59>
f0103697:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010369a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010369d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01036a1:	0f 89 70 ff ff ff    	jns    f0103617 <vprintfmt+0x59>
				width = precision, precision = -1;
f01036a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01036aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01036ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01036b4:	e9 5e ff ff ff       	jmp    f0103617 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01036b9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01036bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01036bf:	e9 53 ff ff ff       	jmp    f0103617 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01036c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01036c7:	8d 50 04             	lea    0x4(%eax),%edx
f01036ca:	89 55 14             	mov    %edx,0x14(%ebp)
f01036cd:	83 ec 08             	sub    $0x8,%esp
f01036d0:	53                   	push   %ebx
f01036d1:	ff 30                	pushl  (%eax)
f01036d3:	ff d6                	call   *%esi
			break;
f01036d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01036d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01036db:	e9 04 ff ff ff       	jmp    f01035e4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01036e0:	8b 45 14             	mov    0x14(%ebp),%eax
f01036e3:	8d 50 04             	lea    0x4(%eax),%edx
f01036e6:	89 55 14             	mov    %edx,0x14(%ebp)
f01036e9:	8b 00                	mov    (%eax),%eax
f01036eb:	99                   	cltd   
f01036ec:	31 d0                	xor    %edx,%eax
f01036ee:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01036f0:	83 f8 06             	cmp    $0x6,%eax
f01036f3:	7f 0b                	jg     f0103700 <vprintfmt+0x142>
f01036f5:	8b 14 85 24 58 10 f0 	mov    -0xfefa7dc(,%eax,4),%edx
f01036fc:	85 d2                	test   %edx,%edx
f01036fe:	75 18                	jne    f0103718 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0103700:	50                   	push   %eax
f0103701:	68 59 56 10 f0       	push   $0xf0105659
f0103706:	53                   	push   %ebx
f0103707:	56                   	push   %esi
f0103708:	e8 94 fe ff ff       	call   f01035a1 <printfmt>
f010370d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103710:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103713:	e9 cc fe ff ff       	jmp    f01035e4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0103718:	52                   	push   %edx
f0103719:	68 57 46 10 f0       	push   $0xf0104657
f010371e:	53                   	push   %ebx
f010371f:	56                   	push   %esi
f0103720:	e8 7c fe ff ff       	call   f01035a1 <printfmt>
f0103725:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103728:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010372b:	e9 b4 fe ff ff       	jmp    f01035e4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103730:	8b 45 14             	mov    0x14(%ebp),%eax
f0103733:	8d 50 04             	lea    0x4(%eax),%edx
f0103736:	89 55 14             	mov    %edx,0x14(%ebp)
f0103739:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010373b:	85 ff                	test   %edi,%edi
f010373d:	b8 52 56 10 f0       	mov    $0xf0105652,%eax
f0103742:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103745:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103749:	0f 8e 94 00 00 00    	jle    f01037e3 <vprintfmt+0x225>
f010374f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103753:	0f 84 98 00 00 00    	je     f01037f1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103759:	83 ec 08             	sub    $0x8,%esp
f010375c:	ff 75 d0             	pushl  -0x30(%ebp)
f010375f:	57                   	push   %edi
f0103760:	e8 5f 03 00 00       	call   f0103ac4 <strnlen>
f0103765:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103768:	29 c1                	sub    %eax,%ecx
f010376a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010376d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103770:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103774:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103777:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010377a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010377c:	eb 0f                	jmp    f010378d <vprintfmt+0x1cf>
					putch(padc, putdat);
f010377e:	83 ec 08             	sub    $0x8,%esp
f0103781:	53                   	push   %ebx
f0103782:	ff 75 e0             	pushl  -0x20(%ebp)
f0103785:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103787:	83 ef 01             	sub    $0x1,%edi
f010378a:	83 c4 10             	add    $0x10,%esp
f010378d:	85 ff                	test   %edi,%edi
f010378f:	7f ed                	jg     f010377e <vprintfmt+0x1c0>
f0103791:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103794:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103797:	85 c9                	test   %ecx,%ecx
f0103799:	b8 00 00 00 00       	mov    $0x0,%eax
f010379e:	0f 49 c1             	cmovns %ecx,%eax
f01037a1:	29 c1                	sub    %eax,%ecx
f01037a3:	89 75 08             	mov    %esi,0x8(%ebp)
f01037a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01037a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01037ac:	89 cb                	mov    %ecx,%ebx
f01037ae:	eb 4d                	jmp    f01037fd <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01037b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01037b4:	74 1b                	je     f01037d1 <vprintfmt+0x213>
f01037b6:	0f be c0             	movsbl %al,%eax
f01037b9:	83 e8 20             	sub    $0x20,%eax
f01037bc:	83 f8 5e             	cmp    $0x5e,%eax
f01037bf:	76 10                	jbe    f01037d1 <vprintfmt+0x213>
					putch('?', putdat);
f01037c1:	83 ec 08             	sub    $0x8,%esp
f01037c4:	ff 75 0c             	pushl  0xc(%ebp)
f01037c7:	6a 3f                	push   $0x3f
f01037c9:	ff 55 08             	call   *0x8(%ebp)
f01037cc:	83 c4 10             	add    $0x10,%esp
f01037cf:	eb 0d                	jmp    f01037de <vprintfmt+0x220>
				else
					putch(ch, putdat);
f01037d1:	83 ec 08             	sub    $0x8,%esp
f01037d4:	ff 75 0c             	pushl  0xc(%ebp)
f01037d7:	52                   	push   %edx
f01037d8:	ff 55 08             	call   *0x8(%ebp)
f01037db:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01037de:	83 eb 01             	sub    $0x1,%ebx
f01037e1:	eb 1a                	jmp    f01037fd <vprintfmt+0x23f>
f01037e3:	89 75 08             	mov    %esi,0x8(%ebp)
f01037e6:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01037e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01037ec:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01037ef:	eb 0c                	jmp    f01037fd <vprintfmt+0x23f>
f01037f1:	89 75 08             	mov    %esi,0x8(%ebp)
f01037f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01037f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01037fa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01037fd:	83 c7 01             	add    $0x1,%edi
f0103800:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103804:	0f be d0             	movsbl %al,%edx
f0103807:	85 d2                	test   %edx,%edx
f0103809:	74 23                	je     f010382e <vprintfmt+0x270>
f010380b:	85 f6                	test   %esi,%esi
f010380d:	78 a1                	js     f01037b0 <vprintfmt+0x1f2>
f010380f:	83 ee 01             	sub    $0x1,%esi
f0103812:	79 9c                	jns    f01037b0 <vprintfmt+0x1f2>
f0103814:	89 df                	mov    %ebx,%edi
f0103816:	8b 75 08             	mov    0x8(%ebp),%esi
f0103819:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010381c:	eb 18                	jmp    f0103836 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010381e:	83 ec 08             	sub    $0x8,%esp
f0103821:	53                   	push   %ebx
f0103822:	6a 20                	push   $0x20
f0103824:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103826:	83 ef 01             	sub    $0x1,%edi
f0103829:	83 c4 10             	add    $0x10,%esp
f010382c:	eb 08                	jmp    f0103836 <vprintfmt+0x278>
f010382e:	89 df                	mov    %ebx,%edi
f0103830:	8b 75 08             	mov    0x8(%ebp),%esi
f0103833:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103836:	85 ff                	test   %edi,%edi
f0103838:	7f e4                	jg     f010381e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010383a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010383d:	e9 a2 fd ff ff       	jmp    f01035e4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103842:	83 fa 01             	cmp    $0x1,%edx
f0103845:	7e 16                	jle    f010385d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0103847:	8b 45 14             	mov    0x14(%ebp),%eax
f010384a:	8d 50 08             	lea    0x8(%eax),%edx
f010384d:	89 55 14             	mov    %edx,0x14(%ebp)
f0103850:	8b 50 04             	mov    0x4(%eax),%edx
f0103853:	8b 00                	mov    (%eax),%eax
f0103855:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103858:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010385b:	eb 32                	jmp    f010388f <vprintfmt+0x2d1>
	else if (lflag)
f010385d:	85 d2                	test   %edx,%edx
f010385f:	74 18                	je     f0103879 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0103861:	8b 45 14             	mov    0x14(%ebp),%eax
f0103864:	8d 50 04             	lea    0x4(%eax),%edx
f0103867:	89 55 14             	mov    %edx,0x14(%ebp)
f010386a:	8b 00                	mov    (%eax),%eax
f010386c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010386f:	89 c1                	mov    %eax,%ecx
f0103871:	c1 f9 1f             	sar    $0x1f,%ecx
f0103874:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103877:	eb 16                	jmp    f010388f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0103879:	8b 45 14             	mov    0x14(%ebp),%eax
f010387c:	8d 50 04             	lea    0x4(%eax),%edx
f010387f:	89 55 14             	mov    %edx,0x14(%ebp)
f0103882:	8b 00                	mov    (%eax),%eax
f0103884:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103887:	89 c1                	mov    %eax,%ecx
f0103889:	c1 f9 1f             	sar    $0x1f,%ecx
f010388c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010388f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103892:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103895:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010389a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010389e:	79 74                	jns    f0103914 <vprintfmt+0x356>
				putch('-', putdat);
f01038a0:	83 ec 08             	sub    $0x8,%esp
f01038a3:	53                   	push   %ebx
f01038a4:	6a 2d                	push   $0x2d
f01038a6:	ff d6                	call   *%esi
				num = -(long long) num;
f01038a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01038ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01038ae:	f7 d8                	neg    %eax
f01038b0:	83 d2 00             	adc    $0x0,%edx
f01038b3:	f7 da                	neg    %edx
f01038b5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01038b8:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01038bd:	eb 55                	jmp    f0103914 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01038bf:	8d 45 14             	lea    0x14(%ebp),%eax
f01038c2:	e8 83 fc ff ff       	call   f010354a <getuint>
			base = 10;
f01038c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01038cc:	eb 46                	jmp    f0103914 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f01038ce:	8d 45 14             	lea    0x14(%ebp),%eax
f01038d1:	e8 74 fc ff ff       	call   f010354a <getuint>
			base = 8;
f01038d6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01038db:	eb 37                	jmp    f0103914 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f01038dd:	83 ec 08             	sub    $0x8,%esp
f01038e0:	53                   	push   %ebx
f01038e1:	6a 30                	push   $0x30
f01038e3:	ff d6                	call   *%esi
			putch('x', putdat);
f01038e5:	83 c4 08             	add    $0x8,%esp
f01038e8:	53                   	push   %ebx
f01038e9:	6a 78                	push   $0x78
f01038eb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01038ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01038f0:	8d 50 04             	lea    0x4(%eax),%edx
f01038f3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01038f6:	8b 00                	mov    (%eax),%eax
f01038f8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01038fd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103900:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0103905:	eb 0d                	jmp    f0103914 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103907:	8d 45 14             	lea    0x14(%ebp),%eax
f010390a:	e8 3b fc ff ff       	call   f010354a <getuint>
			base = 16;
f010390f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103914:	83 ec 0c             	sub    $0xc,%esp
f0103917:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010391b:	57                   	push   %edi
f010391c:	ff 75 e0             	pushl  -0x20(%ebp)
f010391f:	51                   	push   %ecx
f0103920:	52                   	push   %edx
f0103921:	50                   	push   %eax
f0103922:	89 da                	mov    %ebx,%edx
f0103924:	89 f0                	mov    %esi,%eax
f0103926:	e8 70 fb ff ff       	call   f010349b <printnum>
			break;
f010392b:	83 c4 20             	add    $0x20,%esp
f010392e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103931:	e9 ae fc ff ff       	jmp    f01035e4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103936:	83 ec 08             	sub    $0x8,%esp
f0103939:	53                   	push   %ebx
f010393a:	51                   	push   %ecx
f010393b:	ff d6                	call   *%esi
			break;
f010393d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103940:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103943:	e9 9c fc ff ff       	jmp    f01035e4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103948:	83 ec 08             	sub    $0x8,%esp
f010394b:	53                   	push   %ebx
f010394c:	6a 25                	push   $0x25
f010394e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103950:	83 c4 10             	add    $0x10,%esp
f0103953:	eb 03                	jmp    f0103958 <vprintfmt+0x39a>
f0103955:	83 ef 01             	sub    $0x1,%edi
f0103958:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010395c:	75 f7                	jne    f0103955 <vprintfmt+0x397>
f010395e:	e9 81 fc ff ff       	jmp    f01035e4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0103963:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103966:	5b                   	pop    %ebx
f0103967:	5e                   	pop    %esi
f0103968:	5f                   	pop    %edi
f0103969:	5d                   	pop    %ebp
f010396a:	c3                   	ret    

f010396b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010396b:	55                   	push   %ebp
f010396c:	89 e5                	mov    %esp,%ebp
f010396e:	83 ec 18             	sub    $0x18,%esp
f0103971:	8b 45 08             	mov    0x8(%ebp),%eax
f0103974:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103977:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010397a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010397e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103981:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103988:	85 c0                	test   %eax,%eax
f010398a:	74 26                	je     f01039b2 <vsnprintf+0x47>
f010398c:	85 d2                	test   %edx,%edx
f010398e:	7e 22                	jle    f01039b2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103990:	ff 75 14             	pushl  0x14(%ebp)
f0103993:	ff 75 10             	pushl  0x10(%ebp)
f0103996:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103999:	50                   	push   %eax
f010399a:	68 84 35 10 f0       	push   $0xf0103584
f010399f:	e8 1a fc ff ff       	call   f01035be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01039a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01039a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01039aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01039ad:	83 c4 10             	add    $0x10,%esp
f01039b0:	eb 05                	jmp    f01039b7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01039b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01039b7:	c9                   	leave  
f01039b8:	c3                   	ret    

f01039b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01039b9:	55                   	push   %ebp
f01039ba:	89 e5                	mov    %esp,%ebp
f01039bc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01039bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01039c2:	50                   	push   %eax
f01039c3:	ff 75 10             	pushl  0x10(%ebp)
f01039c6:	ff 75 0c             	pushl  0xc(%ebp)
f01039c9:	ff 75 08             	pushl  0x8(%ebp)
f01039cc:	e8 9a ff ff ff       	call   f010396b <vsnprintf>
	va_end(ap);

	return rc;
}
f01039d1:	c9                   	leave  
f01039d2:	c3                   	ret    

f01039d3 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01039d3:	55                   	push   %ebp
f01039d4:	89 e5                	mov    %esp,%ebp
f01039d6:	57                   	push   %edi
f01039d7:	56                   	push   %esi
f01039d8:	53                   	push   %ebx
f01039d9:	83 ec 0c             	sub    $0xc,%esp
f01039dc:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01039df:	85 c0                	test   %eax,%eax
f01039e1:	74 11                	je     f01039f4 <readline+0x21>
		cprintf("%s", prompt);
f01039e3:	83 ec 08             	sub    $0x8,%esp
f01039e6:	50                   	push   %eax
f01039e7:	68 57 46 10 f0       	push   $0xf0104657
f01039ec:	e8 a4 f3 ff ff       	call   f0102d95 <cprintf>
f01039f1:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01039f4:	83 ec 0c             	sub    $0xc,%esp
f01039f7:	6a 00                	push   $0x0
f01039f9:	e8 38 cc ff ff       	call   f0100636 <iscons>
f01039fe:	89 c7                	mov    %eax,%edi
f0103a00:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103a03:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103a08:	e8 18 cc ff ff       	call   f0100625 <getchar>
f0103a0d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103a0f:	85 c0                	test   %eax,%eax
f0103a11:	79 18                	jns    f0103a2b <readline+0x58>
			cprintf("read error: %e\n", c);
f0103a13:	83 ec 08             	sub    $0x8,%esp
f0103a16:	50                   	push   %eax
f0103a17:	68 40 58 10 f0       	push   $0xf0105840
f0103a1c:	e8 74 f3 ff ff       	call   f0102d95 <cprintf>
			return NULL;
f0103a21:	83 c4 10             	add    $0x10,%esp
f0103a24:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a29:	eb 79                	jmp    f0103aa4 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103a2b:	83 f8 08             	cmp    $0x8,%eax
f0103a2e:	0f 94 c2             	sete   %dl
f0103a31:	83 f8 7f             	cmp    $0x7f,%eax
f0103a34:	0f 94 c0             	sete   %al
f0103a37:	08 c2                	or     %al,%dl
f0103a39:	74 1a                	je     f0103a55 <readline+0x82>
f0103a3b:	85 f6                	test   %esi,%esi
f0103a3d:	7e 16                	jle    f0103a55 <readline+0x82>
			if (echoing)
f0103a3f:	85 ff                	test   %edi,%edi
f0103a41:	74 0d                	je     f0103a50 <readline+0x7d>
				cputchar('\b');
f0103a43:	83 ec 0c             	sub    $0xc,%esp
f0103a46:	6a 08                	push   $0x8
f0103a48:	e8 c8 cb ff ff       	call   f0100615 <cputchar>
f0103a4d:	83 c4 10             	add    $0x10,%esp
			i--;
f0103a50:	83 ee 01             	sub    $0x1,%esi
f0103a53:	eb b3                	jmp    f0103a08 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103a55:	83 fb 1f             	cmp    $0x1f,%ebx
f0103a58:	7e 23                	jle    f0103a7d <readline+0xaa>
f0103a5a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103a60:	7f 1b                	jg     f0103a7d <readline+0xaa>
			if (echoing)
f0103a62:	85 ff                	test   %edi,%edi
f0103a64:	74 0c                	je     f0103a72 <readline+0x9f>
				cputchar(c);
f0103a66:	83 ec 0c             	sub    $0xc,%esp
f0103a69:	53                   	push   %ebx
f0103a6a:	e8 a6 cb ff ff       	call   f0100615 <cputchar>
f0103a6f:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103a72:	88 9e 40 08 17 f0    	mov    %bl,-0xfe8f7c0(%esi)
f0103a78:	8d 76 01             	lea    0x1(%esi),%esi
f0103a7b:	eb 8b                	jmp    f0103a08 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103a7d:	83 fb 0a             	cmp    $0xa,%ebx
f0103a80:	74 05                	je     f0103a87 <readline+0xb4>
f0103a82:	83 fb 0d             	cmp    $0xd,%ebx
f0103a85:	75 81                	jne    f0103a08 <readline+0x35>
			if (echoing)
f0103a87:	85 ff                	test   %edi,%edi
f0103a89:	74 0d                	je     f0103a98 <readline+0xc5>
				cputchar('\n');
f0103a8b:	83 ec 0c             	sub    $0xc,%esp
f0103a8e:	6a 0a                	push   $0xa
f0103a90:	e8 80 cb ff ff       	call   f0100615 <cputchar>
f0103a95:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103a98:	c6 86 40 08 17 f0 00 	movb   $0x0,-0xfe8f7c0(%esi)
			return buf;
f0103a9f:	b8 40 08 17 f0       	mov    $0xf0170840,%eax
		}
	}
}
f0103aa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103aa7:	5b                   	pop    %ebx
f0103aa8:	5e                   	pop    %esi
f0103aa9:	5f                   	pop    %edi
f0103aaa:	5d                   	pop    %ebp
f0103aab:	c3                   	ret    

f0103aac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103aac:	55                   	push   %ebp
f0103aad:	89 e5                	mov    %esp,%ebp
f0103aaf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103ab2:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ab7:	eb 03                	jmp    f0103abc <strlen+0x10>
		n++;
f0103ab9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103abc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103ac0:	75 f7                	jne    f0103ab9 <strlen+0xd>
		n++;
	return n;
}
f0103ac2:	5d                   	pop    %ebp
f0103ac3:	c3                   	ret    

f0103ac4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103ac4:	55                   	push   %ebp
f0103ac5:	89 e5                	mov    %esp,%ebp
f0103ac7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103aca:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103acd:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ad2:	eb 03                	jmp    f0103ad7 <strnlen+0x13>
		n++;
f0103ad4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103ad7:	39 c2                	cmp    %eax,%edx
f0103ad9:	74 08                	je     f0103ae3 <strnlen+0x1f>
f0103adb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0103adf:	75 f3                	jne    f0103ad4 <strnlen+0x10>
f0103ae1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0103ae3:	5d                   	pop    %ebp
f0103ae4:	c3                   	ret    

f0103ae5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103ae5:	55                   	push   %ebp
f0103ae6:	89 e5                	mov    %esp,%ebp
f0103ae8:	53                   	push   %ebx
f0103ae9:	8b 45 08             	mov    0x8(%ebp),%eax
f0103aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103aef:	89 c2                	mov    %eax,%edx
f0103af1:	83 c2 01             	add    $0x1,%edx
f0103af4:	83 c1 01             	add    $0x1,%ecx
f0103af7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103afb:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103afe:	84 db                	test   %bl,%bl
f0103b00:	75 ef                	jne    f0103af1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103b02:	5b                   	pop    %ebx
f0103b03:	5d                   	pop    %ebp
f0103b04:	c3                   	ret    

f0103b05 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103b05:	55                   	push   %ebp
f0103b06:	89 e5                	mov    %esp,%ebp
f0103b08:	53                   	push   %ebx
f0103b09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103b0c:	53                   	push   %ebx
f0103b0d:	e8 9a ff ff ff       	call   f0103aac <strlen>
f0103b12:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103b15:	ff 75 0c             	pushl  0xc(%ebp)
f0103b18:	01 d8                	add    %ebx,%eax
f0103b1a:	50                   	push   %eax
f0103b1b:	e8 c5 ff ff ff       	call   f0103ae5 <strcpy>
	return dst;
}
f0103b20:	89 d8                	mov    %ebx,%eax
f0103b22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b25:	c9                   	leave  
f0103b26:	c3                   	ret    

f0103b27 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103b27:	55                   	push   %ebp
f0103b28:	89 e5                	mov    %esp,%ebp
f0103b2a:	56                   	push   %esi
f0103b2b:	53                   	push   %ebx
f0103b2c:	8b 75 08             	mov    0x8(%ebp),%esi
f0103b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103b32:	89 f3                	mov    %esi,%ebx
f0103b34:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103b37:	89 f2                	mov    %esi,%edx
f0103b39:	eb 0f                	jmp    f0103b4a <strncpy+0x23>
		*dst++ = *src;
f0103b3b:	83 c2 01             	add    $0x1,%edx
f0103b3e:	0f b6 01             	movzbl (%ecx),%eax
f0103b41:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103b44:	80 39 01             	cmpb   $0x1,(%ecx)
f0103b47:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103b4a:	39 da                	cmp    %ebx,%edx
f0103b4c:	75 ed                	jne    f0103b3b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103b4e:	89 f0                	mov    %esi,%eax
f0103b50:	5b                   	pop    %ebx
f0103b51:	5e                   	pop    %esi
f0103b52:	5d                   	pop    %ebp
f0103b53:	c3                   	ret    

f0103b54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103b54:	55                   	push   %ebp
f0103b55:	89 e5                	mov    %esp,%ebp
f0103b57:	56                   	push   %esi
f0103b58:	53                   	push   %ebx
f0103b59:	8b 75 08             	mov    0x8(%ebp),%esi
f0103b5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103b5f:	8b 55 10             	mov    0x10(%ebp),%edx
f0103b62:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103b64:	85 d2                	test   %edx,%edx
f0103b66:	74 21                	je     f0103b89 <strlcpy+0x35>
f0103b68:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103b6c:	89 f2                	mov    %esi,%edx
f0103b6e:	eb 09                	jmp    f0103b79 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103b70:	83 c2 01             	add    $0x1,%edx
f0103b73:	83 c1 01             	add    $0x1,%ecx
f0103b76:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103b79:	39 c2                	cmp    %eax,%edx
f0103b7b:	74 09                	je     f0103b86 <strlcpy+0x32>
f0103b7d:	0f b6 19             	movzbl (%ecx),%ebx
f0103b80:	84 db                	test   %bl,%bl
f0103b82:	75 ec                	jne    f0103b70 <strlcpy+0x1c>
f0103b84:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103b86:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103b89:	29 f0                	sub    %esi,%eax
}
f0103b8b:	5b                   	pop    %ebx
f0103b8c:	5e                   	pop    %esi
f0103b8d:	5d                   	pop    %ebp
f0103b8e:	c3                   	ret    

f0103b8f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103b8f:	55                   	push   %ebp
f0103b90:	89 e5                	mov    %esp,%ebp
f0103b92:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103b95:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103b98:	eb 06                	jmp    f0103ba0 <strcmp+0x11>
		p++, q++;
f0103b9a:	83 c1 01             	add    $0x1,%ecx
f0103b9d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103ba0:	0f b6 01             	movzbl (%ecx),%eax
f0103ba3:	84 c0                	test   %al,%al
f0103ba5:	74 04                	je     f0103bab <strcmp+0x1c>
f0103ba7:	3a 02                	cmp    (%edx),%al
f0103ba9:	74 ef                	je     f0103b9a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103bab:	0f b6 c0             	movzbl %al,%eax
f0103bae:	0f b6 12             	movzbl (%edx),%edx
f0103bb1:	29 d0                	sub    %edx,%eax
}
f0103bb3:	5d                   	pop    %ebp
f0103bb4:	c3                   	ret    

f0103bb5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103bb5:	55                   	push   %ebp
f0103bb6:	89 e5                	mov    %esp,%ebp
f0103bb8:	53                   	push   %ebx
f0103bb9:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103bbf:	89 c3                	mov    %eax,%ebx
f0103bc1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103bc4:	eb 06                	jmp    f0103bcc <strncmp+0x17>
		n--, p++, q++;
f0103bc6:	83 c0 01             	add    $0x1,%eax
f0103bc9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103bcc:	39 d8                	cmp    %ebx,%eax
f0103bce:	74 15                	je     f0103be5 <strncmp+0x30>
f0103bd0:	0f b6 08             	movzbl (%eax),%ecx
f0103bd3:	84 c9                	test   %cl,%cl
f0103bd5:	74 04                	je     f0103bdb <strncmp+0x26>
f0103bd7:	3a 0a                	cmp    (%edx),%cl
f0103bd9:	74 eb                	je     f0103bc6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103bdb:	0f b6 00             	movzbl (%eax),%eax
f0103bde:	0f b6 12             	movzbl (%edx),%edx
f0103be1:	29 d0                	sub    %edx,%eax
f0103be3:	eb 05                	jmp    f0103bea <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103be5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103bea:	5b                   	pop    %ebx
f0103beb:	5d                   	pop    %ebp
f0103bec:	c3                   	ret    

f0103bed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103bed:	55                   	push   %ebp
f0103bee:	89 e5                	mov    %esp,%ebp
f0103bf0:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bf3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103bf7:	eb 07                	jmp    f0103c00 <strchr+0x13>
		if (*s == c)
f0103bf9:	38 ca                	cmp    %cl,%dl
f0103bfb:	74 0f                	je     f0103c0c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103bfd:	83 c0 01             	add    $0x1,%eax
f0103c00:	0f b6 10             	movzbl (%eax),%edx
f0103c03:	84 d2                	test   %dl,%dl
f0103c05:	75 f2                	jne    f0103bf9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103c07:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c0c:	5d                   	pop    %ebp
f0103c0d:	c3                   	ret    

f0103c0e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103c0e:	55                   	push   %ebp
f0103c0f:	89 e5                	mov    %esp,%ebp
f0103c11:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103c18:	eb 03                	jmp    f0103c1d <strfind+0xf>
f0103c1a:	83 c0 01             	add    $0x1,%eax
f0103c1d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103c20:	38 ca                	cmp    %cl,%dl
f0103c22:	74 04                	je     f0103c28 <strfind+0x1a>
f0103c24:	84 d2                	test   %dl,%dl
f0103c26:	75 f2                	jne    f0103c1a <strfind+0xc>
			break;
	return (char *) s;
}
f0103c28:	5d                   	pop    %ebp
f0103c29:	c3                   	ret    

f0103c2a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103c2a:	55                   	push   %ebp
f0103c2b:	89 e5                	mov    %esp,%ebp
f0103c2d:	57                   	push   %edi
f0103c2e:	56                   	push   %esi
f0103c2f:	53                   	push   %ebx
f0103c30:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103c33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103c36:	85 c9                	test   %ecx,%ecx
f0103c38:	74 36                	je     f0103c70 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103c3a:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103c40:	75 28                	jne    f0103c6a <memset+0x40>
f0103c42:	f6 c1 03             	test   $0x3,%cl
f0103c45:	75 23                	jne    f0103c6a <memset+0x40>
		c &= 0xFF;
f0103c47:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103c4b:	89 d3                	mov    %edx,%ebx
f0103c4d:	c1 e3 08             	shl    $0x8,%ebx
f0103c50:	89 d6                	mov    %edx,%esi
f0103c52:	c1 e6 18             	shl    $0x18,%esi
f0103c55:	89 d0                	mov    %edx,%eax
f0103c57:	c1 e0 10             	shl    $0x10,%eax
f0103c5a:	09 f0                	or     %esi,%eax
f0103c5c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0103c5e:	89 d8                	mov    %ebx,%eax
f0103c60:	09 d0                	or     %edx,%eax
f0103c62:	c1 e9 02             	shr    $0x2,%ecx
f0103c65:	fc                   	cld    
f0103c66:	f3 ab                	rep stos %eax,%es:(%edi)
f0103c68:	eb 06                	jmp    f0103c70 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c6d:	fc                   	cld    
f0103c6e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103c70:	89 f8                	mov    %edi,%eax
f0103c72:	5b                   	pop    %ebx
f0103c73:	5e                   	pop    %esi
f0103c74:	5f                   	pop    %edi
f0103c75:	5d                   	pop    %ebp
f0103c76:	c3                   	ret    

f0103c77 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103c77:	55                   	push   %ebp
f0103c78:	89 e5                	mov    %esp,%ebp
f0103c7a:	57                   	push   %edi
f0103c7b:	56                   	push   %esi
f0103c7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c7f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103c82:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103c85:	39 c6                	cmp    %eax,%esi
f0103c87:	73 35                	jae    f0103cbe <memmove+0x47>
f0103c89:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103c8c:	39 d0                	cmp    %edx,%eax
f0103c8e:	73 2e                	jae    f0103cbe <memmove+0x47>
		s += n;
		d += n;
f0103c90:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103c93:	89 d6                	mov    %edx,%esi
f0103c95:	09 fe                	or     %edi,%esi
f0103c97:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103c9d:	75 13                	jne    f0103cb2 <memmove+0x3b>
f0103c9f:	f6 c1 03             	test   $0x3,%cl
f0103ca2:	75 0e                	jne    f0103cb2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0103ca4:	83 ef 04             	sub    $0x4,%edi
f0103ca7:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103caa:	c1 e9 02             	shr    $0x2,%ecx
f0103cad:	fd                   	std    
f0103cae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103cb0:	eb 09                	jmp    f0103cbb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103cb2:	83 ef 01             	sub    $0x1,%edi
f0103cb5:	8d 72 ff             	lea    -0x1(%edx),%esi
f0103cb8:	fd                   	std    
f0103cb9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103cbb:	fc                   	cld    
f0103cbc:	eb 1d                	jmp    f0103cdb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103cbe:	89 f2                	mov    %esi,%edx
f0103cc0:	09 c2                	or     %eax,%edx
f0103cc2:	f6 c2 03             	test   $0x3,%dl
f0103cc5:	75 0f                	jne    f0103cd6 <memmove+0x5f>
f0103cc7:	f6 c1 03             	test   $0x3,%cl
f0103cca:	75 0a                	jne    f0103cd6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0103ccc:	c1 e9 02             	shr    $0x2,%ecx
f0103ccf:	89 c7                	mov    %eax,%edi
f0103cd1:	fc                   	cld    
f0103cd2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103cd4:	eb 05                	jmp    f0103cdb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103cd6:	89 c7                	mov    %eax,%edi
f0103cd8:	fc                   	cld    
f0103cd9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103cdb:	5e                   	pop    %esi
f0103cdc:	5f                   	pop    %edi
f0103cdd:	5d                   	pop    %ebp
f0103cde:	c3                   	ret    

f0103cdf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103cdf:	55                   	push   %ebp
f0103ce0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103ce2:	ff 75 10             	pushl  0x10(%ebp)
f0103ce5:	ff 75 0c             	pushl  0xc(%ebp)
f0103ce8:	ff 75 08             	pushl  0x8(%ebp)
f0103ceb:	e8 87 ff ff ff       	call   f0103c77 <memmove>
}
f0103cf0:	c9                   	leave  
f0103cf1:	c3                   	ret    

f0103cf2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103cf2:	55                   	push   %ebp
f0103cf3:	89 e5                	mov    %esp,%ebp
f0103cf5:	56                   	push   %esi
f0103cf6:	53                   	push   %ebx
f0103cf7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cfa:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103cfd:	89 c6                	mov    %eax,%esi
f0103cff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103d02:	eb 1a                	jmp    f0103d1e <memcmp+0x2c>
		if (*s1 != *s2)
f0103d04:	0f b6 08             	movzbl (%eax),%ecx
f0103d07:	0f b6 1a             	movzbl (%edx),%ebx
f0103d0a:	38 d9                	cmp    %bl,%cl
f0103d0c:	74 0a                	je     f0103d18 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0103d0e:	0f b6 c1             	movzbl %cl,%eax
f0103d11:	0f b6 db             	movzbl %bl,%ebx
f0103d14:	29 d8                	sub    %ebx,%eax
f0103d16:	eb 0f                	jmp    f0103d27 <memcmp+0x35>
		s1++, s2++;
f0103d18:	83 c0 01             	add    $0x1,%eax
f0103d1b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103d1e:	39 f0                	cmp    %esi,%eax
f0103d20:	75 e2                	jne    f0103d04 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103d22:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d27:	5b                   	pop    %ebx
f0103d28:	5e                   	pop    %esi
f0103d29:	5d                   	pop    %ebp
f0103d2a:	c3                   	ret    

f0103d2b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103d2b:	55                   	push   %ebp
f0103d2c:	89 e5                	mov    %esp,%ebp
f0103d2e:	53                   	push   %ebx
f0103d2f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103d32:	89 c1                	mov    %eax,%ecx
f0103d34:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0103d37:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103d3b:	eb 0a                	jmp    f0103d47 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103d3d:	0f b6 10             	movzbl (%eax),%edx
f0103d40:	39 da                	cmp    %ebx,%edx
f0103d42:	74 07                	je     f0103d4b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103d44:	83 c0 01             	add    $0x1,%eax
f0103d47:	39 c8                	cmp    %ecx,%eax
f0103d49:	72 f2                	jb     f0103d3d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103d4b:	5b                   	pop    %ebx
f0103d4c:	5d                   	pop    %ebp
f0103d4d:	c3                   	ret    

f0103d4e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103d4e:	55                   	push   %ebp
f0103d4f:	89 e5                	mov    %esp,%ebp
f0103d51:	57                   	push   %edi
f0103d52:	56                   	push   %esi
f0103d53:	53                   	push   %ebx
f0103d54:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103d57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103d5a:	eb 03                	jmp    f0103d5f <strtol+0x11>
		s++;
f0103d5c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103d5f:	0f b6 01             	movzbl (%ecx),%eax
f0103d62:	3c 20                	cmp    $0x20,%al
f0103d64:	74 f6                	je     f0103d5c <strtol+0xe>
f0103d66:	3c 09                	cmp    $0x9,%al
f0103d68:	74 f2                	je     f0103d5c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103d6a:	3c 2b                	cmp    $0x2b,%al
f0103d6c:	75 0a                	jne    f0103d78 <strtol+0x2a>
		s++;
f0103d6e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103d71:	bf 00 00 00 00       	mov    $0x0,%edi
f0103d76:	eb 11                	jmp    f0103d89 <strtol+0x3b>
f0103d78:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103d7d:	3c 2d                	cmp    $0x2d,%al
f0103d7f:	75 08                	jne    f0103d89 <strtol+0x3b>
		s++, neg = 1;
f0103d81:	83 c1 01             	add    $0x1,%ecx
f0103d84:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103d89:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103d8f:	75 15                	jne    f0103da6 <strtol+0x58>
f0103d91:	80 39 30             	cmpb   $0x30,(%ecx)
f0103d94:	75 10                	jne    f0103da6 <strtol+0x58>
f0103d96:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103d9a:	75 7c                	jne    f0103e18 <strtol+0xca>
		s += 2, base = 16;
f0103d9c:	83 c1 02             	add    $0x2,%ecx
f0103d9f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103da4:	eb 16                	jmp    f0103dbc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0103da6:	85 db                	test   %ebx,%ebx
f0103da8:	75 12                	jne    f0103dbc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103daa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103daf:	80 39 30             	cmpb   $0x30,(%ecx)
f0103db2:	75 08                	jne    f0103dbc <strtol+0x6e>
		s++, base = 8;
f0103db4:	83 c1 01             	add    $0x1,%ecx
f0103db7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0103dbc:	b8 00 00 00 00       	mov    $0x0,%eax
f0103dc1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103dc4:	0f b6 11             	movzbl (%ecx),%edx
f0103dc7:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103dca:	89 f3                	mov    %esi,%ebx
f0103dcc:	80 fb 09             	cmp    $0x9,%bl
f0103dcf:	77 08                	ja     f0103dd9 <strtol+0x8b>
			dig = *s - '0';
f0103dd1:	0f be d2             	movsbl %dl,%edx
f0103dd4:	83 ea 30             	sub    $0x30,%edx
f0103dd7:	eb 22                	jmp    f0103dfb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0103dd9:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103ddc:	89 f3                	mov    %esi,%ebx
f0103dde:	80 fb 19             	cmp    $0x19,%bl
f0103de1:	77 08                	ja     f0103deb <strtol+0x9d>
			dig = *s - 'a' + 10;
f0103de3:	0f be d2             	movsbl %dl,%edx
f0103de6:	83 ea 57             	sub    $0x57,%edx
f0103de9:	eb 10                	jmp    f0103dfb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0103deb:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103dee:	89 f3                	mov    %esi,%ebx
f0103df0:	80 fb 19             	cmp    $0x19,%bl
f0103df3:	77 16                	ja     f0103e0b <strtol+0xbd>
			dig = *s - 'A' + 10;
f0103df5:	0f be d2             	movsbl %dl,%edx
f0103df8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0103dfb:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103dfe:	7d 0b                	jge    f0103e0b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0103e00:	83 c1 01             	add    $0x1,%ecx
f0103e03:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103e07:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0103e09:	eb b9                	jmp    f0103dc4 <strtol+0x76>

	if (endptr)
f0103e0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103e0f:	74 0d                	je     f0103e1e <strtol+0xd0>
		*endptr = (char *) s;
f0103e11:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103e14:	89 0e                	mov    %ecx,(%esi)
f0103e16:	eb 06                	jmp    f0103e1e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103e18:	85 db                	test   %ebx,%ebx
f0103e1a:	74 98                	je     f0103db4 <strtol+0x66>
f0103e1c:	eb 9e                	jmp    f0103dbc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0103e1e:	89 c2                	mov    %eax,%edx
f0103e20:	f7 da                	neg    %edx
f0103e22:	85 ff                	test   %edi,%edi
f0103e24:	0f 45 c2             	cmovne %edx,%eax
}
f0103e27:	5b                   	pop    %ebx
f0103e28:	5e                   	pop    %esi
f0103e29:	5f                   	pop    %edi
f0103e2a:	5d                   	pop    %ebp
f0103e2b:	c3                   	ret    
f0103e2c:	66 90                	xchg   %ax,%ax
f0103e2e:	66 90                	xchg   %ax,%ax

f0103e30 <__udivdi3>:
f0103e30:	55                   	push   %ebp
f0103e31:	57                   	push   %edi
f0103e32:	56                   	push   %esi
f0103e33:	53                   	push   %ebx
f0103e34:	83 ec 1c             	sub    $0x1c,%esp
f0103e37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0103e3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0103e3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0103e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103e47:	85 f6                	test   %esi,%esi
f0103e49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103e4d:	89 ca                	mov    %ecx,%edx
f0103e4f:	89 f8                	mov    %edi,%eax
f0103e51:	75 3d                	jne    f0103e90 <__udivdi3+0x60>
f0103e53:	39 cf                	cmp    %ecx,%edi
f0103e55:	0f 87 c5 00 00 00    	ja     f0103f20 <__udivdi3+0xf0>
f0103e5b:	85 ff                	test   %edi,%edi
f0103e5d:	89 fd                	mov    %edi,%ebp
f0103e5f:	75 0b                	jne    f0103e6c <__udivdi3+0x3c>
f0103e61:	b8 01 00 00 00       	mov    $0x1,%eax
f0103e66:	31 d2                	xor    %edx,%edx
f0103e68:	f7 f7                	div    %edi
f0103e6a:	89 c5                	mov    %eax,%ebp
f0103e6c:	89 c8                	mov    %ecx,%eax
f0103e6e:	31 d2                	xor    %edx,%edx
f0103e70:	f7 f5                	div    %ebp
f0103e72:	89 c1                	mov    %eax,%ecx
f0103e74:	89 d8                	mov    %ebx,%eax
f0103e76:	89 cf                	mov    %ecx,%edi
f0103e78:	f7 f5                	div    %ebp
f0103e7a:	89 c3                	mov    %eax,%ebx
f0103e7c:	89 d8                	mov    %ebx,%eax
f0103e7e:	89 fa                	mov    %edi,%edx
f0103e80:	83 c4 1c             	add    $0x1c,%esp
f0103e83:	5b                   	pop    %ebx
f0103e84:	5e                   	pop    %esi
f0103e85:	5f                   	pop    %edi
f0103e86:	5d                   	pop    %ebp
f0103e87:	c3                   	ret    
f0103e88:	90                   	nop
f0103e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103e90:	39 ce                	cmp    %ecx,%esi
f0103e92:	77 74                	ja     f0103f08 <__udivdi3+0xd8>
f0103e94:	0f bd fe             	bsr    %esi,%edi
f0103e97:	83 f7 1f             	xor    $0x1f,%edi
f0103e9a:	0f 84 98 00 00 00    	je     f0103f38 <__udivdi3+0x108>
f0103ea0:	bb 20 00 00 00       	mov    $0x20,%ebx
f0103ea5:	89 f9                	mov    %edi,%ecx
f0103ea7:	89 c5                	mov    %eax,%ebp
f0103ea9:	29 fb                	sub    %edi,%ebx
f0103eab:	d3 e6                	shl    %cl,%esi
f0103ead:	89 d9                	mov    %ebx,%ecx
f0103eaf:	d3 ed                	shr    %cl,%ebp
f0103eb1:	89 f9                	mov    %edi,%ecx
f0103eb3:	d3 e0                	shl    %cl,%eax
f0103eb5:	09 ee                	or     %ebp,%esi
f0103eb7:	89 d9                	mov    %ebx,%ecx
f0103eb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ebd:	89 d5                	mov    %edx,%ebp
f0103ebf:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103ec3:	d3 ed                	shr    %cl,%ebp
f0103ec5:	89 f9                	mov    %edi,%ecx
f0103ec7:	d3 e2                	shl    %cl,%edx
f0103ec9:	89 d9                	mov    %ebx,%ecx
f0103ecb:	d3 e8                	shr    %cl,%eax
f0103ecd:	09 c2                	or     %eax,%edx
f0103ecf:	89 d0                	mov    %edx,%eax
f0103ed1:	89 ea                	mov    %ebp,%edx
f0103ed3:	f7 f6                	div    %esi
f0103ed5:	89 d5                	mov    %edx,%ebp
f0103ed7:	89 c3                	mov    %eax,%ebx
f0103ed9:	f7 64 24 0c          	mull   0xc(%esp)
f0103edd:	39 d5                	cmp    %edx,%ebp
f0103edf:	72 10                	jb     f0103ef1 <__udivdi3+0xc1>
f0103ee1:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103ee5:	89 f9                	mov    %edi,%ecx
f0103ee7:	d3 e6                	shl    %cl,%esi
f0103ee9:	39 c6                	cmp    %eax,%esi
f0103eeb:	73 07                	jae    f0103ef4 <__udivdi3+0xc4>
f0103eed:	39 d5                	cmp    %edx,%ebp
f0103eef:	75 03                	jne    f0103ef4 <__udivdi3+0xc4>
f0103ef1:	83 eb 01             	sub    $0x1,%ebx
f0103ef4:	31 ff                	xor    %edi,%edi
f0103ef6:	89 d8                	mov    %ebx,%eax
f0103ef8:	89 fa                	mov    %edi,%edx
f0103efa:	83 c4 1c             	add    $0x1c,%esp
f0103efd:	5b                   	pop    %ebx
f0103efe:	5e                   	pop    %esi
f0103eff:	5f                   	pop    %edi
f0103f00:	5d                   	pop    %ebp
f0103f01:	c3                   	ret    
f0103f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103f08:	31 ff                	xor    %edi,%edi
f0103f0a:	31 db                	xor    %ebx,%ebx
f0103f0c:	89 d8                	mov    %ebx,%eax
f0103f0e:	89 fa                	mov    %edi,%edx
f0103f10:	83 c4 1c             	add    $0x1c,%esp
f0103f13:	5b                   	pop    %ebx
f0103f14:	5e                   	pop    %esi
f0103f15:	5f                   	pop    %edi
f0103f16:	5d                   	pop    %ebp
f0103f17:	c3                   	ret    
f0103f18:	90                   	nop
f0103f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103f20:	89 d8                	mov    %ebx,%eax
f0103f22:	f7 f7                	div    %edi
f0103f24:	31 ff                	xor    %edi,%edi
f0103f26:	89 c3                	mov    %eax,%ebx
f0103f28:	89 d8                	mov    %ebx,%eax
f0103f2a:	89 fa                	mov    %edi,%edx
f0103f2c:	83 c4 1c             	add    $0x1c,%esp
f0103f2f:	5b                   	pop    %ebx
f0103f30:	5e                   	pop    %esi
f0103f31:	5f                   	pop    %edi
f0103f32:	5d                   	pop    %ebp
f0103f33:	c3                   	ret    
f0103f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103f38:	39 ce                	cmp    %ecx,%esi
f0103f3a:	72 0c                	jb     f0103f48 <__udivdi3+0x118>
f0103f3c:	31 db                	xor    %ebx,%ebx
f0103f3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0103f42:	0f 87 34 ff ff ff    	ja     f0103e7c <__udivdi3+0x4c>
f0103f48:	bb 01 00 00 00       	mov    $0x1,%ebx
f0103f4d:	e9 2a ff ff ff       	jmp    f0103e7c <__udivdi3+0x4c>
f0103f52:	66 90                	xchg   %ax,%ax
f0103f54:	66 90                	xchg   %ax,%ax
f0103f56:	66 90                	xchg   %ax,%ax
f0103f58:	66 90                	xchg   %ax,%ax
f0103f5a:	66 90                	xchg   %ax,%ax
f0103f5c:	66 90                	xchg   %ax,%ax
f0103f5e:	66 90                	xchg   %ax,%ax

f0103f60 <__umoddi3>:
f0103f60:	55                   	push   %ebp
f0103f61:	57                   	push   %edi
f0103f62:	56                   	push   %esi
f0103f63:	53                   	push   %ebx
f0103f64:	83 ec 1c             	sub    $0x1c,%esp
f0103f67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0103f6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0103f6f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103f77:	85 d2                	test   %edx,%edx
f0103f79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103f81:	89 f3                	mov    %esi,%ebx
f0103f83:	89 3c 24             	mov    %edi,(%esp)
f0103f86:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103f8a:	75 1c                	jne    f0103fa8 <__umoddi3+0x48>
f0103f8c:	39 f7                	cmp    %esi,%edi
f0103f8e:	76 50                	jbe    f0103fe0 <__umoddi3+0x80>
f0103f90:	89 c8                	mov    %ecx,%eax
f0103f92:	89 f2                	mov    %esi,%edx
f0103f94:	f7 f7                	div    %edi
f0103f96:	89 d0                	mov    %edx,%eax
f0103f98:	31 d2                	xor    %edx,%edx
f0103f9a:	83 c4 1c             	add    $0x1c,%esp
f0103f9d:	5b                   	pop    %ebx
f0103f9e:	5e                   	pop    %esi
f0103f9f:	5f                   	pop    %edi
f0103fa0:	5d                   	pop    %ebp
f0103fa1:	c3                   	ret    
f0103fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103fa8:	39 f2                	cmp    %esi,%edx
f0103faa:	89 d0                	mov    %edx,%eax
f0103fac:	77 52                	ja     f0104000 <__umoddi3+0xa0>
f0103fae:	0f bd ea             	bsr    %edx,%ebp
f0103fb1:	83 f5 1f             	xor    $0x1f,%ebp
f0103fb4:	75 5a                	jne    f0104010 <__umoddi3+0xb0>
f0103fb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0103fba:	0f 82 e0 00 00 00    	jb     f01040a0 <__umoddi3+0x140>
f0103fc0:	39 0c 24             	cmp    %ecx,(%esp)
f0103fc3:	0f 86 d7 00 00 00    	jbe    f01040a0 <__umoddi3+0x140>
f0103fc9:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103fcd:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103fd1:	83 c4 1c             	add    $0x1c,%esp
f0103fd4:	5b                   	pop    %ebx
f0103fd5:	5e                   	pop    %esi
f0103fd6:	5f                   	pop    %edi
f0103fd7:	5d                   	pop    %ebp
f0103fd8:	c3                   	ret    
f0103fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103fe0:	85 ff                	test   %edi,%edi
f0103fe2:	89 fd                	mov    %edi,%ebp
f0103fe4:	75 0b                	jne    f0103ff1 <__umoddi3+0x91>
f0103fe6:	b8 01 00 00 00       	mov    $0x1,%eax
f0103feb:	31 d2                	xor    %edx,%edx
f0103fed:	f7 f7                	div    %edi
f0103fef:	89 c5                	mov    %eax,%ebp
f0103ff1:	89 f0                	mov    %esi,%eax
f0103ff3:	31 d2                	xor    %edx,%edx
f0103ff5:	f7 f5                	div    %ebp
f0103ff7:	89 c8                	mov    %ecx,%eax
f0103ff9:	f7 f5                	div    %ebp
f0103ffb:	89 d0                	mov    %edx,%eax
f0103ffd:	eb 99                	jmp    f0103f98 <__umoddi3+0x38>
f0103fff:	90                   	nop
f0104000:	89 c8                	mov    %ecx,%eax
f0104002:	89 f2                	mov    %esi,%edx
f0104004:	83 c4 1c             	add    $0x1c,%esp
f0104007:	5b                   	pop    %ebx
f0104008:	5e                   	pop    %esi
f0104009:	5f                   	pop    %edi
f010400a:	5d                   	pop    %ebp
f010400b:	c3                   	ret    
f010400c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104010:	8b 34 24             	mov    (%esp),%esi
f0104013:	bf 20 00 00 00       	mov    $0x20,%edi
f0104018:	89 e9                	mov    %ebp,%ecx
f010401a:	29 ef                	sub    %ebp,%edi
f010401c:	d3 e0                	shl    %cl,%eax
f010401e:	89 f9                	mov    %edi,%ecx
f0104020:	89 f2                	mov    %esi,%edx
f0104022:	d3 ea                	shr    %cl,%edx
f0104024:	89 e9                	mov    %ebp,%ecx
f0104026:	09 c2                	or     %eax,%edx
f0104028:	89 d8                	mov    %ebx,%eax
f010402a:	89 14 24             	mov    %edx,(%esp)
f010402d:	89 f2                	mov    %esi,%edx
f010402f:	d3 e2                	shl    %cl,%edx
f0104031:	89 f9                	mov    %edi,%ecx
f0104033:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104037:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010403b:	d3 e8                	shr    %cl,%eax
f010403d:	89 e9                	mov    %ebp,%ecx
f010403f:	89 c6                	mov    %eax,%esi
f0104041:	d3 e3                	shl    %cl,%ebx
f0104043:	89 f9                	mov    %edi,%ecx
f0104045:	89 d0                	mov    %edx,%eax
f0104047:	d3 e8                	shr    %cl,%eax
f0104049:	89 e9                	mov    %ebp,%ecx
f010404b:	09 d8                	or     %ebx,%eax
f010404d:	89 d3                	mov    %edx,%ebx
f010404f:	89 f2                	mov    %esi,%edx
f0104051:	f7 34 24             	divl   (%esp)
f0104054:	89 d6                	mov    %edx,%esi
f0104056:	d3 e3                	shl    %cl,%ebx
f0104058:	f7 64 24 04          	mull   0x4(%esp)
f010405c:	39 d6                	cmp    %edx,%esi
f010405e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104062:	89 d1                	mov    %edx,%ecx
f0104064:	89 c3                	mov    %eax,%ebx
f0104066:	72 08                	jb     f0104070 <__umoddi3+0x110>
f0104068:	75 11                	jne    f010407b <__umoddi3+0x11b>
f010406a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010406e:	73 0b                	jae    f010407b <__umoddi3+0x11b>
f0104070:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104074:	1b 14 24             	sbb    (%esp),%edx
f0104077:	89 d1                	mov    %edx,%ecx
f0104079:	89 c3                	mov    %eax,%ebx
f010407b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010407f:	29 da                	sub    %ebx,%edx
f0104081:	19 ce                	sbb    %ecx,%esi
f0104083:	89 f9                	mov    %edi,%ecx
f0104085:	89 f0                	mov    %esi,%eax
f0104087:	d3 e0                	shl    %cl,%eax
f0104089:	89 e9                	mov    %ebp,%ecx
f010408b:	d3 ea                	shr    %cl,%edx
f010408d:	89 e9                	mov    %ebp,%ecx
f010408f:	d3 ee                	shr    %cl,%esi
f0104091:	09 d0                	or     %edx,%eax
f0104093:	89 f2                	mov    %esi,%edx
f0104095:	83 c4 1c             	add    $0x1c,%esp
f0104098:	5b                   	pop    %ebx
f0104099:	5e                   	pop    %esi
f010409a:	5f                   	pop    %edi
f010409b:	5d                   	pop    %ebp
f010409c:	c3                   	ret    
f010409d:	8d 76 00             	lea    0x0(%esi),%esi
f01040a0:	29 f9                	sub    %edi,%ecx
f01040a2:	19 d6                	sbb    %edx,%esi
f01040a4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01040a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01040ac:	e9 18 ff ff ff       	jmp    f0103fc9 <__umoddi3+0x69>
