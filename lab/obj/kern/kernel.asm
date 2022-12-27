
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
f0100058:	e8 fe 32 00 00       	call   f010335b <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 96 04 00 00       	call   f01004f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 00 38 10 f0       	push   $0xf0103800
f010006f:	e8 23 28 00 00       	call   f0102897 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 74 11 00 00       	call   f01011ed <mem_init>
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
f01000b0:	68 1b 38 10 f0       	push   $0xf010381b
f01000b5:	e8 dd 27 00 00       	call   f0102897 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 ad 27 00 00       	call   f0102871 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 10 40 10 f0 	movl   $0xf0104010,(%esp)
f01000cb:	e8 c7 27 00 00       	call   f0102897 <cprintf>
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
f01000f2:	68 33 38 10 f0       	push   $0xf0103833
f01000f7:	e8 9b 27 00 00       	call   f0102897 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 69 27 00 00       	call   f0102871 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 10 40 10 f0 	movl   $0xf0104010,(%esp)
f010010f:	e8 83 27 00 00       	call   f0102897 <cprintf>
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
f01001ce:	0f b6 82 a0 39 10 f0 	movzbl -0xfefc660(%edx),%eax
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
f010020a:	0f b6 82 a0 39 10 f0 	movzbl -0xfefc660(%edx),%eax
f0100211:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
f0100217:	0f b6 8a a0 38 10 f0 	movzbl -0xfefc760(%edx),%ecx
f010021e:	31 c8                	xor    %ecx,%eax
f0100220:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100225:	89 c1                	mov    %eax,%ecx
f0100227:	83 e1 03             	and    $0x3,%ecx
f010022a:	8b 0c 8d 80 38 10 f0 	mov    -0xfefc780(,%ecx,4),%ecx
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
f0100268:	68 4d 38 10 f0       	push   $0xf010384d
f010026d:	e8 25 26 00 00       	call   f0102897 <cprintf>
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
f010041c:	e8 87 2f 00 00       	call   f01033a8 <memmove>
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
f01005eb:	68 59 38 10 f0       	push   $0xf0103859
f01005f0:	e8 a2 22 00 00       	call   f0102897 <cprintf>
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
f0100631:	68 a0 3a 10 f0       	push   $0xf0103aa0
f0100636:	68 be 3a 10 f0       	push   $0xf0103abe
f010063b:	68 c3 3a 10 f0       	push   $0xf0103ac3
f0100640:	e8 52 22 00 00       	call   f0102897 <cprintf>
f0100645:	83 c4 0c             	add    $0xc,%esp
f0100648:	68 7c 3b 10 f0       	push   $0xf0103b7c
f010064d:	68 cc 3a 10 f0       	push   $0xf0103acc
f0100652:	68 c3 3a 10 f0       	push   $0xf0103ac3
f0100657:	e8 3b 22 00 00       	call   f0102897 <cprintf>
f010065c:	83 c4 0c             	add    $0xc,%esp
f010065f:	68 d5 3a 10 f0       	push   $0xf0103ad5
f0100664:	68 f3 3a 10 f0       	push   $0xf0103af3
f0100669:	68 c3 3a 10 f0       	push   $0xf0103ac3
f010066e:	e8 24 22 00 00       	call   f0102897 <cprintf>
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
f0100680:	68 fd 3a 10 f0       	push   $0xf0103afd
f0100685:	e8 0d 22 00 00       	call   f0102897 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010068a:	83 c4 08             	add    $0x8,%esp
f010068d:	68 0c 00 10 00       	push   $0x10000c
f0100692:	68 a4 3b 10 f0       	push   $0xf0103ba4
f0100697:	e8 fb 21 00 00       	call   f0102897 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010069c:	83 c4 0c             	add    $0xc,%esp
f010069f:	68 0c 00 10 00       	push   $0x10000c
f01006a4:	68 0c 00 10 f0       	push   $0xf010000c
f01006a9:	68 cc 3b 10 f0       	push   $0xf0103bcc
f01006ae:	e8 e4 21 00 00       	call   f0102897 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b3:	83 c4 0c             	add    $0xc,%esp
f01006b6:	68 e1 37 10 00       	push   $0x1037e1
f01006bb:	68 e1 37 10 f0       	push   $0xf01037e1
f01006c0:	68 f0 3b 10 f0       	push   $0xf0103bf0
f01006c5:	e8 cd 21 00 00       	call   f0102897 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ca:	83 c4 0c             	add    $0xc,%esp
f01006cd:	68 00 73 11 00       	push   $0x117300
f01006d2:	68 00 73 11 f0       	push   $0xf0117300
f01006d7:	68 14 3c 10 f0       	push   $0xf0103c14
f01006dc:	e8 b6 21 00 00       	call   f0102897 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e1:	83 c4 0c             	add    $0xc,%esp
f01006e4:	68 60 79 11 00       	push   $0x117960
f01006e9:	68 60 79 11 f0       	push   $0xf0117960
f01006ee:	68 38 3c 10 f0       	push   $0xf0103c38
f01006f3:	e8 9f 21 00 00       	call   f0102897 <cprintf>
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
f0100719:	68 5c 3c 10 f0       	push   $0xf0103c5c
f010071e:	e8 74 21 00 00       	call   f0102897 <cprintf>
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
f0100758:	68 16 3b 10 f0       	push   $0xf0103b16
f010075d:	e8 35 21 00 00       	call   f0102897 <cprintf>

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
f010078a:	e8 12 22 00 00       	call   f01029a1 <debuginfo_eip>

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
f01007e6:	68 88 3c 10 f0       	push   $0xf0103c88
f01007eb:	e8 a7 20 00 00       	call   f0102897 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f01007f0:	83 c4 14             	add    $0x14,%esp
f01007f3:	2b 75 cc             	sub    -0x34(%ebp),%esi
f01007f6:	56                   	push   %esi
f01007f7:	8d 45 8a             	lea    -0x76(%ebp),%eax
f01007fa:	50                   	push   %eax
f01007fb:	ff 75 c0             	pushl  -0x40(%ebp)
f01007fe:	ff 75 bc             	pushl  -0x44(%ebp)
f0100801:	68 28 3b 10 f0       	push   $0xf0103b28
f0100806:	e8 8c 20 00 00       	call   f0102897 <cprintf>

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
f010082e:	68 c0 3c 10 f0       	push   $0xf0103cc0
f0100833:	e8 5f 20 00 00       	call   f0102897 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100838:	c7 04 24 e4 3c 10 f0 	movl   $0xf0103ce4,(%esp)
f010083f:	e8 53 20 00 00       	call   f0102897 <cprintf>
f0100844:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100847:	83 ec 0c             	sub    $0xc,%esp
f010084a:	68 3f 3b 10 f0       	push   $0xf0103b3f
f010084f:	e8 b0 28 00 00       	call   f0103104 <readline>
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
f0100883:	68 43 3b 10 f0       	push   $0xf0103b43
f0100888:	e8 91 2a 00 00       	call   f010331e <strchr>
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
f01008a3:	68 48 3b 10 f0       	push   $0xf0103b48
f01008a8:	e8 ea 1f 00 00       	call   f0102897 <cprintf>
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
f01008cc:	68 43 3b 10 f0       	push   $0xf0103b43
f01008d1:	e8 48 2a 00 00       	call   f010331e <strchr>
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
f01008fa:	ff 34 85 20 3d 10 f0 	pushl  -0xfefc2e0(,%eax,4)
f0100901:	ff 75 a8             	pushl  -0x58(%ebp)
f0100904:	e8 b7 29 00 00       	call   f01032c0 <strcmp>
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
f010091e:	ff 14 85 28 3d 10 f0 	call   *-0xfefc2d8(,%eax,4)


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
f010093f:	68 65 3b 10 f0       	push   $0xf0103b65
f0100944:	e8 4e 1f 00 00       	call   f0102897 <cprintf>
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
f0100964:	e8 c7 1e 00 00       	call   f0102830 <mc146818_read>
f0100969:	89 c6                	mov    %eax,%esi
f010096b:	83 c3 01             	add    $0x1,%ebx
f010096e:	89 1c 24             	mov    %ebx,(%esp)
f0100971:	e8 ba 1e 00 00       	call   f0102830 <mc146818_read>
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
f01009b0:	68 44 3d 10 f0       	push   $0xf0103d44
f01009b5:	6a 6b                	push   $0x6b
f01009b7:	68 5f 3d 10 f0       	push   $0xf0103d5f
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
f01009df:	74 52                	je     f0100a33 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009e6:	89 c1                	mov    %eax,%ecx
f01009e8:	c1 e9 0c             	shr    $0xc,%ecx
f01009eb:	3b 0d 68 79 11 f0    	cmp    0xf0117968,%ecx
f01009f1:	72 1b                	jb     f0100a0e <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009f3:	55                   	push   %ebp
f01009f4:	89 e5                	mov    %esp,%ebp
f01009f6:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009f9:	50                   	push   %eax
f01009fa:	68 44 40 10 f0       	push   $0xf0104044
f01009ff:	68 5f 03 00 00       	push   $0x35f
f0100a04:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100a09:	e8 7d f6 ff ff       	call   f010008b <_panic>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));

	// cprintf("[?] In check_va2pa\n");
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
f0100a0e:	c1 ea 0c             	shr    $0xc,%edx
f0100a11:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a17:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a1e:	89 c2                	mov    %eax,%edx
f0100a20:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a23:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a28:	85 d2                	test   %edx,%edx
f0100a2a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a2f:	0f 44 c2             	cmove  %edx,%eax
f0100a32:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", &p[PTX(va)], p[PTX(va)]);

	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a38:	c3                   	ret    

f0100a39 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a39:	55                   	push   %ebp
f0100a3a:	89 e5                	mov    %esp,%ebp
f0100a3c:	57                   	push   %edi
f0100a3d:	56                   	push   %esi
f0100a3e:	53                   	push   %ebx
f0100a3f:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a42:	84 c0                	test   %al,%al
f0100a44:	0f 85 81 02 00 00    	jne    f0100ccb <check_page_free_list+0x292>
f0100a4a:	e9 8e 02 00 00       	jmp    f0100cdd <check_page_free_list+0x2a4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a4f:	83 ec 04             	sub    $0x4,%esp
f0100a52:	68 68 40 10 f0       	push   $0xf0104068
f0100a57:	68 9e 02 00 00       	push   $0x29e
f0100a5c:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100a61:	e8 25 f6 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a66:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a69:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a6c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a6f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a72:	89 c2                	mov    %eax,%edx
f0100a74:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0100a7a:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a80:	0f 95 c2             	setne  %dl
f0100a83:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a86:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a8a:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a8c:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a90:	8b 00                	mov    (%eax),%eax
f0100a92:	85 c0                	test   %eax,%eax
f0100a94:	75 dc                	jne    f0100a72 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100aa2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100aa5:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100aa7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100aaa:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100aaf:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ab4:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100aba:	eb 53                	jmp    f0100b0f <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100abc:	89 d8                	mov    %ebx,%eax
f0100abe:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0100ac4:	c1 f8 03             	sar    $0x3,%eax
f0100ac7:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100aca:	89 c2                	mov    %eax,%edx
f0100acc:	c1 ea 16             	shr    $0x16,%edx
f0100acf:	39 f2                	cmp    %esi,%edx
f0100ad1:	73 3a                	jae    f0100b0d <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ad3:	89 c2                	mov    %eax,%edx
f0100ad5:	c1 ea 0c             	shr    $0xc,%edx
f0100ad8:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0100ade:	72 12                	jb     f0100af2 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ae0:	50                   	push   %eax
f0100ae1:	68 44 40 10 f0       	push   $0xf0104044
f0100ae6:	6a 52                	push   $0x52
f0100ae8:	68 6b 3d 10 f0       	push   $0xf0103d6b
f0100aed:	e8 99 f5 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100af2:	83 ec 04             	sub    $0x4,%esp
f0100af5:	68 80 00 00 00       	push   $0x80
f0100afa:	68 97 00 00 00       	push   $0x97
f0100aff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b04:	50                   	push   %eax
f0100b05:	e8 51 28 00 00       	call   f010335b <memset>
f0100b0a:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b0d:	8b 1b                	mov    (%ebx),%ebx
f0100b0f:	85 db                	test   %ebx,%ebx
f0100b11:	75 a9                	jne    f0100abc <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b13:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b18:	e8 65 fe ff ff       	call   f0100982 <boot_alloc>
f0100b1d:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b20:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b26:	8b 0d 70 79 11 f0    	mov    0xf0117970,%ecx
		assert(pp < pages + npages);
f0100b2c:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0100b31:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b34:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b37:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b3a:	be 00 00 00 00       	mov    $0x0,%esi
f0100b3f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b42:	e9 30 01 00 00       	jmp    f0100c77 <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b47:	39 ca                	cmp    %ecx,%edx
f0100b49:	73 19                	jae    f0100b64 <check_page_free_list+0x12b>
f0100b4b:	68 79 3d 10 f0       	push   $0xf0103d79
f0100b50:	68 85 3d 10 f0       	push   $0xf0103d85
f0100b55:	68 b8 02 00 00       	push   $0x2b8
f0100b5a:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100b5f:	e8 27 f5 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100b64:	39 fa                	cmp    %edi,%edx
f0100b66:	72 19                	jb     f0100b81 <check_page_free_list+0x148>
f0100b68:	68 9a 3d 10 f0       	push   $0xf0103d9a
f0100b6d:	68 85 3d 10 f0       	push   $0xf0103d85
f0100b72:	68 b9 02 00 00       	push   $0x2b9
f0100b77:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100b7c:	e8 0a f5 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b81:	89 d0                	mov    %edx,%eax
f0100b83:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b86:	a8 07                	test   $0x7,%al
f0100b88:	74 19                	je     f0100ba3 <check_page_free_list+0x16a>
f0100b8a:	68 8c 40 10 f0       	push   $0xf010408c
f0100b8f:	68 85 3d 10 f0       	push   $0xf0103d85
f0100b94:	68 ba 02 00 00       	push   $0x2ba
f0100b99:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100b9e:	e8 e8 f4 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ba3:	c1 f8 03             	sar    $0x3,%eax
f0100ba6:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100ba9:	85 c0                	test   %eax,%eax
f0100bab:	75 19                	jne    f0100bc6 <check_page_free_list+0x18d>
f0100bad:	68 ae 3d 10 f0       	push   $0xf0103dae
f0100bb2:	68 85 3d 10 f0       	push   $0xf0103d85
f0100bb7:	68 bd 02 00 00       	push   $0x2bd
f0100bbc:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100bc1:	e8 c5 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bc6:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bcb:	75 19                	jne    f0100be6 <check_page_free_list+0x1ad>
f0100bcd:	68 bf 3d 10 f0       	push   $0xf0103dbf
f0100bd2:	68 85 3d 10 f0       	push   $0xf0103d85
f0100bd7:	68 be 02 00 00       	push   $0x2be
f0100bdc:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100be1:	e8 a5 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100be6:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100beb:	75 19                	jne    f0100c06 <check_page_free_list+0x1cd>
f0100bed:	68 c0 40 10 f0       	push   $0xf01040c0
f0100bf2:	68 85 3d 10 f0       	push   $0xf0103d85
f0100bf7:	68 bf 02 00 00       	push   $0x2bf
f0100bfc:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100c01:	e8 85 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c06:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c0b:	75 19                	jne    f0100c26 <check_page_free_list+0x1ed>
f0100c0d:	68 d8 3d 10 f0       	push   $0xf0103dd8
f0100c12:	68 85 3d 10 f0       	push   $0xf0103d85
f0100c17:	68 c0 02 00 00       	push   $0x2c0
f0100c1c:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100c21:	e8 65 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c26:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c2b:	76 3f                	jbe    f0100c6c <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c2d:	89 c3                	mov    %eax,%ebx
f0100c2f:	c1 eb 0c             	shr    $0xc,%ebx
f0100c32:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100c35:	77 12                	ja     f0100c49 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c37:	50                   	push   %eax
f0100c38:	68 44 40 10 f0       	push   $0xf0104044
f0100c3d:	6a 52                	push   $0x52
f0100c3f:	68 6b 3d 10 f0       	push   $0xf0103d6b
f0100c44:	e8 42 f4 ff ff       	call   f010008b <_panic>
f0100c49:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c4e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c51:	76 1e                	jbe    f0100c71 <check_page_free_list+0x238>
f0100c53:	68 e4 40 10 f0       	push   $0xf01040e4
f0100c58:	68 85 3d 10 f0       	push   $0xf0103d85
f0100c5d:	68 c1 02 00 00       	push   $0x2c1
f0100c62:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100c67:	e8 1f f4 ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c6c:	83 c6 01             	add    $0x1,%esi
f0100c6f:	eb 04                	jmp    f0100c75 <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100c71:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c75:	8b 12                	mov    (%edx),%edx
f0100c77:	85 d2                	test   %edx,%edx
f0100c79:	0f 85 c8 fe ff ff    	jne    f0100b47 <check_page_free_list+0x10e>
f0100c7f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c82:	85 f6                	test   %esi,%esi
f0100c84:	7f 19                	jg     f0100c9f <check_page_free_list+0x266>
f0100c86:	68 f2 3d 10 f0       	push   $0xf0103df2
f0100c8b:	68 85 3d 10 f0       	push   $0xf0103d85
f0100c90:	68 c9 02 00 00       	push   $0x2c9
f0100c95:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100c9a:	e8 ec f3 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100c9f:	85 db                	test   %ebx,%ebx
f0100ca1:	7f 19                	jg     f0100cbc <check_page_free_list+0x283>
f0100ca3:	68 04 3e 10 f0       	push   $0xf0103e04
f0100ca8:	68 85 3d 10 f0       	push   $0xf0103d85
f0100cad:	68 ca 02 00 00       	push   $0x2ca
f0100cb2:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100cb7:	e8 cf f3 ff ff       	call   f010008b <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100cbc:	83 ec 0c             	sub    $0xc,%esp
f0100cbf:	68 2c 41 10 f0       	push   $0xf010412c
f0100cc4:	e8 ce 1b 00 00       	call   f0102897 <cprintf>
}
f0100cc9:	eb 29                	jmp    f0100cf4 <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100ccb:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0100cd0:	85 c0                	test   %eax,%eax
f0100cd2:	0f 85 8e fd ff ff    	jne    f0100a66 <check_page_free_list+0x2d>
f0100cd8:	e9 72 fd ff ff       	jmp    f0100a4f <check_page_free_list+0x16>
f0100cdd:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
f0100ce4:	0f 84 65 fd ff ff    	je     f0100a4f <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cea:	be 00 04 00 00       	mov    $0x400,%esi
f0100cef:	e9 c0 fd ff ff       	jmp    f0100ab4 <check_page_free_list+0x7b>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cf7:	5b                   	pop    %ebx
f0100cf8:	5e                   	pop    %esi
f0100cf9:	5f                   	pop    %edi
f0100cfa:	5d                   	pop    %ebp
f0100cfb:	c3                   	ret    

f0100cfc <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100cfc:	55                   	push   %ebp
f0100cfd:	89 e5                	mov    %esp,%ebp
f0100cff:	56                   	push   %esi
f0100d00:	53                   	push   %ebx
	// 	pages[i].pp_link = page_free_list;
	// 	page_free_list = &pages[i];
	// }

	// 1)	first page in use
	pages[0].pp_ref = 1;
f0100d01:	a1 70 79 11 f0       	mov    0xf0117970,%eax
f0100d06:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100d0c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100d12:	8b 35 40 75 11 f0    	mov    0xf0117540,%esi
f0100d18:	8b 0d 3c 75 11 f0    	mov    0xf011753c,%ecx
f0100d1e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d23:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100d28:	eb 27                	jmp    f0100d51 <page_init+0x55>
		pages[i].pp_ref = 0;
f0100d2a:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100d31:	89 c2                	mov    %eax,%edx
f0100d33:	03 15 70 79 11 f0    	add    0xf0117970,%edx
f0100d39:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100d3f:	89 0a                	mov    %ecx,(%edx)
	// 1)	first page in use
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100d41:	83 c3 01             	add    $0x1,%ebx
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100d44:	03 05 70 79 11 f0    	add    0xf0117970,%eax
f0100d4a:	89 c1                	mov    %eax,%ecx
f0100d4c:	b8 01 00 00 00       	mov    $0x1,%eax
	// 1)	first page in use
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100d51:	39 f3                	cmp    %esi,%ebx
f0100d53:	72 d5                	jb     f0100d2a <page_init+0x2e>
f0100d55:	84 c0                	test   %al,%al
f0100d57:	74 06                	je     f0100d5f <page_init+0x63>
f0100d59:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c
f0100d5f:	8b 0d 3c 75 11 f0    	mov    0xf011753c,%ecx
f0100d65:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100d6c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d71:	eb 23                	jmp    f0100d96 <page_init+0x9a>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100d73:	89 c2                	mov    %eax,%edx
f0100d75:	03 15 70 79 11 f0    	add    0xf0117970,%edx
f0100d7b:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100d81:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100d83:	89 c1                	mov    %eax,%ecx
f0100d85:	03 0d 70 79 11 f0    	add    0xf0117970,%ecx
		page_free_list = &pages[i];
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
f0100d8b:	83 c3 01             	add    $0x1,%ebx
f0100d8e:	83 c0 08             	add    $0x8,%eax
f0100d91:	ba 01 00 00 00       	mov    $0x1,%edx
f0100d96:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100d9c:	76 d5                	jbe    f0100d73 <page_init+0x77>
f0100d9e:	84 d2                	test   %dl,%dl
f0100da0:	74 06                	je     f0100da8 <page_init+0xac>
f0100da2:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c
f0100da8:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100daf:	eb 1a                	jmp    f0100dcb <page_init+0xcf>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100db1:	89 c2                	mov    %eax,%edx
f0100db3:	03 15 70 79 11 f0    	add    0xf0117970,%edx
f0100db9:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = 0;
f0100dbf:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
f0100dc5:	83 c3 01             	add    $0x1,%ebx
f0100dc8:	83 c0 08             	add    $0x8,%eax
f0100dcb:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100dd1:	76 de                	jbe    f0100db1 <page_init+0xb5>
f0100dd3:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f0100dda:	eb 1a                	jmp    f0100df6 <page_init+0xfa>


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100ddc:	89 f0                	mov    %esi,%eax
f0100dde:	03 05 70 79 11 f0    	add    0xf0117970,%eax
f0100de4:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = 0;
f0100dea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
f0100df0:	83 c3 01             	add    $0x1,%ebx
f0100df3:	83 c6 08             	add    $0x8,%esi
f0100df6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dfb:	e8 82 fb ff ff       	call   f0100982 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e00:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e05:	77 15                	ja     f0100e1c <page_init+0x120>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e07:	50                   	push   %eax
f0100e08:	68 50 41 10 f0       	push   $0xf0104150
f0100e0d:	68 34 01 00 00       	push   $0x134
f0100e12:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100e17:	e8 6f f2 ff ff       	call   f010008b <_panic>
f0100e1c:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e21:	c1 e8 0c             	shr    $0xc,%eax
f0100e24:	39 c3                	cmp    %eax,%ebx
f0100e26:	72 b4                	jb     f0100ddc <page_init+0xe0>
f0100e28:	8b 0d 3c 75 11 f0    	mov    0xf011753c,%ecx
f0100e2e:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100e35:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e3a:	eb 23                	jmp    f0100e5f <page_init+0x163>
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f0100e3c:	89 c2                	mov    %eax,%edx
f0100e3e:	03 15 70 79 11 f0    	add    0xf0117970,%edx
f0100e44:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100e4a:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100e4c:	89 c1                	mov    %eax,%ecx
f0100e4e:	03 0d 70 79 11 f0    	add    0xf0117970,%ecx
		pages[i].pp_link = 0;
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
f0100e54:	83 c3 01             	add    $0x1,%ebx
f0100e57:	83 c0 08             	add    $0x8,%eax
f0100e5a:	ba 01 00 00 00       	mov    $0x1,%edx
f0100e5f:	3b 1d 68 79 11 f0    	cmp    0xf0117968,%ebx
f0100e65:	72 d5                	jb     f0100e3c <page_init+0x140>
f0100e67:	84 d2                	test   %dl,%dl
f0100e69:	74 06                	je     f0100e71 <page_init+0x175>
f0100e6b:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

}
f0100e71:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e74:	5b                   	pop    %ebx
f0100e75:	5e                   	pop    %esi
f0100e76:	5d                   	pop    %ebp
f0100e77:	c3                   	ret    

f0100e78 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e78:	55                   	push   %ebp
f0100e79:	89 e5                	mov    %esp,%ebp
f0100e7b:	56                   	push   %esi
f0100e7c:	53                   	push   %ebx
	// Fill this function in

	// no more page in free list, we run out of free memory
	if (page_free_list == 0)
f0100e7d:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100e83:	85 db                	test   %ebx,%ebx
f0100e85:	74 59                	je     f0100ee0 <page_alloc+0x68>
		return 0;

	// get the previous page in free link
	struct PageInfo* last_free = page_free_list->pp_link;
f0100e87:	8b 33                	mov    (%ebx),%esi
	struct PageInfo* result = page_free_list;

	// get a free page from the list
	page_free_list->pp_link = 0;
f0100e89:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) {
f0100e8f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e93:	74 45                	je     f0100eda <page_alloc+0x62>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e95:	89 d8                	mov    %ebx,%eax
f0100e97:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0100e9d:	c1 f8 03             	sar    $0x3,%eax
f0100ea0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ea3:	89 c2                	mov    %eax,%edx
f0100ea5:	c1 ea 0c             	shr    $0xc,%edx
f0100ea8:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0100eae:	72 12                	jb     f0100ec2 <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eb0:	50                   	push   %eax
f0100eb1:	68 44 40 10 f0       	push   $0xf0104044
f0100eb6:	6a 52                	push   $0x52
f0100eb8:	68 6b 3d 10 f0       	push   $0xf0103d6b
f0100ebd:	e8 c9 f1 ff ff       	call   f010008b <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f0100ec2:	83 ec 04             	sub    $0x4,%esp
f0100ec5:	68 00 10 00 00       	push   $0x1000
f0100eca:	6a 00                	push   $0x0
f0100ecc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ed1:	50                   	push   %eax
f0100ed2:	e8 84 24 00 00       	call   f010335b <memset>
f0100ed7:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f0100eda:	89 35 3c 75 11 f0    	mov    %esi,0xf011753c

	return result;
}
f0100ee0:	89 d8                	mov    %ebx,%eax
f0100ee2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ee5:	5b                   	pop    %ebx
f0100ee6:	5e                   	pop    %esi
f0100ee7:	5d                   	pop    %ebp
f0100ee8:	c3                   	ret    

f0100ee9 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100ee9:	55                   	push   %ebp
f0100eea:	89 e5                	mov    %esp,%ebp
f0100eec:	83 ec 08             	sub    $0x8,%esp
f0100eef:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.

	if (pp == 0)
f0100ef2:	85 c0                	test   %eax,%eax
f0100ef4:	74 47                	je     f0100f3d <page_free+0x54>
		return;
	if (pp->pp_link != 0)
f0100ef6:	83 38 00             	cmpl   $0x0,(%eax)
f0100ef9:	74 17                	je     f0100f12 <page_free+0x29>
		panic("page_free: double free or corrupted\n");
f0100efb:	83 ec 04             	sub    $0x4,%esp
f0100efe:	68 74 41 10 f0       	push   $0xf0104174
f0100f03:	68 79 01 00 00       	push   $0x179
f0100f08:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100f0d:	e8 79 f1 ff ff       	call   f010008b <_panic>
	if (pp->pp_ref != 0)
f0100f12:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f17:	74 17                	je     f0100f30 <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0100f19:	83 ec 04             	sub    $0x4,%esp
f0100f1c:	68 9c 41 10 f0       	push   $0xf010419c
f0100f21:	68 7b 01 00 00       	push   $0x17b
f0100f26:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100f2b:	e8 5b f1 ff ff       	call   f010008b <_panic>

	pp->pp_link = page_free_list;
f0100f30:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100f36:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f38:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

}
f0100f3d:	c9                   	leave  
f0100f3e:	c3                   	ret    

f0100f3f <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f3f:	55                   	push   %ebp
f0100f40:	89 e5                	mov    %esp,%ebp
f0100f42:	83 ec 08             	sub    $0x8,%esp
f0100f45:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f48:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f4c:	83 e8 01             	sub    $0x1,%eax
f0100f4f:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f53:	66 85 c0             	test   %ax,%ax
f0100f56:	75 0c                	jne    f0100f64 <page_decref+0x25>
		page_free(pp);
f0100f58:	83 ec 0c             	sub    $0xc,%esp
f0100f5b:	52                   	push   %edx
f0100f5c:	e8 88 ff ff ff       	call   f0100ee9 <page_free>
f0100f61:	83 c4 10             	add    $0x10,%esp
}
f0100f64:	c9                   	leave  
f0100f65:	c3                   	ret    

f0100f66 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f66:	55                   	push   %ebp
f0100f67:	89 e5                	mov    %esp,%ebp
f0100f69:	56                   	push   %esi
f0100f6a:	53                   	push   %ebx
f0100f6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	// we have virtual address
	// cprintf("[?] %x\n", va);
	uint32_t Page_Directory_Index = PDX(va);
	uint32_t Page_Table_Index = PTX(va);
f0100f6e:	89 de                	mov    %ebx,%esi
f0100f70:	c1 ee 0c             	shr    $0xc,%esi
f0100f73:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
f0100f79:	c1 eb 16             	shr    $0x16,%ebx
f0100f7c:	c1 e3 02             	shl    $0x2,%ebx
f0100f7f:	03 5d 08             	add    0x8(%ebp),%ebx
f0100f82:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100f85:	75 30                	jne    f0100fb7 <pgdir_walk+0x51>
		if (create == 0)
f0100f87:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f8b:	74 5c                	je     f0100fe9 <pgdir_walk+0x83>
			return NULL;
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f0100f8d:	83 ec 0c             	sub    $0xc,%esp
f0100f90:	6a 01                	push   $0x1
f0100f92:	e8 e1 fe ff ff       	call   f0100e78 <page_alloc>
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
f0100f97:	83 c4 10             	add    $0x10,%esp
f0100f9a:	85 c0                	test   %eax,%eax
f0100f9c:	74 52                	je     f0100ff0 <pgdir_walk+0x8a>
		// set level 1 page table entry to this new level 2 page table
		// this new page is for level2 PT, so flags are:
		// 	PTE_P: this page is present
		//	PTE_U: user process can use this page
		//	PTE_W: this page can be edit
		pgdir[Page_Directory_Index] = page2pa(new_page) | PTE_P | PTE_U | PTE_W;
f0100f9e:	89 c2                	mov    %eax,%edx
f0100fa0:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0100fa6:	c1 fa 03             	sar    $0x3,%edx
f0100fa9:	c1 e2 0c             	shl    $0xc,%edx
f0100fac:	83 ca 07             	or     $0x7,%edx
f0100faf:	89 13                	mov    %edx,(%ebx)
		new_page->pp_ref = 1;
f0100fb1:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	// cprintf("[?] %x\n", KADDR(PTE_ADDR(pgdir[Page_Directory_Index])));
	
	// remember each entry is 4 byte long
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));
f0100fb7:	8b 03                	mov    (%ebx),%eax
f0100fb9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fbe:	89 c2                	mov    %eax,%edx
f0100fc0:	c1 ea 0c             	shr    $0xc,%edx
f0100fc3:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0100fc9:	72 15                	jb     f0100fe0 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fcb:	50                   	push   %eax
f0100fcc:	68 44 40 10 f0       	push   $0xf0104044
f0100fd1:	68 c8 01 00 00       	push   $0x1c8
f0100fd6:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0100fdb:	e8 ab f0 ff ff       	call   f010008b <_panic>

	return &p[Page_Table_Index];
f0100fe0:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0100fe7:	eb 0c                	jmp    f0100ff5 <pgdir_walk+0x8f>
	uint32_t Offset_In_PTE = PGOFF(va);

	// level 2 page table not exist
	if (pgdir[Page_Directory_Index] == 0) {
		if (create == 0)
			return NULL;
f0100fe9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fee:	eb 05                	jmp    f0100ff5 <pgdir_walk+0x8f>
		
		// allocate a new physical page to be a page table
		struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
		// cprintf("[??] %x\n", new_page);
		if (new_page == 0)	// page allocate fail
			return NULL;
f0100ff0:	b8 00 00 00 00       	mov    $0x0,%eax
	// so we need to convert type to pte_t * in order to add 4 on address each time
	// instead of add 1
	pte_t *p = (pte_t *) KADDR(PTE_ADDR(pgdir[Page_Directory_Index]));

	return &p[Page_Table_Index];
}
f0100ff5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ff8:	5b                   	pop    %ebx
f0100ff9:	5e                   	pop    %esi
f0100ffa:	5d                   	pop    %ebp
f0100ffb:	c3                   	ret    

f0100ffc <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100ffc:	55                   	push   %ebp
f0100ffd:	89 e5                	mov    %esp,%ebp
f0100fff:	57                   	push   %edi
f0101000:	56                   	push   %esi
f0101001:	53                   	push   %ebx
f0101002:	83 ec 1c             	sub    $0x1c,%esp
f0101005:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101008:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in	
	if (size % PGSIZE != 0)
f010100b:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
f0101011:	74 17                	je     f010102a <boot_map_region+0x2e>
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
f0101013:	83 ec 04             	sub    $0x4,%esp
f0101016:	68 e0 41 10 f0       	push   $0xf01041e0
f010101b:	68 dd 01 00 00       	push   $0x1dd
f0101020:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101025:	e8 61 f0 ff ff       	call   f010008b <_panic>
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
f010102a:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101030:	75 23                	jne    f0101055 <boot_map_region+0x59>
f0101032:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0101037:	75 1c                	jne    f0101055 <boot_map_region+0x59>
f0101039:	c1 e9 0c             	shr    $0xc,%ecx
f010103c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f010103f:	89 c3                	mov    %eax,%ebx
f0101041:	be 00 00 00 00       	mov    $0x0,%esi

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f0101046:	89 d7                	mov    %edx,%edi
f0101048:	29 c7                	sub    %eax,%edi

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f010104a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010104d:	83 c8 01             	or     $0x1,%eax
f0101050:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101053:	eb 5c                	jmp    f01010b1 <boot_map_region+0xb5>
	// Fill this function in	
	if (size % PGSIZE != 0)
		panic("boot_map_region: size is not a multiple of PGSIZE\n");
	
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");
f0101055:	83 ec 04             	sub    $0x4,%esp
f0101058:	68 14 42 10 f0       	push   $0xf0104214
f010105d:	68 e0 01 00 00       	push   $0x1e0
f0101062:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101067:	e8 1f f0 ff ff       	call   f010008b <_panic>
	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {

		// find the real PTE for va
		// create on walk, if not present
		pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f010106c:	83 ec 04             	sub    $0x4,%esp
f010106f:	6a 01                	push   $0x1
f0101071:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0101074:	50                   	push   %eax
f0101075:	ff 75 e0             	pushl  -0x20(%ebp)
f0101078:	e8 e9 fe ff ff       	call   f0100f66 <pgdir_walk>

		if (pte == 0)
f010107d:	83 c4 10             	add    $0x10,%esp
f0101080:	85 c0                	test   %eax,%eax
f0101082:	75 17                	jne    f010109b <boot_map_region+0x9f>
			panic("boot_map_region: pgdir_walk return NULL\n");
f0101084:	83 ec 04             	sub    $0x4,%esp
f0101087:	68 44 42 10 f0       	push   $0xf0104244
f010108c:	68 eb 01 00 00       	push   $0x1eb
f0101091:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101096:	e8 f0 ef ff ff       	call   f010008b <_panic>

		// set the real PTE to pa, zero out least 12 bits
		*pte = PTE_ADDR(pa);
		
		// set flags
		*pte |= (perm | PTE_P);
f010109b:	89 da                	mov    %ebx,%edx
f010109d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01010a3:	0b 55 dc             	or     -0x24(%ebp),%edx
f01010a6:	89 10                	mov    %edx,(%eax)

		// deal with next page
		va += PGSIZE;
		pa += PGSIZE;
f01010a8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	if (va % PGSIZE != 0 || pa % PGSIZE != 0)
		panic("boot_map_region: va or pa is not page-aligned\n");


	// set all pages related
	for (int i=0; i<size/PGSIZE; i++) {
f01010ae:	83 c6 01             	add    $0x1,%esi
f01010b1:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01010b4:	75 b6                	jne    f010106c <boot_map_region+0x70>
		va += PGSIZE;
		pa += PGSIZE;

	}

}
f01010b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010b9:	5b                   	pop    %ebx
f01010ba:	5e                   	pop    %esi
f01010bb:	5f                   	pop    %edi
f01010bc:	5d                   	pop    %ebp
f01010bd:	c3                   	ret    

f01010be <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01010be:	55                   	push   %ebp
f01010bf:	89 e5                	mov    %esp,%ebp
f01010c1:	53                   	push   %ebx
f01010c2:	83 ec 08             	sub    $0x8,%esp
f01010c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in

	// do a page table walk to find real PTE
	pte_t * pte = pgdir_walk(pgdir, va, 0);
f01010c8:	6a 00                	push   $0x0
f01010ca:	ff 75 0c             	pushl  0xc(%ebp)
f01010cd:	ff 75 08             	pushl  0x8(%ebp)
f01010d0:	e8 91 fe ff ff       	call   f0100f66 <pgdir_walk>

	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
f01010d5:	83 c4 10             	add    $0x10,%esp
f01010d8:	85 c0                	test   %eax,%eax
f01010da:	74 37                	je     f0101113 <page_lookup+0x55>
f01010dc:	83 38 00             	cmpl   $0x0,(%eax)
f01010df:	74 39                	je     f010111a <page_lookup+0x5c>
		return NULL;
	
	// store pte
	if (pte_store != 0)
f01010e1:	85 db                	test   %ebx,%ebx
f01010e3:	74 02                	je     f01010e7 <page_lookup+0x29>
		*pte_store = pte;
f01010e5:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010e7:	8b 00                	mov    (%eax),%eax
f01010e9:	c1 e8 0c             	shr    $0xc,%eax
f01010ec:	3b 05 68 79 11 f0    	cmp    0xf0117968,%eax
f01010f2:	72 14                	jb     f0101108 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01010f4:	83 ec 04             	sub    $0x4,%esp
f01010f7:	68 70 42 10 f0       	push   $0xf0104270
f01010fc:	6a 4b                	push   $0x4b
f01010fe:	68 6b 3d 10 f0       	push   $0xf0103d6b
f0101103:	e8 83 ef ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0101108:	8b 15 70 79 11 f0    	mov    0xf0117970,%edx
f010110e:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte)) ;
f0101111:	eb 0c                	jmp    f010111f <page_lookup+0x61>
	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
		return NULL;
f0101113:	b8 00 00 00 00       	mov    $0x0,%eax
f0101118:	eb 05                	jmp    f010111f <page_lookup+0x61>
f010111a:	b8 00 00 00 00       	mov    $0x0,%eax
	// store pte
	if (pte_store != 0)
		*pte_store = pte;

	return pa2page(PTE_ADDR(*pte)) ;
}
f010111f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101122:	c9                   	leave  
f0101123:	c3                   	ret    

f0101124 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101124:	55                   	push   %ebp
f0101125:	89 e5                	mov    %esp,%ebp
f0101127:	53                   	push   %ebx
f0101128:	83 ec 18             	sub    $0x18,%esp
f010112b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	// pte_t *tmp;
	pte_t *pte_store = NULL;
f010112e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * pp = page_lookup(pgdir, va, &pte_store);
f0101135:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101138:	50                   	push   %eax
f0101139:	53                   	push   %ebx
f010113a:	ff 75 08             	pushl  0x8(%ebp)
f010113d:	e8 7c ff ff ff       	call   f01010be <page_lookup>

	// if not present, silently return
	if (pp == NULL)
f0101142:	83 c4 10             	add    $0x10,%esp
f0101145:	85 c0                	test   %eax,%eax
f0101147:	74 18                	je     f0101161 <page_remove+0x3d>
		return;

	// decrement ref count, and if reaches 0, free it
	page_decref(pp);
f0101149:	83 ec 0c             	sub    $0xc,%esp
f010114c:	50                   	push   %eax
f010114d:	e8 ed fd ff ff       	call   f0100f3f <page_decref>

	// null the real PTE pointer 
	*pte_store = 0;
f0101152:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101155:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010115b:	0f 01 3b             	invlpg (%ebx)
f010115e:	83 c4 10             	add    $0x10,%esp
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", *pte_store, **pte_store);

	// tlb invalidate
	tlb_invalidate(pgdir, va);

}
f0101161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101164:	c9                   	leave  
f0101165:	c3                   	ret    

f0101166 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101166:	55                   	push   %ebp
f0101167:	89 e5                	mov    %esp,%ebp
f0101169:	57                   	push   %edi
f010116a:	56                   	push   %esi
f010116b:	53                   	push   %ebx
f010116c:	83 ec 10             	sub    $0x10,%esp
f010116f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101172:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	
f0101175:	6a 01                	push   $0x1
f0101177:	57                   	push   %edi
f0101178:	ff 75 08             	pushl  0x8(%ebp)
f010117b:	e8 e6 fd ff ff       	call   f0100f66 <pgdir_walk>

	if (pte == 0)
f0101180:	83 c4 10             	add    $0x10,%esp
f0101183:	85 c0                	test   %eax,%eax
f0101185:	74 59                	je     f01011e0 <page_insert+0x7a>
f0101187:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;

	// already have a page
	// remove it and invalidate tlb
	if (*pte != 0) {
f0101189:	8b 00                	mov    (%eax),%eax
f010118b:	85 c0                	test   %eax,%eax
f010118d:	74 2d                	je     f01011bc <page_insert+0x56>
		// corner case
		if (page2pa(pp) == PTE_ADDR(*pte))
f010118f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101194:	89 da                	mov    %ebx,%edx
f0101196:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f010119c:	c1 fa 03             	sar    $0x3,%edx
f010119f:	c1 e2 0c             	shl    $0xc,%edx
f01011a2:	39 d0                	cmp    %edx,%eax
f01011a4:	75 07                	jne    f01011ad <page_insert+0x47>
			pp->pp_ref--;	// keep pp_ref consistent, in the meantime change perm potentially.
f01011a6:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01011ab:	eb 0f                	jmp    f01011bc <page_insert+0x56>
		else
			page_remove(pgdir, va);
f01011ad:	83 ec 08             	sub    $0x8,%esp
f01011b0:	57                   	push   %edi
f01011b1:	ff 75 08             	pushl  0x8(%ebp)
f01011b4:	e8 6b ff ff ff       	call   f0101124 <page_remove>
f01011b9:	83 c4 10             	add    $0x10,%esp

	// set the real PTE to pa, zero out least 12 bits
	*pte = PTE_ADDR(page2pa(pp));
	
	// set flags
	*pte |= (perm | PTE_P);
f01011bc:	89 d8                	mov    %ebx,%eax
f01011be:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01011c4:	c1 f8 03             	sar    $0x3,%eax
f01011c7:	c1 e0 0c             	shl    $0xc,%eax
f01011ca:	8b 55 14             	mov    0x14(%ebp),%edx
f01011cd:	83 ca 01             	or     $0x1,%edx
f01011d0:	09 d0                	or     %edx,%eax
f01011d2:	89 06                	mov    %eax,(%esi)

	// increment ref cnt
	pp->pp_ref++;
f01011d4:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	return 0;
f01011d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01011de:	eb 05                	jmp    f01011e5 <page_insert+0x7f>
	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	

	if (pte == 0)
		return -E_NO_MEM;
f01011e0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	// increment ref cnt
	pp->pp_ref++;

	return 0;
}
f01011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011e8:	5b                   	pop    %ebx
f01011e9:	5e                   	pop    %esi
f01011ea:	5f                   	pop    %edi
f01011eb:	5d                   	pop    %ebp
f01011ec:	c3                   	ret    

f01011ed <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01011ed:	55                   	push   %ebp
f01011ee:	89 e5                	mov    %esp,%ebp
f01011f0:	57                   	push   %edi
f01011f1:	56                   	push   %esi
f01011f2:	53                   	push   %ebx
f01011f3:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01011f6:	b8 15 00 00 00       	mov    $0x15,%eax
f01011fb:	e8 59 f7 ff ff       	call   f0100959 <nvram_read>
f0101200:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101202:	b8 17 00 00 00       	mov    $0x17,%eax
f0101207:	e8 4d f7 ff ff       	call   f0100959 <nvram_read>
f010120c:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010120e:	b8 34 00 00 00       	mov    $0x34,%eax
f0101213:	e8 41 f7 ff ff       	call   f0100959 <nvram_read>
f0101218:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f010121b:	85 c0                	test   %eax,%eax
f010121d:	74 07                	je     f0101226 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f010121f:	05 00 40 00 00       	add    $0x4000,%eax
f0101224:	eb 0b                	jmp    f0101231 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0101226:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010122c:	85 f6                	test   %esi,%esi
f010122e:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0101231:	89 c2                	mov    %eax,%edx
f0101233:	c1 ea 02             	shr    $0x2,%edx
f0101236:	89 15 68 79 11 f0    	mov    %edx,0xf0117968
	npages_basemem = basemem / (PGSIZE / 1024);
f010123c:	89 da                	mov    %ebx,%edx
f010123e:	c1 ea 02             	shr    $0x2,%edx
f0101241:	89 15 40 75 11 f0    	mov    %edx,0xf0117540

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101247:	89 c2                	mov    %eax,%edx
f0101249:	29 da                	sub    %ebx,%edx
f010124b:	52                   	push   %edx
f010124c:	53                   	push   %ebx
f010124d:	50                   	push   %eax
f010124e:	68 90 42 10 f0       	push   $0xf0104290
f0101253:	e8 3f 16 00 00       	call   f0102897 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101258:	b8 00 10 00 00       	mov    $0x1000,%eax
f010125d:	e8 20 f7 ff ff       	call   f0100982 <boot_alloc>
f0101262:	a3 6c 79 11 f0       	mov    %eax,0xf011796c
	memset(kern_pgdir, 0, PGSIZE);
f0101267:	83 c4 0c             	add    $0xc,%esp
f010126a:	68 00 10 00 00       	push   $0x1000
f010126f:	6a 00                	push   $0x0
f0101271:	50                   	push   %eax
f0101272:	e8 e4 20 00 00       	call   f010335b <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101277:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010127c:	83 c4 10             	add    $0x10,%esp
f010127f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101284:	77 15                	ja     f010129b <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101286:	50                   	push   %eax
f0101287:	68 50 41 10 f0       	push   $0xf0104150
f010128c:	68 96 00 00 00       	push   $0x96
f0101291:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101296:	e8 f0 ed ff ff       	call   f010008b <_panic>
f010129b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01012a1:	83 ca 05             	or     $0x5,%edx
f01012a4:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f01012aa:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01012af:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f01012b6:	89 d8                	mov    %ebx,%eax
f01012b8:	e8 c5 f6 ff ff       	call   f0100982 <boot_alloc>
f01012bd:	a3 70 79 11 f0       	mov    %eax,0xf0117970
	memset(pages, 0, n);
f01012c2:	83 ec 04             	sub    $0x4,%esp
f01012c5:	53                   	push   %ebx
f01012c6:	6a 00                	push   $0x0
f01012c8:	50                   	push   %eax
f01012c9:	e8 8d 20 00 00       	call   f010335b <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01012ce:	e8 29 fa ff ff       	call   f0100cfc <page_init>

	check_page_free_list(1);
f01012d3:	b8 01 00 00 00       	mov    $0x1,%eax
f01012d8:	e8 5c f7 ff ff       	call   f0100a39 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01012dd:	83 c4 10             	add    $0x10,%esp
f01012e0:	83 3d 70 79 11 f0 00 	cmpl   $0x0,0xf0117970
f01012e7:	75 17                	jne    f0101300 <mem_init+0x113>
		panic("'pages' is a null pointer!");
f01012e9:	83 ec 04             	sub    $0x4,%esp
f01012ec:	68 15 3e 10 f0       	push   $0xf0103e15
f01012f1:	68 dd 02 00 00       	push   $0x2dd
f01012f6:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01012fb:	e8 8b ed ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101300:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101305:	bb 00 00 00 00       	mov    $0x0,%ebx
f010130a:	eb 05                	jmp    f0101311 <mem_init+0x124>
		++nfree;
f010130c:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010130f:	8b 00                	mov    (%eax),%eax
f0101311:	85 c0                	test   %eax,%eax
f0101313:	75 f7                	jne    f010130c <mem_init+0x11f>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101315:	83 ec 0c             	sub    $0xc,%esp
f0101318:	6a 00                	push   $0x0
f010131a:	e8 59 fb ff ff       	call   f0100e78 <page_alloc>
f010131f:	89 c7                	mov    %eax,%edi
f0101321:	83 c4 10             	add    $0x10,%esp
f0101324:	85 c0                	test   %eax,%eax
f0101326:	75 19                	jne    f0101341 <mem_init+0x154>
f0101328:	68 30 3e 10 f0       	push   $0xf0103e30
f010132d:	68 85 3d 10 f0       	push   $0xf0103d85
f0101332:	68 e5 02 00 00       	push   $0x2e5
f0101337:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010133c:	e8 4a ed ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101341:	83 ec 0c             	sub    $0xc,%esp
f0101344:	6a 00                	push   $0x0
f0101346:	e8 2d fb ff ff       	call   f0100e78 <page_alloc>
f010134b:	89 c6                	mov    %eax,%esi
f010134d:	83 c4 10             	add    $0x10,%esp
f0101350:	85 c0                	test   %eax,%eax
f0101352:	75 19                	jne    f010136d <mem_init+0x180>
f0101354:	68 46 3e 10 f0       	push   $0xf0103e46
f0101359:	68 85 3d 10 f0       	push   $0xf0103d85
f010135e:	68 e6 02 00 00       	push   $0x2e6
f0101363:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101368:	e8 1e ed ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010136d:	83 ec 0c             	sub    $0xc,%esp
f0101370:	6a 00                	push   $0x0
f0101372:	e8 01 fb ff ff       	call   f0100e78 <page_alloc>
f0101377:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010137a:	83 c4 10             	add    $0x10,%esp
f010137d:	85 c0                	test   %eax,%eax
f010137f:	75 19                	jne    f010139a <mem_init+0x1ad>
f0101381:	68 5c 3e 10 f0       	push   $0xf0103e5c
f0101386:	68 85 3d 10 f0       	push   $0xf0103d85
f010138b:	68 e7 02 00 00       	push   $0x2e7
f0101390:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101395:	e8 f1 ec ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010139a:	39 f7                	cmp    %esi,%edi
f010139c:	75 19                	jne    f01013b7 <mem_init+0x1ca>
f010139e:	68 72 3e 10 f0       	push   $0xf0103e72
f01013a3:	68 85 3d 10 f0       	push   $0xf0103d85
f01013a8:	68 ea 02 00 00       	push   $0x2ea
f01013ad:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01013b2:	e8 d4 ec ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013ba:	39 c6                	cmp    %eax,%esi
f01013bc:	74 04                	je     f01013c2 <mem_init+0x1d5>
f01013be:	39 c7                	cmp    %eax,%edi
f01013c0:	75 19                	jne    f01013db <mem_init+0x1ee>
f01013c2:	68 cc 42 10 f0       	push   $0xf01042cc
f01013c7:	68 85 3d 10 f0       	push   $0xf0103d85
f01013cc:	68 eb 02 00 00       	push   $0x2eb
f01013d1:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01013d6:	e8 b0 ec ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013db:	8b 0d 70 79 11 f0    	mov    0xf0117970,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01013e1:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f01013e7:	c1 e2 0c             	shl    $0xc,%edx
f01013ea:	89 f8                	mov    %edi,%eax
f01013ec:	29 c8                	sub    %ecx,%eax
f01013ee:	c1 f8 03             	sar    $0x3,%eax
f01013f1:	c1 e0 0c             	shl    $0xc,%eax
f01013f4:	39 d0                	cmp    %edx,%eax
f01013f6:	72 19                	jb     f0101411 <mem_init+0x224>
f01013f8:	68 84 3e 10 f0       	push   $0xf0103e84
f01013fd:	68 85 3d 10 f0       	push   $0xf0103d85
f0101402:	68 ec 02 00 00       	push   $0x2ec
f0101407:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010140c:	e8 7a ec ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101411:	89 f0                	mov    %esi,%eax
f0101413:	29 c8                	sub    %ecx,%eax
f0101415:	c1 f8 03             	sar    $0x3,%eax
f0101418:	c1 e0 0c             	shl    $0xc,%eax
f010141b:	39 c2                	cmp    %eax,%edx
f010141d:	77 19                	ja     f0101438 <mem_init+0x24b>
f010141f:	68 a1 3e 10 f0       	push   $0xf0103ea1
f0101424:	68 85 3d 10 f0       	push   $0xf0103d85
f0101429:	68 ed 02 00 00       	push   $0x2ed
f010142e:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101433:	e8 53 ec ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101438:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010143b:	29 c8                	sub    %ecx,%eax
f010143d:	c1 f8 03             	sar    $0x3,%eax
f0101440:	c1 e0 0c             	shl    $0xc,%eax
f0101443:	39 c2                	cmp    %eax,%edx
f0101445:	77 19                	ja     f0101460 <mem_init+0x273>
f0101447:	68 be 3e 10 f0       	push   $0xf0103ebe
f010144c:	68 85 3d 10 f0       	push   $0xf0103d85
f0101451:	68 ee 02 00 00       	push   $0x2ee
f0101456:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010145b:	e8 2b ec ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101460:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101465:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101468:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f010146f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101472:	83 ec 0c             	sub    $0xc,%esp
f0101475:	6a 00                	push   $0x0
f0101477:	e8 fc f9 ff ff       	call   f0100e78 <page_alloc>
f010147c:	83 c4 10             	add    $0x10,%esp
f010147f:	85 c0                	test   %eax,%eax
f0101481:	74 19                	je     f010149c <mem_init+0x2af>
f0101483:	68 db 3e 10 f0       	push   $0xf0103edb
f0101488:	68 85 3d 10 f0       	push   $0xf0103d85
f010148d:	68 f5 02 00 00       	push   $0x2f5
f0101492:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101497:	e8 ef eb ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f010149c:	83 ec 0c             	sub    $0xc,%esp
f010149f:	57                   	push   %edi
f01014a0:	e8 44 fa ff ff       	call   f0100ee9 <page_free>
	page_free(pp1);
f01014a5:	89 34 24             	mov    %esi,(%esp)
f01014a8:	e8 3c fa ff ff       	call   f0100ee9 <page_free>
	page_free(pp2);
f01014ad:	83 c4 04             	add    $0x4,%esp
f01014b0:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014b3:	e8 31 fa ff ff       	call   f0100ee9 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014bf:	e8 b4 f9 ff ff       	call   f0100e78 <page_alloc>
f01014c4:	89 c6                	mov    %eax,%esi
f01014c6:	83 c4 10             	add    $0x10,%esp
f01014c9:	85 c0                	test   %eax,%eax
f01014cb:	75 19                	jne    f01014e6 <mem_init+0x2f9>
f01014cd:	68 30 3e 10 f0       	push   $0xf0103e30
f01014d2:	68 85 3d 10 f0       	push   $0xf0103d85
f01014d7:	68 fc 02 00 00       	push   $0x2fc
f01014dc:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01014e1:	e8 a5 eb ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01014e6:	83 ec 0c             	sub    $0xc,%esp
f01014e9:	6a 00                	push   $0x0
f01014eb:	e8 88 f9 ff ff       	call   f0100e78 <page_alloc>
f01014f0:	89 c7                	mov    %eax,%edi
f01014f2:	83 c4 10             	add    $0x10,%esp
f01014f5:	85 c0                	test   %eax,%eax
f01014f7:	75 19                	jne    f0101512 <mem_init+0x325>
f01014f9:	68 46 3e 10 f0       	push   $0xf0103e46
f01014fe:	68 85 3d 10 f0       	push   $0xf0103d85
f0101503:	68 fd 02 00 00       	push   $0x2fd
f0101508:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010150d:	e8 79 eb ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101512:	83 ec 0c             	sub    $0xc,%esp
f0101515:	6a 00                	push   $0x0
f0101517:	e8 5c f9 ff ff       	call   f0100e78 <page_alloc>
f010151c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010151f:	83 c4 10             	add    $0x10,%esp
f0101522:	85 c0                	test   %eax,%eax
f0101524:	75 19                	jne    f010153f <mem_init+0x352>
f0101526:	68 5c 3e 10 f0       	push   $0xf0103e5c
f010152b:	68 85 3d 10 f0       	push   $0xf0103d85
f0101530:	68 fe 02 00 00       	push   $0x2fe
f0101535:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010153a:	e8 4c eb ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010153f:	39 fe                	cmp    %edi,%esi
f0101541:	75 19                	jne    f010155c <mem_init+0x36f>
f0101543:	68 72 3e 10 f0       	push   $0xf0103e72
f0101548:	68 85 3d 10 f0       	push   $0xf0103d85
f010154d:	68 00 03 00 00       	push   $0x300
f0101552:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101557:	e8 2f eb ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010155c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010155f:	39 c7                	cmp    %eax,%edi
f0101561:	74 04                	je     f0101567 <mem_init+0x37a>
f0101563:	39 c6                	cmp    %eax,%esi
f0101565:	75 19                	jne    f0101580 <mem_init+0x393>
f0101567:	68 cc 42 10 f0       	push   $0xf01042cc
f010156c:	68 85 3d 10 f0       	push   $0xf0103d85
f0101571:	68 01 03 00 00       	push   $0x301
f0101576:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010157b:	e8 0b eb ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101580:	83 ec 0c             	sub    $0xc,%esp
f0101583:	6a 00                	push   $0x0
f0101585:	e8 ee f8 ff ff       	call   f0100e78 <page_alloc>
f010158a:	83 c4 10             	add    $0x10,%esp
f010158d:	85 c0                	test   %eax,%eax
f010158f:	74 19                	je     f01015aa <mem_init+0x3bd>
f0101591:	68 db 3e 10 f0       	push   $0xf0103edb
f0101596:	68 85 3d 10 f0       	push   $0xf0103d85
f010159b:	68 02 03 00 00       	push   $0x302
f01015a0:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01015a5:	e8 e1 ea ff ff       	call   f010008b <_panic>
f01015aa:	89 f0                	mov    %esi,%eax
f01015ac:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01015b2:	c1 f8 03             	sar    $0x3,%eax
f01015b5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015b8:	89 c2                	mov    %eax,%edx
f01015ba:	c1 ea 0c             	shr    $0xc,%edx
f01015bd:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f01015c3:	72 12                	jb     f01015d7 <mem_init+0x3ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015c5:	50                   	push   %eax
f01015c6:	68 44 40 10 f0       	push   $0xf0104044
f01015cb:	6a 52                	push   $0x52
f01015cd:	68 6b 3d 10 f0       	push   $0xf0103d6b
f01015d2:	e8 b4 ea ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01015d7:	83 ec 04             	sub    $0x4,%esp
f01015da:	68 00 10 00 00       	push   $0x1000
f01015df:	6a 01                	push   $0x1
f01015e1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015e6:	50                   	push   %eax
f01015e7:	e8 6f 1d 00 00       	call   f010335b <memset>
	page_free(pp0);
f01015ec:	89 34 24             	mov    %esi,(%esp)
f01015ef:	e8 f5 f8 ff ff       	call   f0100ee9 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015fb:	e8 78 f8 ff ff       	call   f0100e78 <page_alloc>
f0101600:	83 c4 10             	add    $0x10,%esp
f0101603:	85 c0                	test   %eax,%eax
f0101605:	75 19                	jne    f0101620 <mem_init+0x433>
f0101607:	68 ea 3e 10 f0       	push   $0xf0103eea
f010160c:	68 85 3d 10 f0       	push   $0xf0103d85
f0101611:	68 07 03 00 00       	push   $0x307
f0101616:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010161b:	e8 6b ea ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f0101620:	39 c6                	cmp    %eax,%esi
f0101622:	74 19                	je     f010163d <mem_init+0x450>
f0101624:	68 08 3f 10 f0       	push   $0xf0103f08
f0101629:	68 85 3d 10 f0       	push   $0xf0103d85
f010162e:	68 08 03 00 00       	push   $0x308
f0101633:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101638:	e8 4e ea ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010163d:	89 f0                	mov    %esi,%eax
f010163f:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0101645:	c1 f8 03             	sar    $0x3,%eax
f0101648:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010164b:	89 c2                	mov    %eax,%edx
f010164d:	c1 ea 0c             	shr    $0xc,%edx
f0101650:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0101656:	72 12                	jb     f010166a <mem_init+0x47d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101658:	50                   	push   %eax
f0101659:	68 44 40 10 f0       	push   $0xf0104044
f010165e:	6a 52                	push   $0x52
f0101660:	68 6b 3d 10 f0       	push   $0xf0103d6b
f0101665:	e8 21 ea ff ff       	call   f010008b <_panic>
f010166a:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101670:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
f0101676:	80 38 00             	cmpb   $0x0,(%eax)
f0101679:	74 19                	je     f0101694 <mem_init+0x4a7>
f010167b:	68 18 3f 10 f0       	push   $0xf0103f18
f0101680:	68 85 3d 10 f0       	push   $0xf0103d85
f0101685:	68 0c 03 00 00       	push   $0x30c
f010168a:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010168f:	e8 f7 e9 ff ff       	call   f010008b <_panic>
f0101694:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
f0101697:	39 d0                	cmp    %edx,%eax
f0101699:	75 db                	jne    f0101676 <mem_init+0x489>
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
	}

	// give free list back
	page_free_list = fl;
f010169b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010169e:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f01016a3:	83 ec 0c             	sub    $0xc,%esp
f01016a6:	56                   	push   %esi
f01016a7:	e8 3d f8 ff ff       	call   f0100ee9 <page_free>
	page_free(pp1);
f01016ac:	89 3c 24             	mov    %edi,(%esp)
f01016af:	e8 35 f8 ff ff       	call   f0100ee9 <page_free>
	page_free(pp2);
f01016b4:	83 c4 04             	add    $0x4,%esp
f01016b7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016ba:	e8 2a f8 ff ff       	call   f0100ee9 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016bf:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01016c4:	83 c4 10             	add    $0x10,%esp
f01016c7:	eb 05                	jmp    f01016ce <mem_init+0x4e1>
		--nfree;
f01016c9:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016cc:	8b 00                	mov    (%eax),%eax
f01016ce:	85 c0                	test   %eax,%eax
f01016d0:	75 f7                	jne    f01016c9 <mem_init+0x4dc>
		--nfree;
	assert(nfree == 0);
f01016d2:	85 db                	test   %ebx,%ebx
f01016d4:	74 19                	je     f01016ef <mem_init+0x502>
f01016d6:	68 22 3f 10 f0       	push   $0xf0103f22
f01016db:	68 85 3d 10 f0       	push   $0xf0103d85
f01016e0:	68 1a 03 00 00       	push   $0x31a
f01016e5:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01016ea:	e8 9c e9 ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01016ef:	83 ec 0c             	sub    $0xc,%esp
f01016f2:	68 ec 42 10 f0       	push   $0xf01042ec
f01016f7:	e8 9b 11 00 00       	call   f0102897 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101703:	e8 70 f7 ff ff       	call   f0100e78 <page_alloc>
f0101708:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010170b:	83 c4 10             	add    $0x10,%esp
f010170e:	85 c0                	test   %eax,%eax
f0101710:	75 19                	jne    f010172b <mem_init+0x53e>
f0101712:	68 30 3e 10 f0       	push   $0xf0103e30
f0101717:	68 85 3d 10 f0       	push   $0xf0103d85
f010171c:	68 77 03 00 00       	push   $0x377
f0101721:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101726:	e8 60 e9 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010172b:	83 ec 0c             	sub    $0xc,%esp
f010172e:	6a 00                	push   $0x0
f0101730:	e8 43 f7 ff ff       	call   f0100e78 <page_alloc>
f0101735:	89 c3                	mov    %eax,%ebx
f0101737:	83 c4 10             	add    $0x10,%esp
f010173a:	85 c0                	test   %eax,%eax
f010173c:	75 19                	jne    f0101757 <mem_init+0x56a>
f010173e:	68 46 3e 10 f0       	push   $0xf0103e46
f0101743:	68 85 3d 10 f0       	push   $0xf0103d85
f0101748:	68 78 03 00 00       	push   $0x378
f010174d:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101752:	e8 34 e9 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101757:	83 ec 0c             	sub    $0xc,%esp
f010175a:	6a 00                	push   $0x0
f010175c:	e8 17 f7 ff ff       	call   f0100e78 <page_alloc>
f0101761:	89 c6                	mov    %eax,%esi
f0101763:	83 c4 10             	add    $0x10,%esp
f0101766:	85 c0                	test   %eax,%eax
f0101768:	75 19                	jne    f0101783 <mem_init+0x596>
f010176a:	68 5c 3e 10 f0       	push   $0xf0103e5c
f010176f:	68 85 3d 10 f0       	push   $0xf0103d85
f0101774:	68 79 03 00 00       	push   $0x379
f0101779:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010177e:	e8 08 e9 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101783:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101786:	75 19                	jne    f01017a1 <mem_init+0x5b4>
f0101788:	68 72 3e 10 f0       	push   $0xf0103e72
f010178d:	68 85 3d 10 f0       	push   $0xf0103d85
f0101792:	68 7c 03 00 00       	push   $0x37c
f0101797:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010179c:	e8 ea e8 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017a1:	39 c3                	cmp    %eax,%ebx
f01017a3:	74 05                	je     f01017aa <mem_init+0x5bd>
f01017a5:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01017a8:	75 19                	jne    f01017c3 <mem_init+0x5d6>
f01017aa:	68 cc 42 10 f0       	push   $0xf01042cc
f01017af:	68 85 3d 10 f0       	push   $0xf0103d85
f01017b4:	68 7d 03 00 00       	push   $0x37d
f01017b9:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01017be:	e8 c8 e8 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017c3:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01017c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01017cb:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f01017d2:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01017d5:	83 ec 0c             	sub    $0xc,%esp
f01017d8:	6a 00                	push   $0x0
f01017da:	e8 99 f6 ff ff       	call   f0100e78 <page_alloc>
f01017df:	83 c4 10             	add    $0x10,%esp
f01017e2:	85 c0                	test   %eax,%eax
f01017e4:	74 19                	je     f01017ff <mem_init+0x612>
f01017e6:	68 db 3e 10 f0       	push   $0xf0103edb
f01017eb:	68 85 3d 10 f0       	push   $0xf0103d85
f01017f0:	68 84 03 00 00       	push   $0x384
f01017f5:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01017fa:	e8 8c e8 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01017ff:	83 ec 04             	sub    $0x4,%esp
f0101802:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101805:	50                   	push   %eax
f0101806:	6a 00                	push   $0x0
f0101808:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f010180e:	e8 ab f8 ff ff       	call   f01010be <page_lookup>
f0101813:	83 c4 10             	add    $0x10,%esp
f0101816:	85 c0                	test   %eax,%eax
f0101818:	74 19                	je     f0101833 <mem_init+0x646>
f010181a:	68 0c 43 10 f0       	push   $0xf010430c
f010181f:	68 85 3d 10 f0       	push   $0xf0103d85
f0101824:	68 87 03 00 00       	push   $0x387
f0101829:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010182e:	e8 58 e8 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101833:	6a 02                	push   $0x2
f0101835:	6a 00                	push   $0x0
f0101837:	53                   	push   %ebx
f0101838:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f010183e:	e8 23 f9 ff ff       	call   f0101166 <page_insert>
f0101843:	83 c4 10             	add    $0x10,%esp
f0101846:	85 c0                	test   %eax,%eax
f0101848:	78 19                	js     f0101863 <mem_init+0x676>
f010184a:	68 44 43 10 f0       	push   $0xf0104344
f010184f:	68 85 3d 10 f0       	push   $0xf0103d85
f0101854:	68 8a 03 00 00       	push   $0x38a
f0101859:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010185e:	e8 28 e8 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101863:	83 ec 0c             	sub    $0xc,%esp
f0101866:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101869:	e8 7b f6 ff ff       	call   f0100ee9 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010186e:	6a 02                	push   $0x2
f0101870:	6a 00                	push   $0x0
f0101872:	53                   	push   %ebx
f0101873:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101879:	e8 e8 f8 ff ff       	call   f0101166 <page_insert>
f010187e:	83 c4 20             	add    $0x20,%esp
f0101881:	85 c0                	test   %eax,%eax
f0101883:	74 19                	je     f010189e <mem_init+0x6b1>
f0101885:	68 74 43 10 f0       	push   $0xf0104374
f010188a:	68 85 3d 10 f0       	push   $0xf0103d85
f010188f:	68 8e 03 00 00       	push   $0x38e
f0101894:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101899:	e8 ed e7 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010189e:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018a4:	a1 70 79 11 f0       	mov    0xf0117970,%eax
f01018a9:	89 c1                	mov    %eax,%ecx
f01018ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01018ae:	8b 17                	mov    (%edi),%edx
f01018b0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018b9:	29 c8                	sub    %ecx,%eax
f01018bb:	c1 f8 03             	sar    $0x3,%eax
f01018be:	c1 e0 0c             	shl    $0xc,%eax
f01018c1:	39 c2                	cmp    %eax,%edx
f01018c3:	74 19                	je     f01018de <mem_init+0x6f1>
f01018c5:	68 a4 43 10 f0       	push   $0xf01043a4
f01018ca:	68 85 3d 10 f0       	push   $0xf0103d85
f01018cf:	68 8f 03 00 00       	push   $0x38f
f01018d4:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01018d9:	e8 ad e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01018de:	ba 00 00 00 00       	mov    $0x0,%edx
f01018e3:	89 f8                	mov    %edi,%eax
f01018e5:	e8 eb f0 ff ff       	call   f01009d5 <check_va2pa>
f01018ea:	89 da                	mov    %ebx,%edx
f01018ec:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01018ef:	c1 fa 03             	sar    $0x3,%edx
f01018f2:	c1 e2 0c             	shl    $0xc,%edx
f01018f5:	39 d0                	cmp    %edx,%eax
f01018f7:	74 19                	je     f0101912 <mem_init+0x725>
f01018f9:	68 cc 43 10 f0       	push   $0xf01043cc
f01018fe:	68 85 3d 10 f0       	push   $0xf0103d85
f0101903:	68 90 03 00 00       	push   $0x390
f0101908:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010190d:	e8 79 e7 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101912:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101917:	74 19                	je     f0101932 <mem_init+0x745>
f0101919:	68 2d 3f 10 f0       	push   $0xf0103f2d
f010191e:	68 85 3d 10 f0       	push   $0xf0103d85
f0101923:	68 91 03 00 00       	push   $0x391
f0101928:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010192d:	e8 59 e7 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0101932:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101935:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010193a:	74 19                	je     f0101955 <mem_init+0x768>
f010193c:	68 3e 3f 10 f0       	push   $0xf0103f3e
f0101941:	68 85 3d 10 f0       	push   $0xf0103d85
f0101946:	68 92 03 00 00       	push   $0x392
f010194b:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101950:	e8 36 e7 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101955:	6a 02                	push   $0x2
f0101957:	68 00 10 00 00       	push   $0x1000
f010195c:	56                   	push   %esi
f010195d:	57                   	push   %edi
f010195e:	e8 03 f8 ff ff       	call   f0101166 <page_insert>
f0101963:	83 c4 10             	add    $0x10,%esp
f0101966:	85 c0                	test   %eax,%eax
f0101968:	74 19                	je     f0101983 <mem_init+0x796>
f010196a:	68 fc 43 10 f0       	push   $0xf01043fc
f010196f:	68 85 3d 10 f0       	push   $0xf0103d85
f0101974:	68 95 03 00 00       	push   $0x395
f0101979:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010197e:	e8 08 e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101983:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101988:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f010198d:	e8 43 f0 ff ff       	call   f01009d5 <check_va2pa>
f0101992:	89 f2                	mov    %esi,%edx
f0101994:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f010199a:	c1 fa 03             	sar    $0x3,%edx
f010199d:	c1 e2 0c             	shl    $0xc,%edx
f01019a0:	39 d0                	cmp    %edx,%eax
f01019a2:	74 19                	je     f01019bd <mem_init+0x7d0>
f01019a4:	68 38 44 10 f0       	push   $0xf0104438
f01019a9:	68 85 3d 10 f0       	push   $0xf0103d85
f01019ae:	68 96 03 00 00       	push   $0x396
f01019b3:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01019b8:	e8 ce e6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01019bd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019c2:	74 19                	je     f01019dd <mem_init+0x7f0>
f01019c4:	68 4f 3f 10 f0       	push   $0xf0103f4f
f01019c9:	68 85 3d 10 f0       	push   $0xf0103d85
f01019ce:	68 97 03 00 00       	push   $0x397
f01019d3:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01019d8:	e8 ae e6 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01019dd:	83 ec 0c             	sub    $0xc,%esp
f01019e0:	6a 00                	push   $0x0
f01019e2:	e8 91 f4 ff ff       	call   f0100e78 <page_alloc>
f01019e7:	83 c4 10             	add    $0x10,%esp
f01019ea:	85 c0                	test   %eax,%eax
f01019ec:	74 19                	je     f0101a07 <mem_init+0x81a>
f01019ee:	68 db 3e 10 f0       	push   $0xf0103edb
f01019f3:	68 85 3d 10 f0       	push   $0xf0103d85
f01019f8:	68 9a 03 00 00       	push   $0x39a
f01019fd:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101a02:	e8 84 e6 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a07:	6a 02                	push   $0x2
f0101a09:	68 00 10 00 00       	push   $0x1000
f0101a0e:	56                   	push   %esi
f0101a0f:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101a15:	e8 4c f7 ff ff       	call   f0101166 <page_insert>
f0101a1a:	83 c4 10             	add    $0x10,%esp
f0101a1d:	85 c0                	test   %eax,%eax
f0101a1f:	74 19                	je     f0101a3a <mem_init+0x84d>
f0101a21:	68 fc 43 10 f0       	push   $0xf01043fc
f0101a26:	68 85 3d 10 f0       	push   $0xf0103d85
f0101a2b:	68 9d 03 00 00       	push   $0x39d
f0101a30:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101a35:	e8 51 e6 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a3a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a3f:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101a44:	e8 8c ef ff ff       	call   f01009d5 <check_va2pa>
f0101a49:	89 f2                	mov    %esi,%edx
f0101a4b:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101a51:	c1 fa 03             	sar    $0x3,%edx
f0101a54:	c1 e2 0c             	shl    $0xc,%edx
f0101a57:	39 d0                	cmp    %edx,%eax
f0101a59:	74 19                	je     f0101a74 <mem_init+0x887>
f0101a5b:	68 38 44 10 f0       	push   $0xf0104438
f0101a60:	68 85 3d 10 f0       	push   $0xf0103d85
f0101a65:	68 9e 03 00 00       	push   $0x39e
f0101a6a:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101a6f:	e8 17 e6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101a74:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a79:	74 19                	je     f0101a94 <mem_init+0x8a7>
f0101a7b:	68 4f 3f 10 f0       	push   $0xf0103f4f
f0101a80:	68 85 3d 10 f0       	push   $0xf0103d85
f0101a85:	68 9f 03 00 00       	push   $0x39f
f0101a8a:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101a8f:	e8 f7 e5 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a94:	83 ec 0c             	sub    $0xc,%esp
f0101a97:	6a 00                	push   $0x0
f0101a99:	e8 da f3 ff ff       	call   f0100e78 <page_alloc>
f0101a9e:	83 c4 10             	add    $0x10,%esp
f0101aa1:	85 c0                	test   %eax,%eax
f0101aa3:	74 19                	je     f0101abe <mem_init+0x8d1>
f0101aa5:	68 db 3e 10 f0       	push   $0xf0103edb
f0101aaa:	68 85 3d 10 f0       	push   $0xf0103d85
f0101aaf:	68 a3 03 00 00       	push   $0x3a3
f0101ab4:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101ab9:	e8 cd e5 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101abe:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
f0101ac4:	8b 02                	mov    (%edx),%eax
f0101ac6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101acb:	89 c1                	mov    %eax,%ecx
f0101acd:	c1 e9 0c             	shr    $0xc,%ecx
f0101ad0:	3b 0d 68 79 11 f0    	cmp    0xf0117968,%ecx
f0101ad6:	72 15                	jb     f0101aed <mem_init+0x900>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ad8:	50                   	push   %eax
f0101ad9:	68 44 40 10 f0       	push   $0xf0104044
f0101ade:	68 a6 03 00 00       	push   $0x3a6
f0101ae3:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101ae8:	e8 9e e5 ff ff       	call   f010008b <_panic>
f0101aed:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101af2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101af5:	83 ec 04             	sub    $0x4,%esp
f0101af8:	6a 00                	push   $0x0
f0101afa:	68 00 10 00 00       	push   $0x1000
f0101aff:	52                   	push   %edx
f0101b00:	e8 61 f4 ff ff       	call   f0100f66 <pgdir_walk>
f0101b05:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101b08:	8d 51 04             	lea    0x4(%ecx),%edx
f0101b0b:	83 c4 10             	add    $0x10,%esp
f0101b0e:	39 d0                	cmp    %edx,%eax
f0101b10:	74 19                	je     f0101b2b <mem_init+0x93e>
f0101b12:	68 68 44 10 f0       	push   $0xf0104468
f0101b17:	68 85 3d 10 f0       	push   $0xf0103d85
f0101b1c:	68 a7 03 00 00       	push   $0x3a7
f0101b21:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101b26:	e8 60 e5 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b2b:	6a 06                	push   $0x6
f0101b2d:	68 00 10 00 00       	push   $0x1000
f0101b32:	56                   	push   %esi
f0101b33:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101b39:	e8 28 f6 ff ff       	call   f0101166 <page_insert>
f0101b3e:	83 c4 10             	add    $0x10,%esp
f0101b41:	85 c0                	test   %eax,%eax
f0101b43:	74 19                	je     f0101b5e <mem_init+0x971>
f0101b45:	68 a8 44 10 f0       	push   $0xf01044a8
f0101b4a:	68 85 3d 10 f0       	push   $0xf0103d85
f0101b4f:	68 aa 03 00 00       	push   $0x3aa
f0101b54:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101b59:	e8 2d e5 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b5e:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101b64:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b69:	89 f8                	mov    %edi,%eax
f0101b6b:	e8 65 ee ff ff       	call   f01009d5 <check_va2pa>
f0101b70:	89 f2                	mov    %esi,%edx
f0101b72:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101b78:	c1 fa 03             	sar    $0x3,%edx
f0101b7b:	c1 e2 0c             	shl    $0xc,%edx
f0101b7e:	39 d0                	cmp    %edx,%eax
f0101b80:	74 19                	je     f0101b9b <mem_init+0x9ae>
f0101b82:	68 38 44 10 f0       	push   $0xf0104438
f0101b87:	68 85 3d 10 f0       	push   $0xf0103d85
f0101b8c:	68 ab 03 00 00       	push   $0x3ab
f0101b91:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101b96:	e8 f0 e4 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101b9b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ba0:	74 19                	je     f0101bbb <mem_init+0x9ce>
f0101ba2:	68 4f 3f 10 f0       	push   $0xf0103f4f
f0101ba7:	68 85 3d 10 f0       	push   $0xf0103d85
f0101bac:	68 ac 03 00 00       	push   $0x3ac
f0101bb1:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101bb6:	e8 d0 e4 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101bbb:	83 ec 04             	sub    $0x4,%esp
f0101bbe:	6a 00                	push   $0x0
f0101bc0:	68 00 10 00 00       	push   $0x1000
f0101bc5:	57                   	push   %edi
f0101bc6:	e8 9b f3 ff ff       	call   f0100f66 <pgdir_walk>
f0101bcb:	83 c4 10             	add    $0x10,%esp
f0101bce:	f6 00 04             	testb  $0x4,(%eax)
f0101bd1:	75 19                	jne    f0101bec <mem_init+0x9ff>
f0101bd3:	68 e8 44 10 f0       	push   $0xf01044e8
f0101bd8:	68 85 3d 10 f0       	push   $0xf0103d85
f0101bdd:	68 ad 03 00 00       	push   $0x3ad
f0101be2:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101be7:	e8 9f e4 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101bec:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101bf1:	f6 00 04             	testb  $0x4,(%eax)
f0101bf4:	75 19                	jne    f0101c0f <mem_init+0xa22>
f0101bf6:	68 60 3f 10 f0       	push   $0xf0103f60
f0101bfb:	68 85 3d 10 f0       	push   $0xf0103d85
f0101c00:	68 ae 03 00 00       	push   $0x3ae
f0101c05:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101c0a:	e8 7c e4 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c0f:	6a 02                	push   $0x2
f0101c11:	68 00 10 00 00       	push   $0x1000
f0101c16:	56                   	push   %esi
f0101c17:	50                   	push   %eax
f0101c18:	e8 49 f5 ff ff       	call   f0101166 <page_insert>
f0101c1d:	83 c4 10             	add    $0x10,%esp
f0101c20:	85 c0                	test   %eax,%eax
f0101c22:	74 19                	je     f0101c3d <mem_init+0xa50>
f0101c24:	68 fc 43 10 f0       	push   $0xf01043fc
f0101c29:	68 85 3d 10 f0       	push   $0xf0103d85
f0101c2e:	68 b1 03 00 00       	push   $0x3b1
f0101c33:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101c38:	e8 4e e4 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c3d:	83 ec 04             	sub    $0x4,%esp
f0101c40:	6a 00                	push   $0x0
f0101c42:	68 00 10 00 00       	push   $0x1000
f0101c47:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101c4d:	e8 14 f3 ff ff       	call   f0100f66 <pgdir_walk>
f0101c52:	83 c4 10             	add    $0x10,%esp
f0101c55:	f6 00 02             	testb  $0x2,(%eax)
f0101c58:	75 19                	jne    f0101c73 <mem_init+0xa86>
f0101c5a:	68 1c 45 10 f0       	push   $0xf010451c
f0101c5f:	68 85 3d 10 f0       	push   $0xf0103d85
f0101c64:	68 b2 03 00 00       	push   $0x3b2
f0101c69:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101c6e:	e8 18 e4 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c73:	83 ec 04             	sub    $0x4,%esp
f0101c76:	6a 00                	push   $0x0
f0101c78:	68 00 10 00 00       	push   $0x1000
f0101c7d:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101c83:	e8 de f2 ff ff       	call   f0100f66 <pgdir_walk>
f0101c88:	83 c4 10             	add    $0x10,%esp
f0101c8b:	f6 00 04             	testb  $0x4,(%eax)
f0101c8e:	74 19                	je     f0101ca9 <mem_init+0xabc>
f0101c90:	68 50 45 10 f0       	push   $0xf0104550
f0101c95:	68 85 3d 10 f0       	push   $0xf0103d85
f0101c9a:	68 b3 03 00 00       	push   $0x3b3
f0101c9f:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101ca4:	e8 e2 e3 ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ca9:	6a 02                	push   $0x2
f0101cab:	68 00 00 40 00       	push   $0x400000
f0101cb0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101cb3:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101cb9:	e8 a8 f4 ff ff       	call   f0101166 <page_insert>
f0101cbe:	83 c4 10             	add    $0x10,%esp
f0101cc1:	85 c0                	test   %eax,%eax
f0101cc3:	78 19                	js     f0101cde <mem_init+0xaf1>
f0101cc5:	68 88 45 10 f0       	push   $0xf0104588
f0101cca:	68 85 3d 10 f0       	push   $0xf0103d85
f0101ccf:	68 b6 03 00 00       	push   $0x3b6
f0101cd4:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101cd9:	e8 ad e3 ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101cde:	6a 02                	push   $0x2
f0101ce0:	68 00 10 00 00       	push   $0x1000
f0101ce5:	53                   	push   %ebx
f0101ce6:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101cec:	e8 75 f4 ff ff       	call   f0101166 <page_insert>
f0101cf1:	83 c4 10             	add    $0x10,%esp
f0101cf4:	85 c0                	test   %eax,%eax
f0101cf6:	74 19                	je     f0101d11 <mem_init+0xb24>
f0101cf8:	68 c0 45 10 f0       	push   $0xf01045c0
f0101cfd:	68 85 3d 10 f0       	push   $0xf0103d85
f0101d02:	68 b9 03 00 00       	push   $0x3b9
f0101d07:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101d0c:	e8 7a e3 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d11:	83 ec 04             	sub    $0x4,%esp
f0101d14:	6a 00                	push   $0x0
f0101d16:	68 00 10 00 00       	push   $0x1000
f0101d1b:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101d21:	e8 40 f2 ff ff       	call   f0100f66 <pgdir_walk>
f0101d26:	83 c4 10             	add    $0x10,%esp
f0101d29:	f6 00 04             	testb  $0x4,(%eax)
f0101d2c:	74 19                	je     f0101d47 <mem_init+0xb5a>
f0101d2e:	68 50 45 10 f0       	push   $0xf0104550
f0101d33:	68 85 3d 10 f0       	push   $0xf0103d85
f0101d38:	68 ba 03 00 00       	push   $0x3ba
f0101d3d:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101d42:	e8 44 e3 ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d47:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101d4d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d52:	89 f8                	mov    %edi,%eax
f0101d54:	e8 7c ec ff ff       	call   f01009d5 <check_va2pa>
f0101d59:	89 c1                	mov    %eax,%ecx
f0101d5b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d5e:	89 d8                	mov    %ebx,%eax
f0101d60:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0101d66:	c1 f8 03             	sar    $0x3,%eax
f0101d69:	c1 e0 0c             	shl    $0xc,%eax
f0101d6c:	39 c1                	cmp    %eax,%ecx
f0101d6e:	74 19                	je     f0101d89 <mem_init+0xb9c>
f0101d70:	68 fc 45 10 f0       	push   $0xf01045fc
f0101d75:	68 85 3d 10 f0       	push   $0xf0103d85
f0101d7a:	68 bd 03 00 00       	push   $0x3bd
f0101d7f:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101d84:	e8 02 e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d89:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d8e:	89 f8                	mov    %edi,%eax
f0101d90:	e8 40 ec ff ff       	call   f01009d5 <check_va2pa>
f0101d95:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101d98:	74 19                	je     f0101db3 <mem_init+0xbc6>
f0101d9a:	68 28 46 10 f0       	push   $0xf0104628
f0101d9f:	68 85 3d 10 f0       	push   $0xf0103d85
f0101da4:	68 be 03 00 00       	push   $0x3be
f0101da9:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101dae:	e8 d8 e2 ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101db3:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101db8:	74 19                	je     f0101dd3 <mem_init+0xbe6>
f0101dba:	68 76 3f 10 f0       	push   $0xf0103f76
f0101dbf:	68 85 3d 10 f0       	push   $0xf0103d85
f0101dc4:	68 c0 03 00 00       	push   $0x3c0
f0101dc9:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101dce:	e8 b8 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101dd3:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101dd8:	74 19                	je     f0101df3 <mem_init+0xc06>
f0101dda:	68 87 3f 10 f0       	push   $0xf0103f87
f0101ddf:	68 85 3d 10 f0       	push   $0xf0103d85
f0101de4:	68 c1 03 00 00       	push   $0x3c1
f0101de9:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101dee:	e8 98 e2 ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101df3:	83 ec 0c             	sub    $0xc,%esp
f0101df6:	6a 00                	push   $0x0
f0101df8:	e8 7b f0 ff ff       	call   f0100e78 <page_alloc>
f0101dfd:	83 c4 10             	add    $0x10,%esp
f0101e00:	85 c0                	test   %eax,%eax
f0101e02:	74 04                	je     f0101e08 <mem_init+0xc1b>
f0101e04:	39 c6                	cmp    %eax,%esi
f0101e06:	74 19                	je     f0101e21 <mem_init+0xc34>
f0101e08:	68 58 46 10 f0       	push   $0xf0104658
f0101e0d:	68 85 3d 10 f0       	push   $0xf0103d85
f0101e12:	68 c4 03 00 00       	push   $0x3c4
f0101e17:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101e1c:	e8 6a e2 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e21:	83 ec 08             	sub    $0x8,%esp
f0101e24:	6a 00                	push   $0x0
f0101e26:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101e2c:	e8 f3 f2 ff ff       	call   f0101124 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e31:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101e37:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e3c:	89 f8                	mov    %edi,%eax
f0101e3e:	e8 92 eb ff ff       	call   f01009d5 <check_va2pa>
f0101e43:	83 c4 10             	add    $0x10,%esp
f0101e46:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e49:	74 19                	je     f0101e64 <mem_init+0xc77>
f0101e4b:	68 7c 46 10 f0       	push   $0xf010467c
f0101e50:	68 85 3d 10 f0       	push   $0xf0103d85
f0101e55:	68 c8 03 00 00       	push   $0x3c8
f0101e5a:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101e5f:	e8 27 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e64:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e69:	89 f8                	mov    %edi,%eax
f0101e6b:	e8 65 eb ff ff       	call   f01009d5 <check_va2pa>
f0101e70:	89 da                	mov    %ebx,%edx
f0101e72:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101e78:	c1 fa 03             	sar    $0x3,%edx
f0101e7b:	c1 e2 0c             	shl    $0xc,%edx
f0101e7e:	39 d0                	cmp    %edx,%eax
f0101e80:	74 19                	je     f0101e9b <mem_init+0xcae>
f0101e82:	68 28 46 10 f0       	push   $0xf0104628
f0101e87:	68 85 3d 10 f0       	push   $0xf0103d85
f0101e8c:	68 c9 03 00 00       	push   $0x3c9
f0101e91:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101e96:	e8 f0 e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101e9b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ea0:	74 19                	je     f0101ebb <mem_init+0xcce>
f0101ea2:	68 2d 3f 10 f0       	push   $0xf0103f2d
f0101ea7:	68 85 3d 10 f0       	push   $0xf0103d85
f0101eac:	68 ca 03 00 00       	push   $0x3ca
f0101eb1:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101eb6:	e8 d0 e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101ebb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ec0:	74 19                	je     f0101edb <mem_init+0xcee>
f0101ec2:	68 87 3f 10 f0       	push   $0xf0103f87
f0101ec7:	68 85 3d 10 f0       	push   $0xf0103d85
f0101ecc:	68 cb 03 00 00       	push   $0x3cb
f0101ed1:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101ed6:	e8 b0 e1 ff ff       	call   f010008b <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101edb:	6a 00                	push   $0x0
f0101edd:	68 00 10 00 00       	push   $0x1000
f0101ee2:	53                   	push   %ebx
f0101ee3:	57                   	push   %edi
f0101ee4:	e8 7d f2 ff ff       	call   f0101166 <page_insert>
f0101ee9:	83 c4 10             	add    $0x10,%esp
f0101eec:	85 c0                	test   %eax,%eax
f0101eee:	74 19                	je     f0101f09 <mem_init+0xd1c>
f0101ef0:	68 a0 46 10 f0       	push   $0xf01046a0
f0101ef5:	68 85 3d 10 f0       	push   $0xf0103d85
f0101efa:	68 ce 03 00 00       	push   $0x3ce
f0101eff:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101f04:	e8 82 e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f0101f09:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f0e:	75 19                	jne    f0101f29 <mem_init+0xd3c>
f0101f10:	68 98 3f 10 f0       	push   $0xf0103f98
f0101f15:	68 85 3d 10 f0       	push   $0xf0103d85
f0101f1a:	68 cf 03 00 00       	push   $0x3cf
f0101f1f:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101f24:	e8 62 e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f0101f29:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101f2c:	74 19                	je     f0101f47 <mem_init+0xd5a>
f0101f2e:	68 a4 3f 10 f0       	push   $0xf0103fa4
f0101f33:	68 85 3d 10 f0       	push   $0xf0103d85
f0101f38:	68 d0 03 00 00       	push   $0x3d0
f0101f3d:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101f42:	e8 44 e1 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f47:	83 ec 08             	sub    $0x8,%esp
f0101f4a:	68 00 10 00 00       	push   $0x1000
f0101f4f:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101f55:	e8 ca f1 ff ff       	call   f0101124 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f5a:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101f60:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f65:	89 f8                	mov    %edi,%eax
f0101f67:	e8 69 ea ff ff       	call   f01009d5 <check_va2pa>
f0101f6c:	83 c4 10             	add    $0x10,%esp
f0101f6f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f72:	74 19                	je     f0101f8d <mem_init+0xda0>
f0101f74:	68 7c 46 10 f0       	push   $0xf010467c
f0101f79:	68 85 3d 10 f0       	push   $0xf0103d85
f0101f7e:	68 d4 03 00 00       	push   $0x3d4
f0101f83:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101f88:	e8 fe e0 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f8d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f92:	89 f8                	mov    %edi,%eax
f0101f94:	e8 3c ea ff ff       	call   f01009d5 <check_va2pa>
f0101f99:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f9c:	74 19                	je     f0101fb7 <mem_init+0xdca>
f0101f9e:	68 d8 46 10 f0       	push   $0xf01046d8
f0101fa3:	68 85 3d 10 f0       	push   $0xf0103d85
f0101fa8:	68 d5 03 00 00       	push   $0x3d5
f0101fad:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101fb2:	e8 d4 e0 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0101fb7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101fbc:	74 19                	je     f0101fd7 <mem_init+0xdea>
f0101fbe:	68 b9 3f 10 f0       	push   $0xf0103fb9
f0101fc3:	68 85 3d 10 f0       	push   $0xf0103d85
f0101fc8:	68 d6 03 00 00       	push   $0x3d6
f0101fcd:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101fd2:	e8 b4 e0 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101fd7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fdc:	74 19                	je     f0101ff7 <mem_init+0xe0a>
f0101fde:	68 87 3f 10 f0       	push   $0xf0103f87
f0101fe3:	68 85 3d 10 f0       	push   $0xf0103d85
f0101fe8:	68 d7 03 00 00       	push   $0x3d7
f0101fed:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0101ff2:	e8 94 e0 ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101ff7:	83 ec 0c             	sub    $0xc,%esp
f0101ffa:	6a 00                	push   $0x0
f0101ffc:	e8 77 ee ff ff       	call   f0100e78 <page_alloc>
f0102001:	83 c4 10             	add    $0x10,%esp
f0102004:	39 c3                	cmp    %eax,%ebx
f0102006:	75 04                	jne    f010200c <mem_init+0xe1f>
f0102008:	85 c0                	test   %eax,%eax
f010200a:	75 19                	jne    f0102025 <mem_init+0xe38>
f010200c:	68 00 47 10 f0       	push   $0xf0104700
f0102011:	68 85 3d 10 f0       	push   $0xf0103d85
f0102016:	68 da 03 00 00       	push   $0x3da
f010201b:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0102020:	e8 66 e0 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102025:	83 ec 0c             	sub    $0xc,%esp
f0102028:	6a 00                	push   $0x0
f010202a:	e8 49 ee ff ff       	call   f0100e78 <page_alloc>
f010202f:	83 c4 10             	add    $0x10,%esp
f0102032:	85 c0                	test   %eax,%eax
f0102034:	74 19                	je     f010204f <mem_init+0xe62>
f0102036:	68 db 3e 10 f0       	push   $0xf0103edb
f010203b:	68 85 3d 10 f0       	push   $0xf0103d85
f0102040:	68 dd 03 00 00       	push   $0x3dd
f0102045:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010204a:	e8 3c e0 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010204f:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
f0102055:	8b 11                	mov    (%ecx),%edx
f0102057:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010205d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102060:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0102066:	c1 f8 03             	sar    $0x3,%eax
f0102069:	c1 e0 0c             	shl    $0xc,%eax
f010206c:	39 c2                	cmp    %eax,%edx
f010206e:	74 19                	je     f0102089 <mem_init+0xe9c>
f0102070:	68 a4 43 10 f0       	push   $0xf01043a4
f0102075:	68 85 3d 10 f0       	push   $0xf0103d85
f010207a:	68 e0 03 00 00       	push   $0x3e0
f010207f:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0102084:	e8 02 e0 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102089:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010208f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102092:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102097:	74 19                	je     f01020b2 <mem_init+0xec5>
f0102099:	68 3e 3f 10 f0       	push   $0xf0103f3e
f010209e:	68 85 3d 10 f0       	push   $0xf0103d85
f01020a3:	68 e2 03 00 00       	push   $0x3e2
f01020a8:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01020ad:	e8 d9 df ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f01020b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020b5:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01020bb:	83 ec 0c             	sub    $0xc,%esp
f01020be:	50                   	push   %eax
f01020bf:	e8 25 ee ff ff       	call   f0100ee9 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01020c4:	83 c4 0c             	add    $0xc,%esp
f01020c7:	6a 01                	push   $0x1
f01020c9:	68 00 10 40 00       	push   $0x401000
f01020ce:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01020d4:	e8 8d ee ff ff       	call   f0100f66 <pgdir_walk>
f01020d9:	89 c7                	mov    %eax,%edi
f01020db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01020de:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f01020e3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01020e6:	8b 40 04             	mov    0x4(%eax),%eax
f01020e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020ee:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f01020f4:	89 c2                	mov    %eax,%edx
f01020f6:	c1 ea 0c             	shr    $0xc,%edx
f01020f9:	83 c4 10             	add    $0x10,%esp
f01020fc:	39 ca                	cmp    %ecx,%edx
f01020fe:	72 15                	jb     f0102115 <mem_init+0xf28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102100:	50                   	push   %eax
f0102101:	68 44 40 10 f0       	push   $0xf0104044
f0102106:	68 e9 03 00 00       	push   $0x3e9
f010210b:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0102110:	e8 76 df ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102115:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010211a:	39 c7                	cmp    %eax,%edi
f010211c:	74 19                	je     f0102137 <mem_init+0xf4a>
f010211e:	68 ca 3f 10 f0       	push   $0xf0103fca
f0102123:	68 85 3d 10 f0       	push   $0xf0103d85
f0102128:	68 ea 03 00 00       	push   $0x3ea
f010212d:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0102132:	e8 54 df ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102137:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010213a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102141:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102144:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010214a:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0102150:	c1 f8 03             	sar    $0x3,%eax
f0102153:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102156:	89 c2                	mov    %eax,%edx
f0102158:	c1 ea 0c             	shr    $0xc,%edx
f010215b:	39 d1                	cmp    %edx,%ecx
f010215d:	77 12                	ja     f0102171 <mem_init+0xf84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010215f:	50                   	push   %eax
f0102160:	68 44 40 10 f0       	push   $0xf0104044
f0102165:	6a 52                	push   $0x52
f0102167:	68 6b 3d 10 f0       	push   $0xf0103d6b
f010216c:	e8 1a df ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102171:	83 ec 04             	sub    $0x4,%esp
f0102174:	68 00 10 00 00       	push   $0x1000
f0102179:	68 ff 00 00 00       	push   $0xff
f010217e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102183:	50                   	push   %eax
f0102184:	e8 d2 11 00 00       	call   f010335b <memset>
	page_free(pp0);
f0102189:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010218c:	89 3c 24             	mov    %edi,(%esp)
f010218f:	e8 55 ed ff ff       	call   f0100ee9 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102194:	83 c4 0c             	add    $0xc,%esp
f0102197:	6a 01                	push   $0x1
f0102199:	6a 00                	push   $0x0
f010219b:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01021a1:	e8 c0 ed ff ff       	call   f0100f66 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01021a6:	89 fa                	mov    %edi,%edx
f01021a8:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f01021ae:	c1 fa 03             	sar    $0x3,%edx
f01021b1:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021b4:	89 d0                	mov    %edx,%eax
f01021b6:	c1 e8 0c             	shr    $0xc,%eax
f01021b9:	83 c4 10             	add    $0x10,%esp
f01021bc:	3b 05 68 79 11 f0    	cmp    0xf0117968,%eax
f01021c2:	72 12                	jb     f01021d6 <mem_init+0xfe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021c4:	52                   	push   %edx
f01021c5:	68 44 40 10 f0       	push   $0xf0104044
f01021ca:	6a 52                	push   $0x52
f01021cc:	68 6b 3d 10 f0       	push   $0xf0103d6b
f01021d1:	e8 b5 de ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f01021d6:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01021dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01021df:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01021e5:	f6 00 01             	testb  $0x1,(%eax)
f01021e8:	74 19                	je     f0102203 <mem_init+0x1016>
f01021ea:	68 e2 3f 10 f0       	push   $0xf0103fe2
f01021ef:	68 85 3d 10 f0       	push   $0xf0103d85
f01021f4:	68 f4 03 00 00       	push   $0x3f4
f01021f9:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01021fe:	e8 88 de ff ff       	call   f010008b <_panic>
f0102203:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102206:	39 d0                	cmp    %edx,%eax
f0102208:	75 db                	jne    f01021e5 <mem_init+0xff8>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010220a:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f010220f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102215:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102218:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010221e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102221:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c

	// free the pages we took
	page_free(pp0);
f0102227:	83 ec 0c             	sub    $0xc,%esp
f010222a:	50                   	push   %eax
f010222b:	e8 b9 ec ff ff       	call   f0100ee9 <page_free>
	page_free(pp1);
f0102230:	89 1c 24             	mov    %ebx,(%esp)
f0102233:	e8 b1 ec ff ff       	call   f0100ee9 <page_free>
	page_free(pp2);
f0102238:	89 34 24             	mov    %esi,(%esp)
f010223b:	e8 a9 ec ff ff       	call   f0100ee9 <page_free>

	cprintf("check_page() succeeded!\n");
f0102240:	c7 04 24 f9 3f 10 f0 	movl   $0xf0103ff9,(%esp)
f0102247:	e8 4b 06 00 00       	call   f0102897 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010224c:	a1 70 79 11 f0       	mov    0xf0117970,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102251:	83 c4 10             	add    $0x10,%esp
f0102254:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102259:	77 15                	ja     f0102270 <mem_init+0x1083>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010225b:	50                   	push   %eax
f010225c:	68 50 41 10 f0       	push   $0xf0104150
f0102261:	68 bd 00 00 00       	push   $0xbd
f0102266:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010226b:	e8 1b de ff ff       	call   f010008b <_panic>
f0102270:	83 ec 08             	sub    $0x8,%esp
f0102273:	6a 04                	push   $0x4
f0102275:	05 00 00 00 10       	add    $0x10000000,%eax
f010227a:	50                   	push   %eax
f010227b:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102280:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102285:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f010228a:	e8 6d ed ff ff       	call   f0100ffc <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010228f:	83 c4 10             	add    $0x10,%esp
f0102292:	b8 00 d0 10 f0       	mov    $0xf010d000,%eax
f0102297:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010229c:	77 15                	ja     f01022b3 <mem_init+0x10c6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010229e:	50                   	push   %eax
f010229f:	68 50 41 10 f0       	push   $0xf0104150
f01022a4:	68 cb 00 00 00       	push   $0xcb
f01022a9:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01022ae:	e8 d8 dd ff ff       	call   f010008b <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01022b3:	83 ec 08             	sub    $0x8,%esp
f01022b6:	6a 02                	push   $0x2
f01022b8:	68 00 d0 10 00       	push   $0x10d000
f01022bd:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01022c2:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01022c7:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f01022cc:	e8 2b ed ff ff       	call   f0100ffc <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KERNBASE, ROUNDUP(~0 - KERNBASE, PGSIZE), 0, PTE_W);
f01022d1:	83 c4 08             	add    $0x8,%esp
f01022d4:	6a 02                	push   $0x2
f01022d6:	6a 00                	push   $0x0
f01022d8:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01022dd:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01022e2:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f01022e7:	e8 10 ed ff ff       	call   f0100ffc <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01022ec:	8b 35 6c 79 11 f0    	mov    0xf011796c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01022f2:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01022f7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01022fa:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102301:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102306:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102309:	8b 3d 70 79 11 f0    	mov    0xf0117970,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010230f:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102312:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102315:	bb 00 00 00 00       	mov    $0x0,%ebx
f010231a:	eb 55                	jmp    f0102371 <mem_init+0x1184>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010231c:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102322:	89 f0                	mov    %esi,%eax
f0102324:	e8 ac e6 ff ff       	call   f01009d5 <check_va2pa>
f0102329:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102330:	77 15                	ja     f0102347 <mem_init+0x115a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102332:	57                   	push   %edi
f0102333:	68 50 41 10 f0       	push   $0xf0104150
f0102338:	68 32 03 00 00       	push   $0x332
f010233d:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0102342:	e8 44 dd ff ff       	call   f010008b <_panic>
f0102347:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f010234e:	39 c2                	cmp    %eax,%edx
f0102350:	74 19                	je     f010236b <mem_init+0x117e>
f0102352:	68 24 47 10 f0       	push   $0xf0104724
f0102357:	68 85 3d 10 f0       	push   $0xf0103d85
f010235c:	68 32 03 00 00       	push   $0x332
f0102361:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0102366:	e8 20 dd ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010236b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102371:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102374:	77 a6                	ja     f010231c <mem_init+0x112f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102376:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102379:	c1 e7 0c             	shl    $0xc,%edi
f010237c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102381:	eb 30                	jmp    f01023b3 <mem_init+0x11c6>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102383:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102389:	89 f0                	mov    %esi,%eax
f010238b:	e8 45 e6 ff ff       	call   f01009d5 <check_va2pa>
f0102390:	39 c3                	cmp    %eax,%ebx
f0102392:	74 19                	je     f01023ad <mem_init+0x11c0>
f0102394:	68 58 47 10 f0       	push   $0xf0104758
f0102399:	68 85 3d 10 f0       	push   $0xf0103d85
f010239e:	68 37 03 00 00       	push   $0x337
f01023a3:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01023a8:	e8 de dc ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01023ad:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01023b3:	39 fb                	cmp    %edi,%ebx
f01023b5:	72 cc                	jb     f0102383 <mem_init+0x1196>
f01023b7:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01023bc:	89 da                	mov    %ebx,%edx
f01023be:	89 f0                	mov    %esi,%eax
f01023c0:	e8 10 e6 ff ff       	call   f01009d5 <check_va2pa>
f01023c5:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f01023cb:	39 c2                	cmp    %eax,%edx
f01023cd:	74 19                	je     f01023e8 <mem_init+0x11fb>
f01023cf:	68 80 47 10 f0       	push   $0xf0104780
f01023d4:	68 85 3d 10 f0       	push   $0xf0103d85
f01023d9:	68 3b 03 00 00       	push   $0x33b
f01023de:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01023e3:	e8 a3 dc ff ff       	call   f010008b <_panic>
f01023e8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01023ee:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f01023f4:	75 c6                	jne    f01023bc <mem_init+0x11cf>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01023f6:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01023fb:	89 f0                	mov    %esi,%eax
f01023fd:	e8 d3 e5 ff ff       	call   f01009d5 <check_va2pa>
f0102402:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102405:	74 51                	je     f0102458 <mem_init+0x126b>
f0102407:	68 c8 47 10 f0       	push   $0xf01047c8
f010240c:	68 85 3d 10 f0       	push   $0xf0103d85
f0102411:	68 3c 03 00 00       	push   $0x33c
f0102416:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010241b:	e8 6b dc ff ff       	call   f010008b <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102420:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102425:	72 36                	jb     f010245d <mem_init+0x1270>
f0102427:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010242c:	76 07                	jbe    f0102435 <mem_init+0x1248>
f010242e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102433:	75 28                	jne    f010245d <mem_init+0x1270>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102435:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102439:	0f 85 83 00 00 00    	jne    f01024c2 <mem_init+0x12d5>
f010243f:	68 12 40 10 f0       	push   $0xf0104012
f0102444:	68 85 3d 10 f0       	push   $0xf0103d85
f0102449:	68 44 03 00 00       	push   $0x344
f010244e:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0102453:	e8 33 dc ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102458:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010245d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102462:	76 3f                	jbe    f01024a3 <mem_init+0x12b6>
				assert(pgdir[i] & PTE_P);
f0102464:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102467:	f6 c2 01             	test   $0x1,%dl
f010246a:	75 19                	jne    f0102485 <mem_init+0x1298>
f010246c:	68 12 40 10 f0       	push   $0xf0104012
f0102471:	68 85 3d 10 f0       	push   $0xf0103d85
f0102476:	68 48 03 00 00       	push   $0x348
f010247b:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0102480:	e8 06 dc ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f0102485:	f6 c2 02             	test   $0x2,%dl
f0102488:	75 38                	jne    f01024c2 <mem_init+0x12d5>
f010248a:	68 23 40 10 f0       	push   $0xf0104023
f010248f:	68 85 3d 10 f0       	push   $0xf0103d85
f0102494:	68 49 03 00 00       	push   $0x349
f0102499:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010249e:	e8 e8 db ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f01024a3:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f01024a7:	74 19                	je     f01024c2 <mem_init+0x12d5>
f01024a9:	68 34 40 10 f0       	push   $0xf0104034
f01024ae:	68 85 3d 10 f0       	push   $0xf0103d85
f01024b3:	68 4b 03 00 00       	push   $0x34b
f01024b8:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01024bd:	e8 c9 db ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01024c2:	83 c0 01             	add    $0x1,%eax
f01024c5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01024ca:	0f 86 50 ff ff ff    	jbe    f0102420 <mem_init+0x1233>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01024d0:	83 ec 0c             	sub    $0xc,%esp
f01024d3:	68 f8 47 10 f0       	push   $0xf01047f8
f01024d8:	e8 ba 03 00 00       	call   f0102897 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01024dd:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01024e2:	83 c4 10             	add    $0x10,%esp
f01024e5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024ea:	77 15                	ja     f0102501 <mem_init+0x1314>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024ec:	50                   	push   %eax
f01024ed:	68 50 41 10 f0       	push   $0xf0104150
f01024f2:	68 e2 00 00 00       	push   $0xe2
f01024f7:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01024fc:	e8 8a db ff ff       	call   f010008b <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102501:	05 00 00 00 10       	add    $0x10000000,%eax
f0102506:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102509:	b8 00 00 00 00       	mov    $0x0,%eax
f010250e:	e8 26 e5 ff ff       	call   f0100a39 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102513:	0f 20 c0             	mov    %cr0,%eax
f0102516:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102519:	0d 23 00 05 80       	or     $0x80050023,%eax
f010251e:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102521:	83 ec 0c             	sub    $0xc,%esp
f0102524:	6a 00                	push   $0x0
f0102526:	e8 4d e9 ff ff       	call   f0100e78 <page_alloc>
f010252b:	89 c3                	mov    %eax,%ebx
f010252d:	83 c4 10             	add    $0x10,%esp
f0102530:	85 c0                	test   %eax,%eax
f0102532:	75 19                	jne    f010254d <mem_init+0x1360>
f0102534:	68 30 3e 10 f0       	push   $0xf0103e30
f0102539:	68 85 3d 10 f0       	push   $0xf0103d85
f010253e:	68 0f 04 00 00       	push   $0x40f
f0102543:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0102548:	e8 3e db ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010254d:	83 ec 0c             	sub    $0xc,%esp
f0102550:	6a 00                	push   $0x0
f0102552:	e8 21 e9 ff ff       	call   f0100e78 <page_alloc>
f0102557:	89 c7                	mov    %eax,%edi
f0102559:	83 c4 10             	add    $0x10,%esp
f010255c:	85 c0                	test   %eax,%eax
f010255e:	75 19                	jne    f0102579 <mem_init+0x138c>
f0102560:	68 46 3e 10 f0       	push   $0xf0103e46
f0102565:	68 85 3d 10 f0       	push   $0xf0103d85
f010256a:	68 10 04 00 00       	push   $0x410
f010256f:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0102574:	e8 12 db ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0102579:	83 ec 0c             	sub    $0xc,%esp
f010257c:	6a 00                	push   $0x0
f010257e:	e8 f5 e8 ff ff       	call   f0100e78 <page_alloc>
f0102583:	89 c6                	mov    %eax,%esi
f0102585:	83 c4 10             	add    $0x10,%esp
f0102588:	85 c0                	test   %eax,%eax
f010258a:	75 19                	jne    f01025a5 <mem_init+0x13b8>
f010258c:	68 5c 3e 10 f0       	push   $0xf0103e5c
f0102591:	68 85 3d 10 f0       	push   $0xf0103d85
f0102596:	68 11 04 00 00       	push   $0x411
f010259b:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01025a0:	e8 e6 da ff ff       	call   f010008b <_panic>
	page_free(pp0);
f01025a5:	83 ec 0c             	sub    $0xc,%esp
f01025a8:	53                   	push   %ebx
f01025a9:	e8 3b e9 ff ff       	call   f0100ee9 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025ae:	89 f8                	mov    %edi,%eax
f01025b0:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01025b6:	c1 f8 03             	sar    $0x3,%eax
f01025b9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025bc:	89 c2                	mov    %eax,%edx
f01025be:	c1 ea 0c             	shr    $0xc,%edx
f01025c1:	83 c4 10             	add    $0x10,%esp
f01025c4:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f01025ca:	72 12                	jb     f01025de <mem_init+0x13f1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025cc:	50                   	push   %eax
f01025cd:	68 44 40 10 f0       	push   $0xf0104044
f01025d2:	6a 52                	push   $0x52
f01025d4:	68 6b 3d 10 f0       	push   $0xf0103d6b
f01025d9:	e8 ad da ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01025de:	83 ec 04             	sub    $0x4,%esp
f01025e1:	68 00 10 00 00       	push   $0x1000
f01025e6:	6a 01                	push   $0x1
f01025e8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025ed:	50                   	push   %eax
f01025ee:	e8 68 0d 00 00       	call   f010335b <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025f3:	89 f0                	mov    %esi,%eax
f01025f5:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01025fb:	c1 f8 03             	sar    $0x3,%eax
f01025fe:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102601:	89 c2                	mov    %eax,%edx
f0102603:	c1 ea 0c             	shr    $0xc,%edx
f0102606:	83 c4 10             	add    $0x10,%esp
f0102609:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f010260f:	72 12                	jb     f0102623 <mem_init+0x1436>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102611:	50                   	push   %eax
f0102612:	68 44 40 10 f0       	push   $0xf0104044
f0102617:	6a 52                	push   $0x52
f0102619:	68 6b 3d 10 f0       	push   $0xf0103d6b
f010261e:	e8 68 da ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102623:	83 ec 04             	sub    $0x4,%esp
f0102626:	68 00 10 00 00       	push   $0x1000
f010262b:	6a 02                	push   $0x2
f010262d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102632:	50                   	push   %eax
f0102633:	e8 23 0d 00 00       	call   f010335b <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102638:	6a 02                	push   $0x2
f010263a:	68 00 10 00 00       	push   $0x1000
f010263f:	57                   	push   %edi
f0102640:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0102646:	e8 1b eb ff ff       	call   f0101166 <page_insert>
	assert(pp1->pp_ref == 1);
f010264b:	83 c4 20             	add    $0x20,%esp
f010264e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102653:	74 19                	je     f010266e <mem_init+0x1481>
f0102655:	68 2d 3f 10 f0       	push   $0xf0103f2d
f010265a:	68 85 3d 10 f0       	push   $0xf0103d85
f010265f:	68 16 04 00 00       	push   $0x416
f0102664:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0102669:	e8 1d da ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010266e:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102675:	01 01 01 
f0102678:	74 19                	je     f0102693 <mem_init+0x14a6>
f010267a:	68 18 48 10 f0       	push   $0xf0104818
f010267f:	68 85 3d 10 f0       	push   $0xf0103d85
f0102684:	68 17 04 00 00       	push   $0x417
f0102689:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010268e:	e8 f8 d9 ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102693:	6a 02                	push   $0x2
f0102695:	68 00 10 00 00       	push   $0x1000
f010269a:	56                   	push   %esi
f010269b:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01026a1:	e8 c0 ea ff ff       	call   f0101166 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01026a6:	83 c4 10             	add    $0x10,%esp
f01026a9:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01026b0:	02 02 02 
f01026b3:	74 19                	je     f01026ce <mem_init+0x14e1>
f01026b5:	68 3c 48 10 f0       	push   $0xf010483c
f01026ba:	68 85 3d 10 f0       	push   $0xf0103d85
f01026bf:	68 19 04 00 00       	push   $0x419
f01026c4:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01026c9:	e8 bd d9 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01026ce:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01026d3:	74 19                	je     f01026ee <mem_init+0x1501>
f01026d5:	68 4f 3f 10 f0       	push   $0xf0103f4f
f01026da:	68 85 3d 10 f0       	push   $0xf0103d85
f01026df:	68 1a 04 00 00       	push   $0x41a
f01026e4:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01026e9:	e8 9d d9 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f01026ee:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01026f3:	74 19                	je     f010270e <mem_init+0x1521>
f01026f5:	68 b9 3f 10 f0       	push   $0xf0103fb9
f01026fa:	68 85 3d 10 f0       	push   $0xf0103d85
f01026ff:	68 1b 04 00 00       	push   $0x41b
f0102704:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0102709:	e8 7d d9 ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010270e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102715:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102718:	89 f0                	mov    %esi,%eax
f010271a:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0102720:	c1 f8 03             	sar    $0x3,%eax
f0102723:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102726:	89 c2                	mov    %eax,%edx
f0102728:	c1 ea 0c             	shr    $0xc,%edx
f010272b:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0102731:	72 12                	jb     f0102745 <mem_init+0x1558>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102733:	50                   	push   %eax
f0102734:	68 44 40 10 f0       	push   $0xf0104044
f0102739:	6a 52                	push   $0x52
f010273b:	68 6b 3d 10 f0       	push   $0xf0103d6b
f0102740:	e8 46 d9 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102745:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010274c:	03 03 03 
f010274f:	74 19                	je     f010276a <mem_init+0x157d>
f0102751:	68 60 48 10 f0       	push   $0xf0104860
f0102756:	68 85 3d 10 f0       	push   $0xf0103d85
f010275b:	68 1d 04 00 00       	push   $0x41d
f0102760:	68 5f 3d 10 f0       	push   $0xf0103d5f
f0102765:	e8 21 d9 ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010276a:	83 ec 08             	sub    $0x8,%esp
f010276d:	68 00 10 00 00       	push   $0x1000
f0102772:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0102778:	e8 a7 e9 ff ff       	call   f0101124 <page_remove>
	assert(pp2->pp_ref == 0);
f010277d:	83 c4 10             	add    $0x10,%esp
f0102780:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102785:	74 19                	je     f01027a0 <mem_init+0x15b3>
f0102787:	68 87 3f 10 f0       	push   $0xf0103f87
f010278c:	68 85 3d 10 f0       	push   $0xf0103d85
f0102791:	68 1f 04 00 00       	push   $0x41f
f0102796:	68 5f 3d 10 f0       	push   $0xf0103d5f
f010279b:	e8 eb d8 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027a0:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
f01027a6:	8b 11                	mov    (%ecx),%edx
f01027a8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01027ae:	89 d8                	mov    %ebx,%eax
f01027b0:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01027b6:	c1 f8 03             	sar    $0x3,%eax
f01027b9:	c1 e0 0c             	shl    $0xc,%eax
f01027bc:	39 c2                	cmp    %eax,%edx
f01027be:	74 19                	je     f01027d9 <mem_init+0x15ec>
f01027c0:	68 a4 43 10 f0       	push   $0xf01043a4
f01027c5:	68 85 3d 10 f0       	push   $0xf0103d85
f01027ca:	68 22 04 00 00       	push   $0x422
f01027cf:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01027d4:	e8 b2 d8 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f01027d9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01027df:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01027e4:	74 19                	je     f01027ff <mem_init+0x1612>
f01027e6:	68 3e 3f 10 f0       	push   $0xf0103f3e
f01027eb:	68 85 3d 10 f0       	push   $0xf0103d85
f01027f0:	68 24 04 00 00       	push   $0x424
f01027f5:	68 5f 3d 10 f0       	push   $0xf0103d5f
f01027fa:	e8 8c d8 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f01027ff:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102805:	83 ec 0c             	sub    $0xc,%esp
f0102808:	53                   	push   %ebx
f0102809:	e8 db e6 ff ff       	call   f0100ee9 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010280e:	c7 04 24 8c 48 10 f0 	movl   $0xf010488c,(%esp)
f0102815:	e8 7d 00 00 00       	call   f0102897 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010281a:	83 c4 10             	add    $0x10,%esp
f010281d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102820:	5b                   	pop    %ebx
f0102821:	5e                   	pop    %esi
f0102822:	5f                   	pop    %edi
f0102823:	5d                   	pop    %ebp
f0102824:	c3                   	ret    

f0102825 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102825:	55                   	push   %ebp
f0102826:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102828:	8b 45 0c             	mov    0xc(%ebp),%eax
f010282b:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010282e:	5d                   	pop    %ebp
f010282f:	c3                   	ret    

f0102830 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102830:	55                   	push   %ebp
f0102831:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102833:	ba 70 00 00 00       	mov    $0x70,%edx
f0102838:	8b 45 08             	mov    0x8(%ebp),%eax
f010283b:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010283c:	ba 71 00 00 00       	mov    $0x71,%edx
f0102841:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102842:	0f b6 c0             	movzbl %al,%eax
}
f0102845:	5d                   	pop    %ebp
f0102846:	c3                   	ret    

f0102847 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102847:	55                   	push   %ebp
f0102848:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010284a:	ba 70 00 00 00       	mov    $0x70,%edx
f010284f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102852:	ee                   	out    %al,(%dx)
f0102853:	ba 71 00 00 00       	mov    $0x71,%edx
f0102858:	8b 45 0c             	mov    0xc(%ebp),%eax
f010285b:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010285c:	5d                   	pop    %ebp
f010285d:	c3                   	ret    

f010285e <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010285e:	55                   	push   %ebp
f010285f:	89 e5                	mov    %esp,%ebp
f0102861:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102864:	ff 75 08             	pushl  0x8(%ebp)
f0102867:	e8 94 dd ff ff       	call   f0100600 <cputchar>
	*cnt++;
}
f010286c:	83 c4 10             	add    $0x10,%esp
f010286f:	c9                   	leave  
f0102870:	c3                   	ret    

f0102871 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102871:	55                   	push   %ebp
f0102872:	89 e5                	mov    %esp,%ebp
f0102874:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102877:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010287e:	ff 75 0c             	pushl  0xc(%ebp)
f0102881:	ff 75 08             	pushl  0x8(%ebp)
f0102884:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102887:	50                   	push   %eax
f0102888:	68 5e 28 10 f0       	push   $0xf010285e
f010288d:	e8 5d 04 00 00       	call   f0102cef <vprintfmt>
	return cnt;
}
f0102892:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102895:	c9                   	leave  
f0102896:	c3                   	ret    

f0102897 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102897:	55                   	push   %ebp
f0102898:	89 e5                	mov    %esp,%ebp
f010289a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010289d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01028a0:	50                   	push   %eax
f01028a1:	ff 75 08             	pushl  0x8(%ebp)
f01028a4:	e8 c8 ff ff ff       	call   f0102871 <vcprintf>
	va_end(ap);

	return cnt;
}
f01028a9:	c9                   	leave  
f01028aa:	c3                   	ret    

f01028ab <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01028ab:	55                   	push   %ebp
f01028ac:	89 e5                	mov    %esp,%ebp
f01028ae:	57                   	push   %edi
f01028af:	56                   	push   %esi
f01028b0:	53                   	push   %ebx
f01028b1:	83 ec 14             	sub    $0x14,%esp
f01028b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01028b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01028ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01028bd:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01028c0:	8b 1a                	mov    (%edx),%ebx
f01028c2:	8b 01                	mov    (%ecx),%eax
f01028c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01028c7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01028ce:	eb 7f                	jmp    f010294f <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01028d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01028d3:	01 d8                	add    %ebx,%eax
f01028d5:	89 c6                	mov    %eax,%esi
f01028d7:	c1 ee 1f             	shr    $0x1f,%esi
f01028da:	01 c6                	add    %eax,%esi
f01028dc:	d1 fe                	sar    %esi
f01028de:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01028e1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01028e4:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01028e7:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01028e9:	eb 03                	jmp    f01028ee <stab_binsearch+0x43>
			m--;
f01028eb:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01028ee:	39 c3                	cmp    %eax,%ebx
f01028f0:	7f 0d                	jg     f01028ff <stab_binsearch+0x54>
f01028f2:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01028f6:	83 ea 0c             	sub    $0xc,%edx
f01028f9:	39 f9                	cmp    %edi,%ecx
f01028fb:	75 ee                	jne    f01028eb <stab_binsearch+0x40>
f01028fd:	eb 05                	jmp    f0102904 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01028ff:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0102902:	eb 4b                	jmp    f010294f <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102904:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102907:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010290a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010290e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102911:	76 11                	jbe    f0102924 <stab_binsearch+0x79>
			*region_left = m;
f0102913:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102916:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0102918:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010291b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102922:	eb 2b                	jmp    f010294f <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102924:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102927:	73 14                	jae    f010293d <stab_binsearch+0x92>
			*region_right = m - 1;
f0102929:	83 e8 01             	sub    $0x1,%eax
f010292c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010292f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102932:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102934:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010293b:	eb 12                	jmp    f010294f <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010293d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102940:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102942:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0102946:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102948:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010294f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102952:	0f 8e 78 ff ff ff    	jle    f01028d0 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102958:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010295c:	75 0f                	jne    f010296d <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010295e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102961:	8b 00                	mov    (%eax),%eax
f0102963:	83 e8 01             	sub    $0x1,%eax
f0102966:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102969:	89 06                	mov    %eax,(%esi)
f010296b:	eb 2c                	jmp    f0102999 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010296d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102970:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102972:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102975:	8b 0e                	mov    (%esi),%ecx
f0102977:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010297a:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010297d:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102980:	eb 03                	jmp    f0102985 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102982:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102985:	39 c8                	cmp    %ecx,%eax
f0102987:	7e 0b                	jle    f0102994 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0102989:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010298d:	83 ea 0c             	sub    $0xc,%edx
f0102990:	39 df                	cmp    %ebx,%edi
f0102992:	75 ee                	jne    f0102982 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102994:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102997:	89 06                	mov    %eax,(%esi)
	}
}
f0102999:	83 c4 14             	add    $0x14,%esp
f010299c:	5b                   	pop    %ebx
f010299d:	5e                   	pop    %esi
f010299e:	5f                   	pop    %edi
f010299f:	5d                   	pop    %ebp
f01029a0:	c3                   	ret    

f01029a1 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01029a1:	55                   	push   %ebp
f01029a2:	89 e5                	mov    %esp,%ebp
f01029a4:	57                   	push   %edi
f01029a5:	56                   	push   %esi
f01029a6:	53                   	push   %ebx
f01029a7:	83 ec 3c             	sub    $0x3c,%esp
f01029aa:	8b 75 08             	mov    0x8(%ebp),%esi
f01029ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01029b0:	c7 03 b8 48 10 f0    	movl   $0xf01048b8,(%ebx)
	info->eip_line = 0;
f01029b6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01029bd:	c7 43 08 b8 48 10 f0 	movl   $0xf01048b8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01029c4:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01029cb:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01029ce:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01029d5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01029db:	76 11                	jbe    f01029ee <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01029dd:	b8 ba c4 10 f0       	mov    $0xf010c4ba,%eax
f01029e2:	3d 79 a6 10 f0       	cmp    $0xf010a679,%eax
f01029e7:	77 19                	ja     f0102a02 <debuginfo_eip+0x61>
f01029e9:	e9 b5 01 00 00       	jmp    f0102ba3 <debuginfo_eip+0x202>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f01029ee:	83 ec 04             	sub    $0x4,%esp
f01029f1:	68 c2 48 10 f0       	push   $0xf01048c2
f01029f6:	6a 7f                	push   $0x7f
f01029f8:	68 cf 48 10 f0       	push   $0xf01048cf
f01029fd:	e8 89 d6 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102a02:	80 3d b9 c4 10 f0 00 	cmpb   $0x0,0xf010c4b9
f0102a09:	0f 85 9b 01 00 00    	jne    f0102baa <debuginfo_eip+0x209>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102a0f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102a16:	b8 78 a6 10 f0       	mov    $0xf010a678,%eax
f0102a1b:	2d ec 4a 10 f0       	sub    $0xf0104aec,%eax
f0102a20:	c1 f8 02             	sar    $0x2,%eax
f0102a23:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102a29:	83 e8 01             	sub    $0x1,%eax
f0102a2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102a2f:	83 ec 08             	sub    $0x8,%esp
f0102a32:	56                   	push   %esi
f0102a33:	6a 64                	push   $0x64
f0102a35:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102a38:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102a3b:	b8 ec 4a 10 f0       	mov    $0xf0104aec,%eax
f0102a40:	e8 66 fe ff ff       	call   f01028ab <stab_binsearch>
	if (lfile == 0)
f0102a45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102a48:	83 c4 10             	add    $0x10,%esp
f0102a4b:	85 c0                	test   %eax,%eax
f0102a4d:	0f 84 5e 01 00 00    	je     f0102bb1 <debuginfo_eip+0x210>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102a53:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102a56:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102a59:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102a5c:	83 ec 08             	sub    $0x8,%esp
f0102a5f:	56                   	push   %esi
f0102a60:	6a 24                	push   $0x24
f0102a62:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102a65:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102a68:	b8 ec 4a 10 f0       	mov    $0xf0104aec,%eax
f0102a6d:	e8 39 fe ff ff       	call   f01028ab <stab_binsearch>

	if (lfun <= rfun) {
f0102a72:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102a75:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102a78:	83 c4 10             	add    $0x10,%esp
f0102a7b:	39 d0                	cmp    %edx,%eax
f0102a7d:	7f 40                	jg     f0102abf <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102a7f:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102a82:	c1 e1 02             	shl    $0x2,%ecx
f0102a85:	8d b9 ec 4a 10 f0    	lea    -0xfefb514(%ecx),%edi
f0102a8b:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102a8e:	8b b9 ec 4a 10 f0    	mov    -0xfefb514(%ecx),%edi
f0102a94:	b9 ba c4 10 f0       	mov    $0xf010c4ba,%ecx
f0102a99:	81 e9 79 a6 10 f0    	sub    $0xf010a679,%ecx
f0102a9f:	39 cf                	cmp    %ecx,%edi
f0102aa1:	73 09                	jae    f0102aac <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102aa3:	81 c7 79 a6 10 f0    	add    $0xf010a679,%edi
f0102aa9:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102aac:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102aaf:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102ab2:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102ab5:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102ab7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102aba:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102abd:	eb 0f                	jmp    f0102ace <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102abf:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102ac2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102ac5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102ac8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102acb:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102ace:	83 ec 08             	sub    $0x8,%esp
f0102ad1:	6a 3a                	push   $0x3a
f0102ad3:	ff 73 08             	pushl  0x8(%ebx)
f0102ad6:	e8 64 08 00 00       	call   f010333f <strfind>
f0102adb:	2b 43 08             	sub    0x8(%ebx),%eax
f0102ade:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102ae1:	83 c4 08             	add    $0x8,%esp
f0102ae4:	56                   	push   %esi
f0102ae5:	6a 44                	push   $0x44
f0102ae7:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102aea:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102aed:	b8 ec 4a 10 f0       	mov    $0xf0104aec,%eax
f0102af2:	e8 b4 fd ff ff       	call   f01028ab <stab_binsearch>
	if (lline == 0)
f0102af7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102afa:	83 c4 10             	add    $0x10,%esp
f0102afd:	85 c0                	test   %eax,%eax
f0102aff:	0f 84 b3 00 00 00    	je     f0102bb8 <debuginfo_eip+0x217>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0102b05:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102b08:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102b0b:	0f b7 14 95 f2 4a 10 	movzwl -0xfefb50e(,%edx,4),%edx
f0102b12:	f0 
f0102b13:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102b16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102b19:	89 c2                	mov    %eax,%edx
f0102b1b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102b1e:	8d 04 85 ec 4a 10 f0 	lea    -0xfefb514(,%eax,4),%eax
f0102b25:	eb 06                	jmp    f0102b2d <debuginfo_eip+0x18c>
f0102b27:	83 ea 01             	sub    $0x1,%edx
f0102b2a:	83 e8 0c             	sub    $0xc,%eax
f0102b2d:	39 d7                	cmp    %edx,%edi
f0102b2f:	7f 34                	jg     f0102b65 <debuginfo_eip+0x1c4>
	       && stabs[lline].n_type != N_SOL
f0102b31:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0102b35:	80 f9 84             	cmp    $0x84,%cl
f0102b38:	74 0b                	je     f0102b45 <debuginfo_eip+0x1a4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102b3a:	80 f9 64             	cmp    $0x64,%cl
f0102b3d:	75 e8                	jne    f0102b27 <debuginfo_eip+0x186>
f0102b3f:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102b43:	74 e2                	je     f0102b27 <debuginfo_eip+0x186>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102b45:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102b48:	8b 14 85 ec 4a 10 f0 	mov    -0xfefb514(,%eax,4),%edx
f0102b4f:	b8 ba c4 10 f0       	mov    $0xf010c4ba,%eax
f0102b54:	2d 79 a6 10 f0       	sub    $0xf010a679,%eax
f0102b59:	39 c2                	cmp    %eax,%edx
f0102b5b:	73 08                	jae    f0102b65 <debuginfo_eip+0x1c4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102b5d:	81 c2 79 a6 10 f0    	add    $0xf010a679,%edx
f0102b63:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102b65:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102b68:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102b6b:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102b70:	39 f2                	cmp    %esi,%edx
f0102b72:	7d 50                	jge    f0102bc4 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
f0102b74:	83 c2 01             	add    $0x1,%edx
f0102b77:	89 d0                	mov    %edx,%eax
f0102b79:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102b7c:	8d 14 95 ec 4a 10 f0 	lea    -0xfefb514(,%edx,4),%edx
f0102b83:	eb 04                	jmp    f0102b89 <debuginfo_eip+0x1e8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102b85:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102b89:	39 c6                	cmp    %eax,%esi
f0102b8b:	7e 32                	jle    f0102bbf <debuginfo_eip+0x21e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102b8d:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102b91:	83 c0 01             	add    $0x1,%eax
f0102b94:	83 c2 0c             	add    $0xc,%edx
f0102b97:	80 f9 a0             	cmp    $0xa0,%cl
f0102b9a:	74 e9                	je     f0102b85 <debuginfo_eip+0x1e4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102b9c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ba1:	eb 21                	jmp    f0102bc4 <debuginfo_eip+0x223>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102ba3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102ba8:	eb 1a                	jmp    f0102bc4 <debuginfo_eip+0x223>
f0102baa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102baf:	eb 13                	jmp    f0102bc4 <debuginfo_eip+0x223>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102bb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102bb6:	eb 0c                	jmp    f0102bc4 <debuginfo_eip+0x223>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0102bb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102bbd:	eb 05                	jmp    f0102bc4 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102bbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102bc7:	5b                   	pop    %ebx
f0102bc8:	5e                   	pop    %esi
f0102bc9:	5f                   	pop    %edi
f0102bca:	5d                   	pop    %ebp
f0102bcb:	c3                   	ret    

f0102bcc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102bcc:	55                   	push   %ebp
f0102bcd:	89 e5                	mov    %esp,%ebp
f0102bcf:	57                   	push   %edi
f0102bd0:	56                   	push   %esi
f0102bd1:	53                   	push   %ebx
f0102bd2:	83 ec 1c             	sub    $0x1c,%esp
f0102bd5:	89 c7                	mov    %eax,%edi
f0102bd7:	89 d6                	mov    %edx,%esi
f0102bd9:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102bdf:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102be2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102be5:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102be8:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102bed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102bf0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102bf3:	39 d3                	cmp    %edx,%ebx
f0102bf5:	72 05                	jb     f0102bfc <printnum+0x30>
f0102bf7:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102bfa:	77 45                	ja     f0102c41 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102bfc:	83 ec 0c             	sub    $0xc,%esp
f0102bff:	ff 75 18             	pushl  0x18(%ebp)
f0102c02:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c05:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102c08:	53                   	push   %ebx
f0102c09:	ff 75 10             	pushl  0x10(%ebp)
f0102c0c:	83 ec 08             	sub    $0x8,%esp
f0102c0f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102c12:	ff 75 e0             	pushl  -0x20(%ebp)
f0102c15:	ff 75 dc             	pushl  -0x24(%ebp)
f0102c18:	ff 75 d8             	pushl  -0x28(%ebp)
f0102c1b:	e8 40 09 00 00       	call   f0103560 <__udivdi3>
f0102c20:	83 c4 18             	add    $0x18,%esp
f0102c23:	52                   	push   %edx
f0102c24:	50                   	push   %eax
f0102c25:	89 f2                	mov    %esi,%edx
f0102c27:	89 f8                	mov    %edi,%eax
f0102c29:	e8 9e ff ff ff       	call   f0102bcc <printnum>
f0102c2e:	83 c4 20             	add    $0x20,%esp
f0102c31:	eb 18                	jmp    f0102c4b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102c33:	83 ec 08             	sub    $0x8,%esp
f0102c36:	56                   	push   %esi
f0102c37:	ff 75 18             	pushl  0x18(%ebp)
f0102c3a:	ff d7                	call   *%edi
f0102c3c:	83 c4 10             	add    $0x10,%esp
f0102c3f:	eb 03                	jmp    f0102c44 <printnum+0x78>
f0102c41:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102c44:	83 eb 01             	sub    $0x1,%ebx
f0102c47:	85 db                	test   %ebx,%ebx
f0102c49:	7f e8                	jg     f0102c33 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102c4b:	83 ec 08             	sub    $0x8,%esp
f0102c4e:	56                   	push   %esi
f0102c4f:	83 ec 04             	sub    $0x4,%esp
f0102c52:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102c55:	ff 75 e0             	pushl  -0x20(%ebp)
f0102c58:	ff 75 dc             	pushl  -0x24(%ebp)
f0102c5b:	ff 75 d8             	pushl  -0x28(%ebp)
f0102c5e:	e8 2d 0a 00 00       	call   f0103690 <__umoddi3>
f0102c63:	83 c4 14             	add    $0x14,%esp
f0102c66:	0f be 80 dd 48 10 f0 	movsbl -0xfefb723(%eax),%eax
f0102c6d:	50                   	push   %eax
f0102c6e:	ff d7                	call   *%edi
}
f0102c70:	83 c4 10             	add    $0x10,%esp
f0102c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c76:	5b                   	pop    %ebx
f0102c77:	5e                   	pop    %esi
f0102c78:	5f                   	pop    %edi
f0102c79:	5d                   	pop    %ebp
f0102c7a:	c3                   	ret    

f0102c7b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102c7b:	55                   	push   %ebp
f0102c7c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102c7e:	83 fa 01             	cmp    $0x1,%edx
f0102c81:	7e 0e                	jle    f0102c91 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102c83:	8b 10                	mov    (%eax),%edx
f0102c85:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102c88:	89 08                	mov    %ecx,(%eax)
f0102c8a:	8b 02                	mov    (%edx),%eax
f0102c8c:	8b 52 04             	mov    0x4(%edx),%edx
f0102c8f:	eb 22                	jmp    f0102cb3 <getuint+0x38>
	else if (lflag)
f0102c91:	85 d2                	test   %edx,%edx
f0102c93:	74 10                	je     f0102ca5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102c95:	8b 10                	mov    (%eax),%edx
f0102c97:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102c9a:	89 08                	mov    %ecx,(%eax)
f0102c9c:	8b 02                	mov    (%edx),%eax
f0102c9e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ca3:	eb 0e                	jmp    f0102cb3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102ca5:	8b 10                	mov    (%eax),%edx
f0102ca7:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102caa:	89 08                	mov    %ecx,(%eax)
f0102cac:	8b 02                	mov    (%edx),%eax
f0102cae:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102cb3:	5d                   	pop    %ebp
f0102cb4:	c3                   	ret    

f0102cb5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102cb5:	55                   	push   %ebp
f0102cb6:	89 e5                	mov    %esp,%ebp
f0102cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102cbb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102cbf:	8b 10                	mov    (%eax),%edx
f0102cc1:	3b 50 04             	cmp    0x4(%eax),%edx
f0102cc4:	73 0a                	jae    f0102cd0 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102cc6:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102cc9:	89 08                	mov    %ecx,(%eax)
f0102ccb:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cce:	88 02                	mov    %al,(%edx)
}
f0102cd0:	5d                   	pop    %ebp
f0102cd1:	c3                   	ret    

f0102cd2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102cd2:	55                   	push   %ebp
f0102cd3:	89 e5                	mov    %esp,%ebp
f0102cd5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102cd8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102cdb:	50                   	push   %eax
f0102cdc:	ff 75 10             	pushl  0x10(%ebp)
f0102cdf:	ff 75 0c             	pushl  0xc(%ebp)
f0102ce2:	ff 75 08             	pushl  0x8(%ebp)
f0102ce5:	e8 05 00 00 00       	call   f0102cef <vprintfmt>
	va_end(ap);
}
f0102cea:	83 c4 10             	add    $0x10,%esp
f0102ced:	c9                   	leave  
f0102cee:	c3                   	ret    

f0102cef <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102cef:	55                   	push   %ebp
f0102cf0:	89 e5                	mov    %esp,%ebp
f0102cf2:	57                   	push   %edi
f0102cf3:	56                   	push   %esi
f0102cf4:	53                   	push   %ebx
f0102cf5:	83 ec 2c             	sub    $0x2c,%esp
f0102cf8:	8b 75 08             	mov    0x8(%ebp),%esi
f0102cfb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102cfe:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102d01:	eb 12                	jmp    f0102d15 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102d03:	85 c0                	test   %eax,%eax
f0102d05:	0f 84 89 03 00 00    	je     f0103094 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0102d0b:	83 ec 08             	sub    $0x8,%esp
f0102d0e:	53                   	push   %ebx
f0102d0f:	50                   	push   %eax
f0102d10:	ff d6                	call   *%esi
f0102d12:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102d15:	83 c7 01             	add    $0x1,%edi
f0102d18:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102d1c:	83 f8 25             	cmp    $0x25,%eax
f0102d1f:	75 e2                	jne    f0102d03 <vprintfmt+0x14>
f0102d21:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102d25:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102d2c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102d33:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102d3a:	ba 00 00 00 00       	mov    $0x0,%edx
f0102d3f:	eb 07                	jmp    f0102d48 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d41:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102d44:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d48:	8d 47 01             	lea    0x1(%edi),%eax
f0102d4b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102d4e:	0f b6 07             	movzbl (%edi),%eax
f0102d51:	0f b6 c8             	movzbl %al,%ecx
f0102d54:	83 e8 23             	sub    $0x23,%eax
f0102d57:	3c 55                	cmp    $0x55,%al
f0102d59:	0f 87 1a 03 00 00    	ja     f0103079 <vprintfmt+0x38a>
f0102d5f:	0f b6 c0             	movzbl %al,%eax
f0102d62:	ff 24 85 68 49 10 f0 	jmp    *-0xfefb698(,%eax,4)
f0102d69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102d6c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102d70:	eb d6                	jmp    f0102d48 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d72:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102d75:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d7a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102d7d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102d80:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0102d84:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0102d87:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0102d8a:	83 fa 09             	cmp    $0x9,%edx
f0102d8d:	77 39                	ja     f0102dc8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102d8f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102d92:	eb e9                	jmp    f0102d7d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102d94:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d97:	8d 48 04             	lea    0x4(%eax),%ecx
f0102d9a:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102d9d:	8b 00                	mov    (%eax),%eax
f0102d9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102da2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102da5:	eb 27                	jmp    f0102dce <vprintfmt+0xdf>
f0102da7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102daa:	85 c0                	test   %eax,%eax
f0102dac:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102db1:	0f 49 c8             	cmovns %eax,%ecx
f0102db4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102db7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102dba:	eb 8c                	jmp    f0102d48 <vprintfmt+0x59>
f0102dbc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102dbf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102dc6:	eb 80                	jmp    f0102d48 <vprintfmt+0x59>
f0102dc8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102dcb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102dce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102dd2:	0f 89 70 ff ff ff    	jns    f0102d48 <vprintfmt+0x59>
				width = precision, precision = -1;
f0102dd8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102ddb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102dde:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102de5:	e9 5e ff ff ff       	jmp    f0102d48 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102dea:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ded:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102df0:	e9 53 ff ff ff       	jmp    f0102d48 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102df5:	8b 45 14             	mov    0x14(%ebp),%eax
f0102df8:	8d 50 04             	lea    0x4(%eax),%edx
f0102dfb:	89 55 14             	mov    %edx,0x14(%ebp)
f0102dfe:	83 ec 08             	sub    $0x8,%esp
f0102e01:	53                   	push   %ebx
f0102e02:	ff 30                	pushl  (%eax)
f0102e04:	ff d6                	call   *%esi
			break;
f0102e06:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102e0c:	e9 04 ff ff ff       	jmp    f0102d15 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102e11:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e14:	8d 50 04             	lea    0x4(%eax),%edx
f0102e17:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e1a:	8b 00                	mov    (%eax),%eax
f0102e1c:	99                   	cltd   
f0102e1d:	31 d0                	xor    %edx,%eax
f0102e1f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102e21:	83 f8 06             	cmp    $0x6,%eax
f0102e24:	7f 0b                	jg     f0102e31 <vprintfmt+0x142>
f0102e26:	8b 14 85 c0 4a 10 f0 	mov    -0xfefb540(,%eax,4),%edx
f0102e2d:	85 d2                	test   %edx,%edx
f0102e2f:	75 18                	jne    f0102e49 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0102e31:	50                   	push   %eax
f0102e32:	68 f5 48 10 f0       	push   $0xf01048f5
f0102e37:	53                   	push   %ebx
f0102e38:	56                   	push   %esi
f0102e39:	e8 94 fe ff ff       	call   f0102cd2 <printfmt>
f0102e3e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e41:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102e44:	e9 cc fe ff ff       	jmp    f0102d15 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102e49:	52                   	push   %edx
f0102e4a:	68 97 3d 10 f0       	push   $0xf0103d97
f0102e4f:	53                   	push   %ebx
f0102e50:	56                   	push   %esi
f0102e51:	e8 7c fe ff ff       	call   f0102cd2 <printfmt>
f0102e56:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e59:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e5c:	e9 b4 fe ff ff       	jmp    f0102d15 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102e61:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e64:	8d 50 04             	lea    0x4(%eax),%edx
f0102e67:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e6a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102e6c:	85 ff                	test   %edi,%edi
f0102e6e:	b8 ee 48 10 f0       	mov    $0xf01048ee,%eax
f0102e73:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102e76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102e7a:	0f 8e 94 00 00 00    	jle    f0102f14 <vprintfmt+0x225>
f0102e80:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102e84:	0f 84 98 00 00 00    	je     f0102f22 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102e8a:	83 ec 08             	sub    $0x8,%esp
f0102e8d:	ff 75 d0             	pushl  -0x30(%ebp)
f0102e90:	57                   	push   %edi
f0102e91:	e8 5f 03 00 00       	call   f01031f5 <strnlen>
f0102e96:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102e99:	29 c1                	sub    %eax,%ecx
f0102e9b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102e9e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102ea1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102ea5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102ea8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102eab:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102ead:	eb 0f                	jmp    f0102ebe <vprintfmt+0x1cf>
					putch(padc, putdat);
f0102eaf:	83 ec 08             	sub    $0x8,%esp
f0102eb2:	53                   	push   %ebx
f0102eb3:	ff 75 e0             	pushl  -0x20(%ebp)
f0102eb6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102eb8:	83 ef 01             	sub    $0x1,%edi
f0102ebb:	83 c4 10             	add    $0x10,%esp
f0102ebe:	85 ff                	test   %edi,%edi
f0102ec0:	7f ed                	jg     f0102eaf <vprintfmt+0x1c0>
f0102ec2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102ec5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102ec8:	85 c9                	test   %ecx,%ecx
f0102eca:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ecf:	0f 49 c1             	cmovns %ecx,%eax
f0102ed2:	29 c1                	sub    %eax,%ecx
f0102ed4:	89 75 08             	mov    %esi,0x8(%ebp)
f0102ed7:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102eda:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102edd:	89 cb                	mov    %ecx,%ebx
f0102edf:	eb 4d                	jmp    f0102f2e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102ee1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102ee5:	74 1b                	je     f0102f02 <vprintfmt+0x213>
f0102ee7:	0f be c0             	movsbl %al,%eax
f0102eea:	83 e8 20             	sub    $0x20,%eax
f0102eed:	83 f8 5e             	cmp    $0x5e,%eax
f0102ef0:	76 10                	jbe    f0102f02 <vprintfmt+0x213>
					putch('?', putdat);
f0102ef2:	83 ec 08             	sub    $0x8,%esp
f0102ef5:	ff 75 0c             	pushl  0xc(%ebp)
f0102ef8:	6a 3f                	push   $0x3f
f0102efa:	ff 55 08             	call   *0x8(%ebp)
f0102efd:	83 c4 10             	add    $0x10,%esp
f0102f00:	eb 0d                	jmp    f0102f0f <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0102f02:	83 ec 08             	sub    $0x8,%esp
f0102f05:	ff 75 0c             	pushl  0xc(%ebp)
f0102f08:	52                   	push   %edx
f0102f09:	ff 55 08             	call   *0x8(%ebp)
f0102f0c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102f0f:	83 eb 01             	sub    $0x1,%ebx
f0102f12:	eb 1a                	jmp    f0102f2e <vprintfmt+0x23f>
f0102f14:	89 75 08             	mov    %esi,0x8(%ebp)
f0102f17:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102f1a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102f1d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102f20:	eb 0c                	jmp    f0102f2e <vprintfmt+0x23f>
f0102f22:	89 75 08             	mov    %esi,0x8(%ebp)
f0102f25:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102f28:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102f2b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102f2e:	83 c7 01             	add    $0x1,%edi
f0102f31:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102f35:	0f be d0             	movsbl %al,%edx
f0102f38:	85 d2                	test   %edx,%edx
f0102f3a:	74 23                	je     f0102f5f <vprintfmt+0x270>
f0102f3c:	85 f6                	test   %esi,%esi
f0102f3e:	78 a1                	js     f0102ee1 <vprintfmt+0x1f2>
f0102f40:	83 ee 01             	sub    $0x1,%esi
f0102f43:	79 9c                	jns    f0102ee1 <vprintfmt+0x1f2>
f0102f45:	89 df                	mov    %ebx,%edi
f0102f47:	8b 75 08             	mov    0x8(%ebp),%esi
f0102f4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102f4d:	eb 18                	jmp    f0102f67 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102f4f:	83 ec 08             	sub    $0x8,%esp
f0102f52:	53                   	push   %ebx
f0102f53:	6a 20                	push   $0x20
f0102f55:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102f57:	83 ef 01             	sub    $0x1,%edi
f0102f5a:	83 c4 10             	add    $0x10,%esp
f0102f5d:	eb 08                	jmp    f0102f67 <vprintfmt+0x278>
f0102f5f:	89 df                	mov    %ebx,%edi
f0102f61:	8b 75 08             	mov    0x8(%ebp),%esi
f0102f64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102f67:	85 ff                	test   %edi,%edi
f0102f69:	7f e4                	jg     f0102f4f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102f6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102f6e:	e9 a2 fd ff ff       	jmp    f0102d15 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102f73:	83 fa 01             	cmp    $0x1,%edx
f0102f76:	7e 16                	jle    f0102f8e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0102f78:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f7b:	8d 50 08             	lea    0x8(%eax),%edx
f0102f7e:	89 55 14             	mov    %edx,0x14(%ebp)
f0102f81:	8b 50 04             	mov    0x4(%eax),%edx
f0102f84:	8b 00                	mov    (%eax),%eax
f0102f86:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f89:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102f8c:	eb 32                	jmp    f0102fc0 <vprintfmt+0x2d1>
	else if (lflag)
f0102f8e:	85 d2                	test   %edx,%edx
f0102f90:	74 18                	je     f0102faa <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0102f92:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f95:	8d 50 04             	lea    0x4(%eax),%edx
f0102f98:	89 55 14             	mov    %edx,0x14(%ebp)
f0102f9b:	8b 00                	mov    (%eax),%eax
f0102f9d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102fa0:	89 c1                	mov    %eax,%ecx
f0102fa2:	c1 f9 1f             	sar    $0x1f,%ecx
f0102fa5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102fa8:	eb 16                	jmp    f0102fc0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0102faa:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fad:	8d 50 04             	lea    0x4(%eax),%edx
f0102fb0:	89 55 14             	mov    %edx,0x14(%ebp)
f0102fb3:	8b 00                	mov    (%eax),%eax
f0102fb5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102fb8:	89 c1                	mov    %eax,%ecx
f0102fba:	c1 f9 1f             	sar    $0x1f,%ecx
f0102fbd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102fc0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102fc3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102fc6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102fcb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102fcf:	79 74                	jns    f0103045 <vprintfmt+0x356>
				putch('-', putdat);
f0102fd1:	83 ec 08             	sub    $0x8,%esp
f0102fd4:	53                   	push   %ebx
f0102fd5:	6a 2d                	push   $0x2d
f0102fd7:	ff d6                	call   *%esi
				num = -(long long) num;
f0102fd9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102fdc:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102fdf:	f7 d8                	neg    %eax
f0102fe1:	83 d2 00             	adc    $0x0,%edx
f0102fe4:	f7 da                	neg    %edx
f0102fe6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102fe9:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102fee:	eb 55                	jmp    f0103045 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102ff0:	8d 45 14             	lea    0x14(%ebp),%eax
f0102ff3:	e8 83 fc ff ff       	call   f0102c7b <getuint>
			base = 10;
f0102ff8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0102ffd:	eb 46                	jmp    f0103045 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0102fff:	8d 45 14             	lea    0x14(%ebp),%eax
f0103002:	e8 74 fc ff ff       	call   f0102c7b <getuint>
			base = 8;
f0103007:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f010300c:	eb 37                	jmp    f0103045 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f010300e:	83 ec 08             	sub    $0x8,%esp
f0103011:	53                   	push   %ebx
f0103012:	6a 30                	push   $0x30
f0103014:	ff d6                	call   *%esi
			putch('x', putdat);
f0103016:	83 c4 08             	add    $0x8,%esp
f0103019:	53                   	push   %ebx
f010301a:	6a 78                	push   $0x78
f010301c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010301e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103021:	8d 50 04             	lea    0x4(%eax),%edx
f0103024:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103027:	8b 00                	mov    (%eax),%eax
f0103029:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010302e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103031:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0103036:	eb 0d                	jmp    f0103045 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103038:	8d 45 14             	lea    0x14(%ebp),%eax
f010303b:	e8 3b fc ff ff       	call   f0102c7b <getuint>
			base = 16;
f0103040:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103045:	83 ec 0c             	sub    $0xc,%esp
f0103048:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010304c:	57                   	push   %edi
f010304d:	ff 75 e0             	pushl  -0x20(%ebp)
f0103050:	51                   	push   %ecx
f0103051:	52                   	push   %edx
f0103052:	50                   	push   %eax
f0103053:	89 da                	mov    %ebx,%edx
f0103055:	89 f0                	mov    %esi,%eax
f0103057:	e8 70 fb ff ff       	call   f0102bcc <printnum>
			break;
f010305c:	83 c4 20             	add    $0x20,%esp
f010305f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103062:	e9 ae fc ff ff       	jmp    f0102d15 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103067:	83 ec 08             	sub    $0x8,%esp
f010306a:	53                   	push   %ebx
f010306b:	51                   	push   %ecx
f010306c:	ff d6                	call   *%esi
			break;
f010306e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103071:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103074:	e9 9c fc ff ff       	jmp    f0102d15 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103079:	83 ec 08             	sub    $0x8,%esp
f010307c:	53                   	push   %ebx
f010307d:	6a 25                	push   $0x25
f010307f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103081:	83 c4 10             	add    $0x10,%esp
f0103084:	eb 03                	jmp    f0103089 <vprintfmt+0x39a>
f0103086:	83 ef 01             	sub    $0x1,%edi
f0103089:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010308d:	75 f7                	jne    f0103086 <vprintfmt+0x397>
f010308f:	e9 81 fc ff ff       	jmp    f0102d15 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0103094:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103097:	5b                   	pop    %ebx
f0103098:	5e                   	pop    %esi
f0103099:	5f                   	pop    %edi
f010309a:	5d                   	pop    %ebp
f010309b:	c3                   	ret    

f010309c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010309c:	55                   	push   %ebp
f010309d:	89 e5                	mov    %esp,%ebp
f010309f:	83 ec 18             	sub    $0x18,%esp
f01030a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01030a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01030a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01030ab:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01030af:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01030b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01030b9:	85 c0                	test   %eax,%eax
f01030bb:	74 26                	je     f01030e3 <vsnprintf+0x47>
f01030bd:	85 d2                	test   %edx,%edx
f01030bf:	7e 22                	jle    f01030e3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01030c1:	ff 75 14             	pushl  0x14(%ebp)
f01030c4:	ff 75 10             	pushl  0x10(%ebp)
f01030c7:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01030ca:	50                   	push   %eax
f01030cb:	68 b5 2c 10 f0       	push   $0xf0102cb5
f01030d0:	e8 1a fc ff ff       	call   f0102cef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01030d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01030d8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01030db:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01030de:	83 c4 10             	add    $0x10,%esp
f01030e1:	eb 05                	jmp    f01030e8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01030e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01030e8:	c9                   	leave  
f01030e9:	c3                   	ret    

f01030ea <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01030ea:	55                   	push   %ebp
f01030eb:	89 e5                	mov    %esp,%ebp
f01030ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01030f0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01030f3:	50                   	push   %eax
f01030f4:	ff 75 10             	pushl  0x10(%ebp)
f01030f7:	ff 75 0c             	pushl  0xc(%ebp)
f01030fa:	ff 75 08             	pushl  0x8(%ebp)
f01030fd:	e8 9a ff ff ff       	call   f010309c <vsnprintf>
	va_end(ap);

	return rc;
}
f0103102:	c9                   	leave  
f0103103:	c3                   	ret    

f0103104 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103104:	55                   	push   %ebp
f0103105:	89 e5                	mov    %esp,%ebp
f0103107:	57                   	push   %edi
f0103108:	56                   	push   %esi
f0103109:	53                   	push   %ebx
f010310a:	83 ec 0c             	sub    $0xc,%esp
f010310d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103110:	85 c0                	test   %eax,%eax
f0103112:	74 11                	je     f0103125 <readline+0x21>
		cprintf("%s", prompt);
f0103114:	83 ec 08             	sub    $0x8,%esp
f0103117:	50                   	push   %eax
f0103118:	68 97 3d 10 f0       	push   $0xf0103d97
f010311d:	e8 75 f7 ff ff       	call   f0102897 <cprintf>
f0103122:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103125:	83 ec 0c             	sub    $0xc,%esp
f0103128:	6a 00                	push   $0x0
f010312a:	e8 f2 d4 ff ff       	call   f0100621 <iscons>
f010312f:	89 c7                	mov    %eax,%edi
f0103131:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103134:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103139:	e8 d2 d4 ff ff       	call   f0100610 <getchar>
f010313e:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103140:	85 c0                	test   %eax,%eax
f0103142:	79 18                	jns    f010315c <readline+0x58>
			cprintf("read error: %e\n", c);
f0103144:	83 ec 08             	sub    $0x8,%esp
f0103147:	50                   	push   %eax
f0103148:	68 dc 4a 10 f0       	push   $0xf0104adc
f010314d:	e8 45 f7 ff ff       	call   f0102897 <cprintf>
			return NULL;
f0103152:	83 c4 10             	add    $0x10,%esp
f0103155:	b8 00 00 00 00       	mov    $0x0,%eax
f010315a:	eb 79                	jmp    f01031d5 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010315c:	83 f8 08             	cmp    $0x8,%eax
f010315f:	0f 94 c2             	sete   %dl
f0103162:	83 f8 7f             	cmp    $0x7f,%eax
f0103165:	0f 94 c0             	sete   %al
f0103168:	08 c2                	or     %al,%dl
f010316a:	74 1a                	je     f0103186 <readline+0x82>
f010316c:	85 f6                	test   %esi,%esi
f010316e:	7e 16                	jle    f0103186 <readline+0x82>
			if (echoing)
f0103170:	85 ff                	test   %edi,%edi
f0103172:	74 0d                	je     f0103181 <readline+0x7d>
				cputchar('\b');
f0103174:	83 ec 0c             	sub    $0xc,%esp
f0103177:	6a 08                	push   $0x8
f0103179:	e8 82 d4 ff ff       	call   f0100600 <cputchar>
f010317e:	83 c4 10             	add    $0x10,%esp
			i--;
f0103181:	83 ee 01             	sub    $0x1,%esi
f0103184:	eb b3                	jmp    f0103139 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103186:	83 fb 1f             	cmp    $0x1f,%ebx
f0103189:	7e 23                	jle    f01031ae <readline+0xaa>
f010318b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103191:	7f 1b                	jg     f01031ae <readline+0xaa>
			if (echoing)
f0103193:	85 ff                	test   %edi,%edi
f0103195:	74 0c                	je     f01031a3 <readline+0x9f>
				cputchar(c);
f0103197:	83 ec 0c             	sub    $0xc,%esp
f010319a:	53                   	push   %ebx
f010319b:	e8 60 d4 ff ff       	call   f0100600 <cputchar>
f01031a0:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01031a3:	88 9e 60 75 11 f0    	mov    %bl,-0xfee8aa0(%esi)
f01031a9:	8d 76 01             	lea    0x1(%esi),%esi
f01031ac:	eb 8b                	jmp    f0103139 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01031ae:	83 fb 0a             	cmp    $0xa,%ebx
f01031b1:	74 05                	je     f01031b8 <readline+0xb4>
f01031b3:	83 fb 0d             	cmp    $0xd,%ebx
f01031b6:	75 81                	jne    f0103139 <readline+0x35>
			if (echoing)
f01031b8:	85 ff                	test   %edi,%edi
f01031ba:	74 0d                	je     f01031c9 <readline+0xc5>
				cputchar('\n');
f01031bc:	83 ec 0c             	sub    $0xc,%esp
f01031bf:	6a 0a                	push   $0xa
f01031c1:	e8 3a d4 ff ff       	call   f0100600 <cputchar>
f01031c6:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01031c9:	c6 86 60 75 11 f0 00 	movb   $0x0,-0xfee8aa0(%esi)
			return buf;
f01031d0:	b8 60 75 11 f0       	mov    $0xf0117560,%eax
		}
	}
}
f01031d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031d8:	5b                   	pop    %ebx
f01031d9:	5e                   	pop    %esi
f01031da:	5f                   	pop    %edi
f01031db:	5d                   	pop    %ebp
f01031dc:	c3                   	ret    

f01031dd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01031dd:	55                   	push   %ebp
f01031de:	89 e5                	mov    %esp,%ebp
f01031e0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01031e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01031e8:	eb 03                	jmp    f01031ed <strlen+0x10>
		n++;
f01031ea:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01031ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01031f1:	75 f7                	jne    f01031ea <strlen+0xd>
		n++;
	return n;
}
f01031f3:	5d                   	pop    %ebp
f01031f4:	c3                   	ret    

f01031f5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01031f5:	55                   	push   %ebp
f01031f6:	89 e5                	mov    %esp,%ebp
f01031f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01031fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01031fe:	ba 00 00 00 00       	mov    $0x0,%edx
f0103203:	eb 03                	jmp    f0103208 <strnlen+0x13>
		n++;
f0103205:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103208:	39 c2                	cmp    %eax,%edx
f010320a:	74 08                	je     f0103214 <strnlen+0x1f>
f010320c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0103210:	75 f3                	jne    f0103205 <strnlen+0x10>
f0103212:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0103214:	5d                   	pop    %ebp
f0103215:	c3                   	ret    

f0103216 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103216:	55                   	push   %ebp
f0103217:	89 e5                	mov    %esp,%ebp
f0103219:	53                   	push   %ebx
f010321a:	8b 45 08             	mov    0x8(%ebp),%eax
f010321d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103220:	89 c2                	mov    %eax,%edx
f0103222:	83 c2 01             	add    $0x1,%edx
f0103225:	83 c1 01             	add    $0x1,%ecx
f0103228:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010322c:	88 5a ff             	mov    %bl,-0x1(%edx)
f010322f:	84 db                	test   %bl,%bl
f0103231:	75 ef                	jne    f0103222 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103233:	5b                   	pop    %ebx
f0103234:	5d                   	pop    %ebp
f0103235:	c3                   	ret    

f0103236 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103236:	55                   	push   %ebp
f0103237:	89 e5                	mov    %esp,%ebp
f0103239:	53                   	push   %ebx
f010323a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010323d:	53                   	push   %ebx
f010323e:	e8 9a ff ff ff       	call   f01031dd <strlen>
f0103243:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103246:	ff 75 0c             	pushl  0xc(%ebp)
f0103249:	01 d8                	add    %ebx,%eax
f010324b:	50                   	push   %eax
f010324c:	e8 c5 ff ff ff       	call   f0103216 <strcpy>
	return dst;
}
f0103251:	89 d8                	mov    %ebx,%eax
f0103253:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103256:	c9                   	leave  
f0103257:	c3                   	ret    

f0103258 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103258:	55                   	push   %ebp
f0103259:	89 e5                	mov    %esp,%ebp
f010325b:	56                   	push   %esi
f010325c:	53                   	push   %ebx
f010325d:	8b 75 08             	mov    0x8(%ebp),%esi
f0103260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103263:	89 f3                	mov    %esi,%ebx
f0103265:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103268:	89 f2                	mov    %esi,%edx
f010326a:	eb 0f                	jmp    f010327b <strncpy+0x23>
		*dst++ = *src;
f010326c:	83 c2 01             	add    $0x1,%edx
f010326f:	0f b6 01             	movzbl (%ecx),%eax
f0103272:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103275:	80 39 01             	cmpb   $0x1,(%ecx)
f0103278:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010327b:	39 da                	cmp    %ebx,%edx
f010327d:	75 ed                	jne    f010326c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010327f:	89 f0                	mov    %esi,%eax
f0103281:	5b                   	pop    %ebx
f0103282:	5e                   	pop    %esi
f0103283:	5d                   	pop    %ebp
f0103284:	c3                   	ret    

f0103285 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103285:	55                   	push   %ebp
f0103286:	89 e5                	mov    %esp,%ebp
f0103288:	56                   	push   %esi
f0103289:	53                   	push   %ebx
f010328a:	8b 75 08             	mov    0x8(%ebp),%esi
f010328d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103290:	8b 55 10             	mov    0x10(%ebp),%edx
f0103293:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103295:	85 d2                	test   %edx,%edx
f0103297:	74 21                	je     f01032ba <strlcpy+0x35>
f0103299:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010329d:	89 f2                	mov    %esi,%edx
f010329f:	eb 09                	jmp    f01032aa <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01032a1:	83 c2 01             	add    $0x1,%edx
f01032a4:	83 c1 01             	add    $0x1,%ecx
f01032a7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01032aa:	39 c2                	cmp    %eax,%edx
f01032ac:	74 09                	je     f01032b7 <strlcpy+0x32>
f01032ae:	0f b6 19             	movzbl (%ecx),%ebx
f01032b1:	84 db                	test   %bl,%bl
f01032b3:	75 ec                	jne    f01032a1 <strlcpy+0x1c>
f01032b5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01032b7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01032ba:	29 f0                	sub    %esi,%eax
}
f01032bc:	5b                   	pop    %ebx
f01032bd:	5e                   	pop    %esi
f01032be:	5d                   	pop    %ebp
f01032bf:	c3                   	ret    

f01032c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01032c0:	55                   	push   %ebp
f01032c1:	89 e5                	mov    %esp,%ebp
f01032c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01032c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01032c9:	eb 06                	jmp    f01032d1 <strcmp+0x11>
		p++, q++;
f01032cb:	83 c1 01             	add    $0x1,%ecx
f01032ce:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01032d1:	0f b6 01             	movzbl (%ecx),%eax
f01032d4:	84 c0                	test   %al,%al
f01032d6:	74 04                	je     f01032dc <strcmp+0x1c>
f01032d8:	3a 02                	cmp    (%edx),%al
f01032da:	74 ef                	je     f01032cb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01032dc:	0f b6 c0             	movzbl %al,%eax
f01032df:	0f b6 12             	movzbl (%edx),%edx
f01032e2:	29 d0                	sub    %edx,%eax
}
f01032e4:	5d                   	pop    %ebp
f01032e5:	c3                   	ret    

f01032e6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01032e6:	55                   	push   %ebp
f01032e7:	89 e5                	mov    %esp,%ebp
f01032e9:	53                   	push   %ebx
f01032ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01032ed:	8b 55 0c             	mov    0xc(%ebp),%edx
f01032f0:	89 c3                	mov    %eax,%ebx
f01032f2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01032f5:	eb 06                	jmp    f01032fd <strncmp+0x17>
		n--, p++, q++;
f01032f7:	83 c0 01             	add    $0x1,%eax
f01032fa:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01032fd:	39 d8                	cmp    %ebx,%eax
f01032ff:	74 15                	je     f0103316 <strncmp+0x30>
f0103301:	0f b6 08             	movzbl (%eax),%ecx
f0103304:	84 c9                	test   %cl,%cl
f0103306:	74 04                	je     f010330c <strncmp+0x26>
f0103308:	3a 0a                	cmp    (%edx),%cl
f010330a:	74 eb                	je     f01032f7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010330c:	0f b6 00             	movzbl (%eax),%eax
f010330f:	0f b6 12             	movzbl (%edx),%edx
f0103312:	29 d0                	sub    %edx,%eax
f0103314:	eb 05                	jmp    f010331b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103316:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010331b:	5b                   	pop    %ebx
f010331c:	5d                   	pop    %ebp
f010331d:	c3                   	ret    

f010331e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010331e:	55                   	push   %ebp
f010331f:	89 e5                	mov    %esp,%ebp
f0103321:	8b 45 08             	mov    0x8(%ebp),%eax
f0103324:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103328:	eb 07                	jmp    f0103331 <strchr+0x13>
		if (*s == c)
f010332a:	38 ca                	cmp    %cl,%dl
f010332c:	74 0f                	je     f010333d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010332e:	83 c0 01             	add    $0x1,%eax
f0103331:	0f b6 10             	movzbl (%eax),%edx
f0103334:	84 d2                	test   %dl,%dl
f0103336:	75 f2                	jne    f010332a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103338:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010333d:	5d                   	pop    %ebp
f010333e:	c3                   	ret    

f010333f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010333f:	55                   	push   %ebp
f0103340:	89 e5                	mov    %esp,%ebp
f0103342:	8b 45 08             	mov    0x8(%ebp),%eax
f0103345:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103349:	eb 03                	jmp    f010334e <strfind+0xf>
f010334b:	83 c0 01             	add    $0x1,%eax
f010334e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103351:	38 ca                	cmp    %cl,%dl
f0103353:	74 04                	je     f0103359 <strfind+0x1a>
f0103355:	84 d2                	test   %dl,%dl
f0103357:	75 f2                	jne    f010334b <strfind+0xc>
			break;
	return (char *) s;
}
f0103359:	5d                   	pop    %ebp
f010335a:	c3                   	ret    

f010335b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010335b:	55                   	push   %ebp
f010335c:	89 e5                	mov    %esp,%ebp
f010335e:	57                   	push   %edi
f010335f:	56                   	push   %esi
f0103360:	53                   	push   %ebx
f0103361:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103364:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103367:	85 c9                	test   %ecx,%ecx
f0103369:	74 36                	je     f01033a1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010336b:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103371:	75 28                	jne    f010339b <memset+0x40>
f0103373:	f6 c1 03             	test   $0x3,%cl
f0103376:	75 23                	jne    f010339b <memset+0x40>
		c &= 0xFF;
f0103378:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010337c:	89 d3                	mov    %edx,%ebx
f010337e:	c1 e3 08             	shl    $0x8,%ebx
f0103381:	89 d6                	mov    %edx,%esi
f0103383:	c1 e6 18             	shl    $0x18,%esi
f0103386:	89 d0                	mov    %edx,%eax
f0103388:	c1 e0 10             	shl    $0x10,%eax
f010338b:	09 f0                	or     %esi,%eax
f010338d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010338f:	89 d8                	mov    %ebx,%eax
f0103391:	09 d0                	or     %edx,%eax
f0103393:	c1 e9 02             	shr    $0x2,%ecx
f0103396:	fc                   	cld    
f0103397:	f3 ab                	rep stos %eax,%es:(%edi)
f0103399:	eb 06                	jmp    f01033a1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010339b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010339e:	fc                   	cld    
f010339f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01033a1:	89 f8                	mov    %edi,%eax
f01033a3:	5b                   	pop    %ebx
f01033a4:	5e                   	pop    %esi
f01033a5:	5f                   	pop    %edi
f01033a6:	5d                   	pop    %ebp
f01033a7:	c3                   	ret    

f01033a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01033a8:	55                   	push   %ebp
f01033a9:	89 e5                	mov    %esp,%ebp
f01033ab:	57                   	push   %edi
f01033ac:	56                   	push   %esi
f01033ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01033b0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01033b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01033b6:	39 c6                	cmp    %eax,%esi
f01033b8:	73 35                	jae    f01033ef <memmove+0x47>
f01033ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01033bd:	39 d0                	cmp    %edx,%eax
f01033bf:	73 2e                	jae    f01033ef <memmove+0x47>
		s += n;
		d += n;
f01033c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01033c4:	89 d6                	mov    %edx,%esi
f01033c6:	09 fe                	or     %edi,%esi
f01033c8:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01033ce:	75 13                	jne    f01033e3 <memmove+0x3b>
f01033d0:	f6 c1 03             	test   $0x3,%cl
f01033d3:	75 0e                	jne    f01033e3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01033d5:	83 ef 04             	sub    $0x4,%edi
f01033d8:	8d 72 fc             	lea    -0x4(%edx),%esi
f01033db:	c1 e9 02             	shr    $0x2,%ecx
f01033de:	fd                   	std    
f01033df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01033e1:	eb 09                	jmp    f01033ec <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01033e3:	83 ef 01             	sub    $0x1,%edi
f01033e6:	8d 72 ff             	lea    -0x1(%edx),%esi
f01033e9:	fd                   	std    
f01033ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01033ec:	fc                   	cld    
f01033ed:	eb 1d                	jmp    f010340c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01033ef:	89 f2                	mov    %esi,%edx
f01033f1:	09 c2                	or     %eax,%edx
f01033f3:	f6 c2 03             	test   $0x3,%dl
f01033f6:	75 0f                	jne    f0103407 <memmove+0x5f>
f01033f8:	f6 c1 03             	test   $0x3,%cl
f01033fb:	75 0a                	jne    f0103407 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01033fd:	c1 e9 02             	shr    $0x2,%ecx
f0103400:	89 c7                	mov    %eax,%edi
f0103402:	fc                   	cld    
f0103403:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103405:	eb 05                	jmp    f010340c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103407:	89 c7                	mov    %eax,%edi
f0103409:	fc                   	cld    
f010340a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010340c:	5e                   	pop    %esi
f010340d:	5f                   	pop    %edi
f010340e:	5d                   	pop    %ebp
f010340f:	c3                   	ret    

f0103410 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103410:	55                   	push   %ebp
f0103411:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103413:	ff 75 10             	pushl  0x10(%ebp)
f0103416:	ff 75 0c             	pushl  0xc(%ebp)
f0103419:	ff 75 08             	pushl  0x8(%ebp)
f010341c:	e8 87 ff ff ff       	call   f01033a8 <memmove>
}
f0103421:	c9                   	leave  
f0103422:	c3                   	ret    

f0103423 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103423:	55                   	push   %ebp
f0103424:	89 e5                	mov    %esp,%ebp
f0103426:	56                   	push   %esi
f0103427:	53                   	push   %ebx
f0103428:	8b 45 08             	mov    0x8(%ebp),%eax
f010342b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010342e:	89 c6                	mov    %eax,%esi
f0103430:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103433:	eb 1a                	jmp    f010344f <memcmp+0x2c>
		if (*s1 != *s2)
f0103435:	0f b6 08             	movzbl (%eax),%ecx
f0103438:	0f b6 1a             	movzbl (%edx),%ebx
f010343b:	38 d9                	cmp    %bl,%cl
f010343d:	74 0a                	je     f0103449 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010343f:	0f b6 c1             	movzbl %cl,%eax
f0103442:	0f b6 db             	movzbl %bl,%ebx
f0103445:	29 d8                	sub    %ebx,%eax
f0103447:	eb 0f                	jmp    f0103458 <memcmp+0x35>
		s1++, s2++;
f0103449:	83 c0 01             	add    $0x1,%eax
f010344c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010344f:	39 f0                	cmp    %esi,%eax
f0103451:	75 e2                	jne    f0103435 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103453:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103458:	5b                   	pop    %ebx
f0103459:	5e                   	pop    %esi
f010345a:	5d                   	pop    %ebp
f010345b:	c3                   	ret    

f010345c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010345c:	55                   	push   %ebp
f010345d:	89 e5                	mov    %esp,%ebp
f010345f:	53                   	push   %ebx
f0103460:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103463:	89 c1                	mov    %eax,%ecx
f0103465:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0103468:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010346c:	eb 0a                	jmp    f0103478 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010346e:	0f b6 10             	movzbl (%eax),%edx
f0103471:	39 da                	cmp    %ebx,%edx
f0103473:	74 07                	je     f010347c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103475:	83 c0 01             	add    $0x1,%eax
f0103478:	39 c8                	cmp    %ecx,%eax
f010347a:	72 f2                	jb     f010346e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010347c:	5b                   	pop    %ebx
f010347d:	5d                   	pop    %ebp
f010347e:	c3                   	ret    

f010347f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010347f:	55                   	push   %ebp
f0103480:	89 e5                	mov    %esp,%ebp
f0103482:	57                   	push   %edi
f0103483:	56                   	push   %esi
f0103484:	53                   	push   %ebx
f0103485:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103488:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010348b:	eb 03                	jmp    f0103490 <strtol+0x11>
		s++;
f010348d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103490:	0f b6 01             	movzbl (%ecx),%eax
f0103493:	3c 20                	cmp    $0x20,%al
f0103495:	74 f6                	je     f010348d <strtol+0xe>
f0103497:	3c 09                	cmp    $0x9,%al
f0103499:	74 f2                	je     f010348d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010349b:	3c 2b                	cmp    $0x2b,%al
f010349d:	75 0a                	jne    f01034a9 <strtol+0x2a>
		s++;
f010349f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01034a2:	bf 00 00 00 00       	mov    $0x0,%edi
f01034a7:	eb 11                	jmp    f01034ba <strtol+0x3b>
f01034a9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01034ae:	3c 2d                	cmp    $0x2d,%al
f01034b0:	75 08                	jne    f01034ba <strtol+0x3b>
		s++, neg = 1;
f01034b2:	83 c1 01             	add    $0x1,%ecx
f01034b5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01034ba:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01034c0:	75 15                	jne    f01034d7 <strtol+0x58>
f01034c2:	80 39 30             	cmpb   $0x30,(%ecx)
f01034c5:	75 10                	jne    f01034d7 <strtol+0x58>
f01034c7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01034cb:	75 7c                	jne    f0103549 <strtol+0xca>
		s += 2, base = 16;
f01034cd:	83 c1 02             	add    $0x2,%ecx
f01034d0:	bb 10 00 00 00       	mov    $0x10,%ebx
f01034d5:	eb 16                	jmp    f01034ed <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01034d7:	85 db                	test   %ebx,%ebx
f01034d9:	75 12                	jne    f01034ed <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01034db:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01034e0:	80 39 30             	cmpb   $0x30,(%ecx)
f01034e3:	75 08                	jne    f01034ed <strtol+0x6e>
		s++, base = 8;
f01034e5:	83 c1 01             	add    $0x1,%ecx
f01034e8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01034ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01034f2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01034f5:	0f b6 11             	movzbl (%ecx),%edx
f01034f8:	8d 72 d0             	lea    -0x30(%edx),%esi
f01034fb:	89 f3                	mov    %esi,%ebx
f01034fd:	80 fb 09             	cmp    $0x9,%bl
f0103500:	77 08                	ja     f010350a <strtol+0x8b>
			dig = *s - '0';
f0103502:	0f be d2             	movsbl %dl,%edx
f0103505:	83 ea 30             	sub    $0x30,%edx
f0103508:	eb 22                	jmp    f010352c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010350a:	8d 72 9f             	lea    -0x61(%edx),%esi
f010350d:	89 f3                	mov    %esi,%ebx
f010350f:	80 fb 19             	cmp    $0x19,%bl
f0103512:	77 08                	ja     f010351c <strtol+0x9d>
			dig = *s - 'a' + 10;
f0103514:	0f be d2             	movsbl %dl,%edx
f0103517:	83 ea 57             	sub    $0x57,%edx
f010351a:	eb 10                	jmp    f010352c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010351c:	8d 72 bf             	lea    -0x41(%edx),%esi
f010351f:	89 f3                	mov    %esi,%ebx
f0103521:	80 fb 19             	cmp    $0x19,%bl
f0103524:	77 16                	ja     f010353c <strtol+0xbd>
			dig = *s - 'A' + 10;
f0103526:	0f be d2             	movsbl %dl,%edx
f0103529:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010352c:	3b 55 10             	cmp    0x10(%ebp),%edx
f010352f:	7d 0b                	jge    f010353c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0103531:	83 c1 01             	add    $0x1,%ecx
f0103534:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103538:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010353a:	eb b9                	jmp    f01034f5 <strtol+0x76>

	if (endptr)
f010353c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103540:	74 0d                	je     f010354f <strtol+0xd0>
		*endptr = (char *) s;
f0103542:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103545:	89 0e                	mov    %ecx,(%esi)
f0103547:	eb 06                	jmp    f010354f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103549:	85 db                	test   %ebx,%ebx
f010354b:	74 98                	je     f01034e5 <strtol+0x66>
f010354d:	eb 9e                	jmp    f01034ed <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010354f:	89 c2                	mov    %eax,%edx
f0103551:	f7 da                	neg    %edx
f0103553:	85 ff                	test   %edi,%edi
f0103555:	0f 45 c2             	cmovne %edx,%eax
}
f0103558:	5b                   	pop    %ebx
f0103559:	5e                   	pop    %esi
f010355a:	5f                   	pop    %edi
f010355b:	5d                   	pop    %ebp
f010355c:	c3                   	ret    
f010355d:	66 90                	xchg   %ax,%ax
f010355f:	90                   	nop

f0103560 <__udivdi3>:
f0103560:	55                   	push   %ebp
f0103561:	57                   	push   %edi
f0103562:	56                   	push   %esi
f0103563:	53                   	push   %ebx
f0103564:	83 ec 1c             	sub    $0x1c,%esp
f0103567:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010356b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010356f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0103573:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103577:	85 f6                	test   %esi,%esi
f0103579:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010357d:	89 ca                	mov    %ecx,%edx
f010357f:	89 f8                	mov    %edi,%eax
f0103581:	75 3d                	jne    f01035c0 <__udivdi3+0x60>
f0103583:	39 cf                	cmp    %ecx,%edi
f0103585:	0f 87 c5 00 00 00    	ja     f0103650 <__udivdi3+0xf0>
f010358b:	85 ff                	test   %edi,%edi
f010358d:	89 fd                	mov    %edi,%ebp
f010358f:	75 0b                	jne    f010359c <__udivdi3+0x3c>
f0103591:	b8 01 00 00 00       	mov    $0x1,%eax
f0103596:	31 d2                	xor    %edx,%edx
f0103598:	f7 f7                	div    %edi
f010359a:	89 c5                	mov    %eax,%ebp
f010359c:	89 c8                	mov    %ecx,%eax
f010359e:	31 d2                	xor    %edx,%edx
f01035a0:	f7 f5                	div    %ebp
f01035a2:	89 c1                	mov    %eax,%ecx
f01035a4:	89 d8                	mov    %ebx,%eax
f01035a6:	89 cf                	mov    %ecx,%edi
f01035a8:	f7 f5                	div    %ebp
f01035aa:	89 c3                	mov    %eax,%ebx
f01035ac:	89 d8                	mov    %ebx,%eax
f01035ae:	89 fa                	mov    %edi,%edx
f01035b0:	83 c4 1c             	add    $0x1c,%esp
f01035b3:	5b                   	pop    %ebx
f01035b4:	5e                   	pop    %esi
f01035b5:	5f                   	pop    %edi
f01035b6:	5d                   	pop    %ebp
f01035b7:	c3                   	ret    
f01035b8:	90                   	nop
f01035b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01035c0:	39 ce                	cmp    %ecx,%esi
f01035c2:	77 74                	ja     f0103638 <__udivdi3+0xd8>
f01035c4:	0f bd fe             	bsr    %esi,%edi
f01035c7:	83 f7 1f             	xor    $0x1f,%edi
f01035ca:	0f 84 98 00 00 00    	je     f0103668 <__udivdi3+0x108>
f01035d0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01035d5:	89 f9                	mov    %edi,%ecx
f01035d7:	89 c5                	mov    %eax,%ebp
f01035d9:	29 fb                	sub    %edi,%ebx
f01035db:	d3 e6                	shl    %cl,%esi
f01035dd:	89 d9                	mov    %ebx,%ecx
f01035df:	d3 ed                	shr    %cl,%ebp
f01035e1:	89 f9                	mov    %edi,%ecx
f01035e3:	d3 e0                	shl    %cl,%eax
f01035e5:	09 ee                	or     %ebp,%esi
f01035e7:	89 d9                	mov    %ebx,%ecx
f01035e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035ed:	89 d5                	mov    %edx,%ebp
f01035ef:	8b 44 24 08          	mov    0x8(%esp),%eax
f01035f3:	d3 ed                	shr    %cl,%ebp
f01035f5:	89 f9                	mov    %edi,%ecx
f01035f7:	d3 e2                	shl    %cl,%edx
f01035f9:	89 d9                	mov    %ebx,%ecx
f01035fb:	d3 e8                	shr    %cl,%eax
f01035fd:	09 c2                	or     %eax,%edx
f01035ff:	89 d0                	mov    %edx,%eax
f0103601:	89 ea                	mov    %ebp,%edx
f0103603:	f7 f6                	div    %esi
f0103605:	89 d5                	mov    %edx,%ebp
f0103607:	89 c3                	mov    %eax,%ebx
f0103609:	f7 64 24 0c          	mull   0xc(%esp)
f010360d:	39 d5                	cmp    %edx,%ebp
f010360f:	72 10                	jb     f0103621 <__udivdi3+0xc1>
f0103611:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103615:	89 f9                	mov    %edi,%ecx
f0103617:	d3 e6                	shl    %cl,%esi
f0103619:	39 c6                	cmp    %eax,%esi
f010361b:	73 07                	jae    f0103624 <__udivdi3+0xc4>
f010361d:	39 d5                	cmp    %edx,%ebp
f010361f:	75 03                	jne    f0103624 <__udivdi3+0xc4>
f0103621:	83 eb 01             	sub    $0x1,%ebx
f0103624:	31 ff                	xor    %edi,%edi
f0103626:	89 d8                	mov    %ebx,%eax
f0103628:	89 fa                	mov    %edi,%edx
f010362a:	83 c4 1c             	add    $0x1c,%esp
f010362d:	5b                   	pop    %ebx
f010362e:	5e                   	pop    %esi
f010362f:	5f                   	pop    %edi
f0103630:	5d                   	pop    %ebp
f0103631:	c3                   	ret    
f0103632:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103638:	31 ff                	xor    %edi,%edi
f010363a:	31 db                	xor    %ebx,%ebx
f010363c:	89 d8                	mov    %ebx,%eax
f010363e:	89 fa                	mov    %edi,%edx
f0103640:	83 c4 1c             	add    $0x1c,%esp
f0103643:	5b                   	pop    %ebx
f0103644:	5e                   	pop    %esi
f0103645:	5f                   	pop    %edi
f0103646:	5d                   	pop    %ebp
f0103647:	c3                   	ret    
f0103648:	90                   	nop
f0103649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103650:	89 d8                	mov    %ebx,%eax
f0103652:	f7 f7                	div    %edi
f0103654:	31 ff                	xor    %edi,%edi
f0103656:	89 c3                	mov    %eax,%ebx
f0103658:	89 d8                	mov    %ebx,%eax
f010365a:	89 fa                	mov    %edi,%edx
f010365c:	83 c4 1c             	add    $0x1c,%esp
f010365f:	5b                   	pop    %ebx
f0103660:	5e                   	pop    %esi
f0103661:	5f                   	pop    %edi
f0103662:	5d                   	pop    %ebp
f0103663:	c3                   	ret    
f0103664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103668:	39 ce                	cmp    %ecx,%esi
f010366a:	72 0c                	jb     f0103678 <__udivdi3+0x118>
f010366c:	31 db                	xor    %ebx,%ebx
f010366e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0103672:	0f 87 34 ff ff ff    	ja     f01035ac <__udivdi3+0x4c>
f0103678:	bb 01 00 00 00       	mov    $0x1,%ebx
f010367d:	e9 2a ff ff ff       	jmp    f01035ac <__udivdi3+0x4c>
f0103682:	66 90                	xchg   %ax,%ax
f0103684:	66 90                	xchg   %ax,%ax
f0103686:	66 90                	xchg   %ax,%ax
f0103688:	66 90                	xchg   %ax,%ax
f010368a:	66 90                	xchg   %ax,%ax
f010368c:	66 90                	xchg   %ax,%ax
f010368e:	66 90                	xchg   %ax,%ax

f0103690 <__umoddi3>:
f0103690:	55                   	push   %ebp
f0103691:	57                   	push   %edi
f0103692:	56                   	push   %esi
f0103693:	53                   	push   %ebx
f0103694:	83 ec 1c             	sub    $0x1c,%esp
f0103697:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010369b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010369f:	8b 74 24 34          	mov    0x34(%esp),%esi
f01036a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01036a7:	85 d2                	test   %edx,%edx
f01036a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01036ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01036b1:	89 f3                	mov    %esi,%ebx
f01036b3:	89 3c 24             	mov    %edi,(%esp)
f01036b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01036ba:	75 1c                	jne    f01036d8 <__umoddi3+0x48>
f01036bc:	39 f7                	cmp    %esi,%edi
f01036be:	76 50                	jbe    f0103710 <__umoddi3+0x80>
f01036c0:	89 c8                	mov    %ecx,%eax
f01036c2:	89 f2                	mov    %esi,%edx
f01036c4:	f7 f7                	div    %edi
f01036c6:	89 d0                	mov    %edx,%eax
f01036c8:	31 d2                	xor    %edx,%edx
f01036ca:	83 c4 1c             	add    $0x1c,%esp
f01036cd:	5b                   	pop    %ebx
f01036ce:	5e                   	pop    %esi
f01036cf:	5f                   	pop    %edi
f01036d0:	5d                   	pop    %ebp
f01036d1:	c3                   	ret    
f01036d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01036d8:	39 f2                	cmp    %esi,%edx
f01036da:	89 d0                	mov    %edx,%eax
f01036dc:	77 52                	ja     f0103730 <__umoddi3+0xa0>
f01036de:	0f bd ea             	bsr    %edx,%ebp
f01036e1:	83 f5 1f             	xor    $0x1f,%ebp
f01036e4:	75 5a                	jne    f0103740 <__umoddi3+0xb0>
f01036e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01036ea:	0f 82 e0 00 00 00    	jb     f01037d0 <__umoddi3+0x140>
f01036f0:	39 0c 24             	cmp    %ecx,(%esp)
f01036f3:	0f 86 d7 00 00 00    	jbe    f01037d0 <__umoddi3+0x140>
f01036f9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01036fd:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103701:	83 c4 1c             	add    $0x1c,%esp
f0103704:	5b                   	pop    %ebx
f0103705:	5e                   	pop    %esi
f0103706:	5f                   	pop    %edi
f0103707:	5d                   	pop    %ebp
f0103708:	c3                   	ret    
f0103709:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103710:	85 ff                	test   %edi,%edi
f0103712:	89 fd                	mov    %edi,%ebp
f0103714:	75 0b                	jne    f0103721 <__umoddi3+0x91>
f0103716:	b8 01 00 00 00       	mov    $0x1,%eax
f010371b:	31 d2                	xor    %edx,%edx
f010371d:	f7 f7                	div    %edi
f010371f:	89 c5                	mov    %eax,%ebp
f0103721:	89 f0                	mov    %esi,%eax
f0103723:	31 d2                	xor    %edx,%edx
f0103725:	f7 f5                	div    %ebp
f0103727:	89 c8                	mov    %ecx,%eax
f0103729:	f7 f5                	div    %ebp
f010372b:	89 d0                	mov    %edx,%eax
f010372d:	eb 99                	jmp    f01036c8 <__umoddi3+0x38>
f010372f:	90                   	nop
f0103730:	89 c8                	mov    %ecx,%eax
f0103732:	89 f2                	mov    %esi,%edx
f0103734:	83 c4 1c             	add    $0x1c,%esp
f0103737:	5b                   	pop    %ebx
f0103738:	5e                   	pop    %esi
f0103739:	5f                   	pop    %edi
f010373a:	5d                   	pop    %ebp
f010373b:	c3                   	ret    
f010373c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103740:	8b 34 24             	mov    (%esp),%esi
f0103743:	bf 20 00 00 00       	mov    $0x20,%edi
f0103748:	89 e9                	mov    %ebp,%ecx
f010374a:	29 ef                	sub    %ebp,%edi
f010374c:	d3 e0                	shl    %cl,%eax
f010374e:	89 f9                	mov    %edi,%ecx
f0103750:	89 f2                	mov    %esi,%edx
f0103752:	d3 ea                	shr    %cl,%edx
f0103754:	89 e9                	mov    %ebp,%ecx
f0103756:	09 c2                	or     %eax,%edx
f0103758:	89 d8                	mov    %ebx,%eax
f010375a:	89 14 24             	mov    %edx,(%esp)
f010375d:	89 f2                	mov    %esi,%edx
f010375f:	d3 e2                	shl    %cl,%edx
f0103761:	89 f9                	mov    %edi,%ecx
f0103763:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103767:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010376b:	d3 e8                	shr    %cl,%eax
f010376d:	89 e9                	mov    %ebp,%ecx
f010376f:	89 c6                	mov    %eax,%esi
f0103771:	d3 e3                	shl    %cl,%ebx
f0103773:	89 f9                	mov    %edi,%ecx
f0103775:	89 d0                	mov    %edx,%eax
f0103777:	d3 e8                	shr    %cl,%eax
f0103779:	89 e9                	mov    %ebp,%ecx
f010377b:	09 d8                	or     %ebx,%eax
f010377d:	89 d3                	mov    %edx,%ebx
f010377f:	89 f2                	mov    %esi,%edx
f0103781:	f7 34 24             	divl   (%esp)
f0103784:	89 d6                	mov    %edx,%esi
f0103786:	d3 e3                	shl    %cl,%ebx
f0103788:	f7 64 24 04          	mull   0x4(%esp)
f010378c:	39 d6                	cmp    %edx,%esi
f010378e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103792:	89 d1                	mov    %edx,%ecx
f0103794:	89 c3                	mov    %eax,%ebx
f0103796:	72 08                	jb     f01037a0 <__umoddi3+0x110>
f0103798:	75 11                	jne    f01037ab <__umoddi3+0x11b>
f010379a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010379e:	73 0b                	jae    f01037ab <__umoddi3+0x11b>
f01037a0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01037a4:	1b 14 24             	sbb    (%esp),%edx
f01037a7:	89 d1                	mov    %edx,%ecx
f01037a9:	89 c3                	mov    %eax,%ebx
f01037ab:	8b 54 24 08          	mov    0x8(%esp),%edx
f01037af:	29 da                	sub    %ebx,%edx
f01037b1:	19 ce                	sbb    %ecx,%esi
f01037b3:	89 f9                	mov    %edi,%ecx
f01037b5:	89 f0                	mov    %esi,%eax
f01037b7:	d3 e0                	shl    %cl,%eax
f01037b9:	89 e9                	mov    %ebp,%ecx
f01037bb:	d3 ea                	shr    %cl,%edx
f01037bd:	89 e9                	mov    %ebp,%ecx
f01037bf:	d3 ee                	shr    %cl,%esi
f01037c1:	09 d0                	or     %edx,%eax
f01037c3:	89 f2                	mov    %esi,%edx
f01037c5:	83 c4 1c             	add    $0x1c,%esp
f01037c8:	5b                   	pop    %ebx
f01037c9:	5e                   	pop    %esi
f01037ca:	5f                   	pop    %edi
f01037cb:	5d                   	pop    %ebp
f01037cc:	c3                   	ret    
f01037cd:	8d 76 00             	lea    0x0(%esi),%esi
f01037d0:	29 f9                	sub    %edi,%ecx
f01037d2:	19 d6                	sbb    %edx,%esi
f01037d4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01037d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01037dc:	e9 18 ff ff ff       	jmp    f01036f9 <__umoddi3+0x69>
