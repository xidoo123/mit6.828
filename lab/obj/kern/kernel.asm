
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
f0100058:	e8 9c 3e 00 00       	call   f0103ef9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 ab 04 00 00       	call   f010050d <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 a0 43 10 f0       	push   $0xf01043a0
f010006f:	e8 f0 2f 00 00       	call   f0103064 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 9d 11 00 00       	call   f0101216 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 e5 29 00 00       	call   f0102a63 <env_init>
	trap_init();
f010007e:	e8 5b 30 00 00       	call   f01030de <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 56 a3 11 f0       	push   $0xf011a356
f010008d:	e8 7a 2b 00 00       	call   f0102c0c <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100092:	83 c4 04             	add    $0x4,%esp
f0100095:	ff 35 88 ff 16 f0    	pushl  0xf016ff88
f010009b:	e8 df 2e 00 00       	call   f0102f7f <env_run>

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
f01000c5:	68 bb 43 10 f0       	push   $0xf01043bb
f01000ca:	e8 95 2f 00 00       	call   f0103064 <cprintf>
	vcprintf(fmt, ap);
f01000cf:	83 c4 08             	add    $0x8,%esp
f01000d2:	53                   	push   %ebx
f01000d3:	56                   	push   %esi
f01000d4:	e8 65 2f 00 00       	call   f010303e <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 b0 4b 10 f0 	movl   $0xf0104bb0,(%esp)
f01000e0:	e8 7f 2f 00 00       	call   f0103064 <cprintf>
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
f0100107:	68 d3 43 10 f0       	push   $0xf01043d3
f010010c:	e8 53 2f 00 00       	call   f0103064 <cprintf>
	vcprintf(fmt, ap);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	53                   	push   %ebx
f0100115:	ff 75 10             	pushl  0x10(%ebp)
f0100118:	e8 21 2f 00 00       	call   f010303e <vcprintf>
	cprintf("\n");
f010011d:	c7 04 24 b0 4b 10 f0 	movl   $0xf0104bb0,(%esp)
f0100124:	e8 3b 2f 00 00       	call   f0103064 <cprintf>
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
f01001e3:	0f b6 82 40 45 10 f0 	movzbl -0xfefbac0(%edx),%eax
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
f010021f:	0f b6 82 40 45 10 f0 	movzbl -0xfefbac0(%edx),%eax
f0100226:	0b 05 40 fd 16 f0    	or     0xf016fd40,%eax
f010022c:	0f b6 8a 40 44 10 f0 	movzbl -0xfefbbc0(%edx),%ecx
f0100233:	31 c8                	xor    %ecx,%eax
f0100235:	a3 40 fd 16 f0       	mov    %eax,0xf016fd40

	c = charcode[shift & (CTL | SHIFT)][data];
f010023a:	89 c1                	mov    %eax,%ecx
f010023c:	83 e1 03             	and    $0x3,%ecx
f010023f:	8b 0c 8d 20 44 10 f0 	mov    -0xfefbbe0(,%ecx,4),%ecx
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
f010027d:	68 ed 43 10 f0       	push   $0xf01043ed
f0100282:	e8 dd 2d 00 00       	call   f0103064 <cprintf>
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
f0100431:	e8 10 3b 00 00       	call   f0103f46 <memmove>
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
f0100600:	68 f9 43 10 f0       	push   $0xf01043f9
f0100605:	e8 5a 2a 00 00       	call   f0103064 <cprintf>
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
f0100646:	68 40 46 10 f0       	push   $0xf0104640
f010064b:	68 5e 46 10 f0       	push   $0xf010465e
f0100650:	68 63 46 10 f0       	push   $0xf0104663
f0100655:	e8 0a 2a 00 00       	call   f0103064 <cprintf>
f010065a:	83 c4 0c             	add    $0xc,%esp
f010065d:	68 1c 47 10 f0       	push   $0xf010471c
f0100662:	68 6c 46 10 f0       	push   $0xf010466c
f0100667:	68 63 46 10 f0       	push   $0xf0104663
f010066c:	e8 f3 29 00 00       	call   f0103064 <cprintf>
f0100671:	83 c4 0c             	add    $0xc,%esp
f0100674:	68 75 46 10 f0       	push   $0xf0104675
f0100679:	68 93 46 10 f0       	push   $0xf0104693
f010067e:	68 63 46 10 f0       	push   $0xf0104663
f0100683:	e8 dc 29 00 00       	call   f0103064 <cprintf>
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
f0100695:	68 9d 46 10 f0       	push   $0xf010469d
f010069a:	e8 c5 29 00 00       	call   f0103064 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010069f:	83 c4 08             	add    $0x8,%esp
f01006a2:	68 0c 00 10 00       	push   $0x10000c
f01006a7:	68 44 47 10 f0       	push   $0xf0104744
f01006ac:	e8 b3 29 00 00       	call   f0103064 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006b1:	83 c4 0c             	add    $0xc,%esp
f01006b4:	68 0c 00 10 00       	push   $0x10000c
f01006b9:	68 0c 00 10 f0       	push   $0xf010000c
f01006be:	68 6c 47 10 f0       	push   $0xf010476c
f01006c3:	e8 9c 29 00 00       	call   f0103064 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006c8:	83 c4 0c             	add    $0xc,%esp
f01006cb:	68 81 43 10 00       	push   $0x104381
f01006d0:	68 81 43 10 f0       	push   $0xf0104381
f01006d5:	68 90 47 10 f0       	push   $0xf0104790
f01006da:	e8 85 29 00 00       	call   f0103064 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006df:	83 c4 0c             	add    $0xc,%esp
f01006e2:	68 40 fd 16 00       	push   $0x16fd40
f01006e7:	68 40 fd 16 f0       	push   $0xf016fd40
f01006ec:	68 b4 47 10 f0       	push   $0xf01047b4
f01006f1:	e8 6e 29 00 00       	call   f0103064 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006f6:	83 c4 0c             	add    $0xc,%esp
f01006f9:	68 40 0c 17 00       	push   $0x170c40
f01006fe:	68 40 0c 17 f0       	push   $0xf0170c40
f0100703:	68 d8 47 10 f0       	push   $0xf01047d8
f0100708:	e8 57 29 00 00       	call   f0103064 <cprintf>
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
f010072e:	68 fc 47 10 f0       	push   $0xf01047fc
f0100733:	e8 2c 29 00 00       	call   f0103064 <cprintf>
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
f010076d:	68 b6 46 10 f0       	push   $0xf01046b6
f0100772:	e8 ed 28 00 00       	call   f0103064 <cprintf>

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
f010079f:	e8 7d 2d 00 00       	call   f0103521 <debuginfo_eip>

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
f01007fb:	68 28 48 10 f0       	push   $0xf0104828
f0100800:	e8 5f 28 00 00       	call   f0103064 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f0100805:	83 c4 14             	add    $0x14,%esp
f0100808:	2b 75 cc             	sub    -0x34(%ebp),%esi
f010080b:	56                   	push   %esi
f010080c:	8d 45 8a             	lea    -0x76(%ebp),%eax
f010080f:	50                   	push   %eax
f0100810:	ff 75 c0             	pushl  -0x40(%ebp)
f0100813:	ff 75 bc             	pushl  -0x44(%ebp)
f0100816:	68 c8 46 10 f0       	push   $0xf01046c8
f010081b:	e8 44 28 00 00       	call   f0103064 <cprintf>

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
f0100843:	68 60 48 10 f0       	push   $0xf0104860
f0100848:	e8 17 28 00 00       	call   f0103064 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010084d:	c7 04 24 84 48 10 f0 	movl   $0xf0104884,(%esp)
f0100854:	e8 0b 28 00 00       	call   f0103064 <cprintf>

	if (tf != NULL)
f0100859:	83 c4 10             	add    $0x10,%esp
f010085c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100860:	74 0e                	je     f0100870 <monitor+0x36>
		print_trapframe(tf);
f0100862:	83 ec 0c             	sub    $0xc,%esp
f0100865:	ff 75 08             	pushl  0x8(%ebp)
f0100868:	e8 09 29 00 00       	call   f0103176 <print_trapframe>
f010086d:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100870:	83 ec 0c             	sub    $0xc,%esp
f0100873:	68 df 46 10 f0       	push   $0xf01046df
f0100878:	e8 25 34 00 00       	call   f0103ca2 <readline>
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
f01008ac:	68 e3 46 10 f0       	push   $0xf01046e3
f01008b1:	e8 06 36 00 00       	call   f0103ebc <strchr>
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
f01008cc:	68 e8 46 10 f0       	push   $0xf01046e8
f01008d1:	e8 8e 27 00 00       	call   f0103064 <cprintf>
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
f01008f5:	68 e3 46 10 f0       	push   $0xf01046e3
f01008fa:	e8 bd 35 00 00       	call   f0103ebc <strchr>
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
f0100923:	ff 34 85 c0 48 10 f0 	pushl  -0xfefb740(,%eax,4)
f010092a:	ff 75 a8             	pushl  -0x58(%ebp)
f010092d:	e8 2c 35 00 00       	call   f0103e5e <strcmp>
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
f0100947:	ff 14 85 c8 48 10 f0 	call   *-0xfefb738(,%eax,4)
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
f0100968:	68 05 47 10 f0       	push   $0xf0104705
f010096d:	e8 f2 26 00 00       	call   f0103064 <cprintf>
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
f010098d:	e8 6b 26 00 00       	call   f0102ffd <mc146818_read>
f0100992:	89 c6                	mov    %eax,%esi
f0100994:	83 c3 01             	add    $0x1,%ebx
f0100997:	89 1c 24             	mov    %ebx,(%esp)
f010099a:	e8 5e 26 00 00       	call   f0102ffd <mc146818_read>
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
f01009d9:	68 e4 48 10 f0       	push   $0xf01048e4
f01009de:	6a 6c                	push   $0x6c
f01009e0:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0100a23:	68 e4 4b 10 f0       	push   $0xf0104be4
f0100a28:	68 a4 03 00 00       	push   $0x3a4
f0100a2d:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0100a7b:	68 08 4c 10 f0       	push   $0xf0104c08
f0100a80:	68 de 02 00 00       	push   $0x2de
f0100a85:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0100b0a:	68 e4 4b 10 f0       	push   $0xf0104be4
f0100b0f:	6a 56                	push   $0x56
f0100b11:	68 0b 49 10 f0       	push   $0xf010490b
f0100b16:	e8 85 f5 ff ff       	call   f01000a0 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b1b:	83 ec 04             	sub    $0x4,%esp
f0100b1e:	68 80 00 00 00       	push   $0x80
f0100b23:	68 97 00 00 00       	push   $0x97
f0100b28:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b2d:	50                   	push   %eax
f0100b2e:	e8 c6 33 00 00       	call   f0103ef9 <memset>
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
f0100b74:	68 19 49 10 f0       	push   $0xf0104919
f0100b79:	68 25 49 10 f0       	push   $0xf0104925
f0100b7e:	68 f8 02 00 00       	push   $0x2f8
f0100b83:	68 ff 48 10 f0       	push   $0xf01048ff
f0100b88:	e8 13 f5 ff ff       	call   f01000a0 <_panic>
		assert(pp < pages + npages);
f0100b8d:	39 fa                	cmp    %edi,%edx
f0100b8f:	72 19                	jb     f0100baa <check_page_free_list+0x148>
f0100b91:	68 3a 49 10 f0       	push   $0xf010493a
f0100b96:	68 25 49 10 f0       	push   $0xf0104925
f0100b9b:	68 f9 02 00 00       	push   $0x2f9
f0100ba0:	68 ff 48 10 f0       	push   $0xf01048ff
f0100ba5:	e8 f6 f4 ff ff       	call   f01000a0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100baa:	89 d0                	mov    %edx,%eax
f0100bac:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100baf:	a8 07                	test   $0x7,%al
f0100bb1:	74 19                	je     f0100bcc <check_page_free_list+0x16a>
f0100bb3:	68 2c 4c 10 f0       	push   $0xf0104c2c
f0100bb8:	68 25 49 10 f0       	push   $0xf0104925
f0100bbd:	68 fa 02 00 00       	push   $0x2fa
f0100bc2:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0100bd6:	68 4e 49 10 f0       	push   $0xf010494e
f0100bdb:	68 25 49 10 f0       	push   $0xf0104925
f0100be0:	68 fd 02 00 00       	push   $0x2fd
f0100be5:	68 ff 48 10 f0       	push   $0xf01048ff
f0100bea:	e8 b1 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bef:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bf4:	75 19                	jne    f0100c0f <check_page_free_list+0x1ad>
f0100bf6:	68 5f 49 10 f0       	push   $0xf010495f
f0100bfb:	68 25 49 10 f0       	push   $0xf0104925
f0100c00:	68 fe 02 00 00       	push   $0x2fe
f0100c05:	68 ff 48 10 f0       	push   $0xf01048ff
f0100c0a:	e8 91 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c0f:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c14:	75 19                	jne    f0100c2f <check_page_free_list+0x1cd>
f0100c16:	68 60 4c 10 f0       	push   $0xf0104c60
f0100c1b:	68 25 49 10 f0       	push   $0xf0104925
f0100c20:	68 ff 02 00 00       	push   $0x2ff
f0100c25:	68 ff 48 10 f0       	push   $0xf01048ff
f0100c2a:	e8 71 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c2f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c34:	75 19                	jne    f0100c4f <check_page_free_list+0x1ed>
f0100c36:	68 78 49 10 f0       	push   $0xf0104978
f0100c3b:	68 25 49 10 f0       	push   $0xf0104925
f0100c40:	68 00 03 00 00       	push   $0x300
f0100c45:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0100c61:	68 e4 4b 10 f0       	push   $0xf0104be4
f0100c66:	6a 56                	push   $0x56
f0100c68:	68 0b 49 10 f0       	push   $0xf010490b
f0100c6d:	e8 2e f4 ff ff       	call   f01000a0 <_panic>
f0100c72:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c77:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c7a:	76 1e                	jbe    f0100c9a <check_page_free_list+0x238>
f0100c7c:	68 84 4c 10 f0       	push   $0xf0104c84
f0100c81:	68 25 49 10 f0       	push   $0xf0104925
f0100c86:	68 01 03 00 00       	push   $0x301
f0100c8b:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0100caf:	68 92 49 10 f0       	push   $0xf0104992
f0100cb4:	68 25 49 10 f0       	push   $0xf0104925
f0100cb9:	68 09 03 00 00       	push   $0x309
f0100cbe:	68 ff 48 10 f0       	push   $0xf01048ff
f0100cc3:	e8 d8 f3 ff ff       	call   f01000a0 <_panic>
	assert(nfree_extmem > 0);
f0100cc8:	85 db                	test   %ebx,%ebx
f0100cca:	7f 19                	jg     f0100ce5 <check_page_free_list+0x283>
f0100ccc:	68 a4 49 10 f0       	push   $0xf01049a4
f0100cd1:	68 25 49 10 f0       	push   $0xf0104925
f0100cd6:	68 0a 03 00 00       	push   $0x30a
f0100cdb:	68 ff 48 10 f0       	push   $0xf01048ff
f0100ce0:	e8 bb f3 ff ff       	call   f01000a0 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100ce5:	83 ec 0c             	sub    $0xc,%esp
f0100ce8:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0100ced:	e8 72 23 00 00       	call   f0103064 <cprintf>
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
f0100e31:	68 f0 4c 10 f0       	push   $0xf0104cf0
f0100e36:	68 47 01 00 00       	push   $0x147
f0100e3b:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0100eda:	68 e4 4b 10 f0       	push   $0xf0104be4
f0100edf:	6a 56                	push   $0x56
f0100ee1:	68 0b 49 10 f0       	push   $0xf010490b
f0100ee6:	e8 b5 f1 ff ff       	call   f01000a0 <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f0100eeb:	83 ec 04             	sub    $0x4,%esp
f0100eee:	68 00 10 00 00       	push   $0x1000
f0100ef3:	6a 00                	push   $0x0
f0100ef5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100efa:	50                   	push   %eax
f0100efb:	e8 f9 2f 00 00       	call   f0103ef9 <memset>
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
f0100f27:	68 14 4d 10 f0       	push   $0xf0104d14
f0100f2c:	68 8c 01 00 00       	push   $0x18c
f0100f31:	68 ff 48 10 f0       	push   $0xf01048ff
f0100f36:	e8 65 f1 ff ff       	call   f01000a0 <_panic>
	if (pp->pp_ref != 0)
f0100f3b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f40:	74 17                	je     f0100f59 <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0100f42:	83 ec 04             	sub    $0x4,%esp
f0100f45:	68 3c 4d 10 f0       	push   $0xf0104d3c
f0100f4a:	68 8e 01 00 00       	push   $0x18e
f0100f4f:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0100ff5:	68 e4 4b 10 f0       	push   $0xf0104be4
f0100ffa:	68 db 01 00 00       	push   $0x1db
f0100fff:	68 ff 48 10 f0       	push   $0xf01048ff
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
f010103f:	68 80 4d 10 f0       	push   $0xf0104d80
f0101044:	68 f0 01 00 00       	push   $0x1f0
f0101049:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101081:	68 b4 4d 10 f0       	push   $0xf0104db4
f0101086:	68 f3 01 00 00       	push   $0x1f3
f010108b:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01010b0:	68 e4 4d 10 f0       	push   $0xf0104de4
f01010b5:	68 fe 01 00 00       	push   $0x1fe
f01010ba:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101120:	68 10 4e 10 f0       	push   $0xf0104e10
f0101125:	6a 4f                	push   $0x4f
f0101127:	68 0b 49 10 f0       	push   $0xf010490b
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
f0101277:	68 30 4e 10 f0       	push   $0xf0104e30
f010127c:	e8 e3 1d 00 00       	call   f0103064 <cprintf>
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
f010129b:	e8 59 2c 00 00       	call   f0103ef9 <memset>
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
f01012b0:	68 f0 4c 10 f0       	push   $0xf0104cf0
f01012b5:	68 97 00 00 00       	push   $0x97
f01012ba:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01012f2:	e8 02 2c 00 00       	call   f0103ef9 <memset>
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
f0101311:	e8 e3 2b 00 00       	call   f0103ef9 <memset>
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
f0101334:	68 b5 49 10 f0       	push   $0xf01049b5
f0101339:	68 1d 03 00 00       	push   $0x31d
f010133e:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101370:	68 d0 49 10 f0       	push   $0xf01049d0
f0101375:	68 25 49 10 f0       	push   $0xf0104925
f010137a:	68 25 03 00 00       	push   $0x325
f010137f:	68 ff 48 10 f0       	push   $0xf01048ff
f0101384:	e8 17 ed ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101389:	83 ec 0c             	sub    $0xc,%esp
f010138c:	6a 00                	push   $0x0
f010138e:	e8 0e fb ff ff       	call   f0100ea1 <page_alloc>
f0101393:	89 c6                	mov    %eax,%esi
f0101395:	83 c4 10             	add    $0x10,%esp
f0101398:	85 c0                	test   %eax,%eax
f010139a:	75 19                	jne    f01013b5 <mem_init+0x19f>
f010139c:	68 e6 49 10 f0       	push   $0xf01049e6
f01013a1:	68 25 49 10 f0       	push   $0xf0104925
f01013a6:	68 26 03 00 00       	push   $0x326
f01013ab:	68 ff 48 10 f0       	push   $0xf01048ff
f01013b0:	e8 eb ec ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01013b5:	83 ec 0c             	sub    $0xc,%esp
f01013b8:	6a 00                	push   $0x0
f01013ba:	e8 e2 fa ff ff       	call   f0100ea1 <page_alloc>
f01013bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013c2:	83 c4 10             	add    $0x10,%esp
f01013c5:	85 c0                	test   %eax,%eax
f01013c7:	75 19                	jne    f01013e2 <mem_init+0x1cc>
f01013c9:	68 fc 49 10 f0       	push   $0xf01049fc
f01013ce:	68 25 49 10 f0       	push   $0xf0104925
f01013d3:	68 27 03 00 00       	push   $0x327
f01013d8:	68 ff 48 10 f0       	push   $0xf01048ff
f01013dd:	e8 be ec ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013e2:	39 f7                	cmp    %esi,%edi
f01013e4:	75 19                	jne    f01013ff <mem_init+0x1e9>
f01013e6:	68 12 4a 10 f0       	push   $0xf0104a12
f01013eb:	68 25 49 10 f0       	push   $0xf0104925
f01013f0:	68 2a 03 00 00       	push   $0x32a
f01013f5:	68 ff 48 10 f0       	push   $0xf01048ff
f01013fa:	e8 a1 ec ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101402:	39 c6                	cmp    %eax,%esi
f0101404:	74 04                	je     f010140a <mem_init+0x1f4>
f0101406:	39 c7                	cmp    %eax,%edi
f0101408:	75 19                	jne    f0101423 <mem_init+0x20d>
f010140a:	68 6c 4e 10 f0       	push   $0xf0104e6c
f010140f:	68 25 49 10 f0       	push   $0xf0104925
f0101414:	68 2b 03 00 00       	push   $0x32b
f0101419:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101440:	68 24 4a 10 f0       	push   $0xf0104a24
f0101445:	68 25 49 10 f0       	push   $0xf0104925
f010144a:	68 2c 03 00 00       	push   $0x32c
f010144f:	68 ff 48 10 f0       	push   $0xf01048ff
f0101454:	e8 47 ec ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101459:	89 f0                	mov    %esi,%eax
f010145b:	29 c8                	sub    %ecx,%eax
f010145d:	c1 f8 03             	sar    $0x3,%eax
f0101460:	c1 e0 0c             	shl    $0xc,%eax
f0101463:	39 c2                	cmp    %eax,%edx
f0101465:	77 19                	ja     f0101480 <mem_init+0x26a>
f0101467:	68 41 4a 10 f0       	push   $0xf0104a41
f010146c:	68 25 49 10 f0       	push   $0xf0104925
f0101471:	68 2d 03 00 00       	push   $0x32d
f0101476:	68 ff 48 10 f0       	push   $0xf01048ff
f010147b:	e8 20 ec ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101480:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101483:	29 c8                	sub    %ecx,%eax
f0101485:	c1 f8 03             	sar    $0x3,%eax
f0101488:	c1 e0 0c             	shl    $0xc,%eax
f010148b:	39 c2                	cmp    %eax,%edx
f010148d:	77 19                	ja     f01014a8 <mem_init+0x292>
f010148f:	68 5e 4a 10 f0       	push   $0xf0104a5e
f0101494:	68 25 49 10 f0       	push   $0xf0104925
f0101499:	68 2e 03 00 00       	push   $0x32e
f010149e:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01014cb:	68 7b 4a 10 f0       	push   $0xf0104a7b
f01014d0:	68 25 49 10 f0       	push   $0xf0104925
f01014d5:	68 35 03 00 00       	push   $0x335
f01014da:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101515:	68 d0 49 10 f0       	push   $0xf01049d0
f010151a:	68 25 49 10 f0       	push   $0xf0104925
f010151f:	68 3c 03 00 00       	push   $0x33c
f0101524:	68 ff 48 10 f0       	push   $0xf01048ff
f0101529:	e8 72 eb ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f010152e:	83 ec 0c             	sub    $0xc,%esp
f0101531:	6a 00                	push   $0x0
f0101533:	e8 69 f9 ff ff       	call   f0100ea1 <page_alloc>
f0101538:	89 c7                	mov    %eax,%edi
f010153a:	83 c4 10             	add    $0x10,%esp
f010153d:	85 c0                	test   %eax,%eax
f010153f:	75 19                	jne    f010155a <mem_init+0x344>
f0101541:	68 e6 49 10 f0       	push   $0xf01049e6
f0101546:	68 25 49 10 f0       	push   $0xf0104925
f010154b:	68 3d 03 00 00       	push   $0x33d
f0101550:	68 ff 48 10 f0       	push   $0xf01048ff
f0101555:	e8 46 eb ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f010155a:	83 ec 0c             	sub    $0xc,%esp
f010155d:	6a 00                	push   $0x0
f010155f:	e8 3d f9 ff ff       	call   f0100ea1 <page_alloc>
f0101564:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101567:	83 c4 10             	add    $0x10,%esp
f010156a:	85 c0                	test   %eax,%eax
f010156c:	75 19                	jne    f0101587 <mem_init+0x371>
f010156e:	68 fc 49 10 f0       	push   $0xf01049fc
f0101573:	68 25 49 10 f0       	push   $0xf0104925
f0101578:	68 3e 03 00 00       	push   $0x33e
f010157d:	68 ff 48 10 f0       	push   $0xf01048ff
f0101582:	e8 19 eb ff ff       	call   f01000a0 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101587:	39 fe                	cmp    %edi,%esi
f0101589:	75 19                	jne    f01015a4 <mem_init+0x38e>
f010158b:	68 12 4a 10 f0       	push   $0xf0104a12
f0101590:	68 25 49 10 f0       	push   $0xf0104925
f0101595:	68 40 03 00 00       	push   $0x340
f010159a:	68 ff 48 10 f0       	push   $0xf01048ff
f010159f:	e8 fc ea ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015a7:	39 c7                	cmp    %eax,%edi
f01015a9:	74 04                	je     f01015af <mem_init+0x399>
f01015ab:	39 c6                	cmp    %eax,%esi
f01015ad:	75 19                	jne    f01015c8 <mem_init+0x3b2>
f01015af:	68 6c 4e 10 f0       	push   $0xf0104e6c
f01015b4:	68 25 49 10 f0       	push   $0xf0104925
f01015b9:	68 41 03 00 00       	push   $0x341
f01015be:	68 ff 48 10 f0       	push   $0xf01048ff
f01015c3:	e8 d8 ea ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f01015c8:	83 ec 0c             	sub    $0xc,%esp
f01015cb:	6a 00                	push   $0x0
f01015cd:	e8 cf f8 ff ff       	call   f0100ea1 <page_alloc>
f01015d2:	83 c4 10             	add    $0x10,%esp
f01015d5:	85 c0                	test   %eax,%eax
f01015d7:	74 19                	je     f01015f2 <mem_init+0x3dc>
f01015d9:	68 7b 4a 10 f0       	push   $0xf0104a7b
f01015de:	68 25 49 10 f0       	push   $0xf0104925
f01015e3:	68 42 03 00 00       	push   $0x342
f01015e8:	68 ff 48 10 f0       	push   $0xf01048ff
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
f010160e:	68 e4 4b 10 f0       	push   $0xf0104be4
f0101613:	6a 56                	push   $0x56
f0101615:	68 0b 49 10 f0       	push   $0xf010490b
f010161a:	e8 81 ea ff ff       	call   f01000a0 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010161f:	83 ec 04             	sub    $0x4,%esp
f0101622:	68 00 10 00 00       	push   $0x1000
f0101627:	6a 01                	push   $0x1
f0101629:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010162e:	50                   	push   %eax
f010162f:	e8 c5 28 00 00       	call   f0103ef9 <memset>
	page_free(pp0);
f0101634:	89 34 24             	mov    %esi,(%esp)
f0101637:	e8 d6 f8 ff ff       	call   f0100f12 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010163c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101643:	e8 59 f8 ff ff       	call   f0100ea1 <page_alloc>
f0101648:	83 c4 10             	add    $0x10,%esp
f010164b:	85 c0                	test   %eax,%eax
f010164d:	75 19                	jne    f0101668 <mem_init+0x452>
f010164f:	68 8a 4a 10 f0       	push   $0xf0104a8a
f0101654:	68 25 49 10 f0       	push   $0xf0104925
f0101659:	68 47 03 00 00       	push   $0x347
f010165e:	68 ff 48 10 f0       	push   $0xf01048ff
f0101663:	e8 38 ea ff ff       	call   f01000a0 <_panic>
	assert(pp && pp0 == pp);
f0101668:	39 c6                	cmp    %eax,%esi
f010166a:	74 19                	je     f0101685 <mem_init+0x46f>
f010166c:	68 a8 4a 10 f0       	push   $0xf0104aa8
f0101671:	68 25 49 10 f0       	push   $0xf0104925
f0101676:	68 48 03 00 00       	push   $0x348
f010167b:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01016a1:	68 e4 4b 10 f0       	push   $0xf0104be4
f01016a6:	6a 56                	push   $0x56
f01016a8:	68 0b 49 10 f0       	push   $0xf010490b
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
f01016c3:	68 b8 4a 10 f0       	push   $0xf0104ab8
f01016c8:	68 25 49 10 f0       	push   $0xf0104925
f01016cd:	68 4c 03 00 00       	push   $0x34c
f01016d2:	68 ff 48 10 f0       	push   $0xf01048ff
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
f010171e:	68 c2 4a 10 f0       	push   $0xf0104ac2
f0101723:	68 25 49 10 f0       	push   $0xf0104925
f0101728:	68 5a 03 00 00       	push   $0x35a
f010172d:	68 ff 48 10 f0       	push   $0xf01048ff
f0101732:	e8 69 e9 ff ff       	call   f01000a0 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101737:	83 ec 0c             	sub    $0xc,%esp
f010173a:	68 8c 4e 10 f0       	push   $0xf0104e8c
f010173f:	e8 20 19 00 00       	call   f0103064 <cprintf>
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
f010175a:	68 d0 49 10 f0       	push   $0xf01049d0
f010175f:	68 25 49 10 f0       	push   $0xf0104925
f0101764:	68 bc 03 00 00       	push   $0x3bc
f0101769:	68 ff 48 10 f0       	push   $0xf01048ff
f010176e:	e8 2d e9 ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101773:	83 ec 0c             	sub    $0xc,%esp
f0101776:	6a 00                	push   $0x0
f0101778:	e8 24 f7 ff ff       	call   f0100ea1 <page_alloc>
f010177d:	89 c3                	mov    %eax,%ebx
f010177f:	83 c4 10             	add    $0x10,%esp
f0101782:	85 c0                	test   %eax,%eax
f0101784:	75 19                	jne    f010179f <mem_init+0x589>
f0101786:	68 e6 49 10 f0       	push   $0xf01049e6
f010178b:	68 25 49 10 f0       	push   $0xf0104925
f0101790:	68 bd 03 00 00       	push   $0x3bd
f0101795:	68 ff 48 10 f0       	push   $0xf01048ff
f010179a:	e8 01 e9 ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f010179f:	83 ec 0c             	sub    $0xc,%esp
f01017a2:	6a 00                	push   $0x0
f01017a4:	e8 f8 f6 ff ff       	call   f0100ea1 <page_alloc>
f01017a9:	89 c6                	mov    %eax,%esi
f01017ab:	83 c4 10             	add    $0x10,%esp
f01017ae:	85 c0                	test   %eax,%eax
f01017b0:	75 19                	jne    f01017cb <mem_init+0x5b5>
f01017b2:	68 fc 49 10 f0       	push   $0xf01049fc
f01017b7:	68 25 49 10 f0       	push   $0xf0104925
f01017bc:	68 be 03 00 00       	push   $0x3be
f01017c1:	68 ff 48 10 f0       	push   $0xf01048ff
f01017c6:	e8 d5 e8 ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017cb:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01017ce:	75 19                	jne    f01017e9 <mem_init+0x5d3>
f01017d0:	68 12 4a 10 f0       	push   $0xf0104a12
f01017d5:	68 25 49 10 f0       	push   $0xf0104925
f01017da:	68 c1 03 00 00       	push   $0x3c1
f01017df:	68 ff 48 10 f0       	push   $0xf01048ff
f01017e4:	e8 b7 e8 ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017e9:	39 c3                	cmp    %eax,%ebx
f01017eb:	74 05                	je     f01017f2 <mem_init+0x5dc>
f01017ed:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01017f0:	75 19                	jne    f010180b <mem_init+0x5f5>
f01017f2:	68 6c 4e 10 f0       	push   $0xf0104e6c
f01017f7:	68 25 49 10 f0       	push   $0xf0104925
f01017fc:	68 c2 03 00 00       	push   $0x3c2
f0101801:	68 ff 48 10 f0       	push   $0xf01048ff
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
f010182e:	68 7b 4a 10 f0       	push   $0xf0104a7b
f0101833:	68 25 49 10 f0       	push   $0xf0104925
f0101838:	68 c9 03 00 00       	push   $0x3c9
f010183d:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101862:	68 ac 4e 10 f0       	push   $0xf0104eac
f0101867:	68 25 49 10 f0       	push   $0xf0104925
f010186c:	68 cc 03 00 00       	push   $0x3cc
f0101871:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101892:	68 e4 4e 10 f0       	push   $0xf0104ee4
f0101897:	68 25 49 10 f0       	push   $0xf0104925
f010189c:	68 cf 03 00 00       	push   $0x3cf
f01018a1:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01018cd:	68 14 4f 10 f0       	push   $0xf0104f14
f01018d2:	68 25 49 10 f0       	push   $0xf0104925
f01018d7:	68 d3 03 00 00       	push   $0x3d3
f01018dc:	68 ff 48 10 f0       	push   $0xf01048ff
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
f010190d:	68 44 4f 10 f0       	push   $0xf0104f44
f0101912:	68 25 49 10 f0       	push   $0xf0104925
f0101917:	68 d4 03 00 00       	push   $0x3d4
f010191c:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101941:	68 6c 4f 10 f0       	push   $0xf0104f6c
f0101946:	68 25 49 10 f0       	push   $0xf0104925
f010194b:	68 d5 03 00 00       	push   $0x3d5
f0101950:	68 ff 48 10 f0       	push   $0xf01048ff
f0101955:	e8 46 e7 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f010195a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010195f:	74 19                	je     f010197a <mem_init+0x764>
f0101961:	68 cd 4a 10 f0       	push   $0xf0104acd
f0101966:	68 25 49 10 f0       	push   $0xf0104925
f010196b:	68 d6 03 00 00       	push   $0x3d6
f0101970:	68 ff 48 10 f0       	push   $0xf01048ff
f0101975:	e8 26 e7 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f010197a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010197d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101982:	74 19                	je     f010199d <mem_init+0x787>
f0101984:	68 de 4a 10 f0       	push   $0xf0104ade
f0101989:	68 25 49 10 f0       	push   $0xf0104925
f010198e:	68 d7 03 00 00       	push   $0x3d7
f0101993:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01019b2:	68 9c 4f 10 f0       	push   $0xf0104f9c
f01019b7:	68 25 49 10 f0       	push   $0xf0104925
f01019bc:	68 da 03 00 00       	push   $0x3da
f01019c1:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01019ec:	68 d8 4f 10 f0       	push   $0xf0104fd8
f01019f1:	68 25 49 10 f0       	push   $0xf0104925
f01019f6:	68 db 03 00 00       	push   $0x3db
f01019fb:	68 ff 48 10 f0       	push   $0xf01048ff
f0101a00:	e8 9b e6 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101a05:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a0a:	74 19                	je     f0101a25 <mem_init+0x80f>
f0101a0c:	68 ef 4a 10 f0       	push   $0xf0104aef
f0101a11:	68 25 49 10 f0       	push   $0xf0104925
f0101a16:	68 dc 03 00 00       	push   $0x3dc
f0101a1b:	68 ff 48 10 f0       	push   $0xf01048ff
f0101a20:	e8 7b e6 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101a25:	83 ec 0c             	sub    $0xc,%esp
f0101a28:	6a 00                	push   $0x0
f0101a2a:	e8 72 f4 ff ff       	call   f0100ea1 <page_alloc>
f0101a2f:	83 c4 10             	add    $0x10,%esp
f0101a32:	85 c0                	test   %eax,%eax
f0101a34:	74 19                	je     f0101a4f <mem_init+0x839>
f0101a36:	68 7b 4a 10 f0       	push   $0xf0104a7b
f0101a3b:	68 25 49 10 f0       	push   $0xf0104925
f0101a40:	68 df 03 00 00       	push   $0x3df
f0101a45:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101a69:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0101a6e:	68 25 49 10 f0       	push   $0xf0104925
f0101a73:	68 e2 03 00 00       	push   $0x3e2
f0101a78:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101aa3:	68 d8 4f 10 f0       	push   $0xf0104fd8
f0101aa8:	68 25 49 10 f0       	push   $0xf0104925
f0101aad:	68 e3 03 00 00       	push   $0x3e3
f0101ab2:	68 ff 48 10 f0       	push   $0xf01048ff
f0101ab7:	e8 e4 e5 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101abc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ac1:	74 19                	je     f0101adc <mem_init+0x8c6>
f0101ac3:	68 ef 4a 10 f0       	push   $0xf0104aef
f0101ac8:	68 25 49 10 f0       	push   $0xf0104925
f0101acd:	68 e4 03 00 00       	push   $0x3e4
f0101ad2:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101aed:	68 7b 4a 10 f0       	push   $0xf0104a7b
f0101af2:	68 25 49 10 f0       	push   $0xf0104925
f0101af7:	68 e8 03 00 00       	push   $0x3e8
f0101afc:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101b21:	68 e4 4b 10 f0       	push   $0xf0104be4
f0101b26:	68 eb 03 00 00       	push   $0x3eb
f0101b2b:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101b5a:	68 08 50 10 f0       	push   $0xf0105008
f0101b5f:	68 25 49 10 f0       	push   $0xf0104925
f0101b64:	68 ec 03 00 00       	push   $0x3ec
f0101b69:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101b8d:	68 48 50 10 f0       	push   $0xf0105048
f0101b92:	68 25 49 10 f0       	push   $0xf0104925
f0101b97:	68 ef 03 00 00       	push   $0x3ef
f0101b9c:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101bca:	68 d8 4f 10 f0       	push   $0xf0104fd8
f0101bcf:	68 25 49 10 f0       	push   $0xf0104925
f0101bd4:	68 f0 03 00 00       	push   $0x3f0
f0101bd9:	68 ff 48 10 f0       	push   $0xf01048ff
f0101bde:	e8 bd e4 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101be3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101be8:	74 19                	je     f0101c03 <mem_init+0x9ed>
f0101bea:	68 ef 4a 10 f0       	push   $0xf0104aef
f0101bef:	68 25 49 10 f0       	push   $0xf0104925
f0101bf4:	68 f1 03 00 00       	push   $0x3f1
f0101bf9:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101c1b:	68 88 50 10 f0       	push   $0xf0105088
f0101c20:	68 25 49 10 f0       	push   $0xf0104925
f0101c25:	68 f2 03 00 00       	push   $0x3f2
f0101c2a:	68 ff 48 10 f0       	push   $0xf01048ff
f0101c2f:	e8 6c e4 ff ff       	call   f01000a0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101c34:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
f0101c39:	f6 00 04             	testb  $0x4,(%eax)
f0101c3c:	75 19                	jne    f0101c57 <mem_init+0xa41>
f0101c3e:	68 00 4b 10 f0       	push   $0xf0104b00
f0101c43:	68 25 49 10 f0       	push   $0xf0104925
f0101c48:	68 f3 03 00 00       	push   $0x3f3
f0101c4d:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101c6c:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0101c71:	68 25 49 10 f0       	push   $0xf0104925
f0101c76:	68 f6 03 00 00       	push   $0x3f6
f0101c7b:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101ca2:	68 bc 50 10 f0       	push   $0xf01050bc
f0101ca7:	68 25 49 10 f0       	push   $0xf0104925
f0101cac:	68 f7 03 00 00       	push   $0x3f7
f0101cb1:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101cd8:	68 f0 50 10 f0       	push   $0xf01050f0
f0101cdd:	68 25 49 10 f0       	push   $0xf0104925
f0101ce2:	68 f8 03 00 00       	push   $0x3f8
f0101ce7:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101d0d:	68 28 51 10 f0       	push   $0xf0105128
f0101d12:	68 25 49 10 f0       	push   $0xf0104925
f0101d17:	68 fb 03 00 00       	push   $0x3fb
f0101d1c:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101d40:	68 60 51 10 f0       	push   $0xf0105160
f0101d45:	68 25 49 10 f0       	push   $0xf0104925
f0101d4a:	68 fe 03 00 00       	push   $0x3fe
f0101d4f:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101d76:	68 f0 50 10 f0       	push   $0xf01050f0
f0101d7b:	68 25 49 10 f0       	push   $0xf0104925
f0101d80:	68 ff 03 00 00       	push   $0x3ff
f0101d85:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101db8:	68 9c 51 10 f0       	push   $0xf010519c
f0101dbd:	68 25 49 10 f0       	push   $0xf0104925
f0101dc2:	68 02 04 00 00       	push   $0x402
f0101dc7:	68 ff 48 10 f0       	push   $0xf01048ff
f0101dcc:	e8 cf e2 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dd1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dd6:	89 f8                	mov    %edi,%eax
f0101dd8:	e8 21 ec ff ff       	call   f01009fe <check_va2pa>
f0101ddd:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101de0:	74 19                	je     f0101dfb <mem_init+0xbe5>
f0101de2:	68 c8 51 10 f0       	push   $0xf01051c8
f0101de7:	68 25 49 10 f0       	push   $0xf0104925
f0101dec:	68 03 04 00 00       	push   $0x403
f0101df1:	68 ff 48 10 f0       	push   $0xf01048ff
f0101df6:	e8 a5 e2 ff ff       	call   f01000a0 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101dfb:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101e00:	74 19                	je     f0101e1b <mem_init+0xc05>
f0101e02:	68 16 4b 10 f0       	push   $0xf0104b16
f0101e07:	68 25 49 10 f0       	push   $0xf0104925
f0101e0c:	68 05 04 00 00       	push   $0x405
f0101e11:	68 ff 48 10 f0       	push   $0xf01048ff
f0101e16:	e8 85 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101e1b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e20:	74 19                	je     f0101e3b <mem_init+0xc25>
f0101e22:	68 27 4b 10 f0       	push   $0xf0104b27
f0101e27:	68 25 49 10 f0       	push   $0xf0104925
f0101e2c:	68 06 04 00 00       	push   $0x406
f0101e31:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101e50:	68 f8 51 10 f0       	push   $0xf01051f8
f0101e55:	68 25 49 10 f0       	push   $0xf0104925
f0101e5a:	68 09 04 00 00       	push   $0x409
f0101e5f:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101e93:	68 1c 52 10 f0       	push   $0xf010521c
f0101e98:	68 25 49 10 f0       	push   $0xf0104925
f0101e9d:	68 0d 04 00 00       	push   $0x40d
f0101ea2:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101eca:	68 c8 51 10 f0       	push   $0xf01051c8
f0101ecf:	68 25 49 10 f0       	push   $0xf0104925
f0101ed4:	68 0e 04 00 00       	push   $0x40e
f0101ed9:	68 ff 48 10 f0       	push   $0xf01048ff
f0101ede:	e8 bd e1 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101ee3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ee8:	74 19                	je     f0101f03 <mem_init+0xced>
f0101eea:	68 cd 4a 10 f0       	push   $0xf0104acd
f0101eef:	68 25 49 10 f0       	push   $0xf0104925
f0101ef4:	68 0f 04 00 00       	push   $0x40f
f0101ef9:	68 ff 48 10 f0       	push   $0xf01048ff
f0101efe:	e8 9d e1 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101f03:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f08:	74 19                	je     f0101f23 <mem_init+0xd0d>
f0101f0a:	68 27 4b 10 f0       	push   $0xf0104b27
f0101f0f:	68 25 49 10 f0       	push   $0xf0104925
f0101f14:	68 10 04 00 00       	push   $0x410
f0101f19:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101f38:	68 40 52 10 f0       	push   $0xf0105240
f0101f3d:	68 25 49 10 f0       	push   $0xf0104925
f0101f42:	68 13 04 00 00       	push   $0x413
f0101f47:	68 ff 48 10 f0       	push   $0xf01048ff
f0101f4c:	e8 4f e1 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref);
f0101f51:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f56:	75 19                	jne    f0101f71 <mem_init+0xd5b>
f0101f58:	68 38 4b 10 f0       	push   $0xf0104b38
f0101f5d:	68 25 49 10 f0       	push   $0xf0104925
f0101f62:	68 14 04 00 00       	push   $0x414
f0101f67:	68 ff 48 10 f0       	push   $0xf01048ff
f0101f6c:	e8 2f e1 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_link == NULL);
f0101f71:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101f74:	74 19                	je     f0101f8f <mem_init+0xd79>
f0101f76:	68 44 4b 10 f0       	push   $0xf0104b44
f0101f7b:	68 25 49 10 f0       	push   $0xf0104925
f0101f80:	68 15 04 00 00       	push   $0x415
f0101f85:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0101fbc:	68 1c 52 10 f0       	push   $0xf010521c
f0101fc1:	68 25 49 10 f0       	push   $0xf0104925
f0101fc6:	68 19 04 00 00       	push   $0x419
f0101fcb:	68 ff 48 10 f0       	push   $0xf01048ff
f0101fd0:	e8 cb e0 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101fd5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fda:	89 f8                	mov    %edi,%eax
f0101fdc:	e8 1d ea ff ff       	call   f01009fe <check_va2pa>
f0101fe1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fe4:	74 19                	je     f0101fff <mem_init+0xde9>
f0101fe6:	68 78 52 10 f0       	push   $0xf0105278
f0101feb:	68 25 49 10 f0       	push   $0xf0104925
f0101ff0:	68 1a 04 00 00       	push   $0x41a
f0101ff5:	68 ff 48 10 f0       	push   $0xf01048ff
f0101ffa:	e8 a1 e0 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0101fff:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102004:	74 19                	je     f010201f <mem_init+0xe09>
f0102006:	68 59 4b 10 f0       	push   $0xf0104b59
f010200b:	68 25 49 10 f0       	push   $0xf0104925
f0102010:	68 1b 04 00 00       	push   $0x41b
f0102015:	68 ff 48 10 f0       	push   $0xf01048ff
f010201a:	e8 81 e0 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f010201f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102024:	74 19                	je     f010203f <mem_init+0xe29>
f0102026:	68 27 4b 10 f0       	push   $0xf0104b27
f010202b:	68 25 49 10 f0       	push   $0xf0104925
f0102030:	68 1c 04 00 00       	push   $0x41c
f0102035:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0102054:	68 a0 52 10 f0       	push   $0xf01052a0
f0102059:	68 25 49 10 f0       	push   $0xf0104925
f010205e:	68 1f 04 00 00       	push   $0x41f
f0102063:	68 ff 48 10 f0       	push   $0xf01048ff
f0102068:	e8 33 e0 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010206d:	83 ec 0c             	sub    $0xc,%esp
f0102070:	6a 00                	push   $0x0
f0102072:	e8 2a ee ff ff       	call   f0100ea1 <page_alloc>
f0102077:	83 c4 10             	add    $0x10,%esp
f010207a:	85 c0                	test   %eax,%eax
f010207c:	74 19                	je     f0102097 <mem_init+0xe81>
f010207e:	68 7b 4a 10 f0       	push   $0xf0104a7b
f0102083:	68 25 49 10 f0       	push   $0xf0104925
f0102088:	68 22 04 00 00       	push   $0x422
f010208d:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01020b8:	68 44 4f 10 f0       	push   $0xf0104f44
f01020bd:	68 25 49 10 f0       	push   $0xf0104925
f01020c2:	68 25 04 00 00       	push   $0x425
f01020c7:	68 ff 48 10 f0       	push   $0xf01048ff
f01020cc:	e8 cf df ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f01020d1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01020d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020da:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01020df:	74 19                	je     f01020fa <mem_init+0xee4>
f01020e1:	68 de 4a 10 f0       	push   $0xf0104ade
f01020e6:	68 25 49 10 f0       	push   $0xf0104925
f01020eb:	68 27 04 00 00       	push   $0x427
f01020f0:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0102149:	68 e4 4b 10 f0       	push   $0xf0104be4
f010214e:	68 2e 04 00 00       	push   $0x42e
f0102153:	68 ff 48 10 f0       	push   $0xf01048ff
f0102158:	e8 43 df ff ff       	call   f01000a0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010215d:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102162:	39 c7                	cmp    %eax,%edi
f0102164:	74 19                	je     f010217f <mem_init+0xf69>
f0102166:	68 6a 4b 10 f0       	push   $0xf0104b6a
f010216b:	68 25 49 10 f0       	push   $0xf0104925
f0102170:	68 2f 04 00 00       	push   $0x42f
f0102175:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01021a8:	68 e4 4b 10 f0       	push   $0xf0104be4
f01021ad:	6a 56                	push   $0x56
f01021af:	68 0b 49 10 f0       	push   $0xf010490b
f01021b4:	e8 e7 de ff ff       	call   f01000a0 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01021b9:	83 ec 04             	sub    $0x4,%esp
f01021bc:	68 00 10 00 00       	push   $0x1000
f01021c1:	68 ff 00 00 00       	push   $0xff
f01021c6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021cb:	50                   	push   %eax
f01021cc:	e8 28 1d 00 00       	call   f0103ef9 <memset>
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
f010220d:	68 e4 4b 10 f0       	push   $0xf0104be4
f0102212:	6a 56                	push   $0x56
f0102214:	68 0b 49 10 f0       	push   $0xf010490b
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
f0102232:	68 82 4b 10 f0       	push   $0xf0104b82
f0102237:	68 25 49 10 f0       	push   $0xf0104925
f010223c:	68 39 04 00 00       	push   $0x439
f0102241:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0102288:	c7 04 24 99 4b 10 f0 	movl   $0xf0104b99,(%esp)
f010228f:	e8 d0 0d 00 00       	call   f0103064 <cprintf>
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
f01022a4:	68 f0 4c 10 f0       	push   $0xf0104cf0
f01022a9:	68 c6 00 00 00       	push   $0xc6
f01022ae:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01022e7:	68 f0 4c 10 f0       	push   $0xf0104cf0
f01022ec:	68 d0 00 00 00       	push   $0xd0
f01022f1:	68 ff 48 10 f0       	push   $0xf01048ff
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
f010232a:	68 f0 4c 10 f0       	push   $0xf0104cf0
f010232f:	68 de 00 00 00       	push   $0xde
f0102334:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01023be:	68 f0 4c 10 f0       	push   $0xf0104cf0
f01023c3:	68 72 03 00 00       	push   $0x372
f01023c8:	68 ff 48 10 f0       	push   $0xf01048ff
f01023cd:	e8 ce dc ff ff       	call   f01000a0 <_panic>
f01023d2:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f01023d9:	39 d0                	cmp    %edx,%eax
f01023db:	74 19                	je     f01023f6 <mem_init+0x11e0>
f01023dd:	68 c4 52 10 f0       	push   $0xf01052c4
f01023e2:	68 25 49 10 f0       	push   $0xf0104925
f01023e7:	68 72 03 00 00       	push   $0x372
f01023ec:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0102422:	68 f0 4c 10 f0       	push   $0xf0104cf0
f0102427:	68 77 03 00 00       	push   $0x377
f010242c:	68 ff 48 10 f0       	push   $0xf01048ff
f0102431:	e8 6a dc ff ff       	call   f01000a0 <_panic>
f0102436:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f010243d:	39 c2                	cmp    %eax,%edx
f010243f:	74 19                	je     f010245a <mem_init+0x1244>
f0102441:	68 f8 52 10 f0       	push   $0xf01052f8
f0102446:	68 25 49 10 f0       	push   $0xf0104925
f010244b:	68 77 03 00 00       	push   $0x377
f0102450:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0102486:	68 2c 53 10 f0       	push   $0xf010532c
f010248b:	68 25 49 10 f0       	push   $0xf0104925
f0102490:	68 7b 03 00 00       	push   $0x37b
f0102495:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01024c1:	68 54 53 10 f0       	push   $0xf0105354
f01024c6:	68 25 49 10 f0       	push   $0xf0104925
f01024cb:	68 7f 03 00 00       	push   $0x37f
f01024d0:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01024f9:	68 9c 53 10 f0       	push   $0xf010539c
f01024fe:	68 25 49 10 f0       	push   $0xf0104925
f0102503:	68 80 03 00 00       	push   $0x380
f0102508:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0102531:	68 b2 4b 10 f0       	push   $0xf0104bb2
f0102536:	68 25 49 10 f0       	push   $0xf0104925
f010253b:	68 89 03 00 00       	push   $0x389
f0102540:	68 ff 48 10 f0       	push   $0xf01048ff
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
f010255e:	68 b2 4b 10 f0       	push   $0xf0104bb2
f0102563:	68 25 49 10 f0       	push   $0xf0104925
f0102568:	68 8d 03 00 00       	push   $0x38d
f010256d:	68 ff 48 10 f0       	push   $0xf01048ff
f0102572:	e8 29 db ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_W);
f0102577:	f6 c2 02             	test   $0x2,%dl
f010257a:	75 38                	jne    f01025b4 <mem_init+0x139e>
f010257c:	68 c3 4b 10 f0       	push   $0xf0104bc3
f0102581:	68 25 49 10 f0       	push   $0xf0104925
f0102586:	68 8e 03 00 00       	push   $0x38e
f010258b:	68 ff 48 10 f0       	push   $0xf01048ff
f0102590:	e8 0b db ff ff       	call   f01000a0 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102595:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102599:	74 19                	je     f01025b4 <mem_init+0x139e>
f010259b:	68 d4 4b 10 f0       	push   $0xf0104bd4
f01025a0:	68 25 49 10 f0       	push   $0xf0104925
f01025a5:	68 90 03 00 00       	push   $0x390
f01025aa:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01025c5:	68 cc 53 10 f0       	push   $0xf01053cc
f01025ca:	e8 95 0a 00 00       	call   f0103064 <cprintf>
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
f01025df:	68 f0 4c 10 f0       	push   $0xf0104cf0
f01025e4:	68 f5 00 00 00       	push   $0xf5
f01025e9:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0102626:	68 d0 49 10 f0       	push   $0xf01049d0
f010262b:	68 25 49 10 f0       	push   $0xf0104925
f0102630:	68 54 04 00 00       	push   $0x454
f0102635:	68 ff 48 10 f0       	push   $0xf01048ff
f010263a:	e8 61 da ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f010263f:	83 ec 0c             	sub    $0xc,%esp
f0102642:	6a 00                	push   $0x0
f0102644:	e8 58 e8 ff ff       	call   f0100ea1 <page_alloc>
f0102649:	89 c7                	mov    %eax,%edi
f010264b:	83 c4 10             	add    $0x10,%esp
f010264e:	85 c0                	test   %eax,%eax
f0102650:	75 19                	jne    f010266b <mem_init+0x1455>
f0102652:	68 e6 49 10 f0       	push   $0xf01049e6
f0102657:	68 25 49 10 f0       	push   $0xf0104925
f010265c:	68 55 04 00 00       	push   $0x455
f0102661:	68 ff 48 10 f0       	push   $0xf01048ff
f0102666:	e8 35 da ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f010266b:	83 ec 0c             	sub    $0xc,%esp
f010266e:	6a 00                	push   $0x0
f0102670:	e8 2c e8 ff ff       	call   f0100ea1 <page_alloc>
f0102675:	89 c6                	mov    %eax,%esi
f0102677:	83 c4 10             	add    $0x10,%esp
f010267a:	85 c0                	test   %eax,%eax
f010267c:	75 19                	jne    f0102697 <mem_init+0x1481>
f010267e:	68 fc 49 10 f0       	push   $0xf01049fc
f0102683:	68 25 49 10 f0       	push   $0xf0104925
f0102688:	68 56 04 00 00       	push   $0x456
f010268d:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01026bf:	68 e4 4b 10 f0       	push   $0xf0104be4
f01026c4:	6a 56                	push   $0x56
f01026c6:	68 0b 49 10 f0       	push   $0xf010490b
f01026cb:	e8 d0 d9 ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01026d0:	83 ec 04             	sub    $0x4,%esp
f01026d3:	68 00 10 00 00       	push   $0x1000
f01026d8:	6a 01                	push   $0x1
f01026da:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026df:	50                   	push   %eax
f01026e0:	e8 14 18 00 00       	call   f0103ef9 <memset>
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
f0102704:	68 e4 4b 10 f0       	push   $0xf0104be4
f0102709:	6a 56                	push   $0x56
f010270b:	68 0b 49 10 f0       	push   $0xf010490b
f0102710:	e8 8b d9 ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102715:	83 ec 04             	sub    $0x4,%esp
f0102718:	68 00 10 00 00       	push   $0x1000
f010271d:	6a 02                	push   $0x2
f010271f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102724:	50                   	push   %eax
f0102725:	e8 cf 17 00 00       	call   f0103ef9 <memset>
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
f0102747:	68 cd 4a 10 f0       	push   $0xf0104acd
f010274c:	68 25 49 10 f0       	push   $0xf0104925
f0102751:	68 5b 04 00 00       	push   $0x45b
f0102756:	68 ff 48 10 f0       	push   $0xf01048ff
f010275b:	e8 40 d9 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102760:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102767:	01 01 01 
f010276a:	74 19                	je     f0102785 <mem_init+0x156f>
f010276c:	68 ec 53 10 f0       	push   $0xf01053ec
f0102771:	68 25 49 10 f0       	push   $0xf0104925
f0102776:	68 5c 04 00 00       	push   $0x45c
f010277b:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01027a7:	68 10 54 10 f0       	push   $0xf0105410
f01027ac:	68 25 49 10 f0       	push   $0xf0104925
f01027b1:	68 5e 04 00 00       	push   $0x45e
f01027b6:	68 ff 48 10 f0       	push   $0xf01048ff
f01027bb:	e8 e0 d8 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01027c0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01027c5:	74 19                	je     f01027e0 <mem_init+0x15ca>
f01027c7:	68 ef 4a 10 f0       	push   $0xf0104aef
f01027cc:	68 25 49 10 f0       	push   $0xf0104925
f01027d1:	68 5f 04 00 00       	push   $0x45f
f01027d6:	68 ff 48 10 f0       	push   $0xf01048ff
f01027db:	e8 c0 d8 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f01027e0:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01027e5:	74 19                	je     f0102800 <mem_init+0x15ea>
f01027e7:	68 59 4b 10 f0       	push   $0xf0104b59
f01027ec:	68 25 49 10 f0       	push   $0xf0104925
f01027f1:	68 60 04 00 00       	push   $0x460
f01027f6:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0102826:	68 e4 4b 10 f0       	push   $0xf0104be4
f010282b:	6a 56                	push   $0x56
f010282d:	68 0b 49 10 f0       	push   $0xf010490b
f0102832:	e8 69 d8 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102837:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010283e:	03 03 03 
f0102841:	74 19                	je     f010285c <mem_init+0x1646>
f0102843:	68 34 54 10 f0       	push   $0xf0105434
f0102848:	68 25 49 10 f0       	push   $0xf0104925
f010284d:	68 62 04 00 00       	push   $0x462
f0102852:	68 ff 48 10 f0       	push   $0xf01048ff
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
f0102879:	68 27 4b 10 f0       	push   $0xf0104b27
f010287e:	68 25 49 10 f0       	push   $0xf0104925
f0102883:	68 64 04 00 00       	push   $0x464
f0102888:	68 ff 48 10 f0       	push   $0xf01048ff
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
f01028b2:	68 44 4f 10 f0       	push   $0xf0104f44
f01028b7:	68 25 49 10 f0       	push   $0xf0104925
f01028bc:	68 67 04 00 00       	push   $0x467
f01028c1:	68 ff 48 10 f0       	push   $0xf01048ff
f01028c6:	e8 d5 d7 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f01028cb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01028d1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01028d6:	74 19                	je     f01028f1 <mem_init+0x16db>
f01028d8:	68 de 4a 10 f0       	push   $0xf0104ade
f01028dd:	68 25 49 10 f0       	push   $0xf0104925
f01028e2:	68 69 04 00 00       	push   $0x469
f01028e7:	68 ff 48 10 f0       	push   $0xf01048ff
f01028ec:	e8 af d7 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f01028f1:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01028f7:	83 ec 0c             	sub    $0xc,%esp
f01028fa:	53                   	push   %ebx
f01028fb:	e8 12 e6 ff ff       	call   f0100f12 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102900:	c7 04 24 60 54 10 f0 	movl   $0xf0105460,(%esp)
f0102907:	e8 58 07 00 00       	call   f0103064 <cprintf>
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

f0102931 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102931:	55                   	push   %ebp
f0102932:	89 e5                	mov    %esp,%ebp
f0102934:	57                   	push   %edi
f0102935:	56                   	push   %esi
f0102936:	53                   	push   %ebx
f0102937:	83 ec 0c             	sub    $0xc,%esp
f010293a:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f010293c:	89 d3                	mov    %edx,%ebx
f010293e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102944:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010294b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0102951:	eb 56                	jmp    f01029a9 <region_alloc+0x78>

		struct PageInfo* pp = page_alloc(ALLOC_ZERO);
f0102953:	83 ec 0c             	sub    $0xc,%esp
f0102956:	6a 01                	push   $0x1
f0102958:	e8 44 e5 ff ff       	call   f0100ea1 <page_alloc>
		if (pp == 0) {
f010295d:	83 c4 10             	add    $0x10,%esp
f0102960:	85 c0                	test   %eax,%eax
f0102962:	75 17                	jne    f010297b <region_alloc+0x4a>
			panic("region_alloc: page_alloc return 0");
f0102964:	83 ec 04             	sub    $0x4,%esp
f0102967:	68 8c 54 10 f0       	push   $0xf010548c
f010296c:	68 1f 01 00 00       	push   $0x11f
f0102971:	68 af 55 10 f0       	push   $0xf01055af
f0102976:	e8 25 d7 ff ff       	call   f01000a0 <_panic>
		}

		int err = page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
f010297b:	6a 06                	push   $0x6
f010297d:	53                   	push   %ebx
f010297e:	50                   	push   %eax
f010297f:	ff 77 5c             	pushl  0x5c(%edi)
f0102982:	e8 08 e8 ff ff       	call   f010118f <page_insert>
		if (err < 0) {
f0102987:	83 c4 10             	add    $0x10,%esp
f010298a:	85 c0                	test   %eax,%eax
f010298c:	79 15                	jns    f01029a3 <region_alloc+0x72>
			panic("region_alloc: page_insert failed: %e", err);
f010298e:	50                   	push   %eax
f010298f:	68 b0 54 10 f0       	push   $0xf01054b0
f0102994:	68 24 01 00 00       	push   $0x124
f0102999:	68 af 55 10 f0       	push   $0xf01055af
f010299e:	e8 fd d6 ff ff       	call   f01000a0 <_panic>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	for (void* i=ROUNDDOWN(va, PGSIZE); i<ROUNDUP(va+len, PGSIZE); i += PGSIZE) {
f01029a3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029a9:	39 f3                	cmp    %esi,%ebx
f01029ab:	72 a6                	jb     f0102953 <region_alloc+0x22>
		}

	}

	
}
f01029ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01029b0:	5b                   	pop    %ebx
f01029b1:	5e                   	pop    %esi
f01029b2:	5f                   	pop    %edi
f01029b3:	5d                   	pop    %ebp
f01029b4:	c3                   	ret    

f01029b5 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01029b5:	55                   	push   %ebp
f01029b6:	89 e5                	mov    %esp,%ebp
f01029b8:	8b 55 08             	mov    0x8(%ebp),%edx
f01029bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01029be:	85 d2                	test   %edx,%edx
f01029c0:	75 11                	jne    f01029d3 <envid2env+0x1e>
		*env_store = curenv;
f01029c2:	a1 84 ff 16 f0       	mov    0xf016ff84,%eax
f01029c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01029ca:	89 01                	mov    %eax,(%ecx)
		return 0;
f01029cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01029d1:	eb 5e                	jmp    f0102a31 <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01029d3:	89 d0                	mov    %edx,%eax
f01029d5:	25 ff 03 00 00       	and    $0x3ff,%eax
f01029da:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01029dd:	c1 e0 05             	shl    $0x5,%eax
f01029e0:	03 05 88 ff 16 f0    	add    0xf016ff88,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01029e6:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f01029ea:	74 05                	je     f01029f1 <envid2env+0x3c>
f01029ec:	3b 50 48             	cmp    0x48(%eax),%edx
f01029ef:	74 10                	je     f0102a01 <envid2env+0x4c>
		*env_store = 0;
f01029f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01029fa:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01029ff:	eb 30                	jmp    f0102a31 <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102a01:	84 c9                	test   %cl,%cl
f0102a03:	74 22                	je     f0102a27 <envid2env+0x72>
f0102a05:	8b 15 84 ff 16 f0    	mov    0xf016ff84,%edx
f0102a0b:	39 d0                	cmp    %edx,%eax
f0102a0d:	74 18                	je     f0102a27 <envid2env+0x72>
f0102a0f:	8b 4a 48             	mov    0x48(%edx),%ecx
f0102a12:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f0102a15:	74 10                	je     f0102a27 <envid2env+0x72>
		*env_store = 0;
f0102a17:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102a20:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102a25:	eb 0a                	jmp    f0102a31 <envid2env+0x7c>
	}

	*env_store = e;
f0102a27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102a2a:	89 01                	mov    %eax,(%ecx)
	return 0;
f0102a2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102a31:	5d                   	pop    %ebp
f0102a32:	c3                   	ret    

f0102a33 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102a33:	55                   	push   %ebp
f0102a34:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102a36:	b8 00 a3 11 f0       	mov    $0xf011a300,%eax
f0102a3b:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102a3e:	b8 23 00 00 00       	mov    $0x23,%eax
f0102a43:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102a45:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102a47:	b8 10 00 00 00       	mov    $0x10,%eax
f0102a4c:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102a4e:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102a50:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102a52:	ea 59 2a 10 f0 08 00 	ljmp   $0x8,$0xf0102a59
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102a59:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a5e:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102a61:	5d                   	pop    %ebp
f0102a62:	c3                   	ret    

f0102a63 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102a63:	55                   	push   %ebp
f0102a64:	89 e5                	mov    %esp,%ebp
f0102a66:	56                   	push   %esi
f0102a67:	53                   	push   %ebx
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
		envs[i].env_id = 0;
f0102a68:	8b 35 88 ff 16 f0    	mov    0xf016ff88,%esi
f0102a6e:	8b 15 8c ff 16 f0    	mov    0xf016ff8c,%edx
f0102a74:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0102a7a:	8d 5e a0             	lea    -0x60(%esi),%ebx
f0102a7d:	89 c1                	mov    %eax,%ecx
f0102a7f:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102a86:	89 50 44             	mov    %edx,0x44(%eax)
f0102a89:	83 e8 60             	sub    $0x60,%eax
		env_free_list = &envs[i];
f0102a8c:	89 ca                	mov    %ecx,%edx
	// Set up envs array
	// LAB 3: Your code here.

	// make sure env_free_list point to envs[0]
	// so that the first env_alloc() will return envs[0]
	for (int i=NENV-1; i>=0; i--) {
f0102a8e:	39 d8                	cmp    %ebx,%eax
f0102a90:	75 eb                	jne    f0102a7d <env_init+0x1a>
f0102a92:	89 35 8c ff 16 f0    	mov    %esi,0xf016ff8c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0102a98:	e8 96 ff ff ff       	call   f0102a33 <env_init_percpu>
}
f0102a9d:	5b                   	pop    %ebx
f0102a9e:	5e                   	pop    %esi
f0102a9f:	5d                   	pop    %ebp
f0102aa0:	c3                   	ret    

f0102aa1 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102aa1:	55                   	push   %ebp
f0102aa2:	89 e5                	mov    %esp,%ebp
f0102aa4:	56                   	push   %esi
f0102aa5:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102aa6:	8b 1d 8c ff 16 f0    	mov    0xf016ff8c,%ebx
f0102aac:	85 db                	test   %ebx,%ebx
f0102aae:	0f 84 45 01 00 00    	je     f0102bf9 <env_alloc+0x158>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102ab4:	83 ec 0c             	sub    $0xc,%esp
f0102ab7:	6a 01                	push   $0x1
f0102ab9:	e8 e3 e3 ff ff       	call   f0100ea1 <page_alloc>
f0102abe:	89 c6                	mov    %eax,%esi
f0102ac0:	83 c4 10             	add    $0x10,%esp
f0102ac3:	85 c0                	test   %eax,%eax
f0102ac5:	0f 84 35 01 00 00    	je     f0102c00 <env_alloc+0x15f>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102acb:	2b 05 50 0c 17 f0    	sub    0xf0170c50,%eax
f0102ad1:	c1 f8 03             	sar    $0x3,%eax
f0102ad4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ad7:	89 c2                	mov    %eax,%edx
f0102ad9:	c1 ea 0c             	shr    $0xc,%edx
f0102adc:	3b 15 48 0c 17 f0    	cmp    0xf0170c48,%edx
f0102ae2:	72 12                	jb     f0102af6 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ae4:	50                   	push   %eax
f0102ae5:	68 e4 4b 10 f0       	push   $0xf0104be4
f0102aea:	6a 56                	push   $0x56
f0102aec:	68 0b 49 10 f0       	push   $0xf010490b
f0102af1:	e8 aa d5 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0102af6:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	e->env_pgdir = page2kva(p);
f0102afb:	89 43 5c             	mov    %eax,0x5c(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102afe:	83 ec 04             	sub    $0x4,%esp
f0102b01:	68 00 10 00 00       	push   $0x1000
f0102b06:	ff 35 4c 0c 17 f0    	pushl  0xf0170c4c
f0102b0c:	50                   	push   %eax
f0102b0d:	e8 9c 14 00 00       	call   f0103fae <memcpy>
	p->pp_ref++;
f0102b12:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102b17:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b1a:	83 c4 10             	add    $0x10,%esp
f0102b1d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b22:	77 15                	ja     f0102b39 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b24:	50                   	push   %eax
f0102b25:	68 f0 4c 10 f0       	push   $0xf0104cf0
f0102b2a:	68 c5 00 00 00       	push   $0xc5
f0102b2f:	68 af 55 10 f0       	push   $0xf01055af
f0102b34:	e8 67 d5 ff ff       	call   f01000a0 <_panic>
f0102b39:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102b3f:	83 ca 05             	or     $0x5,%edx
f0102b42:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102b48:	8b 43 48             	mov    0x48(%ebx),%eax
f0102b4b:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102b50:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102b55:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b5a:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102b5d:	89 da                	mov    %ebx,%edx
f0102b5f:	2b 15 88 ff 16 f0    	sub    0xf016ff88,%edx
f0102b65:	c1 fa 05             	sar    $0x5,%edx
f0102b68:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102b6e:	09 d0                	or     %edx,%eax
f0102b70:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102b73:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b76:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102b79:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102b80:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102b87:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102b8e:	83 ec 04             	sub    $0x4,%esp
f0102b91:	6a 44                	push   $0x44
f0102b93:	6a 00                	push   $0x0
f0102b95:	53                   	push   %ebx
f0102b96:	e8 5e 13 00 00       	call   f0103ef9 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102b9b:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102ba1:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102ba7:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102bad:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102bb4:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102bba:	8b 43 44             	mov    0x44(%ebx),%eax
f0102bbd:	a3 8c ff 16 f0       	mov    %eax,0xf016ff8c
	*newenv_store = e;
f0102bc2:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bc5:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102bc7:	8b 53 48             	mov    0x48(%ebx),%edx
f0102bca:	a1 84 ff 16 f0       	mov    0xf016ff84,%eax
f0102bcf:	83 c4 10             	add    $0x10,%esp
f0102bd2:	85 c0                	test   %eax,%eax
f0102bd4:	74 05                	je     f0102bdb <env_alloc+0x13a>
f0102bd6:	8b 40 48             	mov    0x48(%eax),%eax
f0102bd9:	eb 05                	jmp    f0102be0 <env_alloc+0x13f>
f0102bdb:	b8 00 00 00 00       	mov    $0x0,%eax
f0102be0:	83 ec 04             	sub    $0x4,%esp
f0102be3:	52                   	push   %edx
f0102be4:	50                   	push   %eax
f0102be5:	68 ba 55 10 f0       	push   $0xf01055ba
f0102bea:	e8 75 04 00 00       	call   f0103064 <cprintf>
	return 0;
f0102bef:	83 c4 10             	add    $0x10,%esp
f0102bf2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bf7:	eb 0c                	jmp    f0102c05 <env_alloc+0x164>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102bf9:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102bfe:	eb 05                	jmp    f0102c05 <env_alloc+0x164>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102c00:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102c05:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102c08:	5b                   	pop    %ebx
f0102c09:	5e                   	pop    %esi
f0102c0a:	5d                   	pop    %ebp
f0102c0b:	c3                   	ret    

f0102c0c <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102c0c:	55                   	push   %ebp
f0102c0d:	89 e5                	mov    %esp,%ebp
f0102c0f:	57                   	push   %edi
f0102c10:	56                   	push   %esi
f0102c11:	53                   	push   %ebx
f0102c12:	83 ec 34             	sub    $0x34,%esp
f0102c15:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.

	struct Env *newenv_store;
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
f0102c18:	6a 00                	push   $0x0
f0102c1a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102c1d:	50                   	push   %eax
f0102c1e:	e8 7e fe ff ff       	call   f0102aa1 <env_alloc>
	if (err < 0) 
f0102c23:	83 c4 10             	add    $0x10,%esp
f0102c26:	85 c0                	test   %eax,%eax
f0102c28:	79 15                	jns    f0102c3f <env_create+0x33>
		panic("env_create: env_alloc failed: %e", err);
f0102c2a:	50                   	push   %eax
f0102c2b:	68 d8 54 10 f0       	push   $0xf01054d8
f0102c30:	68 aa 01 00 00       	push   $0x1aa
f0102c35:	68 af 55 10 f0       	push   $0xf01055af
f0102c3a:	e8 61 d4 ff ff       	call   f01000a0 <_panic>
	load_icode(newenv_store, binary);
f0102c3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102c42:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.

	// read and check ELF property, inspired by boot/main.c
	struct Elf* elf = (struct Elf*) binary;

	if (elf->e_magic != ELF_MAGIC)
f0102c45:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102c4b:	74 17                	je     f0102c64 <env_create+0x58>
		panic("load_icode: not a valid ELF format file");
f0102c4d:	83 ec 04             	sub    $0x4,%esp
f0102c50:	68 fc 54 10 f0       	push   $0xf01054fc
f0102c55:	68 67 01 00 00       	push   $0x167
f0102c5a:	68 af 55 10 f0       	push   $0xf01055af
f0102c5f:	e8 3c d4 ff ff       	call   f01000a0 <_panic>

	struct Proghdr *ph, *eph;
	
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0102c64:	89 fb                	mov    %edi,%ebx
f0102c66:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f0102c69:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102c6d:	c1 e6 05             	shl    $0x5,%esi
f0102c70:	01 de                	add    %ebx,%esi

	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	
f0102c72:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c75:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c78:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c7d:	77 15                	ja     f0102c94 <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c7f:	50                   	push   %eax
f0102c80:	68 f0 4c 10 f0       	push   $0xf0104cf0
f0102c85:	68 70 01 00 00       	push   $0x170
f0102c8a:	68 af 55 10 f0       	push   $0xf01055af
f0102c8f:	e8 0c d4 ff ff       	call   f01000a0 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102c94:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c99:	0f 22 d8             	mov    %eax,%cr3
f0102c9c:	eb 6c                	jmp    f0102d0a <env_create+0xfe>

	// for every segment
	for (; ph < eph; ph++) {

		// only load this type of segment
		if (ph->p_type == ELF_PROG_LOAD) {
f0102c9e:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102ca1:	75 64                	jne    f0102d07 <env_create+0xfb>

			if (ph->p_filesz > ph->p_memsz)
f0102ca3:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102ca6:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0102ca9:	76 17                	jbe    f0102cc2 <env_create+0xb6>
				panic("load_icode: not a valid ELF format file (2)");
f0102cab:	83 ec 04             	sub    $0x4,%esp
f0102cae:	68 24 55 10 f0       	push   $0xf0105524
f0102cb3:	68 79 01 00 00       	push   $0x179
f0102cb8:	68 af 55 10 f0       	push   $0xf01055af
f0102cbd:	e8 de d3 ff ff       	call   f01000a0 <_panic>

			// allocate and map each segment
			// this function needs e->env_pgdir
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102cc2:	8b 53 08             	mov    0x8(%ebx),%edx
f0102cc5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cc8:	e8 64 fc ff ff       	call   f0102931 <region_alloc>

			// all clear to 0
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0102ccd:	83 ec 04             	sub    $0x4,%esp
f0102cd0:	ff 73 14             	pushl  0x14(%ebx)
f0102cd3:	6a 00                	push   $0x0
f0102cd5:	ff 73 08             	pushl  0x8(%ebx)
f0102cd8:	e8 1c 12 00 00       	call   f0103ef9 <memset>

			// copy [binary + ph->p_offset, binary + ph->p_offset + ph->p_filesz) to ph->p_va
			// binary is of type uint8_t *
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0102cdd:	83 c4 0c             	add    $0xc,%esp
f0102ce0:	ff 73 10             	pushl  0x10(%ebx)
f0102ce3:	89 f8                	mov    %edi,%eax
f0102ce5:	03 43 04             	add    0x4(%ebx),%eax
f0102ce8:	50                   	push   %eax
f0102ce9:	ff 73 08             	pushl  0x8(%ebx)
f0102cec:	e8 bd 12 00 00       	call   f0103fae <memcpy>
			cprintf("[?] copy 0x%x bytes at %x\n", ph->p_filesz, ph->p_va);
f0102cf1:	83 c4 0c             	add    $0xc,%esp
f0102cf4:	ff 73 08             	pushl  0x8(%ebx)
f0102cf7:	ff 73 10             	pushl  0x10(%ebx)
f0102cfa:	68 cf 55 10 f0       	push   $0xf01055cf
f0102cff:	e8 60 03 00 00       	call   f0103064 <cprintf>
f0102d04:	83 c4 10             	add    $0x10,%esp
	// we are setting user virtual address, but now we are in kernel mode
	// load env pgdir to cr3
	lcr3(PADDR(e->env_pgdir));	

	// for every segment
	for (; ph < eph; ph++) {
f0102d07:	83 c3 20             	add    $0x20,%ebx
f0102d0a:	39 de                	cmp    %ebx,%esi
f0102d0c:	77 90                	ja     f0102c9e <env_create+0x92>
		}

	}

	// load program entry point to eip
	e->env_tf.tf_eip = elf->e_entry;
f0102d0e:	8b 47 18             	mov    0x18(%edi),%eax
f0102d11:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102d14:	89 47 30             	mov    %eax,0x30(%edi)
	cprintf("[?] load entry point: %x\n", e->env_tf.tf_eip);
f0102d17:	83 ec 08             	sub    $0x8,%esp
f0102d1a:	50                   	push   %eax
f0102d1b:	68 ea 55 10 f0       	push   $0xf01055ea
f0102d20:	e8 3f 03 00 00       	call   f0103064 <cprintf>
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.

	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0102d25:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102d2a:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102d2f:	89 f8                	mov    %edi,%eax
f0102d31:	e8 fb fb ff ff       	call   f0102931 <region_alloc>

	// after loading things from elf, restore cr3 in kernel
	lcr3(PADDR(kern_pgdir));
f0102d36:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d3b:	83 c4 10             	add    $0x10,%esp
f0102d3e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d43:	77 15                	ja     f0102d5a <env_create+0x14e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d45:	50                   	push   %eax
f0102d46:	68 f0 4c 10 f0       	push   $0xf0104cf0
f0102d4b:	68 96 01 00 00       	push   $0x196
f0102d50:	68 af 55 10 f0       	push   $0xf01055af
f0102d55:	e8 46 d3 ff ff       	call   f01000a0 <_panic>
f0102d5a:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d5f:	0f 22 d8             	mov    %eax,%cr3
	envid_t parent_id = 0;
	int err = env_alloc(&newenv_store, 0);
	if (err < 0) 
		panic("env_create: env_alloc failed: %e", err);
	load_icode(newenv_store, binary);
	newenv_store->env_type = type;
f0102d62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d65:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102d68:	89 50 50             	mov    %edx,0x50(%eax)

}
f0102d6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d6e:	5b                   	pop    %ebx
f0102d6f:	5e                   	pop    %esi
f0102d70:	5f                   	pop    %edi
f0102d71:	5d                   	pop    %ebp
f0102d72:	c3                   	ret    

f0102d73 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102d73:	55                   	push   %ebp
f0102d74:	89 e5                	mov    %esp,%ebp
f0102d76:	57                   	push   %edi
f0102d77:	56                   	push   %esi
f0102d78:	53                   	push   %ebx
f0102d79:	83 ec 1c             	sub    $0x1c,%esp
f0102d7c:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102d7f:	8b 15 84 ff 16 f0    	mov    0xf016ff84,%edx
f0102d85:	39 fa                	cmp    %edi,%edx
f0102d87:	75 29                	jne    f0102db2 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102d89:	a1 4c 0c 17 f0       	mov    0xf0170c4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d8e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d93:	77 15                	ja     f0102daa <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d95:	50                   	push   %eax
f0102d96:	68 f0 4c 10 f0       	push   $0xf0104cf0
f0102d9b:	68 be 01 00 00       	push   $0x1be
f0102da0:	68 af 55 10 f0       	push   $0xf01055af
f0102da5:	e8 f6 d2 ff ff       	call   f01000a0 <_panic>
f0102daa:	05 00 00 00 10       	add    $0x10000000,%eax
f0102daf:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102db2:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102db5:	85 d2                	test   %edx,%edx
f0102db7:	74 05                	je     f0102dbe <env_free+0x4b>
f0102db9:	8b 42 48             	mov    0x48(%edx),%eax
f0102dbc:	eb 05                	jmp    f0102dc3 <env_free+0x50>
f0102dbe:	b8 00 00 00 00       	mov    $0x0,%eax
f0102dc3:	83 ec 04             	sub    $0x4,%esp
f0102dc6:	51                   	push   %ecx
f0102dc7:	50                   	push   %eax
f0102dc8:	68 04 56 10 f0       	push   $0xf0105604
f0102dcd:	e8 92 02 00 00       	call   f0103064 <cprintf>
f0102dd2:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102dd5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102ddc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102ddf:	89 d0                	mov    %edx,%eax
f0102de1:	c1 e0 02             	shl    $0x2,%eax
f0102de4:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102de7:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102dea:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102ded:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102df3:	0f 84 a8 00 00 00    	je     f0102ea1 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102df9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dff:	89 f0                	mov    %esi,%eax
f0102e01:	c1 e8 0c             	shr    $0xc,%eax
f0102e04:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e07:	39 05 48 0c 17 f0    	cmp    %eax,0xf0170c48
f0102e0d:	77 15                	ja     f0102e24 <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e0f:	56                   	push   %esi
f0102e10:	68 e4 4b 10 f0       	push   $0xf0104be4
f0102e15:	68 cd 01 00 00       	push   $0x1cd
f0102e1a:	68 af 55 10 f0       	push   $0xf01055af
f0102e1f:	e8 7c d2 ff ff       	call   f01000a0 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102e24:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e27:	c1 e0 16             	shl    $0x16,%eax
f0102e2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102e2d:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102e32:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102e39:	01 
f0102e3a:	74 17                	je     f0102e53 <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102e3c:	83 ec 08             	sub    $0x8,%esp
f0102e3f:	89 d8                	mov    %ebx,%eax
f0102e41:	c1 e0 0c             	shl    $0xc,%eax
f0102e44:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102e47:	50                   	push   %eax
f0102e48:	ff 77 5c             	pushl  0x5c(%edi)
f0102e4b:	e8 fd e2 ff ff       	call   f010114d <page_remove>
f0102e50:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102e53:	83 c3 01             	add    $0x1,%ebx
f0102e56:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102e5c:	75 d4                	jne    f0102e32 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102e5e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e61:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e64:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e6b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e6e:	3b 05 48 0c 17 f0    	cmp    0xf0170c48,%eax
f0102e74:	72 14                	jb     f0102e8a <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102e76:	83 ec 04             	sub    $0x4,%esp
f0102e79:	68 10 4e 10 f0       	push   $0xf0104e10
f0102e7e:	6a 4f                	push   $0x4f
f0102e80:	68 0b 49 10 f0       	push   $0xf010490b
f0102e85:	e8 16 d2 ff ff       	call   f01000a0 <_panic>
		page_decref(pa2page(pa));
f0102e8a:	83 ec 0c             	sub    $0xc,%esp
f0102e8d:	a1 50 0c 17 f0       	mov    0xf0170c50,%eax
f0102e92:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102e95:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102e98:	50                   	push   %eax
f0102e99:	e8 ca e0 ff ff       	call   f0100f68 <page_decref>
f0102e9e:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102ea1:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102ea5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ea8:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102ead:	0f 85 29 ff ff ff    	jne    f0102ddc <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102eb3:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102eb6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ebb:	77 15                	ja     f0102ed2 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ebd:	50                   	push   %eax
f0102ebe:	68 f0 4c 10 f0       	push   $0xf0104cf0
f0102ec3:	68 db 01 00 00       	push   $0x1db
f0102ec8:	68 af 55 10 f0       	push   $0xf01055af
f0102ecd:	e8 ce d1 ff ff       	call   f01000a0 <_panic>
	e->env_pgdir = 0;
f0102ed2:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ed9:	05 00 00 00 10       	add    $0x10000000,%eax
f0102ede:	c1 e8 0c             	shr    $0xc,%eax
f0102ee1:	3b 05 48 0c 17 f0    	cmp    0xf0170c48,%eax
f0102ee7:	72 14                	jb     f0102efd <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102ee9:	83 ec 04             	sub    $0x4,%esp
f0102eec:	68 10 4e 10 f0       	push   $0xf0104e10
f0102ef1:	6a 4f                	push   $0x4f
f0102ef3:	68 0b 49 10 f0       	push   $0xf010490b
f0102ef8:	e8 a3 d1 ff ff       	call   f01000a0 <_panic>
	page_decref(pa2page(pa));
f0102efd:	83 ec 0c             	sub    $0xc,%esp
f0102f00:	8b 15 50 0c 17 f0    	mov    0xf0170c50,%edx
f0102f06:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102f09:	50                   	push   %eax
f0102f0a:	e8 59 e0 ff ff       	call   f0100f68 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102f0f:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102f16:	a1 8c ff 16 f0       	mov    0xf016ff8c,%eax
f0102f1b:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102f1e:	89 3d 8c ff 16 f0    	mov    %edi,0xf016ff8c
}
f0102f24:	83 c4 10             	add    $0x10,%esp
f0102f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f2a:	5b                   	pop    %ebx
f0102f2b:	5e                   	pop    %esi
f0102f2c:	5f                   	pop    %edi
f0102f2d:	5d                   	pop    %ebp
f0102f2e:	c3                   	ret    

f0102f2f <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102f2f:	55                   	push   %ebp
f0102f30:	89 e5                	mov    %esp,%ebp
f0102f32:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102f35:	ff 75 08             	pushl  0x8(%ebp)
f0102f38:	e8 36 fe ff ff       	call   f0102d73 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102f3d:	c7 04 24 50 55 10 f0 	movl   $0xf0105550,(%esp)
f0102f44:	e8 1b 01 00 00       	call   f0103064 <cprintf>
f0102f49:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102f4c:	83 ec 0c             	sub    $0xc,%esp
f0102f4f:	6a 00                	push   $0x0
f0102f51:	e8 e4 d8 ff ff       	call   f010083a <monitor>
f0102f56:	83 c4 10             	add    $0x10,%esp
f0102f59:	eb f1                	jmp    f0102f4c <env_destroy+0x1d>

f0102f5b <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102f5b:	55                   	push   %ebp
f0102f5c:	89 e5                	mov    %esp,%ebp
f0102f5e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile(
f0102f61:	8b 65 08             	mov    0x8(%ebp),%esp
f0102f64:	61                   	popa   
f0102f65:	07                   	pop    %es
f0102f66:	1f                   	pop    %ds
f0102f67:	83 c4 08             	add    $0x8,%esp
f0102f6a:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102f6b:	68 1a 56 10 f0       	push   $0xf010561a
f0102f70:	68 04 02 00 00       	push   $0x204
f0102f75:	68 af 55 10 f0       	push   $0xf01055af
f0102f7a:	e8 21 d1 ff ff       	call   f01000a0 <_panic>

f0102f7f <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102f7f:	55                   	push   %ebp
f0102f80:	89 e5                	mov    %esp,%ebp
f0102f82:	83 ec 08             	sub    $0x8,%esp
f0102f85:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	// context switch
	if (curenv != e) {
f0102f88:	8b 15 84 ff 16 f0    	mov    0xf016ff84,%edx
f0102f8e:	39 c2                	cmp    %eax,%edx
f0102f90:	74 48                	je     f0102fda <env_run+0x5b>

		if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0102f92:	85 d2                	test   %edx,%edx
f0102f94:	74 0d                	je     f0102fa3 <env_run+0x24>
f0102f96:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0102f9a:	75 07                	jne    f0102fa3 <env_run+0x24>
			curenv->env_status = ENV_RUNNABLE;
f0102f9c:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
		
		curenv = e;
f0102fa3:	a3 84 ff 16 f0       	mov    %eax,0xf016ff84
		curenv->env_status = ENV_RUNNING;
f0102fa8:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0102faf:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f0102fb3:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fb6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fbb:	77 15                	ja     f0102fd2 <env_run+0x53>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fbd:	50                   	push   %eax
f0102fbe:	68 f0 4c 10 f0       	push   $0xf0104cf0
f0102fc3:	68 2c 02 00 00       	push   $0x22c
f0102fc8:	68 af 55 10 f0       	push   $0xf01055af
f0102fcd:	e8 ce d0 ff ff       	call   f01000a0 <_panic>
f0102fd2:	05 00 00 00 10       	add    $0x10000000,%eax
f0102fd7:	0f 22 d8             	mov    %eax,%cr3
	}

	// iret to execute entry point stored in tf_eip
	cprintf("[?] try to execute at entry point: %x\n", curenv->env_tf.tf_eip);
f0102fda:	83 ec 08             	sub    $0x8,%esp
f0102fdd:	a1 84 ff 16 f0       	mov    0xf016ff84,%eax
f0102fe2:	ff 70 30             	pushl  0x30(%eax)
f0102fe5:	68 88 55 10 f0       	push   $0xf0105588
f0102fea:	e8 75 00 00 00       	call   f0103064 <cprintf>
	env_pop_tf(&curenv->env_tf);
f0102fef:	83 c4 04             	add    $0x4,%esp
f0102ff2:	ff 35 84 ff 16 f0    	pushl  0xf016ff84
f0102ff8:	e8 5e ff ff ff       	call   f0102f5b <env_pop_tf>

f0102ffd <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102ffd:	55                   	push   %ebp
f0102ffe:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103000:	ba 70 00 00 00       	mov    $0x70,%edx
f0103005:	8b 45 08             	mov    0x8(%ebp),%eax
f0103008:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103009:	ba 71 00 00 00       	mov    $0x71,%edx
f010300e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010300f:	0f b6 c0             	movzbl %al,%eax
}
f0103012:	5d                   	pop    %ebp
f0103013:	c3                   	ret    

f0103014 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103014:	55                   	push   %ebp
f0103015:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103017:	ba 70 00 00 00       	mov    $0x70,%edx
f010301c:	8b 45 08             	mov    0x8(%ebp),%eax
f010301f:	ee                   	out    %al,(%dx)
f0103020:	ba 71 00 00 00       	mov    $0x71,%edx
f0103025:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103028:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103029:	5d                   	pop    %ebp
f010302a:	c3                   	ret    

f010302b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010302b:	55                   	push   %ebp
f010302c:	89 e5                	mov    %esp,%ebp
f010302e:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103031:	ff 75 08             	pushl  0x8(%ebp)
f0103034:	e8 dc d5 ff ff       	call   f0100615 <cputchar>
	*cnt++;
}
f0103039:	83 c4 10             	add    $0x10,%esp
f010303c:	c9                   	leave  
f010303d:	c3                   	ret    

f010303e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010303e:	55                   	push   %ebp
f010303f:	89 e5                	mov    %esp,%ebp
f0103041:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103044:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010304b:	ff 75 0c             	pushl  0xc(%ebp)
f010304e:	ff 75 08             	pushl  0x8(%ebp)
f0103051:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103054:	50                   	push   %eax
f0103055:	68 2b 30 10 f0       	push   $0xf010302b
f010305a:	e8 2e 08 00 00       	call   f010388d <vprintfmt>
	return cnt;
}
f010305f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103062:	c9                   	leave  
f0103063:	c3                   	ret    

f0103064 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103064:	55                   	push   %ebp
f0103065:	89 e5                	mov    %esp,%ebp
f0103067:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010306a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010306d:	50                   	push   %eax
f010306e:	ff 75 08             	pushl  0x8(%ebp)
f0103071:	e8 c8 ff ff ff       	call   f010303e <vcprintf>
	va_end(ap);

	return cnt;
}
f0103076:	c9                   	leave  
f0103077:	c3                   	ret    

f0103078 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103078:	55                   	push   %ebp
f0103079:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f010307b:	b8 c0 07 17 f0       	mov    $0xf01707c0,%eax
f0103080:	c7 05 c4 07 17 f0 00 	movl   $0xf0000000,0xf01707c4
f0103087:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010308a:	66 c7 05 c8 07 17 f0 	movw   $0x10,0xf01707c8
f0103091:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103093:	66 c7 05 26 08 17 f0 	movw   $0x68,0xf0170826
f010309a:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010309c:	66 c7 05 48 a3 11 f0 	movw   $0x67,0xf011a348
f01030a3:	67 00 
f01030a5:	66 a3 4a a3 11 f0    	mov    %ax,0xf011a34a
f01030ab:	89 c2                	mov    %eax,%edx
f01030ad:	c1 ea 10             	shr    $0x10,%edx
f01030b0:	88 15 4c a3 11 f0    	mov    %dl,0xf011a34c
f01030b6:	c6 05 4e a3 11 f0 40 	movb   $0x40,0xf011a34e
f01030bd:	c1 e8 18             	shr    $0x18,%eax
f01030c0:	a2 4f a3 11 f0       	mov    %al,0xf011a34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01030c5:	c6 05 4d a3 11 f0 89 	movb   $0x89,0xf011a34d
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f01030cc:	b8 28 00 00 00       	mov    $0x28,%eax
f01030d1:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f01030d4:	b8 50 a3 11 f0       	mov    $0xf011a350,%eax
f01030d9:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01030dc:	5d                   	pop    %ebp
f01030dd:	c3                   	ret    

f01030de <trap_init>:
}


void
trap_init(void)
{
f01030de:	55                   	push   %ebp
f01030df:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f01030e1:	e8 92 ff ff ff       	call   f0103078 <trap_init_percpu>
}
f01030e6:	5d                   	pop    %ebp
f01030e7:	c3                   	ret    

f01030e8 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01030e8:	55                   	push   %ebp
f01030e9:	89 e5                	mov    %esp,%ebp
f01030eb:	53                   	push   %ebx
f01030ec:	83 ec 0c             	sub    $0xc,%esp
f01030ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01030f2:	ff 33                	pushl  (%ebx)
f01030f4:	68 26 56 10 f0       	push   $0xf0105626
f01030f9:	e8 66 ff ff ff       	call   f0103064 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01030fe:	83 c4 08             	add    $0x8,%esp
f0103101:	ff 73 04             	pushl  0x4(%ebx)
f0103104:	68 35 56 10 f0       	push   $0xf0105635
f0103109:	e8 56 ff ff ff       	call   f0103064 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010310e:	83 c4 08             	add    $0x8,%esp
f0103111:	ff 73 08             	pushl  0x8(%ebx)
f0103114:	68 44 56 10 f0       	push   $0xf0105644
f0103119:	e8 46 ff ff ff       	call   f0103064 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010311e:	83 c4 08             	add    $0x8,%esp
f0103121:	ff 73 0c             	pushl  0xc(%ebx)
f0103124:	68 53 56 10 f0       	push   $0xf0105653
f0103129:	e8 36 ff ff ff       	call   f0103064 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010312e:	83 c4 08             	add    $0x8,%esp
f0103131:	ff 73 10             	pushl  0x10(%ebx)
f0103134:	68 62 56 10 f0       	push   $0xf0105662
f0103139:	e8 26 ff ff ff       	call   f0103064 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010313e:	83 c4 08             	add    $0x8,%esp
f0103141:	ff 73 14             	pushl  0x14(%ebx)
f0103144:	68 71 56 10 f0       	push   $0xf0105671
f0103149:	e8 16 ff ff ff       	call   f0103064 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010314e:	83 c4 08             	add    $0x8,%esp
f0103151:	ff 73 18             	pushl  0x18(%ebx)
f0103154:	68 80 56 10 f0       	push   $0xf0105680
f0103159:	e8 06 ff ff ff       	call   f0103064 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010315e:	83 c4 08             	add    $0x8,%esp
f0103161:	ff 73 1c             	pushl  0x1c(%ebx)
f0103164:	68 8f 56 10 f0       	push   $0xf010568f
f0103169:	e8 f6 fe ff ff       	call   f0103064 <cprintf>
}
f010316e:	83 c4 10             	add    $0x10,%esp
f0103171:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103174:	c9                   	leave  
f0103175:	c3                   	ret    

f0103176 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103176:	55                   	push   %ebp
f0103177:	89 e5                	mov    %esp,%ebp
f0103179:	56                   	push   %esi
f010317a:	53                   	push   %ebx
f010317b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f010317e:	83 ec 08             	sub    $0x8,%esp
f0103181:	53                   	push   %ebx
f0103182:	68 c5 57 10 f0       	push   $0xf01057c5
f0103187:	e8 d8 fe ff ff       	call   f0103064 <cprintf>
	print_regs(&tf->tf_regs);
f010318c:	89 1c 24             	mov    %ebx,(%esp)
f010318f:	e8 54 ff ff ff       	call   f01030e8 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103194:	83 c4 08             	add    $0x8,%esp
f0103197:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010319b:	50                   	push   %eax
f010319c:	68 e0 56 10 f0       	push   $0xf01056e0
f01031a1:	e8 be fe ff ff       	call   f0103064 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01031a6:	83 c4 08             	add    $0x8,%esp
f01031a9:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01031ad:	50                   	push   %eax
f01031ae:	68 f3 56 10 f0       	push   $0xf01056f3
f01031b3:	e8 ac fe ff ff       	call   f0103064 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01031b8:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f01031bb:	83 c4 10             	add    $0x10,%esp
f01031be:	83 f8 13             	cmp    $0x13,%eax
f01031c1:	77 09                	ja     f01031cc <print_trapframe+0x56>
		return excnames[trapno];
f01031c3:	8b 14 85 a0 59 10 f0 	mov    -0xfefa660(,%eax,4),%edx
f01031ca:	eb 10                	jmp    f01031dc <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f01031cc:	83 f8 30             	cmp    $0x30,%eax
f01031cf:	b9 aa 56 10 f0       	mov    $0xf01056aa,%ecx
f01031d4:	ba 9e 56 10 f0       	mov    $0xf010569e,%edx
f01031d9:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01031dc:	83 ec 04             	sub    $0x4,%esp
f01031df:	52                   	push   %edx
f01031e0:	50                   	push   %eax
f01031e1:	68 06 57 10 f0       	push   $0xf0105706
f01031e6:	e8 79 fe ff ff       	call   f0103064 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01031eb:	83 c4 10             	add    $0x10,%esp
f01031ee:	3b 1d a0 07 17 f0    	cmp    0xf01707a0,%ebx
f01031f4:	75 1a                	jne    f0103210 <print_trapframe+0x9a>
f01031f6:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01031fa:	75 14                	jne    f0103210 <print_trapframe+0x9a>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01031fc:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01031ff:	83 ec 08             	sub    $0x8,%esp
f0103202:	50                   	push   %eax
f0103203:	68 18 57 10 f0       	push   $0xf0105718
f0103208:	e8 57 fe ff ff       	call   f0103064 <cprintf>
f010320d:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103210:	83 ec 08             	sub    $0x8,%esp
f0103213:	ff 73 2c             	pushl  0x2c(%ebx)
f0103216:	68 27 57 10 f0       	push   $0xf0105727
f010321b:	e8 44 fe ff ff       	call   f0103064 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103220:	83 c4 10             	add    $0x10,%esp
f0103223:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103227:	75 49                	jne    f0103272 <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103229:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010322c:	89 c2                	mov    %eax,%edx
f010322e:	83 e2 01             	and    $0x1,%edx
f0103231:	ba c4 56 10 f0       	mov    $0xf01056c4,%edx
f0103236:	b9 b9 56 10 f0       	mov    $0xf01056b9,%ecx
f010323b:	0f 44 ca             	cmove  %edx,%ecx
f010323e:	89 c2                	mov    %eax,%edx
f0103240:	83 e2 02             	and    $0x2,%edx
f0103243:	ba d6 56 10 f0       	mov    $0xf01056d6,%edx
f0103248:	be d0 56 10 f0       	mov    $0xf01056d0,%esi
f010324d:	0f 45 d6             	cmovne %esi,%edx
f0103250:	83 e0 04             	and    $0x4,%eax
f0103253:	be f0 57 10 f0       	mov    $0xf01057f0,%esi
f0103258:	b8 db 56 10 f0       	mov    $0xf01056db,%eax
f010325d:	0f 44 c6             	cmove  %esi,%eax
f0103260:	51                   	push   %ecx
f0103261:	52                   	push   %edx
f0103262:	50                   	push   %eax
f0103263:	68 35 57 10 f0       	push   $0xf0105735
f0103268:	e8 f7 fd ff ff       	call   f0103064 <cprintf>
f010326d:	83 c4 10             	add    $0x10,%esp
f0103270:	eb 10                	jmp    f0103282 <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103272:	83 ec 0c             	sub    $0xc,%esp
f0103275:	68 b0 4b 10 f0       	push   $0xf0104bb0
f010327a:	e8 e5 fd ff ff       	call   f0103064 <cprintf>
f010327f:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103282:	83 ec 08             	sub    $0x8,%esp
f0103285:	ff 73 30             	pushl  0x30(%ebx)
f0103288:	68 44 57 10 f0       	push   $0xf0105744
f010328d:	e8 d2 fd ff ff       	call   f0103064 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103292:	83 c4 08             	add    $0x8,%esp
f0103295:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103299:	50                   	push   %eax
f010329a:	68 53 57 10 f0       	push   $0xf0105753
f010329f:	e8 c0 fd ff ff       	call   f0103064 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01032a4:	83 c4 08             	add    $0x8,%esp
f01032a7:	ff 73 38             	pushl  0x38(%ebx)
f01032aa:	68 66 57 10 f0       	push   $0xf0105766
f01032af:	e8 b0 fd ff ff       	call   f0103064 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01032b4:	83 c4 10             	add    $0x10,%esp
f01032b7:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01032bb:	74 25                	je     f01032e2 <print_trapframe+0x16c>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01032bd:	83 ec 08             	sub    $0x8,%esp
f01032c0:	ff 73 3c             	pushl  0x3c(%ebx)
f01032c3:	68 75 57 10 f0       	push   $0xf0105775
f01032c8:	e8 97 fd ff ff       	call   f0103064 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01032cd:	83 c4 08             	add    $0x8,%esp
f01032d0:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01032d4:	50                   	push   %eax
f01032d5:	68 84 57 10 f0       	push   $0xf0105784
f01032da:	e8 85 fd ff ff       	call   f0103064 <cprintf>
f01032df:	83 c4 10             	add    $0x10,%esp
	}
}
f01032e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01032e5:	5b                   	pop    %ebx
f01032e6:	5e                   	pop    %esi
f01032e7:	5d                   	pop    %ebp
f01032e8:	c3                   	ret    

f01032e9 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01032e9:	55                   	push   %ebp
f01032ea:	89 e5                	mov    %esp,%ebp
f01032ec:	57                   	push   %edi
f01032ed:	56                   	push   %esi
f01032ee:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01032f1:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01032f2:	9c                   	pushf  
f01032f3:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01032f4:	f6 c4 02             	test   $0x2,%ah
f01032f7:	74 19                	je     f0103312 <trap+0x29>
f01032f9:	68 97 57 10 f0       	push   $0xf0105797
f01032fe:	68 25 49 10 f0       	push   $0xf0104925
f0103303:	68 a8 00 00 00       	push   $0xa8
f0103308:	68 b0 57 10 f0       	push   $0xf01057b0
f010330d:	e8 8e cd ff ff       	call   f01000a0 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103312:	83 ec 08             	sub    $0x8,%esp
f0103315:	56                   	push   %esi
f0103316:	68 bc 57 10 f0       	push   $0xf01057bc
f010331b:	e8 44 fd ff ff       	call   f0103064 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103320:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103324:	83 e0 03             	and    $0x3,%eax
f0103327:	83 c4 10             	add    $0x10,%esp
f010332a:	66 83 f8 03          	cmp    $0x3,%ax
f010332e:	75 31                	jne    f0103361 <trap+0x78>
		// Trapped from user mode.
		assert(curenv);
f0103330:	a1 84 ff 16 f0       	mov    0xf016ff84,%eax
f0103335:	85 c0                	test   %eax,%eax
f0103337:	75 19                	jne    f0103352 <trap+0x69>
f0103339:	68 d7 57 10 f0       	push   $0xf01057d7
f010333e:	68 25 49 10 f0       	push   $0xf0104925
f0103343:	68 ae 00 00 00       	push   $0xae
f0103348:	68 b0 57 10 f0       	push   $0xf01057b0
f010334d:	e8 4e cd ff ff       	call   f01000a0 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103352:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103357:	89 c7                	mov    %eax,%edi
f0103359:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010335b:	8b 35 84 ff 16 f0    	mov    0xf016ff84,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103361:	89 35 a0 07 17 f0    	mov    %esi,0xf01707a0
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103367:	83 ec 0c             	sub    $0xc,%esp
f010336a:	56                   	push   %esi
f010336b:	e8 06 fe ff ff       	call   f0103176 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103370:	83 c4 10             	add    $0x10,%esp
f0103373:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103378:	75 17                	jne    f0103391 <trap+0xa8>
		panic("unhandled trap in kernel");
f010337a:	83 ec 04             	sub    $0x4,%esp
f010337d:	68 de 57 10 f0       	push   $0xf01057de
f0103382:	68 97 00 00 00       	push   $0x97
f0103387:	68 b0 57 10 f0       	push   $0xf01057b0
f010338c:	e8 0f cd ff ff       	call   f01000a0 <_panic>
	else {
		env_destroy(curenv);
f0103391:	83 ec 0c             	sub    $0xc,%esp
f0103394:	ff 35 84 ff 16 f0    	pushl  0xf016ff84
f010339a:	e8 90 fb ff ff       	call   f0102f2f <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010339f:	a1 84 ff 16 f0       	mov    0xf016ff84,%eax
f01033a4:	83 c4 10             	add    $0x10,%esp
f01033a7:	85 c0                	test   %eax,%eax
f01033a9:	74 06                	je     f01033b1 <trap+0xc8>
f01033ab:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01033af:	74 19                	je     f01033ca <trap+0xe1>
f01033b1:	68 3c 59 10 f0       	push   $0xf010593c
f01033b6:	68 25 49 10 f0       	push   $0xf0104925
f01033bb:	68 c0 00 00 00       	push   $0xc0
f01033c0:	68 b0 57 10 f0       	push   $0xf01057b0
f01033c5:	e8 d6 cc ff ff       	call   f01000a0 <_panic>
	env_run(curenv);
f01033ca:	83 ec 0c             	sub    $0xc,%esp
f01033cd:	50                   	push   %eax
f01033ce:	e8 ac fb ff ff       	call   f0102f7f <env_run>

f01033d3 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01033d3:	55                   	push   %ebp
f01033d4:	89 e5                	mov    %esp,%ebp
f01033d6:	53                   	push   %ebx
f01033d7:	83 ec 04             	sub    $0x4,%esp
f01033da:	8b 5d 08             	mov    0x8(%ebp),%ebx

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01033dd:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01033e0:	ff 73 30             	pushl  0x30(%ebx)
f01033e3:	50                   	push   %eax
f01033e4:	a1 84 ff 16 f0       	mov    0xf016ff84,%eax
f01033e9:	ff 70 48             	pushl  0x48(%eax)
f01033ec:	68 68 59 10 f0       	push   $0xf0105968
f01033f1:	e8 6e fc ff ff       	call   f0103064 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01033f6:	89 1c 24             	mov    %ebx,(%esp)
f01033f9:	e8 78 fd ff ff       	call   f0103176 <print_trapframe>
	env_destroy(curenv);
f01033fe:	83 c4 04             	add    $0x4,%esp
f0103401:	ff 35 84 ff 16 f0    	pushl  0xf016ff84
f0103407:	e8 23 fb ff ff       	call   f0102f2f <env_destroy>
}
f010340c:	83 c4 10             	add    $0x10,%esp
f010340f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103412:	c9                   	leave  
f0103413:	c3                   	ret    

f0103414 <syscall>:
f0103414:	55                   	push   %ebp
f0103415:	89 e5                	mov    %esp,%ebp
f0103417:	83 ec 0c             	sub    $0xc,%esp
f010341a:	68 f0 59 10 f0       	push   $0xf01059f0
f010341f:	6a 49                	push   $0x49
f0103421:	68 08 5a 10 f0       	push   $0xf0105a08
f0103426:	e8 75 cc ff ff       	call   f01000a0 <_panic>

f010342b <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010342b:	55                   	push   %ebp
f010342c:	89 e5                	mov    %esp,%ebp
f010342e:	57                   	push   %edi
f010342f:	56                   	push   %esi
f0103430:	53                   	push   %ebx
f0103431:	83 ec 14             	sub    $0x14,%esp
f0103434:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103437:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010343a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010343d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103440:	8b 1a                	mov    (%edx),%ebx
f0103442:	8b 01                	mov    (%ecx),%eax
f0103444:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103447:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010344e:	eb 7f                	jmp    f01034cf <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0103450:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103453:	01 d8                	add    %ebx,%eax
f0103455:	89 c6                	mov    %eax,%esi
f0103457:	c1 ee 1f             	shr    $0x1f,%esi
f010345a:	01 c6                	add    %eax,%esi
f010345c:	d1 fe                	sar    %esi
f010345e:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103461:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103464:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0103467:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103469:	eb 03                	jmp    f010346e <stab_binsearch+0x43>
			m--;
f010346b:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010346e:	39 c3                	cmp    %eax,%ebx
f0103470:	7f 0d                	jg     f010347f <stab_binsearch+0x54>
f0103472:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103476:	83 ea 0c             	sub    $0xc,%edx
f0103479:	39 f9                	cmp    %edi,%ecx
f010347b:	75 ee                	jne    f010346b <stab_binsearch+0x40>
f010347d:	eb 05                	jmp    f0103484 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010347f:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0103482:	eb 4b                	jmp    f01034cf <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103484:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103487:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010348a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010348e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103491:	76 11                	jbe    f01034a4 <stab_binsearch+0x79>
			*region_left = m;
f0103493:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103496:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103498:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010349b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01034a2:	eb 2b                	jmp    f01034cf <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01034a4:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01034a7:	73 14                	jae    f01034bd <stab_binsearch+0x92>
			*region_right = m - 1;
f01034a9:	83 e8 01             	sub    $0x1,%eax
f01034ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01034af:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01034b2:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01034b4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01034bb:	eb 12                	jmp    f01034cf <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01034bd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01034c0:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01034c2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01034c6:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01034c8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01034cf:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01034d2:	0f 8e 78 ff ff ff    	jle    f0103450 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01034d8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01034dc:	75 0f                	jne    f01034ed <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01034de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034e1:	8b 00                	mov    (%eax),%eax
f01034e3:	83 e8 01             	sub    $0x1,%eax
f01034e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01034e9:	89 06                	mov    %eax,(%esi)
f01034eb:	eb 2c                	jmp    f0103519 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01034ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034f0:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01034f2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01034f5:	8b 0e                	mov    (%esi),%ecx
f01034f7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01034fa:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01034fd:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103500:	eb 03                	jmp    f0103505 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103502:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103505:	39 c8                	cmp    %ecx,%eax
f0103507:	7e 0b                	jle    f0103514 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0103509:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010350d:	83 ea 0c             	sub    $0xc,%edx
f0103510:	39 df                	cmp    %ebx,%edi
f0103512:	75 ee                	jne    f0103502 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103514:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103517:	89 06                	mov    %eax,(%esi)
	}
}
f0103519:	83 c4 14             	add    $0x14,%esp
f010351c:	5b                   	pop    %ebx
f010351d:	5e                   	pop    %esi
f010351e:	5f                   	pop    %edi
f010351f:	5d                   	pop    %ebp
f0103520:	c3                   	ret    

f0103521 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103521:	55                   	push   %ebp
f0103522:	89 e5                	mov    %esp,%ebp
f0103524:	57                   	push   %edi
f0103525:	56                   	push   %esi
f0103526:	53                   	push   %ebx
f0103527:	83 ec 3c             	sub    $0x3c,%esp
f010352a:	8b 75 08             	mov    0x8(%ebp),%esi
f010352d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103530:	c7 03 17 5a 10 f0    	movl   $0xf0105a17,(%ebx)
	info->eip_line = 0;
f0103536:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010353d:	c7 43 08 17 5a 10 f0 	movl   $0xf0105a17,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103544:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010354b:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010354e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103555:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010355b:	77 21                	ja     f010357e <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010355d:	a1 00 00 20 00       	mov    0x200000,%eax
f0103562:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f0103565:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010356a:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0103570:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0103573:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0103579:	89 7d c0             	mov    %edi,-0x40(%ebp)
f010357c:	eb 1a                	jmp    f0103598 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010357e:	c7 45 c0 a9 fc 10 f0 	movl   $0xf010fca9,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103585:	c7 45 b8 39 d2 10 f0 	movl   $0xf010d239,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010358c:	b8 38 d2 10 f0       	mov    $0xf010d238,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103591:	c7 45 bc 30 5c 10 f0 	movl   $0xf0105c30,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103598:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010359b:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f010359e:	0f 83 9d 01 00 00    	jae    f0103741 <debuginfo_eip+0x220>
f01035a4:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f01035a8:	0f 85 9a 01 00 00    	jne    f0103748 <debuginfo_eip+0x227>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01035ae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01035b5:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01035b8:	29 f8                	sub    %edi,%eax
f01035ba:	c1 f8 02             	sar    $0x2,%eax
f01035bd:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01035c3:	83 e8 01             	sub    $0x1,%eax
f01035c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01035c9:	56                   	push   %esi
f01035ca:	6a 64                	push   $0x64
f01035cc:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01035cf:	89 c1                	mov    %eax,%ecx
f01035d1:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01035d4:	89 f8                	mov    %edi,%eax
f01035d6:	e8 50 fe ff ff       	call   f010342b <stab_binsearch>
	if (lfile == 0)
f01035db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035de:	83 c4 08             	add    $0x8,%esp
f01035e1:	85 c0                	test   %eax,%eax
f01035e3:	0f 84 66 01 00 00    	je     f010374f <debuginfo_eip+0x22e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01035e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01035ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01035f2:	56                   	push   %esi
f01035f3:	6a 24                	push   $0x24
f01035f5:	8d 45 d8             	lea    -0x28(%ebp),%eax
f01035f8:	89 c1                	mov    %eax,%ecx
f01035fa:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01035fd:	89 f8                	mov    %edi,%eax
f01035ff:	e8 27 fe ff ff       	call   f010342b <stab_binsearch>

	if (lfun <= rfun) {
f0103604:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103607:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010360a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010360d:	83 c4 08             	add    $0x8,%esp
f0103610:	39 d0                	cmp    %edx,%eax
f0103612:	7f 2b                	jg     f010363f <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103614:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103617:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f010361a:	8b 11                	mov    (%ecx),%edx
f010361c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010361f:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0103622:	39 fa                	cmp    %edi,%edx
f0103624:	73 06                	jae    f010362c <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103626:	03 55 b8             	add    -0x48(%ebp),%edx
f0103629:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010362c:	8b 51 08             	mov    0x8(%ecx),%edx
f010362f:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103632:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103634:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103637:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010363a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010363d:	eb 0f                	jmp    f010364e <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010363f:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103642:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103645:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103648:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010364b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010364e:	83 ec 08             	sub    $0x8,%esp
f0103651:	6a 3a                	push   $0x3a
f0103653:	ff 73 08             	pushl  0x8(%ebx)
f0103656:	e8 82 08 00 00       	call   f0103edd <strfind>
f010365b:	2b 43 08             	sub    0x8(%ebx),%eax
f010365e:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103661:	83 c4 08             	add    $0x8,%esp
f0103664:	56                   	push   %esi
f0103665:	6a 44                	push   $0x44
f0103667:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010366a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010366d:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0103670:	89 f0                	mov    %esi,%eax
f0103672:	e8 b4 fd ff ff       	call   f010342b <stab_binsearch>
	if (lline == 0)
f0103677:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010367a:	83 c4 10             	add    $0x10,%esp
f010367d:	85 d2                	test   %edx,%edx
f010367f:	0f 84 d1 00 00 00    	je     f0103756 <debuginfo_eip+0x235>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0103685:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103688:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010368b:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0103690:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103693:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103696:	89 d0                	mov    %edx,%eax
f0103698:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010369b:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010369e:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01036a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01036a5:	eb 0a                	jmp    f01036b1 <debuginfo_eip+0x190>
f01036a7:	83 e8 01             	sub    $0x1,%eax
f01036aa:	83 ea 0c             	sub    $0xc,%edx
f01036ad:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01036b1:	39 c7                	cmp    %eax,%edi
f01036b3:	7e 05                	jle    f01036ba <debuginfo_eip+0x199>
f01036b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01036b8:	eb 47                	jmp    f0103701 <debuginfo_eip+0x1e0>
	       && stabs[lline].n_type != N_SOL
f01036ba:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01036be:	80 f9 84             	cmp    $0x84,%cl
f01036c1:	75 0e                	jne    f01036d1 <debuginfo_eip+0x1b0>
f01036c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01036c6:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01036ca:	74 1c                	je     f01036e8 <debuginfo_eip+0x1c7>
f01036cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01036cf:	eb 17                	jmp    f01036e8 <debuginfo_eip+0x1c7>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01036d1:	80 f9 64             	cmp    $0x64,%cl
f01036d4:	75 d1                	jne    f01036a7 <debuginfo_eip+0x186>
f01036d6:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01036da:	74 cb                	je     f01036a7 <debuginfo_eip+0x186>
f01036dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01036df:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01036e3:	74 03                	je     f01036e8 <debuginfo_eip+0x1c7>
f01036e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01036e8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01036eb:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01036ee:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01036f1:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01036f4:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01036f7:	29 f8                	sub    %edi,%eax
f01036f9:	39 c2                	cmp    %eax,%edx
f01036fb:	73 04                	jae    f0103701 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01036fd:	01 fa                	add    %edi,%edx
f01036ff:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103701:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103704:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103707:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010370c:	39 f2                	cmp    %esi,%edx
f010370e:	7d 52                	jge    f0103762 <debuginfo_eip+0x241>
		for (lline = lfun + 1;
f0103710:	83 c2 01             	add    $0x1,%edx
f0103713:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103716:	89 d0                	mov    %edx,%eax
f0103718:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010371b:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010371e:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103721:	eb 04                	jmp    f0103727 <debuginfo_eip+0x206>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103723:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103727:	39 c6                	cmp    %eax,%esi
f0103729:	7e 32                	jle    f010375d <debuginfo_eip+0x23c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010372b:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010372f:	83 c0 01             	add    $0x1,%eax
f0103732:	83 c2 0c             	add    $0xc,%edx
f0103735:	80 f9 a0             	cmp    $0xa0,%cl
f0103738:	74 e9                	je     f0103723 <debuginfo_eip+0x202>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010373a:	b8 00 00 00 00       	mov    $0x0,%eax
f010373f:	eb 21                	jmp    f0103762 <debuginfo_eip+0x241>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103741:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103746:	eb 1a                	jmp    f0103762 <debuginfo_eip+0x241>
f0103748:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010374d:	eb 13                	jmp    f0103762 <debuginfo_eip+0x241>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010374f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103754:	eb 0c                	jmp    f0103762 <debuginfo_eip+0x241>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0103756:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010375b:	eb 05                	jmp    f0103762 <debuginfo_eip+0x241>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010375d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103762:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103765:	5b                   	pop    %ebx
f0103766:	5e                   	pop    %esi
f0103767:	5f                   	pop    %edi
f0103768:	5d                   	pop    %ebp
f0103769:	c3                   	ret    

f010376a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010376a:	55                   	push   %ebp
f010376b:	89 e5                	mov    %esp,%ebp
f010376d:	57                   	push   %edi
f010376e:	56                   	push   %esi
f010376f:	53                   	push   %ebx
f0103770:	83 ec 1c             	sub    $0x1c,%esp
f0103773:	89 c7                	mov    %eax,%edi
f0103775:	89 d6                	mov    %edx,%esi
f0103777:	8b 45 08             	mov    0x8(%ebp),%eax
f010377a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010377d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103780:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103783:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103786:	bb 00 00 00 00       	mov    $0x0,%ebx
f010378b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010378e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103791:	39 d3                	cmp    %edx,%ebx
f0103793:	72 05                	jb     f010379a <printnum+0x30>
f0103795:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103798:	77 45                	ja     f01037df <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010379a:	83 ec 0c             	sub    $0xc,%esp
f010379d:	ff 75 18             	pushl  0x18(%ebp)
f01037a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01037a3:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01037a6:	53                   	push   %ebx
f01037a7:	ff 75 10             	pushl  0x10(%ebp)
f01037aa:	83 ec 08             	sub    $0x8,%esp
f01037ad:	ff 75 e4             	pushl  -0x1c(%ebp)
f01037b0:	ff 75 e0             	pushl  -0x20(%ebp)
f01037b3:	ff 75 dc             	pushl  -0x24(%ebp)
f01037b6:	ff 75 d8             	pushl  -0x28(%ebp)
f01037b9:	e8 42 09 00 00       	call   f0104100 <__udivdi3>
f01037be:	83 c4 18             	add    $0x18,%esp
f01037c1:	52                   	push   %edx
f01037c2:	50                   	push   %eax
f01037c3:	89 f2                	mov    %esi,%edx
f01037c5:	89 f8                	mov    %edi,%eax
f01037c7:	e8 9e ff ff ff       	call   f010376a <printnum>
f01037cc:	83 c4 20             	add    $0x20,%esp
f01037cf:	eb 18                	jmp    f01037e9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01037d1:	83 ec 08             	sub    $0x8,%esp
f01037d4:	56                   	push   %esi
f01037d5:	ff 75 18             	pushl  0x18(%ebp)
f01037d8:	ff d7                	call   *%edi
f01037da:	83 c4 10             	add    $0x10,%esp
f01037dd:	eb 03                	jmp    f01037e2 <printnum+0x78>
f01037df:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01037e2:	83 eb 01             	sub    $0x1,%ebx
f01037e5:	85 db                	test   %ebx,%ebx
f01037e7:	7f e8                	jg     f01037d1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01037e9:	83 ec 08             	sub    $0x8,%esp
f01037ec:	56                   	push   %esi
f01037ed:	83 ec 04             	sub    $0x4,%esp
f01037f0:	ff 75 e4             	pushl  -0x1c(%ebp)
f01037f3:	ff 75 e0             	pushl  -0x20(%ebp)
f01037f6:	ff 75 dc             	pushl  -0x24(%ebp)
f01037f9:	ff 75 d8             	pushl  -0x28(%ebp)
f01037fc:	e8 2f 0a 00 00       	call   f0104230 <__umoddi3>
f0103801:	83 c4 14             	add    $0x14,%esp
f0103804:	0f be 80 21 5a 10 f0 	movsbl -0xfefa5df(%eax),%eax
f010380b:	50                   	push   %eax
f010380c:	ff d7                	call   *%edi
}
f010380e:	83 c4 10             	add    $0x10,%esp
f0103811:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103814:	5b                   	pop    %ebx
f0103815:	5e                   	pop    %esi
f0103816:	5f                   	pop    %edi
f0103817:	5d                   	pop    %ebp
f0103818:	c3                   	ret    

f0103819 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103819:	55                   	push   %ebp
f010381a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010381c:	83 fa 01             	cmp    $0x1,%edx
f010381f:	7e 0e                	jle    f010382f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103821:	8b 10                	mov    (%eax),%edx
f0103823:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103826:	89 08                	mov    %ecx,(%eax)
f0103828:	8b 02                	mov    (%edx),%eax
f010382a:	8b 52 04             	mov    0x4(%edx),%edx
f010382d:	eb 22                	jmp    f0103851 <getuint+0x38>
	else if (lflag)
f010382f:	85 d2                	test   %edx,%edx
f0103831:	74 10                	je     f0103843 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103833:	8b 10                	mov    (%eax),%edx
f0103835:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103838:	89 08                	mov    %ecx,(%eax)
f010383a:	8b 02                	mov    (%edx),%eax
f010383c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103841:	eb 0e                	jmp    f0103851 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103843:	8b 10                	mov    (%eax),%edx
f0103845:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103848:	89 08                	mov    %ecx,(%eax)
f010384a:	8b 02                	mov    (%edx),%eax
f010384c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103851:	5d                   	pop    %ebp
f0103852:	c3                   	ret    

f0103853 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103853:	55                   	push   %ebp
f0103854:	89 e5                	mov    %esp,%ebp
f0103856:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103859:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010385d:	8b 10                	mov    (%eax),%edx
f010385f:	3b 50 04             	cmp    0x4(%eax),%edx
f0103862:	73 0a                	jae    f010386e <sprintputch+0x1b>
		*b->buf++ = ch;
f0103864:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103867:	89 08                	mov    %ecx,(%eax)
f0103869:	8b 45 08             	mov    0x8(%ebp),%eax
f010386c:	88 02                	mov    %al,(%edx)
}
f010386e:	5d                   	pop    %ebp
f010386f:	c3                   	ret    

f0103870 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103870:	55                   	push   %ebp
f0103871:	89 e5                	mov    %esp,%ebp
f0103873:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103876:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103879:	50                   	push   %eax
f010387a:	ff 75 10             	pushl  0x10(%ebp)
f010387d:	ff 75 0c             	pushl  0xc(%ebp)
f0103880:	ff 75 08             	pushl  0x8(%ebp)
f0103883:	e8 05 00 00 00       	call   f010388d <vprintfmt>
	va_end(ap);
}
f0103888:	83 c4 10             	add    $0x10,%esp
f010388b:	c9                   	leave  
f010388c:	c3                   	ret    

f010388d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010388d:	55                   	push   %ebp
f010388e:	89 e5                	mov    %esp,%ebp
f0103890:	57                   	push   %edi
f0103891:	56                   	push   %esi
f0103892:	53                   	push   %ebx
f0103893:	83 ec 2c             	sub    $0x2c,%esp
f0103896:	8b 75 08             	mov    0x8(%ebp),%esi
f0103899:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010389c:	8b 7d 10             	mov    0x10(%ebp),%edi
f010389f:	eb 12                	jmp    f01038b3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01038a1:	85 c0                	test   %eax,%eax
f01038a3:	0f 84 89 03 00 00    	je     f0103c32 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f01038a9:	83 ec 08             	sub    $0x8,%esp
f01038ac:	53                   	push   %ebx
f01038ad:	50                   	push   %eax
f01038ae:	ff d6                	call   *%esi
f01038b0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01038b3:	83 c7 01             	add    $0x1,%edi
f01038b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01038ba:	83 f8 25             	cmp    $0x25,%eax
f01038bd:	75 e2                	jne    f01038a1 <vprintfmt+0x14>
f01038bf:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01038c3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01038ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01038d1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01038d8:	ba 00 00 00 00       	mov    $0x0,%edx
f01038dd:	eb 07                	jmp    f01038e6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01038df:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01038e2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01038e6:	8d 47 01             	lea    0x1(%edi),%eax
f01038e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01038ec:	0f b6 07             	movzbl (%edi),%eax
f01038ef:	0f b6 c8             	movzbl %al,%ecx
f01038f2:	83 e8 23             	sub    $0x23,%eax
f01038f5:	3c 55                	cmp    $0x55,%al
f01038f7:	0f 87 1a 03 00 00    	ja     f0103c17 <vprintfmt+0x38a>
f01038fd:	0f b6 c0             	movzbl %al,%eax
f0103900:	ff 24 85 ac 5a 10 f0 	jmp    *-0xfefa554(,%eax,4)
f0103907:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010390a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010390e:	eb d6                	jmp    f01038e6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103910:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103913:	b8 00 00 00 00       	mov    $0x0,%eax
f0103918:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010391b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010391e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0103922:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0103925:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0103928:	83 fa 09             	cmp    $0x9,%edx
f010392b:	77 39                	ja     f0103966 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010392d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103930:	eb e9                	jmp    f010391b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103932:	8b 45 14             	mov    0x14(%ebp),%eax
f0103935:	8d 48 04             	lea    0x4(%eax),%ecx
f0103938:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010393b:	8b 00                	mov    (%eax),%eax
f010393d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103940:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103943:	eb 27                	jmp    f010396c <vprintfmt+0xdf>
f0103945:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103948:	85 c0                	test   %eax,%eax
f010394a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010394f:	0f 49 c8             	cmovns %eax,%ecx
f0103952:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103955:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103958:	eb 8c                	jmp    f01038e6 <vprintfmt+0x59>
f010395a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010395d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103964:	eb 80                	jmp    f01038e6 <vprintfmt+0x59>
f0103966:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103969:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010396c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103970:	0f 89 70 ff ff ff    	jns    f01038e6 <vprintfmt+0x59>
				width = precision, precision = -1;
f0103976:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103979:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010397c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103983:	e9 5e ff ff ff       	jmp    f01038e6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103988:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010398b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010398e:	e9 53 ff ff ff       	jmp    f01038e6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103993:	8b 45 14             	mov    0x14(%ebp),%eax
f0103996:	8d 50 04             	lea    0x4(%eax),%edx
f0103999:	89 55 14             	mov    %edx,0x14(%ebp)
f010399c:	83 ec 08             	sub    $0x8,%esp
f010399f:	53                   	push   %ebx
f01039a0:	ff 30                	pushl  (%eax)
f01039a2:	ff d6                	call   *%esi
			break;
f01039a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01039aa:	e9 04 ff ff ff       	jmp    f01038b3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01039af:	8b 45 14             	mov    0x14(%ebp),%eax
f01039b2:	8d 50 04             	lea    0x4(%eax),%edx
f01039b5:	89 55 14             	mov    %edx,0x14(%ebp)
f01039b8:	8b 00                	mov    (%eax),%eax
f01039ba:	99                   	cltd   
f01039bb:	31 d0                	xor    %edx,%eax
f01039bd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01039bf:	83 f8 06             	cmp    $0x6,%eax
f01039c2:	7f 0b                	jg     f01039cf <vprintfmt+0x142>
f01039c4:	8b 14 85 04 5c 10 f0 	mov    -0xfefa3fc(,%eax,4),%edx
f01039cb:	85 d2                	test   %edx,%edx
f01039cd:	75 18                	jne    f01039e7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f01039cf:	50                   	push   %eax
f01039d0:	68 39 5a 10 f0       	push   $0xf0105a39
f01039d5:	53                   	push   %ebx
f01039d6:	56                   	push   %esi
f01039d7:	e8 94 fe ff ff       	call   f0103870 <printfmt>
f01039dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01039e2:	e9 cc fe ff ff       	jmp    f01038b3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01039e7:	52                   	push   %edx
f01039e8:	68 37 49 10 f0       	push   $0xf0104937
f01039ed:	53                   	push   %ebx
f01039ee:	56                   	push   %esi
f01039ef:	e8 7c fe ff ff       	call   f0103870 <printfmt>
f01039f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01039fa:	e9 b4 fe ff ff       	jmp    f01038b3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01039ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a02:	8d 50 04             	lea    0x4(%eax),%edx
f0103a05:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a08:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103a0a:	85 ff                	test   %edi,%edi
f0103a0c:	b8 32 5a 10 f0       	mov    $0xf0105a32,%eax
f0103a11:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103a14:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103a18:	0f 8e 94 00 00 00    	jle    f0103ab2 <vprintfmt+0x225>
f0103a1e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103a22:	0f 84 98 00 00 00    	je     f0103ac0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103a28:	83 ec 08             	sub    $0x8,%esp
f0103a2b:	ff 75 d0             	pushl  -0x30(%ebp)
f0103a2e:	57                   	push   %edi
f0103a2f:	e8 5f 03 00 00       	call   f0103d93 <strnlen>
f0103a34:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103a37:	29 c1                	sub    %eax,%ecx
f0103a39:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0103a3c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103a3f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103a43:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103a46:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103a49:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103a4b:	eb 0f                	jmp    f0103a5c <vprintfmt+0x1cf>
					putch(padc, putdat);
f0103a4d:	83 ec 08             	sub    $0x8,%esp
f0103a50:	53                   	push   %ebx
f0103a51:	ff 75 e0             	pushl  -0x20(%ebp)
f0103a54:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103a56:	83 ef 01             	sub    $0x1,%edi
f0103a59:	83 c4 10             	add    $0x10,%esp
f0103a5c:	85 ff                	test   %edi,%edi
f0103a5e:	7f ed                	jg     f0103a4d <vprintfmt+0x1c0>
f0103a60:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103a63:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103a66:	85 c9                	test   %ecx,%ecx
f0103a68:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a6d:	0f 49 c1             	cmovns %ecx,%eax
f0103a70:	29 c1                	sub    %eax,%ecx
f0103a72:	89 75 08             	mov    %esi,0x8(%ebp)
f0103a75:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103a78:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103a7b:	89 cb                	mov    %ecx,%ebx
f0103a7d:	eb 4d                	jmp    f0103acc <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103a7f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103a83:	74 1b                	je     f0103aa0 <vprintfmt+0x213>
f0103a85:	0f be c0             	movsbl %al,%eax
f0103a88:	83 e8 20             	sub    $0x20,%eax
f0103a8b:	83 f8 5e             	cmp    $0x5e,%eax
f0103a8e:	76 10                	jbe    f0103aa0 <vprintfmt+0x213>
					putch('?', putdat);
f0103a90:	83 ec 08             	sub    $0x8,%esp
f0103a93:	ff 75 0c             	pushl  0xc(%ebp)
f0103a96:	6a 3f                	push   $0x3f
f0103a98:	ff 55 08             	call   *0x8(%ebp)
f0103a9b:	83 c4 10             	add    $0x10,%esp
f0103a9e:	eb 0d                	jmp    f0103aad <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0103aa0:	83 ec 08             	sub    $0x8,%esp
f0103aa3:	ff 75 0c             	pushl  0xc(%ebp)
f0103aa6:	52                   	push   %edx
f0103aa7:	ff 55 08             	call   *0x8(%ebp)
f0103aaa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103aad:	83 eb 01             	sub    $0x1,%ebx
f0103ab0:	eb 1a                	jmp    f0103acc <vprintfmt+0x23f>
f0103ab2:	89 75 08             	mov    %esi,0x8(%ebp)
f0103ab5:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103ab8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103abb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103abe:	eb 0c                	jmp    f0103acc <vprintfmt+0x23f>
f0103ac0:	89 75 08             	mov    %esi,0x8(%ebp)
f0103ac3:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103ac6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103ac9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103acc:	83 c7 01             	add    $0x1,%edi
f0103acf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103ad3:	0f be d0             	movsbl %al,%edx
f0103ad6:	85 d2                	test   %edx,%edx
f0103ad8:	74 23                	je     f0103afd <vprintfmt+0x270>
f0103ada:	85 f6                	test   %esi,%esi
f0103adc:	78 a1                	js     f0103a7f <vprintfmt+0x1f2>
f0103ade:	83 ee 01             	sub    $0x1,%esi
f0103ae1:	79 9c                	jns    f0103a7f <vprintfmt+0x1f2>
f0103ae3:	89 df                	mov    %ebx,%edi
f0103ae5:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ae8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103aeb:	eb 18                	jmp    f0103b05 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103aed:	83 ec 08             	sub    $0x8,%esp
f0103af0:	53                   	push   %ebx
f0103af1:	6a 20                	push   $0x20
f0103af3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103af5:	83 ef 01             	sub    $0x1,%edi
f0103af8:	83 c4 10             	add    $0x10,%esp
f0103afb:	eb 08                	jmp    f0103b05 <vprintfmt+0x278>
f0103afd:	89 df                	mov    %ebx,%edi
f0103aff:	8b 75 08             	mov    0x8(%ebp),%esi
f0103b02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103b05:	85 ff                	test   %edi,%edi
f0103b07:	7f e4                	jg     f0103aed <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103b09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103b0c:	e9 a2 fd ff ff       	jmp    f01038b3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103b11:	83 fa 01             	cmp    $0x1,%edx
f0103b14:	7e 16                	jle    f0103b2c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0103b16:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b19:	8d 50 08             	lea    0x8(%eax),%edx
f0103b1c:	89 55 14             	mov    %edx,0x14(%ebp)
f0103b1f:	8b 50 04             	mov    0x4(%eax),%edx
f0103b22:	8b 00                	mov    (%eax),%eax
f0103b24:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b27:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103b2a:	eb 32                	jmp    f0103b5e <vprintfmt+0x2d1>
	else if (lflag)
f0103b2c:	85 d2                	test   %edx,%edx
f0103b2e:	74 18                	je     f0103b48 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0103b30:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b33:	8d 50 04             	lea    0x4(%eax),%edx
f0103b36:	89 55 14             	mov    %edx,0x14(%ebp)
f0103b39:	8b 00                	mov    (%eax),%eax
f0103b3b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b3e:	89 c1                	mov    %eax,%ecx
f0103b40:	c1 f9 1f             	sar    $0x1f,%ecx
f0103b43:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103b46:	eb 16                	jmp    f0103b5e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0103b48:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b4b:	8d 50 04             	lea    0x4(%eax),%edx
f0103b4e:	89 55 14             	mov    %edx,0x14(%ebp)
f0103b51:	8b 00                	mov    (%eax),%eax
f0103b53:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b56:	89 c1                	mov    %eax,%ecx
f0103b58:	c1 f9 1f             	sar    $0x1f,%ecx
f0103b5b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103b5e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b61:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103b64:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103b69:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103b6d:	79 74                	jns    f0103be3 <vprintfmt+0x356>
				putch('-', putdat);
f0103b6f:	83 ec 08             	sub    $0x8,%esp
f0103b72:	53                   	push   %ebx
f0103b73:	6a 2d                	push   $0x2d
f0103b75:	ff d6                	call   *%esi
				num = -(long long) num;
f0103b77:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b7a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b7d:	f7 d8                	neg    %eax
f0103b7f:	83 d2 00             	adc    $0x0,%edx
f0103b82:	f7 da                	neg    %edx
f0103b84:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103b87:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103b8c:	eb 55                	jmp    f0103be3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103b8e:	8d 45 14             	lea    0x14(%ebp),%eax
f0103b91:	e8 83 fc ff ff       	call   f0103819 <getuint>
			base = 10;
f0103b96:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0103b9b:	eb 46                	jmp    f0103be3 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0103b9d:	8d 45 14             	lea    0x14(%ebp),%eax
f0103ba0:	e8 74 fc ff ff       	call   f0103819 <getuint>
			base = 8;
f0103ba5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0103baa:	eb 37                	jmp    f0103be3 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0103bac:	83 ec 08             	sub    $0x8,%esp
f0103baf:	53                   	push   %ebx
f0103bb0:	6a 30                	push   $0x30
f0103bb2:	ff d6                	call   *%esi
			putch('x', putdat);
f0103bb4:	83 c4 08             	add    $0x8,%esp
f0103bb7:	53                   	push   %ebx
f0103bb8:	6a 78                	push   $0x78
f0103bba:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103bbc:	8b 45 14             	mov    0x14(%ebp),%eax
f0103bbf:	8d 50 04             	lea    0x4(%eax),%edx
f0103bc2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103bc5:	8b 00                	mov    (%eax),%eax
f0103bc7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103bcc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103bcf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0103bd4:	eb 0d                	jmp    f0103be3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103bd6:	8d 45 14             	lea    0x14(%ebp),%eax
f0103bd9:	e8 3b fc ff ff       	call   f0103819 <getuint>
			base = 16;
f0103bde:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103be3:	83 ec 0c             	sub    $0xc,%esp
f0103be6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103bea:	57                   	push   %edi
f0103beb:	ff 75 e0             	pushl  -0x20(%ebp)
f0103bee:	51                   	push   %ecx
f0103bef:	52                   	push   %edx
f0103bf0:	50                   	push   %eax
f0103bf1:	89 da                	mov    %ebx,%edx
f0103bf3:	89 f0                	mov    %esi,%eax
f0103bf5:	e8 70 fb ff ff       	call   f010376a <printnum>
			break;
f0103bfa:	83 c4 20             	add    $0x20,%esp
f0103bfd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103c00:	e9 ae fc ff ff       	jmp    f01038b3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103c05:	83 ec 08             	sub    $0x8,%esp
f0103c08:	53                   	push   %ebx
f0103c09:	51                   	push   %ecx
f0103c0a:	ff d6                	call   *%esi
			break;
f0103c0c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103c12:	e9 9c fc ff ff       	jmp    f01038b3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103c17:	83 ec 08             	sub    $0x8,%esp
f0103c1a:	53                   	push   %ebx
f0103c1b:	6a 25                	push   $0x25
f0103c1d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103c1f:	83 c4 10             	add    $0x10,%esp
f0103c22:	eb 03                	jmp    f0103c27 <vprintfmt+0x39a>
f0103c24:	83 ef 01             	sub    $0x1,%edi
f0103c27:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103c2b:	75 f7                	jne    f0103c24 <vprintfmt+0x397>
f0103c2d:	e9 81 fc ff ff       	jmp    f01038b3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0103c32:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c35:	5b                   	pop    %ebx
f0103c36:	5e                   	pop    %esi
f0103c37:	5f                   	pop    %edi
f0103c38:	5d                   	pop    %ebp
f0103c39:	c3                   	ret    

f0103c3a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103c3a:	55                   	push   %ebp
f0103c3b:	89 e5                	mov    %esp,%ebp
f0103c3d:	83 ec 18             	sub    $0x18,%esp
f0103c40:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c43:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103c46:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103c49:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103c4d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103c50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103c57:	85 c0                	test   %eax,%eax
f0103c59:	74 26                	je     f0103c81 <vsnprintf+0x47>
f0103c5b:	85 d2                	test   %edx,%edx
f0103c5d:	7e 22                	jle    f0103c81 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103c5f:	ff 75 14             	pushl  0x14(%ebp)
f0103c62:	ff 75 10             	pushl  0x10(%ebp)
f0103c65:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103c68:	50                   	push   %eax
f0103c69:	68 53 38 10 f0       	push   $0xf0103853
f0103c6e:	e8 1a fc ff ff       	call   f010388d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103c73:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103c76:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c7c:	83 c4 10             	add    $0x10,%esp
f0103c7f:	eb 05                	jmp    f0103c86 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103c81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103c86:	c9                   	leave  
f0103c87:	c3                   	ret    

f0103c88 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103c88:	55                   	push   %ebp
f0103c89:	89 e5                	mov    %esp,%ebp
f0103c8b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103c8e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103c91:	50                   	push   %eax
f0103c92:	ff 75 10             	pushl  0x10(%ebp)
f0103c95:	ff 75 0c             	pushl  0xc(%ebp)
f0103c98:	ff 75 08             	pushl  0x8(%ebp)
f0103c9b:	e8 9a ff ff ff       	call   f0103c3a <vsnprintf>
	va_end(ap);

	return rc;
}
f0103ca0:	c9                   	leave  
f0103ca1:	c3                   	ret    

f0103ca2 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103ca2:	55                   	push   %ebp
f0103ca3:	89 e5                	mov    %esp,%ebp
f0103ca5:	57                   	push   %edi
f0103ca6:	56                   	push   %esi
f0103ca7:	53                   	push   %ebx
f0103ca8:	83 ec 0c             	sub    $0xc,%esp
f0103cab:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103cae:	85 c0                	test   %eax,%eax
f0103cb0:	74 11                	je     f0103cc3 <readline+0x21>
		cprintf("%s", prompt);
f0103cb2:	83 ec 08             	sub    $0x8,%esp
f0103cb5:	50                   	push   %eax
f0103cb6:	68 37 49 10 f0       	push   $0xf0104937
f0103cbb:	e8 a4 f3 ff ff       	call   f0103064 <cprintf>
f0103cc0:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103cc3:	83 ec 0c             	sub    $0xc,%esp
f0103cc6:	6a 00                	push   $0x0
f0103cc8:	e8 69 c9 ff ff       	call   f0100636 <iscons>
f0103ccd:	89 c7                	mov    %eax,%edi
f0103ccf:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103cd2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103cd7:	e8 49 c9 ff ff       	call   f0100625 <getchar>
f0103cdc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103cde:	85 c0                	test   %eax,%eax
f0103ce0:	79 18                	jns    f0103cfa <readline+0x58>
			cprintf("read error: %e\n", c);
f0103ce2:	83 ec 08             	sub    $0x8,%esp
f0103ce5:	50                   	push   %eax
f0103ce6:	68 20 5c 10 f0       	push   $0xf0105c20
f0103ceb:	e8 74 f3 ff ff       	call   f0103064 <cprintf>
			return NULL;
f0103cf0:	83 c4 10             	add    $0x10,%esp
f0103cf3:	b8 00 00 00 00       	mov    $0x0,%eax
f0103cf8:	eb 79                	jmp    f0103d73 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103cfa:	83 f8 08             	cmp    $0x8,%eax
f0103cfd:	0f 94 c2             	sete   %dl
f0103d00:	83 f8 7f             	cmp    $0x7f,%eax
f0103d03:	0f 94 c0             	sete   %al
f0103d06:	08 c2                	or     %al,%dl
f0103d08:	74 1a                	je     f0103d24 <readline+0x82>
f0103d0a:	85 f6                	test   %esi,%esi
f0103d0c:	7e 16                	jle    f0103d24 <readline+0x82>
			if (echoing)
f0103d0e:	85 ff                	test   %edi,%edi
f0103d10:	74 0d                	je     f0103d1f <readline+0x7d>
				cputchar('\b');
f0103d12:	83 ec 0c             	sub    $0xc,%esp
f0103d15:	6a 08                	push   $0x8
f0103d17:	e8 f9 c8 ff ff       	call   f0100615 <cputchar>
f0103d1c:	83 c4 10             	add    $0x10,%esp
			i--;
f0103d1f:	83 ee 01             	sub    $0x1,%esi
f0103d22:	eb b3                	jmp    f0103cd7 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103d24:	83 fb 1f             	cmp    $0x1f,%ebx
f0103d27:	7e 23                	jle    f0103d4c <readline+0xaa>
f0103d29:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103d2f:	7f 1b                	jg     f0103d4c <readline+0xaa>
			if (echoing)
f0103d31:	85 ff                	test   %edi,%edi
f0103d33:	74 0c                	je     f0103d41 <readline+0x9f>
				cputchar(c);
f0103d35:	83 ec 0c             	sub    $0xc,%esp
f0103d38:	53                   	push   %ebx
f0103d39:	e8 d7 c8 ff ff       	call   f0100615 <cputchar>
f0103d3e:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103d41:	88 9e 40 08 17 f0    	mov    %bl,-0xfe8f7c0(%esi)
f0103d47:	8d 76 01             	lea    0x1(%esi),%esi
f0103d4a:	eb 8b                	jmp    f0103cd7 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103d4c:	83 fb 0a             	cmp    $0xa,%ebx
f0103d4f:	74 05                	je     f0103d56 <readline+0xb4>
f0103d51:	83 fb 0d             	cmp    $0xd,%ebx
f0103d54:	75 81                	jne    f0103cd7 <readline+0x35>
			if (echoing)
f0103d56:	85 ff                	test   %edi,%edi
f0103d58:	74 0d                	je     f0103d67 <readline+0xc5>
				cputchar('\n');
f0103d5a:	83 ec 0c             	sub    $0xc,%esp
f0103d5d:	6a 0a                	push   $0xa
f0103d5f:	e8 b1 c8 ff ff       	call   f0100615 <cputchar>
f0103d64:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103d67:	c6 86 40 08 17 f0 00 	movb   $0x0,-0xfe8f7c0(%esi)
			return buf;
f0103d6e:	b8 40 08 17 f0       	mov    $0xf0170840,%eax
		}
	}
}
f0103d73:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d76:	5b                   	pop    %ebx
f0103d77:	5e                   	pop    %esi
f0103d78:	5f                   	pop    %edi
f0103d79:	5d                   	pop    %ebp
f0103d7a:	c3                   	ret    

f0103d7b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103d7b:	55                   	push   %ebp
f0103d7c:	89 e5                	mov    %esp,%ebp
f0103d7e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103d81:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d86:	eb 03                	jmp    f0103d8b <strlen+0x10>
		n++;
f0103d88:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103d8b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103d8f:	75 f7                	jne    f0103d88 <strlen+0xd>
		n++;
	return n;
}
f0103d91:	5d                   	pop    %ebp
f0103d92:	c3                   	ret    

f0103d93 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103d93:	55                   	push   %ebp
f0103d94:	89 e5                	mov    %esp,%ebp
f0103d96:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103d99:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103d9c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103da1:	eb 03                	jmp    f0103da6 <strnlen+0x13>
		n++;
f0103da3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103da6:	39 c2                	cmp    %eax,%edx
f0103da8:	74 08                	je     f0103db2 <strnlen+0x1f>
f0103daa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0103dae:	75 f3                	jne    f0103da3 <strnlen+0x10>
f0103db0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0103db2:	5d                   	pop    %ebp
f0103db3:	c3                   	ret    

f0103db4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103db4:	55                   	push   %ebp
f0103db5:	89 e5                	mov    %esp,%ebp
f0103db7:	53                   	push   %ebx
f0103db8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103dbe:	89 c2                	mov    %eax,%edx
f0103dc0:	83 c2 01             	add    $0x1,%edx
f0103dc3:	83 c1 01             	add    $0x1,%ecx
f0103dc6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103dca:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103dcd:	84 db                	test   %bl,%bl
f0103dcf:	75 ef                	jne    f0103dc0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103dd1:	5b                   	pop    %ebx
f0103dd2:	5d                   	pop    %ebp
f0103dd3:	c3                   	ret    

f0103dd4 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103dd4:	55                   	push   %ebp
f0103dd5:	89 e5                	mov    %esp,%ebp
f0103dd7:	53                   	push   %ebx
f0103dd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103ddb:	53                   	push   %ebx
f0103ddc:	e8 9a ff ff ff       	call   f0103d7b <strlen>
f0103de1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103de4:	ff 75 0c             	pushl  0xc(%ebp)
f0103de7:	01 d8                	add    %ebx,%eax
f0103de9:	50                   	push   %eax
f0103dea:	e8 c5 ff ff ff       	call   f0103db4 <strcpy>
	return dst;
}
f0103def:	89 d8                	mov    %ebx,%eax
f0103df1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103df4:	c9                   	leave  
f0103df5:	c3                   	ret    

f0103df6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103df6:	55                   	push   %ebp
f0103df7:	89 e5                	mov    %esp,%ebp
f0103df9:	56                   	push   %esi
f0103dfa:	53                   	push   %ebx
f0103dfb:	8b 75 08             	mov    0x8(%ebp),%esi
f0103dfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103e01:	89 f3                	mov    %esi,%ebx
f0103e03:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103e06:	89 f2                	mov    %esi,%edx
f0103e08:	eb 0f                	jmp    f0103e19 <strncpy+0x23>
		*dst++ = *src;
f0103e0a:	83 c2 01             	add    $0x1,%edx
f0103e0d:	0f b6 01             	movzbl (%ecx),%eax
f0103e10:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103e13:	80 39 01             	cmpb   $0x1,(%ecx)
f0103e16:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103e19:	39 da                	cmp    %ebx,%edx
f0103e1b:	75 ed                	jne    f0103e0a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103e1d:	89 f0                	mov    %esi,%eax
f0103e1f:	5b                   	pop    %ebx
f0103e20:	5e                   	pop    %esi
f0103e21:	5d                   	pop    %ebp
f0103e22:	c3                   	ret    

f0103e23 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103e23:	55                   	push   %ebp
f0103e24:	89 e5                	mov    %esp,%ebp
f0103e26:	56                   	push   %esi
f0103e27:	53                   	push   %ebx
f0103e28:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103e2e:	8b 55 10             	mov    0x10(%ebp),%edx
f0103e31:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103e33:	85 d2                	test   %edx,%edx
f0103e35:	74 21                	je     f0103e58 <strlcpy+0x35>
f0103e37:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103e3b:	89 f2                	mov    %esi,%edx
f0103e3d:	eb 09                	jmp    f0103e48 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103e3f:	83 c2 01             	add    $0x1,%edx
f0103e42:	83 c1 01             	add    $0x1,%ecx
f0103e45:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103e48:	39 c2                	cmp    %eax,%edx
f0103e4a:	74 09                	je     f0103e55 <strlcpy+0x32>
f0103e4c:	0f b6 19             	movzbl (%ecx),%ebx
f0103e4f:	84 db                	test   %bl,%bl
f0103e51:	75 ec                	jne    f0103e3f <strlcpy+0x1c>
f0103e53:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103e55:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103e58:	29 f0                	sub    %esi,%eax
}
f0103e5a:	5b                   	pop    %ebx
f0103e5b:	5e                   	pop    %esi
f0103e5c:	5d                   	pop    %ebp
f0103e5d:	c3                   	ret    

f0103e5e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103e5e:	55                   	push   %ebp
f0103e5f:	89 e5                	mov    %esp,%ebp
f0103e61:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103e64:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103e67:	eb 06                	jmp    f0103e6f <strcmp+0x11>
		p++, q++;
f0103e69:	83 c1 01             	add    $0x1,%ecx
f0103e6c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103e6f:	0f b6 01             	movzbl (%ecx),%eax
f0103e72:	84 c0                	test   %al,%al
f0103e74:	74 04                	je     f0103e7a <strcmp+0x1c>
f0103e76:	3a 02                	cmp    (%edx),%al
f0103e78:	74 ef                	je     f0103e69 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103e7a:	0f b6 c0             	movzbl %al,%eax
f0103e7d:	0f b6 12             	movzbl (%edx),%edx
f0103e80:	29 d0                	sub    %edx,%eax
}
f0103e82:	5d                   	pop    %ebp
f0103e83:	c3                   	ret    

f0103e84 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103e84:	55                   	push   %ebp
f0103e85:	89 e5                	mov    %esp,%ebp
f0103e87:	53                   	push   %ebx
f0103e88:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e8b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103e8e:	89 c3                	mov    %eax,%ebx
f0103e90:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103e93:	eb 06                	jmp    f0103e9b <strncmp+0x17>
		n--, p++, q++;
f0103e95:	83 c0 01             	add    $0x1,%eax
f0103e98:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103e9b:	39 d8                	cmp    %ebx,%eax
f0103e9d:	74 15                	je     f0103eb4 <strncmp+0x30>
f0103e9f:	0f b6 08             	movzbl (%eax),%ecx
f0103ea2:	84 c9                	test   %cl,%cl
f0103ea4:	74 04                	je     f0103eaa <strncmp+0x26>
f0103ea6:	3a 0a                	cmp    (%edx),%cl
f0103ea8:	74 eb                	je     f0103e95 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103eaa:	0f b6 00             	movzbl (%eax),%eax
f0103ead:	0f b6 12             	movzbl (%edx),%edx
f0103eb0:	29 d0                	sub    %edx,%eax
f0103eb2:	eb 05                	jmp    f0103eb9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103eb4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103eb9:	5b                   	pop    %ebx
f0103eba:	5d                   	pop    %ebp
f0103ebb:	c3                   	ret    

f0103ebc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103ebc:	55                   	push   %ebp
f0103ebd:	89 e5                	mov    %esp,%ebp
f0103ebf:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ec2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103ec6:	eb 07                	jmp    f0103ecf <strchr+0x13>
		if (*s == c)
f0103ec8:	38 ca                	cmp    %cl,%dl
f0103eca:	74 0f                	je     f0103edb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103ecc:	83 c0 01             	add    $0x1,%eax
f0103ecf:	0f b6 10             	movzbl (%eax),%edx
f0103ed2:	84 d2                	test   %dl,%dl
f0103ed4:	75 f2                	jne    f0103ec8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103ed6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103edb:	5d                   	pop    %ebp
f0103edc:	c3                   	ret    

f0103edd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103edd:	55                   	push   %ebp
f0103ede:	89 e5                	mov    %esp,%ebp
f0103ee0:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ee3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103ee7:	eb 03                	jmp    f0103eec <strfind+0xf>
f0103ee9:	83 c0 01             	add    $0x1,%eax
f0103eec:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103eef:	38 ca                	cmp    %cl,%dl
f0103ef1:	74 04                	je     f0103ef7 <strfind+0x1a>
f0103ef3:	84 d2                	test   %dl,%dl
f0103ef5:	75 f2                	jne    f0103ee9 <strfind+0xc>
			break;
	return (char *) s;
}
f0103ef7:	5d                   	pop    %ebp
f0103ef8:	c3                   	ret    

f0103ef9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103ef9:	55                   	push   %ebp
f0103efa:	89 e5                	mov    %esp,%ebp
f0103efc:	57                   	push   %edi
f0103efd:	56                   	push   %esi
f0103efe:	53                   	push   %ebx
f0103eff:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103f02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103f05:	85 c9                	test   %ecx,%ecx
f0103f07:	74 36                	je     f0103f3f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103f09:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103f0f:	75 28                	jne    f0103f39 <memset+0x40>
f0103f11:	f6 c1 03             	test   $0x3,%cl
f0103f14:	75 23                	jne    f0103f39 <memset+0x40>
		c &= 0xFF;
f0103f16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103f1a:	89 d3                	mov    %edx,%ebx
f0103f1c:	c1 e3 08             	shl    $0x8,%ebx
f0103f1f:	89 d6                	mov    %edx,%esi
f0103f21:	c1 e6 18             	shl    $0x18,%esi
f0103f24:	89 d0                	mov    %edx,%eax
f0103f26:	c1 e0 10             	shl    $0x10,%eax
f0103f29:	09 f0                	or     %esi,%eax
f0103f2b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0103f2d:	89 d8                	mov    %ebx,%eax
f0103f2f:	09 d0                	or     %edx,%eax
f0103f31:	c1 e9 02             	shr    $0x2,%ecx
f0103f34:	fc                   	cld    
f0103f35:	f3 ab                	rep stos %eax,%es:(%edi)
f0103f37:	eb 06                	jmp    f0103f3f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103f39:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f3c:	fc                   	cld    
f0103f3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103f3f:	89 f8                	mov    %edi,%eax
f0103f41:	5b                   	pop    %ebx
f0103f42:	5e                   	pop    %esi
f0103f43:	5f                   	pop    %edi
f0103f44:	5d                   	pop    %ebp
f0103f45:	c3                   	ret    

f0103f46 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103f46:	55                   	push   %ebp
f0103f47:	89 e5                	mov    %esp,%ebp
f0103f49:	57                   	push   %edi
f0103f4a:	56                   	push   %esi
f0103f4b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f4e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103f51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103f54:	39 c6                	cmp    %eax,%esi
f0103f56:	73 35                	jae    f0103f8d <memmove+0x47>
f0103f58:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103f5b:	39 d0                	cmp    %edx,%eax
f0103f5d:	73 2e                	jae    f0103f8d <memmove+0x47>
		s += n;
		d += n;
f0103f5f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103f62:	89 d6                	mov    %edx,%esi
f0103f64:	09 fe                	or     %edi,%esi
f0103f66:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103f6c:	75 13                	jne    f0103f81 <memmove+0x3b>
f0103f6e:	f6 c1 03             	test   $0x3,%cl
f0103f71:	75 0e                	jne    f0103f81 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0103f73:	83 ef 04             	sub    $0x4,%edi
f0103f76:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103f79:	c1 e9 02             	shr    $0x2,%ecx
f0103f7c:	fd                   	std    
f0103f7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103f7f:	eb 09                	jmp    f0103f8a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103f81:	83 ef 01             	sub    $0x1,%edi
f0103f84:	8d 72 ff             	lea    -0x1(%edx),%esi
f0103f87:	fd                   	std    
f0103f88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103f8a:	fc                   	cld    
f0103f8b:	eb 1d                	jmp    f0103faa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103f8d:	89 f2                	mov    %esi,%edx
f0103f8f:	09 c2                	or     %eax,%edx
f0103f91:	f6 c2 03             	test   $0x3,%dl
f0103f94:	75 0f                	jne    f0103fa5 <memmove+0x5f>
f0103f96:	f6 c1 03             	test   $0x3,%cl
f0103f99:	75 0a                	jne    f0103fa5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0103f9b:	c1 e9 02             	shr    $0x2,%ecx
f0103f9e:	89 c7                	mov    %eax,%edi
f0103fa0:	fc                   	cld    
f0103fa1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103fa3:	eb 05                	jmp    f0103faa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103fa5:	89 c7                	mov    %eax,%edi
f0103fa7:	fc                   	cld    
f0103fa8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103faa:	5e                   	pop    %esi
f0103fab:	5f                   	pop    %edi
f0103fac:	5d                   	pop    %ebp
f0103fad:	c3                   	ret    

f0103fae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103fae:	55                   	push   %ebp
f0103faf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103fb1:	ff 75 10             	pushl  0x10(%ebp)
f0103fb4:	ff 75 0c             	pushl  0xc(%ebp)
f0103fb7:	ff 75 08             	pushl  0x8(%ebp)
f0103fba:	e8 87 ff ff ff       	call   f0103f46 <memmove>
}
f0103fbf:	c9                   	leave  
f0103fc0:	c3                   	ret    

f0103fc1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103fc1:	55                   	push   %ebp
f0103fc2:	89 e5                	mov    %esp,%ebp
f0103fc4:	56                   	push   %esi
f0103fc5:	53                   	push   %ebx
f0103fc6:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fc9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103fcc:	89 c6                	mov    %eax,%esi
f0103fce:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103fd1:	eb 1a                	jmp    f0103fed <memcmp+0x2c>
		if (*s1 != *s2)
f0103fd3:	0f b6 08             	movzbl (%eax),%ecx
f0103fd6:	0f b6 1a             	movzbl (%edx),%ebx
f0103fd9:	38 d9                	cmp    %bl,%cl
f0103fdb:	74 0a                	je     f0103fe7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0103fdd:	0f b6 c1             	movzbl %cl,%eax
f0103fe0:	0f b6 db             	movzbl %bl,%ebx
f0103fe3:	29 d8                	sub    %ebx,%eax
f0103fe5:	eb 0f                	jmp    f0103ff6 <memcmp+0x35>
		s1++, s2++;
f0103fe7:	83 c0 01             	add    $0x1,%eax
f0103fea:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103fed:	39 f0                	cmp    %esi,%eax
f0103fef:	75 e2                	jne    f0103fd3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103ff1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103ff6:	5b                   	pop    %ebx
f0103ff7:	5e                   	pop    %esi
f0103ff8:	5d                   	pop    %ebp
f0103ff9:	c3                   	ret    

f0103ffa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103ffa:	55                   	push   %ebp
f0103ffb:	89 e5                	mov    %esp,%ebp
f0103ffd:	53                   	push   %ebx
f0103ffe:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104001:	89 c1                	mov    %eax,%ecx
f0104003:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0104006:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010400a:	eb 0a                	jmp    f0104016 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010400c:	0f b6 10             	movzbl (%eax),%edx
f010400f:	39 da                	cmp    %ebx,%edx
f0104011:	74 07                	je     f010401a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104013:	83 c0 01             	add    $0x1,%eax
f0104016:	39 c8                	cmp    %ecx,%eax
f0104018:	72 f2                	jb     f010400c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010401a:	5b                   	pop    %ebx
f010401b:	5d                   	pop    %ebp
f010401c:	c3                   	ret    

f010401d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010401d:	55                   	push   %ebp
f010401e:	89 e5                	mov    %esp,%ebp
f0104020:	57                   	push   %edi
f0104021:	56                   	push   %esi
f0104022:	53                   	push   %ebx
f0104023:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104026:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104029:	eb 03                	jmp    f010402e <strtol+0x11>
		s++;
f010402b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010402e:	0f b6 01             	movzbl (%ecx),%eax
f0104031:	3c 20                	cmp    $0x20,%al
f0104033:	74 f6                	je     f010402b <strtol+0xe>
f0104035:	3c 09                	cmp    $0x9,%al
f0104037:	74 f2                	je     f010402b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104039:	3c 2b                	cmp    $0x2b,%al
f010403b:	75 0a                	jne    f0104047 <strtol+0x2a>
		s++;
f010403d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104040:	bf 00 00 00 00       	mov    $0x0,%edi
f0104045:	eb 11                	jmp    f0104058 <strtol+0x3b>
f0104047:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010404c:	3c 2d                	cmp    $0x2d,%al
f010404e:	75 08                	jne    f0104058 <strtol+0x3b>
		s++, neg = 1;
f0104050:	83 c1 01             	add    $0x1,%ecx
f0104053:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104058:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010405e:	75 15                	jne    f0104075 <strtol+0x58>
f0104060:	80 39 30             	cmpb   $0x30,(%ecx)
f0104063:	75 10                	jne    f0104075 <strtol+0x58>
f0104065:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104069:	75 7c                	jne    f01040e7 <strtol+0xca>
		s += 2, base = 16;
f010406b:	83 c1 02             	add    $0x2,%ecx
f010406e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104073:	eb 16                	jmp    f010408b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0104075:	85 db                	test   %ebx,%ebx
f0104077:	75 12                	jne    f010408b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104079:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010407e:	80 39 30             	cmpb   $0x30,(%ecx)
f0104081:	75 08                	jne    f010408b <strtol+0x6e>
		s++, base = 8;
f0104083:	83 c1 01             	add    $0x1,%ecx
f0104086:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010408b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104090:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104093:	0f b6 11             	movzbl (%ecx),%edx
f0104096:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104099:	89 f3                	mov    %esi,%ebx
f010409b:	80 fb 09             	cmp    $0x9,%bl
f010409e:	77 08                	ja     f01040a8 <strtol+0x8b>
			dig = *s - '0';
f01040a0:	0f be d2             	movsbl %dl,%edx
f01040a3:	83 ea 30             	sub    $0x30,%edx
f01040a6:	eb 22                	jmp    f01040ca <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01040a8:	8d 72 9f             	lea    -0x61(%edx),%esi
f01040ab:	89 f3                	mov    %esi,%ebx
f01040ad:	80 fb 19             	cmp    $0x19,%bl
f01040b0:	77 08                	ja     f01040ba <strtol+0x9d>
			dig = *s - 'a' + 10;
f01040b2:	0f be d2             	movsbl %dl,%edx
f01040b5:	83 ea 57             	sub    $0x57,%edx
f01040b8:	eb 10                	jmp    f01040ca <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01040ba:	8d 72 bf             	lea    -0x41(%edx),%esi
f01040bd:	89 f3                	mov    %esi,%ebx
f01040bf:	80 fb 19             	cmp    $0x19,%bl
f01040c2:	77 16                	ja     f01040da <strtol+0xbd>
			dig = *s - 'A' + 10;
f01040c4:	0f be d2             	movsbl %dl,%edx
f01040c7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01040ca:	3b 55 10             	cmp    0x10(%ebp),%edx
f01040cd:	7d 0b                	jge    f01040da <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01040cf:	83 c1 01             	add    $0x1,%ecx
f01040d2:	0f af 45 10          	imul   0x10(%ebp),%eax
f01040d6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01040d8:	eb b9                	jmp    f0104093 <strtol+0x76>

	if (endptr)
f01040da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01040de:	74 0d                	je     f01040ed <strtol+0xd0>
		*endptr = (char *) s;
f01040e0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01040e3:	89 0e                	mov    %ecx,(%esi)
f01040e5:	eb 06                	jmp    f01040ed <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01040e7:	85 db                	test   %ebx,%ebx
f01040e9:	74 98                	je     f0104083 <strtol+0x66>
f01040eb:	eb 9e                	jmp    f010408b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01040ed:	89 c2                	mov    %eax,%edx
f01040ef:	f7 da                	neg    %edx
f01040f1:	85 ff                	test   %edi,%edi
f01040f3:	0f 45 c2             	cmovne %edx,%eax
}
f01040f6:	5b                   	pop    %ebx
f01040f7:	5e                   	pop    %esi
f01040f8:	5f                   	pop    %edi
f01040f9:	5d                   	pop    %ebp
f01040fa:	c3                   	ret    
f01040fb:	66 90                	xchg   %ax,%ax
f01040fd:	66 90                	xchg   %ax,%ax
f01040ff:	90                   	nop

f0104100 <__udivdi3>:
f0104100:	55                   	push   %ebp
f0104101:	57                   	push   %edi
f0104102:	56                   	push   %esi
f0104103:	53                   	push   %ebx
f0104104:	83 ec 1c             	sub    $0x1c,%esp
f0104107:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010410b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010410f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0104113:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104117:	85 f6                	test   %esi,%esi
f0104119:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010411d:	89 ca                	mov    %ecx,%edx
f010411f:	89 f8                	mov    %edi,%eax
f0104121:	75 3d                	jne    f0104160 <__udivdi3+0x60>
f0104123:	39 cf                	cmp    %ecx,%edi
f0104125:	0f 87 c5 00 00 00    	ja     f01041f0 <__udivdi3+0xf0>
f010412b:	85 ff                	test   %edi,%edi
f010412d:	89 fd                	mov    %edi,%ebp
f010412f:	75 0b                	jne    f010413c <__udivdi3+0x3c>
f0104131:	b8 01 00 00 00       	mov    $0x1,%eax
f0104136:	31 d2                	xor    %edx,%edx
f0104138:	f7 f7                	div    %edi
f010413a:	89 c5                	mov    %eax,%ebp
f010413c:	89 c8                	mov    %ecx,%eax
f010413e:	31 d2                	xor    %edx,%edx
f0104140:	f7 f5                	div    %ebp
f0104142:	89 c1                	mov    %eax,%ecx
f0104144:	89 d8                	mov    %ebx,%eax
f0104146:	89 cf                	mov    %ecx,%edi
f0104148:	f7 f5                	div    %ebp
f010414a:	89 c3                	mov    %eax,%ebx
f010414c:	89 d8                	mov    %ebx,%eax
f010414e:	89 fa                	mov    %edi,%edx
f0104150:	83 c4 1c             	add    $0x1c,%esp
f0104153:	5b                   	pop    %ebx
f0104154:	5e                   	pop    %esi
f0104155:	5f                   	pop    %edi
f0104156:	5d                   	pop    %ebp
f0104157:	c3                   	ret    
f0104158:	90                   	nop
f0104159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104160:	39 ce                	cmp    %ecx,%esi
f0104162:	77 74                	ja     f01041d8 <__udivdi3+0xd8>
f0104164:	0f bd fe             	bsr    %esi,%edi
f0104167:	83 f7 1f             	xor    $0x1f,%edi
f010416a:	0f 84 98 00 00 00    	je     f0104208 <__udivdi3+0x108>
f0104170:	bb 20 00 00 00       	mov    $0x20,%ebx
f0104175:	89 f9                	mov    %edi,%ecx
f0104177:	89 c5                	mov    %eax,%ebp
f0104179:	29 fb                	sub    %edi,%ebx
f010417b:	d3 e6                	shl    %cl,%esi
f010417d:	89 d9                	mov    %ebx,%ecx
f010417f:	d3 ed                	shr    %cl,%ebp
f0104181:	89 f9                	mov    %edi,%ecx
f0104183:	d3 e0                	shl    %cl,%eax
f0104185:	09 ee                	or     %ebp,%esi
f0104187:	89 d9                	mov    %ebx,%ecx
f0104189:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010418d:	89 d5                	mov    %edx,%ebp
f010418f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104193:	d3 ed                	shr    %cl,%ebp
f0104195:	89 f9                	mov    %edi,%ecx
f0104197:	d3 e2                	shl    %cl,%edx
f0104199:	89 d9                	mov    %ebx,%ecx
f010419b:	d3 e8                	shr    %cl,%eax
f010419d:	09 c2                	or     %eax,%edx
f010419f:	89 d0                	mov    %edx,%eax
f01041a1:	89 ea                	mov    %ebp,%edx
f01041a3:	f7 f6                	div    %esi
f01041a5:	89 d5                	mov    %edx,%ebp
f01041a7:	89 c3                	mov    %eax,%ebx
f01041a9:	f7 64 24 0c          	mull   0xc(%esp)
f01041ad:	39 d5                	cmp    %edx,%ebp
f01041af:	72 10                	jb     f01041c1 <__udivdi3+0xc1>
f01041b1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01041b5:	89 f9                	mov    %edi,%ecx
f01041b7:	d3 e6                	shl    %cl,%esi
f01041b9:	39 c6                	cmp    %eax,%esi
f01041bb:	73 07                	jae    f01041c4 <__udivdi3+0xc4>
f01041bd:	39 d5                	cmp    %edx,%ebp
f01041bf:	75 03                	jne    f01041c4 <__udivdi3+0xc4>
f01041c1:	83 eb 01             	sub    $0x1,%ebx
f01041c4:	31 ff                	xor    %edi,%edi
f01041c6:	89 d8                	mov    %ebx,%eax
f01041c8:	89 fa                	mov    %edi,%edx
f01041ca:	83 c4 1c             	add    $0x1c,%esp
f01041cd:	5b                   	pop    %ebx
f01041ce:	5e                   	pop    %esi
f01041cf:	5f                   	pop    %edi
f01041d0:	5d                   	pop    %ebp
f01041d1:	c3                   	ret    
f01041d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01041d8:	31 ff                	xor    %edi,%edi
f01041da:	31 db                	xor    %ebx,%ebx
f01041dc:	89 d8                	mov    %ebx,%eax
f01041de:	89 fa                	mov    %edi,%edx
f01041e0:	83 c4 1c             	add    $0x1c,%esp
f01041e3:	5b                   	pop    %ebx
f01041e4:	5e                   	pop    %esi
f01041e5:	5f                   	pop    %edi
f01041e6:	5d                   	pop    %ebp
f01041e7:	c3                   	ret    
f01041e8:	90                   	nop
f01041e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01041f0:	89 d8                	mov    %ebx,%eax
f01041f2:	f7 f7                	div    %edi
f01041f4:	31 ff                	xor    %edi,%edi
f01041f6:	89 c3                	mov    %eax,%ebx
f01041f8:	89 d8                	mov    %ebx,%eax
f01041fa:	89 fa                	mov    %edi,%edx
f01041fc:	83 c4 1c             	add    $0x1c,%esp
f01041ff:	5b                   	pop    %ebx
f0104200:	5e                   	pop    %esi
f0104201:	5f                   	pop    %edi
f0104202:	5d                   	pop    %ebp
f0104203:	c3                   	ret    
f0104204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104208:	39 ce                	cmp    %ecx,%esi
f010420a:	72 0c                	jb     f0104218 <__udivdi3+0x118>
f010420c:	31 db                	xor    %ebx,%ebx
f010420e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0104212:	0f 87 34 ff ff ff    	ja     f010414c <__udivdi3+0x4c>
f0104218:	bb 01 00 00 00       	mov    $0x1,%ebx
f010421d:	e9 2a ff ff ff       	jmp    f010414c <__udivdi3+0x4c>
f0104222:	66 90                	xchg   %ax,%ax
f0104224:	66 90                	xchg   %ax,%ax
f0104226:	66 90                	xchg   %ax,%ax
f0104228:	66 90                	xchg   %ax,%ax
f010422a:	66 90                	xchg   %ax,%ax
f010422c:	66 90                	xchg   %ax,%ax
f010422e:	66 90                	xchg   %ax,%ax

f0104230 <__umoddi3>:
f0104230:	55                   	push   %ebp
f0104231:	57                   	push   %edi
f0104232:	56                   	push   %esi
f0104233:	53                   	push   %ebx
f0104234:	83 ec 1c             	sub    $0x1c,%esp
f0104237:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010423b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010423f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104243:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104247:	85 d2                	test   %edx,%edx
f0104249:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010424d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104251:	89 f3                	mov    %esi,%ebx
f0104253:	89 3c 24             	mov    %edi,(%esp)
f0104256:	89 74 24 04          	mov    %esi,0x4(%esp)
f010425a:	75 1c                	jne    f0104278 <__umoddi3+0x48>
f010425c:	39 f7                	cmp    %esi,%edi
f010425e:	76 50                	jbe    f01042b0 <__umoddi3+0x80>
f0104260:	89 c8                	mov    %ecx,%eax
f0104262:	89 f2                	mov    %esi,%edx
f0104264:	f7 f7                	div    %edi
f0104266:	89 d0                	mov    %edx,%eax
f0104268:	31 d2                	xor    %edx,%edx
f010426a:	83 c4 1c             	add    $0x1c,%esp
f010426d:	5b                   	pop    %ebx
f010426e:	5e                   	pop    %esi
f010426f:	5f                   	pop    %edi
f0104270:	5d                   	pop    %ebp
f0104271:	c3                   	ret    
f0104272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104278:	39 f2                	cmp    %esi,%edx
f010427a:	89 d0                	mov    %edx,%eax
f010427c:	77 52                	ja     f01042d0 <__umoddi3+0xa0>
f010427e:	0f bd ea             	bsr    %edx,%ebp
f0104281:	83 f5 1f             	xor    $0x1f,%ebp
f0104284:	75 5a                	jne    f01042e0 <__umoddi3+0xb0>
f0104286:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010428a:	0f 82 e0 00 00 00    	jb     f0104370 <__umoddi3+0x140>
f0104290:	39 0c 24             	cmp    %ecx,(%esp)
f0104293:	0f 86 d7 00 00 00    	jbe    f0104370 <__umoddi3+0x140>
f0104299:	8b 44 24 08          	mov    0x8(%esp),%eax
f010429d:	8b 54 24 04          	mov    0x4(%esp),%edx
f01042a1:	83 c4 1c             	add    $0x1c,%esp
f01042a4:	5b                   	pop    %ebx
f01042a5:	5e                   	pop    %esi
f01042a6:	5f                   	pop    %edi
f01042a7:	5d                   	pop    %ebp
f01042a8:	c3                   	ret    
f01042a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01042b0:	85 ff                	test   %edi,%edi
f01042b2:	89 fd                	mov    %edi,%ebp
f01042b4:	75 0b                	jne    f01042c1 <__umoddi3+0x91>
f01042b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01042bb:	31 d2                	xor    %edx,%edx
f01042bd:	f7 f7                	div    %edi
f01042bf:	89 c5                	mov    %eax,%ebp
f01042c1:	89 f0                	mov    %esi,%eax
f01042c3:	31 d2                	xor    %edx,%edx
f01042c5:	f7 f5                	div    %ebp
f01042c7:	89 c8                	mov    %ecx,%eax
f01042c9:	f7 f5                	div    %ebp
f01042cb:	89 d0                	mov    %edx,%eax
f01042cd:	eb 99                	jmp    f0104268 <__umoddi3+0x38>
f01042cf:	90                   	nop
f01042d0:	89 c8                	mov    %ecx,%eax
f01042d2:	89 f2                	mov    %esi,%edx
f01042d4:	83 c4 1c             	add    $0x1c,%esp
f01042d7:	5b                   	pop    %ebx
f01042d8:	5e                   	pop    %esi
f01042d9:	5f                   	pop    %edi
f01042da:	5d                   	pop    %ebp
f01042db:	c3                   	ret    
f01042dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01042e0:	8b 34 24             	mov    (%esp),%esi
f01042e3:	bf 20 00 00 00       	mov    $0x20,%edi
f01042e8:	89 e9                	mov    %ebp,%ecx
f01042ea:	29 ef                	sub    %ebp,%edi
f01042ec:	d3 e0                	shl    %cl,%eax
f01042ee:	89 f9                	mov    %edi,%ecx
f01042f0:	89 f2                	mov    %esi,%edx
f01042f2:	d3 ea                	shr    %cl,%edx
f01042f4:	89 e9                	mov    %ebp,%ecx
f01042f6:	09 c2                	or     %eax,%edx
f01042f8:	89 d8                	mov    %ebx,%eax
f01042fa:	89 14 24             	mov    %edx,(%esp)
f01042fd:	89 f2                	mov    %esi,%edx
f01042ff:	d3 e2                	shl    %cl,%edx
f0104301:	89 f9                	mov    %edi,%ecx
f0104303:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104307:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010430b:	d3 e8                	shr    %cl,%eax
f010430d:	89 e9                	mov    %ebp,%ecx
f010430f:	89 c6                	mov    %eax,%esi
f0104311:	d3 e3                	shl    %cl,%ebx
f0104313:	89 f9                	mov    %edi,%ecx
f0104315:	89 d0                	mov    %edx,%eax
f0104317:	d3 e8                	shr    %cl,%eax
f0104319:	89 e9                	mov    %ebp,%ecx
f010431b:	09 d8                	or     %ebx,%eax
f010431d:	89 d3                	mov    %edx,%ebx
f010431f:	89 f2                	mov    %esi,%edx
f0104321:	f7 34 24             	divl   (%esp)
f0104324:	89 d6                	mov    %edx,%esi
f0104326:	d3 e3                	shl    %cl,%ebx
f0104328:	f7 64 24 04          	mull   0x4(%esp)
f010432c:	39 d6                	cmp    %edx,%esi
f010432e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104332:	89 d1                	mov    %edx,%ecx
f0104334:	89 c3                	mov    %eax,%ebx
f0104336:	72 08                	jb     f0104340 <__umoddi3+0x110>
f0104338:	75 11                	jne    f010434b <__umoddi3+0x11b>
f010433a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010433e:	73 0b                	jae    f010434b <__umoddi3+0x11b>
f0104340:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104344:	1b 14 24             	sbb    (%esp),%edx
f0104347:	89 d1                	mov    %edx,%ecx
f0104349:	89 c3                	mov    %eax,%ebx
f010434b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010434f:	29 da                	sub    %ebx,%edx
f0104351:	19 ce                	sbb    %ecx,%esi
f0104353:	89 f9                	mov    %edi,%ecx
f0104355:	89 f0                	mov    %esi,%eax
f0104357:	d3 e0                	shl    %cl,%eax
f0104359:	89 e9                	mov    %ebp,%ecx
f010435b:	d3 ea                	shr    %cl,%edx
f010435d:	89 e9                	mov    %ebp,%ecx
f010435f:	d3 ee                	shr    %cl,%esi
f0104361:	09 d0                	or     %edx,%eax
f0104363:	89 f2                	mov    %esi,%edx
f0104365:	83 c4 1c             	add    $0x1c,%esp
f0104368:	5b                   	pop    %ebx
f0104369:	5e                   	pop    %esi
f010436a:	5f                   	pop    %edi
f010436b:	5d                   	pop    %ebp
f010436c:	c3                   	ret    
f010436d:	8d 76 00             	lea    0x0(%esi),%esi
f0104370:	29 f9                	sub    %edi,%ecx
f0104372:	19 d6                	sbb    %edx,%esi
f0104374:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104378:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010437c:	e9 18 ff ff ff       	jmp    f0104299 <__umoddi3+0x69>
