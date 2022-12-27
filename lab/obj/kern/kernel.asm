
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
f0100015:	b8 00 50 11 00       	mov    $0x115000,%eax
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
f0100034:	bc 00 50 11 f0       	mov    $0xf0115000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


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
f0100046:	b8 60 79 11 f0       	mov    $0xf0117960,%eax
f010004b:	2d 00 73 11 f0       	sub    $0xf0117300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 73 11 f0       	push   $0xf0117300
f0100058:	e8 3c 32 00 00       	call   f0103299 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 96 04 00 00       	call   f01004f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 40 37 10 f0       	push   $0xf0103740
f010006f:	e8 61 27 00 00       	call   f01027d5 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 fe 10 00 00       	call   f0101177 <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 9f 07 00 00       	call   f0100825 <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 64 79 11 f0 00 	cmpl   $0x0,0xf0117964
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 64 79 11 f0    	mov    %esi,0xf0117964

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000a2:	fa                   	cli    
f01000a3:	fc                   	cld    

	va_start(ap, fmt);
f01000a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	83 ec 04             	sub    $0x4,%esp
f01000aa:	ff 75 0c             	pushl  0xc(%ebp)
f01000ad:	ff 75 08             	pushl  0x8(%ebp)
f01000b0:	68 5b 37 10 f0       	push   $0xf010375b
f01000b5:	e8 1b 27 00 00       	call   f01027d5 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 eb 26 00 00       	call   f01027af <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 a0 3f 10 f0 	movl   $0xf0103fa0,(%esp)
f01000cb:	e8 05 27 00 00       	call   f01027d5 <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 48 07 00 00       	call   f0100825 <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x48>

f01000e2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e2:	55                   	push   %ebp
f01000e3:	89 e5                	mov    %esp,%ebp
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000e9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	68 73 37 10 f0       	push   $0xf0103773
f01000f7:	e8 d9 26 00 00       	call   f01027d5 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 a7 26 00 00       	call   f01027af <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 a0 3f 10 f0 	movl   $0xf0103fa0,(%esp)
f010010f:	e8 c1 26 00 00       	call   f01027d5 <cprintf>
	va_end(ap);
}
f0100114:	83 c4 10             	add    $0x10,%esp
f0100117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011a:	c9                   	leave  
f010011b:	c3                   	ret    

f010011c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010011c:	55                   	push   %ebp
f010011d:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010011f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100124:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100125:	a8 01                	test   $0x1,%al
f0100127:	74 0b                	je     f0100134 <serial_proc_data+0x18>
f0100129:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010012e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010012f:	0f b6 c0             	movzbl %al,%eax
f0100132:	eb 05                	jmp    f0100139 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100139:	5d                   	pop    %ebp
f010013a:	c3                   	ret    

f010013b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010013b:	55                   	push   %ebp
f010013c:	89 e5                	mov    %esp,%ebp
f010013e:	53                   	push   %ebx
f010013f:	83 ec 04             	sub    $0x4,%esp
f0100142:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100144:	eb 2b                	jmp    f0100171 <cons_intr+0x36>
		if (c == 0)
f0100146:	85 c0                	test   %eax,%eax
f0100148:	74 27                	je     f0100171 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010014a:	8b 0d 24 75 11 f0    	mov    0xf0117524,%ecx
f0100150:	8d 51 01             	lea    0x1(%ecx),%edx
f0100153:	89 15 24 75 11 f0    	mov    %edx,0xf0117524
f0100159:	88 81 20 73 11 f0    	mov    %al,-0xfee8ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010015f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100165:	75 0a                	jne    f0100171 <cons_intr+0x36>
			cons.wpos = 0;
f0100167:	c7 05 24 75 11 f0 00 	movl   $0x0,0xf0117524
f010016e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100171:	ff d3                	call   *%ebx
f0100173:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100176:	75 ce                	jne    f0100146 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100178:	83 c4 04             	add    $0x4,%esp
f010017b:	5b                   	pop    %ebx
f010017c:	5d                   	pop    %ebp
f010017d:	c3                   	ret    

f010017e <kbd_proc_data>:
f010017e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100183:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100184:	a8 01                	test   $0x1,%al
f0100186:	0f 84 f8 00 00 00    	je     f0100284 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f010018c:	a8 20                	test   $0x20,%al
f010018e:	0f 85 f6 00 00 00    	jne    f010028a <kbd_proc_data+0x10c>
f0100194:	ba 60 00 00 00       	mov    $0x60,%edx
f0100199:	ec                   	in     (%dx),%al
f010019a:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010019c:	3c e0                	cmp    $0xe0,%al
f010019e:	75 0d                	jne    f01001ad <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001a0:	83 0d 00 73 11 f0 40 	orl    $0x40,0xf0117300
		return 0;
f01001a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ac:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001ad:	55                   	push   %ebp
f01001ae:	89 e5                	mov    %esp,%ebp
f01001b0:	53                   	push   %ebx
f01001b1:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001b4:	84 c0                	test   %al,%al
f01001b6:	79 36                	jns    f01001ee <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001b8:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01001be:	89 cb                	mov    %ecx,%ebx
f01001c0:	83 e3 40             	and    $0x40,%ebx
f01001c3:	83 e0 7f             	and    $0x7f,%eax
f01001c6:	85 db                	test   %ebx,%ebx
f01001c8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001cb:	0f b6 d2             	movzbl %dl,%edx
f01001ce:	0f b6 82 e0 38 10 f0 	movzbl -0xfefc720(%edx),%eax
f01001d5:	83 c8 40             	or     $0x40,%eax
f01001d8:	0f b6 c0             	movzbl %al,%eax
f01001db:	f7 d0                	not    %eax
f01001dd:	21 c8                	and    %ecx,%eax
f01001df:	a3 00 73 11 f0       	mov    %eax,0xf0117300
		return 0;
f01001e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01001e9:	e9 a4 00 00 00       	jmp    f0100292 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f01001ee:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01001f4:	f6 c1 40             	test   $0x40,%cl
f01001f7:	74 0e                	je     f0100207 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001f9:	83 c8 80             	or     $0xffffff80,%eax
f01001fc:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001fe:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100201:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
	}

	shift |= shiftcode[data];
f0100207:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010020a:	0f b6 82 e0 38 10 f0 	movzbl -0xfefc720(%edx),%eax
f0100211:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
f0100217:	0f b6 8a e0 37 10 f0 	movzbl -0xfefc820(%edx),%ecx
f010021e:	31 c8                	xor    %ecx,%eax
f0100220:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100225:	89 c1                	mov    %eax,%ecx
f0100227:	83 e1 03             	and    $0x3,%ecx
f010022a:	8b 0c 8d c0 37 10 f0 	mov    -0xfefc840(,%ecx,4),%ecx
f0100231:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100235:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100238:	a8 08                	test   $0x8,%al
f010023a:	74 1b                	je     f0100257 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010023c:	89 da                	mov    %ebx,%edx
f010023e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100241:	83 f9 19             	cmp    $0x19,%ecx
f0100244:	77 05                	ja     f010024b <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f0100246:	83 eb 20             	sub    $0x20,%ebx
f0100249:	eb 0c                	jmp    f0100257 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f010024b:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010024e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100251:	83 fa 19             	cmp    $0x19,%edx
f0100254:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100257:	f7 d0                	not    %eax
f0100259:	a8 06                	test   $0x6,%al
f010025b:	75 33                	jne    f0100290 <kbd_proc_data+0x112>
f010025d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100263:	75 2b                	jne    f0100290 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100265:	83 ec 0c             	sub    $0xc,%esp
f0100268:	68 8d 37 10 f0       	push   $0xf010378d
f010026d:	e8 63 25 00 00       	call   f01027d5 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100272:	ba 92 00 00 00       	mov    $0x92,%edx
f0100277:	b8 03 00 00 00       	mov    $0x3,%eax
f010027c:	ee                   	out    %al,(%dx)
f010027d:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100280:	89 d8                	mov    %ebx,%eax
f0100282:	eb 0e                	jmp    f0100292 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100284:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100289:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010028a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010028f:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100290:	89 d8                	mov    %ebx,%eax
}
f0100292:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100295:	c9                   	leave  
f0100296:	c3                   	ret    

f0100297 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100297:	55                   	push   %ebp
f0100298:	89 e5                	mov    %esp,%ebp
f010029a:	57                   	push   %edi
f010029b:	56                   	push   %esi
f010029c:	53                   	push   %ebx
f010029d:	83 ec 1c             	sub    $0x1c,%esp
f01002a0:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002a2:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a7:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002ac:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002b1:	eb 09                	jmp    f01002bc <cons_putc+0x25>
f01002b3:	89 ca                	mov    %ecx,%edx
f01002b5:	ec                   	in     (%dx),%al
f01002b6:	ec                   	in     (%dx),%al
f01002b7:	ec                   	in     (%dx),%al
f01002b8:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002b9:	83 c3 01             	add    $0x1,%ebx
f01002bc:	89 f2                	mov    %esi,%edx
f01002be:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002bf:	a8 20                	test   $0x20,%al
f01002c1:	75 08                	jne    f01002cb <cons_putc+0x34>
f01002c3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002c9:	7e e8                	jle    f01002b3 <cons_putc+0x1c>
f01002cb:	89 f8                	mov    %edi,%eax
f01002cd:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002d5:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002d6:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002db:	be 79 03 00 00       	mov    $0x379,%esi
f01002e0:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002e5:	eb 09                	jmp    f01002f0 <cons_putc+0x59>
f01002e7:	89 ca                	mov    %ecx,%edx
f01002e9:	ec                   	in     (%dx),%al
f01002ea:	ec                   	in     (%dx),%al
f01002eb:	ec                   	in     (%dx),%al
f01002ec:	ec                   	in     (%dx),%al
f01002ed:	83 c3 01             	add    $0x1,%ebx
f01002f0:	89 f2                	mov    %esi,%edx
f01002f2:	ec                   	in     (%dx),%al
f01002f3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002f9:	7f 04                	jg     f01002ff <cons_putc+0x68>
f01002fb:	84 c0                	test   %al,%al
f01002fd:	79 e8                	jns    f01002e7 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ff:	ba 78 03 00 00       	mov    $0x378,%edx
f0100304:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100308:	ee                   	out    %al,(%dx)
f0100309:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010030e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100313:	ee                   	out    %al,(%dx)
f0100314:	b8 08 00 00 00       	mov    $0x8,%eax
f0100319:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010031a:	89 fa                	mov    %edi,%edx
f010031c:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100322:	89 f8                	mov    %edi,%eax
f0100324:	80 cc 07             	or     $0x7,%ah
f0100327:	85 d2                	test   %edx,%edx
f0100329:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010032c:	89 f8                	mov    %edi,%eax
f010032e:	0f b6 c0             	movzbl %al,%eax
f0100331:	83 f8 09             	cmp    $0x9,%eax
f0100334:	74 74                	je     f01003aa <cons_putc+0x113>
f0100336:	83 f8 09             	cmp    $0x9,%eax
f0100339:	7f 0a                	jg     f0100345 <cons_putc+0xae>
f010033b:	83 f8 08             	cmp    $0x8,%eax
f010033e:	74 14                	je     f0100354 <cons_putc+0xbd>
f0100340:	e9 99 00 00 00       	jmp    f01003de <cons_putc+0x147>
f0100345:	83 f8 0a             	cmp    $0xa,%eax
f0100348:	74 3a                	je     f0100384 <cons_putc+0xed>
f010034a:	83 f8 0d             	cmp    $0xd,%eax
f010034d:	74 3d                	je     f010038c <cons_putc+0xf5>
f010034f:	e9 8a 00 00 00       	jmp    f01003de <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100354:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f010035b:	66 85 c0             	test   %ax,%ax
f010035e:	0f 84 e6 00 00 00    	je     f010044a <cons_putc+0x1b3>
			crt_pos--;
f0100364:	83 e8 01             	sub    $0x1,%eax
f0100367:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010036d:	0f b7 c0             	movzwl %ax,%eax
f0100370:	66 81 e7 00 ff       	and    $0xff00,%di
f0100375:	83 cf 20             	or     $0x20,%edi
f0100378:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f010037e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100382:	eb 78                	jmp    f01003fc <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100384:	66 83 05 28 75 11 f0 	addw   $0x50,0xf0117528
f010038b:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010038c:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f0100393:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100399:	c1 e8 16             	shr    $0x16,%eax
f010039c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010039f:	c1 e0 04             	shl    $0x4,%eax
f01003a2:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
f01003a8:	eb 52                	jmp    f01003fc <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003aa:	b8 20 00 00 00       	mov    $0x20,%eax
f01003af:	e8 e3 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b9:	e8 d9 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003be:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c3:	e8 cf fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003c8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003cd:	e8 c5 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d7:	e8 bb fe ff ff       	call   f0100297 <cons_putc>
f01003dc:	eb 1e                	jmp    f01003fc <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003de:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f01003e5:	8d 50 01             	lea    0x1(%eax),%edx
f01003e8:	66 89 15 28 75 11 f0 	mov    %dx,0xf0117528
f01003ef:	0f b7 c0             	movzwl %ax,%eax
f01003f2:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f01003f8:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003fc:	66 81 3d 28 75 11 f0 	cmpw   $0x7cf,0xf0117528
f0100403:	cf 07 
f0100405:	76 43                	jbe    f010044a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100407:	a1 2c 75 11 f0       	mov    0xf011752c,%eax
f010040c:	83 ec 04             	sub    $0x4,%esp
f010040f:	68 00 0f 00 00       	push   $0xf00
f0100414:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010041a:	52                   	push   %edx
f010041b:	50                   	push   %eax
f010041c:	e8 c5 2e 00 00       	call   f01032e6 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100421:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100427:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010042d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100433:	83 c4 10             	add    $0x10,%esp
f0100436:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010043b:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010043e:	39 d0                	cmp    %edx,%eax
f0100440:	75 f4                	jne    f0100436 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100442:	66 83 2d 28 75 11 f0 	subw   $0x50,0xf0117528
f0100449:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010044a:	8b 0d 30 75 11 f0    	mov    0xf0117530,%ecx
f0100450:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100455:	89 ca                	mov    %ecx,%edx
f0100457:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100458:	0f b7 1d 28 75 11 f0 	movzwl 0xf0117528,%ebx
f010045f:	8d 71 01             	lea    0x1(%ecx),%esi
f0100462:	89 d8                	mov    %ebx,%eax
f0100464:	66 c1 e8 08          	shr    $0x8,%ax
f0100468:	89 f2                	mov    %esi,%edx
f010046a:	ee                   	out    %al,(%dx)
f010046b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100470:	89 ca                	mov    %ecx,%edx
f0100472:	ee                   	out    %al,(%dx)
f0100473:	89 d8                	mov    %ebx,%eax
f0100475:	89 f2                	mov    %esi,%edx
f0100477:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100478:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010047b:	5b                   	pop    %ebx
f010047c:	5e                   	pop    %esi
f010047d:	5f                   	pop    %edi
f010047e:	5d                   	pop    %ebp
f010047f:	c3                   	ret    

f0100480 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100480:	80 3d 34 75 11 f0 00 	cmpb   $0x0,0xf0117534
f0100487:	74 11                	je     f010049a <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100489:	55                   	push   %ebp
f010048a:	89 e5                	mov    %esp,%ebp
f010048c:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010048f:	b8 1c 01 10 f0       	mov    $0xf010011c,%eax
f0100494:	e8 a2 fc ff ff       	call   f010013b <cons_intr>
}
f0100499:	c9                   	leave  
f010049a:	f3 c3                	repz ret 

f010049c <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010049c:	55                   	push   %ebp
f010049d:	89 e5                	mov    %esp,%ebp
f010049f:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a2:	b8 7e 01 10 f0       	mov    $0xf010017e,%eax
f01004a7:	e8 8f fc ff ff       	call   f010013b <cons_intr>
}
f01004ac:	c9                   	leave  
f01004ad:	c3                   	ret    

f01004ae <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004ae:	55                   	push   %ebp
f01004af:	89 e5                	mov    %esp,%ebp
f01004b1:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004b4:	e8 c7 ff ff ff       	call   f0100480 <serial_intr>
	kbd_intr();
f01004b9:	e8 de ff ff ff       	call   f010049c <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004be:	a1 20 75 11 f0       	mov    0xf0117520,%eax
f01004c3:	3b 05 24 75 11 f0    	cmp    0xf0117524,%eax
f01004c9:	74 26                	je     f01004f1 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004cb:	8d 50 01             	lea    0x1(%eax),%edx
f01004ce:	89 15 20 75 11 f0    	mov    %edx,0xf0117520
f01004d4:	0f b6 88 20 73 11 f0 	movzbl -0xfee8ce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004db:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004dd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004e3:	75 11                	jne    f01004f6 <cons_getc+0x48>
			cons.rpos = 0;
f01004e5:	c7 05 20 75 11 f0 00 	movl   $0x0,0xf0117520
f01004ec:	00 00 00 
f01004ef:	eb 05                	jmp    f01004f6 <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004f6:	c9                   	leave  
f01004f7:	c3                   	ret    

f01004f8 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004f8:	55                   	push   %ebp
f01004f9:	89 e5                	mov    %esp,%ebp
f01004fb:	57                   	push   %edi
f01004fc:	56                   	push   %esi
f01004fd:	53                   	push   %ebx
f01004fe:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100501:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100508:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010050f:	5a a5 
	if (*cp != 0xA55A) {
f0100511:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100518:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010051c:	74 11                	je     f010052f <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010051e:	c7 05 30 75 11 f0 b4 	movl   $0x3b4,0xf0117530
f0100525:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100528:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010052d:	eb 16                	jmp    f0100545 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010052f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100536:	c7 05 30 75 11 f0 d4 	movl   $0x3d4,0xf0117530
f010053d:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100540:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100545:	8b 3d 30 75 11 f0    	mov    0xf0117530,%edi
f010054b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100550:	89 fa                	mov    %edi,%edx
f0100552:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100553:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100556:	89 da                	mov    %ebx,%edx
f0100558:	ec                   	in     (%dx),%al
f0100559:	0f b6 c8             	movzbl %al,%ecx
f010055c:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010055f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100564:	89 fa                	mov    %edi,%edx
f0100566:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100567:	89 da                	mov    %ebx,%edx
f0100569:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010056a:	89 35 2c 75 11 f0    	mov    %esi,0xf011752c
	crt_pos = pos;
f0100570:	0f b6 c0             	movzbl %al,%eax
f0100573:	09 c8                	or     %ecx,%eax
f0100575:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010057b:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100580:	b8 00 00 00 00       	mov    $0x0,%eax
f0100585:	89 f2                	mov    %esi,%edx
f0100587:	ee                   	out    %al,(%dx)
f0100588:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010058d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100592:	ee                   	out    %al,(%dx)
f0100593:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100598:	b8 0c 00 00 00       	mov    $0xc,%eax
f010059d:	89 da                	mov    %ebx,%edx
f010059f:	ee                   	out    %al,(%dx)
f01005a0:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01005aa:	ee                   	out    %al,(%dx)
f01005ab:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005b0:	b8 03 00 00 00       	mov    $0x3,%eax
f01005b5:	ee                   	out    %al,(%dx)
f01005b6:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c0:	ee                   	out    %al,(%dx)
f01005c1:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01005cb:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005cc:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005d1:	ec                   	in     (%dx),%al
f01005d2:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005d4:	3c ff                	cmp    $0xff,%al
f01005d6:	0f 95 05 34 75 11 f0 	setne  0xf0117534
f01005dd:	89 f2                	mov    %esi,%edx
f01005df:	ec                   	in     (%dx),%al
f01005e0:	89 da                	mov    %ebx,%edx
f01005e2:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005e3:	80 f9 ff             	cmp    $0xff,%cl
f01005e6:	75 10                	jne    f01005f8 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005e8:	83 ec 0c             	sub    $0xc,%esp
f01005eb:	68 99 37 10 f0       	push   $0xf0103799
f01005f0:	e8 e0 21 00 00       	call   f01027d5 <cprintf>
f01005f5:	83 c4 10             	add    $0x10,%esp
}
f01005f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005fb:	5b                   	pop    %ebx
f01005fc:	5e                   	pop    %esi
f01005fd:	5f                   	pop    %edi
f01005fe:	5d                   	pop    %ebp
f01005ff:	c3                   	ret    

f0100600 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100600:	55                   	push   %ebp
f0100601:	89 e5                	mov    %esp,%ebp
f0100603:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100606:	8b 45 08             	mov    0x8(%ebp),%eax
f0100609:	e8 89 fc ff ff       	call   f0100297 <cons_putc>
}
f010060e:	c9                   	leave  
f010060f:	c3                   	ret    

f0100610 <getchar>:

int
getchar(void)
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100616:	e8 93 fe ff ff       	call   f01004ae <cons_getc>
f010061b:	85 c0                	test   %eax,%eax
f010061d:	74 f7                	je     f0100616 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010061f:	c9                   	leave  
f0100620:	c3                   	ret    

f0100621 <iscons>:

int
iscons(int fdnum)
{
f0100621:	55                   	push   %ebp
f0100622:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100624:	b8 01 00 00 00       	mov    $0x1,%eax
f0100629:	5d                   	pop    %ebp
f010062a:	c3                   	ret    

f010062b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010062b:	55                   	push   %ebp
f010062c:	89 e5                	mov    %esp,%ebp
f010062e:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100631:	68 e0 39 10 f0       	push   $0xf01039e0
f0100636:	68 fe 39 10 f0       	push   $0xf01039fe
f010063b:	68 03 3a 10 f0       	push   $0xf0103a03
f0100640:	e8 90 21 00 00       	call   f01027d5 <cprintf>
f0100645:	83 c4 0c             	add    $0xc,%esp
f0100648:	68 bc 3a 10 f0       	push   $0xf0103abc
f010064d:	68 0c 3a 10 f0       	push   $0xf0103a0c
f0100652:	68 03 3a 10 f0       	push   $0xf0103a03
f0100657:	e8 79 21 00 00       	call   f01027d5 <cprintf>
f010065c:	83 c4 0c             	add    $0xc,%esp
f010065f:	68 15 3a 10 f0       	push   $0xf0103a15
f0100664:	68 33 3a 10 f0       	push   $0xf0103a33
f0100669:	68 03 3a 10 f0       	push   $0xf0103a03
f010066e:	e8 62 21 00 00       	call   f01027d5 <cprintf>
	return 0;
}
f0100673:	b8 00 00 00 00       	mov    $0x0,%eax
f0100678:	c9                   	leave  
f0100679:	c3                   	ret    

f010067a <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010067a:	55                   	push   %ebp
f010067b:	89 e5                	mov    %esp,%ebp
f010067d:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100680:	68 3d 3a 10 f0       	push   $0xf0103a3d
f0100685:	e8 4b 21 00 00       	call   f01027d5 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010068a:	83 c4 08             	add    $0x8,%esp
f010068d:	68 0c 00 10 00       	push   $0x10000c
f0100692:	68 e4 3a 10 f0       	push   $0xf0103ae4
f0100697:	e8 39 21 00 00       	call   f01027d5 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010069c:	83 c4 0c             	add    $0xc,%esp
f010069f:	68 0c 00 10 00       	push   $0x10000c
f01006a4:	68 0c 00 10 f0       	push   $0xf010000c
f01006a9:	68 0c 3b 10 f0       	push   $0xf0103b0c
f01006ae:	e8 22 21 00 00       	call   f01027d5 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b3:	83 c4 0c             	add    $0xc,%esp
f01006b6:	68 21 37 10 00       	push   $0x103721
f01006bb:	68 21 37 10 f0       	push   $0xf0103721
f01006c0:	68 30 3b 10 f0       	push   $0xf0103b30
f01006c5:	e8 0b 21 00 00       	call   f01027d5 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ca:	83 c4 0c             	add    $0xc,%esp
f01006cd:	68 00 73 11 00       	push   $0x117300
f01006d2:	68 00 73 11 f0       	push   $0xf0117300
f01006d7:	68 54 3b 10 f0       	push   $0xf0103b54
f01006dc:	e8 f4 20 00 00       	call   f01027d5 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e1:	83 c4 0c             	add    $0xc,%esp
f01006e4:	68 60 79 11 00       	push   $0x117960
f01006e9:	68 60 79 11 f0       	push   $0xf0117960
f01006ee:	68 78 3b 10 f0       	push   $0xf0103b78
f01006f3:	e8 dd 20 00 00       	call   f01027d5 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006f8:	b8 5f 7d 11 f0       	mov    $0xf0117d5f,%eax
f01006fd:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100702:	83 c4 08             	add    $0x8,%esp
f0100705:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010070a:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100710:	85 c0                	test   %eax,%eax
f0100712:	0f 48 c2             	cmovs  %edx,%eax
f0100715:	c1 f8 0a             	sar    $0xa,%eax
f0100718:	50                   	push   %eax
f0100719:	68 9c 3b 10 f0       	push   $0xf0103b9c
f010071e:	e8 b2 20 00 00       	call   f01027d5 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100723:	b8 00 00 00 00       	mov    $0x0,%eax
f0100728:	c9                   	leave  
f0100729:	c3                   	ret    

f010072a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010072a:	55                   	push   %ebp
f010072b:	89 e5                	mov    %esp,%ebp
f010072d:	57                   	push   %edi
f010072e:	56                   	push   %esi
f010072f:	53                   	push   %ebx
f0100730:	83 ec 78             	sub    $0x78,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100733:	89 eb                	mov    %ebp,%ebx

	uint32_t _ebp, _eip;
	// _esp = read_esp();
	_ebp = read_ebp();

	uint32_t args[5] = {0, 0, 0, 0, 0};
f0100735:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010073c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100743:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010074a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100751:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");
f0100758:	68 56 3a 10 f0       	push   $0xf0103a56
f010075d:	e8 73 20 00 00       	call   f01027d5 <cprintf>

	while (_ebp != 0) {
f0100762:	83 c4 10             	add    $0x10,%esp
f0100765:	e9 a6 00 00 00       	jmp    f0100810 <mon_backtrace+0xe6>
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr
f010076a:	8b 73 04             	mov    0x4(%ebx),%esi

		for (int i=0; i<5; i++) {
f010076d:	b8 00 00 00 00       	mov    $0x0,%eax
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
f0100772:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f0100776:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)

	while (_ebp != 0) {
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr

		for (int i=0; i<5; i++) {
f010077a:	83 c0 01             	add    $0x1,%eax
f010077d:	83 f8 05             	cmp    $0x5,%eax
f0100780:	75 f0                	jne    f0100772 <mon_backtrace+0x48>
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
		}

		debuginfo_eip((uintptr_t)_eip, &context);
f0100782:	83 ec 08             	sub    $0x8,%esp
f0100785:	8d 45 bc             	lea    -0x44(%ebp),%eax
f0100788:	50                   	push   %eax
f0100789:	56                   	push   %esi
f010078a:	e8 50 21 00 00       	call   f01028df <debuginfo_eip>

		char function_name[50] = {0};
f010078f:	c7 45 8a 00 00 00 00 	movl   $0x0,-0x76(%ebp)
f0100796:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
f010079d:	8d 7d 8c             	lea    -0x74(%ebp),%edi
f01007a0:	b9 0c 00 00 00       	mov    $0xc,%ecx
f01007a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007aa:	f3 ab                	rep stos %eax,%es:(%edi)
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f01007ac:	8b 4d c8             	mov    -0x38(%ebp),%ecx
			function_name[i] = context.eip_fn_name[i];
f01007af:	8b 7d c4             	mov    -0x3c(%ebp),%edi

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f01007b2:	83 c4 10             	add    $0x10,%esp
f01007b5:	eb 0b                	jmp    f01007c2 <mon_backtrace+0x98>
			function_name[i] = context.eip_fn_name[i];
f01007b7:	0f b6 14 07          	movzbl (%edi,%eax,1),%edx
f01007bb:	88 54 05 8a          	mov    %dl,-0x76(%ebp,%eax,1)

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f01007bf:	83 c0 01             	add    $0x1,%eax
f01007c2:	39 c8                	cmp    %ecx,%eax
f01007c4:	7c f1                	jl     f01007b7 <mon_backtrace+0x8d>
			function_name[i] = context.eip_fn_name[i];
		}
		function_name[i] = '\0';
f01007c6:	85 c9                	test   %ecx,%ecx
f01007c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01007cd:	0f 48 c8             	cmovs  %eax,%ecx
f01007d0:	c6 44 0d 8a 00       	movb   $0x0,-0x76(%ebp,%ecx,1)

		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", _ebp, _eip, args[0], args[1], args[2], args[3], args[4]);
f01007d5:	ff 75 e4             	pushl  -0x1c(%ebp)
f01007d8:	ff 75 e0             	pushl  -0x20(%ebp)
f01007db:	ff 75 dc             	pushl  -0x24(%ebp)
f01007de:	ff 75 d8             	pushl  -0x28(%ebp)
f01007e1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007e4:	56                   	push   %esi
f01007e5:	53                   	push   %ebx
f01007e6:	68 c8 3b 10 f0       	push   $0xf0103bc8
f01007eb:	e8 e5 1f 00 00       	call   f01027d5 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f01007f0:	83 c4 14             	add    $0x14,%esp
f01007f3:	2b 75 cc             	sub    -0x34(%ebp),%esi
f01007f6:	56                   	push   %esi
f01007f7:	8d 45 8a             	lea    -0x76(%ebp),%eax
f01007fa:	50                   	push   %eax
f01007fb:	ff 75 c0             	pushl  -0x40(%ebp)
f01007fe:	ff 75 bc             	pushl  -0x44(%ebp)
f0100801:	68 68 3a 10 f0       	push   $0xf0103a68
f0100806:	e8 ca 1f 00 00       	call   f01027d5 <cprintf>

		// _rsp = _ebp + 8;			// old_rsp
		_ebp = *(uint32_t *)_ebp;	// old_ebp
f010080b:	8b 1b                	mov    (%ebx),%ebx
f010080d:	83 c4 20             	add    $0x20,%esp

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");

	while (_ebp != 0) {
f0100810:	85 db                	test   %ebx,%ebx
f0100812:	0f 85 52 ff ff ff    	jne    f010076a <mon_backtrace+0x40>
		_ebp = *(uint32_t *)_ebp;	// old_ebp

	} 

	return 0;
}
f0100818:	b8 00 00 00 00       	mov    $0x0,%eax
f010081d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100820:	5b                   	pop    %ebx
f0100821:	5e                   	pop    %esi
f0100822:	5f                   	pop    %edi
f0100823:	5d                   	pop    %ebp
f0100824:	c3                   	ret    

f0100825 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100825:	55                   	push   %ebp
f0100826:	89 e5                	mov    %esp,%ebp
f0100828:	57                   	push   %edi
f0100829:	56                   	push   %esi
f010082a:	53                   	push   %ebx
f010082b:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010082e:	68 00 3c 10 f0       	push   $0xf0103c00
f0100833:	e8 9d 1f 00 00       	call   f01027d5 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100838:	c7 04 24 24 3c 10 f0 	movl   $0xf0103c24,(%esp)
f010083f:	e8 91 1f 00 00       	call   f01027d5 <cprintf>
f0100844:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100847:	83 ec 0c             	sub    $0xc,%esp
f010084a:	68 7f 3a 10 f0       	push   $0xf0103a7f
f010084f:	e8 ee 27 00 00       	call   f0103042 <readline>
f0100854:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100856:	83 c4 10             	add    $0x10,%esp
f0100859:	85 c0                	test   %eax,%eax
f010085b:	74 ea                	je     f0100847 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010085d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100864:	be 00 00 00 00       	mov    $0x0,%esi
f0100869:	eb 0a                	jmp    f0100875 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010086b:	c6 03 00             	movb   $0x0,(%ebx)
f010086e:	89 f7                	mov    %esi,%edi
f0100870:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100873:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100875:	0f b6 03             	movzbl (%ebx),%eax
f0100878:	84 c0                	test   %al,%al
f010087a:	74 63                	je     f01008df <monitor+0xba>
f010087c:	83 ec 08             	sub    $0x8,%esp
f010087f:	0f be c0             	movsbl %al,%eax
f0100882:	50                   	push   %eax
f0100883:	68 83 3a 10 f0       	push   $0xf0103a83
f0100888:	e8 cf 29 00 00       	call   f010325c <strchr>
f010088d:	83 c4 10             	add    $0x10,%esp
f0100890:	85 c0                	test   %eax,%eax
f0100892:	75 d7                	jne    f010086b <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100894:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100897:	74 46                	je     f01008df <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100899:	83 fe 0f             	cmp    $0xf,%esi
f010089c:	75 14                	jne    f01008b2 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010089e:	83 ec 08             	sub    $0x8,%esp
f01008a1:	6a 10                	push   $0x10
f01008a3:	68 88 3a 10 f0       	push   $0xf0103a88
f01008a8:	e8 28 1f 00 00       	call   f01027d5 <cprintf>
f01008ad:	83 c4 10             	add    $0x10,%esp
f01008b0:	eb 95                	jmp    f0100847 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01008b2:	8d 7e 01             	lea    0x1(%esi),%edi
f01008b5:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008b9:	eb 03                	jmp    f01008be <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008bb:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008be:	0f b6 03             	movzbl (%ebx),%eax
f01008c1:	84 c0                	test   %al,%al
f01008c3:	74 ae                	je     f0100873 <monitor+0x4e>
f01008c5:	83 ec 08             	sub    $0x8,%esp
f01008c8:	0f be c0             	movsbl %al,%eax
f01008cb:	50                   	push   %eax
f01008cc:	68 83 3a 10 f0       	push   $0xf0103a83
f01008d1:	e8 86 29 00 00       	call   f010325c <strchr>
f01008d6:	83 c4 10             	add    $0x10,%esp
f01008d9:	85 c0                	test   %eax,%eax
f01008db:	74 de                	je     f01008bb <monitor+0x96>
f01008dd:	eb 94                	jmp    f0100873 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008df:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008e6:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008e7:	85 f6                	test   %esi,%esi
f01008e9:	0f 84 58 ff ff ff    	je     f0100847 <monitor+0x22>
f01008ef:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008f4:	83 ec 08             	sub    $0x8,%esp
f01008f7:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008fa:	ff 34 85 60 3c 10 f0 	pushl  -0xfefc3a0(,%eax,4)
f0100901:	ff 75 a8             	pushl  -0x58(%ebp)
f0100904:	e8 f5 28 00 00       	call   f01031fe <strcmp>
f0100909:	83 c4 10             	add    $0x10,%esp
f010090c:	85 c0                	test   %eax,%eax
f010090e:	75 21                	jne    f0100931 <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f0100910:	83 ec 04             	sub    $0x4,%esp
f0100913:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100916:	ff 75 08             	pushl  0x8(%ebp)
f0100919:	8d 55 a8             	lea    -0x58(%ebp),%edx
f010091c:	52                   	push   %edx
f010091d:	56                   	push   %esi
f010091e:	ff 14 85 68 3c 10 f0 	call   *-0xfefc398(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100925:	83 c4 10             	add    $0x10,%esp
f0100928:	85 c0                	test   %eax,%eax
f010092a:	78 25                	js     f0100951 <monitor+0x12c>
f010092c:	e9 16 ff ff ff       	jmp    f0100847 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100931:	83 c3 01             	add    $0x1,%ebx
f0100934:	83 fb 03             	cmp    $0x3,%ebx
f0100937:	75 bb                	jne    f01008f4 <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100939:	83 ec 08             	sub    $0x8,%esp
f010093c:	ff 75 a8             	pushl  -0x58(%ebp)
f010093f:	68 a5 3a 10 f0       	push   $0xf0103aa5
f0100944:	e8 8c 1e 00 00       	call   f01027d5 <cprintf>
f0100949:	83 c4 10             	add    $0x10,%esp
f010094c:	e9 f6 fe ff ff       	jmp    f0100847 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100951:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100954:	5b                   	pop    %ebx
f0100955:	5e                   	pop    %esi
f0100956:	5f                   	pop    %edi
f0100957:	5d                   	pop    %ebp
f0100958:	c3                   	ret    

f0100959 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100959:	55                   	push   %ebp
f010095a:	89 e5                	mov    %esp,%ebp
f010095c:	56                   	push   %esi
f010095d:	53                   	push   %ebx
f010095e:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100960:	83 ec 0c             	sub    $0xc,%esp
f0100963:	50                   	push   %eax
f0100964:	e8 05 1e 00 00       	call   f010276e <mc146818_read>
f0100969:	89 c6                	mov    %eax,%esi
f010096b:	83 c3 01             	add    $0x1,%ebx
f010096e:	89 1c 24             	mov    %ebx,(%esp)
f0100971:	e8 f8 1d 00 00       	call   f010276e <mc146818_read>
f0100976:	c1 e0 08             	shl    $0x8,%eax
f0100979:	09 f0                	or     %esi,%eax
}
f010097b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010097e:	5b                   	pop    %ebx
f010097f:	5e                   	pop    %esi
f0100980:	5d                   	pop    %ebp
f0100981:	c3                   	ret    

f0100982 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100982:	83 3d 38 75 11 f0 00 	cmpl   $0x0,0xf0117538
f0100989:	75 11                	jne    f010099c <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010098b:	ba 5f 89 11 f0       	mov    $0xf011895f,%edx
f0100990:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100996:	89 15 38 75 11 f0    	mov    %edx,0xf0117538
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f010099c:	8b 15 38 75 11 f0    	mov    0xf0117538,%edx
f01009a2:	89 c1                	mov    %eax,%ecx
f01009a4:	f7 d1                	not    %ecx
f01009a6:	39 ca                	cmp    %ecx,%edx
f01009a8:	76 17                	jbe    f01009c1 <boot_alloc+0x3f>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01009aa:	55                   	push   %ebp
f01009ab:	89 e5                	mov    %esp,%ebp
f01009ad:	83 ec 0c             	sub    $0xc,%esp
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
		panic("boot_alloc: out of memory\n");
f01009b0:	68 84 3c 10 f0       	push   $0xf0103c84
f01009b5:	6a 6b                	push   $0x6b
f01009b7:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01009bc:	e8 ca f6 ff ff       	call   f010008b <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f01009c1:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f01009c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009cd:	a3 38 75 11 f0       	mov    %eax,0xf0117538

	return result;
}
f01009d2:	89 d0                	mov    %edx,%eax
f01009d4:	c3                   	ret    

f01009d5 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01009d5:	89 d1                	mov    %edx,%ecx
f01009d7:	c1 e9 16             	shr    $0x16,%ecx
f01009da:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009dd:	a8 01                	test   $0x1,%al
f01009df:	74 78                	je     f0100a59 <check_va2pa+0x84>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009e1:	55                   	push   %ebp
f01009e2:	89 e5                	mov    %esp,%ebp
f01009e4:	56                   	push   %esi
f01009e5:	53                   	push   %ebx
f01009e6:	89 d3                	mov    %edx,%ebx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009ed:	89 c6                	mov    %eax,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009ef:	c1 e8 0c             	shr    $0xc,%eax
f01009f2:	3b 05 68 79 11 f0    	cmp    0xf0117968,%eax
f01009f8:	72 15                	jb     f0100a0f <check_va2pa+0x3a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009fa:	56                   	push   %esi
f01009fb:	68 d4 3f 10 f0       	push   $0xf0103fd4
f0100a00:	68 59 03 00 00       	push   $0x359
f0100a05:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100a0a:	e8 7c f6 ff ff       	call   f010008b <_panic>

	cprintf("[?] In check_va2pa\n");
f0100a0f:	83 ec 0c             	sub    $0xc,%esp
f0100a12:	68 ab 3c 10 f0       	push   $0xf0103cab
f0100a17:	e8 b9 1d 00 00       	call   f01027d5 <cprintf>
	cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);
f0100a1c:	c1 eb 0a             	shr    $0xa,%ebx
f0100a1f:	89 da                	mov    %ebx,%edx
f0100a21:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0100a27:	8d 9c 16 00 00 00 f0 	lea    -0x10000000(%esi,%edx,1),%ebx
f0100a2e:	83 c4 0c             	add    $0xc,%esp
f0100a31:	ff 33                	pushl  (%ebx)
f0100a33:	53                   	push   %ebx
f0100a34:	68 f8 3f 10 f0       	push   $0xf0103ff8
f0100a39:	e8 97 1d 00 00       	call   f01027d5 <cprintf>

	if (!(p[PTX(va)] & PTE_P))
f0100a3e:	8b 03                	mov    (%ebx),%eax
f0100a40:	83 c4 10             	add    $0x10,%esp
f0100a43:	89 c2                	mov    %eax,%edx
f0100a45:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a4d:	85 d2                	test   %edx,%edx
f0100a4f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a54:	0f 44 c2             	cmove  %edx,%eax
f0100a57:	eb 06                	jmp    f0100a5f <check_va2pa+0x8a>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100a5e:	c3                   	ret    
	cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a62:	5b                   	pop    %ebx
f0100a63:	5e                   	pop    %esi
f0100a64:	5d                   	pop    %ebp
f0100a65:	c3                   	ret    

f0100a66 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a66:	55                   	push   %ebp
f0100a67:	89 e5                	mov    %esp,%ebp
f0100a69:	57                   	push   %edi
f0100a6a:	56                   	push   %esi
f0100a6b:	53                   	push   %ebx
f0100a6c:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a6f:	84 c0                	test   %al,%al
f0100a71:	0f 85 81 02 00 00    	jne    f0100cf8 <check_page_free_list+0x292>
f0100a77:	e9 8e 02 00 00       	jmp    f0100d0a <check_page_free_list+0x2a4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a7c:	83 ec 04             	sub    $0x4,%esp
f0100a7f:	68 1c 40 10 f0       	push   $0xf010401c
f0100a84:	68 98 02 00 00       	push   $0x298
f0100a89:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100a8e:	e8 f8 f5 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a93:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a96:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a99:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a9c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a9f:	89 c2                	mov    %eax,%edx
f0100aa1:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0100aa7:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100aad:	0f 95 c2             	setne  %dl
f0100ab0:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100ab3:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ab7:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ab9:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100abd:	8b 00                	mov    (%eax),%eax
f0100abf:	85 c0                	test   %eax,%eax
f0100ac1:	75 dc                	jne    f0100a9f <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100ac3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ac6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100acc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100acf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ad2:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ad4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ad7:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100adc:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ae1:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100ae7:	eb 53                	jmp    f0100b3c <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ae9:	89 d8                	mov    %ebx,%eax
f0100aeb:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0100af1:	c1 f8 03             	sar    $0x3,%eax
f0100af4:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100af7:	89 c2                	mov    %eax,%edx
f0100af9:	c1 ea 16             	shr    $0x16,%edx
f0100afc:	39 f2                	cmp    %esi,%edx
f0100afe:	73 3a                	jae    f0100b3a <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b00:	89 c2                	mov    %eax,%edx
f0100b02:	c1 ea 0c             	shr    $0xc,%edx
f0100b05:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0100b0b:	72 12                	jb     f0100b1f <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b0d:	50                   	push   %eax
f0100b0e:	68 d4 3f 10 f0       	push   $0xf0103fd4
f0100b13:	6a 52                	push   $0x52
f0100b15:	68 bf 3c 10 f0       	push   $0xf0103cbf
f0100b1a:	e8 6c f5 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b1f:	83 ec 04             	sub    $0x4,%esp
f0100b22:	68 80 00 00 00       	push   $0x80
f0100b27:	68 97 00 00 00       	push   $0x97
f0100b2c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b31:	50                   	push   %eax
f0100b32:	e8 62 27 00 00       	call   f0103299 <memset>
f0100b37:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b3a:	8b 1b                	mov    (%ebx),%ebx
f0100b3c:	85 db                	test   %ebx,%ebx
f0100b3e:	75 a9                	jne    f0100ae9 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b40:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b45:	e8 38 fe ff ff       	call   f0100982 <boot_alloc>
f0100b4a:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b4d:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b53:	8b 0d 70 79 11 f0    	mov    0xf0117970,%ecx
		assert(pp < pages + npages);
f0100b59:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0100b5e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b61:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b64:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b67:	be 00 00 00 00       	mov    $0x0,%esi
f0100b6c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b6f:	e9 30 01 00 00       	jmp    f0100ca4 <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b74:	39 ca                	cmp    %ecx,%edx
f0100b76:	73 19                	jae    f0100b91 <check_page_free_list+0x12b>
f0100b78:	68 cd 3c 10 f0       	push   $0xf0103ccd
f0100b7d:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0100b82:	68 b2 02 00 00       	push   $0x2b2
f0100b87:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100b8c:	e8 fa f4 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100b91:	39 fa                	cmp    %edi,%edx
f0100b93:	72 19                	jb     f0100bae <check_page_free_list+0x148>
f0100b95:	68 ee 3c 10 f0       	push   $0xf0103cee
f0100b9a:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0100b9f:	68 b3 02 00 00       	push   $0x2b3
f0100ba4:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100ba9:	e8 dd f4 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bae:	89 d0                	mov    %edx,%eax
f0100bb0:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100bb3:	a8 07                	test   $0x7,%al
f0100bb5:	74 19                	je     f0100bd0 <check_page_free_list+0x16a>
f0100bb7:	68 40 40 10 f0       	push   $0xf0104040
f0100bbc:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0100bc1:	68 b4 02 00 00       	push   $0x2b4
f0100bc6:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100bcb:	e8 bb f4 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bd0:	c1 f8 03             	sar    $0x3,%eax
f0100bd3:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100bd6:	85 c0                	test   %eax,%eax
f0100bd8:	75 19                	jne    f0100bf3 <check_page_free_list+0x18d>
f0100bda:	68 02 3d 10 f0       	push   $0xf0103d02
f0100bdf:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0100be4:	68 b7 02 00 00       	push   $0x2b7
f0100be9:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100bee:	e8 98 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bf3:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bf8:	75 19                	jne    f0100c13 <check_page_free_list+0x1ad>
f0100bfa:	68 13 3d 10 f0       	push   $0xf0103d13
f0100bff:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0100c04:	68 b8 02 00 00       	push   $0x2b8
f0100c09:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100c0e:	e8 78 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c13:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c18:	75 19                	jne    f0100c33 <check_page_free_list+0x1cd>
f0100c1a:	68 74 40 10 f0       	push   $0xf0104074
f0100c1f:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0100c24:	68 b9 02 00 00       	push   $0x2b9
f0100c29:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100c2e:	e8 58 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c33:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c38:	75 19                	jne    f0100c53 <check_page_free_list+0x1ed>
f0100c3a:	68 2c 3d 10 f0       	push   $0xf0103d2c
f0100c3f:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0100c44:	68 ba 02 00 00       	push   $0x2ba
f0100c49:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100c4e:	e8 38 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c53:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c58:	76 3f                	jbe    f0100c99 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c5a:	89 c3                	mov    %eax,%ebx
f0100c5c:	c1 eb 0c             	shr    $0xc,%ebx
f0100c5f:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100c62:	77 12                	ja     f0100c76 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c64:	50                   	push   %eax
f0100c65:	68 d4 3f 10 f0       	push   $0xf0103fd4
f0100c6a:	6a 52                	push   $0x52
f0100c6c:	68 bf 3c 10 f0       	push   $0xf0103cbf
f0100c71:	e8 15 f4 ff ff       	call   f010008b <_panic>
f0100c76:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c7b:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c7e:	76 1e                	jbe    f0100c9e <check_page_free_list+0x238>
f0100c80:	68 98 40 10 f0       	push   $0xf0104098
f0100c85:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0100c8a:	68 bb 02 00 00       	push   $0x2bb
f0100c8f:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100c94:	e8 f2 f3 ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c99:	83 c6 01             	add    $0x1,%esi
f0100c9c:	eb 04                	jmp    f0100ca2 <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100c9e:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca2:	8b 12                	mov    (%edx),%edx
f0100ca4:	85 d2                	test   %edx,%edx
f0100ca6:	0f 85 c8 fe ff ff    	jne    f0100b74 <check_page_free_list+0x10e>
f0100cac:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100caf:	85 f6                	test   %esi,%esi
f0100cb1:	7f 19                	jg     f0100ccc <check_page_free_list+0x266>
f0100cb3:	68 46 3d 10 f0       	push   $0xf0103d46
f0100cb8:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0100cbd:	68 c3 02 00 00       	push   $0x2c3
f0100cc2:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100cc7:	e8 bf f3 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100ccc:	85 db                	test   %ebx,%ebx
f0100cce:	7f 19                	jg     f0100ce9 <check_page_free_list+0x283>
f0100cd0:	68 58 3d 10 f0       	push   $0xf0103d58
f0100cd5:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0100cda:	68 c4 02 00 00       	push   $0x2c4
f0100cdf:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100ce4:	e8 a2 f3 ff ff       	call   f010008b <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100ce9:	83 ec 0c             	sub    $0xc,%esp
f0100cec:	68 e0 40 10 f0       	push   $0xf01040e0
f0100cf1:	e8 df 1a 00 00       	call   f01027d5 <cprintf>
}
f0100cf6:	eb 29                	jmp    f0100d21 <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100cf8:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0100cfd:	85 c0                	test   %eax,%eax
f0100cff:	0f 85 8e fd ff ff    	jne    f0100a93 <check_page_free_list+0x2d>
f0100d05:	e9 72 fd ff ff       	jmp    f0100a7c <check_page_free_list+0x16>
f0100d0a:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
f0100d11:	0f 84 65 fd ff ff    	je     f0100a7c <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d17:	be 00 04 00 00       	mov    $0x400,%esi
f0100d1c:	e9 c0 fd ff ff       	jmp    f0100ae1 <check_page_free_list+0x7b>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d24:	5b                   	pop    %ebx
f0100d25:	5e                   	pop    %esi
f0100d26:	5f                   	pop    %edi
f0100d27:	5d                   	pop    %ebp
f0100d28:	c3                   	ret    

f0100d29 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d29:	55                   	push   %ebp
f0100d2a:	89 e5                	mov    %esp,%ebp
f0100d2c:	56                   	push   %esi
f0100d2d:	53                   	push   %ebx
	// 	pages[i].pp_link = page_free_list;
	// 	page_free_list = &pages[i];
	// }

	// 1)	first page in use
	pages[0].pp_ref = 1;
f0100d2e:	a1 70 79 11 f0       	mov    0xf0117970,%eax
f0100d33:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100d39:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100d3f:	8b 35 40 75 11 f0    	mov    0xf0117540,%esi
f0100d45:	8b 0d 3c 75 11 f0    	mov    0xf011753c,%ecx
f0100d4b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d50:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100d55:	eb 27                	jmp    f0100d7e <page_init+0x55>
		pages[i].pp_ref = 0;
f0100d57:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100d5e:	89 c2                	mov    %eax,%edx
f0100d60:	03 15 70 79 11 f0    	add    0xf0117970,%edx
f0100d66:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100d6c:	89 0a                	mov    %ecx,(%edx)
	// 1)	first page in use
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100d6e:	83 c3 01             	add    $0x1,%ebx
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100d71:	03 05 70 79 11 f0    	add    0xf0117970,%eax
f0100d77:	89 c1                	mov    %eax,%ecx
f0100d79:	b8 01 00 00 00       	mov    $0x1,%eax
	// 1)	first page in use
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100d7e:	39 f3                	cmp    %esi,%ebx
f0100d80:	72 d5                	jb     f0100d57 <page_init+0x2e>
f0100d82:	84 c0                	test   %al,%al
f0100d84:	74 06                	je     f0100d8c <page_init+0x63>
f0100d86:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c
f0100d8c:	8b 0d 3c 75 11 f0    	mov    0xf011753c,%ecx
f0100d92:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100d99:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d9e:	eb 23                	jmp    f0100dc3 <page_init+0x9a>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100da0:	89 c2                	mov    %eax,%edx
f0100da2:	03 15 70 79 11 f0    	add    0xf0117970,%edx
f0100da8:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100dae:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100db0:	89 c1                	mov    %eax,%ecx
f0100db2:	03 0d 70 79 11 f0    	add    0xf0117970,%ecx
		page_free_list = &pages[i];
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
f0100db8:	83 c3 01             	add    $0x1,%ebx
f0100dbb:	83 c0 08             	add    $0x8,%eax
f0100dbe:	ba 01 00 00 00       	mov    $0x1,%edx
f0100dc3:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100dc9:	76 d5                	jbe    f0100da0 <page_init+0x77>
f0100dcb:	84 d2                	test   %dl,%dl
f0100dcd:	74 06                	je     f0100dd5 <page_init+0xac>
f0100dcf:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c
f0100dd5:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100ddc:	eb 1a                	jmp    f0100df8 <page_init+0xcf>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100dde:	89 c2                	mov    %eax,%edx
f0100de0:	03 15 70 79 11 f0    	add    0xf0117970,%edx
f0100de6:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = 0;
f0100dec:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
f0100df2:	83 c3 01             	add    $0x1,%ebx
f0100df5:	83 c0 08             	add    $0x8,%eax
f0100df8:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100dfe:	76 de                	jbe    f0100dde <page_init+0xb5>
f0100e00:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f0100e07:	eb 1a                	jmp    f0100e23 <page_init+0xfa>


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100e09:	89 f0                	mov    %esi,%eax
f0100e0b:	03 05 70 79 11 f0    	add    0xf0117970,%eax
f0100e11:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = 0;
f0100e17:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
f0100e1d:	83 c3 01             	add    $0x1,%ebx
f0100e20:	83 c6 08             	add    $0x8,%esi
f0100e23:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e28:	e8 55 fb ff ff       	call   f0100982 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e2d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e32:	77 15                	ja     f0100e49 <page_init+0x120>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e34:	50                   	push   %eax
f0100e35:	68 04 41 10 f0       	push   $0xf0104104
f0100e3a:	68 2e 01 00 00       	push   $0x12e
f0100e3f:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100e44:	e8 42 f2 ff ff       	call   f010008b <_panic>
f0100e49:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e4e:	c1 e8 0c             	shr    $0xc,%eax
f0100e51:	39 c3                	cmp    %eax,%ebx
f0100e53:	72 b4                	jb     f0100e09 <page_init+0xe0>
f0100e55:	8b 0d 3c 75 11 f0    	mov    0xf011753c,%ecx
f0100e5b:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100e62:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e67:	eb 23                	jmp    f0100e8c <page_init+0x163>
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f0100e69:	89 c2                	mov    %eax,%edx
f0100e6b:	03 15 70 79 11 f0    	add    0xf0117970,%edx
f0100e71:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100e77:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100e79:	89 c1                	mov    %eax,%ecx
f0100e7b:	03 0d 70 79 11 f0    	add    0xf0117970,%ecx
		pages[i].pp_link = 0;
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
f0100e81:	83 c3 01             	add    $0x1,%ebx
f0100e84:	83 c0 08             	add    $0x8,%eax
f0100e87:	ba 01 00 00 00       	mov    $0x1,%edx
f0100e8c:	3b 1d 68 79 11 f0    	cmp    0xf0117968,%ebx
f0100e92:	72 d5                	jb     f0100e69 <page_init+0x140>
f0100e94:	84 d2                	test   %dl,%dl
f0100e96:	74 06                	je     f0100e9e <page_init+0x175>
f0100e98:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

}
f0100e9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ea1:	5b                   	pop    %ebx
f0100ea2:	5e                   	pop    %esi
f0100ea3:	5d                   	pop    %ebp
f0100ea4:	c3                   	ret    

f0100ea5 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100ea5:	55                   	push   %ebp
f0100ea6:	89 e5                	mov    %esp,%ebp
f0100ea8:	56                   	push   %esi
f0100ea9:	53                   	push   %ebx
	// Fill this function in

	// no more page in free list, we run out of free memory
	if (page_free_list == 0)
f0100eaa:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100eb0:	85 db                	test   %ebx,%ebx
f0100eb2:	74 59                	je     f0100f0d <page_alloc+0x68>
		return 0;

	// get the previous page in free link
	struct PageInfo* last_free = page_free_list->pp_link;
f0100eb4:	8b 33                	mov    (%ebx),%esi
	struct PageInfo* result = page_free_list;

	// get a free page from the list
	page_free_list->pp_link = 0;
f0100eb6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) {
f0100ebc:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100ec0:	74 45                	je     f0100f07 <page_alloc+0x62>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ec2:	89 d8                	mov    %ebx,%eax
f0100ec4:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0100eca:	c1 f8 03             	sar    $0x3,%eax
f0100ecd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ed0:	89 c2                	mov    %eax,%edx
f0100ed2:	c1 ea 0c             	shr    $0xc,%edx
f0100ed5:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0100edb:	72 12                	jb     f0100eef <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100edd:	50                   	push   %eax
f0100ede:	68 d4 3f 10 f0       	push   $0xf0103fd4
f0100ee3:	6a 52                	push   $0x52
f0100ee5:	68 bf 3c 10 f0       	push   $0xf0103cbf
f0100eea:	e8 9c f1 ff ff       	call   f010008b <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f0100eef:	83 ec 04             	sub    $0x4,%esp
f0100ef2:	68 00 10 00 00       	push   $0x1000
f0100ef7:	6a 00                	push   $0x0
f0100ef9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100efe:	50                   	push   %eax
f0100eff:	e8 95 23 00 00       	call   f0103299 <memset>
f0100f04:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f0100f07:	89 35 3c 75 11 f0    	mov    %esi,0xf011753c

	return result;
}
f0100f0d:	89 d8                	mov    %ebx,%eax
f0100f0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f12:	5b                   	pop    %ebx
f0100f13:	5e                   	pop    %esi
f0100f14:	5d                   	pop    %ebp
f0100f15:	c3                   	ret    

f0100f16 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f16:	55                   	push   %ebp
f0100f17:	89 e5                	mov    %esp,%ebp
f0100f19:	83 ec 08             	sub    $0x8,%esp
f0100f1c:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.

	if (pp == 0)
f0100f1f:	85 c0                	test   %eax,%eax
f0100f21:	74 47                	je     f0100f6a <page_free+0x54>
		return;
	if (pp->pp_link != 0)
f0100f23:	83 38 00             	cmpl   $0x0,(%eax)
f0100f26:	74 17                	je     f0100f3f <page_free+0x29>
		panic("page_free: double free or corrupted\n");
f0100f28:	83 ec 04             	sub    $0x4,%esp
f0100f2b:	68 28 41 10 f0       	push   $0xf0104128
f0100f30:	68 73 01 00 00       	push   $0x173
f0100f35:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100f3a:	e8 4c f1 ff ff       	call   f010008b <_panic>
	if (pp->pp_ref != 0)
f0100f3f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f44:	74 17                	je     f0100f5d <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0100f46:	83 ec 04             	sub    $0x4,%esp
f0100f49:	68 50 41 10 f0       	push   $0xf0104150
f0100f4e:	68 75 01 00 00       	push   $0x175
f0100f53:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0100f58:	e8 2e f1 ff ff       	call   f010008b <_panic>

	pp->pp_link = page_free_list;
f0100f5d:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100f63:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f65:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

}
f0100f6a:	c9                   	leave  
f0100f6b:	c3                   	ret    

f0100f6c <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f6c:	55                   	push   %ebp
f0100f6d:	89 e5                	mov    %esp,%ebp
f0100f6f:	83 ec 08             	sub    $0x8,%esp
f0100f72:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f75:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f79:	83 e8 01             	sub    $0x1,%eax
f0100f7c:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f80:	66 85 c0             	test   %ax,%ax
f0100f83:	75 0c                	jne    f0100f91 <page_decref+0x25>
		page_free(pp);
f0100f85:	83 ec 0c             	sub    $0xc,%esp
f0100f88:	52                   	push   %edx
f0100f89:	e8 88 ff ff ff       	call   f0100f16 <page_free>
f0100f8e:	83 c4 10             	add    $0x10,%esp
}
f0100f91:	c9                   	leave  
f0100f92:	c3                   	ret    

f0100f93 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f93:	55                   	push   %ebp
f0100f94:	89 e5                	mov    %esp,%ebp
f0100f96:	56                   	push   %esi
f0100f97:	53                   	push   %ebx
f0100f98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	// we have virtual address
	// cprintf("[?] %x\n", va);
	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f0100f9b:	89 de                	mov    %ebx,%esi
f0100f9d:	c1 ee 0c             	shr    $0xc,%esi
f0100fa0:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
f0100fa6:	c1 eb 16             	shr    $0x16,%ebx
f0100fa9:	c1 e3 02             	shl    $0x2,%ebx
f0100fac:	03 5d 08             	add    0x8(%ebp),%ebx
f0100faf:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100fb2:	75 30                	jne    f0100fe4 <pgdir_walk+0x51>
		if (create == 0)
f0100fb4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100fb8:	74 5c                	je     f0101016 <pgdir_walk+0x83>
			return NULL;
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f0100fba:	83 ec 0c             	sub    $0xc,%esp
f0100fbd:	6a 01                	push   $0x1
f0100fbf:	e8 e1 fe ff ff       	call   f0100ea5 <page_alloc>
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
f0100fc4:	83 c4 10             	add    $0x10,%esp
f0100fc7:	85 c0                	test   %eax,%eax
f0100fc9:	74 52                	je     f010101d <pgdir_walk+0x8a>
		// set level 1 page table entry to this new level 2 page table
		// this new page is for level2 PT, so flags are:
		// 	PTE_P: this page is present
		//	PTE_U: user process can use this page
		//	PTE_W: this page can be edit
		pgdir[Page_Directory_Index] = page2pa(new_page) | PTE_P | PTE_U | PTE_W;
f0100fcb:	89 c2                	mov    %eax,%edx
f0100fcd:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0100fd3:	c1 fa 03             	sar    $0x3,%edx
f0100fd6:	c1 e2 0c             	shl    $0xc,%edx
f0100fd9:	83 ca 07             	or     $0x7,%edx
f0100fdc:	89 13                	mov    %edx,(%ebx)
		new_page->pp_ref = 1;
f0100fde:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	// cprintf("[?] %x\n", KADDR(PTE_ADDR(pgdir[Page_Directory_Index])));
	
	// remember each entry is 4 byte long
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));
f0100fe4:	8b 03                	mov    (%ebx),%eax
f0100fe6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100feb:	89 c2                	mov    %eax,%edx
f0100fed:	c1 ea 0c             	shr    $0xc,%edx
f0100ff0:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0100ff6:	72 15                	jb     f010100d <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff8:	50                   	push   %eax
f0100ff9:	68 d4 3f 10 f0       	push   $0xf0103fd4
f0100ffe:	68 c2 01 00 00       	push   $0x1c2
f0101003:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101008:	e8 7e f0 ff ff       	call   f010008b <_panic>

	return &p[Page_Table_Index];
f010100d:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0101014:	eb 0c                	jmp    f0101022 <pgdir_walk+0x8f>
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
		if (create == 0)
			return NULL;
f0101016:	b8 00 00 00 00       	mov    $0x0,%eax
f010101b:	eb 05                	jmp    f0101022 <pgdir_walk+0x8f>
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
			return NULL;
f010101d:	b8 00 00 00 00       	mov    $0x0,%eax
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));

	return &p[Page_Table_Index];
}
f0101022:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101025:	5b                   	pop    %ebx
f0101026:	5e                   	pop    %esi
f0101027:	5d                   	pop    %ebp
f0101028:	c3                   	ret    

f0101029 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101029:	55                   	push   %ebp
f010102a:	89 e5                	mov    %esp,%ebp
f010102c:	56                   	push   %esi
f010102d:	53                   	push   %ebx
f010102e:	8b 75 10             	mov    0x10(%ebp),%esi
	// Fill this function in

	// do a page table walk to find real PTE
	pte_t * pte = pgdir_walk(pgdir, va, 0);
f0101031:	83 ec 04             	sub    $0x4,%esp
f0101034:	6a 00                	push   $0x0
f0101036:	ff 75 0c             	pushl  0xc(%ebp)
f0101039:	ff 75 08             	pushl  0x8(%ebp)
f010103c:	e8 52 ff ff ff       	call   f0100f93 <pgdir_walk>
f0101041:	89 c3                	mov    %eax,%ebx

	cprintf("[?] In page_lookup\n");
f0101043:	c7 04 24 69 3d 10 f0 	movl   $0xf0103d69,(%esp)
f010104a:	e8 86 17 00 00       	call   f01027d5 <cprintf>
	cprintf("[?] %x\n", pte);
f010104f:	83 c4 08             	add    $0x8,%esp
f0101052:	53                   	push   %ebx
f0101053:	68 7d 3d 10 f0       	push   $0xf0103d7d
f0101058:	e8 78 17 00 00       	call   f01027d5 <cprintf>

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
f010105d:	83 c4 10             	add    $0x10,%esp
f0101060:	85 db                	test   %ebx,%ebx
f0101062:	74 37                	je     f010109b <page_lookup+0x72>
f0101064:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101067:	74 39                	je     f01010a2 <page_lookup+0x79>
		return NULL;
	
	// store pte
	if (pte_store != 0)
f0101069:	85 f6                	test   %esi,%esi
f010106b:	74 02                	je     f010106f <page_lookup+0x46>
		*pte_store = pte;
f010106d:	89 1e                	mov    %ebx,(%esi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010106f:	8b 03                	mov    (%ebx),%eax
f0101071:	c1 e8 0c             	shr    $0xc,%eax
f0101074:	3b 05 68 79 11 f0    	cmp    0xf0117968,%eax
f010107a:	72 14                	jb     f0101090 <page_lookup+0x67>
		panic("pa2page called with invalid pa");
f010107c:	83 ec 04             	sub    $0x4,%esp
f010107f:	68 94 41 10 f0       	push   $0xf0104194
f0101084:	6a 4b                	push   $0x4b
f0101086:	68 bf 3c 10 f0       	push   $0xf0103cbf
f010108b:	e8 fb ef ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0101090:	8b 15 70 79 11 f0    	mov    0xf0117970,%edx
f0101096:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte)) ;
f0101099:	eb 0c                	jmp    f01010a7 <page_lookup+0x7e>
	cprintf("[?] In page_lookup\n");
	cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
		return NULL;
f010109b:	b8 00 00 00 00       	mov    $0x0,%eax
f01010a0:	eb 05                	jmp    f01010a7 <page_lookup+0x7e>
f01010a2:	b8 00 00 00 00       	mov    $0x0,%eax
	// store pte
	if (pte_store != 0)
		*pte_store = pte;

	return pa2page(PTE_ADDR(*pte)) ;
}
f01010a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010aa:	5b                   	pop    %ebx
f01010ab:	5e                   	pop    %esi
f01010ac:	5d                   	pop    %ebp
f01010ad:	c3                   	ret    

f01010ae <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01010ae:	55                   	push   %ebp
f01010af:	89 e5                	mov    %esp,%ebp
f01010b1:	53                   	push   %ebx
f01010b2:	83 ec 18             	sub    $0x18,%esp
f01010b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	// pte_t *tmp;
	pte_t *pte_store = NULL;
f01010b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * pp = page_lookup(pgdir, va, &pte_store);
f01010bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01010c2:	50                   	push   %eax
f01010c3:	53                   	push   %ebx
f01010c4:	ff 75 08             	pushl  0x8(%ebp)
f01010c7:	e8 5d ff ff ff       	call   f0101029 <page_lookup>

	// if not present, silently return
	if (pp == NULL)
f01010cc:	83 c4 10             	add    $0x10,%esp
f01010cf:	85 c0                	test   %eax,%eax
f01010d1:	74 18                	je     f01010eb <page_remove+0x3d>
		return;

	// decrement ref count, and if reaches 0, free it
	page_decref(pp);
f01010d3:	83 ec 0c             	sub    $0xc,%esp
f01010d6:	50                   	push   %eax
f01010d7:	e8 90 fe ff ff       	call   f0100f6c <page_decref>

	// null the real PTE pointer 
	*pte_store = 0;
f01010dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01010df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010e5:	0f 01 3b             	invlpg (%ebx)
f01010e8:	83 c4 10             	add    $0x10,%esp
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", *pte_store, **pte_store);

	// tlb invalidate
	tlb_invalidate(pgdir, va);

}
f01010eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010ee:	c9                   	leave  
f01010ef:	c3                   	ret    

f01010f0 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01010f0:	55                   	push   %ebp
f01010f1:	89 e5                	mov    %esp,%ebp
f01010f3:	57                   	push   %edi
f01010f4:	56                   	push   %esi
f01010f5:	53                   	push   %ebx
f01010f6:	83 ec 10             	sub    $0x10,%esp
f01010f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010fc:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	
f01010ff:	6a 01                	push   $0x1
f0101101:	57                   	push   %edi
f0101102:	ff 75 08             	pushl  0x8(%ebp)
f0101105:	e8 89 fe ff ff       	call   f0100f93 <pgdir_walk>

	if (pte == 0)
f010110a:	83 c4 10             	add    $0x10,%esp
f010110d:	85 c0                	test   %eax,%eax
f010110f:	74 59                	je     f010116a <page_insert+0x7a>
f0101111:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;

	// already have a page
	// remove it and invalidate tlb
	if (*pte != 0) {
f0101113:	8b 00                	mov    (%eax),%eax
f0101115:	85 c0                	test   %eax,%eax
f0101117:	74 2d                	je     f0101146 <page_insert+0x56>
		// corner case
		if (page2pa(pp) == PTE_ADDR(*pte))
f0101119:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010111e:	89 da                	mov    %ebx,%edx
f0101120:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101126:	c1 fa 03             	sar    $0x3,%edx
f0101129:	c1 e2 0c             	shl    $0xc,%edx
f010112c:	39 d0                	cmp    %edx,%eax
f010112e:	75 07                	jne    f0101137 <page_insert+0x47>
			pp->pp_ref--;	// keep pp_ref consistent, in the meantime change perm potentially.
f0101130:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f0101135:	eb 0f                	jmp    f0101146 <page_insert+0x56>
		else
			page_remove(pgdir, va);
f0101137:	83 ec 08             	sub    $0x8,%esp
f010113a:	57                   	push   %edi
f010113b:	ff 75 08             	pushl  0x8(%ebp)
f010113e:	e8 6b ff ff ff       	call   f01010ae <page_remove>
f0101143:	83 c4 10             	add    $0x10,%esp

	// set the real PTE to pa, zero out least 12 bits
	*pte = PTE_ADDR(page2pa(pp));
	
	// set flags
	*pte |= (perm | PTE_P);
f0101146:	89 d8                	mov    %ebx,%eax
f0101148:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f010114e:	c1 f8 03             	sar    $0x3,%eax
f0101151:	c1 e0 0c             	shl    $0xc,%eax
f0101154:	8b 55 14             	mov    0x14(%ebp),%edx
f0101157:	83 ca 01             	or     $0x1,%edx
f010115a:	09 d0                	or     %edx,%eax
f010115c:	89 06                	mov    %eax,(%esi)

	// increment ref cnt
	pp->pp_ref++;
f010115e:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	return 0;
f0101163:	b8 00 00 00 00       	mov    $0x0,%eax
f0101168:	eb 05                	jmp    f010116f <page_insert+0x7f>
	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	

	if (pte == 0)
		return -E_NO_MEM;
f010116a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	// increment ref cnt
	pp->pp_ref++;

	return 0;
}
f010116f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101172:	5b                   	pop    %ebx
f0101173:	5e                   	pop    %esi
f0101174:	5f                   	pop    %edi
f0101175:	5d                   	pop    %ebp
f0101176:	c3                   	ret    

f0101177 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101177:	55                   	push   %ebp
f0101178:	89 e5                	mov    %esp,%ebp
f010117a:	57                   	push   %edi
f010117b:	56                   	push   %esi
f010117c:	53                   	push   %ebx
f010117d:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101180:	b8 15 00 00 00       	mov    $0x15,%eax
f0101185:	e8 cf f7 ff ff       	call   f0100959 <nvram_read>
f010118a:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010118c:	b8 17 00 00 00       	mov    $0x17,%eax
f0101191:	e8 c3 f7 ff ff       	call   f0100959 <nvram_read>
f0101196:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101198:	b8 34 00 00 00       	mov    $0x34,%eax
f010119d:	e8 b7 f7 ff ff       	call   f0100959 <nvram_read>
f01011a2:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01011a5:	85 c0                	test   %eax,%eax
f01011a7:	74 07                	je     f01011b0 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01011a9:	05 00 40 00 00       	add    $0x4000,%eax
f01011ae:	eb 0b                	jmp    f01011bb <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01011b0:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01011b6:	85 f6                	test   %esi,%esi
f01011b8:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01011bb:	89 c2                	mov    %eax,%edx
f01011bd:	c1 ea 02             	shr    $0x2,%edx
f01011c0:	89 15 68 79 11 f0    	mov    %edx,0xf0117968
	npages_basemem = basemem / (PGSIZE / 1024);
f01011c6:	89 da                	mov    %ebx,%edx
f01011c8:	c1 ea 02             	shr    $0x2,%edx
f01011cb:	89 15 40 75 11 f0    	mov    %edx,0xf0117540

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011d1:	89 c2                	mov    %eax,%edx
f01011d3:	29 da                	sub    %ebx,%edx
f01011d5:	52                   	push   %edx
f01011d6:	53                   	push   %ebx
f01011d7:	50                   	push   %eax
f01011d8:	68 b4 41 10 f0       	push   $0xf01041b4
f01011dd:	e8 f3 15 00 00       	call   f01027d5 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011e2:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011e7:	e8 96 f7 ff ff       	call   f0100982 <boot_alloc>
f01011ec:	a3 6c 79 11 f0       	mov    %eax,0xf011796c
	memset(kern_pgdir, 0, PGSIZE);
f01011f1:	83 c4 0c             	add    $0xc,%esp
f01011f4:	68 00 10 00 00       	push   $0x1000
f01011f9:	6a 00                	push   $0x0
f01011fb:	50                   	push   %eax
f01011fc:	e8 98 20 00 00       	call   f0103299 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101201:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101206:	83 c4 10             	add    $0x10,%esp
f0101209:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010120e:	77 15                	ja     f0101225 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101210:	50                   	push   %eax
f0101211:	68 04 41 10 f0       	push   $0xf0104104
f0101216:	68 96 00 00 00       	push   $0x96
f010121b:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101220:	e8 66 ee ff ff       	call   f010008b <_panic>
f0101225:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010122b:	83 ca 05             	or     $0x5,%edx
f010122e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f0101234:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101239:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f0101240:	89 d8                	mov    %ebx,%eax
f0101242:	e8 3b f7 ff ff       	call   f0100982 <boot_alloc>
f0101247:	a3 70 79 11 f0       	mov    %eax,0xf0117970
	memset(pages, 0, n);
f010124c:	83 ec 04             	sub    $0x4,%esp
f010124f:	53                   	push   %ebx
f0101250:	6a 00                	push   $0x0
f0101252:	50                   	push   %eax
f0101253:	e8 41 20 00 00       	call   f0103299 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101258:	e8 cc fa ff ff       	call   f0100d29 <page_init>

	check_page_free_list(1);
f010125d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101262:	e8 ff f7 ff ff       	call   f0100a66 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101267:	83 c4 10             	add    $0x10,%esp
f010126a:	83 3d 70 79 11 f0 00 	cmpl   $0x0,0xf0117970
f0101271:	75 17                	jne    f010128a <mem_init+0x113>
		panic("'pages' is a null pointer!");
f0101273:	83 ec 04             	sub    $0x4,%esp
f0101276:	68 85 3d 10 f0       	push   $0xf0103d85
f010127b:	68 d7 02 00 00       	push   $0x2d7
f0101280:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101285:	e8 01 ee ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010128a:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010128f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101294:	eb 05                	jmp    f010129b <mem_init+0x124>
		++nfree;
f0101296:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101299:	8b 00                	mov    (%eax),%eax
f010129b:	85 c0                	test   %eax,%eax
f010129d:	75 f7                	jne    f0101296 <mem_init+0x11f>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010129f:	83 ec 0c             	sub    $0xc,%esp
f01012a2:	6a 00                	push   $0x0
f01012a4:	e8 fc fb ff ff       	call   f0100ea5 <page_alloc>
f01012a9:	89 c7                	mov    %eax,%edi
f01012ab:	83 c4 10             	add    $0x10,%esp
f01012ae:	85 c0                	test   %eax,%eax
f01012b0:	75 19                	jne    f01012cb <mem_init+0x154>
f01012b2:	68 a0 3d 10 f0       	push   $0xf0103da0
f01012b7:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01012bc:	68 df 02 00 00       	push   $0x2df
f01012c1:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01012c6:	e8 c0 ed ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01012cb:	83 ec 0c             	sub    $0xc,%esp
f01012ce:	6a 00                	push   $0x0
f01012d0:	e8 d0 fb ff ff       	call   f0100ea5 <page_alloc>
f01012d5:	89 c6                	mov    %eax,%esi
f01012d7:	83 c4 10             	add    $0x10,%esp
f01012da:	85 c0                	test   %eax,%eax
f01012dc:	75 19                	jne    f01012f7 <mem_init+0x180>
f01012de:	68 b6 3d 10 f0       	push   $0xf0103db6
f01012e3:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01012e8:	68 e0 02 00 00       	push   $0x2e0
f01012ed:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01012f2:	e8 94 ed ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01012f7:	83 ec 0c             	sub    $0xc,%esp
f01012fa:	6a 00                	push   $0x0
f01012fc:	e8 a4 fb ff ff       	call   f0100ea5 <page_alloc>
f0101301:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101304:	83 c4 10             	add    $0x10,%esp
f0101307:	85 c0                	test   %eax,%eax
f0101309:	75 19                	jne    f0101324 <mem_init+0x1ad>
f010130b:	68 cc 3d 10 f0       	push   $0xf0103dcc
f0101310:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101315:	68 e1 02 00 00       	push   $0x2e1
f010131a:	68 9f 3c 10 f0       	push   $0xf0103c9f
f010131f:	e8 67 ed ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101324:	39 f7                	cmp    %esi,%edi
f0101326:	75 19                	jne    f0101341 <mem_init+0x1ca>
f0101328:	68 e2 3d 10 f0       	push   $0xf0103de2
f010132d:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101332:	68 e4 02 00 00       	push   $0x2e4
f0101337:	68 9f 3c 10 f0       	push   $0xf0103c9f
f010133c:	e8 4a ed ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101341:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101344:	39 c6                	cmp    %eax,%esi
f0101346:	74 04                	je     f010134c <mem_init+0x1d5>
f0101348:	39 c7                	cmp    %eax,%edi
f010134a:	75 19                	jne    f0101365 <mem_init+0x1ee>
f010134c:	68 f0 41 10 f0       	push   $0xf01041f0
f0101351:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101356:	68 e5 02 00 00       	push   $0x2e5
f010135b:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101360:	e8 26 ed ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101365:	8b 0d 70 79 11 f0    	mov    0xf0117970,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010136b:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f0101371:	c1 e2 0c             	shl    $0xc,%edx
f0101374:	89 f8                	mov    %edi,%eax
f0101376:	29 c8                	sub    %ecx,%eax
f0101378:	c1 f8 03             	sar    $0x3,%eax
f010137b:	c1 e0 0c             	shl    $0xc,%eax
f010137e:	39 d0                	cmp    %edx,%eax
f0101380:	72 19                	jb     f010139b <mem_init+0x224>
f0101382:	68 f4 3d 10 f0       	push   $0xf0103df4
f0101387:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010138c:	68 e6 02 00 00       	push   $0x2e6
f0101391:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101396:	e8 f0 ec ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010139b:	89 f0                	mov    %esi,%eax
f010139d:	29 c8                	sub    %ecx,%eax
f010139f:	c1 f8 03             	sar    $0x3,%eax
f01013a2:	c1 e0 0c             	shl    $0xc,%eax
f01013a5:	39 c2                	cmp    %eax,%edx
f01013a7:	77 19                	ja     f01013c2 <mem_init+0x24b>
f01013a9:	68 11 3e 10 f0       	push   $0xf0103e11
f01013ae:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01013b3:	68 e7 02 00 00       	push   $0x2e7
f01013b8:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01013bd:	e8 c9 ec ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01013c2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013c5:	29 c8                	sub    %ecx,%eax
f01013c7:	c1 f8 03             	sar    $0x3,%eax
f01013ca:	c1 e0 0c             	shl    $0xc,%eax
f01013cd:	39 c2                	cmp    %eax,%edx
f01013cf:	77 19                	ja     f01013ea <mem_init+0x273>
f01013d1:	68 2e 3e 10 f0       	push   $0xf0103e2e
f01013d6:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01013db:	68 e8 02 00 00       	push   $0x2e8
f01013e0:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01013e5:	e8 a1 ec ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01013ea:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01013ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01013f2:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f01013f9:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01013fc:	83 ec 0c             	sub    $0xc,%esp
f01013ff:	6a 00                	push   $0x0
f0101401:	e8 9f fa ff ff       	call   f0100ea5 <page_alloc>
f0101406:	83 c4 10             	add    $0x10,%esp
f0101409:	85 c0                	test   %eax,%eax
f010140b:	74 19                	je     f0101426 <mem_init+0x2af>
f010140d:	68 4b 3e 10 f0       	push   $0xf0103e4b
f0101412:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101417:	68 ef 02 00 00       	push   $0x2ef
f010141c:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101421:	e8 65 ec ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101426:	83 ec 0c             	sub    $0xc,%esp
f0101429:	57                   	push   %edi
f010142a:	e8 e7 fa ff ff       	call   f0100f16 <page_free>
	page_free(pp1);
f010142f:	89 34 24             	mov    %esi,(%esp)
f0101432:	e8 df fa ff ff       	call   f0100f16 <page_free>
	page_free(pp2);
f0101437:	83 c4 04             	add    $0x4,%esp
f010143a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010143d:	e8 d4 fa ff ff       	call   f0100f16 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101442:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101449:	e8 57 fa ff ff       	call   f0100ea5 <page_alloc>
f010144e:	89 c6                	mov    %eax,%esi
f0101450:	83 c4 10             	add    $0x10,%esp
f0101453:	85 c0                	test   %eax,%eax
f0101455:	75 19                	jne    f0101470 <mem_init+0x2f9>
f0101457:	68 a0 3d 10 f0       	push   $0xf0103da0
f010145c:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101461:	68 f6 02 00 00       	push   $0x2f6
f0101466:	68 9f 3c 10 f0       	push   $0xf0103c9f
f010146b:	e8 1b ec ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101470:	83 ec 0c             	sub    $0xc,%esp
f0101473:	6a 00                	push   $0x0
f0101475:	e8 2b fa ff ff       	call   f0100ea5 <page_alloc>
f010147a:	89 c7                	mov    %eax,%edi
f010147c:	83 c4 10             	add    $0x10,%esp
f010147f:	85 c0                	test   %eax,%eax
f0101481:	75 19                	jne    f010149c <mem_init+0x325>
f0101483:	68 b6 3d 10 f0       	push   $0xf0103db6
f0101488:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010148d:	68 f7 02 00 00       	push   $0x2f7
f0101492:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101497:	e8 ef eb ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010149c:	83 ec 0c             	sub    $0xc,%esp
f010149f:	6a 00                	push   $0x0
f01014a1:	e8 ff f9 ff ff       	call   f0100ea5 <page_alloc>
f01014a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014a9:	83 c4 10             	add    $0x10,%esp
f01014ac:	85 c0                	test   %eax,%eax
f01014ae:	75 19                	jne    f01014c9 <mem_init+0x352>
f01014b0:	68 cc 3d 10 f0       	push   $0xf0103dcc
f01014b5:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01014ba:	68 f8 02 00 00       	push   $0x2f8
f01014bf:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01014c4:	e8 c2 eb ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014c9:	39 fe                	cmp    %edi,%esi
f01014cb:	75 19                	jne    f01014e6 <mem_init+0x36f>
f01014cd:	68 e2 3d 10 f0       	push   $0xf0103de2
f01014d2:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01014d7:	68 fa 02 00 00       	push   $0x2fa
f01014dc:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01014e1:	e8 a5 eb ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014e9:	39 c7                	cmp    %eax,%edi
f01014eb:	74 04                	je     f01014f1 <mem_init+0x37a>
f01014ed:	39 c6                	cmp    %eax,%esi
f01014ef:	75 19                	jne    f010150a <mem_init+0x393>
f01014f1:	68 f0 41 10 f0       	push   $0xf01041f0
f01014f6:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01014fb:	68 fb 02 00 00       	push   $0x2fb
f0101500:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101505:	e8 81 eb ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f010150a:	83 ec 0c             	sub    $0xc,%esp
f010150d:	6a 00                	push   $0x0
f010150f:	e8 91 f9 ff ff       	call   f0100ea5 <page_alloc>
f0101514:	83 c4 10             	add    $0x10,%esp
f0101517:	85 c0                	test   %eax,%eax
f0101519:	74 19                	je     f0101534 <mem_init+0x3bd>
f010151b:	68 4b 3e 10 f0       	push   $0xf0103e4b
f0101520:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101525:	68 fc 02 00 00       	push   $0x2fc
f010152a:	68 9f 3c 10 f0       	push   $0xf0103c9f
f010152f:	e8 57 eb ff ff       	call   f010008b <_panic>
f0101534:	89 f0                	mov    %esi,%eax
f0101536:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f010153c:	c1 f8 03             	sar    $0x3,%eax
f010153f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101542:	89 c2                	mov    %eax,%edx
f0101544:	c1 ea 0c             	shr    $0xc,%edx
f0101547:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f010154d:	72 12                	jb     f0101561 <mem_init+0x3ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010154f:	50                   	push   %eax
f0101550:	68 d4 3f 10 f0       	push   $0xf0103fd4
f0101555:	6a 52                	push   $0x52
f0101557:	68 bf 3c 10 f0       	push   $0xf0103cbf
f010155c:	e8 2a eb ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101561:	83 ec 04             	sub    $0x4,%esp
f0101564:	68 00 10 00 00       	push   $0x1000
f0101569:	6a 01                	push   $0x1
f010156b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101570:	50                   	push   %eax
f0101571:	e8 23 1d 00 00       	call   f0103299 <memset>
	page_free(pp0);
f0101576:	89 34 24             	mov    %esi,(%esp)
f0101579:	e8 98 f9 ff ff       	call   f0100f16 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010157e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101585:	e8 1b f9 ff ff       	call   f0100ea5 <page_alloc>
f010158a:	83 c4 10             	add    $0x10,%esp
f010158d:	85 c0                	test   %eax,%eax
f010158f:	75 19                	jne    f01015aa <mem_init+0x433>
f0101591:	68 5a 3e 10 f0       	push   $0xf0103e5a
f0101596:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010159b:	68 01 03 00 00       	push   $0x301
f01015a0:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01015a5:	e8 e1 ea ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f01015aa:	39 c6                	cmp    %eax,%esi
f01015ac:	74 19                	je     f01015c7 <mem_init+0x450>
f01015ae:	68 78 3e 10 f0       	push   $0xf0103e78
f01015b3:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01015b8:	68 02 03 00 00       	push   $0x302
f01015bd:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01015c2:	e8 c4 ea ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015c7:	89 f0                	mov    %esi,%eax
f01015c9:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01015cf:	c1 f8 03             	sar    $0x3,%eax
f01015d2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015d5:	89 c2                	mov    %eax,%edx
f01015d7:	c1 ea 0c             	shr    $0xc,%edx
f01015da:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f01015e0:	72 12                	jb     f01015f4 <mem_init+0x47d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015e2:	50                   	push   %eax
f01015e3:	68 d4 3f 10 f0       	push   $0xf0103fd4
f01015e8:	6a 52                	push   $0x52
f01015ea:	68 bf 3c 10 f0       	push   $0xf0103cbf
f01015ef:	e8 97 ea ff ff       	call   f010008b <_panic>
f01015f4:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01015fa:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
f0101600:	80 38 00             	cmpb   $0x0,(%eax)
f0101603:	74 19                	je     f010161e <mem_init+0x4a7>
f0101605:	68 88 3e 10 f0       	push   $0xf0103e88
f010160a:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010160f:	68 06 03 00 00       	push   $0x306
f0101614:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101619:	e8 6d ea ff ff       	call   f010008b <_panic>
f010161e:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
f0101621:	39 d0                	cmp    %edx,%eax
f0101623:	75 db                	jne    f0101600 <mem_init+0x489>
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
	}

	// give free list back
	page_free_list = fl;
f0101625:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101628:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f010162d:	83 ec 0c             	sub    $0xc,%esp
f0101630:	56                   	push   %esi
f0101631:	e8 e0 f8 ff ff       	call   f0100f16 <page_free>
	page_free(pp1);
f0101636:	89 3c 24             	mov    %edi,(%esp)
f0101639:	e8 d8 f8 ff ff       	call   f0100f16 <page_free>
	page_free(pp2);
f010163e:	83 c4 04             	add    $0x4,%esp
f0101641:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101644:	e8 cd f8 ff ff       	call   f0100f16 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101649:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010164e:	83 c4 10             	add    $0x10,%esp
f0101651:	eb 05                	jmp    f0101658 <mem_init+0x4e1>
		--nfree;
f0101653:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101656:	8b 00                	mov    (%eax),%eax
f0101658:	85 c0                	test   %eax,%eax
f010165a:	75 f7                	jne    f0101653 <mem_init+0x4dc>
		--nfree;
	assert(nfree == 0);
f010165c:	85 db                	test   %ebx,%ebx
f010165e:	74 19                	je     f0101679 <mem_init+0x502>
f0101660:	68 92 3e 10 f0       	push   $0xf0103e92
f0101665:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010166a:	68 14 03 00 00       	push   $0x314
f010166f:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101674:	e8 12 ea ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101679:	83 ec 0c             	sub    $0xc,%esp
f010167c:	68 10 42 10 f0       	push   $0xf0104210
f0101681:	e8 4f 11 00 00       	call   f01027d5 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101686:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010168d:	e8 13 f8 ff ff       	call   f0100ea5 <page_alloc>
f0101692:	89 c7                	mov    %eax,%edi
f0101694:	83 c4 10             	add    $0x10,%esp
f0101697:	85 c0                	test   %eax,%eax
f0101699:	75 19                	jne    f01016b4 <mem_init+0x53d>
f010169b:	68 a0 3d 10 f0       	push   $0xf0103da0
f01016a0:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01016a5:	68 71 03 00 00       	push   $0x371
f01016aa:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01016af:	e8 d7 e9 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01016b4:	83 ec 0c             	sub    $0xc,%esp
f01016b7:	6a 00                	push   $0x0
f01016b9:	e8 e7 f7 ff ff       	call   f0100ea5 <page_alloc>
f01016be:	89 c3                	mov    %eax,%ebx
f01016c0:	83 c4 10             	add    $0x10,%esp
f01016c3:	85 c0                	test   %eax,%eax
f01016c5:	75 19                	jne    f01016e0 <mem_init+0x569>
f01016c7:	68 b6 3d 10 f0       	push   $0xf0103db6
f01016cc:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01016d1:	68 72 03 00 00       	push   $0x372
f01016d6:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01016db:	e8 ab e9 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01016e0:	83 ec 0c             	sub    $0xc,%esp
f01016e3:	6a 00                	push   $0x0
f01016e5:	e8 bb f7 ff ff       	call   f0100ea5 <page_alloc>
f01016ea:	89 c6                	mov    %eax,%esi
f01016ec:	83 c4 10             	add    $0x10,%esp
f01016ef:	85 c0                	test   %eax,%eax
f01016f1:	75 19                	jne    f010170c <mem_init+0x595>
f01016f3:	68 cc 3d 10 f0       	push   $0xf0103dcc
f01016f8:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01016fd:	68 73 03 00 00       	push   $0x373
f0101702:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101707:	e8 7f e9 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010170c:	39 df                	cmp    %ebx,%edi
f010170e:	75 19                	jne    f0101729 <mem_init+0x5b2>
f0101710:	68 e2 3d 10 f0       	push   $0xf0103de2
f0101715:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010171a:	68 76 03 00 00       	push   $0x376
f010171f:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101724:	e8 62 e9 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101729:	39 c3                	cmp    %eax,%ebx
f010172b:	74 04                	je     f0101731 <mem_init+0x5ba>
f010172d:	39 c7                	cmp    %eax,%edi
f010172f:	75 19                	jne    f010174a <mem_init+0x5d3>
f0101731:	68 f0 41 10 f0       	push   $0xf01041f0
f0101736:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010173b:	68 77 03 00 00       	push   $0x377
f0101740:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101745:	e8 41 e9 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010174a:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010174f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	page_free_list = 0;
f0101752:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0101759:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010175c:	83 ec 0c             	sub    $0xc,%esp
f010175f:	6a 00                	push   $0x0
f0101761:	e8 3f f7 ff ff       	call   f0100ea5 <page_alloc>
f0101766:	83 c4 10             	add    $0x10,%esp
f0101769:	85 c0                	test   %eax,%eax
f010176b:	74 19                	je     f0101786 <mem_init+0x60f>
f010176d:	68 4b 3e 10 f0       	push   $0xf0103e4b
f0101772:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101777:	68 7e 03 00 00       	push   $0x37e
f010177c:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101781:	e8 05 e9 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101786:	83 ec 04             	sub    $0x4,%esp
f0101789:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010178c:	50                   	push   %eax
f010178d:	6a 00                	push   $0x0
f010178f:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101795:	e8 8f f8 ff ff       	call   f0101029 <page_lookup>
f010179a:	83 c4 10             	add    $0x10,%esp
f010179d:	85 c0                	test   %eax,%eax
f010179f:	74 19                	je     f01017ba <mem_init+0x643>
f01017a1:	68 30 42 10 f0       	push   $0xf0104230
f01017a6:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01017ab:	68 81 03 00 00       	push   $0x381
f01017b0:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01017b5:	e8 d1 e8 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01017ba:	6a 02                	push   $0x2
f01017bc:	6a 00                	push   $0x0
f01017be:	53                   	push   %ebx
f01017bf:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01017c5:	e8 26 f9 ff ff       	call   f01010f0 <page_insert>
f01017ca:	83 c4 10             	add    $0x10,%esp
f01017cd:	85 c0                	test   %eax,%eax
f01017cf:	78 19                	js     f01017ea <mem_init+0x673>
f01017d1:	68 68 42 10 f0       	push   $0xf0104268
f01017d6:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01017db:	68 84 03 00 00       	push   $0x384
f01017e0:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01017e5:	e8 a1 e8 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01017ea:	83 ec 0c             	sub    $0xc,%esp
f01017ed:	57                   	push   %edi
f01017ee:	e8 23 f7 ff ff       	call   f0100f16 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01017f3:	6a 02                	push   $0x2
f01017f5:	6a 00                	push   $0x0
f01017f7:	53                   	push   %ebx
f01017f8:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01017fe:	e8 ed f8 ff ff       	call   f01010f0 <page_insert>
f0101803:	83 c4 20             	add    $0x20,%esp
f0101806:	85 c0                	test   %eax,%eax
f0101808:	74 19                	je     f0101823 <mem_init+0x6ac>
f010180a:	68 98 42 10 f0       	push   $0xf0104298
f010180f:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101814:	68 88 03 00 00       	push   $0x388
f0101819:	68 9f 3c 10 f0       	push   $0xf0103c9f
f010181e:	e8 68 e8 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101823:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101828:	8b 08                	mov    (%eax),%ecx
f010182a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101830:	89 fa                	mov    %edi,%edx
f0101832:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101838:	c1 fa 03             	sar    $0x3,%edx
f010183b:	c1 e2 0c             	shl    $0xc,%edx
f010183e:	39 d1                	cmp    %edx,%ecx
f0101840:	74 19                	je     f010185b <mem_init+0x6e4>
f0101842:	68 c8 42 10 f0       	push   $0xf01042c8
f0101847:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010184c:	68 89 03 00 00       	push   $0x389
f0101851:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101856:	e8 30 e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010185b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101860:	e8 70 f1 ff ff       	call   f01009d5 <check_va2pa>
f0101865:	89 da                	mov    %ebx,%edx
f0101867:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f010186d:	c1 fa 03             	sar    $0x3,%edx
f0101870:	c1 e2 0c             	shl    $0xc,%edx
f0101873:	39 d0                	cmp    %edx,%eax
f0101875:	74 19                	je     f0101890 <mem_init+0x719>
f0101877:	68 f0 42 10 f0       	push   $0xf01042f0
f010187c:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101881:	68 8a 03 00 00       	push   $0x38a
f0101886:	68 9f 3c 10 f0       	push   $0xf0103c9f
f010188b:	e8 fb e7 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101890:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101895:	74 19                	je     f01018b0 <mem_init+0x739>
f0101897:	68 9d 3e 10 f0       	push   $0xf0103e9d
f010189c:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01018a1:	68 8b 03 00 00       	push   $0x38b
f01018a6:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01018ab:	e8 db e7 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f01018b0:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01018b5:	74 19                	je     f01018d0 <mem_init+0x759>
f01018b7:	68 ae 3e 10 f0       	push   $0xf0103eae
f01018bc:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01018c1:	68 8c 03 00 00       	push   $0x38c
f01018c6:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01018cb:	e8 bb e7 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018d0:	6a 02                	push   $0x2
f01018d2:	68 00 10 00 00       	push   $0x1000
f01018d7:	56                   	push   %esi
f01018d8:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01018de:	e8 0d f8 ff ff       	call   f01010f0 <page_insert>
f01018e3:	83 c4 10             	add    $0x10,%esp
f01018e6:	85 c0                	test   %eax,%eax
f01018e8:	74 19                	je     f0101903 <mem_init+0x78c>
f01018ea:	68 20 43 10 f0       	push   $0xf0104320
f01018ef:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01018f4:	68 8f 03 00 00       	push   $0x38f
f01018f9:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01018fe:	e8 88 e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101903:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101908:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f010190d:	e8 c3 f0 ff ff       	call   f01009d5 <check_va2pa>
f0101912:	89 f2                	mov    %esi,%edx
f0101914:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f010191a:	c1 fa 03             	sar    $0x3,%edx
f010191d:	c1 e2 0c             	shl    $0xc,%edx
f0101920:	39 d0                	cmp    %edx,%eax
f0101922:	74 19                	je     f010193d <mem_init+0x7c6>
f0101924:	68 5c 43 10 f0       	push   $0xf010435c
f0101929:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010192e:	68 90 03 00 00       	push   $0x390
f0101933:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101938:	e8 4e e7 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f010193d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101942:	74 19                	je     f010195d <mem_init+0x7e6>
f0101944:	68 bf 3e 10 f0       	push   $0xf0103ebf
f0101949:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010194e:	68 91 03 00 00       	push   $0x391
f0101953:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101958:	e8 2e e7 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010195d:	83 ec 0c             	sub    $0xc,%esp
f0101960:	6a 00                	push   $0x0
f0101962:	e8 3e f5 ff ff       	call   f0100ea5 <page_alloc>
f0101967:	83 c4 10             	add    $0x10,%esp
f010196a:	85 c0                	test   %eax,%eax
f010196c:	74 19                	je     f0101987 <mem_init+0x810>
f010196e:	68 4b 3e 10 f0       	push   $0xf0103e4b
f0101973:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101978:	68 94 03 00 00       	push   $0x394
f010197d:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101982:	e8 04 e7 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101987:	6a 02                	push   $0x2
f0101989:	68 00 10 00 00       	push   $0x1000
f010198e:	56                   	push   %esi
f010198f:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101995:	e8 56 f7 ff ff       	call   f01010f0 <page_insert>
f010199a:	83 c4 10             	add    $0x10,%esp
f010199d:	85 c0                	test   %eax,%eax
f010199f:	74 19                	je     f01019ba <mem_init+0x843>
f01019a1:	68 20 43 10 f0       	push   $0xf0104320
f01019a6:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01019ab:	68 97 03 00 00       	push   $0x397
f01019b0:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01019b5:	e8 d1 e6 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019ba:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019bf:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f01019c4:	e8 0c f0 ff ff       	call   f01009d5 <check_va2pa>
f01019c9:	89 f2                	mov    %esi,%edx
f01019cb:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f01019d1:	c1 fa 03             	sar    $0x3,%edx
f01019d4:	c1 e2 0c             	shl    $0xc,%edx
f01019d7:	39 d0                	cmp    %edx,%eax
f01019d9:	74 19                	je     f01019f4 <mem_init+0x87d>
f01019db:	68 5c 43 10 f0       	push   $0xf010435c
f01019e0:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01019e5:	68 98 03 00 00       	push   $0x398
f01019ea:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01019ef:	e8 97 e6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01019f4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019f9:	74 19                	je     f0101a14 <mem_init+0x89d>
f01019fb:	68 bf 3e 10 f0       	push   $0xf0103ebf
f0101a00:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101a05:	68 99 03 00 00       	push   $0x399
f0101a0a:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101a0f:	e8 77 e6 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a14:	83 ec 0c             	sub    $0xc,%esp
f0101a17:	6a 00                	push   $0x0
f0101a19:	e8 87 f4 ff ff       	call   f0100ea5 <page_alloc>
f0101a1e:	83 c4 10             	add    $0x10,%esp
f0101a21:	85 c0                	test   %eax,%eax
f0101a23:	74 19                	je     f0101a3e <mem_init+0x8c7>
f0101a25:	68 4b 3e 10 f0       	push   $0xf0103e4b
f0101a2a:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101a2f:	68 9d 03 00 00       	push   $0x39d
f0101a34:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101a39:	e8 4d e6 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a3e:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
f0101a44:	8b 02                	mov    (%edx),%eax
f0101a46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a4b:	89 c1                	mov    %eax,%ecx
f0101a4d:	c1 e9 0c             	shr    $0xc,%ecx
f0101a50:	3b 0d 68 79 11 f0    	cmp    0xf0117968,%ecx
f0101a56:	72 15                	jb     f0101a6d <mem_init+0x8f6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a58:	50                   	push   %eax
f0101a59:	68 d4 3f 10 f0       	push   $0xf0103fd4
f0101a5e:	68 a0 03 00 00       	push   $0x3a0
f0101a63:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101a68:	e8 1e e6 ff ff       	call   f010008b <_panic>
f0101a6d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a75:	83 ec 04             	sub    $0x4,%esp
f0101a78:	6a 00                	push   $0x0
f0101a7a:	68 00 10 00 00       	push   $0x1000
f0101a7f:	52                   	push   %edx
f0101a80:	e8 0e f5 ff ff       	call   f0100f93 <pgdir_walk>
f0101a85:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a88:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a8b:	83 c4 10             	add    $0x10,%esp
f0101a8e:	39 d0                	cmp    %edx,%eax
f0101a90:	74 19                	je     f0101aab <mem_init+0x934>
f0101a92:	68 8c 43 10 f0       	push   $0xf010438c
f0101a97:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101a9c:	68 a1 03 00 00       	push   $0x3a1
f0101aa1:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101aa6:	e8 e0 e5 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101aab:	6a 06                	push   $0x6
f0101aad:	68 00 10 00 00       	push   $0x1000
f0101ab2:	56                   	push   %esi
f0101ab3:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101ab9:	e8 32 f6 ff ff       	call   f01010f0 <page_insert>
f0101abe:	83 c4 10             	add    $0x10,%esp
f0101ac1:	85 c0                	test   %eax,%eax
f0101ac3:	74 19                	je     f0101ade <mem_init+0x967>
f0101ac5:	68 cc 43 10 f0       	push   $0xf01043cc
f0101aca:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101acf:	68 a4 03 00 00       	push   $0x3a4
f0101ad4:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101ad9:	e8 ad e5 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ade:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ae3:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101ae8:	e8 e8 ee ff ff       	call   f01009d5 <check_va2pa>
f0101aed:	89 f2                	mov    %esi,%edx
f0101aef:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101af5:	c1 fa 03             	sar    $0x3,%edx
f0101af8:	c1 e2 0c             	shl    $0xc,%edx
f0101afb:	39 d0                	cmp    %edx,%eax
f0101afd:	74 19                	je     f0101b18 <mem_init+0x9a1>
f0101aff:	68 5c 43 10 f0       	push   $0xf010435c
f0101b04:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101b09:	68 a5 03 00 00       	push   $0x3a5
f0101b0e:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101b13:	e8 73 e5 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101b18:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b1d:	74 19                	je     f0101b38 <mem_init+0x9c1>
f0101b1f:	68 bf 3e 10 f0       	push   $0xf0103ebf
f0101b24:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101b29:	68 a6 03 00 00       	push   $0x3a6
f0101b2e:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101b33:	e8 53 e5 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b38:	83 ec 04             	sub    $0x4,%esp
f0101b3b:	6a 00                	push   $0x0
f0101b3d:	68 00 10 00 00       	push   $0x1000
f0101b42:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101b48:	e8 46 f4 ff ff       	call   f0100f93 <pgdir_walk>
f0101b4d:	83 c4 10             	add    $0x10,%esp
f0101b50:	f6 00 04             	testb  $0x4,(%eax)
f0101b53:	75 19                	jne    f0101b6e <mem_init+0x9f7>
f0101b55:	68 0c 44 10 f0       	push   $0xf010440c
f0101b5a:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101b5f:	68 a7 03 00 00       	push   $0x3a7
f0101b64:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101b69:	e8 1d e5 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101b6e:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101b73:	f6 00 04             	testb  $0x4,(%eax)
f0101b76:	75 19                	jne    f0101b91 <mem_init+0xa1a>
f0101b78:	68 d0 3e 10 f0       	push   $0xf0103ed0
f0101b7d:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101b82:	68 a8 03 00 00       	push   $0x3a8
f0101b87:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101b8c:	e8 fa e4 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b91:	6a 02                	push   $0x2
f0101b93:	68 00 10 00 00       	push   $0x1000
f0101b98:	56                   	push   %esi
f0101b99:	50                   	push   %eax
f0101b9a:	e8 51 f5 ff ff       	call   f01010f0 <page_insert>
f0101b9f:	83 c4 10             	add    $0x10,%esp
f0101ba2:	85 c0                	test   %eax,%eax
f0101ba4:	74 19                	je     f0101bbf <mem_init+0xa48>
f0101ba6:	68 20 43 10 f0       	push   $0xf0104320
f0101bab:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101bb0:	68 ab 03 00 00       	push   $0x3ab
f0101bb5:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101bba:	e8 cc e4 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101bbf:	83 ec 04             	sub    $0x4,%esp
f0101bc2:	6a 00                	push   $0x0
f0101bc4:	68 00 10 00 00       	push   $0x1000
f0101bc9:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101bcf:	e8 bf f3 ff ff       	call   f0100f93 <pgdir_walk>
f0101bd4:	83 c4 10             	add    $0x10,%esp
f0101bd7:	f6 00 02             	testb  $0x2,(%eax)
f0101bda:	75 19                	jne    f0101bf5 <mem_init+0xa7e>
f0101bdc:	68 40 44 10 f0       	push   $0xf0104440
f0101be1:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101be6:	68 ac 03 00 00       	push   $0x3ac
f0101beb:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101bf0:	e8 96 e4 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bf5:	83 ec 04             	sub    $0x4,%esp
f0101bf8:	6a 00                	push   $0x0
f0101bfa:	68 00 10 00 00       	push   $0x1000
f0101bff:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101c05:	e8 89 f3 ff ff       	call   f0100f93 <pgdir_walk>
f0101c0a:	83 c4 10             	add    $0x10,%esp
f0101c0d:	f6 00 04             	testb  $0x4,(%eax)
f0101c10:	74 19                	je     f0101c2b <mem_init+0xab4>
f0101c12:	68 74 44 10 f0       	push   $0xf0104474
f0101c17:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101c1c:	68 ad 03 00 00       	push   $0x3ad
f0101c21:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101c26:	e8 60 e4 ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c2b:	6a 02                	push   $0x2
f0101c2d:	68 00 00 40 00       	push   $0x400000
f0101c32:	57                   	push   %edi
f0101c33:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101c39:	e8 b2 f4 ff ff       	call   f01010f0 <page_insert>
f0101c3e:	83 c4 10             	add    $0x10,%esp
f0101c41:	85 c0                	test   %eax,%eax
f0101c43:	78 19                	js     f0101c5e <mem_init+0xae7>
f0101c45:	68 ac 44 10 f0       	push   $0xf01044ac
f0101c4a:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101c4f:	68 b0 03 00 00       	push   $0x3b0
f0101c54:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101c59:	e8 2d e4 ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c5e:	6a 02                	push   $0x2
f0101c60:	68 00 10 00 00       	push   $0x1000
f0101c65:	53                   	push   %ebx
f0101c66:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101c6c:	e8 7f f4 ff ff       	call   f01010f0 <page_insert>
f0101c71:	83 c4 10             	add    $0x10,%esp
f0101c74:	85 c0                	test   %eax,%eax
f0101c76:	74 19                	je     f0101c91 <mem_init+0xb1a>
f0101c78:	68 e4 44 10 f0       	push   $0xf01044e4
f0101c7d:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101c82:	68 b3 03 00 00       	push   $0x3b3
f0101c87:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101c8c:	e8 fa e3 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c91:	83 ec 04             	sub    $0x4,%esp
f0101c94:	6a 00                	push   $0x0
f0101c96:	68 00 10 00 00       	push   $0x1000
f0101c9b:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101ca1:	e8 ed f2 ff ff       	call   f0100f93 <pgdir_walk>
f0101ca6:	83 c4 10             	add    $0x10,%esp
f0101ca9:	f6 00 04             	testb  $0x4,(%eax)
f0101cac:	74 19                	je     f0101cc7 <mem_init+0xb50>
f0101cae:	68 74 44 10 f0       	push   $0xf0104474
f0101cb3:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101cb8:	68 b4 03 00 00       	push   $0x3b4
f0101cbd:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101cc2:	e8 c4 e3 ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101cc7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ccc:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101cd1:	e8 ff ec ff ff       	call   f01009d5 <check_va2pa>
f0101cd6:	89 da                	mov    %ebx,%edx
f0101cd8:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101cde:	c1 fa 03             	sar    $0x3,%edx
f0101ce1:	c1 e2 0c             	shl    $0xc,%edx
f0101ce4:	39 d0                	cmp    %edx,%eax
f0101ce6:	74 19                	je     f0101d01 <mem_init+0xb8a>
f0101ce8:	68 20 45 10 f0       	push   $0xf0104520
f0101ced:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101cf2:	68 b7 03 00 00       	push   $0x3b7
f0101cf7:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101cfc:	e8 8a e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d01:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d06:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101d0b:	e8 c5 ec ff ff       	call   f01009d5 <check_va2pa>
f0101d10:	89 da                	mov    %ebx,%edx
f0101d12:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101d18:	c1 fa 03             	sar    $0x3,%edx
f0101d1b:	c1 e2 0c             	shl    $0xc,%edx
f0101d1e:	39 d0                	cmp    %edx,%eax
f0101d20:	74 19                	je     f0101d3b <mem_init+0xbc4>
f0101d22:	68 4c 45 10 f0       	push   $0xf010454c
f0101d27:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101d2c:	68 b8 03 00 00       	push   $0x3b8
f0101d31:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101d36:	e8 50 e3 ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d3b:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101d40:	74 19                	je     f0101d5b <mem_init+0xbe4>
f0101d42:	68 e6 3e 10 f0       	push   $0xf0103ee6
f0101d47:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101d4c:	68 ba 03 00 00       	push   $0x3ba
f0101d51:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101d56:	e8 30 e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101d5b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d60:	74 19                	je     f0101d7b <mem_init+0xc04>
f0101d62:	68 f7 3e 10 f0       	push   $0xf0103ef7
f0101d67:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101d6c:	68 bb 03 00 00       	push   $0x3bb
f0101d71:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101d76:	e8 10 e3 ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d7b:	83 ec 0c             	sub    $0xc,%esp
f0101d7e:	6a 00                	push   $0x0
f0101d80:	e8 20 f1 ff ff       	call   f0100ea5 <page_alloc>
f0101d85:	83 c4 10             	add    $0x10,%esp
f0101d88:	85 c0                	test   %eax,%eax
f0101d8a:	74 04                	je     f0101d90 <mem_init+0xc19>
f0101d8c:	39 c6                	cmp    %eax,%esi
f0101d8e:	74 19                	je     f0101da9 <mem_init+0xc32>
f0101d90:	68 7c 45 10 f0       	push   $0xf010457c
f0101d95:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101d9a:	68 be 03 00 00       	push   $0x3be
f0101d9f:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101da4:	e8 e2 e2 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	cprintf("[?] wrong here\n");
f0101da9:	83 ec 0c             	sub    $0xc,%esp
f0101dac:	68 08 3f 10 f0       	push   $0xf0103f08
f0101db1:	e8 1f 0a 00 00       	call   f01027d5 <cprintf>
	page_remove(kern_pgdir, 0x0);
f0101db6:	83 c4 08             	add    $0x8,%esp
f0101db9:	6a 00                	push   $0x0
f0101dbb:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101dc1:	e8 e8 f2 ff ff       	call   f01010ae <page_remove>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101dc6:	89 d8                	mov    %ebx,%eax
f0101dc8:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0101dce:	c1 f8 03             	sar    $0x3,%eax
f0101dd1:	c1 e0 0c             	shl    $0xc,%eax
f0101dd4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	cprintf("[?] %d, %x, %x\n", pp1->pp_ref, check_va2pa(kern_pgdir, 0x0), page2pa(pp1));
f0101dd7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ddc:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101de1:	e8 ef eb ff ff       	call   f01009d5 <check_va2pa>
f0101de6:	ff 75 d0             	pushl  -0x30(%ebp)
f0101de9:	50                   	push   %eax
f0101dea:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0101dee:	50                   	push   %eax
f0101def:	68 18 3f 10 f0       	push   $0xf0103f18
f0101df4:	e8 dc 09 00 00       	call   f01027d5 <cprintf>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101df9:	83 c4 20             	add    $0x20,%esp
f0101dfc:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e01:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101e06:	e8 ca eb ff ff       	call   f01009d5 <check_va2pa>
f0101e0b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e0e:	74 19                	je     f0101e29 <mem_init+0xcb2>
f0101e10:	68 a0 45 10 f0       	push   $0xf01045a0
f0101e15:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101e1a:	68 c4 03 00 00       	push   $0x3c4
f0101e1f:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101e24:	e8 62 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e29:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e2e:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101e33:	e8 9d eb ff ff       	call   f01009d5 <check_va2pa>
f0101e38:	89 da                	mov    %ebx,%edx
f0101e3a:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101e40:	c1 fa 03             	sar    $0x3,%edx
f0101e43:	c1 e2 0c             	shl    $0xc,%edx
f0101e46:	39 d0                	cmp    %edx,%eax
f0101e48:	74 19                	je     f0101e63 <mem_init+0xcec>
f0101e4a:	68 4c 45 10 f0       	push   $0xf010454c
f0101e4f:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101e54:	68 c5 03 00 00       	push   $0x3c5
f0101e59:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101e5e:	e8 28 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101e63:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e68:	74 19                	je     f0101e83 <mem_init+0xd0c>
f0101e6a:	68 9d 3e 10 f0       	push   $0xf0103e9d
f0101e6f:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101e74:	68 c6 03 00 00       	push   $0x3c6
f0101e79:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101e7e:	e8 08 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101e83:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e88:	74 19                	je     f0101ea3 <mem_init+0xd2c>
f0101e8a:	68 f7 3e 10 f0       	push   $0xf0103ef7
f0101e8f:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101e94:	68 c7 03 00 00       	push   $0x3c7
f0101e99:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101e9e:	e8 e8 e1 ff ff       	call   f010008b <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101ea3:	6a 00                	push   $0x0
f0101ea5:	68 00 10 00 00       	push   $0x1000
f0101eaa:	53                   	push   %ebx
f0101eab:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101eb1:	e8 3a f2 ff ff       	call   f01010f0 <page_insert>
f0101eb6:	83 c4 10             	add    $0x10,%esp
f0101eb9:	85 c0                	test   %eax,%eax
f0101ebb:	74 19                	je     f0101ed6 <mem_init+0xd5f>
f0101ebd:	68 c4 45 10 f0       	push   $0xf01045c4
f0101ec2:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101ec7:	68 ca 03 00 00       	push   $0x3ca
f0101ecc:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101ed1:	e8 b5 e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f0101ed6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101edb:	75 19                	jne    f0101ef6 <mem_init+0xd7f>
f0101edd:	68 28 3f 10 f0       	push   $0xf0103f28
f0101ee2:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101ee7:	68 cb 03 00 00       	push   $0x3cb
f0101eec:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101ef1:	e8 95 e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f0101ef6:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101ef9:	74 19                	je     f0101f14 <mem_init+0xd9d>
f0101efb:	68 34 3f 10 f0       	push   $0xf0103f34
f0101f00:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101f05:	68 cc 03 00 00       	push   $0x3cc
f0101f0a:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101f0f:	e8 77 e1 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f14:	83 ec 08             	sub    $0x8,%esp
f0101f17:	68 00 10 00 00       	push   $0x1000
f0101f1c:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101f22:	e8 87 f1 ff ff       	call   f01010ae <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f27:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f2c:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101f31:	e8 9f ea ff ff       	call   f01009d5 <check_va2pa>
f0101f36:	83 c4 10             	add    $0x10,%esp
f0101f39:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f3c:	74 19                	je     f0101f57 <mem_init+0xde0>
f0101f3e:	68 a0 45 10 f0       	push   $0xf01045a0
f0101f43:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101f48:	68 d0 03 00 00       	push   $0x3d0
f0101f4d:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101f52:	e8 34 e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f57:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f5c:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101f61:	e8 6f ea ff ff       	call   f01009d5 <check_va2pa>
f0101f66:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f69:	74 19                	je     f0101f84 <mem_init+0xe0d>
f0101f6b:	68 fc 45 10 f0       	push   $0xf01045fc
f0101f70:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101f75:	68 d1 03 00 00       	push   $0x3d1
f0101f7a:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101f7f:	e8 07 e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0101f84:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f89:	74 19                	je     f0101fa4 <mem_init+0xe2d>
f0101f8b:	68 49 3f 10 f0       	push   $0xf0103f49
f0101f90:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101f95:	68 d2 03 00 00       	push   $0x3d2
f0101f9a:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101f9f:	e8 e7 e0 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101fa4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fa9:	74 19                	je     f0101fc4 <mem_init+0xe4d>
f0101fab:	68 f7 3e 10 f0       	push   $0xf0103ef7
f0101fb0:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101fb5:	68 d3 03 00 00       	push   $0x3d3
f0101fba:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101fbf:	e8 c7 e0 ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101fc4:	83 ec 0c             	sub    $0xc,%esp
f0101fc7:	6a 00                	push   $0x0
f0101fc9:	e8 d7 ee ff ff       	call   f0100ea5 <page_alloc>
f0101fce:	83 c4 10             	add    $0x10,%esp
f0101fd1:	39 c3                	cmp    %eax,%ebx
f0101fd3:	75 04                	jne    f0101fd9 <mem_init+0xe62>
f0101fd5:	85 c0                	test   %eax,%eax
f0101fd7:	75 19                	jne    f0101ff2 <mem_init+0xe7b>
f0101fd9:	68 24 46 10 f0       	push   $0xf0104624
f0101fde:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0101fe3:	68 d6 03 00 00       	push   $0x3d6
f0101fe8:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0101fed:	e8 99 e0 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ff2:	83 ec 0c             	sub    $0xc,%esp
f0101ff5:	6a 00                	push   $0x0
f0101ff7:	e8 a9 ee ff ff       	call   f0100ea5 <page_alloc>
f0101ffc:	83 c4 10             	add    $0x10,%esp
f0101fff:	85 c0                	test   %eax,%eax
f0102001:	74 19                	je     f010201c <mem_init+0xea5>
f0102003:	68 4b 3e 10 f0       	push   $0xf0103e4b
f0102008:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010200d:	68 d9 03 00 00       	push   $0x3d9
f0102012:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0102017:	e8 6f e0 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010201c:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
f0102022:	8b 11                	mov    (%ecx),%edx
f0102024:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010202a:	89 f8                	mov    %edi,%eax
f010202c:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0102032:	c1 f8 03             	sar    $0x3,%eax
f0102035:	c1 e0 0c             	shl    $0xc,%eax
f0102038:	39 c2                	cmp    %eax,%edx
f010203a:	74 19                	je     f0102055 <mem_init+0xede>
f010203c:	68 c8 42 10 f0       	push   $0xf01042c8
f0102041:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0102046:	68 dc 03 00 00       	push   $0x3dc
f010204b:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0102050:	e8 36 e0 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102055:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010205b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102060:	74 19                	je     f010207b <mem_init+0xf04>
f0102062:	68 ae 3e 10 f0       	push   $0xf0103eae
f0102067:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010206c:	68 de 03 00 00       	push   $0x3de
f0102071:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0102076:	e8 10 e0 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f010207b:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102081:	83 ec 0c             	sub    $0xc,%esp
f0102084:	57                   	push   %edi
f0102085:	e8 8c ee ff ff       	call   f0100f16 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010208a:	83 c4 0c             	add    $0xc,%esp
f010208d:	6a 01                	push   $0x1
f010208f:	68 00 10 40 00       	push   $0x401000
f0102094:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f010209a:	e8 f4 ee ff ff       	call   f0100f93 <pgdir_walk>
f010209f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01020a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01020a5:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f01020aa:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01020ad:	8b 40 04             	mov    0x4(%eax),%eax
f01020b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020b5:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f01020bb:	89 c2                	mov    %eax,%edx
f01020bd:	c1 ea 0c             	shr    $0xc,%edx
f01020c0:	83 c4 10             	add    $0x10,%esp
f01020c3:	39 ca                	cmp    %ecx,%edx
f01020c5:	72 15                	jb     f01020dc <mem_init+0xf65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020c7:	50                   	push   %eax
f01020c8:	68 d4 3f 10 f0       	push   $0xf0103fd4
f01020cd:	68 e5 03 00 00       	push   $0x3e5
f01020d2:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01020d7:	e8 af df ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f01020dc:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01020e1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01020e4:	74 19                	je     f01020ff <mem_init+0xf88>
f01020e6:	68 5a 3f 10 f0       	push   $0xf0103f5a
f01020eb:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01020f0:	68 e6 03 00 00       	push   $0x3e6
f01020f5:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01020fa:	e8 8c df ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f01020ff:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102102:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102109:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010210f:	89 f8                	mov    %edi,%eax
f0102111:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0102117:	c1 f8 03             	sar    $0x3,%eax
f010211a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010211d:	89 c2                	mov    %eax,%edx
f010211f:	c1 ea 0c             	shr    $0xc,%edx
f0102122:	39 d1                	cmp    %edx,%ecx
f0102124:	77 12                	ja     f0102138 <mem_init+0xfc1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102126:	50                   	push   %eax
f0102127:	68 d4 3f 10 f0       	push   $0xf0103fd4
f010212c:	6a 52                	push   $0x52
f010212e:	68 bf 3c 10 f0       	push   $0xf0103cbf
f0102133:	e8 53 df ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102138:	83 ec 04             	sub    $0x4,%esp
f010213b:	68 00 10 00 00       	push   $0x1000
f0102140:	68 ff 00 00 00       	push   $0xff
f0102145:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010214a:	50                   	push   %eax
f010214b:	e8 49 11 00 00       	call   f0103299 <memset>
	page_free(pp0);
f0102150:	89 3c 24             	mov    %edi,(%esp)
f0102153:	e8 be ed ff ff       	call   f0100f16 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102158:	83 c4 0c             	add    $0xc,%esp
f010215b:	6a 01                	push   $0x1
f010215d:	6a 00                	push   $0x0
f010215f:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0102165:	e8 29 ee ff ff       	call   f0100f93 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010216a:	89 fa                	mov    %edi,%edx
f010216c:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0102172:	c1 fa 03             	sar    $0x3,%edx
f0102175:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102178:	89 d0                	mov    %edx,%eax
f010217a:	c1 e8 0c             	shr    $0xc,%eax
f010217d:	83 c4 10             	add    $0x10,%esp
f0102180:	3b 05 68 79 11 f0    	cmp    0xf0117968,%eax
f0102186:	72 12                	jb     f010219a <mem_init+0x1023>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102188:	52                   	push   %edx
f0102189:	68 d4 3f 10 f0       	push   $0xf0103fd4
f010218e:	6a 52                	push   $0x52
f0102190:	68 bf 3c 10 f0       	push   $0xf0103cbf
f0102195:	e8 f1 de ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f010219a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01021a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01021a3:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01021a9:	f6 00 01             	testb  $0x1,(%eax)
f01021ac:	74 19                	je     f01021c7 <mem_init+0x1050>
f01021ae:	68 72 3f 10 f0       	push   $0xf0103f72
f01021b3:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01021b8:	68 f0 03 00 00       	push   $0x3f0
f01021bd:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01021c2:	e8 c4 de ff ff       	call   f010008b <_panic>
f01021c7:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01021ca:	39 d0                	cmp    %edx,%eax
f01021cc:	75 db                	jne    f01021a9 <mem_init+0x1032>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01021ce:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f01021d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01021d9:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01021df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021e2:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f01021e7:	83 ec 0c             	sub    $0xc,%esp
f01021ea:	57                   	push   %edi
f01021eb:	e8 26 ed ff ff       	call   f0100f16 <page_free>
	page_free(pp1);
f01021f0:	89 1c 24             	mov    %ebx,(%esp)
f01021f3:	e8 1e ed ff ff       	call   f0100f16 <page_free>
	page_free(pp2);
f01021f8:	89 34 24             	mov    %esi,(%esp)
f01021fb:	e8 16 ed ff ff       	call   f0100f16 <page_free>

	cprintf("check_page() succeeded!\n");
f0102200:	c7 04 24 89 3f 10 f0 	movl   $0xf0103f89,(%esp)
f0102207:	e8 c9 05 00 00       	call   f01027d5 <cprintf>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010220c:	8b 35 6c 79 11 f0    	mov    0xf011796c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102212:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102217:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
f010221e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102224:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f0102227:	bb 00 00 00 00       	mov    $0x0,%ebx
f010222c:	eb 5a                	jmp    f0102288 <mem_init+0x1111>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010222e:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102234:	89 f0                	mov    %esi,%eax
f0102236:	e8 9a e7 ff ff       	call   f01009d5 <check_va2pa>
f010223b:	8b 15 70 79 11 f0    	mov    0xf0117970,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102241:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102247:	77 15                	ja     f010225e <mem_init+0x10e7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102249:	52                   	push   %edx
f010224a:	68 04 41 10 f0       	push   $0xf0104104
f010224f:	68 2c 03 00 00       	push   $0x32c
f0102254:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0102259:	e8 2d de ff ff       	call   f010008b <_panic>
f010225e:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f0102265:	39 d0                	cmp    %edx,%eax
f0102267:	74 19                	je     f0102282 <mem_init+0x110b>
f0102269:	68 48 46 10 f0       	push   $0xf0104648
f010226e:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0102273:	68 2c 03 00 00       	push   $0x32c
f0102278:	68 9f 3c 10 f0       	push   $0xf0103c9f
f010227d:	e8 09 de ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102282:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102288:	39 df                	cmp    %ebx,%edi
f010228a:	77 a2                	ja     f010222e <mem_init+0x10b7>
f010228c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102291:	eb 30                	jmp    f01022c3 <mem_init+0x114c>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102293:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102299:	89 f0                	mov    %esi,%eax
f010229b:	e8 35 e7 ff ff       	call   f01009d5 <check_va2pa>
f01022a0:	39 c3                	cmp    %eax,%ebx
f01022a2:	74 19                	je     f01022bd <mem_init+0x1146>
f01022a4:	68 7c 46 10 f0       	push   $0xf010467c
f01022a9:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01022ae:	68 31 03 00 00       	push   $0x331
f01022b3:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01022b8:	e8 ce dd ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01022bd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01022c3:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01022c8:	c1 e0 0c             	shl    $0xc,%eax
f01022cb:	39 c3                	cmp    %eax,%ebx
f01022cd:	72 c4                	jb     f0102293 <mem_init+0x111c>
f01022cf:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022d4:	bf 00 d0 10 f0       	mov    $0xf010d000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01022d9:	89 da                	mov    %ebx,%edx
f01022db:	89 f0                	mov    %esi,%eax
f01022dd:	e8 f3 e6 ff ff       	call   f01009d5 <check_va2pa>
f01022e2:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01022e8:	77 19                	ja     f0102303 <mem_init+0x118c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022ea:	68 00 d0 10 f0       	push   $0xf010d000
f01022ef:	68 04 41 10 f0       	push   $0xf0104104
f01022f4:	68 35 03 00 00       	push   $0x335
f01022f9:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01022fe:	e8 88 dd ff ff       	call   f010008b <_panic>
f0102303:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f0102309:	39 d0                	cmp    %edx,%eax
f010230b:	74 19                	je     f0102326 <mem_init+0x11af>
f010230d:	68 a4 46 10 f0       	push   $0xf01046a4
f0102312:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0102317:	68 35 03 00 00       	push   $0x335
f010231c:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0102321:	e8 65 dd ff ff       	call   f010008b <_panic>
f0102326:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010232c:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102332:	75 a5                	jne    f01022d9 <mem_init+0x1162>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102334:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102339:	89 f0                	mov    %esi,%eax
f010233b:	e8 95 e6 ff ff       	call   f01009d5 <check_va2pa>
f0102340:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102343:	74 51                	je     f0102396 <mem_init+0x121f>
f0102345:	68 ec 46 10 f0       	push   $0xf01046ec
f010234a:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010234f:	68 36 03 00 00       	push   $0x336
f0102354:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0102359:	e8 2d dd ff ff       	call   f010008b <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010235e:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102363:	72 36                	jb     f010239b <mem_init+0x1224>
f0102365:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010236a:	76 07                	jbe    f0102373 <mem_init+0x11fc>
f010236c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102371:	75 28                	jne    f010239b <mem_init+0x1224>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102373:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102377:	0f 85 83 00 00 00    	jne    f0102400 <mem_init+0x1289>
f010237d:	68 a2 3f 10 f0       	push   $0xf0103fa2
f0102382:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0102387:	68 3e 03 00 00       	push   $0x33e
f010238c:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0102391:	e8 f5 dc ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102396:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010239b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01023a0:	76 3f                	jbe    f01023e1 <mem_init+0x126a>
				assert(pgdir[i] & PTE_P);
f01023a2:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01023a5:	f6 c2 01             	test   $0x1,%dl
f01023a8:	75 19                	jne    f01023c3 <mem_init+0x124c>
f01023aa:	68 a2 3f 10 f0       	push   $0xf0103fa2
f01023af:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01023b4:	68 42 03 00 00       	push   $0x342
f01023b9:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01023be:	e8 c8 dc ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f01023c3:	f6 c2 02             	test   $0x2,%dl
f01023c6:	75 38                	jne    f0102400 <mem_init+0x1289>
f01023c8:	68 b3 3f 10 f0       	push   $0xf0103fb3
f01023cd:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01023d2:	68 43 03 00 00       	push   $0x343
f01023d7:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01023dc:	e8 aa dc ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f01023e1:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f01023e5:	74 19                	je     f0102400 <mem_init+0x1289>
f01023e7:	68 c4 3f 10 f0       	push   $0xf0103fc4
f01023ec:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01023f1:	68 45 03 00 00       	push   $0x345
f01023f6:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01023fb:	e8 8b dc ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102400:	83 c0 01             	add    $0x1,%eax
f0102403:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102408:	0f 86 50 ff ff ff    	jbe    f010235e <mem_init+0x11e7>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010240e:	83 ec 0c             	sub    $0xc,%esp
f0102411:	68 1c 47 10 f0       	push   $0xf010471c
f0102416:	e8 ba 03 00 00       	call   f01027d5 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010241b:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102420:	83 c4 10             	add    $0x10,%esp
f0102423:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102428:	77 15                	ja     f010243f <mem_init+0x12c8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010242a:	50                   	push   %eax
f010242b:	68 04 41 10 f0       	push   $0xf0104104
f0102430:	68 dc 00 00 00       	push   $0xdc
f0102435:	68 9f 3c 10 f0       	push   $0xf0103c9f
f010243a:	e8 4c dc ff ff       	call   f010008b <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010243f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102444:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102447:	b8 00 00 00 00       	mov    $0x0,%eax
f010244c:	e8 15 e6 ff ff       	call   f0100a66 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102451:	0f 20 c0             	mov    %cr0,%eax
f0102454:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102457:	0d 23 00 05 80       	or     $0x80050023,%eax
f010245c:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010245f:	83 ec 0c             	sub    $0xc,%esp
f0102462:	6a 00                	push   $0x0
f0102464:	e8 3c ea ff ff       	call   f0100ea5 <page_alloc>
f0102469:	89 c3                	mov    %eax,%ebx
f010246b:	83 c4 10             	add    $0x10,%esp
f010246e:	85 c0                	test   %eax,%eax
f0102470:	75 19                	jne    f010248b <mem_init+0x1314>
f0102472:	68 a0 3d 10 f0       	push   $0xf0103da0
f0102477:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010247c:	68 0b 04 00 00       	push   $0x40b
f0102481:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0102486:	e8 00 dc ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010248b:	83 ec 0c             	sub    $0xc,%esp
f010248e:	6a 00                	push   $0x0
f0102490:	e8 10 ea ff ff       	call   f0100ea5 <page_alloc>
f0102495:	89 c7                	mov    %eax,%edi
f0102497:	83 c4 10             	add    $0x10,%esp
f010249a:	85 c0                	test   %eax,%eax
f010249c:	75 19                	jne    f01024b7 <mem_init+0x1340>
f010249e:	68 b6 3d 10 f0       	push   $0xf0103db6
f01024a3:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01024a8:	68 0c 04 00 00       	push   $0x40c
f01024ad:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01024b2:	e8 d4 db ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01024b7:	83 ec 0c             	sub    $0xc,%esp
f01024ba:	6a 00                	push   $0x0
f01024bc:	e8 e4 e9 ff ff       	call   f0100ea5 <page_alloc>
f01024c1:	89 c6                	mov    %eax,%esi
f01024c3:	83 c4 10             	add    $0x10,%esp
f01024c6:	85 c0                	test   %eax,%eax
f01024c8:	75 19                	jne    f01024e3 <mem_init+0x136c>
f01024ca:	68 cc 3d 10 f0       	push   $0xf0103dcc
f01024cf:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01024d4:	68 0d 04 00 00       	push   $0x40d
f01024d9:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01024de:	e8 a8 db ff ff       	call   f010008b <_panic>
	page_free(pp0);
f01024e3:	83 ec 0c             	sub    $0xc,%esp
f01024e6:	53                   	push   %ebx
f01024e7:	e8 2a ea ff ff       	call   f0100f16 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024ec:	89 f8                	mov    %edi,%eax
f01024ee:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01024f4:	c1 f8 03             	sar    $0x3,%eax
f01024f7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024fa:	89 c2                	mov    %eax,%edx
f01024fc:	c1 ea 0c             	shr    $0xc,%edx
f01024ff:	83 c4 10             	add    $0x10,%esp
f0102502:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0102508:	72 12                	jb     f010251c <mem_init+0x13a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010250a:	50                   	push   %eax
f010250b:	68 d4 3f 10 f0       	push   $0xf0103fd4
f0102510:	6a 52                	push   $0x52
f0102512:	68 bf 3c 10 f0       	push   $0xf0103cbf
f0102517:	e8 6f db ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010251c:	83 ec 04             	sub    $0x4,%esp
f010251f:	68 00 10 00 00       	push   $0x1000
f0102524:	6a 01                	push   $0x1
f0102526:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010252b:	50                   	push   %eax
f010252c:	e8 68 0d 00 00       	call   f0103299 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102531:	89 f0                	mov    %esi,%eax
f0102533:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0102539:	c1 f8 03             	sar    $0x3,%eax
f010253c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010253f:	89 c2                	mov    %eax,%edx
f0102541:	c1 ea 0c             	shr    $0xc,%edx
f0102544:	83 c4 10             	add    $0x10,%esp
f0102547:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f010254d:	72 12                	jb     f0102561 <mem_init+0x13ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010254f:	50                   	push   %eax
f0102550:	68 d4 3f 10 f0       	push   $0xf0103fd4
f0102555:	6a 52                	push   $0x52
f0102557:	68 bf 3c 10 f0       	push   $0xf0103cbf
f010255c:	e8 2a db ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102561:	83 ec 04             	sub    $0x4,%esp
f0102564:	68 00 10 00 00       	push   $0x1000
f0102569:	6a 02                	push   $0x2
f010256b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102570:	50                   	push   %eax
f0102571:	e8 23 0d 00 00       	call   f0103299 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102576:	6a 02                	push   $0x2
f0102578:	68 00 10 00 00       	push   $0x1000
f010257d:	57                   	push   %edi
f010257e:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0102584:	e8 67 eb ff ff       	call   f01010f0 <page_insert>
	assert(pp1->pp_ref == 1);
f0102589:	83 c4 20             	add    $0x20,%esp
f010258c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102591:	74 19                	je     f01025ac <mem_init+0x1435>
f0102593:	68 9d 3e 10 f0       	push   $0xf0103e9d
f0102598:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010259d:	68 12 04 00 00       	push   $0x412
f01025a2:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01025a7:	e8 df da ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01025ac:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01025b3:	01 01 01 
f01025b6:	74 19                	je     f01025d1 <mem_init+0x145a>
f01025b8:	68 3c 47 10 f0       	push   $0xf010473c
f01025bd:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01025c2:	68 13 04 00 00       	push   $0x413
f01025c7:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01025cc:	e8 ba da ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01025d1:	6a 02                	push   $0x2
f01025d3:	68 00 10 00 00       	push   $0x1000
f01025d8:	56                   	push   %esi
f01025d9:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01025df:	e8 0c eb ff ff       	call   f01010f0 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01025e4:	83 c4 10             	add    $0x10,%esp
f01025e7:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01025ee:	02 02 02 
f01025f1:	74 19                	je     f010260c <mem_init+0x1495>
f01025f3:	68 60 47 10 f0       	push   $0xf0104760
f01025f8:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01025fd:	68 15 04 00 00       	push   $0x415
f0102602:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0102607:	e8 7f da ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f010260c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102611:	74 19                	je     f010262c <mem_init+0x14b5>
f0102613:	68 bf 3e 10 f0       	push   $0xf0103ebf
f0102618:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010261d:	68 16 04 00 00       	push   $0x416
f0102622:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0102627:	e8 5f da ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f010262c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102631:	74 19                	je     f010264c <mem_init+0x14d5>
f0102633:	68 49 3f 10 f0       	push   $0xf0103f49
f0102638:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010263d:	68 17 04 00 00       	push   $0x417
f0102642:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0102647:	e8 3f da ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010264c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102653:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102656:	89 f0                	mov    %esi,%eax
f0102658:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f010265e:	c1 f8 03             	sar    $0x3,%eax
f0102661:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102664:	89 c2                	mov    %eax,%edx
f0102666:	c1 ea 0c             	shr    $0xc,%edx
f0102669:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f010266f:	72 12                	jb     f0102683 <mem_init+0x150c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102671:	50                   	push   %eax
f0102672:	68 d4 3f 10 f0       	push   $0xf0103fd4
f0102677:	6a 52                	push   $0x52
f0102679:	68 bf 3c 10 f0       	push   $0xf0103cbf
f010267e:	e8 08 da ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102683:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010268a:	03 03 03 
f010268d:	74 19                	je     f01026a8 <mem_init+0x1531>
f010268f:	68 84 47 10 f0       	push   $0xf0104784
f0102694:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0102699:	68 19 04 00 00       	push   $0x419
f010269e:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01026a3:	e8 e3 d9 ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01026a8:	83 ec 08             	sub    $0x8,%esp
f01026ab:	68 00 10 00 00       	push   $0x1000
f01026b0:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01026b6:	e8 f3 e9 ff ff       	call   f01010ae <page_remove>
	assert(pp2->pp_ref == 0);
f01026bb:	83 c4 10             	add    $0x10,%esp
f01026be:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026c3:	74 19                	je     f01026de <mem_init+0x1567>
f01026c5:	68 f7 3e 10 f0       	push   $0xf0103ef7
f01026ca:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01026cf:	68 1b 04 00 00       	push   $0x41b
f01026d4:	68 9f 3c 10 f0       	push   $0xf0103c9f
f01026d9:	e8 ad d9 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026de:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
f01026e4:	8b 11                	mov    (%ecx),%edx
f01026e6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01026ec:	89 d8                	mov    %ebx,%eax
f01026ee:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01026f4:	c1 f8 03             	sar    $0x3,%eax
f01026f7:	c1 e0 0c             	shl    $0xc,%eax
f01026fa:	39 c2                	cmp    %eax,%edx
f01026fc:	74 19                	je     f0102717 <mem_init+0x15a0>
f01026fe:	68 c8 42 10 f0       	push   $0xf01042c8
f0102703:	68 d9 3c 10 f0       	push   $0xf0103cd9
f0102708:	68 1e 04 00 00       	push   $0x41e
f010270d:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0102712:	e8 74 d9 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102717:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010271d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102722:	74 19                	je     f010273d <mem_init+0x15c6>
f0102724:	68 ae 3e 10 f0       	push   $0xf0103eae
f0102729:	68 d9 3c 10 f0       	push   $0xf0103cd9
f010272e:	68 20 04 00 00       	push   $0x420
f0102733:	68 9f 3c 10 f0       	push   $0xf0103c9f
f0102738:	e8 4e d9 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f010273d:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102743:	83 ec 0c             	sub    $0xc,%esp
f0102746:	53                   	push   %ebx
f0102747:	e8 ca e7 ff ff       	call   f0100f16 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010274c:	c7 04 24 b0 47 10 f0 	movl   $0xf01047b0,(%esp)
f0102753:	e8 7d 00 00 00       	call   f01027d5 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102758:	83 c4 10             	add    $0x10,%esp
f010275b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010275e:	5b                   	pop    %ebx
f010275f:	5e                   	pop    %esi
f0102760:	5f                   	pop    %edi
f0102761:	5d                   	pop    %ebp
f0102762:	c3                   	ret    

f0102763 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102763:	55                   	push   %ebp
f0102764:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102766:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102769:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010276c:	5d                   	pop    %ebp
f010276d:	c3                   	ret    

f010276e <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010276e:	55                   	push   %ebp
f010276f:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102771:	ba 70 00 00 00       	mov    $0x70,%edx
f0102776:	8b 45 08             	mov    0x8(%ebp),%eax
f0102779:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010277a:	ba 71 00 00 00       	mov    $0x71,%edx
f010277f:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102780:	0f b6 c0             	movzbl %al,%eax
}
f0102783:	5d                   	pop    %ebp
f0102784:	c3                   	ret    

f0102785 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102785:	55                   	push   %ebp
f0102786:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102788:	ba 70 00 00 00       	mov    $0x70,%edx
f010278d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102790:	ee                   	out    %al,(%dx)
f0102791:	ba 71 00 00 00       	mov    $0x71,%edx
f0102796:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102799:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010279a:	5d                   	pop    %ebp
f010279b:	c3                   	ret    

f010279c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010279c:	55                   	push   %ebp
f010279d:	89 e5                	mov    %esp,%ebp
f010279f:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01027a2:	ff 75 08             	pushl  0x8(%ebp)
f01027a5:	e8 56 de ff ff       	call   f0100600 <cputchar>
	*cnt++;
}
f01027aa:	83 c4 10             	add    $0x10,%esp
f01027ad:	c9                   	leave  
f01027ae:	c3                   	ret    

f01027af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01027af:	55                   	push   %ebp
f01027b0:	89 e5                	mov    %esp,%ebp
f01027b2:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01027b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01027bc:	ff 75 0c             	pushl  0xc(%ebp)
f01027bf:	ff 75 08             	pushl  0x8(%ebp)
f01027c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01027c5:	50                   	push   %eax
f01027c6:	68 9c 27 10 f0       	push   $0xf010279c
f01027cb:	e8 5d 04 00 00       	call   f0102c2d <vprintfmt>
	return cnt;
}
f01027d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01027d3:	c9                   	leave  
f01027d4:	c3                   	ret    

f01027d5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01027d5:	55                   	push   %ebp
f01027d6:	89 e5                	mov    %esp,%ebp
f01027d8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01027db:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01027de:	50                   	push   %eax
f01027df:	ff 75 08             	pushl  0x8(%ebp)
f01027e2:	e8 c8 ff ff ff       	call   f01027af <vcprintf>
	va_end(ap);

	return cnt;
}
f01027e7:	c9                   	leave  
f01027e8:	c3                   	ret    

f01027e9 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01027e9:	55                   	push   %ebp
f01027ea:	89 e5                	mov    %esp,%ebp
f01027ec:	57                   	push   %edi
f01027ed:	56                   	push   %esi
f01027ee:	53                   	push   %ebx
f01027ef:	83 ec 14             	sub    $0x14,%esp
f01027f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01027f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01027f8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01027fb:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01027fe:	8b 1a                	mov    (%edx),%ebx
f0102800:	8b 01                	mov    (%ecx),%eax
f0102802:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102805:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010280c:	eb 7f                	jmp    f010288d <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f010280e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102811:	01 d8                	add    %ebx,%eax
f0102813:	89 c6                	mov    %eax,%esi
f0102815:	c1 ee 1f             	shr    $0x1f,%esi
f0102818:	01 c6                	add    %eax,%esi
f010281a:	d1 fe                	sar    %esi
f010281c:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010281f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102822:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0102825:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102827:	eb 03                	jmp    f010282c <stab_binsearch+0x43>
			m--;
f0102829:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010282c:	39 c3                	cmp    %eax,%ebx
f010282e:	7f 0d                	jg     f010283d <stab_binsearch+0x54>
f0102830:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102834:	83 ea 0c             	sub    $0xc,%edx
f0102837:	39 f9                	cmp    %edi,%ecx
f0102839:	75 ee                	jne    f0102829 <stab_binsearch+0x40>
f010283b:	eb 05                	jmp    f0102842 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010283d:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0102840:	eb 4b                	jmp    f010288d <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102842:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102845:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102848:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010284c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010284f:	76 11                	jbe    f0102862 <stab_binsearch+0x79>
			*region_left = m;
f0102851:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102854:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0102856:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102859:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102860:	eb 2b                	jmp    f010288d <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102862:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102865:	73 14                	jae    f010287b <stab_binsearch+0x92>
			*region_right = m - 1;
f0102867:	83 e8 01             	sub    $0x1,%eax
f010286a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010286d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102870:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102872:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102879:	eb 12                	jmp    f010288d <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010287b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010287e:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102880:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0102884:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102886:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010288d:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102890:	0f 8e 78 ff ff ff    	jle    f010280e <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102896:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010289a:	75 0f                	jne    f01028ab <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010289c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010289f:	8b 00                	mov    (%eax),%eax
f01028a1:	83 e8 01             	sub    $0x1,%eax
f01028a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01028a7:	89 06                	mov    %eax,(%esi)
f01028a9:	eb 2c                	jmp    f01028d7 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01028ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01028ae:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01028b0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01028b3:	8b 0e                	mov    (%esi),%ecx
f01028b5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01028b8:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01028bb:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01028be:	eb 03                	jmp    f01028c3 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01028c0:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01028c3:	39 c8                	cmp    %ecx,%eax
f01028c5:	7e 0b                	jle    f01028d2 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01028c7:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01028cb:	83 ea 0c             	sub    $0xc,%edx
f01028ce:	39 df                	cmp    %ebx,%edi
f01028d0:	75 ee                	jne    f01028c0 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01028d2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01028d5:	89 06                	mov    %eax,(%esi)
	}
}
f01028d7:	83 c4 14             	add    $0x14,%esp
f01028da:	5b                   	pop    %ebx
f01028db:	5e                   	pop    %esi
f01028dc:	5f                   	pop    %edi
f01028dd:	5d                   	pop    %ebp
f01028de:	c3                   	ret    

f01028df <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01028df:	55                   	push   %ebp
f01028e0:	89 e5                	mov    %esp,%ebp
f01028e2:	57                   	push   %edi
f01028e3:	56                   	push   %esi
f01028e4:	53                   	push   %ebx
f01028e5:	83 ec 3c             	sub    $0x3c,%esp
f01028e8:	8b 75 08             	mov    0x8(%ebp),%esi
f01028eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01028ee:	c7 03 dc 47 10 f0    	movl   $0xf01047dc,(%ebx)
	info->eip_line = 0;
f01028f4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01028fb:	c7 43 08 dc 47 10 f0 	movl   $0xf01047dc,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102902:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102909:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010290c:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102913:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102919:	76 11                	jbe    f010292c <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010291b:	b8 a9 c1 10 f0       	mov    $0xf010c1a9,%eax
f0102920:	3d b1 a3 10 f0       	cmp    $0xf010a3b1,%eax
f0102925:	77 19                	ja     f0102940 <debuginfo_eip+0x61>
f0102927:	e9 b5 01 00 00       	jmp    f0102ae1 <debuginfo_eip+0x202>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f010292c:	83 ec 04             	sub    $0x4,%esp
f010292f:	68 e6 47 10 f0       	push   $0xf01047e6
f0102934:	6a 7f                	push   $0x7f
f0102936:	68 f3 47 10 f0       	push   $0xf01047f3
f010293b:	e8 4b d7 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102940:	80 3d a8 c1 10 f0 00 	cmpb   $0x0,0xf010c1a8
f0102947:	0f 85 9b 01 00 00    	jne    f0102ae8 <debuginfo_eip+0x209>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010294d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102954:	b8 b0 a3 10 f0       	mov    $0xf010a3b0,%eax
f0102959:	2d 10 4a 10 f0       	sub    $0xf0104a10,%eax
f010295e:	c1 f8 02             	sar    $0x2,%eax
f0102961:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102967:	83 e8 01             	sub    $0x1,%eax
f010296a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010296d:	83 ec 08             	sub    $0x8,%esp
f0102970:	56                   	push   %esi
f0102971:	6a 64                	push   $0x64
f0102973:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102976:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102979:	b8 10 4a 10 f0       	mov    $0xf0104a10,%eax
f010297e:	e8 66 fe ff ff       	call   f01027e9 <stab_binsearch>
	if (lfile == 0)
f0102983:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102986:	83 c4 10             	add    $0x10,%esp
f0102989:	85 c0                	test   %eax,%eax
f010298b:	0f 84 5e 01 00 00    	je     f0102aef <debuginfo_eip+0x210>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102991:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102994:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102997:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010299a:	83 ec 08             	sub    $0x8,%esp
f010299d:	56                   	push   %esi
f010299e:	6a 24                	push   $0x24
f01029a0:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01029a3:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01029a6:	b8 10 4a 10 f0       	mov    $0xf0104a10,%eax
f01029ab:	e8 39 fe ff ff       	call   f01027e9 <stab_binsearch>

	if (lfun <= rfun) {
f01029b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01029b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01029b6:	83 c4 10             	add    $0x10,%esp
f01029b9:	39 d0                	cmp    %edx,%eax
f01029bb:	7f 40                	jg     f01029fd <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01029bd:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01029c0:	c1 e1 02             	shl    $0x2,%ecx
f01029c3:	8d b9 10 4a 10 f0    	lea    -0xfefb5f0(%ecx),%edi
f01029c9:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01029cc:	8b b9 10 4a 10 f0    	mov    -0xfefb5f0(%ecx),%edi
f01029d2:	b9 a9 c1 10 f0       	mov    $0xf010c1a9,%ecx
f01029d7:	81 e9 b1 a3 10 f0    	sub    $0xf010a3b1,%ecx
f01029dd:	39 cf                	cmp    %ecx,%edi
f01029df:	73 09                	jae    f01029ea <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01029e1:	81 c7 b1 a3 10 f0    	add    $0xf010a3b1,%edi
f01029e7:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01029ea:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01029ed:	8b 4f 08             	mov    0x8(%edi),%ecx
f01029f0:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01029f3:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01029f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01029f8:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01029fb:	eb 0f                	jmp    f0102a0c <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01029fd:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102a00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102a03:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102a06:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102a09:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102a0c:	83 ec 08             	sub    $0x8,%esp
f0102a0f:	6a 3a                	push   $0x3a
f0102a11:	ff 73 08             	pushl  0x8(%ebx)
f0102a14:	e8 64 08 00 00       	call   f010327d <strfind>
f0102a19:	2b 43 08             	sub    0x8(%ebx),%eax
f0102a1c:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102a1f:	83 c4 08             	add    $0x8,%esp
f0102a22:	56                   	push   %esi
f0102a23:	6a 44                	push   $0x44
f0102a25:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102a28:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102a2b:	b8 10 4a 10 f0       	mov    $0xf0104a10,%eax
f0102a30:	e8 b4 fd ff ff       	call   f01027e9 <stab_binsearch>
	if (lline == 0)
f0102a35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a38:	83 c4 10             	add    $0x10,%esp
f0102a3b:	85 c0                	test   %eax,%eax
f0102a3d:	0f 84 b3 00 00 00    	je     f0102af6 <debuginfo_eip+0x217>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0102a43:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102a46:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102a49:	0f b7 14 95 16 4a 10 	movzwl -0xfefb5ea(,%edx,4),%edx
f0102a50:	f0 
f0102a51:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102a54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102a57:	89 c2                	mov    %eax,%edx
f0102a59:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102a5c:	8d 04 85 10 4a 10 f0 	lea    -0xfefb5f0(,%eax,4),%eax
f0102a63:	eb 06                	jmp    f0102a6b <debuginfo_eip+0x18c>
f0102a65:	83 ea 01             	sub    $0x1,%edx
f0102a68:	83 e8 0c             	sub    $0xc,%eax
f0102a6b:	39 d7                	cmp    %edx,%edi
f0102a6d:	7f 34                	jg     f0102aa3 <debuginfo_eip+0x1c4>
	       && stabs[lline].n_type != N_SOL
f0102a6f:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0102a73:	80 f9 84             	cmp    $0x84,%cl
f0102a76:	74 0b                	je     f0102a83 <debuginfo_eip+0x1a4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102a78:	80 f9 64             	cmp    $0x64,%cl
f0102a7b:	75 e8                	jne    f0102a65 <debuginfo_eip+0x186>
f0102a7d:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102a81:	74 e2                	je     f0102a65 <debuginfo_eip+0x186>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102a83:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102a86:	8b 14 85 10 4a 10 f0 	mov    -0xfefb5f0(,%eax,4),%edx
f0102a8d:	b8 a9 c1 10 f0       	mov    $0xf010c1a9,%eax
f0102a92:	2d b1 a3 10 f0       	sub    $0xf010a3b1,%eax
f0102a97:	39 c2                	cmp    %eax,%edx
f0102a99:	73 08                	jae    f0102aa3 <debuginfo_eip+0x1c4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102a9b:	81 c2 b1 a3 10 f0    	add    $0xf010a3b1,%edx
f0102aa1:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102aa3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102aa6:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102aa9:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102aae:	39 f2                	cmp    %esi,%edx
f0102ab0:	7d 50                	jge    f0102b02 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
f0102ab2:	83 c2 01             	add    $0x1,%edx
f0102ab5:	89 d0                	mov    %edx,%eax
f0102ab7:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102aba:	8d 14 95 10 4a 10 f0 	lea    -0xfefb5f0(,%edx,4),%edx
f0102ac1:	eb 04                	jmp    f0102ac7 <debuginfo_eip+0x1e8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102ac3:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102ac7:	39 c6                	cmp    %eax,%esi
f0102ac9:	7e 32                	jle    f0102afd <debuginfo_eip+0x21e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102acb:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102acf:	83 c0 01             	add    $0x1,%eax
f0102ad2:	83 c2 0c             	add    $0xc,%edx
f0102ad5:	80 f9 a0             	cmp    $0xa0,%cl
f0102ad8:	74 e9                	je     f0102ac3 <debuginfo_eip+0x1e4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102ada:	b8 00 00 00 00       	mov    $0x0,%eax
f0102adf:	eb 21                	jmp    f0102b02 <debuginfo_eip+0x223>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102ae1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102ae6:	eb 1a                	jmp    f0102b02 <debuginfo_eip+0x223>
f0102ae8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102aed:	eb 13                	jmp    f0102b02 <debuginfo_eip+0x223>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102aef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102af4:	eb 0c                	jmp    f0102b02 <debuginfo_eip+0x223>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0102af6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102afb:	eb 05                	jmp    f0102b02 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102b02:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b05:	5b                   	pop    %ebx
f0102b06:	5e                   	pop    %esi
f0102b07:	5f                   	pop    %edi
f0102b08:	5d                   	pop    %ebp
f0102b09:	c3                   	ret    

f0102b0a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102b0a:	55                   	push   %ebp
f0102b0b:	89 e5                	mov    %esp,%ebp
f0102b0d:	57                   	push   %edi
f0102b0e:	56                   	push   %esi
f0102b0f:	53                   	push   %ebx
f0102b10:	83 ec 1c             	sub    $0x1c,%esp
f0102b13:	89 c7                	mov    %eax,%edi
f0102b15:	89 d6                	mov    %edx,%esi
f0102b17:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b1a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102b1d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102b20:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102b23:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102b26:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102b2b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102b2e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102b31:	39 d3                	cmp    %edx,%ebx
f0102b33:	72 05                	jb     f0102b3a <printnum+0x30>
f0102b35:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102b38:	77 45                	ja     f0102b7f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102b3a:	83 ec 0c             	sub    $0xc,%esp
f0102b3d:	ff 75 18             	pushl  0x18(%ebp)
f0102b40:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b43:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102b46:	53                   	push   %ebx
f0102b47:	ff 75 10             	pushl  0x10(%ebp)
f0102b4a:	83 ec 08             	sub    $0x8,%esp
f0102b4d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b50:	ff 75 e0             	pushl  -0x20(%ebp)
f0102b53:	ff 75 dc             	pushl  -0x24(%ebp)
f0102b56:	ff 75 d8             	pushl  -0x28(%ebp)
f0102b59:	e8 42 09 00 00       	call   f01034a0 <__udivdi3>
f0102b5e:	83 c4 18             	add    $0x18,%esp
f0102b61:	52                   	push   %edx
f0102b62:	50                   	push   %eax
f0102b63:	89 f2                	mov    %esi,%edx
f0102b65:	89 f8                	mov    %edi,%eax
f0102b67:	e8 9e ff ff ff       	call   f0102b0a <printnum>
f0102b6c:	83 c4 20             	add    $0x20,%esp
f0102b6f:	eb 18                	jmp    f0102b89 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102b71:	83 ec 08             	sub    $0x8,%esp
f0102b74:	56                   	push   %esi
f0102b75:	ff 75 18             	pushl  0x18(%ebp)
f0102b78:	ff d7                	call   *%edi
f0102b7a:	83 c4 10             	add    $0x10,%esp
f0102b7d:	eb 03                	jmp    f0102b82 <printnum+0x78>
f0102b7f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102b82:	83 eb 01             	sub    $0x1,%ebx
f0102b85:	85 db                	test   %ebx,%ebx
f0102b87:	7f e8                	jg     f0102b71 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102b89:	83 ec 08             	sub    $0x8,%esp
f0102b8c:	56                   	push   %esi
f0102b8d:	83 ec 04             	sub    $0x4,%esp
f0102b90:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b93:	ff 75 e0             	pushl  -0x20(%ebp)
f0102b96:	ff 75 dc             	pushl  -0x24(%ebp)
f0102b99:	ff 75 d8             	pushl  -0x28(%ebp)
f0102b9c:	e8 2f 0a 00 00       	call   f01035d0 <__umoddi3>
f0102ba1:	83 c4 14             	add    $0x14,%esp
f0102ba4:	0f be 80 01 48 10 f0 	movsbl -0xfefb7ff(%eax),%eax
f0102bab:	50                   	push   %eax
f0102bac:	ff d7                	call   *%edi
}
f0102bae:	83 c4 10             	add    $0x10,%esp
f0102bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102bb4:	5b                   	pop    %ebx
f0102bb5:	5e                   	pop    %esi
f0102bb6:	5f                   	pop    %edi
f0102bb7:	5d                   	pop    %ebp
f0102bb8:	c3                   	ret    

f0102bb9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102bb9:	55                   	push   %ebp
f0102bba:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102bbc:	83 fa 01             	cmp    $0x1,%edx
f0102bbf:	7e 0e                	jle    f0102bcf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102bc1:	8b 10                	mov    (%eax),%edx
f0102bc3:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102bc6:	89 08                	mov    %ecx,(%eax)
f0102bc8:	8b 02                	mov    (%edx),%eax
f0102bca:	8b 52 04             	mov    0x4(%edx),%edx
f0102bcd:	eb 22                	jmp    f0102bf1 <getuint+0x38>
	else if (lflag)
f0102bcf:	85 d2                	test   %edx,%edx
f0102bd1:	74 10                	je     f0102be3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102bd3:	8b 10                	mov    (%eax),%edx
f0102bd5:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102bd8:	89 08                	mov    %ecx,(%eax)
f0102bda:	8b 02                	mov    (%edx),%eax
f0102bdc:	ba 00 00 00 00       	mov    $0x0,%edx
f0102be1:	eb 0e                	jmp    f0102bf1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102be3:	8b 10                	mov    (%eax),%edx
f0102be5:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102be8:	89 08                	mov    %ecx,(%eax)
f0102bea:	8b 02                	mov    (%edx),%eax
f0102bec:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102bf1:	5d                   	pop    %ebp
f0102bf2:	c3                   	ret    

f0102bf3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102bf3:	55                   	push   %ebp
f0102bf4:	89 e5                	mov    %esp,%ebp
f0102bf6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102bf9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102bfd:	8b 10                	mov    (%eax),%edx
f0102bff:	3b 50 04             	cmp    0x4(%eax),%edx
f0102c02:	73 0a                	jae    f0102c0e <sprintputch+0x1b>
		*b->buf++ = ch;
f0102c04:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102c07:	89 08                	mov    %ecx,(%eax)
f0102c09:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c0c:	88 02                	mov    %al,(%edx)
}
f0102c0e:	5d                   	pop    %ebp
f0102c0f:	c3                   	ret    

f0102c10 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102c10:	55                   	push   %ebp
f0102c11:	89 e5                	mov    %esp,%ebp
f0102c13:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102c16:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102c19:	50                   	push   %eax
f0102c1a:	ff 75 10             	pushl  0x10(%ebp)
f0102c1d:	ff 75 0c             	pushl  0xc(%ebp)
f0102c20:	ff 75 08             	pushl  0x8(%ebp)
f0102c23:	e8 05 00 00 00       	call   f0102c2d <vprintfmt>
	va_end(ap);
}
f0102c28:	83 c4 10             	add    $0x10,%esp
f0102c2b:	c9                   	leave  
f0102c2c:	c3                   	ret    

f0102c2d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102c2d:	55                   	push   %ebp
f0102c2e:	89 e5                	mov    %esp,%ebp
f0102c30:	57                   	push   %edi
f0102c31:	56                   	push   %esi
f0102c32:	53                   	push   %ebx
f0102c33:	83 ec 2c             	sub    $0x2c,%esp
f0102c36:	8b 75 08             	mov    0x8(%ebp),%esi
f0102c39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102c3c:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102c3f:	eb 12                	jmp    f0102c53 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102c41:	85 c0                	test   %eax,%eax
f0102c43:	0f 84 89 03 00 00    	je     f0102fd2 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0102c49:	83 ec 08             	sub    $0x8,%esp
f0102c4c:	53                   	push   %ebx
f0102c4d:	50                   	push   %eax
f0102c4e:	ff d6                	call   *%esi
f0102c50:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102c53:	83 c7 01             	add    $0x1,%edi
f0102c56:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102c5a:	83 f8 25             	cmp    $0x25,%eax
f0102c5d:	75 e2                	jne    f0102c41 <vprintfmt+0x14>
f0102c5f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102c63:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102c6a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102c71:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102c78:	ba 00 00 00 00       	mov    $0x0,%edx
f0102c7d:	eb 07                	jmp    f0102c86 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c7f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102c82:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c86:	8d 47 01             	lea    0x1(%edi),%eax
f0102c89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102c8c:	0f b6 07             	movzbl (%edi),%eax
f0102c8f:	0f b6 c8             	movzbl %al,%ecx
f0102c92:	83 e8 23             	sub    $0x23,%eax
f0102c95:	3c 55                	cmp    $0x55,%al
f0102c97:	0f 87 1a 03 00 00    	ja     f0102fb7 <vprintfmt+0x38a>
f0102c9d:	0f b6 c0             	movzbl %al,%eax
f0102ca0:	ff 24 85 8c 48 10 f0 	jmp    *-0xfefb774(,%eax,4)
f0102ca7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102caa:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102cae:	eb d6                	jmp    f0102c86 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cb0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102cb3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cb8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102cbb:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102cbe:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0102cc2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0102cc5:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0102cc8:	83 fa 09             	cmp    $0x9,%edx
f0102ccb:	77 39                	ja     f0102d06 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102ccd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102cd0:	eb e9                	jmp    f0102cbb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102cd2:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cd5:	8d 48 04             	lea    0x4(%eax),%ecx
f0102cd8:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102cdb:	8b 00                	mov    (%eax),%eax
f0102cdd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ce0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102ce3:	eb 27                	jmp    f0102d0c <vprintfmt+0xdf>
f0102ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ce8:	85 c0                	test   %eax,%eax
f0102cea:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102cef:	0f 49 c8             	cmovns %eax,%ecx
f0102cf2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cf5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102cf8:	eb 8c                	jmp    f0102c86 <vprintfmt+0x59>
f0102cfa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102cfd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102d04:	eb 80                	jmp    f0102c86 <vprintfmt+0x59>
f0102d06:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102d09:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102d0c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102d10:	0f 89 70 ff ff ff    	jns    f0102c86 <vprintfmt+0x59>
				width = precision, precision = -1;
f0102d16:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d19:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102d1c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102d23:	e9 5e ff ff ff       	jmp    f0102c86 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102d28:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102d2e:	e9 53 ff ff ff       	jmp    f0102c86 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102d33:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d36:	8d 50 04             	lea    0x4(%eax),%edx
f0102d39:	89 55 14             	mov    %edx,0x14(%ebp)
f0102d3c:	83 ec 08             	sub    $0x8,%esp
f0102d3f:	53                   	push   %ebx
f0102d40:	ff 30                	pushl  (%eax)
f0102d42:	ff d6                	call   *%esi
			break;
f0102d44:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102d4a:	e9 04 ff ff ff       	jmp    f0102c53 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102d4f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d52:	8d 50 04             	lea    0x4(%eax),%edx
f0102d55:	89 55 14             	mov    %edx,0x14(%ebp)
f0102d58:	8b 00                	mov    (%eax),%eax
f0102d5a:	99                   	cltd   
f0102d5b:	31 d0                	xor    %edx,%eax
f0102d5d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102d5f:	83 f8 06             	cmp    $0x6,%eax
f0102d62:	7f 0b                	jg     f0102d6f <vprintfmt+0x142>
f0102d64:	8b 14 85 e4 49 10 f0 	mov    -0xfefb61c(,%eax,4),%edx
f0102d6b:	85 d2                	test   %edx,%edx
f0102d6d:	75 18                	jne    f0102d87 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0102d6f:	50                   	push   %eax
f0102d70:	68 19 48 10 f0       	push   $0xf0104819
f0102d75:	53                   	push   %ebx
f0102d76:	56                   	push   %esi
f0102d77:	e8 94 fe ff ff       	call   f0102c10 <printfmt>
f0102d7c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d7f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102d82:	e9 cc fe ff ff       	jmp    f0102c53 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102d87:	52                   	push   %edx
f0102d88:	68 eb 3c 10 f0       	push   $0xf0103ceb
f0102d8d:	53                   	push   %ebx
f0102d8e:	56                   	push   %esi
f0102d8f:	e8 7c fe ff ff       	call   f0102c10 <printfmt>
f0102d94:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102d9a:	e9 b4 fe ff ff       	jmp    f0102c53 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102d9f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102da2:	8d 50 04             	lea    0x4(%eax),%edx
f0102da5:	89 55 14             	mov    %edx,0x14(%ebp)
f0102da8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102daa:	85 ff                	test   %edi,%edi
f0102dac:	b8 12 48 10 f0       	mov    $0xf0104812,%eax
f0102db1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102db4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102db8:	0f 8e 94 00 00 00    	jle    f0102e52 <vprintfmt+0x225>
f0102dbe:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102dc2:	0f 84 98 00 00 00    	je     f0102e60 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102dc8:	83 ec 08             	sub    $0x8,%esp
f0102dcb:	ff 75 d0             	pushl  -0x30(%ebp)
f0102dce:	57                   	push   %edi
f0102dcf:	e8 5f 03 00 00       	call   f0103133 <strnlen>
f0102dd4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102dd7:	29 c1                	sub    %eax,%ecx
f0102dd9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102ddc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102ddf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102de3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102de6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102de9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102deb:	eb 0f                	jmp    f0102dfc <vprintfmt+0x1cf>
					putch(padc, putdat);
f0102ded:	83 ec 08             	sub    $0x8,%esp
f0102df0:	53                   	push   %ebx
f0102df1:	ff 75 e0             	pushl  -0x20(%ebp)
f0102df4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102df6:	83 ef 01             	sub    $0x1,%edi
f0102df9:	83 c4 10             	add    $0x10,%esp
f0102dfc:	85 ff                	test   %edi,%edi
f0102dfe:	7f ed                	jg     f0102ded <vprintfmt+0x1c0>
f0102e00:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102e03:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102e06:	85 c9                	test   %ecx,%ecx
f0102e08:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e0d:	0f 49 c1             	cmovns %ecx,%eax
f0102e10:	29 c1                	sub    %eax,%ecx
f0102e12:	89 75 08             	mov    %esi,0x8(%ebp)
f0102e15:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102e18:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102e1b:	89 cb                	mov    %ecx,%ebx
f0102e1d:	eb 4d                	jmp    f0102e6c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102e1f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102e23:	74 1b                	je     f0102e40 <vprintfmt+0x213>
f0102e25:	0f be c0             	movsbl %al,%eax
f0102e28:	83 e8 20             	sub    $0x20,%eax
f0102e2b:	83 f8 5e             	cmp    $0x5e,%eax
f0102e2e:	76 10                	jbe    f0102e40 <vprintfmt+0x213>
					putch('?', putdat);
f0102e30:	83 ec 08             	sub    $0x8,%esp
f0102e33:	ff 75 0c             	pushl  0xc(%ebp)
f0102e36:	6a 3f                	push   $0x3f
f0102e38:	ff 55 08             	call   *0x8(%ebp)
f0102e3b:	83 c4 10             	add    $0x10,%esp
f0102e3e:	eb 0d                	jmp    f0102e4d <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0102e40:	83 ec 08             	sub    $0x8,%esp
f0102e43:	ff 75 0c             	pushl  0xc(%ebp)
f0102e46:	52                   	push   %edx
f0102e47:	ff 55 08             	call   *0x8(%ebp)
f0102e4a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102e4d:	83 eb 01             	sub    $0x1,%ebx
f0102e50:	eb 1a                	jmp    f0102e6c <vprintfmt+0x23f>
f0102e52:	89 75 08             	mov    %esi,0x8(%ebp)
f0102e55:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102e58:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102e5b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102e5e:	eb 0c                	jmp    f0102e6c <vprintfmt+0x23f>
f0102e60:	89 75 08             	mov    %esi,0x8(%ebp)
f0102e63:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102e66:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102e69:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102e6c:	83 c7 01             	add    $0x1,%edi
f0102e6f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102e73:	0f be d0             	movsbl %al,%edx
f0102e76:	85 d2                	test   %edx,%edx
f0102e78:	74 23                	je     f0102e9d <vprintfmt+0x270>
f0102e7a:	85 f6                	test   %esi,%esi
f0102e7c:	78 a1                	js     f0102e1f <vprintfmt+0x1f2>
f0102e7e:	83 ee 01             	sub    $0x1,%esi
f0102e81:	79 9c                	jns    f0102e1f <vprintfmt+0x1f2>
f0102e83:	89 df                	mov    %ebx,%edi
f0102e85:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e8b:	eb 18                	jmp    f0102ea5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102e8d:	83 ec 08             	sub    $0x8,%esp
f0102e90:	53                   	push   %ebx
f0102e91:	6a 20                	push   $0x20
f0102e93:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102e95:	83 ef 01             	sub    $0x1,%edi
f0102e98:	83 c4 10             	add    $0x10,%esp
f0102e9b:	eb 08                	jmp    f0102ea5 <vprintfmt+0x278>
f0102e9d:	89 df                	mov    %ebx,%edi
f0102e9f:	8b 75 08             	mov    0x8(%ebp),%esi
f0102ea2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ea5:	85 ff                	test   %edi,%edi
f0102ea7:	7f e4                	jg     f0102e8d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ea9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102eac:	e9 a2 fd ff ff       	jmp    f0102c53 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102eb1:	83 fa 01             	cmp    $0x1,%edx
f0102eb4:	7e 16                	jle    f0102ecc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0102eb6:	8b 45 14             	mov    0x14(%ebp),%eax
f0102eb9:	8d 50 08             	lea    0x8(%eax),%edx
f0102ebc:	89 55 14             	mov    %edx,0x14(%ebp)
f0102ebf:	8b 50 04             	mov    0x4(%eax),%edx
f0102ec2:	8b 00                	mov    (%eax),%eax
f0102ec4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102ec7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102eca:	eb 32                	jmp    f0102efe <vprintfmt+0x2d1>
	else if (lflag)
f0102ecc:	85 d2                	test   %edx,%edx
f0102ece:	74 18                	je     f0102ee8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0102ed0:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ed3:	8d 50 04             	lea    0x4(%eax),%edx
f0102ed6:	89 55 14             	mov    %edx,0x14(%ebp)
f0102ed9:	8b 00                	mov    (%eax),%eax
f0102edb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102ede:	89 c1                	mov    %eax,%ecx
f0102ee0:	c1 f9 1f             	sar    $0x1f,%ecx
f0102ee3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102ee6:	eb 16                	jmp    f0102efe <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0102ee8:	8b 45 14             	mov    0x14(%ebp),%eax
f0102eeb:	8d 50 04             	lea    0x4(%eax),%edx
f0102eee:	89 55 14             	mov    %edx,0x14(%ebp)
f0102ef1:	8b 00                	mov    (%eax),%eax
f0102ef3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102ef6:	89 c1                	mov    %eax,%ecx
f0102ef8:	c1 f9 1f             	sar    $0x1f,%ecx
f0102efb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102efe:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102f01:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102f04:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102f09:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102f0d:	79 74                	jns    f0102f83 <vprintfmt+0x356>
				putch('-', putdat);
f0102f0f:	83 ec 08             	sub    $0x8,%esp
f0102f12:	53                   	push   %ebx
f0102f13:	6a 2d                	push   $0x2d
f0102f15:	ff d6                	call   *%esi
				num = -(long long) num;
f0102f17:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102f1a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102f1d:	f7 d8                	neg    %eax
f0102f1f:	83 d2 00             	adc    $0x0,%edx
f0102f22:	f7 da                	neg    %edx
f0102f24:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102f27:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102f2c:	eb 55                	jmp    f0102f83 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102f2e:	8d 45 14             	lea    0x14(%ebp),%eax
f0102f31:	e8 83 fc ff ff       	call   f0102bb9 <getuint>
			base = 10;
f0102f36:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0102f3b:	eb 46                	jmp    f0102f83 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0102f3d:	8d 45 14             	lea    0x14(%ebp),%eax
f0102f40:	e8 74 fc ff ff       	call   f0102bb9 <getuint>
			base = 8;
f0102f45:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0102f4a:	eb 37                	jmp    f0102f83 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0102f4c:	83 ec 08             	sub    $0x8,%esp
f0102f4f:	53                   	push   %ebx
f0102f50:	6a 30                	push   $0x30
f0102f52:	ff d6                	call   *%esi
			putch('x', putdat);
f0102f54:	83 c4 08             	add    $0x8,%esp
f0102f57:	53                   	push   %ebx
f0102f58:	6a 78                	push   $0x78
f0102f5a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102f5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f5f:	8d 50 04             	lea    0x4(%eax),%edx
f0102f62:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102f65:	8b 00                	mov    (%eax),%eax
f0102f67:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102f6c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102f6f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0102f74:	eb 0d                	jmp    f0102f83 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102f76:	8d 45 14             	lea    0x14(%ebp),%eax
f0102f79:	e8 3b fc ff ff       	call   f0102bb9 <getuint>
			base = 16;
f0102f7e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102f83:	83 ec 0c             	sub    $0xc,%esp
f0102f86:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0102f8a:	57                   	push   %edi
f0102f8b:	ff 75 e0             	pushl  -0x20(%ebp)
f0102f8e:	51                   	push   %ecx
f0102f8f:	52                   	push   %edx
f0102f90:	50                   	push   %eax
f0102f91:	89 da                	mov    %ebx,%edx
f0102f93:	89 f0                	mov    %esi,%eax
f0102f95:	e8 70 fb ff ff       	call   f0102b0a <printnum>
			break;
f0102f9a:	83 c4 20             	add    $0x20,%esp
f0102f9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102fa0:	e9 ae fc ff ff       	jmp    f0102c53 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102fa5:	83 ec 08             	sub    $0x8,%esp
f0102fa8:	53                   	push   %ebx
f0102fa9:	51                   	push   %ecx
f0102faa:	ff d6                	call   *%esi
			break;
f0102fac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102faf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102fb2:	e9 9c fc ff ff       	jmp    f0102c53 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0102fb7:	83 ec 08             	sub    $0x8,%esp
f0102fba:	53                   	push   %ebx
f0102fbb:	6a 25                	push   $0x25
f0102fbd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102fbf:	83 c4 10             	add    $0x10,%esp
f0102fc2:	eb 03                	jmp    f0102fc7 <vprintfmt+0x39a>
f0102fc4:	83 ef 01             	sub    $0x1,%edi
f0102fc7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0102fcb:	75 f7                	jne    f0102fc4 <vprintfmt+0x397>
f0102fcd:	e9 81 fc ff ff       	jmp    f0102c53 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0102fd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fd5:	5b                   	pop    %ebx
f0102fd6:	5e                   	pop    %esi
f0102fd7:	5f                   	pop    %edi
f0102fd8:	5d                   	pop    %ebp
f0102fd9:	c3                   	ret    

f0102fda <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102fda:	55                   	push   %ebp
f0102fdb:	89 e5                	mov    %esp,%ebp
f0102fdd:	83 ec 18             	sub    $0x18,%esp
f0102fe0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fe3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102fe6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102fe9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102fed:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102ff0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102ff7:	85 c0                	test   %eax,%eax
f0102ff9:	74 26                	je     f0103021 <vsnprintf+0x47>
f0102ffb:	85 d2                	test   %edx,%edx
f0102ffd:	7e 22                	jle    f0103021 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102fff:	ff 75 14             	pushl  0x14(%ebp)
f0103002:	ff 75 10             	pushl  0x10(%ebp)
f0103005:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103008:	50                   	push   %eax
f0103009:	68 f3 2b 10 f0       	push   $0xf0102bf3
f010300e:	e8 1a fc ff ff       	call   f0102c2d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103013:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103016:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103019:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010301c:	83 c4 10             	add    $0x10,%esp
f010301f:	eb 05                	jmp    f0103026 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103021:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103026:	c9                   	leave  
f0103027:	c3                   	ret    

f0103028 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103028:	55                   	push   %ebp
f0103029:	89 e5                	mov    %esp,%ebp
f010302b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010302e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103031:	50                   	push   %eax
f0103032:	ff 75 10             	pushl  0x10(%ebp)
f0103035:	ff 75 0c             	pushl  0xc(%ebp)
f0103038:	ff 75 08             	pushl  0x8(%ebp)
f010303b:	e8 9a ff ff ff       	call   f0102fda <vsnprintf>
	va_end(ap);

	return rc;
}
f0103040:	c9                   	leave  
f0103041:	c3                   	ret    

f0103042 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103042:	55                   	push   %ebp
f0103043:	89 e5                	mov    %esp,%ebp
f0103045:	57                   	push   %edi
f0103046:	56                   	push   %esi
f0103047:	53                   	push   %ebx
f0103048:	83 ec 0c             	sub    $0xc,%esp
f010304b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010304e:	85 c0                	test   %eax,%eax
f0103050:	74 11                	je     f0103063 <readline+0x21>
		cprintf("%s", prompt);
f0103052:	83 ec 08             	sub    $0x8,%esp
f0103055:	50                   	push   %eax
f0103056:	68 eb 3c 10 f0       	push   $0xf0103ceb
f010305b:	e8 75 f7 ff ff       	call   f01027d5 <cprintf>
f0103060:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103063:	83 ec 0c             	sub    $0xc,%esp
f0103066:	6a 00                	push   $0x0
f0103068:	e8 b4 d5 ff ff       	call   f0100621 <iscons>
f010306d:	89 c7                	mov    %eax,%edi
f010306f:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103072:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103077:	e8 94 d5 ff ff       	call   f0100610 <getchar>
f010307c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010307e:	85 c0                	test   %eax,%eax
f0103080:	79 18                	jns    f010309a <readline+0x58>
			cprintf("read error: %e\n", c);
f0103082:	83 ec 08             	sub    $0x8,%esp
f0103085:	50                   	push   %eax
f0103086:	68 00 4a 10 f0       	push   $0xf0104a00
f010308b:	e8 45 f7 ff ff       	call   f01027d5 <cprintf>
			return NULL;
f0103090:	83 c4 10             	add    $0x10,%esp
f0103093:	b8 00 00 00 00       	mov    $0x0,%eax
f0103098:	eb 79                	jmp    f0103113 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010309a:	83 f8 08             	cmp    $0x8,%eax
f010309d:	0f 94 c2             	sete   %dl
f01030a0:	83 f8 7f             	cmp    $0x7f,%eax
f01030a3:	0f 94 c0             	sete   %al
f01030a6:	08 c2                	or     %al,%dl
f01030a8:	74 1a                	je     f01030c4 <readline+0x82>
f01030aa:	85 f6                	test   %esi,%esi
f01030ac:	7e 16                	jle    f01030c4 <readline+0x82>
			if (echoing)
f01030ae:	85 ff                	test   %edi,%edi
f01030b0:	74 0d                	je     f01030bf <readline+0x7d>
				cputchar('\b');
f01030b2:	83 ec 0c             	sub    $0xc,%esp
f01030b5:	6a 08                	push   $0x8
f01030b7:	e8 44 d5 ff ff       	call   f0100600 <cputchar>
f01030bc:	83 c4 10             	add    $0x10,%esp
			i--;
f01030bf:	83 ee 01             	sub    $0x1,%esi
f01030c2:	eb b3                	jmp    f0103077 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01030c4:	83 fb 1f             	cmp    $0x1f,%ebx
f01030c7:	7e 23                	jle    f01030ec <readline+0xaa>
f01030c9:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01030cf:	7f 1b                	jg     f01030ec <readline+0xaa>
			if (echoing)
f01030d1:	85 ff                	test   %edi,%edi
f01030d3:	74 0c                	je     f01030e1 <readline+0x9f>
				cputchar(c);
f01030d5:	83 ec 0c             	sub    $0xc,%esp
f01030d8:	53                   	push   %ebx
f01030d9:	e8 22 d5 ff ff       	call   f0100600 <cputchar>
f01030de:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01030e1:	88 9e 60 75 11 f0    	mov    %bl,-0xfee8aa0(%esi)
f01030e7:	8d 76 01             	lea    0x1(%esi),%esi
f01030ea:	eb 8b                	jmp    f0103077 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01030ec:	83 fb 0a             	cmp    $0xa,%ebx
f01030ef:	74 05                	je     f01030f6 <readline+0xb4>
f01030f1:	83 fb 0d             	cmp    $0xd,%ebx
f01030f4:	75 81                	jne    f0103077 <readline+0x35>
			if (echoing)
f01030f6:	85 ff                	test   %edi,%edi
f01030f8:	74 0d                	je     f0103107 <readline+0xc5>
				cputchar('\n');
f01030fa:	83 ec 0c             	sub    $0xc,%esp
f01030fd:	6a 0a                	push   $0xa
f01030ff:	e8 fc d4 ff ff       	call   f0100600 <cputchar>
f0103104:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103107:	c6 86 60 75 11 f0 00 	movb   $0x0,-0xfee8aa0(%esi)
			return buf;
f010310e:	b8 60 75 11 f0       	mov    $0xf0117560,%eax
		}
	}
}
f0103113:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103116:	5b                   	pop    %ebx
f0103117:	5e                   	pop    %esi
f0103118:	5f                   	pop    %edi
f0103119:	5d                   	pop    %ebp
f010311a:	c3                   	ret    

f010311b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010311b:	55                   	push   %ebp
f010311c:	89 e5                	mov    %esp,%ebp
f010311e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103121:	b8 00 00 00 00       	mov    $0x0,%eax
f0103126:	eb 03                	jmp    f010312b <strlen+0x10>
		n++;
f0103128:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010312b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010312f:	75 f7                	jne    f0103128 <strlen+0xd>
		n++;
	return n;
}
f0103131:	5d                   	pop    %ebp
f0103132:	c3                   	ret    

f0103133 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103133:	55                   	push   %ebp
f0103134:	89 e5                	mov    %esp,%ebp
f0103136:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103139:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010313c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103141:	eb 03                	jmp    f0103146 <strnlen+0x13>
		n++;
f0103143:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103146:	39 c2                	cmp    %eax,%edx
f0103148:	74 08                	je     f0103152 <strnlen+0x1f>
f010314a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010314e:	75 f3                	jne    f0103143 <strnlen+0x10>
f0103150:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0103152:	5d                   	pop    %ebp
f0103153:	c3                   	ret    

f0103154 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103154:	55                   	push   %ebp
f0103155:	89 e5                	mov    %esp,%ebp
f0103157:	53                   	push   %ebx
f0103158:	8b 45 08             	mov    0x8(%ebp),%eax
f010315b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010315e:	89 c2                	mov    %eax,%edx
f0103160:	83 c2 01             	add    $0x1,%edx
f0103163:	83 c1 01             	add    $0x1,%ecx
f0103166:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010316a:	88 5a ff             	mov    %bl,-0x1(%edx)
f010316d:	84 db                	test   %bl,%bl
f010316f:	75 ef                	jne    f0103160 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103171:	5b                   	pop    %ebx
f0103172:	5d                   	pop    %ebp
f0103173:	c3                   	ret    

f0103174 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103174:	55                   	push   %ebp
f0103175:	89 e5                	mov    %esp,%ebp
f0103177:	53                   	push   %ebx
f0103178:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010317b:	53                   	push   %ebx
f010317c:	e8 9a ff ff ff       	call   f010311b <strlen>
f0103181:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103184:	ff 75 0c             	pushl  0xc(%ebp)
f0103187:	01 d8                	add    %ebx,%eax
f0103189:	50                   	push   %eax
f010318a:	e8 c5 ff ff ff       	call   f0103154 <strcpy>
	return dst;
}
f010318f:	89 d8                	mov    %ebx,%eax
f0103191:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103194:	c9                   	leave  
f0103195:	c3                   	ret    

f0103196 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103196:	55                   	push   %ebp
f0103197:	89 e5                	mov    %esp,%ebp
f0103199:	56                   	push   %esi
f010319a:	53                   	push   %ebx
f010319b:	8b 75 08             	mov    0x8(%ebp),%esi
f010319e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01031a1:	89 f3                	mov    %esi,%ebx
f01031a3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01031a6:	89 f2                	mov    %esi,%edx
f01031a8:	eb 0f                	jmp    f01031b9 <strncpy+0x23>
		*dst++ = *src;
f01031aa:	83 c2 01             	add    $0x1,%edx
f01031ad:	0f b6 01             	movzbl (%ecx),%eax
f01031b0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01031b3:	80 39 01             	cmpb   $0x1,(%ecx)
f01031b6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01031b9:	39 da                	cmp    %ebx,%edx
f01031bb:	75 ed                	jne    f01031aa <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01031bd:	89 f0                	mov    %esi,%eax
f01031bf:	5b                   	pop    %ebx
f01031c0:	5e                   	pop    %esi
f01031c1:	5d                   	pop    %ebp
f01031c2:	c3                   	ret    

f01031c3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01031c3:	55                   	push   %ebp
f01031c4:	89 e5                	mov    %esp,%ebp
f01031c6:	56                   	push   %esi
f01031c7:	53                   	push   %ebx
f01031c8:	8b 75 08             	mov    0x8(%ebp),%esi
f01031cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01031ce:	8b 55 10             	mov    0x10(%ebp),%edx
f01031d1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01031d3:	85 d2                	test   %edx,%edx
f01031d5:	74 21                	je     f01031f8 <strlcpy+0x35>
f01031d7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01031db:	89 f2                	mov    %esi,%edx
f01031dd:	eb 09                	jmp    f01031e8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01031df:	83 c2 01             	add    $0x1,%edx
f01031e2:	83 c1 01             	add    $0x1,%ecx
f01031e5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01031e8:	39 c2                	cmp    %eax,%edx
f01031ea:	74 09                	je     f01031f5 <strlcpy+0x32>
f01031ec:	0f b6 19             	movzbl (%ecx),%ebx
f01031ef:	84 db                	test   %bl,%bl
f01031f1:	75 ec                	jne    f01031df <strlcpy+0x1c>
f01031f3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01031f5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01031f8:	29 f0                	sub    %esi,%eax
}
f01031fa:	5b                   	pop    %ebx
f01031fb:	5e                   	pop    %esi
f01031fc:	5d                   	pop    %ebp
f01031fd:	c3                   	ret    

f01031fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01031fe:	55                   	push   %ebp
f01031ff:	89 e5                	mov    %esp,%ebp
f0103201:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103204:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103207:	eb 06                	jmp    f010320f <strcmp+0x11>
		p++, q++;
f0103209:	83 c1 01             	add    $0x1,%ecx
f010320c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010320f:	0f b6 01             	movzbl (%ecx),%eax
f0103212:	84 c0                	test   %al,%al
f0103214:	74 04                	je     f010321a <strcmp+0x1c>
f0103216:	3a 02                	cmp    (%edx),%al
f0103218:	74 ef                	je     f0103209 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010321a:	0f b6 c0             	movzbl %al,%eax
f010321d:	0f b6 12             	movzbl (%edx),%edx
f0103220:	29 d0                	sub    %edx,%eax
}
f0103222:	5d                   	pop    %ebp
f0103223:	c3                   	ret    

f0103224 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103224:	55                   	push   %ebp
f0103225:	89 e5                	mov    %esp,%ebp
f0103227:	53                   	push   %ebx
f0103228:	8b 45 08             	mov    0x8(%ebp),%eax
f010322b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010322e:	89 c3                	mov    %eax,%ebx
f0103230:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103233:	eb 06                	jmp    f010323b <strncmp+0x17>
		n--, p++, q++;
f0103235:	83 c0 01             	add    $0x1,%eax
f0103238:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010323b:	39 d8                	cmp    %ebx,%eax
f010323d:	74 15                	je     f0103254 <strncmp+0x30>
f010323f:	0f b6 08             	movzbl (%eax),%ecx
f0103242:	84 c9                	test   %cl,%cl
f0103244:	74 04                	je     f010324a <strncmp+0x26>
f0103246:	3a 0a                	cmp    (%edx),%cl
f0103248:	74 eb                	je     f0103235 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010324a:	0f b6 00             	movzbl (%eax),%eax
f010324d:	0f b6 12             	movzbl (%edx),%edx
f0103250:	29 d0                	sub    %edx,%eax
f0103252:	eb 05                	jmp    f0103259 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103254:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103259:	5b                   	pop    %ebx
f010325a:	5d                   	pop    %ebp
f010325b:	c3                   	ret    

f010325c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010325c:	55                   	push   %ebp
f010325d:	89 e5                	mov    %esp,%ebp
f010325f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103262:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103266:	eb 07                	jmp    f010326f <strchr+0x13>
		if (*s == c)
f0103268:	38 ca                	cmp    %cl,%dl
f010326a:	74 0f                	je     f010327b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010326c:	83 c0 01             	add    $0x1,%eax
f010326f:	0f b6 10             	movzbl (%eax),%edx
f0103272:	84 d2                	test   %dl,%dl
f0103274:	75 f2                	jne    f0103268 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103276:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010327b:	5d                   	pop    %ebp
f010327c:	c3                   	ret    

f010327d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010327d:	55                   	push   %ebp
f010327e:	89 e5                	mov    %esp,%ebp
f0103280:	8b 45 08             	mov    0x8(%ebp),%eax
f0103283:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103287:	eb 03                	jmp    f010328c <strfind+0xf>
f0103289:	83 c0 01             	add    $0x1,%eax
f010328c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010328f:	38 ca                	cmp    %cl,%dl
f0103291:	74 04                	je     f0103297 <strfind+0x1a>
f0103293:	84 d2                	test   %dl,%dl
f0103295:	75 f2                	jne    f0103289 <strfind+0xc>
			break;
	return (char *) s;
}
f0103297:	5d                   	pop    %ebp
f0103298:	c3                   	ret    

f0103299 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103299:	55                   	push   %ebp
f010329a:	89 e5                	mov    %esp,%ebp
f010329c:	57                   	push   %edi
f010329d:	56                   	push   %esi
f010329e:	53                   	push   %ebx
f010329f:	8b 7d 08             	mov    0x8(%ebp),%edi
f01032a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01032a5:	85 c9                	test   %ecx,%ecx
f01032a7:	74 36                	je     f01032df <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01032a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01032af:	75 28                	jne    f01032d9 <memset+0x40>
f01032b1:	f6 c1 03             	test   $0x3,%cl
f01032b4:	75 23                	jne    f01032d9 <memset+0x40>
		c &= 0xFF;
f01032b6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01032ba:	89 d3                	mov    %edx,%ebx
f01032bc:	c1 e3 08             	shl    $0x8,%ebx
f01032bf:	89 d6                	mov    %edx,%esi
f01032c1:	c1 e6 18             	shl    $0x18,%esi
f01032c4:	89 d0                	mov    %edx,%eax
f01032c6:	c1 e0 10             	shl    $0x10,%eax
f01032c9:	09 f0                	or     %esi,%eax
f01032cb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01032cd:	89 d8                	mov    %ebx,%eax
f01032cf:	09 d0                	or     %edx,%eax
f01032d1:	c1 e9 02             	shr    $0x2,%ecx
f01032d4:	fc                   	cld    
f01032d5:	f3 ab                	rep stos %eax,%es:(%edi)
f01032d7:	eb 06                	jmp    f01032df <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01032d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032dc:	fc                   	cld    
f01032dd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01032df:	89 f8                	mov    %edi,%eax
f01032e1:	5b                   	pop    %ebx
f01032e2:	5e                   	pop    %esi
f01032e3:	5f                   	pop    %edi
f01032e4:	5d                   	pop    %ebp
f01032e5:	c3                   	ret    

f01032e6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01032e6:	55                   	push   %ebp
f01032e7:	89 e5                	mov    %esp,%ebp
f01032e9:	57                   	push   %edi
f01032ea:	56                   	push   %esi
f01032eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01032ee:	8b 75 0c             	mov    0xc(%ebp),%esi
f01032f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01032f4:	39 c6                	cmp    %eax,%esi
f01032f6:	73 35                	jae    f010332d <memmove+0x47>
f01032f8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01032fb:	39 d0                	cmp    %edx,%eax
f01032fd:	73 2e                	jae    f010332d <memmove+0x47>
		s += n;
		d += n;
f01032ff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103302:	89 d6                	mov    %edx,%esi
f0103304:	09 fe                	or     %edi,%esi
f0103306:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010330c:	75 13                	jne    f0103321 <memmove+0x3b>
f010330e:	f6 c1 03             	test   $0x3,%cl
f0103311:	75 0e                	jne    f0103321 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0103313:	83 ef 04             	sub    $0x4,%edi
f0103316:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103319:	c1 e9 02             	shr    $0x2,%ecx
f010331c:	fd                   	std    
f010331d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010331f:	eb 09                	jmp    f010332a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103321:	83 ef 01             	sub    $0x1,%edi
f0103324:	8d 72 ff             	lea    -0x1(%edx),%esi
f0103327:	fd                   	std    
f0103328:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010332a:	fc                   	cld    
f010332b:	eb 1d                	jmp    f010334a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010332d:	89 f2                	mov    %esi,%edx
f010332f:	09 c2                	or     %eax,%edx
f0103331:	f6 c2 03             	test   $0x3,%dl
f0103334:	75 0f                	jne    f0103345 <memmove+0x5f>
f0103336:	f6 c1 03             	test   $0x3,%cl
f0103339:	75 0a                	jne    f0103345 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010333b:	c1 e9 02             	shr    $0x2,%ecx
f010333e:	89 c7                	mov    %eax,%edi
f0103340:	fc                   	cld    
f0103341:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103343:	eb 05                	jmp    f010334a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103345:	89 c7                	mov    %eax,%edi
f0103347:	fc                   	cld    
f0103348:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010334a:	5e                   	pop    %esi
f010334b:	5f                   	pop    %edi
f010334c:	5d                   	pop    %ebp
f010334d:	c3                   	ret    

f010334e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010334e:	55                   	push   %ebp
f010334f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103351:	ff 75 10             	pushl  0x10(%ebp)
f0103354:	ff 75 0c             	pushl  0xc(%ebp)
f0103357:	ff 75 08             	pushl  0x8(%ebp)
f010335a:	e8 87 ff ff ff       	call   f01032e6 <memmove>
}
f010335f:	c9                   	leave  
f0103360:	c3                   	ret    

f0103361 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103361:	55                   	push   %ebp
f0103362:	89 e5                	mov    %esp,%ebp
f0103364:	56                   	push   %esi
f0103365:	53                   	push   %ebx
f0103366:	8b 45 08             	mov    0x8(%ebp),%eax
f0103369:	8b 55 0c             	mov    0xc(%ebp),%edx
f010336c:	89 c6                	mov    %eax,%esi
f010336e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103371:	eb 1a                	jmp    f010338d <memcmp+0x2c>
		if (*s1 != *s2)
f0103373:	0f b6 08             	movzbl (%eax),%ecx
f0103376:	0f b6 1a             	movzbl (%edx),%ebx
f0103379:	38 d9                	cmp    %bl,%cl
f010337b:	74 0a                	je     f0103387 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010337d:	0f b6 c1             	movzbl %cl,%eax
f0103380:	0f b6 db             	movzbl %bl,%ebx
f0103383:	29 d8                	sub    %ebx,%eax
f0103385:	eb 0f                	jmp    f0103396 <memcmp+0x35>
		s1++, s2++;
f0103387:	83 c0 01             	add    $0x1,%eax
f010338a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010338d:	39 f0                	cmp    %esi,%eax
f010338f:	75 e2                	jne    f0103373 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103391:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103396:	5b                   	pop    %ebx
f0103397:	5e                   	pop    %esi
f0103398:	5d                   	pop    %ebp
f0103399:	c3                   	ret    

f010339a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010339a:	55                   	push   %ebp
f010339b:	89 e5                	mov    %esp,%ebp
f010339d:	53                   	push   %ebx
f010339e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01033a1:	89 c1                	mov    %eax,%ecx
f01033a3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01033a6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01033aa:	eb 0a                	jmp    f01033b6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01033ac:	0f b6 10             	movzbl (%eax),%edx
f01033af:	39 da                	cmp    %ebx,%edx
f01033b1:	74 07                	je     f01033ba <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01033b3:	83 c0 01             	add    $0x1,%eax
f01033b6:	39 c8                	cmp    %ecx,%eax
f01033b8:	72 f2                	jb     f01033ac <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01033ba:	5b                   	pop    %ebx
f01033bb:	5d                   	pop    %ebp
f01033bc:	c3                   	ret    

f01033bd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01033bd:	55                   	push   %ebp
f01033be:	89 e5                	mov    %esp,%ebp
f01033c0:	57                   	push   %edi
f01033c1:	56                   	push   %esi
f01033c2:	53                   	push   %ebx
f01033c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01033c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01033c9:	eb 03                	jmp    f01033ce <strtol+0x11>
		s++;
f01033cb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01033ce:	0f b6 01             	movzbl (%ecx),%eax
f01033d1:	3c 20                	cmp    $0x20,%al
f01033d3:	74 f6                	je     f01033cb <strtol+0xe>
f01033d5:	3c 09                	cmp    $0x9,%al
f01033d7:	74 f2                	je     f01033cb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01033d9:	3c 2b                	cmp    $0x2b,%al
f01033db:	75 0a                	jne    f01033e7 <strtol+0x2a>
		s++;
f01033dd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01033e0:	bf 00 00 00 00       	mov    $0x0,%edi
f01033e5:	eb 11                	jmp    f01033f8 <strtol+0x3b>
f01033e7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01033ec:	3c 2d                	cmp    $0x2d,%al
f01033ee:	75 08                	jne    f01033f8 <strtol+0x3b>
		s++, neg = 1;
f01033f0:	83 c1 01             	add    $0x1,%ecx
f01033f3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01033f8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01033fe:	75 15                	jne    f0103415 <strtol+0x58>
f0103400:	80 39 30             	cmpb   $0x30,(%ecx)
f0103403:	75 10                	jne    f0103415 <strtol+0x58>
f0103405:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103409:	75 7c                	jne    f0103487 <strtol+0xca>
		s += 2, base = 16;
f010340b:	83 c1 02             	add    $0x2,%ecx
f010340e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103413:	eb 16                	jmp    f010342b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0103415:	85 db                	test   %ebx,%ebx
f0103417:	75 12                	jne    f010342b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103419:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010341e:	80 39 30             	cmpb   $0x30,(%ecx)
f0103421:	75 08                	jne    f010342b <strtol+0x6e>
		s++, base = 8;
f0103423:	83 c1 01             	add    $0x1,%ecx
f0103426:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010342b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103430:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103433:	0f b6 11             	movzbl (%ecx),%edx
f0103436:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103439:	89 f3                	mov    %esi,%ebx
f010343b:	80 fb 09             	cmp    $0x9,%bl
f010343e:	77 08                	ja     f0103448 <strtol+0x8b>
			dig = *s - '0';
f0103440:	0f be d2             	movsbl %dl,%edx
f0103443:	83 ea 30             	sub    $0x30,%edx
f0103446:	eb 22                	jmp    f010346a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0103448:	8d 72 9f             	lea    -0x61(%edx),%esi
f010344b:	89 f3                	mov    %esi,%ebx
f010344d:	80 fb 19             	cmp    $0x19,%bl
f0103450:	77 08                	ja     f010345a <strtol+0x9d>
			dig = *s - 'a' + 10;
f0103452:	0f be d2             	movsbl %dl,%edx
f0103455:	83 ea 57             	sub    $0x57,%edx
f0103458:	eb 10                	jmp    f010346a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010345a:	8d 72 bf             	lea    -0x41(%edx),%esi
f010345d:	89 f3                	mov    %esi,%ebx
f010345f:	80 fb 19             	cmp    $0x19,%bl
f0103462:	77 16                	ja     f010347a <strtol+0xbd>
			dig = *s - 'A' + 10;
f0103464:	0f be d2             	movsbl %dl,%edx
f0103467:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010346a:	3b 55 10             	cmp    0x10(%ebp),%edx
f010346d:	7d 0b                	jge    f010347a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010346f:	83 c1 01             	add    $0x1,%ecx
f0103472:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103476:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0103478:	eb b9                	jmp    f0103433 <strtol+0x76>

	if (endptr)
f010347a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010347e:	74 0d                	je     f010348d <strtol+0xd0>
		*endptr = (char *) s;
f0103480:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103483:	89 0e                	mov    %ecx,(%esi)
f0103485:	eb 06                	jmp    f010348d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103487:	85 db                	test   %ebx,%ebx
f0103489:	74 98                	je     f0103423 <strtol+0x66>
f010348b:	eb 9e                	jmp    f010342b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010348d:	89 c2                	mov    %eax,%edx
f010348f:	f7 da                	neg    %edx
f0103491:	85 ff                	test   %edi,%edi
f0103493:	0f 45 c2             	cmovne %edx,%eax
}
f0103496:	5b                   	pop    %ebx
f0103497:	5e                   	pop    %esi
f0103498:	5f                   	pop    %edi
f0103499:	5d                   	pop    %ebp
f010349a:	c3                   	ret    
f010349b:	66 90                	xchg   %ax,%ax
f010349d:	66 90                	xchg   %ax,%ax
f010349f:	90                   	nop

f01034a0 <__udivdi3>:
f01034a0:	55                   	push   %ebp
f01034a1:	57                   	push   %edi
f01034a2:	56                   	push   %esi
f01034a3:	53                   	push   %ebx
f01034a4:	83 ec 1c             	sub    $0x1c,%esp
f01034a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01034ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01034af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01034b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01034b7:	85 f6                	test   %esi,%esi
f01034b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01034bd:	89 ca                	mov    %ecx,%edx
f01034bf:	89 f8                	mov    %edi,%eax
f01034c1:	75 3d                	jne    f0103500 <__udivdi3+0x60>
f01034c3:	39 cf                	cmp    %ecx,%edi
f01034c5:	0f 87 c5 00 00 00    	ja     f0103590 <__udivdi3+0xf0>
f01034cb:	85 ff                	test   %edi,%edi
f01034cd:	89 fd                	mov    %edi,%ebp
f01034cf:	75 0b                	jne    f01034dc <__udivdi3+0x3c>
f01034d1:	b8 01 00 00 00       	mov    $0x1,%eax
f01034d6:	31 d2                	xor    %edx,%edx
f01034d8:	f7 f7                	div    %edi
f01034da:	89 c5                	mov    %eax,%ebp
f01034dc:	89 c8                	mov    %ecx,%eax
f01034de:	31 d2                	xor    %edx,%edx
f01034e0:	f7 f5                	div    %ebp
f01034e2:	89 c1                	mov    %eax,%ecx
f01034e4:	89 d8                	mov    %ebx,%eax
f01034e6:	89 cf                	mov    %ecx,%edi
f01034e8:	f7 f5                	div    %ebp
f01034ea:	89 c3                	mov    %eax,%ebx
f01034ec:	89 d8                	mov    %ebx,%eax
f01034ee:	89 fa                	mov    %edi,%edx
f01034f0:	83 c4 1c             	add    $0x1c,%esp
f01034f3:	5b                   	pop    %ebx
f01034f4:	5e                   	pop    %esi
f01034f5:	5f                   	pop    %edi
f01034f6:	5d                   	pop    %ebp
f01034f7:	c3                   	ret    
f01034f8:	90                   	nop
f01034f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103500:	39 ce                	cmp    %ecx,%esi
f0103502:	77 74                	ja     f0103578 <__udivdi3+0xd8>
f0103504:	0f bd fe             	bsr    %esi,%edi
f0103507:	83 f7 1f             	xor    $0x1f,%edi
f010350a:	0f 84 98 00 00 00    	je     f01035a8 <__udivdi3+0x108>
f0103510:	bb 20 00 00 00       	mov    $0x20,%ebx
f0103515:	89 f9                	mov    %edi,%ecx
f0103517:	89 c5                	mov    %eax,%ebp
f0103519:	29 fb                	sub    %edi,%ebx
f010351b:	d3 e6                	shl    %cl,%esi
f010351d:	89 d9                	mov    %ebx,%ecx
f010351f:	d3 ed                	shr    %cl,%ebp
f0103521:	89 f9                	mov    %edi,%ecx
f0103523:	d3 e0                	shl    %cl,%eax
f0103525:	09 ee                	or     %ebp,%esi
f0103527:	89 d9                	mov    %ebx,%ecx
f0103529:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010352d:	89 d5                	mov    %edx,%ebp
f010352f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103533:	d3 ed                	shr    %cl,%ebp
f0103535:	89 f9                	mov    %edi,%ecx
f0103537:	d3 e2                	shl    %cl,%edx
f0103539:	89 d9                	mov    %ebx,%ecx
f010353b:	d3 e8                	shr    %cl,%eax
f010353d:	09 c2                	or     %eax,%edx
f010353f:	89 d0                	mov    %edx,%eax
f0103541:	89 ea                	mov    %ebp,%edx
f0103543:	f7 f6                	div    %esi
f0103545:	89 d5                	mov    %edx,%ebp
f0103547:	89 c3                	mov    %eax,%ebx
f0103549:	f7 64 24 0c          	mull   0xc(%esp)
f010354d:	39 d5                	cmp    %edx,%ebp
f010354f:	72 10                	jb     f0103561 <__udivdi3+0xc1>
f0103551:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103555:	89 f9                	mov    %edi,%ecx
f0103557:	d3 e6                	shl    %cl,%esi
f0103559:	39 c6                	cmp    %eax,%esi
f010355b:	73 07                	jae    f0103564 <__udivdi3+0xc4>
f010355d:	39 d5                	cmp    %edx,%ebp
f010355f:	75 03                	jne    f0103564 <__udivdi3+0xc4>
f0103561:	83 eb 01             	sub    $0x1,%ebx
f0103564:	31 ff                	xor    %edi,%edi
f0103566:	89 d8                	mov    %ebx,%eax
f0103568:	89 fa                	mov    %edi,%edx
f010356a:	83 c4 1c             	add    $0x1c,%esp
f010356d:	5b                   	pop    %ebx
f010356e:	5e                   	pop    %esi
f010356f:	5f                   	pop    %edi
f0103570:	5d                   	pop    %ebp
f0103571:	c3                   	ret    
f0103572:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103578:	31 ff                	xor    %edi,%edi
f010357a:	31 db                	xor    %ebx,%ebx
f010357c:	89 d8                	mov    %ebx,%eax
f010357e:	89 fa                	mov    %edi,%edx
f0103580:	83 c4 1c             	add    $0x1c,%esp
f0103583:	5b                   	pop    %ebx
f0103584:	5e                   	pop    %esi
f0103585:	5f                   	pop    %edi
f0103586:	5d                   	pop    %ebp
f0103587:	c3                   	ret    
f0103588:	90                   	nop
f0103589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103590:	89 d8                	mov    %ebx,%eax
f0103592:	f7 f7                	div    %edi
f0103594:	31 ff                	xor    %edi,%edi
f0103596:	89 c3                	mov    %eax,%ebx
f0103598:	89 d8                	mov    %ebx,%eax
f010359a:	89 fa                	mov    %edi,%edx
f010359c:	83 c4 1c             	add    $0x1c,%esp
f010359f:	5b                   	pop    %ebx
f01035a0:	5e                   	pop    %esi
f01035a1:	5f                   	pop    %edi
f01035a2:	5d                   	pop    %ebp
f01035a3:	c3                   	ret    
f01035a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01035a8:	39 ce                	cmp    %ecx,%esi
f01035aa:	72 0c                	jb     f01035b8 <__udivdi3+0x118>
f01035ac:	31 db                	xor    %ebx,%ebx
f01035ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01035b2:	0f 87 34 ff ff ff    	ja     f01034ec <__udivdi3+0x4c>
f01035b8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01035bd:	e9 2a ff ff ff       	jmp    f01034ec <__udivdi3+0x4c>
f01035c2:	66 90                	xchg   %ax,%ax
f01035c4:	66 90                	xchg   %ax,%ax
f01035c6:	66 90                	xchg   %ax,%ax
f01035c8:	66 90                	xchg   %ax,%ax
f01035ca:	66 90                	xchg   %ax,%ax
f01035cc:	66 90                	xchg   %ax,%ax
f01035ce:	66 90                	xchg   %ax,%ax

f01035d0 <__umoddi3>:
f01035d0:	55                   	push   %ebp
f01035d1:	57                   	push   %edi
f01035d2:	56                   	push   %esi
f01035d3:	53                   	push   %ebx
f01035d4:	83 ec 1c             	sub    $0x1c,%esp
f01035d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01035db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01035df:	8b 74 24 34          	mov    0x34(%esp),%esi
f01035e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01035e7:	85 d2                	test   %edx,%edx
f01035e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01035ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01035f1:	89 f3                	mov    %esi,%ebx
f01035f3:	89 3c 24             	mov    %edi,(%esp)
f01035f6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01035fa:	75 1c                	jne    f0103618 <__umoddi3+0x48>
f01035fc:	39 f7                	cmp    %esi,%edi
f01035fe:	76 50                	jbe    f0103650 <__umoddi3+0x80>
f0103600:	89 c8                	mov    %ecx,%eax
f0103602:	89 f2                	mov    %esi,%edx
f0103604:	f7 f7                	div    %edi
f0103606:	89 d0                	mov    %edx,%eax
f0103608:	31 d2                	xor    %edx,%edx
f010360a:	83 c4 1c             	add    $0x1c,%esp
f010360d:	5b                   	pop    %ebx
f010360e:	5e                   	pop    %esi
f010360f:	5f                   	pop    %edi
f0103610:	5d                   	pop    %ebp
f0103611:	c3                   	ret    
f0103612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103618:	39 f2                	cmp    %esi,%edx
f010361a:	89 d0                	mov    %edx,%eax
f010361c:	77 52                	ja     f0103670 <__umoddi3+0xa0>
f010361e:	0f bd ea             	bsr    %edx,%ebp
f0103621:	83 f5 1f             	xor    $0x1f,%ebp
f0103624:	75 5a                	jne    f0103680 <__umoddi3+0xb0>
f0103626:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010362a:	0f 82 e0 00 00 00    	jb     f0103710 <__umoddi3+0x140>
f0103630:	39 0c 24             	cmp    %ecx,(%esp)
f0103633:	0f 86 d7 00 00 00    	jbe    f0103710 <__umoddi3+0x140>
f0103639:	8b 44 24 08          	mov    0x8(%esp),%eax
f010363d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103641:	83 c4 1c             	add    $0x1c,%esp
f0103644:	5b                   	pop    %ebx
f0103645:	5e                   	pop    %esi
f0103646:	5f                   	pop    %edi
f0103647:	5d                   	pop    %ebp
f0103648:	c3                   	ret    
f0103649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103650:	85 ff                	test   %edi,%edi
f0103652:	89 fd                	mov    %edi,%ebp
f0103654:	75 0b                	jne    f0103661 <__umoddi3+0x91>
f0103656:	b8 01 00 00 00       	mov    $0x1,%eax
f010365b:	31 d2                	xor    %edx,%edx
f010365d:	f7 f7                	div    %edi
f010365f:	89 c5                	mov    %eax,%ebp
f0103661:	89 f0                	mov    %esi,%eax
f0103663:	31 d2                	xor    %edx,%edx
f0103665:	f7 f5                	div    %ebp
f0103667:	89 c8                	mov    %ecx,%eax
f0103669:	f7 f5                	div    %ebp
f010366b:	89 d0                	mov    %edx,%eax
f010366d:	eb 99                	jmp    f0103608 <__umoddi3+0x38>
f010366f:	90                   	nop
f0103670:	89 c8                	mov    %ecx,%eax
f0103672:	89 f2                	mov    %esi,%edx
f0103674:	83 c4 1c             	add    $0x1c,%esp
f0103677:	5b                   	pop    %ebx
f0103678:	5e                   	pop    %esi
f0103679:	5f                   	pop    %edi
f010367a:	5d                   	pop    %ebp
f010367b:	c3                   	ret    
f010367c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103680:	8b 34 24             	mov    (%esp),%esi
f0103683:	bf 20 00 00 00       	mov    $0x20,%edi
f0103688:	89 e9                	mov    %ebp,%ecx
f010368a:	29 ef                	sub    %ebp,%edi
f010368c:	d3 e0                	shl    %cl,%eax
f010368e:	89 f9                	mov    %edi,%ecx
f0103690:	89 f2                	mov    %esi,%edx
f0103692:	d3 ea                	shr    %cl,%edx
f0103694:	89 e9                	mov    %ebp,%ecx
f0103696:	09 c2                	or     %eax,%edx
f0103698:	89 d8                	mov    %ebx,%eax
f010369a:	89 14 24             	mov    %edx,(%esp)
f010369d:	89 f2                	mov    %esi,%edx
f010369f:	d3 e2                	shl    %cl,%edx
f01036a1:	89 f9                	mov    %edi,%ecx
f01036a3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01036a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01036ab:	d3 e8                	shr    %cl,%eax
f01036ad:	89 e9                	mov    %ebp,%ecx
f01036af:	89 c6                	mov    %eax,%esi
f01036b1:	d3 e3                	shl    %cl,%ebx
f01036b3:	89 f9                	mov    %edi,%ecx
f01036b5:	89 d0                	mov    %edx,%eax
f01036b7:	d3 e8                	shr    %cl,%eax
f01036b9:	89 e9                	mov    %ebp,%ecx
f01036bb:	09 d8                	or     %ebx,%eax
f01036bd:	89 d3                	mov    %edx,%ebx
f01036bf:	89 f2                	mov    %esi,%edx
f01036c1:	f7 34 24             	divl   (%esp)
f01036c4:	89 d6                	mov    %edx,%esi
f01036c6:	d3 e3                	shl    %cl,%ebx
f01036c8:	f7 64 24 04          	mull   0x4(%esp)
f01036cc:	39 d6                	cmp    %edx,%esi
f01036ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01036d2:	89 d1                	mov    %edx,%ecx
f01036d4:	89 c3                	mov    %eax,%ebx
f01036d6:	72 08                	jb     f01036e0 <__umoddi3+0x110>
f01036d8:	75 11                	jne    f01036eb <__umoddi3+0x11b>
f01036da:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01036de:	73 0b                	jae    f01036eb <__umoddi3+0x11b>
f01036e0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01036e4:	1b 14 24             	sbb    (%esp),%edx
f01036e7:	89 d1                	mov    %edx,%ecx
f01036e9:	89 c3                	mov    %eax,%ebx
f01036eb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01036ef:	29 da                	sub    %ebx,%edx
f01036f1:	19 ce                	sbb    %ecx,%esi
f01036f3:	89 f9                	mov    %edi,%ecx
f01036f5:	89 f0                	mov    %esi,%eax
f01036f7:	d3 e0                	shl    %cl,%eax
f01036f9:	89 e9                	mov    %ebp,%ecx
f01036fb:	d3 ea                	shr    %cl,%edx
f01036fd:	89 e9                	mov    %ebp,%ecx
f01036ff:	d3 ee                	shr    %cl,%esi
f0103701:	09 d0                	or     %edx,%eax
f0103703:	89 f2                	mov    %esi,%edx
f0103705:	83 c4 1c             	add    $0x1c,%esp
f0103708:	5b                   	pop    %ebx
f0103709:	5e                   	pop    %esi
f010370a:	5f                   	pop    %edi
f010370b:	5d                   	pop    %ebp
f010370c:	c3                   	ret    
f010370d:	8d 76 00             	lea    0x0(%esi),%esi
f0103710:	29 f9                	sub    %edi,%ecx
f0103712:	19 d6                	sbb    %edx,%esi
f0103714:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103718:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010371c:	e9 18 ff ff ff       	jmp    f0103639 <__umoddi3+0x69>
