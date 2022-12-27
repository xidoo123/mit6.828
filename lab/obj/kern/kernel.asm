
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
f0100015:	b8 00 30 11 00       	mov    $0x113000,%eax
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
f0100034:	bc 00 30 11 f0       	mov    $0xf0113000,%esp

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
f0100046:	b8 60 59 11 f0       	mov    $0xf0115960,%eax
f010004b:	2d 00 53 11 f0       	sub    $0xf0115300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 53 11 f0       	push   $0xf0115300
f0100058:	e8 d2 21 00 00       	call   f010222f <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 96 04 00 00       	call   f01004f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 e0 26 10 f0       	push   $0xf01026e0
f010006f:	e8 f7 16 00 00       	call   f010176b <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 2e 10 00 00       	call   f01010a7 <mem_init>
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
f0100093:	83 3d 64 59 11 f0 00 	cmpl   $0x0,0xf0115964
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 64 59 11 f0    	mov    %esi,0xf0115964

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
f01000b0:	68 fb 26 10 f0       	push   $0xf01026fb
f01000b5:	e8 b1 16 00 00       	call   f010176b <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 81 16 00 00       	call   f0101745 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 37 27 10 f0 	movl   $0xf0102737,(%esp)
f01000cb:	e8 9b 16 00 00       	call   f010176b <cprintf>
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
f01000f2:	68 13 27 10 f0       	push   $0xf0102713
f01000f7:	e8 6f 16 00 00       	call   f010176b <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 3d 16 00 00       	call   f0101745 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 37 27 10 f0 	movl   $0xf0102737,(%esp)
f010010f:	e8 57 16 00 00       	call   f010176b <cprintf>
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
f010014a:	8b 0d 24 55 11 f0    	mov    0xf0115524,%ecx
f0100150:	8d 51 01             	lea    0x1(%ecx),%edx
f0100153:	89 15 24 55 11 f0    	mov    %edx,0xf0115524
f0100159:	88 81 20 53 11 f0    	mov    %al,-0xfeeace0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010015f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100165:	75 0a                	jne    f0100171 <cons_intr+0x36>
			cons.wpos = 0;
f0100167:	c7 05 24 55 11 f0 00 	movl   $0x0,0xf0115524
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
f01001a0:	83 0d 00 53 11 f0 40 	orl    $0x40,0xf0115300
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
f01001b8:	8b 0d 00 53 11 f0    	mov    0xf0115300,%ecx
f01001be:	89 cb                	mov    %ecx,%ebx
f01001c0:	83 e3 40             	and    $0x40,%ebx
f01001c3:	83 e0 7f             	and    $0x7f,%eax
f01001c6:	85 db                	test   %ebx,%ebx
f01001c8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001cb:	0f b6 d2             	movzbl %dl,%edx
f01001ce:	0f b6 82 80 28 10 f0 	movzbl -0xfefd780(%edx),%eax
f01001d5:	83 c8 40             	or     $0x40,%eax
f01001d8:	0f b6 c0             	movzbl %al,%eax
f01001db:	f7 d0                	not    %eax
f01001dd:	21 c8                	and    %ecx,%eax
f01001df:	a3 00 53 11 f0       	mov    %eax,0xf0115300
		return 0;
f01001e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01001e9:	e9 a4 00 00 00       	jmp    f0100292 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f01001ee:	8b 0d 00 53 11 f0    	mov    0xf0115300,%ecx
f01001f4:	f6 c1 40             	test   $0x40,%cl
f01001f7:	74 0e                	je     f0100207 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001f9:	83 c8 80             	or     $0xffffff80,%eax
f01001fc:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001fe:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100201:	89 0d 00 53 11 f0    	mov    %ecx,0xf0115300
	}

	shift |= shiftcode[data];
f0100207:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010020a:	0f b6 82 80 28 10 f0 	movzbl -0xfefd780(%edx),%eax
f0100211:	0b 05 00 53 11 f0    	or     0xf0115300,%eax
f0100217:	0f b6 8a 80 27 10 f0 	movzbl -0xfefd880(%edx),%ecx
f010021e:	31 c8                	xor    %ecx,%eax
f0100220:	a3 00 53 11 f0       	mov    %eax,0xf0115300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100225:	89 c1                	mov    %eax,%ecx
f0100227:	83 e1 03             	and    $0x3,%ecx
f010022a:	8b 0c 8d 60 27 10 f0 	mov    -0xfefd8a0(,%ecx,4),%ecx
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
f0100268:	68 2d 27 10 f0       	push   $0xf010272d
f010026d:	e8 f9 14 00 00       	call   f010176b <cprintf>
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
f0100354:	0f b7 05 28 55 11 f0 	movzwl 0xf0115528,%eax
f010035b:	66 85 c0             	test   %ax,%ax
f010035e:	0f 84 e6 00 00 00    	je     f010044a <cons_putc+0x1b3>
			crt_pos--;
f0100364:	83 e8 01             	sub    $0x1,%eax
f0100367:	66 a3 28 55 11 f0    	mov    %ax,0xf0115528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010036d:	0f b7 c0             	movzwl %ax,%eax
f0100370:	66 81 e7 00 ff       	and    $0xff00,%di
f0100375:	83 cf 20             	or     $0x20,%edi
f0100378:	8b 15 2c 55 11 f0    	mov    0xf011552c,%edx
f010037e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100382:	eb 78                	jmp    f01003fc <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100384:	66 83 05 28 55 11 f0 	addw   $0x50,0xf0115528
f010038b:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010038c:	0f b7 05 28 55 11 f0 	movzwl 0xf0115528,%eax
f0100393:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100399:	c1 e8 16             	shr    $0x16,%eax
f010039c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010039f:	c1 e0 04             	shl    $0x4,%eax
f01003a2:	66 a3 28 55 11 f0    	mov    %ax,0xf0115528
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
f01003de:	0f b7 05 28 55 11 f0 	movzwl 0xf0115528,%eax
f01003e5:	8d 50 01             	lea    0x1(%eax),%edx
f01003e8:	66 89 15 28 55 11 f0 	mov    %dx,0xf0115528
f01003ef:	0f b7 c0             	movzwl %ax,%eax
f01003f2:	8b 15 2c 55 11 f0    	mov    0xf011552c,%edx
f01003f8:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003fc:	66 81 3d 28 55 11 f0 	cmpw   $0x7cf,0xf0115528
f0100403:	cf 07 
f0100405:	76 43                	jbe    f010044a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100407:	a1 2c 55 11 f0       	mov    0xf011552c,%eax
f010040c:	83 ec 04             	sub    $0x4,%esp
f010040f:	68 00 0f 00 00       	push   $0xf00
f0100414:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010041a:	52                   	push   %edx
f010041b:	50                   	push   %eax
f010041c:	e8 5b 1e 00 00       	call   f010227c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100421:	8b 15 2c 55 11 f0    	mov    0xf011552c,%edx
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
f0100442:	66 83 2d 28 55 11 f0 	subw   $0x50,0xf0115528
f0100449:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010044a:	8b 0d 30 55 11 f0    	mov    0xf0115530,%ecx
f0100450:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100455:	89 ca                	mov    %ecx,%edx
f0100457:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100458:	0f b7 1d 28 55 11 f0 	movzwl 0xf0115528,%ebx
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
f0100480:	80 3d 34 55 11 f0 00 	cmpb   $0x0,0xf0115534
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
f01004be:	a1 20 55 11 f0       	mov    0xf0115520,%eax
f01004c3:	3b 05 24 55 11 f0    	cmp    0xf0115524,%eax
f01004c9:	74 26                	je     f01004f1 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004cb:	8d 50 01             	lea    0x1(%eax),%edx
f01004ce:	89 15 20 55 11 f0    	mov    %edx,0xf0115520
f01004d4:	0f b6 88 20 53 11 f0 	movzbl -0xfeeace0(%eax),%ecx
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
f01004e5:	c7 05 20 55 11 f0 00 	movl   $0x0,0xf0115520
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
f010051e:	c7 05 30 55 11 f0 b4 	movl   $0x3b4,0xf0115530
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
f0100536:	c7 05 30 55 11 f0 d4 	movl   $0x3d4,0xf0115530
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
f0100545:	8b 3d 30 55 11 f0    	mov    0xf0115530,%edi
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
f010056a:	89 35 2c 55 11 f0    	mov    %esi,0xf011552c
	crt_pos = pos;
f0100570:	0f b6 c0             	movzbl %al,%eax
f0100573:	09 c8                	or     %ecx,%eax
f0100575:	66 a3 28 55 11 f0    	mov    %ax,0xf0115528
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
f01005d6:	0f 95 05 34 55 11 f0 	setne  0xf0115534
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
f01005eb:	68 39 27 10 f0       	push   $0xf0102739
f01005f0:	e8 76 11 00 00       	call   f010176b <cprintf>
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
f0100631:	68 80 29 10 f0       	push   $0xf0102980
f0100636:	68 9e 29 10 f0       	push   $0xf010299e
f010063b:	68 a3 29 10 f0       	push   $0xf01029a3
f0100640:	e8 26 11 00 00       	call   f010176b <cprintf>
f0100645:	83 c4 0c             	add    $0xc,%esp
f0100648:	68 5c 2a 10 f0       	push   $0xf0102a5c
f010064d:	68 ac 29 10 f0       	push   $0xf01029ac
f0100652:	68 a3 29 10 f0       	push   $0xf01029a3
f0100657:	e8 0f 11 00 00       	call   f010176b <cprintf>
f010065c:	83 c4 0c             	add    $0xc,%esp
f010065f:	68 b5 29 10 f0       	push   $0xf01029b5
f0100664:	68 d3 29 10 f0       	push   $0xf01029d3
f0100669:	68 a3 29 10 f0       	push   $0xf01029a3
f010066e:	e8 f8 10 00 00       	call   f010176b <cprintf>
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
f0100680:	68 dd 29 10 f0       	push   $0xf01029dd
f0100685:	e8 e1 10 00 00       	call   f010176b <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010068a:	83 c4 08             	add    $0x8,%esp
f010068d:	68 0c 00 10 00       	push   $0x10000c
f0100692:	68 84 2a 10 f0       	push   $0xf0102a84
f0100697:	e8 cf 10 00 00       	call   f010176b <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010069c:	83 c4 0c             	add    $0xc,%esp
f010069f:	68 0c 00 10 00       	push   $0x10000c
f01006a4:	68 0c 00 10 f0       	push   $0xf010000c
f01006a9:	68 ac 2a 10 f0       	push   $0xf0102aac
f01006ae:	e8 b8 10 00 00       	call   f010176b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b3:	83 c4 0c             	add    $0xc,%esp
f01006b6:	68 c1 26 10 00       	push   $0x1026c1
f01006bb:	68 c1 26 10 f0       	push   $0xf01026c1
f01006c0:	68 d0 2a 10 f0       	push   $0xf0102ad0
f01006c5:	e8 a1 10 00 00       	call   f010176b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ca:	83 c4 0c             	add    $0xc,%esp
f01006cd:	68 00 53 11 00       	push   $0x115300
f01006d2:	68 00 53 11 f0       	push   $0xf0115300
f01006d7:	68 f4 2a 10 f0       	push   $0xf0102af4
f01006dc:	e8 8a 10 00 00       	call   f010176b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e1:	83 c4 0c             	add    $0xc,%esp
f01006e4:	68 60 59 11 00       	push   $0x115960
f01006e9:	68 60 59 11 f0       	push   $0xf0115960
f01006ee:	68 18 2b 10 f0       	push   $0xf0102b18
f01006f3:	e8 73 10 00 00       	call   f010176b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006f8:	b8 5f 5d 11 f0       	mov    $0xf0115d5f,%eax
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
f0100719:	68 3c 2b 10 f0       	push   $0xf0102b3c
f010071e:	e8 48 10 00 00       	call   f010176b <cprintf>
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
f0100758:	68 f6 29 10 f0       	push   $0xf01029f6
f010075d:	e8 09 10 00 00       	call   f010176b <cprintf>

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
f010078a:	e8 e6 10 00 00       	call   f0101875 <debuginfo_eip>

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
f01007e6:	68 68 2b 10 f0       	push   $0xf0102b68
f01007eb:	e8 7b 0f 00 00       	call   f010176b <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f01007f0:	83 c4 14             	add    $0x14,%esp
f01007f3:	2b 75 cc             	sub    -0x34(%ebp),%esi
f01007f6:	56                   	push   %esi
f01007f7:	8d 45 8a             	lea    -0x76(%ebp),%eax
f01007fa:	50                   	push   %eax
f01007fb:	ff 75 c0             	pushl  -0x40(%ebp)
f01007fe:	ff 75 bc             	pushl  -0x44(%ebp)
f0100801:	68 08 2a 10 f0       	push   $0xf0102a08
f0100806:	e8 60 0f 00 00       	call   f010176b <cprintf>

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
f010082e:	68 a0 2b 10 f0       	push   $0xf0102ba0
f0100833:	e8 33 0f 00 00       	call   f010176b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100838:	c7 04 24 c4 2b 10 f0 	movl   $0xf0102bc4,(%esp)
f010083f:	e8 27 0f 00 00       	call   f010176b <cprintf>
f0100844:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100847:	83 ec 0c             	sub    $0xc,%esp
f010084a:	68 1f 2a 10 f0       	push   $0xf0102a1f
f010084f:	e8 84 17 00 00       	call   f0101fd8 <readline>
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
f0100883:	68 23 2a 10 f0       	push   $0xf0102a23
f0100888:	e8 65 19 00 00       	call   f01021f2 <strchr>
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
f01008a3:	68 28 2a 10 f0       	push   $0xf0102a28
f01008a8:	e8 be 0e 00 00       	call   f010176b <cprintf>
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
f01008cc:	68 23 2a 10 f0       	push   $0xf0102a23
f01008d1:	e8 1c 19 00 00       	call   f01021f2 <strchr>
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
f01008fa:	ff 34 85 00 2c 10 f0 	pushl  -0xfefd400(,%eax,4)
f0100901:	ff 75 a8             	pushl  -0x58(%ebp)
f0100904:	e8 8b 18 00 00       	call   f0102194 <strcmp>
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
f010091e:	ff 14 85 08 2c 10 f0 	call   *-0xfefd3f8(,%eax,4)


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
f010093f:	68 45 2a 10 f0       	push   $0xf0102a45
f0100944:	e8 22 0e 00 00       	call   f010176b <cprintf>
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
f0100964:	e8 9b 0d 00 00       	call   f0101704 <mc146818_read>
f0100969:	89 c6                	mov    %eax,%esi
f010096b:	83 c3 01             	add    $0x1,%ebx
f010096e:	89 1c 24             	mov    %ebx,(%esp)
f0100971:	e8 8e 0d 00 00       	call   f0101704 <mc146818_read>
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
f0100982:	83 3d 38 55 11 f0 00 	cmpl   $0x0,0xf0115538
f0100989:	75 11                	jne    f010099c <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010098b:	ba 5f 69 11 f0       	mov    $0xf011695f,%edx
f0100990:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100996:	89 15 38 55 11 f0    	mov    %edx,0xf0115538
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f010099c:	8b 15 38 55 11 f0    	mov    0xf0115538,%edx
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
f01009b0:	68 24 2c 10 f0       	push   $0xf0102c24
f01009b5:	6a 6b                	push   $0x6b
f01009b7:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01009bc:	e8 ca f6 ff ff       	call   f010008b <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f01009c1:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f01009c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009cd:	a3 38 55 11 f0       	mov    %eax,0xf0115538

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
f01009eb:	3b 0d 68 59 11 f0    	cmp    0xf0115968,%ecx
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
f01009fa:	68 10 2e 10 f0       	push   $0xf0102e10
f01009ff:	68 32 03 00 00       	push   $0x332
f0100a04:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0100a09:	e8 7d f6 ff ff       	call   f010008b <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
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
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
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
f0100a52:	68 34 2e 10 f0       	push   $0xf0102e34
f0100a57:	68 71 02 00 00       	push   $0x271
f0100a5c:	68 3f 2c 10 f0       	push   $0xf0102c3f
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
f0100a74:	2b 15 70 59 11 f0    	sub    0xf0115970,%edx
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
f0100aaa:	a3 3c 55 11 f0       	mov    %eax,0xf011553c
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
f0100ab4:	8b 1d 3c 55 11 f0    	mov    0xf011553c,%ebx
f0100aba:	eb 53                	jmp    f0100b0f <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100abc:	89 d8                	mov    %ebx,%eax
f0100abe:	2b 05 70 59 11 f0    	sub    0xf0115970,%eax
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
f0100ad8:	3b 15 68 59 11 f0    	cmp    0xf0115968,%edx
f0100ade:	72 12                	jb     f0100af2 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ae0:	50                   	push   %eax
f0100ae1:	68 10 2e 10 f0       	push   $0xf0102e10
f0100ae6:	6a 52                	push   $0x52
f0100ae8:	68 4b 2c 10 f0       	push   $0xf0102c4b
f0100aed:	e8 99 f5 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100af2:	83 ec 04             	sub    $0x4,%esp
f0100af5:	68 80 00 00 00       	push   $0x80
f0100afa:	68 97 00 00 00       	push   $0x97
f0100aff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b04:	50                   	push   %eax
f0100b05:	e8 25 17 00 00       	call   f010222f <memset>
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
f0100b20:	8b 15 3c 55 11 f0    	mov    0xf011553c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b26:	8b 0d 70 59 11 f0    	mov    0xf0115970,%ecx
		assert(pp < pages + npages);
f0100b2c:	a1 68 59 11 f0       	mov    0xf0115968,%eax
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
f0100b4b:	68 59 2c 10 f0       	push   $0xf0102c59
f0100b50:	68 65 2c 10 f0       	push   $0xf0102c65
f0100b55:	68 8b 02 00 00       	push   $0x28b
f0100b5a:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0100b5f:	e8 27 f5 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100b64:	39 fa                	cmp    %edi,%edx
f0100b66:	72 19                	jb     f0100b81 <check_page_free_list+0x148>
f0100b68:	68 7a 2c 10 f0       	push   $0xf0102c7a
f0100b6d:	68 65 2c 10 f0       	push   $0xf0102c65
f0100b72:	68 8c 02 00 00       	push   $0x28c
f0100b77:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0100b7c:	e8 0a f5 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b81:	89 d0                	mov    %edx,%eax
f0100b83:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b86:	a8 07                	test   $0x7,%al
f0100b88:	74 19                	je     f0100ba3 <check_page_free_list+0x16a>
f0100b8a:	68 58 2e 10 f0       	push   $0xf0102e58
f0100b8f:	68 65 2c 10 f0       	push   $0xf0102c65
f0100b94:	68 8d 02 00 00       	push   $0x28d
f0100b99:	68 3f 2c 10 f0       	push   $0xf0102c3f
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
f0100bad:	68 8e 2c 10 f0       	push   $0xf0102c8e
f0100bb2:	68 65 2c 10 f0       	push   $0xf0102c65
f0100bb7:	68 90 02 00 00       	push   $0x290
f0100bbc:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0100bc1:	e8 c5 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bc6:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bcb:	75 19                	jne    f0100be6 <check_page_free_list+0x1ad>
f0100bcd:	68 9f 2c 10 f0       	push   $0xf0102c9f
f0100bd2:	68 65 2c 10 f0       	push   $0xf0102c65
f0100bd7:	68 91 02 00 00       	push   $0x291
f0100bdc:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0100be1:	e8 a5 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100be6:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100beb:	75 19                	jne    f0100c06 <check_page_free_list+0x1cd>
f0100bed:	68 8c 2e 10 f0       	push   $0xf0102e8c
f0100bf2:	68 65 2c 10 f0       	push   $0xf0102c65
f0100bf7:	68 92 02 00 00       	push   $0x292
f0100bfc:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0100c01:	e8 85 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c06:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c0b:	75 19                	jne    f0100c26 <check_page_free_list+0x1ed>
f0100c0d:	68 b8 2c 10 f0       	push   $0xf0102cb8
f0100c12:	68 65 2c 10 f0       	push   $0xf0102c65
f0100c17:	68 93 02 00 00       	push   $0x293
f0100c1c:	68 3f 2c 10 f0       	push   $0xf0102c3f
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
f0100c38:	68 10 2e 10 f0       	push   $0xf0102e10
f0100c3d:	6a 52                	push   $0x52
f0100c3f:	68 4b 2c 10 f0       	push   $0xf0102c4b
f0100c44:	e8 42 f4 ff ff       	call   f010008b <_panic>
f0100c49:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c4e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c51:	76 1e                	jbe    f0100c71 <check_page_free_list+0x238>
f0100c53:	68 b0 2e 10 f0       	push   $0xf0102eb0
f0100c58:	68 65 2c 10 f0       	push   $0xf0102c65
f0100c5d:	68 94 02 00 00       	push   $0x294
f0100c62:	68 3f 2c 10 f0       	push   $0xf0102c3f
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
f0100c86:	68 d2 2c 10 f0       	push   $0xf0102cd2
f0100c8b:	68 65 2c 10 f0       	push   $0xf0102c65
f0100c90:	68 9c 02 00 00       	push   $0x29c
f0100c95:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0100c9a:	e8 ec f3 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100c9f:	85 db                	test   %ebx,%ebx
f0100ca1:	7f 19                	jg     f0100cbc <check_page_free_list+0x283>
f0100ca3:	68 e4 2c 10 f0       	push   $0xf0102ce4
f0100ca8:	68 65 2c 10 f0       	push   $0xf0102c65
f0100cad:	68 9d 02 00 00       	push   $0x29d
f0100cb2:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0100cb7:	e8 cf f3 ff ff       	call   f010008b <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100cbc:	83 ec 0c             	sub    $0xc,%esp
f0100cbf:	68 f8 2e 10 f0       	push   $0xf0102ef8
f0100cc4:	e8 a2 0a 00 00       	call   f010176b <cprintf>
}
f0100cc9:	eb 29                	jmp    f0100cf4 <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100ccb:	a1 3c 55 11 f0       	mov    0xf011553c,%eax
f0100cd0:	85 c0                	test   %eax,%eax
f0100cd2:	0f 85 8e fd ff ff    	jne    f0100a66 <check_page_free_list+0x2d>
f0100cd8:	e9 72 fd ff ff       	jmp    f0100a4f <check_page_free_list+0x16>
f0100cdd:	83 3d 3c 55 11 f0 00 	cmpl   $0x0,0xf011553c
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
f0100d01:	a1 70 59 11 f0       	mov    0xf0115970,%eax
f0100d06:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100d0c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100d12:	8b 35 40 55 11 f0    	mov    0xf0115540,%esi
f0100d18:	8b 0d 3c 55 11 f0    	mov    0xf011553c,%ecx
f0100d1e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d23:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100d28:	eb 27                	jmp    f0100d51 <page_init+0x55>
		pages[i].pp_ref = 0;
f0100d2a:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100d31:	89 c2                	mov    %eax,%edx
f0100d33:	03 15 70 59 11 f0    	add    0xf0115970,%edx
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
f0100d44:	03 05 70 59 11 f0    	add    0xf0115970,%eax
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
f0100d59:	89 0d 3c 55 11 f0    	mov    %ecx,0xf011553c
f0100d5f:	8b 0d 3c 55 11 f0    	mov    0xf011553c,%ecx
f0100d65:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100d6c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d71:	eb 23                	jmp    f0100d96 <page_init+0x9a>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100d73:	89 c2                	mov    %eax,%edx
f0100d75:	03 15 70 59 11 f0    	add    0xf0115970,%edx
f0100d7b:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100d81:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100d83:	89 c1                	mov    %eax,%ecx
f0100d85:	03 0d 70 59 11 f0    	add    0xf0115970,%ecx
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
f0100da2:	89 0d 3c 55 11 f0    	mov    %ecx,0xf011553c
f0100da8:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100daf:	eb 1a                	jmp    f0100dcb <page_init+0xcf>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100db1:	89 c2                	mov    %eax,%edx
f0100db3:	03 15 70 59 11 f0    	add    0xf0115970,%edx
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
f0100dde:	03 05 70 59 11 f0    	add    0xf0115970,%eax
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
f0100e08:	68 1c 2f 10 f0       	push   $0xf0102f1c
f0100e0d:	68 2e 01 00 00       	push   $0x12e
f0100e12:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0100e17:	e8 6f f2 ff ff       	call   f010008b <_panic>
f0100e1c:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e21:	c1 e8 0c             	shr    $0xc,%eax
f0100e24:	39 c3                	cmp    %eax,%ebx
f0100e26:	72 b4                	jb     f0100ddc <page_init+0xe0>
f0100e28:	8b 0d 3c 55 11 f0    	mov    0xf011553c,%ecx
f0100e2e:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100e35:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e3a:	eb 23                	jmp    f0100e5f <page_init+0x163>
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f0100e3c:	89 c2                	mov    %eax,%edx
f0100e3e:	03 15 70 59 11 f0    	add    0xf0115970,%edx
f0100e44:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100e4a:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100e4c:	89 c1                	mov    %eax,%ecx
f0100e4e:	03 0d 70 59 11 f0    	add    0xf0115970,%ecx
		pages[i].pp_link = 0;
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
f0100e54:	83 c3 01             	add    $0x1,%ebx
f0100e57:	83 c0 08             	add    $0x8,%eax
f0100e5a:	ba 01 00 00 00       	mov    $0x1,%edx
f0100e5f:	3b 1d 68 59 11 f0    	cmp    0xf0115968,%ebx
f0100e65:	72 d5                	jb     f0100e3c <page_init+0x140>
f0100e67:	84 d2                	test   %dl,%dl
f0100e69:	74 06                	je     f0100e71 <page_init+0x175>
f0100e6b:	89 0d 3c 55 11 f0    	mov    %ecx,0xf011553c
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
f0100e7d:	8b 1d 3c 55 11 f0    	mov    0xf011553c,%ebx
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
f0100e97:	2b 05 70 59 11 f0    	sub    0xf0115970,%eax
f0100e9d:	c1 f8 03             	sar    $0x3,%eax
f0100ea0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ea3:	89 c2                	mov    %eax,%edx
f0100ea5:	c1 ea 0c             	shr    $0xc,%edx
f0100ea8:	3b 15 68 59 11 f0    	cmp    0xf0115968,%edx
f0100eae:	72 12                	jb     f0100ec2 <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eb0:	50                   	push   %eax
f0100eb1:	68 10 2e 10 f0       	push   $0xf0102e10
f0100eb6:	6a 52                	push   $0x52
f0100eb8:	68 4b 2c 10 f0       	push   $0xf0102c4b
f0100ebd:	e8 c9 f1 ff ff       	call   f010008b <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f0100ec2:	83 ec 04             	sub    $0x4,%esp
f0100ec5:	68 00 10 00 00       	push   $0x1000
f0100eca:	6a 00                	push   $0x0
f0100ecc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ed1:	50                   	push   %eax
f0100ed2:	e8 58 13 00 00       	call   f010222f <memset>
f0100ed7:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f0100eda:	89 35 3c 55 11 f0    	mov    %esi,0xf011553c

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
f0100efe:	68 40 2f 10 f0       	push   $0xf0102f40
f0100f03:	68 73 01 00 00       	push   $0x173
f0100f08:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0100f0d:	e8 79 f1 ff ff       	call   f010008b <_panic>
	if (pp->pp_ref != 0)
f0100f12:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f17:	74 17                	je     f0100f30 <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0100f19:	83 ec 04             	sub    $0x4,%esp
f0100f1c:	68 68 2f 10 f0       	push   $0xf0102f68
f0100f21:	68 75 01 00 00       	push   $0x175
f0100f26:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0100f2b:	e8 5b f1 ff ff       	call   f010008b <_panic>

	pp->pp_link = page_free_list;
f0100f30:	8b 15 3c 55 11 f0    	mov    0xf011553c,%edx
f0100f36:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f38:	a3 3c 55 11 f0       	mov    %eax,0xf011553c

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
f0100fa0:	2b 15 70 59 11 f0    	sub    0xf0115970,%edx
f0100fa6:	c1 fa 03             	sar    $0x3,%edx
f0100fa9:	c1 e2 0c             	shl    $0xc,%edx
f0100fac:	83 ca 07             	or     $0x7,%edx
f0100faf:	89 13                	mov    %edx,(%ebx)
		new_page->pp_ref = 1;
f0100fb1:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)

	}

	// cprintf("[?] %x, %x\n", pgdir[Page_Directory_Index], PTE_ADDR(pgdir[Page_Directory_Index]));
	
	return KADDR(PTE_ADDR(pgdir[Page_Directory_Index])) + Page_Table_Index;
f0100fb7:	8b 03                	mov    (%ebx),%eax
f0100fb9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fbe:	89 c2                	mov    %eax,%edx
f0100fc0:	c1 ea 0c             	shr    $0xc,%edx
f0100fc3:	3b 15 68 59 11 f0    	cmp    0xf0115968,%edx
f0100fc9:	72 15                	jb     f0100fe0 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fcb:	50                   	push   %eax
f0100fcc:	68 10 2e 10 f0       	push   $0xf0102e10
f0100fd1:	68 bf 01 00 00       	push   $0x1bf
f0100fd6:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0100fdb:	e8 ab f0 ff ff       	call   f010008b <_panic>
f0100fe0:	8d 84 06 00 00 00 f0 	lea    -0x10000000(%esi,%eax,1),%eax
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
	}

	// cprintf("[?] %x, %x\n", pgdir[Page_Directory_Index], PTE_ADDR(pgdir[Page_Directory_Index]));
	
	return KADDR(PTE_ADDR(pgdir[Page_Directory_Index])) + Page_Table_Index;
}
f0100ff5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ff8:	5b                   	pop    %ebx
f0100ff9:	5e                   	pop    %esi
f0100ffa:	5d                   	pop    %ebp
f0100ffb:	c3                   	ret    

f0100ffc <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100ffc:	55                   	push   %ebp
f0100ffd:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100fff:	b8 00 00 00 00       	mov    $0x0,%eax
f0101004:	5d                   	pop    %ebp
f0101005:	c3                   	ret    

f0101006 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101006:	55                   	push   %ebp
f0101007:	89 e5                	mov    %esp,%ebp
f0101009:	53                   	push   %ebx
f010100a:	83 ec 08             	sub    $0x8,%esp
f010100d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in

	// do a page table walk to find real PTE
	pte_t * pte = pgdir_walk(pgdir, va, 0);
f0101010:	6a 00                	push   $0x0
f0101012:	ff 75 0c             	pushl  0xc(%ebp)
f0101015:	ff 75 08             	pushl  0x8(%ebp)
f0101018:	e8 49 ff ff ff       	call   f0100f66 <pgdir_walk>

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
f010101d:	83 c4 10             	add    $0x10,%esp
f0101020:	85 c0                	test   %eax,%eax
f0101022:	74 37                	je     f010105b <page_lookup+0x55>
f0101024:	83 38 00             	cmpl   $0x0,(%eax)
f0101027:	74 39                	je     f0101062 <page_lookup+0x5c>
		return NULL;
	
	// store pte
	if (pte_store != 0)
f0101029:	85 db                	test   %ebx,%ebx
f010102b:	74 02                	je     f010102f <page_lookup+0x29>
		*pte_store = pte;
f010102d:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010102f:	8b 00                	mov    (%eax),%eax
f0101031:	c1 e8 0c             	shr    $0xc,%eax
f0101034:	3b 05 68 59 11 f0    	cmp    0xf0115968,%eax
f010103a:	72 14                	jb     f0101050 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f010103c:	83 ec 04             	sub    $0x4,%esp
f010103f:	68 ac 2f 10 f0       	push   $0xf0102fac
f0101044:	6a 4b                	push   $0x4b
f0101046:	68 4b 2c 10 f0       	push   $0xf0102c4b
f010104b:	e8 3b f0 ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0101050:	8b 15 70 59 11 f0    	mov    0xf0115970,%edx
f0101056:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte)) ;
f0101059:	eb 0c                	jmp    f0101067 <page_lookup+0x61>
	// do a page table walk to find real PTE
	pte_t * pte = pgdir_walk(pgdir, va, 0);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
		return NULL;
f010105b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101060:	eb 05                	jmp    f0101067 <page_lookup+0x61>
f0101062:	b8 00 00 00 00       	mov    $0x0,%eax
	// store pte
	if (pte_store != 0)
		*pte_store = pte;

	return pa2page(PTE_ADDR(*pte)) ;
}
f0101067:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010106a:	c9                   	leave  
f010106b:	c3                   	ret    

f010106c <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010106c:	55                   	push   %ebp
f010106d:	89 e5                	mov    %esp,%ebp
f010106f:	53                   	push   %ebx
f0101070:	83 ec 08             	sub    $0x8,%esp
f0101073:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	pte_t **pte_store = NULL;
	struct PageInfo * pp = page_lookup(pgdir, va, pte_store);
f0101076:	6a 00                	push   $0x0
f0101078:	53                   	push   %ebx
f0101079:	ff 75 08             	pushl  0x8(%ebp)
f010107c:	e8 85 ff ff ff       	call   f0101006 <page_lookup>

	// if not present, silently return
	if (pp == NULL)
f0101081:	83 c4 10             	add    $0x10,%esp
f0101084:	85 c0                	test   %eax,%eax
f0101086:	74 1a                	je     f01010a2 <page_remove+0x36>
		return;
	
	// decrement ref count, and if reaches 0, free it
	page_decref(pp);
f0101088:	83 ec 0c             	sub    $0xc,%esp
f010108b:	50                   	push   %eax
f010108c:	e8 ae fe ff ff       	call   f0100f3f <page_decref>

	// null the real PTE pointer 
	**pte_store = 0;
f0101091:	a1 00 00 00 00       	mov    0x0,%eax
f0101096:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010109c:	0f 01 3b             	invlpg (%ebx)
f010109f:	83 c4 10             	add    $0x10,%esp

	// tlb invalidate
	tlb_invalidate(pgdir, va);

}
f01010a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010a5:	c9                   	leave  
f01010a6:	c3                   	ret    

f01010a7 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01010a7:	55                   	push   %ebp
f01010a8:	89 e5                	mov    %esp,%ebp
f01010aa:	57                   	push   %edi
f01010ab:	56                   	push   %esi
f01010ac:	53                   	push   %ebx
f01010ad:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01010b0:	b8 15 00 00 00       	mov    $0x15,%eax
f01010b5:	e8 9f f8 ff ff       	call   f0100959 <nvram_read>
f01010ba:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01010bc:	b8 17 00 00 00       	mov    $0x17,%eax
f01010c1:	e8 93 f8 ff ff       	call   f0100959 <nvram_read>
f01010c6:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01010c8:	b8 34 00 00 00       	mov    $0x34,%eax
f01010cd:	e8 87 f8 ff ff       	call   f0100959 <nvram_read>
f01010d2:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01010d5:	85 c0                	test   %eax,%eax
f01010d7:	74 07                	je     f01010e0 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01010d9:	05 00 40 00 00       	add    $0x4000,%eax
f01010de:	eb 0b                	jmp    f01010eb <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01010e0:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01010e6:	85 f6                	test   %esi,%esi
f01010e8:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01010eb:	89 c2                	mov    %eax,%edx
f01010ed:	c1 ea 02             	shr    $0x2,%edx
f01010f0:	89 15 68 59 11 f0    	mov    %edx,0xf0115968
	npages_basemem = basemem / (PGSIZE / 1024);
f01010f6:	89 da                	mov    %ebx,%edx
f01010f8:	c1 ea 02             	shr    $0x2,%edx
f01010fb:	89 15 40 55 11 f0    	mov    %edx,0xf0115540

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101101:	89 c2                	mov    %eax,%edx
f0101103:	29 da                	sub    %ebx,%edx
f0101105:	52                   	push   %edx
f0101106:	53                   	push   %ebx
f0101107:	50                   	push   %eax
f0101108:	68 cc 2f 10 f0       	push   $0xf0102fcc
f010110d:	e8 59 06 00 00       	call   f010176b <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101112:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101117:	e8 66 f8 ff ff       	call   f0100982 <boot_alloc>
f010111c:	a3 6c 59 11 f0       	mov    %eax,0xf011596c
	memset(kern_pgdir, 0, PGSIZE);
f0101121:	83 c4 0c             	add    $0xc,%esp
f0101124:	68 00 10 00 00       	push   $0x1000
f0101129:	6a 00                	push   $0x0
f010112b:	50                   	push   %eax
f010112c:	e8 fe 10 00 00       	call   f010222f <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101131:	a1 6c 59 11 f0       	mov    0xf011596c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101136:	83 c4 10             	add    $0x10,%esp
f0101139:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010113e:	77 15                	ja     f0101155 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101140:	50                   	push   %eax
f0101141:	68 1c 2f 10 f0       	push   $0xf0102f1c
f0101146:	68 96 00 00 00       	push   $0x96
f010114b:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0101150:	e8 36 ef ff ff       	call   f010008b <_panic>
f0101155:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010115b:	83 ca 05             	or     $0x5,%edx
f010115e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f0101164:	a1 68 59 11 f0       	mov    0xf0115968,%eax
f0101169:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f0101170:	89 d8                	mov    %ebx,%eax
f0101172:	e8 0b f8 ff ff       	call   f0100982 <boot_alloc>
f0101177:	a3 70 59 11 f0       	mov    %eax,0xf0115970
	memset(pages, 0, n);
f010117c:	83 ec 04             	sub    $0x4,%esp
f010117f:	53                   	push   %ebx
f0101180:	6a 00                	push   $0x0
f0101182:	50                   	push   %eax
f0101183:	e8 a7 10 00 00       	call   f010222f <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101188:	e8 6f fb ff ff       	call   f0100cfc <page_init>

	check_page_free_list(1);
f010118d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101192:	e8 a2 f8 ff ff       	call   f0100a39 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101197:	83 c4 10             	add    $0x10,%esp
f010119a:	83 3d 70 59 11 f0 00 	cmpl   $0x0,0xf0115970
f01011a1:	75 17                	jne    f01011ba <mem_init+0x113>
		panic("'pages' is a null pointer!");
f01011a3:	83 ec 04             	sub    $0x4,%esp
f01011a6:	68 f5 2c 10 f0       	push   $0xf0102cf5
f01011ab:	68 b0 02 00 00       	push   $0x2b0
f01011b0:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01011b5:	e8 d1 ee ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011ba:	a1 3c 55 11 f0       	mov    0xf011553c,%eax
f01011bf:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011c4:	eb 05                	jmp    f01011cb <mem_init+0x124>
		++nfree;
f01011c6:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011c9:	8b 00                	mov    (%eax),%eax
f01011cb:	85 c0                	test   %eax,%eax
f01011cd:	75 f7                	jne    f01011c6 <mem_init+0x11f>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01011cf:	83 ec 0c             	sub    $0xc,%esp
f01011d2:	6a 00                	push   $0x0
f01011d4:	e8 9f fc ff ff       	call   f0100e78 <page_alloc>
f01011d9:	89 c7                	mov    %eax,%edi
f01011db:	83 c4 10             	add    $0x10,%esp
f01011de:	85 c0                	test   %eax,%eax
f01011e0:	75 19                	jne    f01011fb <mem_init+0x154>
f01011e2:	68 10 2d 10 f0       	push   $0xf0102d10
f01011e7:	68 65 2c 10 f0       	push   $0xf0102c65
f01011ec:	68 b8 02 00 00       	push   $0x2b8
f01011f1:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01011f6:	e8 90 ee ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01011fb:	83 ec 0c             	sub    $0xc,%esp
f01011fe:	6a 00                	push   $0x0
f0101200:	e8 73 fc ff ff       	call   f0100e78 <page_alloc>
f0101205:	89 c6                	mov    %eax,%esi
f0101207:	83 c4 10             	add    $0x10,%esp
f010120a:	85 c0                	test   %eax,%eax
f010120c:	75 19                	jne    f0101227 <mem_init+0x180>
f010120e:	68 26 2d 10 f0       	push   $0xf0102d26
f0101213:	68 65 2c 10 f0       	push   $0xf0102c65
f0101218:	68 b9 02 00 00       	push   $0x2b9
f010121d:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0101222:	e8 64 ee ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101227:	83 ec 0c             	sub    $0xc,%esp
f010122a:	6a 00                	push   $0x0
f010122c:	e8 47 fc ff ff       	call   f0100e78 <page_alloc>
f0101231:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101234:	83 c4 10             	add    $0x10,%esp
f0101237:	85 c0                	test   %eax,%eax
f0101239:	75 19                	jne    f0101254 <mem_init+0x1ad>
f010123b:	68 3c 2d 10 f0       	push   $0xf0102d3c
f0101240:	68 65 2c 10 f0       	push   $0xf0102c65
f0101245:	68 ba 02 00 00       	push   $0x2ba
f010124a:	68 3f 2c 10 f0       	push   $0xf0102c3f
f010124f:	e8 37 ee ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101254:	39 f7                	cmp    %esi,%edi
f0101256:	75 19                	jne    f0101271 <mem_init+0x1ca>
f0101258:	68 52 2d 10 f0       	push   $0xf0102d52
f010125d:	68 65 2c 10 f0       	push   $0xf0102c65
f0101262:	68 bd 02 00 00       	push   $0x2bd
f0101267:	68 3f 2c 10 f0       	push   $0xf0102c3f
f010126c:	e8 1a ee ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101271:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101274:	39 c7                	cmp    %eax,%edi
f0101276:	74 04                	je     f010127c <mem_init+0x1d5>
f0101278:	39 c6                	cmp    %eax,%esi
f010127a:	75 19                	jne    f0101295 <mem_init+0x1ee>
f010127c:	68 08 30 10 f0       	push   $0xf0103008
f0101281:	68 65 2c 10 f0       	push   $0xf0102c65
f0101286:	68 be 02 00 00       	push   $0x2be
f010128b:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0101290:	e8 f6 ed ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101295:	8b 0d 70 59 11 f0    	mov    0xf0115970,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010129b:	8b 15 68 59 11 f0    	mov    0xf0115968,%edx
f01012a1:	c1 e2 0c             	shl    $0xc,%edx
f01012a4:	89 f8                	mov    %edi,%eax
f01012a6:	29 c8                	sub    %ecx,%eax
f01012a8:	c1 f8 03             	sar    $0x3,%eax
f01012ab:	c1 e0 0c             	shl    $0xc,%eax
f01012ae:	39 d0                	cmp    %edx,%eax
f01012b0:	72 19                	jb     f01012cb <mem_init+0x224>
f01012b2:	68 64 2d 10 f0       	push   $0xf0102d64
f01012b7:	68 65 2c 10 f0       	push   $0xf0102c65
f01012bc:	68 bf 02 00 00       	push   $0x2bf
f01012c1:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01012c6:	e8 c0 ed ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01012cb:	89 f0                	mov    %esi,%eax
f01012cd:	29 c8                	sub    %ecx,%eax
f01012cf:	c1 f8 03             	sar    $0x3,%eax
f01012d2:	c1 e0 0c             	shl    $0xc,%eax
f01012d5:	39 c2                	cmp    %eax,%edx
f01012d7:	77 19                	ja     f01012f2 <mem_init+0x24b>
f01012d9:	68 81 2d 10 f0       	push   $0xf0102d81
f01012de:	68 65 2c 10 f0       	push   $0xf0102c65
f01012e3:	68 c0 02 00 00       	push   $0x2c0
f01012e8:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01012ed:	e8 99 ed ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01012f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012f5:	29 c8                	sub    %ecx,%eax
f01012f7:	c1 f8 03             	sar    $0x3,%eax
f01012fa:	c1 e0 0c             	shl    $0xc,%eax
f01012fd:	39 c2                	cmp    %eax,%edx
f01012ff:	77 19                	ja     f010131a <mem_init+0x273>
f0101301:	68 9e 2d 10 f0       	push   $0xf0102d9e
f0101306:	68 65 2c 10 f0       	push   $0xf0102c65
f010130b:	68 c1 02 00 00       	push   $0x2c1
f0101310:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0101315:	e8 71 ed ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010131a:	a1 3c 55 11 f0       	mov    0xf011553c,%eax
f010131f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101322:	c7 05 3c 55 11 f0 00 	movl   $0x0,0xf011553c
f0101329:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010132c:	83 ec 0c             	sub    $0xc,%esp
f010132f:	6a 00                	push   $0x0
f0101331:	e8 42 fb ff ff       	call   f0100e78 <page_alloc>
f0101336:	83 c4 10             	add    $0x10,%esp
f0101339:	85 c0                	test   %eax,%eax
f010133b:	74 19                	je     f0101356 <mem_init+0x2af>
f010133d:	68 bb 2d 10 f0       	push   $0xf0102dbb
f0101342:	68 65 2c 10 f0       	push   $0xf0102c65
f0101347:	68 c8 02 00 00       	push   $0x2c8
f010134c:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0101351:	e8 35 ed ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101356:	83 ec 0c             	sub    $0xc,%esp
f0101359:	57                   	push   %edi
f010135a:	e8 8a fb ff ff       	call   f0100ee9 <page_free>
	page_free(pp1);
f010135f:	89 34 24             	mov    %esi,(%esp)
f0101362:	e8 82 fb ff ff       	call   f0100ee9 <page_free>
	page_free(pp2);
f0101367:	83 c4 04             	add    $0x4,%esp
f010136a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010136d:	e8 77 fb ff ff       	call   f0100ee9 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101372:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101379:	e8 fa fa ff ff       	call   f0100e78 <page_alloc>
f010137e:	89 c6                	mov    %eax,%esi
f0101380:	83 c4 10             	add    $0x10,%esp
f0101383:	85 c0                	test   %eax,%eax
f0101385:	75 19                	jne    f01013a0 <mem_init+0x2f9>
f0101387:	68 10 2d 10 f0       	push   $0xf0102d10
f010138c:	68 65 2c 10 f0       	push   $0xf0102c65
f0101391:	68 cf 02 00 00       	push   $0x2cf
f0101396:	68 3f 2c 10 f0       	push   $0xf0102c3f
f010139b:	e8 eb ec ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01013a0:	83 ec 0c             	sub    $0xc,%esp
f01013a3:	6a 00                	push   $0x0
f01013a5:	e8 ce fa ff ff       	call   f0100e78 <page_alloc>
f01013aa:	89 c7                	mov    %eax,%edi
f01013ac:	83 c4 10             	add    $0x10,%esp
f01013af:	85 c0                	test   %eax,%eax
f01013b1:	75 19                	jne    f01013cc <mem_init+0x325>
f01013b3:	68 26 2d 10 f0       	push   $0xf0102d26
f01013b8:	68 65 2c 10 f0       	push   $0xf0102c65
f01013bd:	68 d0 02 00 00       	push   $0x2d0
f01013c2:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01013c7:	e8 bf ec ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01013cc:	83 ec 0c             	sub    $0xc,%esp
f01013cf:	6a 00                	push   $0x0
f01013d1:	e8 a2 fa ff ff       	call   f0100e78 <page_alloc>
f01013d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013d9:	83 c4 10             	add    $0x10,%esp
f01013dc:	85 c0                	test   %eax,%eax
f01013de:	75 19                	jne    f01013f9 <mem_init+0x352>
f01013e0:	68 3c 2d 10 f0       	push   $0xf0102d3c
f01013e5:	68 65 2c 10 f0       	push   $0xf0102c65
f01013ea:	68 d1 02 00 00       	push   $0x2d1
f01013ef:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01013f4:	e8 92 ec ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013f9:	39 fe                	cmp    %edi,%esi
f01013fb:	75 19                	jne    f0101416 <mem_init+0x36f>
f01013fd:	68 52 2d 10 f0       	push   $0xf0102d52
f0101402:	68 65 2c 10 f0       	push   $0xf0102c65
f0101407:	68 d3 02 00 00       	push   $0x2d3
f010140c:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0101411:	e8 75 ec ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101416:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101419:	39 c7                	cmp    %eax,%edi
f010141b:	74 04                	je     f0101421 <mem_init+0x37a>
f010141d:	39 c6                	cmp    %eax,%esi
f010141f:	75 19                	jne    f010143a <mem_init+0x393>
f0101421:	68 08 30 10 f0       	push   $0xf0103008
f0101426:	68 65 2c 10 f0       	push   $0xf0102c65
f010142b:	68 d4 02 00 00       	push   $0x2d4
f0101430:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0101435:	e8 51 ec ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f010143a:	83 ec 0c             	sub    $0xc,%esp
f010143d:	6a 00                	push   $0x0
f010143f:	e8 34 fa ff ff       	call   f0100e78 <page_alloc>
f0101444:	83 c4 10             	add    $0x10,%esp
f0101447:	85 c0                	test   %eax,%eax
f0101449:	74 19                	je     f0101464 <mem_init+0x3bd>
f010144b:	68 bb 2d 10 f0       	push   $0xf0102dbb
f0101450:	68 65 2c 10 f0       	push   $0xf0102c65
f0101455:	68 d5 02 00 00       	push   $0x2d5
f010145a:	68 3f 2c 10 f0       	push   $0xf0102c3f
f010145f:	e8 27 ec ff ff       	call   f010008b <_panic>
f0101464:	89 f0                	mov    %esi,%eax
f0101466:	2b 05 70 59 11 f0    	sub    0xf0115970,%eax
f010146c:	c1 f8 03             	sar    $0x3,%eax
f010146f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101472:	89 c2                	mov    %eax,%edx
f0101474:	c1 ea 0c             	shr    $0xc,%edx
f0101477:	3b 15 68 59 11 f0    	cmp    0xf0115968,%edx
f010147d:	72 12                	jb     f0101491 <mem_init+0x3ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010147f:	50                   	push   %eax
f0101480:	68 10 2e 10 f0       	push   $0xf0102e10
f0101485:	6a 52                	push   $0x52
f0101487:	68 4b 2c 10 f0       	push   $0xf0102c4b
f010148c:	e8 fa eb ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101491:	83 ec 04             	sub    $0x4,%esp
f0101494:	68 00 10 00 00       	push   $0x1000
f0101499:	6a 01                	push   $0x1
f010149b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01014a0:	50                   	push   %eax
f01014a1:	e8 89 0d 00 00       	call   f010222f <memset>
	page_free(pp0);
f01014a6:	89 34 24             	mov    %esi,(%esp)
f01014a9:	e8 3b fa ff ff       	call   f0100ee9 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01014ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01014b5:	e8 be f9 ff ff       	call   f0100e78 <page_alloc>
f01014ba:	83 c4 10             	add    $0x10,%esp
f01014bd:	85 c0                	test   %eax,%eax
f01014bf:	75 19                	jne    f01014da <mem_init+0x433>
f01014c1:	68 ca 2d 10 f0       	push   $0xf0102dca
f01014c6:	68 65 2c 10 f0       	push   $0xf0102c65
f01014cb:	68 da 02 00 00       	push   $0x2da
f01014d0:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01014d5:	e8 b1 eb ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f01014da:	39 c6                	cmp    %eax,%esi
f01014dc:	74 19                	je     f01014f7 <mem_init+0x450>
f01014de:	68 e8 2d 10 f0       	push   $0xf0102de8
f01014e3:	68 65 2c 10 f0       	push   $0xf0102c65
f01014e8:	68 db 02 00 00       	push   $0x2db
f01014ed:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01014f2:	e8 94 eb ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014f7:	89 f0                	mov    %esi,%eax
f01014f9:	2b 05 70 59 11 f0    	sub    0xf0115970,%eax
f01014ff:	c1 f8 03             	sar    $0x3,%eax
f0101502:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101505:	89 c2                	mov    %eax,%edx
f0101507:	c1 ea 0c             	shr    $0xc,%edx
f010150a:	3b 15 68 59 11 f0    	cmp    0xf0115968,%edx
f0101510:	72 12                	jb     f0101524 <mem_init+0x47d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101512:	50                   	push   %eax
f0101513:	68 10 2e 10 f0       	push   $0xf0102e10
f0101518:	6a 52                	push   $0x52
f010151a:	68 4b 2c 10 f0       	push   $0xf0102c4b
f010151f:	e8 67 eb ff ff       	call   f010008b <_panic>
f0101524:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010152a:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
f0101530:	80 38 00             	cmpb   $0x0,(%eax)
f0101533:	74 19                	je     f010154e <mem_init+0x4a7>
f0101535:	68 f8 2d 10 f0       	push   $0xf0102df8
f010153a:	68 65 2c 10 f0       	push   $0xf0102c65
f010153f:	68 df 02 00 00       	push   $0x2df
f0101544:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0101549:	e8 3d eb ff ff       	call   f010008b <_panic>
f010154e:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
f0101551:	39 d0                	cmp    %edx,%eax
f0101553:	75 db                	jne    f0101530 <mem_init+0x489>
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
	}

	// give free list back
	page_free_list = fl;
f0101555:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101558:	a3 3c 55 11 f0       	mov    %eax,0xf011553c

	// free the pages we took
	page_free(pp0);
f010155d:	83 ec 0c             	sub    $0xc,%esp
f0101560:	56                   	push   %esi
f0101561:	e8 83 f9 ff ff       	call   f0100ee9 <page_free>
	page_free(pp1);
f0101566:	89 3c 24             	mov    %edi,(%esp)
f0101569:	e8 7b f9 ff ff       	call   f0100ee9 <page_free>
	page_free(pp2);
f010156e:	83 c4 04             	add    $0x4,%esp
f0101571:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101574:	e8 70 f9 ff ff       	call   f0100ee9 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101579:	a1 3c 55 11 f0       	mov    0xf011553c,%eax
f010157e:	83 c4 10             	add    $0x10,%esp
f0101581:	eb 05                	jmp    f0101588 <mem_init+0x4e1>
		--nfree;
f0101583:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101586:	8b 00                	mov    (%eax),%eax
f0101588:	85 c0                	test   %eax,%eax
f010158a:	75 f7                	jne    f0101583 <mem_init+0x4dc>
		--nfree;
	assert(nfree == 0);
f010158c:	85 db                	test   %ebx,%ebx
f010158e:	74 19                	je     f01015a9 <mem_init+0x502>
f0101590:	68 02 2e 10 f0       	push   $0xf0102e02
f0101595:	68 65 2c 10 f0       	push   $0xf0102c65
f010159a:	68 ed 02 00 00       	push   $0x2ed
f010159f:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01015a4:	e8 e2 ea ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01015a9:	83 ec 0c             	sub    $0xc,%esp
f01015ac:	68 28 30 10 f0       	push   $0xf0103028
f01015b1:	e8 b5 01 00 00       	call   f010176b <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015bd:	e8 b6 f8 ff ff       	call   f0100e78 <page_alloc>
f01015c2:	89 c3                	mov    %eax,%ebx
f01015c4:	83 c4 10             	add    $0x10,%esp
f01015c7:	85 c0                	test   %eax,%eax
f01015c9:	75 19                	jne    f01015e4 <mem_init+0x53d>
f01015cb:	68 10 2d 10 f0       	push   $0xf0102d10
f01015d0:	68 65 2c 10 f0       	push   $0xf0102c65
f01015d5:	68 46 03 00 00       	push   $0x346
f01015da:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01015df:	e8 a7 ea ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01015e4:	83 ec 0c             	sub    $0xc,%esp
f01015e7:	6a 00                	push   $0x0
f01015e9:	e8 8a f8 ff ff       	call   f0100e78 <page_alloc>
f01015ee:	89 c6                	mov    %eax,%esi
f01015f0:	83 c4 10             	add    $0x10,%esp
f01015f3:	85 c0                	test   %eax,%eax
f01015f5:	75 19                	jne    f0101610 <mem_init+0x569>
f01015f7:	68 26 2d 10 f0       	push   $0xf0102d26
f01015fc:	68 65 2c 10 f0       	push   $0xf0102c65
f0101601:	68 47 03 00 00       	push   $0x347
f0101606:	68 3f 2c 10 f0       	push   $0xf0102c3f
f010160b:	e8 7b ea ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101610:	83 ec 0c             	sub    $0xc,%esp
f0101613:	6a 00                	push   $0x0
f0101615:	e8 5e f8 ff ff       	call   f0100e78 <page_alloc>
f010161a:	83 c4 10             	add    $0x10,%esp
f010161d:	85 c0                	test   %eax,%eax
f010161f:	75 19                	jne    f010163a <mem_init+0x593>
f0101621:	68 3c 2d 10 f0       	push   $0xf0102d3c
f0101626:	68 65 2c 10 f0       	push   $0xf0102c65
f010162b:	68 48 03 00 00       	push   $0x348
f0101630:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0101635:	e8 51 ea ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010163a:	39 f3                	cmp    %esi,%ebx
f010163c:	75 19                	jne    f0101657 <mem_init+0x5b0>
f010163e:	68 52 2d 10 f0       	push   $0xf0102d52
f0101643:	68 65 2c 10 f0       	push   $0xf0102c65
f0101648:	68 4b 03 00 00       	push   $0x34b
f010164d:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0101652:	e8 34 ea ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101657:	39 c6                	cmp    %eax,%esi
f0101659:	74 04                	je     f010165f <mem_init+0x5b8>
f010165b:	39 c3                	cmp    %eax,%ebx
f010165d:	75 19                	jne    f0101678 <mem_init+0x5d1>
f010165f:	68 08 30 10 f0       	push   $0xf0103008
f0101664:	68 65 2c 10 f0       	push   $0xf0102c65
f0101669:	68 4c 03 00 00       	push   $0x34c
f010166e:	68 3f 2c 10 f0       	push   $0xf0102c3f
f0101673:	e8 13 ea ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;
f0101678:	c7 05 3c 55 11 f0 00 	movl   $0x0,0xf011553c
f010167f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101682:	83 ec 0c             	sub    $0xc,%esp
f0101685:	6a 00                	push   $0x0
f0101687:	e8 ec f7 ff ff       	call   f0100e78 <page_alloc>
f010168c:	83 c4 10             	add    $0x10,%esp
f010168f:	85 c0                	test   %eax,%eax
f0101691:	74 19                	je     f01016ac <mem_init+0x605>
f0101693:	68 bb 2d 10 f0       	push   $0xf0102dbb
f0101698:	68 65 2c 10 f0       	push   $0xf0102c65
f010169d:	68 53 03 00 00       	push   $0x353
f01016a2:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01016a7:	e8 df e9 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01016ac:	83 ec 04             	sub    $0x4,%esp
f01016af:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01016b2:	50                   	push   %eax
f01016b3:	6a 00                	push   $0x0
f01016b5:	ff 35 6c 59 11 f0    	pushl  0xf011596c
f01016bb:	e8 46 f9 ff ff       	call   f0101006 <page_lookup>
f01016c0:	83 c4 10             	add    $0x10,%esp
f01016c3:	85 c0                	test   %eax,%eax
f01016c5:	74 19                	je     f01016e0 <mem_init+0x639>
f01016c7:	68 48 30 10 f0       	push   $0xf0103048
f01016cc:	68 65 2c 10 f0       	push   $0xf0102c65
f01016d1:	68 56 03 00 00       	push   $0x356
f01016d6:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01016db:	e8 ab e9 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01016e0:	68 80 30 10 f0       	push   $0xf0103080
f01016e5:	68 65 2c 10 f0       	push   $0xf0102c65
f01016ea:	68 59 03 00 00       	push   $0x359
f01016ef:	68 3f 2c 10 f0       	push   $0xf0102c3f
f01016f4:	e8 92 e9 ff ff       	call   f010008b <_panic>

f01016f9 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01016f9:	55                   	push   %ebp
f01016fa:	89 e5                	mov    %esp,%ebp
f01016fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016ff:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101702:	5d                   	pop    %ebp
f0101703:	c3                   	ret    

f0101704 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0101704:	55                   	push   %ebp
f0101705:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101707:	ba 70 00 00 00       	mov    $0x70,%edx
f010170c:	8b 45 08             	mov    0x8(%ebp),%eax
f010170f:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0101710:	ba 71 00 00 00       	mov    $0x71,%edx
f0101715:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0101716:	0f b6 c0             	movzbl %al,%eax
}
f0101719:	5d                   	pop    %ebp
f010171a:	c3                   	ret    

f010171b <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010171b:	55                   	push   %ebp
f010171c:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010171e:	ba 70 00 00 00       	mov    $0x70,%edx
f0101723:	8b 45 08             	mov    0x8(%ebp),%eax
f0101726:	ee                   	out    %al,(%dx)
f0101727:	ba 71 00 00 00       	mov    $0x71,%edx
f010172c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010172f:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0101730:	5d                   	pop    %ebp
f0101731:	c3                   	ret    

f0101732 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0101732:	55                   	push   %ebp
f0101733:	89 e5                	mov    %esp,%ebp
f0101735:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0101738:	ff 75 08             	pushl  0x8(%ebp)
f010173b:	e8 c0 ee ff ff       	call   f0100600 <cputchar>
	*cnt++;
}
f0101740:	83 c4 10             	add    $0x10,%esp
f0101743:	c9                   	leave  
f0101744:	c3                   	ret    

f0101745 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0101745:	55                   	push   %ebp
f0101746:	89 e5                	mov    %esp,%ebp
f0101748:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010174b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0101752:	ff 75 0c             	pushl  0xc(%ebp)
f0101755:	ff 75 08             	pushl  0x8(%ebp)
f0101758:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010175b:	50                   	push   %eax
f010175c:	68 32 17 10 f0       	push   $0xf0101732
f0101761:	e8 5d 04 00 00       	call   f0101bc3 <vprintfmt>
	return cnt;
}
f0101766:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101769:	c9                   	leave  
f010176a:	c3                   	ret    

f010176b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010176b:	55                   	push   %ebp
f010176c:	89 e5                	mov    %esp,%ebp
f010176e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0101771:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0101774:	50                   	push   %eax
f0101775:	ff 75 08             	pushl  0x8(%ebp)
f0101778:	e8 c8 ff ff ff       	call   f0101745 <vcprintf>
	va_end(ap);

	return cnt;
}
f010177d:	c9                   	leave  
f010177e:	c3                   	ret    

f010177f <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010177f:	55                   	push   %ebp
f0101780:	89 e5                	mov    %esp,%ebp
f0101782:	57                   	push   %edi
f0101783:	56                   	push   %esi
f0101784:	53                   	push   %ebx
f0101785:	83 ec 14             	sub    $0x14,%esp
f0101788:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010178b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010178e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101791:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0101794:	8b 1a                	mov    (%edx),%ebx
f0101796:	8b 01                	mov    (%ecx),%eax
f0101798:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010179b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01017a2:	eb 7f                	jmp    f0101823 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01017a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01017a7:	01 d8                	add    %ebx,%eax
f01017a9:	89 c6                	mov    %eax,%esi
f01017ab:	c1 ee 1f             	shr    $0x1f,%esi
f01017ae:	01 c6                	add    %eax,%esi
f01017b0:	d1 fe                	sar    %esi
f01017b2:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01017b5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01017b8:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01017bb:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01017bd:	eb 03                	jmp    f01017c2 <stab_binsearch+0x43>
			m--;
f01017bf:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01017c2:	39 c3                	cmp    %eax,%ebx
f01017c4:	7f 0d                	jg     f01017d3 <stab_binsearch+0x54>
f01017c6:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01017ca:	83 ea 0c             	sub    $0xc,%edx
f01017cd:	39 f9                	cmp    %edi,%ecx
f01017cf:	75 ee                	jne    f01017bf <stab_binsearch+0x40>
f01017d1:	eb 05                	jmp    f01017d8 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01017d3:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01017d6:	eb 4b                	jmp    f0101823 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01017d8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01017db:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01017de:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01017e2:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01017e5:	76 11                	jbe    f01017f8 <stab_binsearch+0x79>
			*region_left = m;
f01017e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01017ea:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01017ec:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01017ef:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01017f6:	eb 2b                	jmp    f0101823 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01017f8:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01017fb:	73 14                	jae    f0101811 <stab_binsearch+0x92>
			*region_right = m - 1;
f01017fd:	83 e8 01             	sub    $0x1,%eax
f0101800:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101803:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101806:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101808:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010180f:	eb 12                	jmp    f0101823 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0101811:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101814:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0101816:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010181a:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010181c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0101823:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0101826:	0f 8e 78 ff ff ff    	jle    f01017a4 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010182c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0101830:	75 0f                	jne    f0101841 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0101832:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101835:	8b 00                	mov    (%eax),%eax
f0101837:	83 e8 01             	sub    $0x1,%eax
f010183a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010183d:	89 06                	mov    %eax,(%esi)
f010183f:	eb 2c                	jmp    f010186d <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101841:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101844:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0101846:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101849:	8b 0e                	mov    (%esi),%ecx
f010184b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010184e:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0101851:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101854:	eb 03                	jmp    f0101859 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0101856:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101859:	39 c8                	cmp    %ecx,%eax
f010185b:	7e 0b                	jle    f0101868 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010185d:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0101861:	83 ea 0c             	sub    $0xc,%edx
f0101864:	39 df                	cmp    %ebx,%edi
f0101866:	75 ee                	jne    f0101856 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0101868:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010186b:	89 06                	mov    %eax,(%esi)
	}
}
f010186d:	83 c4 14             	add    $0x14,%esp
f0101870:	5b                   	pop    %ebx
f0101871:	5e                   	pop    %esi
f0101872:	5f                   	pop    %edi
f0101873:	5d                   	pop    %ebp
f0101874:	c3                   	ret    

f0101875 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0101875:	55                   	push   %ebp
f0101876:	89 e5                	mov    %esp,%ebp
f0101878:	57                   	push   %edi
f0101879:	56                   	push   %esi
f010187a:	53                   	push   %ebx
f010187b:	83 ec 3c             	sub    $0x3c,%esp
f010187e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101881:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0101884:	c7 03 b0 30 10 f0    	movl   $0xf01030b0,(%ebx)
	info->eip_line = 0;
f010188a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0101891:	c7 43 08 b0 30 10 f0 	movl   $0xf01030b0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0101898:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010189f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01018a2:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01018a9:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01018af:	76 11                	jbe    f01018c2 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01018b1:	b8 92 a0 10 f0       	mov    $0xf010a092,%eax
f01018b6:	3d b9 82 10 f0       	cmp    $0xf01082b9,%eax
f01018bb:	77 19                	ja     f01018d6 <debuginfo_eip+0x61>
f01018bd:	e9 b5 01 00 00       	jmp    f0101a77 <debuginfo_eip+0x202>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f01018c2:	83 ec 04             	sub    $0x4,%esp
f01018c5:	68 ba 30 10 f0       	push   $0xf01030ba
f01018ca:	6a 7f                	push   $0x7f
f01018cc:	68 c7 30 10 f0       	push   $0xf01030c7
f01018d1:	e8 b5 e7 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01018d6:	80 3d 91 a0 10 f0 00 	cmpb   $0x0,0xf010a091
f01018dd:	0f 85 9b 01 00 00    	jne    f0101a7e <debuginfo_eip+0x209>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01018e3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01018ea:	b8 b8 82 10 f0       	mov    $0xf01082b8,%eax
f01018ef:	2d e4 32 10 f0       	sub    $0xf01032e4,%eax
f01018f4:	c1 f8 02             	sar    $0x2,%eax
f01018f7:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01018fd:	83 e8 01             	sub    $0x1,%eax
f0101900:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0101903:	83 ec 08             	sub    $0x8,%esp
f0101906:	56                   	push   %esi
f0101907:	6a 64                	push   $0x64
f0101909:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010190c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010190f:	b8 e4 32 10 f0       	mov    $0xf01032e4,%eax
f0101914:	e8 66 fe ff ff       	call   f010177f <stab_binsearch>
	if (lfile == 0)
f0101919:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010191c:	83 c4 10             	add    $0x10,%esp
f010191f:	85 c0                	test   %eax,%eax
f0101921:	0f 84 5e 01 00 00    	je     f0101a85 <debuginfo_eip+0x210>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0101927:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010192a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010192d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0101930:	83 ec 08             	sub    $0x8,%esp
f0101933:	56                   	push   %esi
f0101934:	6a 24                	push   $0x24
f0101936:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0101939:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010193c:	b8 e4 32 10 f0       	mov    $0xf01032e4,%eax
f0101941:	e8 39 fe ff ff       	call   f010177f <stab_binsearch>

	if (lfun <= rfun) {
f0101946:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101949:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010194c:	83 c4 10             	add    $0x10,%esp
f010194f:	39 d0                	cmp    %edx,%eax
f0101951:	7f 40                	jg     f0101993 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0101953:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0101956:	c1 e1 02             	shl    $0x2,%ecx
f0101959:	8d b9 e4 32 10 f0    	lea    -0xfefcd1c(%ecx),%edi
f010195f:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0101962:	8b b9 e4 32 10 f0    	mov    -0xfefcd1c(%ecx),%edi
f0101968:	b9 92 a0 10 f0       	mov    $0xf010a092,%ecx
f010196d:	81 e9 b9 82 10 f0    	sub    $0xf01082b9,%ecx
f0101973:	39 cf                	cmp    %ecx,%edi
f0101975:	73 09                	jae    f0101980 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0101977:	81 c7 b9 82 10 f0    	add    $0xf01082b9,%edi
f010197d:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0101980:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0101983:	8b 4f 08             	mov    0x8(%edi),%ecx
f0101986:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0101989:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010198b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010198e:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101991:	eb 0f                	jmp    f01019a2 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0101993:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0101996:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101999:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010199c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010199f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01019a2:	83 ec 08             	sub    $0x8,%esp
f01019a5:	6a 3a                	push   $0x3a
f01019a7:	ff 73 08             	pushl  0x8(%ebx)
f01019aa:	e8 64 08 00 00       	call   f0102213 <strfind>
f01019af:	2b 43 08             	sub    0x8(%ebx),%eax
f01019b2:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01019b5:	83 c4 08             	add    $0x8,%esp
f01019b8:	56                   	push   %esi
f01019b9:	6a 44                	push   $0x44
f01019bb:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01019be:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01019c1:	b8 e4 32 10 f0       	mov    $0xf01032e4,%eax
f01019c6:	e8 b4 fd ff ff       	call   f010177f <stab_binsearch>
	if (lline == 0)
f01019cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019ce:	83 c4 10             	add    $0x10,%esp
f01019d1:	85 c0                	test   %eax,%eax
f01019d3:	0f 84 b3 00 00 00    	je     f0101a8c <debuginfo_eip+0x217>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f01019d9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01019dc:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01019df:	0f b7 14 95 ea 32 10 	movzwl -0xfefcd16(,%edx,4),%edx
f01019e6:	f0 
f01019e7:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01019ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01019ed:	89 c2                	mov    %eax,%edx
f01019ef:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01019f2:	8d 04 85 e4 32 10 f0 	lea    -0xfefcd1c(,%eax,4),%eax
f01019f9:	eb 06                	jmp    f0101a01 <debuginfo_eip+0x18c>
f01019fb:	83 ea 01             	sub    $0x1,%edx
f01019fe:	83 e8 0c             	sub    $0xc,%eax
f0101a01:	39 d7                	cmp    %edx,%edi
f0101a03:	7f 34                	jg     f0101a39 <debuginfo_eip+0x1c4>
	       && stabs[lline].n_type != N_SOL
f0101a05:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0101a09:	80 f9 84             	cmp    $0x84,%cl
f0101a0c:	74 0b                	je     f0101a19 <debuginfo_eip+0x1a4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0101a0e:	80 f9 64             	cmp    $0x64,%cl
f0101a11:	75 e8                	jne    f01019fb <debuginfo_eip+0x186>
f0101a13:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0101a17:	74 e2                	je     f01019fb <debuginfo_eip+0x186>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0101a19:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0101a1c:	8b 14 85 e4 32 10 f0 	mov    -0xfefcd1c(,%eax,4),%edx
f0101a23:	b8 92 a0 10 f0       	mov    $0xf010a092,%eax
f0101a28:	2d b9 82 10 f0       	sub    $0xf01082b9,%eax
f0101a2d:	39 c2                	cmp    %eax,%edx
f0101a2f:	73 08                	jae    f0101a39 <debuginfo_eip+0x1c4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0101a31:	81 c2 b9 82 10 f0    	add    $0xf01082b9,%edx
f0101a37:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101a39:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101a3c:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101a3f:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101a44:	39 f2                	cmp    %esi,%edx
f0101a46:	7d 50                	jge    f0101a98 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
f0101a48:	83 c2 01             	add    $0x1,%edx
f0101a4b:	89 d0                	mov    %edx,%eax
f0101a4d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0101a50:	8d 14 95 e4 32 10 f0 	lea    -0xfefcd1c(,%edx,4),%edx
f0101a57:	eb 04                	jmp    f0101a5d <debuginfo_eip+0x1e8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0101a59:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0101a5d:	39 c6                	cmp    %eax,%esi
f0101a5f:	7e 32                	jle    f0101a93 <debuginfo_eip+0x21e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0101a61:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0101a65:	83 c0 01             	add    $0x1,%eax
f0101a68:	83 c2 0c             	add    $0xc,%edx
f0101a6b:	80 f9 a0             	cmp    $0xa0,%cl
f0101a6e:	74 e9                	je     f0101a59 <debuginfo_eip+0x1e4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101a70:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a75:	eb 21                	jmp    f0101a98 <debuginfo_eip+0x223>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0101a77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101a7c:	eb 1a                	jmp    f0101a98 <debuginfo_eip+0x223>
f0101a7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101a83:	eb 13                	jmp    f0101a98 <debuginfo_eip+0x223>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0101a85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101a8a:	eb 0c                	jmp    f0101a98 <debuginfo_eip+0x223>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0101a8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101a91:	eb 05                	jmp    f0101a98 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a98:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101a9b:	5b                   	pop    %ebx
f0101a9c:	5e                   	pop    %esi
f0101a9d:	5f                   	pop    %edi
f0101a9e:	5d                   	pop    %ebp
f0101a9f:	c3                   	ret    

f0101aa0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101aa0:	55                   	push   %ebp
f0101aa1:	89 e5                	mov    %esp,%ebp
f0101aa3:	57                   	push   %edi
f0101aa4:	56                   	push   %esi
f0101aa5:	53                   	push   %ebx
f0101aa6:	83 ec 1c             	sub    $0x1c,%esp
f0101aa9:	89 c7                	mov    %eax,%edi
f0101aab:	89 d6                	mov    %edx,%esi
f0101aad:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ab0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101ab3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101ab6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101ab9:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101abc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101ac1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101ac4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101ac7:	39 d3                	cmp    %edx,%ebx
f0101ac9:	72 05                	jb     f0101ad0 <printnum+0x30>
f0101acb:	39 45 10             	cmp    %eax,0x10(%ebp)
f0101ace:	77 45                	ja     f0101b15 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101ad0:	83 ec 0c             	sub    $0xc,%esp
f0101ad3:	ff 75 18             	pushl  0x18(%ebp)
f0101ad6:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ad9:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0101adc:	53                   	push   %ebx
f0101add:	ff 75 10             	pushl  0x10(%ebp)
f0101ae0:	83 ec 08             	sub    $0x8,%esp
f0101ae3:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101ae6:	ff 75 e0             	pushl  -0x20(%ebp)
f0101ae9:	ff 75 dc             	pushl  -0x24(%ebp)
f0101aec:	ff 75 d8             	pushl  -0x28(%ebp)
f0101aef:	e8 4c 09 00 00       	call   f0102440 <__udivdi3>
f0101af4:	83 c4 18             	add    $0x18,%esp
f0101af7:	52                   	push   %edx
f0101af8:	50                   	push   %eax
f0101af9:	89 f2                	mov    %esi,%edx
f0101afb:	89 f8                	mov    %edi,%eax
f0101afd:	e8 9e ff ff ff       	call   f0101aa0 <printnum>
f0101b02:	83 c4 20             	add    $0x20,%esp
f0101b05:	eb 18                	jmp    f0101b1f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0101b07:	83 ec 08             	sub    $0x8,%esp
f0101b0a:	56                   	push   %esi
f0101b0b:	ff 75 18             	pushl  0x18(%ebp)
f0101b0e:	ff d7                	call   *%edi
f0101b10:	83 c4 10             	add    $0x10,%esp
f0101b13:	eb 03                	jmp    f0101b18 <printnum+0x78>
f0101b15:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101b18:	83 eb 01             	sub    $0x1,%ebx
f0101b1b:	85 db                	test   %ebx,%ebx
f0101b1d:	7f e8                	jg     f0101b07 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101b1f:	83 ec 08             	sub    $0x8,%esp
f0101b22:	56                   	push   %esi
f0101b23:	83 ec 04             	sub    $0x4,%esp
f0101b26:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101b29:	ff 75 e0             	pushl  -0x20(%ebp)
f0101b2c:	ff 75 dc             	pushl  -0x24(%ebp)
f0101b2f:	ff 75 d8             	pushl  -0x28(%ebp)
f0101b32:	e8 39 0a 00 00       	call   f0102570 <__umoddi3>
f0101b37:	83 c4 14             	add    $0x14,%esp
f0101b3a:	0f be 80 d5 30 10 f0 	movsbl -0xfefcf2b(%eax),%eax
f0101b41:	50                   	push   %eax
f0101b42:	ff d7                	call   *%edi
}
f0101b44:	83 c4 10             	add    $0x10,%esp
f0101b47:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101b4a:	5b                   	pop    %ebx
f0101b4b:	5e                   	pop    %esi
f0101b4c:	5f                   	pop    %edi
f0101b4d:	5d                   	pop    %ebp
f0101b4e:	c3                   	ret    

f0101b4f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0101b4f:	55                   	push   %ebp
f0101b50:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101b52:	83 fa 01             	cmp    $0x1,%edx
f0101b55:	7e 0e                	jle    f0101b65 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0101b57:	8b 10                	mov    (%eax),%edx
f0101b59:	8d 4a 08             	lea    0x8(%edx),%ecx
f0101b5c:	89 08                	mov    %ecx,(%eax)
f0101b5e:	8b 02                	mov    (%edx),%eax
f0101b60:	8b 52 04             	mov    0x4(%edx),%edx
f0101b63:	eb 22                	jmp    f0101b87 <getuint+0x38>
	else if (lflag)
f0101b65:	85 d2                	test   %edx,%edx
f0101b67:	74 10                	je     f0101b79 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0101b69:	8b 10                	mov    (%eax),%edx
f0101b6b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101b6e:	89 08                	mov    %ecx,(%eax)
f0101b70:	8b 02                	mov    (%edx),%eax
f0101b72:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b77:	eb 0e                	jmp    f0101b87 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0101b79:	8b 10                	mov    (%eax),%edx
f0101b7b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101b7e:	89 08                	mov    %ecx,(%eax)
f0101b80:	8b 02                	mov    (%edx),%eax
f0101b82:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101b87:	5d                   	pop    %ebp
f0101b88:	c3                   	ret    

f0101b89 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101b89:	55                   	push   %ebp
f0101b8a:	89 e5                	mov    %esp,%ebp
f0101b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101b8f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101b93:	8b 10                	mov    (%eax),%edx
f0101b95:	3b 50 04             	cmp    0x4(%eax),%edx
f0101b98:	73 0a                	jae    f0101ba4 <sprintputch+0x1b>
		*b->buf++ = ch;
f0101b9a:	8d 4a 01             	lea    0x1(%edx),%ecx
f0101b9d:	89 08                	mov    %ecx,(%eax)
f0101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ba2:	88 02                	mov    %al,(%edx)
}
f0101ba4:	5d                   	pop    %ebp
f0101ba5:	c3                   	ret    

f0101ba6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101ba6:	55                   	push   %ebp
f0101ba7:	89 e5                	mov    %esp,%ebp
f0101ba9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0101bac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101baf:	50                   	push   %eax
f0101bb0:	ff 75 10             	pushl  0x10(%ebp)
f0101bb3:	ff 75 0c             	pushl  0xc(%ebp)
f0101bb6:	ff 75 08             	pushl  0x8(%ebp)
f0101bb9:	e8 05 00 00 00       	call   f0101bc3 <vprintfmt>
	va_end(ap);
}
f0101bbe:	83 c4 10             	add    $0x10,%esp
f0101bc1:	c9                   	leave  
f0101bc2:	c3                   	ret    

f0101bc3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101bc3:	55                   	push   %ebp
f0101bc4:	89 e5                	mov    %esp,%ebp
f0101bc6:	57                   	push   %edi
f0101bc7:	56                   	push   %esi
f0101bc8:	53                   	push   %ebx
f0101bc9:	83 ec 2c             	sub    $0x2c,%esp
f0101bcc:	8b 75 08             	mov    0x8(%ebp),%esi
f0101bcf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101bd2:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101bd5:	eb 12                	jmp    f0101be9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0101bd7:	85 c0                	test   %eax,%eax
f0101bd9:	0f 84 89 03 00 00    	je     f0101f68 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0101bdf:	83 ec 08             	sub    $0x8,%esp
f0101be2:	53                   	push   %ebx
f0101be3:	50                   	push   %eax
f0101be4:	ff d6                	call   *%esi
f0101be6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101be9:	83 c7 01             	add    $0x1,%edi
f0101bec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101bf0:	83 f8 25             	cmp    $0x25,%eax
f0101bf3:	75 e2                	jne    f0101bd7 <vprintfmt+0x14>
f0101bf5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0101bf9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0101c00:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101c07:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0101c0e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c13:	eb 07                	jmp    f0101c1c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c15:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0101c18:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c1c:	8d 47 01             	lea    0x1(%edi),%eax
f0101c1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101c22:	0f b6 07             	movzbl (%edi),%eax
f0101c25:	0f b6 c8             	movzbl %al,%ecx
f0101c28:	83 e8 23             	sub    $0x23,%eax
f0101c2b:	3c 55                	cmp    $0x55,%al
f0101c2d:	0f 87 1a 03 00 00    	ja     f0101f4d <vprintfmt+0x38a>
f0101c33:	0f b6 c0             	movzbl %al,%eax
f0101c36:	ff 24 85 60 31 10 f0 	jmp    *-0xfefcea0(,%eax,4)
f0101c3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101c40:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101c44:	eb d6                	jmp    f0101c1c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101c49:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c4e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101c51:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101c54:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0101c58:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0101c5b:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0101c5e:	83 fa 09             	cmp    $0x9,%edx
f0101c61:	77 39                	ja     f0101c9c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0101c63:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0101c66:	eb e9                	jmp    f0101c51 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101c68:	8b 45 14             	mov    0x14(%ebp),%eax
f0101c6b:	8d 48 04             	lea    0x4(%eax),%ecx
f0101c6e:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0101c71:	8b 00                	mov    (%eax),%eax
f0101c73:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101c79:	eb 27                	jmp    f0101ca2 <vprintfmt+0xdf>
f0101c7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101c7e:	85 c0                	test   %eax,%eax
f0101c80:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101c85:	0f 49 c8             	cmovns %eax,%ecx
f0101c88:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c8b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101c8e:	eb 8c                	jmp    f0101c1c <vprintfmt+0x59>
f0101c90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101c93:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101c9a:	eb 80                	jmp    f0101c1c <vprintfmt+0x59>
f0101c9c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101c9f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0101ca2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101ca6:	0f 89 70 ff ff ff    	jns    f0101c1c <vprintfmt+0x59>
				width = precision, precision = -1;
f0101cac:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101caf:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101cb2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101cb9:	e9 5e ff ff ff       	jmp    f0101c1c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101cbe:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101cc1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0101cc4:	e9 53 ff ff ff       	jmp    f0101c1c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101cc9:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ccc:	8d 50 04             	lea    0x4(%eax),%edx
f0101ccf:	89 55 14             	mov    %edx,0x14(%ebp)
f0101cd2:	83 ec 08             	sub    $0x8,%esp
f0101cd5:	53                   	push   %ebx
f0101cd6:	ff 30                	pushl  (%eax)
f0101cd8:	ff d6                	call   *%esi
			break;
f0101cda:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101cdd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0101ce0:	e9 04 ff ff ff       	jmp    f0101be9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101ce5:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ce8:	8d 50 04             	lea    0x4(%eax),%edx
f0101ceb:	89 55 14             	mov    %edx,0x14(%ebp)
f0101cee:	8b 00                	mov    (%eax),%eax
f0101cf0:	99                   	cltd   
f0101cf1:	31 d0                	xor    %edx,%eax
f0101cf3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101cf5:	83 f8 06             	cmp    $0x6,%eax
f0101cf8:	7f 0b                	jg     f0101d05 <vprintfmt+0x142>
f0101cfa:	8b 14 85 b8 32 10 f0 	mov    -0xfefcd48(,%eax,4),%edx
f0101d01:	85 d2                	test   %edx,%edx
f0101d03:	75 18                	jne    f0101d1d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0101d05:	50                   	push   %eax
f0101d06:	68 ed 30 10 f0       	push   $0xf01030ed
f0101d0b:	53                   	push   %ebx
f0101d0c:	56                   	push   %esi
f0101d0d:	e8 94 fe ff ff       	call   f0101ba6 <printfmt>
f0101d12:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101d15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101d18:	e9 cc fe ff ff       	jmp    f0101be9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0101d1d:	52                   	push   %edx
f0101d1e:	68 77 2c 10 f0       	push   $0xf0102c77
f0101d23:	53                   	push   %ebx
f0101d24:	56                   	push   %esi
f0101d25:	e8 7c fe ff ff       	call   f0101ba6 <printfmt>
f0101d2a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101d2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101d30:	e9 b4 fe ff ff       	jmp    f0101be9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101d35:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d38:	8d 50 04             	lea    0x4(%eax),%edx
f0101d3b:	89 55 14             	mov    %edx,0x14(%ebp)
f0101d3e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0101d40:	85 ff                	test   %edi,%edi
f0101d42:	b8 e6 30 10 f0       	mov    $0xf01030e6,%eax
f0101d47:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0101d4a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101d4e:	0f 8e 94 00 00 00    	jle    f0101de8 <vprintfmt+0x225>
f0101d54:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101d58:	0f 84 98 00 00 00    	je     f0101df6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101d5e:	83 ec 08             	sub    $0x8,%esp
f0101d61:	ff 75 d0             	pushl  -0x30(%ebp)
f0101d64:	57                   	push   %edi
f0101d65:	e8 5f 03 00 00       	call   f01020c9 <strnlen>
f0101d6a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101d6d:	29 c1                	sub    %eax,%ecx
f0101d6f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101d72:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101d75:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101d79:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101d7c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101d7f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101d81:	eb 0f                	jmp    f0101d92 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0101d83:	83 ec 08             	sub    $0x8,%esp
f0101d86:	53                   	push   %ebx
f0101d87:	ff 75 e0             	pushl  -0x20(%ebp)
f0101d8a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101d8c:	83 ef 01             	sub    $0x1,%edi
f0101d8f:	83 c4 10             	add    $0x10,%esp
f0101d92:	85 ff                	test   %edi,%edi
f0101d94:	7f ed                	jg     f0101d83 <vprintfmt+0x1c0>
f0101d96:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101d99:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101d9c:	85 c9                	test   %ecx,%ecx
f0101d9e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101da3:	0f 49 c1             	cmovns %ecx,%eax
f0101da6:	29 c1                	sub    %eax,%ecx
f0101da8:	89 75 08             	mov    %esi,0x8(%ebp)
f0101dab:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101dae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101db1:	89 cb                	mov    %ecx,%ebx
f0101db3:	eb 4d                	jmp    f0101e02 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101db5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101db9:	74 1b                	je     f0101dd6 <vprintfmt+0x213>
f0101dbb:	0f be c0             	movsbl %al,%eax
f0101dbe:	83 e8 20             	sub    $0x20,%eax
f0101dc1:	83 f8 5e             	cmp    $0x5e,%eax
f0101dc4:	76 10                	jbe    f0101dd6 <vprintfmt+0x213>
					putch('?', putdat);
f0101dc6:	83 ec 08             	sub    $0x8,%esp
f0101dc9:	ff 75 0c             	pushl  0xc(%ebp)
f0101dcc:	6a 3f                	push   $0x3f
f0101dce:	ff 55 08             	call   *0x8(%ebp)
f0101dd1:	83 c4 10             	add    $0x10,%esp
f0101dd4:	eb 0d                	jmp    f0101de3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0101dd6:	83 ec 08             	sub    $0x8,%esp
f0101dd9:	ff 75 0c             	pushl  0xc(%ebp)
f0101ddc:	52                   	push   %edx
f0101ddd:	ff 55 08             	call   *0x8(%ebp)
f0101de0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101de3:	83 eb 01             	sub    $0x1,%ebx
f0101de6:	eb 1a                	jmp    f0101e02 <vprintfmt+0x23f>
f0101de8:	89 75 08             	mov    %esi,0x8(%ebp)
f0101deb:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101dee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101df1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101df4:	eb 0c                	jmp    f0101e02 <vprintfmt+0x23f>
f0101df6:	89 75 08             	mov    %esi,0x8(%ebp)
f0101df9:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101dfc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101dff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101e02:	83 c7 01             	add    $0x1,%edi
f0101e05:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101e09:	0f be d0             	movsbl %al,%edx
f0101e0c:	85 d2                	test   %edx,%edx
f0101e0e:	74 23                	je     f0101e33 <vprintfmt+0x270>
f0101e10:	85 f6                	test   %esi,%esi
f0101e12:	78 a1                	js     f0101db5 <vprintfmt+0x1f2>
f0101e14:	83 ee 01             	sub    $0x1,%esi
f0101e17:	79 9c                	jns    f0101db5 <vprintfmt+0x1f2>
f0101e19:	89 df                	mov    %ebx,%edi
f0101e1b:	8b 75 08             	mov    0x8(%ebp),%esi
f0101e1e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101e21:	eb 18                	jmp    f0101e3b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101e23:	83 ec 08             	sub    $0x8,%esp
f0101e26:	53                   	push   %ebx
f0101e27:	6a 20                	push   $0x20
f0101e29:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101e2b:	83 ef 01             	sub    $0x1,%edi
f0101e2e:	83 c4 10             	add    $0x10,%esp
f0101e31:	eb 08                	jmp    f0101e3b <vprintfmt+0x278>
f0101e33:	89 df                	mov    %ebx,%edi
f0101e35:	8b 75 08             	mov    0x8(%ebp),%esi
f0101e38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101e3b:	85 ff                	test   %edi,%edi
f0101e3d:	7f e4                	jg     f0101e23 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101e3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101e42:	e9 a2 fd ff ff       	jmp    f0101be9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101e47:	83 fa 01             	cmp    $0x1,%edx
f0101e4a:	7e 16                	jle    f0101e62 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0101e4c:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e4f:	8d 50 08             	lea    0x8(%eax),%edx
f0101e52:	89 55 14             	mov    %edx,0x14(%ebp)
f0101e55:	8b 50 04             	mov    0x4(%eax),%edx
f0101e58:	8b 00                	mov    (%eax),%eax
f0101e5a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101e5d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101e60:	eb 32                	jmp    f0101e94 <vprintfmt+0x2d1>
	else if (lflag)
f0101e62:	85 d2                	test   %edx,%edx
f0101e64:	74 18                	je     f0101e7e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0101e66:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e69:	8d 50 04             	lea    0x4(%eax),%edx
f0101e6c:	89 55 14             	mov    %edx,0x14(%ebp)
f0101e6f:	8b 00                	mov    (%eax),%eax
f0101e71:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101e74:	89 c1                	mov    %eax,%ecx
f0101e76:	c1 f9 1f             	sar    $0x1f,%ecx
f0101e79:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101e7c:	eb 16                	jmp    f0101e94 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0101e7e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e81:	8d 50 04             	lea    0x4(%eax),%edx
f0101e84:	89 55 14             	mov    %edx,0x14(%ebp)
f0101e87:	8b 00                	mov    (%eax),%eax
f0101e89:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101e8c:	89 c1                	mov    %eax,%ecx
f0101e8e:	c1 f9 1f             	sar    $0x1f,%ecx
f0101e91:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101e94:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101e97:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101e9a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101e9f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101ea3:	79 74                	jns    f0101f19 <vprintfmt+0x356>
				putch('-', putdat);
f0101ea5:	83 ec 08             	sub    $0x8,%esp
f0101ea8:	53                   	push   %ebx
f0101ea9:	6a 2d                	push   $0x2d
f0101eab:	ff d6                	call   *%esi
				num = -(long long) num;
f0101ead:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101eb0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101eb3:	f7 d8                	neg    %eax
f0101eb5:	83 d2 00             	adc    $0x0,%edx
f0101eb8:	f7 da                	neg    %edx
f0101eba:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0101ebd:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101ec2:	eb 55                	jmp    f0101f19 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101ec4:	8d 45 14             	lea    0x14(%ebp),%eax
f0101ec7:	e8 83 fc ff ff       	call   f0101b4f <getuint>
			base = 10;
f0101ecc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101ed1:	eb 46                	jmp    f0101f19 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0101ed3:	8d 45 14             	lea    0x14(%ebp),%eax
f0101ed6:	e8 74 fc ff ff       	call   f0101b4f <getuint>
			base = 8;
f0101edb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0101ee0:	eb 37                	jmp    f0101f19 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0101ee2:	83 ec 08             	sub    $0x8,%esp
f0101ee5:	53                   	push   %ebx
f0101ee6:	6a 30                	push   $0x30
f0101ee8:	ff d6                	call   *%esi
			putch('x', putdat);
f0101eea:	83 c4 08             	add    $0x8,%esp
f0101eed:	53                   	push   %ebx
f0101eee:	6a 78                	push   $0x78
f0101ef0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101ef2:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ef5:	8d 50 04             	lea    0x4(%eax),%edx
f0101ef8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101efb:	8b 00                	mov    (%eax),%eax
f0101efd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101f02:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101f05:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0101f0a:	eb 0d                	jmp    f0101f19 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101f0c:	8d 45 14             	lea    0x14(%ebp),%eax
f0101f0f:	e8 3b fc ff ff       	call   f0101b4f <getuint>
			base = 16;
f0101f14:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101f19:	83 ec 0c             	sub    $0xc,%esp
f0101f1c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101f20:	57                   	push   %edi
f0101f21:	ff 75 e0             	pushl  -0x20(%ebp)
f0101f24:	51                   	push   %ecx
f0101f25:	52                   	push   %edx
f0101f26:	50                   	push   %eax
f0101f27:	89 da                	mov    %ebx,%edx
f0101f29:	89 f0                	mov    %esi,%eax
f0101f2b:	e8 70 fb ff ff       	call   f0101aa0 <printnum>
			break;
f0101f30:	83 c4 20             	add    $0x20,%esp
f0101f33:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101f36:	e9 ae fc ff ff       	jmp    f0101be9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101f3b:	83 ec 08             	sub    $0x8,%esp
f0101f3e:	53                   	push   %ebx
f0101f3f:	51                   	push   %ecx
f0101f40:	ff d6                	call   *%esi
			break;
f0101f42:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101f45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101f48:	e9 9c fc ff ff       	jmp    f0101be9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101f4d:	83 ec 08             	sub    $0x8,%esp
f0101f50:	53                   	push   %ebx
f0101f51:	6a 25                	push   $0x25
f0101f53:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101f55:	83 c4 10             	add    $0x10,%esp
f0101f58:	eb 03                	jmp    f0101f5d <vprintfmt+0x39a>
f0101f5a:	83 ef 01             	sub    $0x1,%edi
f0101f5d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101f61:	75 f7                	jne    f0101f5a <vprintfmt+0x397>
f0101f63:	e9 81 fc ff ff       	jmp    f0101be9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101f6b:	5b                   	pop    %ebx
f0101f6c:	5e                   	pop    %esi
f0101f6d:	5f                   	pop    %edi
f0101f6e:	5d                   	pop    %ebp
f0101f6f:	c3                   	ret    

f0101f70 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101f70:	55                   	push   %ebp
f0101f71:	89 e5                	mov    %esp,%ebp
f0101f73:	83 ec 18             	sub    $0x18,%esp
f0101f76:	8b 45 08             	mov    0x8(%ebp),%eax
f0101f79:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101f7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101f7f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101f83:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101f86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101f8d:	85 c0                	test   %eax,%eax
f0101f8f:	74 26                	je     f0101fb7 <vsnprintf+0x47>
f0101f91:	85 d2                	test   %edx,%edx
f0101f93:	7e 22                	jle    f0101fb7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101f95:	ff 75 14             	pushl  0x14(%ebp)
f0101f98:	ff 75 10             	pushl  0x10(%ebp)
f0101f9b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101f9e:	50                   	push   %eax
f0101f9f:	68 89 1b 10 f0       	push   $0xf0101b89
f0101fa4:	e8 1a fc ff ff       	call   f0101bc3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101fa9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101fac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101fb2:	83 c4 10             	add    $0x10,%esp
f0101fb5:	eb 05                	jmp    f0101fbc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101fb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101fbc:	c9                   	leave  
f0101fbd:	c3                   	ret    

f0101fbe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101fbe:	55                   	push   %ebp
f0101fbf:	89 e5                	mov    %esp,%ebp
f0101fc1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101fc4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101fc7:	50                   	push   %eax
f0101fc8:	ff 75 10             	pushl  0x10(%ebp)
f0101fcb:	ff 75 0c             	pushl  0xc(%ebp)
f0101fce:	ff 75 08             	pushl  0x8(%ebp)
f0101fd1:	e8 9a ff ff ff       	call   f0101f70 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101fd6:	c9                   	leave  
f0101fd7:	c3                   	ret    

f0101fd8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101fd8:	55                   	push   %ebp
f0101fd9:	89 e5                	mov    %esp,%ebp
f0101fdb:	57                   	push   %edi
f0101fdc:	56                   	push   %esi
f0101fdd:	53                   	push   %ebx
f0101fde:	83 ec 0c             	sub    $0xc,%esp
f0101fe1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101fe4:	85 c0                	test   %eax,%eax
f0101fe6:	74 11                	je     f0101ff9 <readline+0x21>
		cprintf("%s", prompt);
f0101fe8:	83 ec 08             	sub    $0x8,%esp
f0101feb:	50                   	push   %eax
f0101fec:	68 77 2c 10 f0       	push   $0xf0102c77
f0101ff1:	e8 75 f7 ff ff       	call   f010176b <cprintf>
f0101ff6:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101ff9:	83 ec 0c             	sub    $0xc,%esp
f0101ffc:	6a 00                	push   $0x0
f0101ffe:	e8 1e e6 ff ff       	call   f0100621 <iscons>
f0102003:	89 c7                	mov    %eax,%edi
f0102005:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0102008:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010200d:	e8 fe e5 ff ff       	call   f0100610 <getchar>
f0102012:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102014:	85 c0                	test   %eax,%eax
f0102016:	79 18                	jns    f0102030 <readline+0x58>
			cprintf("read error: %e\n", c);
f0102018:	83 ec 08             	sub    $0x8,%esp
f010201b:	50                   	push   %eax
f010201c:	68 d4 32 10 f0       	push   $0xf01032d4
f0102021:	e8 45 f7 ff ff       	call   f010176b <cprintf>
			return NULL;
f0102026:	83 c4 10             	add    $0x10,%esp
f0102029:	b8 00 00 00 00       	mov    $0x0,%eax
f010202e:	eb 79                	jmp    f01020a9 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102030:	83 f8 08             	cmp    $0x8,%eax
f0102033:	0f 94 c2             	sete   %dl
f0102036:	83 f8 7f             	cmp    $0x7f,%eax
f0102039:	0f 94 c0             	sete   %al
f010203c:	08 c2                	or     %al,%dl
f010203e:	74 1a                	je     f010205a <readline+0x82>
f0102040:	85 f6                	test   %esi,%esi
f0102042:	7e 16                	jle    f010205a <readline+0x82>
			if (echoing)
f0102044:	85 ff                	test   %edi,%edi
f0102046:	74 0d                	je     f0102055 <readline+0x7d>
				cputchar('\b');
f0102048:	83 ec 0c             	sub    $0xc,%esp
f010204b:	6a 08                	push   $0x8
f010204d:	e8 ae e5 ff ff       	call   f0100600 <cputchar>
f0102052:	83 c4 10             	add    $0x10,%esp
			i--;
f0102055:	83 ee 01             	sub    $0x1,%esi
f0102058:	eb b3                	jmp    f010200d <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010205a:	83 fb 1f             	cmp    $0x1f,%ebx
f010205d:	7e 23                	jle    f0102082 <readline+0xaa>
f010205f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102065:	7f 1b                	jg     f0102082 <readline+0xaa>
			if (echoing)
f0102067:	85 ff                	test   %edi,%edi
f0102069:	74 0c                	je     f0102077 <readline+0x9f>
				cputchar(c);
f010206b:	83 ec 0c             	sub    $0xc,%esp
f010206e:	53                   	push   %ebx
f010206f:	e8 8c e5 ff ff       	call   f0100600 <cputchar>
f0102074:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0102077:	88 9e 60 55 11 f0    	mov    %bl,-0xfeeaaa0(%esi)
f010207d:	8d 76 01             	lea    0x1(%esi),%esi
f0102080:	eb 8b                	jmp    f010200d <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0102082:	83 fb 0a             	cmp    $0xa,%ebx
f0102085:	74 05                	je     f010208c <readline+0xb4>
f0102087:	83 fb 0d             	cmp    $0xd,%ebx
f010208a:	75 81                	jne    f010200d <readline+0x35>
			if (echoing)
f010208c:	85 ff                	test   %edi,%edi
f010208e:	74 0d                	je     f010209d <readline+0xc5>
				cputchar('\n');
f0102090:	83 ec 0c             	sub    $0xc,%esp
f0102093:	6a 0a                	push   $0xa
f0102095:	e8 66 e5 ff ff       	call   f0100600 <cputchar>
f010209a:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010209d:	c6 86 60 55 11 f0 00 	movb   $0x0,-0xfeeaaa0(%esi)
			return buf;
f01020a4:	b8 60 55 11 f0       	mov    $0xf0115560,%eax
		}
	}
}
f01020a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01020ac:	5b                   	pop    %ebx
f01020ad:	5e                   	pop    %esi
f01020ae:	5f                   	pop    %edi
f01020af:	5d                   	pop    %ebp
f01020b0:	c3                   	ret    

f01020b1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01020b1:	55                   	push   %ebp
f01020b2:	89 e5                	mov    %esp,%ebp
f01020b4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01020b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01020bc:	eb 03                	jmp    f01020c1 <strlen+0x10>
		n++;
f01020be:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01020c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01020c5:	75 f7                	jne    f01020be <strlen+0xd>
		n++;
	return n;
}
f01020c7:	5d                   	pop    %ebp
f01020c8:	c3                   	ret    

f01020c9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01020c9:	55                   	push   %ebp
f01020ca:	89 e5                	mov    %esp,%ebp
f01020cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01020cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01020d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01020d7:	eb 03                	jmp    f01020dc <strnlen+0x13>
		n++;
f01020d9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01020dc:	39 c2                	cmp    %eax,%edx
f01020de:	74 08                	je     f01020e8 <strnlen+0x1f>
f01020e0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01020e4:	75 f3                	jne    f01020d9 <strnlen+0x10>
f01020e6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01020e8:	5d                   	pop    %ebp
f01020e9:	c3                   	ret    

f01020ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01020ea:	55                   	push   %ebp
f01020eb:	89 e5                	mov    %esp,%ebp
f01020ed:	53                   	push   %ebx
f01020ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01020f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01020f4:	89 c2                	mov    %eax,%edx
f01020f6:	83 c2 01             	add    $0x1,%edx
f01020f9:	83 c1 01             	add    $0x1,%ecx
f01020fc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0102100:	88 5a ff             	mov    %bl,-0x1(%edx)
f0102103:	84 db                	test   %bl,%bl
f0102105:	75 ef                	jne    f01020f6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0102107:	5b                   	pop    %ebx
f0102108:	5d                   	pop    %ebp
f0102109:	c3                   	ret    

f010210a <strcat>:

char *
strcat(char *dst, const char *src)
{
f010210a:	55                   	push   %ebp
f010210b:	89 e5                	mov    %esp,%ebp
f010210d:	53                   	push   %ebx
f010210e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0102111:	53                   	push   %ebx
f0102112:	e8 9a ff ff ff       	call   f01020b1 <strlen>
f0102117:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010211a:	ff 75 0c             	pushl  0xc(%ebp)
f010211d:	01 d8                	add    %ebx,%eax
f010211f:	50                   	push   %eax
f0102120:	e8 c5 ff ff ff       	call   f01020ea <strcpy>
	return dst;
}
f0102125:	89 d8                	mov    %ebx,%eax
f0102127:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010212a:	c9                   	leave  
f010212b:	c3                   	ret    

f010212c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010212c:	55                   	push   %ebp
f010212d:	89 e5                	mov    %esp,%ebp
f010212f:	56                   	push   %esi
f0102130:	53                   	push   %ebx
f0102131:	8b 75 08             	mov    0x8(%ebp),%esi
f0102134:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102137:	89 f3                	mov    %esi,%ebx
f0102139:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010213c:	89 f2                	mov    %esi,%edx
f010213e:	eb 0f                	jmp    f010214f <strncpy+0x23>
		*dst++ = *src;
f0102140:	83 c2 01             	add    $0x1,%edx
f0102143:	0f b6 01             	movzbl (%ecx),%eax
f0102146:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0102149:	80 39 01             	cmpb   $0x1,(%ecx)
f010214c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010214f:	39 da                	cmp    %ebx,%edx
f0102151:	75 ed                	jne    f0102140 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0102153:	89 f0                	mov    %esi,%eax
f0102155:	5b                   	pop    %ebx
f0102156:	5e                   	pop    %esi
f0102157:	5d                   	pop    %ebp
f0102158:	c3                   	ret    

f0102159 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0102159:	55                   	push   %ebp
f010215a:	89 e5                	mov    %esp,%ebp
f010215c:	56                   	push   %esi
f010215d:	53                   	push   %ebx
f010215e:	8b 75 08             	mov    0x8(%ebp),%esi
f0102161:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102164:	8b 55 10             	mov    0x10(%ebp),%edx
f0102167:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0102169:	85 d2                	test   %edx,%edx
f010216b:	74 21                	je     f010218e <strlcpy+0x35>
f010216d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0102171:	89 f2                	mov    %esi,%edx
f0102173:	eb 09                	jmp    f010217e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0102175:	83 c2 01             	add    $0x1,%edx
f0102178:	83 c1 01             	add    $0x1,%ecx
f010217b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010217e:	39 c2                	cmp    %eax,%edx
f0102180:	74 09                	je     f010218b <strlcpy+0x32>
f0102182:	0f b6 19             	movzbl (%ecx),%ebx
f0102185:	84 db                	test   %bl,%bl
f0102187:	75 ec                	jne    f0102175 <strlcpy+0x1c>
f0102189:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010218b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010218e:	29 f0                	sub    %esi,%eax
}
f0102190:	5b                   	pop    %ebx
f0102191:	5e                   	pop    %esi
f0102192:	5d                   	pop    %ebp
f0102193:	c3                   	ret    

f0102194 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0102194:	55                   	push   %ebp
f0102195:	89 e5                	mov    %esp,%ebp
f0102197:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010219a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010219d:	eb 06                	jmp    f01021a5 <strcmp+0x11>
		p++, q++;
f010219f:	83 c1 01             	add    $0x1,%ecx
f01021a2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01021a5:	0f b6 01             	movzbl (%ecx),%eax
f01021a8:	84 c0                	test   %al,%al
f01021aa:	74 04                	je     f01021b0 <strcmp+0x1c>
f01021ac:	3a 02                	cmp    (%edx),%al
f01021ae:	74 ef                	je     f010219f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01021b0:	0f b6 c0             	movzbl %al,%eax
f01021b3:	0f b6 12             	movzbl (%edx),%edx
f01021b6:	29 d0                	sub    %edx,%eax
}
f01021b8:	5d                   	pop    %ebp
f01021b9:	c3                   	ret    

f01021ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01021ba:	55                   	push   %ebp
f01021bb:	89 e5                	mov    %esp,%ebp
f01021bd:	53                   	push   %ebx
f01021be:	8b 45 08             	mov    0x8(%ebp),%eax
f01021c1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01021c4:	89 c3                	mov    %eax,%ebx
f01021c6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01021c9:	eb 06                	jmp    f01021d1 <strncmp+0x17>
		n--, p++, q++;
f01021cb:	83 c0 01             	add    $0x1,%eax
f01021ce:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01021d1:	39 d8                	cmp    %ebx,%eax
f01021d3:	74 15                	je     f01021ea <strncmp+0x30>
f01021d5:	0f b6 08             	movzbl (%eax),%ecx
f01021d8:	84 c9                	test   %cl,%cl
f01021da:	74 04                	je     f01021e0 <strncmp+0x26>
f01021dc:	3a 0a                	cmp    (%edx),%cl
f01021de:	74 eb                	je     f01021cb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01021e0:	0f b6 00             	movzbl (%eax),%eax
f01021e3:	0f b6 12             	movzbl (%edx),%edx
f01021e6:	29 d0                	sub    %edx,%eax
f01021e8:	eb 05                	jmp    f01021ef <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01021ea:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01021ef:	5b                   	pop    %ebx
f01021f0:	5d                   	pop    %ebp
f01021f1:	c3                   	ret    

f01021f2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01021f2:	55                   	push   %ebp
f01021f3:	89 e5                	mov    %esp,%ebp
f01021f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01021f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01021fc:	eb 07                	jmp    f0102205 <strchr+0x13>
		if (*s == c)
f01021fe:	38 ca                	cmp    %cl,%dl
f0102200:	74 0f                	je     f0102211 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0102202:	83 c0 01             	add    $0x1,%eax
f0102205:	0f b6 10             	movzbl (%eax),%edx
f0102208:	84 d2                	test   %dl,%dl
f010220a:	75 f2                	jne    f01021fe <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010220c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102211:	5d                   	pop    %ebp
f0102212:	c3                   	ret    

f0102213 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0102213:	55                   	push   %ebp
f0102214:	89 e5                	mov    %esp,%ebp
f0102216:	8b 45 08             	mov    0x8(%ebp),%eax
f0102219:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010221d:	eb 03                	jmp    f0102222 <strfind+0xf>
f010221f:	83 c0 01             	add    $0x1,%eax
f0102222:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0102225:	38 ca                	cmp    %cl,%dl
f0102227:	74 04                	je     f010222d <strfind+0x1a>
f0102229:	84 d2                	test   %dl,%dl
f010222b:	75 f2                	jne    f010221f <strfind+0xc>
			break;
	return (char *) s;
}
f010222d:	5d                   	pop    %ebp
f010222e:	c3                   	ret    

f010222f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010222f:	55                   	push   %ebp
f0102230:	89 e5                	mov    %esp,%ebp
f0102232:	57                   	push   %edi
f0102233:	56                   	push   %esi
f0102234:	53                   	push   %ebx
f0102235:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102238:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010223b:	85 c9                	test   %ecx,%ecx
f010223d:	74 36                	je     f0102275 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010223f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0102245:	75 28                	jne    f010226f <memset+0x40>
f0102247:	f6 c1 03             	test   $0x3,%cl
f010224a:	75 23                	jne    f010226f <memset+0x40>
		c &= 0xFF;
f010224c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0102250:	89 d3                	mov    %edx,%ebx
f0102252:	c1 e3 08             	shl    $0x8,%ebx
f0102255:	89 d6                	mov    %edx,%esi
f0102257:	c1 e6 18             	shl    $0x18,%esi
f010225a:	89 d0                	mov    %edx,%eax
f010225c:	c1 e0 10             	shl    $0x10,%eax
f010225f:	09 f0                	or     %esi,%eax
f0102261:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0102263:	89 d8                	mov    %ebx,%eax
f0102265:	09 d0                	or     %edx,%eax
f0102267:	c1 e9 02             	shr    $0x2,%ecx
f010226a:	fc                   	cld    
f010226b:	f3 ab                	rep stos %eax,%es:(%edi)
f010226d:	eb 06                	jmp    f0102275 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010226f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102272:	fc                   	cld    
f0102273:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0102275:	89 f8                	mov    %edi,%eax
f0102277:	5b                   	pop    %ebx
f0102278:	5e                   	pop    %esi
f0102279:	5f                   	pop    %edi
f010227a:	5d                   	pop    %ebp
f010227b:	c3                   	ret    

f010227c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010227c:	55                   	push   %ebp
f010227d:	89 e5                	mov    %esp,%ebp
f010227f:	57                   	push   %edi
f0102280:	56                   	push   %esi
f0102281:	8b 45 08             	mov    0x8(%ebp),%eax
f0102284:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102287:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010228a:	39 c6                	cmp    %eax,%esi
f010228c:	73 35                	jae    f01022c3 <memmove+0x47>
f010228e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0102291:	39 d0                	cmp    %edx,%eax
f0102293:	73 2e                	jae    f01022c3 <memmove+0x47>
		s += n;
		d += n;
f0102295:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0102298:	89 d6                	mov    %edx,%esi
f010229a:	09 fe                	or     %edi,%esi
f010229c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01022a2:	75 13                	jne    f01022b7 <memmove+0x3b>
f01022a4:	f6 c1 03             	test   $0x3,%cl
f01022a7:	75 0e                	jne    f01022b7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01022a9:	83 ef 04             	sub    $0x4,%edi
f01022ac:	8d 72 fc             	lea    -0x4(%edx),%esi
f01022af:	c1 e9 02             	shr    $0x2,%ecx
f01022b2:	fd                   	std    
f01022b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01022b5:	eb 09                	jmp    f01022c0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01022b7:	83 ef 01             	sub    $0x1,%edi
f01022ba:	8d 72 ff             	lea    -0x1(%edx),%esi
f01022bd:	fd                   	std    
f01022be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01022c0:	fc                   	cld    
f01022c1:	eb 1d                	jmp    f01022e0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01022c3:	89 f2                	mov    %esi,%edx
f01022c5:	09 c2                	or     %eax,%edx
f01022c7:	f6 c2 03             	test   $0x3,%dl
f01022ca:	75 0f                	jne    f01022db <memmove+0x5f>
f01022cc:	f6 c1 03             	test   $0x3,%cl
f01022cf:	75 0a                	jne    f01022db <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01022d1:	c1 e9 02             	shr    $0x2,%ecx
f01022d4:	89 c7                	mov    %eax,%edi
f01022d6:	fc                   	cld    
f01022d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01022d9:	eb 05                	jmp    f01022e0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01022db:	89 c7                	mov    %eax,%edi
f01022dd:	fc                   	cld    
f01022de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01022e0:	5e                   	pop    %esi
f01022e1:	5f                   	pop    %edi
f01022e2:	5d                   	pop    %ebp
f01022e3:	c3                   	ret    

f01022e4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01022e4:	55                   	push   %ebp
f01022e5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01022e7:	ff 75 10             	pushl  0x10(%ebp)
f01022ea:	ff 75 0c             	pushl  0xc(%ebp)
f01022ed:	ff 75 08             	pushl  0x8(%ebp)
f01022f0:	e8 87 ff ff ff       	call   f010227c <memmove>
}
f01022f5:	c9                   	leave  
f01022f6:	c3                   	ret    

f01022f7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01022f7:	55                   	push   %ebp
f01022f8:	89 e5                	mov    %esp,%ebp
f01022fa:	56                   	push   %esi
f01022fb:	53                   	push   %ebx
f01022fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01022ff:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102302:	89 c6                	mov    %eax,%esi
f0102304:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102307:	eb 1a                	jmp    f0102323 <memcmp+0x2c>
		if (*s1 != *s2)
f0102309:	0f b6 08             	movzbl (%eax),%ecx
f010230c:	0f b6 1a             	movzbl (%edx),%ebx
f010230f:	38 d9                	cmp    %bl,%cl
f0102311:	74 0a                	je     f010231d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0102313:	0f b6 c1             	movzbl %cl,%eax
f0102316:	0f b6 db             	movzbl %bl,%ebx
f0102319:	29 d8                	sub    %ebx,%eax
f010231b:	eb 0f                	jmp    f010232c <memcmp+0x35>
		s1++, s2++;
f010231d:	83 c0 01             	add    $0x1,%eax
f0102320:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102323:	39 f0                	cmp    %esi,%eax
f0102325:	75 e2                	jne    f0102309 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0102327:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010232c:	5b                   	pop    %ebx
f010232d:	5e                   	pop    %esi
f010232e:	5d                   	pop    %ebp
f010232f:	c3                   	ret    

f0102330 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0102330:	55                   	push   %ebp
f0102331:	89 e5                	mov    %esp,%ebp
f0102333:	53                   	push   %ebx
f0102334:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0102337:	89 c1                	mov    %eax,%ecx
f0102339:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010233c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0102340:	eb 0a                	jmp    f010234c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0102342:	0f b6 10             	movzbl (%eax),%edx
f0102345:	39 da                	cmp    %ebx,%edx
f0102347:	74 07                	je     f0102350 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0102349:	83 c0 01             	add    $0x1,%eax
f010234c:	39 c8                	cmp    %ecx,%eax
f010234e:	72 f2                	jb     f0102342 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0102350:	5b                   	pop    %ebx
f0102351:	5d                   	pop    %ebp
f0102352:	c3                   	ret    

f0102353 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0102353:	55                   	push   %ebp
f0102354:	89 e5                	mov    %esp,%ebp
f0102356:	57                   	push   %edi
f0102357:	56                   	push   %esi
f0102358:	53                   	push   %ebx
f0102359:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010235c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010235f:	eb 03                	jmp    f0102364 <strtol+0x11>
		s++;
f0102361:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102364:	0f b6 01             	movzbl (%ecx),%eax
f0102367:	3c 20                	cmp    $0x20,%al
f0102369:	74 f6                	je     f0102361 <strtol+0xe>
f010236b:	3c 09                	cmp    $0x9,%al
f010236d:	74 f2                	je     f0102361 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010236f:	3c 2b                	cmp    $0x2b,%al
f0102371:	75 0a                	jne    f010237d <strtol+0x2a>
		s++;
f0102373:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0102376:	bf 00 00 00 00       	mov    $0x0,%edi
f010237b:	eb 11                	jmp    f010238e <strtol+0x3b>
f010237d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0102382:	3c 2d                	cmp    $0x2d,%al
f0102384:	75 08                	jne    f010238e <strtol+0x3b>
		s++, neg = 1;
f0102386:	83 c1 01             	add    $0x1,%ecx
f0102389:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010238e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0102394:	75 15                	jne    f01023ab <strtol+0x58>
f0102396:	80 39 30             	cmpb   $0x30,(%ecx)
f0102399:	75 10                	jne    f01023ab <strtol+0x58>
f010239b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010239f:	75 7c                	jne    f010241d <strtol+0xca>
		s += 2, base = 16;
f01023a1:	83 c1 02             	add    $0x2,%ecx
f01023a4:	bb 10 00 00 00       	mov    $0x10,%ebx
f01023a9:	eb 16                	jmp    f01023c1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01023ab:	85 db                	test   %ebx,%ebx
f01023ad:	75 12                	jne    f01023c1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01023af:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01023b4:	80 39 30             	cmpb   $0x30,(%ecx)
f01023b7:	75 08                	jne    f01023c1 <strtol+0x6e>
		s++, base = 8;
f01023b9:	83 c1 01             	add    $0x1,%ecx
f01023bc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01023c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01023c6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01023c9:	0f b6 11             	movzbl (%ecx),%edx
f01023cc:	8d 72 d0             	lea    -0x30(%edx),%esi
f01023cf:	89 f3                	mov    %esi,%ebx
f01023d1:	80 fb 09             	cmp    $0x9,%bl
f01023d4:	77 08                	ja     f01023de <strtol+0x8b>
			dig = *s - '0';
f01023d6:	0f be d2             	movsbl %dl,%edx
f01023d9:	83 ea 30             	sub    $0x30,%edx
f01023dc:	eb 22                	jmp    f0102400 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01023de:	8d 72 9f             	lea    -0x61(%edx),%esi
f01023e1:	89 f3                	mov    %esi,%ebx
f01023e3:	80 fb 19             	cmp    $0x19,%bl
f01023e6:	77 08                	ja     f01023f0 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01023e8:	0f be d2             	movsbl %dl,%edx
f01023eb:	83 ea 57             	sub    $0x57,%edx
f01023ee:	eb 10                	jmp    f0102400 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01023f0:	8d 72 bf             	lea    -0x41(%edx),%esi
f01023f3:	89 f3                	mov    %esi,%ebx
f01023f5:	80 fb 19             	cmp    $0x19,%bl
f01023f8:	77 16                	ja     f0102410 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01023fa:	0f be d2             	movsbl %dl,%edx
f01023fd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0102400:	3b 55 10             	cmp    0x10(%ebp),%edx
f0102403:	7d 0b                	jge    f0102410 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0102405:	83 c1 01             	add    $0x1,%ecx
f0102408:	0f af 45 10          	imul   0x10(%ebp),%eax
f010240c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010240e:	eb b9                	jmp    f01023c9 <strtol+0x76>

	if (endptr)
f0102410:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0102414:	74 0d                	je     f0102423 <strtol+0xd0>
		*endptr = (char *) s;
f0102416:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102419:	89 0e                	mov    %ecx,(%esi)
f010241b:	eb 06                	jmp    f0102423 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010241d:	85 db                	test   %ebx,%ebx
f010241f:	74 98                	je     f01023b9 <strtol+0x66>
f0102421:	eb 9e                	jmp    f01023c1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0102423:	89 c2                	mov    %eax,%edx
f0102425:	f7 da                	neg    %edx
f0102427:	85 ff                	test   %edi,%edi
f0102429:	0f 45 c2             	cmovne %edx,%eax
}
f010242c:	5b                   	pop    %ebx
f010242d:	5e                   	pop    %esi
f010242e:	5f                   	pop    %edi
f010242f:	5d                   	pop    %ebp
f0102430:	c3                   	ret    
f0102431:	66 90                	xchg   %ax,%ax
f0102433:	66 90                	xchg   %ax,%ax
f0102435:	66 90                	xchg   %ax,%ax
f0102437:	66 90                	xchg   %ax,%ax
f0102439:	66 90                	xchg   %ax,%ax
f010243b:	66 90                	xchg   %ax,%ax
f010243d:	66 90                	xchg   %ax,%ax
f010243f:	90                   	nop

f0102440 <__udivdi3>:
f0102440:	55                   	push   %ebp
f0102441:	57                   	push   %edi
f0102442:	56                   	push   %esi
f0102443:	53                   	push   %ebx
f0102444:	83 ec 1c             	sub    $0x1c,%esp
f0102447:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010244b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010244f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0102453:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0102457:	85 f6                	test   %esi,%esi
f0102459:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010245d:	89 ca                	mov    %ecx,%edx
f010245f:	89 f8                	mov    %edi,%eax
f0102461:	75 3d                	jne    f01024a0 <__udivdi3+0x60>
f0102463:	39 cf                	cmp    %ecx,%edi
f0102465:	0f 87 c5 00 00 00    	ja     f0102530 <__udivdi3+0xf0>
f010246b:	85 ff                	test   %edi,%edi
f010246d:	89 fd                	mov    %edi,%ebp
f010246f:	75 0b                	jne    f010247c <__udivdi3+0x3c>
f0102471:	b8 01 00 00 00       	mov    $0x1,%eax
f0102476:	31 d2                	xor    %edx,%edx
f0102478:	f7 f7                	div    %edi
f010247a:	89 c5                	mov    %eax,%ebp
f010247c:	89 c8                	mov    %ecx,%eax
f010247e:	31 d2                	xor    %edx,%edx
f0102480:	f7 f5                	div    %ebp
f0102482:	89 c1                	mov    %eax,%ecx
f0102484:	89 d8                	mov    %ebx,%eax
f0102486:	89 cf                	mov    %ecx,%edi
f0102488:	f7 f5                	div    %ebp
f010248a:	89 c3                	mov    %eax,%ebx
f010248c:	89 d8                	mov    %ebx,%eax
f010248e:	89 fa                	mov    %edi,%edx
f0102490:	83 c4 1c             	add    $0x1c,%esp
f0102493:	5b                   	pop    %ebx
f0102494:	5e                   	pop    %esi
f0102495:	5f                   	pop    %edi
f0102496:	5d                   	pop    %ebp
f0102497:	c3                   	ret    
f0102498:	90                   	nop
f0102499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01024a0:	39 ce                	cmp    %ecx,%esi
f01024a2:	77 74                	ja     f0102518 <__udivdi3+0xd8>
f01024a4:	0f bd fe             	bsr    %esi,%edi
f01024a7:	83 f7 1f             	xor    $0x1f,%edi
f01024aa:	0f 84 98 00 00 00    	je     f0102548 <__udivdi3+0x108>
f01024b0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01024b5:	89 f9                	mov    %edi,%ecx
f01024b7:	89 c5                	mov    %eax,%ebp
f01024b9:	29 fb                	sub    %edi,%ebx
f01024bb:	d3 e6                	shl    %cl,%esi
f01024bd:	89 d9                	mov    %ebx,%ecx
f01024bf:	d3 ed                	shr    %cl,%ebp
f01024c1:	89 f9                	mov    %edi,%ecx
f01024c3:	d3 e0                	shl    %cl,%eax
f01024c5:	09 ee                	or     %ebp,%esi
f01024c7:	89 d9                	mov    %ebx,%ecx
f01024c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024cd:	89 d5                	mov    %edx,%ebp
f01024cf:	8b 44 24 08          	mov    0x8(%esp),%eax
f01024d3:	d3 ed                	shr    %cl,%ebp
f01024d5:	89 f9                	mov    %edi,%ecx
f01024d7:	d3 e2                	shl    %cl,%edx
f01024d9:	89 d9                	mov    %ebx,%ecx
f01024db:	d3 e8                	shr    %cl,%eax
f01024dd:	09 c2                	or     %eax,%edx
f01024df:	89 d0                	mov    %edx,%eax
f01024e1:	89 ea                	mov    %ebp,%edx
f01024e3:	f7 f6                	div    %esi
f01024e5:	89 d5                	mov    %edx,%ebp
f01024e7:	89 c3                	mov    %eax,%ebx
f01024e9:	f7 64 24 0c          	mull   0xc(%esp)
f01024ed:	39 d5                	cmp    %edx,%ebp
f01024ef:	72 10                	jb     f0102501 <__udivdi3+0xc1>
f01024f1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01024f5:	89 f9                	mov    %edi,%ecx
f01024f7:	d3 e6                	shl    %cl,%esi
f01024f9:	39 c6                	cmp    %eax,%esi
f01024fb:	73 07                	jae    f0102504 <__udivdi3+0xc4>
f01024fd:	39 d5                	cmp    %edx,%ebp
f01024ff:	75 03                	jne    f0102504 <__udivdi3+0xc4>
f0102501:	83 eb 01             	sub    $0x1,%ebx
f0102504:	31 ff                	xor    %edi,%edi
f0102506:	89 d8                	mov    %ebx,%eax
f0102508:	89 fa                	mov    %edi,%edx
f010250a:	83 c4 1c             	add    $0x1c,%esp
f010250d:	5b                   	pop    %ebx
f010250e:	5e                   	pop    %esi
f010250f:	5f                   	pop    %edi
f0102510:	5d                   	pop    %ebp
f0102511:	c3                   	ret    
f0102512:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102518:	31 ff                	xor    %edi,%edi
f010251a:	31 db                	xor    %ebx,%ebx
f010251c:	89 d8                	mov    %ebx,%eax
f010251e:	89 fa                	mov    %edi,%edx
f0102520:	83 c4 1c             	add    $0x1c,%esp
f0102523:	5b                   	pop    %ebx
f0102524:	5e                   	pop    %esi
f0102525:	5f                   	pop    %edi
f0102526:	5d                   	pop    %ebp
f0102527:	c3                   	ret    
f0102528:	90                   	nop
f0102529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0102530:	89 d8                	mov    %ebx,%eax
f0102532:	f7 f7                	div    %edi
f0102534:	31 ff                	xor    %edi,%edi
f0102536:	89 c3                	mov    %eax,%ebx
f0102538:	89 d8                	mov    %ebx,%eax
f010253a:	89 fa                	mov    %edi,%edx
f010253c:	83 c4 1c             	add    $0x1c,%esp
f010253f:	5b                   	pop    %ebx
f0102540:	5e                   	pop    %esi
f0102541:	5f                   	pop    %edi
f0102542:	5d                   	pop    %ebp
f0102543:	c3                   	ret    
f0102544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102548:	39 ce                	cmp    %ecx,%esi
f010254a:	72 0c                	jb     f0102558 <__udivdi3+0x118>
f010254c:	31 db                	xor    %ebx,%ebx
f010254e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0102552:	0f 87 34 ff ff ff    	ja     f010248c <__udivdi3+0x4c>
f0102558:	bb 01 00 00 00       	mov    $0x1,%ebx
f010255d:	e9 2a ff ff ff       	jmp    f010248c <__udivdi3+0x4c>
f0102562:	66 90                	xchg   %ax,%ax
f0102564:	66 90                	xchg   %ax,%ax
f0102566:	66 90                	xchg   %ax,%ax
f0102568:	66 90                	xchg   %ax,%ax
f010256a:	66 90                	xchg   %ax,%ax
f010256c:	66 90                	xchg   %ax,%ax
f010256e:	66 90                	xchg   %ax,%ax

f0102570 <__umoddi3>:
f0102570:	55                   	push   %ebp
f0102571:	57                   	push   %edi
f0102572:	56                   	push   %esi
f0102573:	53                   	push   %ebx
f0102574:	83 ec 1c             	sub    $0x1c,%esp
f0102577:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010257b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010257f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0102583:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0102587:	85 d2                	test   %edx,%edx
f0102589:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010258d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102591:	89 f3                	mov    %esi,%ebx
f0102593:	89 3c 24             	mov    %edi,(%esp)
f0102596:	89 74 24 04          	mov    %esi,0x4(%esp)
f010259a:	75 1c                	jne    f01025b8 <__umoddi3+0x48>
f010259c:	39 f7                	cmp    %esi,%edi
f010259e:	76 50                	jbe    f01025f0 <__umoddi3+0x80>
f01025a0:	89 c8                	mov    %ecx,%eax
f01025a2:	89 f2                	mov    %esi,%edx
f01025a4:	f7 f7                	div    %edi
f01025a6:	89 d0                	mov    %edx,%eax
f01025a8:	31 d2                	xor    %edx,%edx
f01025aa:	83 c4 1c             	add    $0x1c,%esp
f01025ad:	5b                   	pop    %ebx
f01025ae:	5e                   	pop    %esi
f01025af:	5f                   	pop    %edi
f01025b0:	5d                   	pop    %ebp
f01025b1:	c3                   	ret    
f01025b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01025b8:	39 f2                	cmp    %esi,%edx
f01025ba:	89 d0                	mov    %edx,%eax
f01025bc:	77 52                	ja     f0102610 <__umoddi3+0xa0>
f01025be:	0f bd ea             	bsr    %edx,%ebp
f01025c1:	83 f5 1f             	xor    $0x1f,%ebp
f01025c4:	75 5a                	jne    f0102620 <__umoddi3+0xb0>
f01025c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01025ca:	0f 82 e0 00 00 00    	jb     f01026b0 <__umoddi3+0x140>
f01025d0:	39 0c 24             	cmp    %ecx,(%esp)
f01025d3:	0f 86 d7 00 00 00    	jbe    f01026b0 <__umoddi3+0x140>
f01025d9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01025dd:	8b 54 24 04          	mov    0x4(%esp),%edx
f01025e1:	83 c4 1c             	add    $0x1c,%esp
f01025e4:	5b                   	pop    %ebx
f01025e5:	5e                   	pop    %esi
f01025e6:	5f                   	pop    %edi
f01025e7:	5d                   	pop    %ebp
f01025e8:	c3                   	ret    
f01025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01025f0:	85 ff                	test   %edi,%edi
f01025f2:	89 fd                	mov    %edi,%ebp
f01025f4:	75 0b                	jne    f0102601 <__umoddi3+0x91>
f01025f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01025fb:	31 d2                	xor    %edx,%edx
f01025fd:	f7 f7                	div    %edi
f01025ff:	89 c5                	mov    %eax,%ebp
f0102601:	89 f0                	mov    %esi,%eax
f0102603:	31 d2                	xor    %edx,%edx
f0102605:	f7 f5                	div    %ebp
f0102607:	89 c8                	mov    %ecx,%eax
f0102609:	f7 f5                	div    %ebp
f010260b:	89 d0                	mov    %edx,%eax
f010260d:	eb 99                	jmp    f01025a8 <__umoddi3+0x38>
f010260f:	90                   	nop
f0102610:	89 c8                	mov    %ecx,%eax
f0102612:	89 f2                	mov    %esi,%edx
f0102614:	83 c4 1c             	add    $0x1c,%esp
f0102617:	5b                   	pop    %ebx
f0102618:	5e                   	pop    %esi
f0102619:	5f                   	pop    %edi
f010261a:	5d                   	pop    %ebp
f010261b:	c3                   	ret    
f010261c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102620:	8b 34 24             	mov    (%esp),%esi
f0102623:	bf 20 00 00 00       	mov    $0x20,%edi
f0102628:	89 e9                	mov    %ebp,%ecx
f010262a:	29 ef                	sub    %ebp,%edi
f010262c:	d3 e0                	shl    %cl,%eax
f010262e:	89 f9                	mov    %edi,%ecx
f0102630:	89 f2                	mov    %esi,%edx
f0102632:	d3 ea                	shr    %cl,%edx
f0102634:	89 e9                	mov    %ebp,%ecx
f0102636:	09 c2                	or     %eax,%edx
f0102638:	89 d8                	mov    %ebx,%eax
f010263a:	89 14 24             	mov    %edx,(%esp)
f010263d:	89 f2                	mov    %esi,%edx
f010263f:	d3 e2                	shl    %cl,%edx
f0102641:	89 f9                	mov    %edi,%ecx
f0102643:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102647:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010264b:	d3 e8                	shr    %cl,%eax
f010264d:	89 e9                	mov    %ebp,%ecx
f010264f:	89 c6                	mov    %eax,%esi
f0102651:	d3 e3                	shl    %cl,%ebx
f0102653:	89 f9                	mov    %edi,%ecx
f0102655:	89 d0                	mov    %edx,%eax
f0102657:	d3 e8                	shr    %cl,%eax
f0102659:	89 e9                	mov    %ebp,%ecx
f010265b:	09 d8                	or     %ebx,%eax
f010265d:	89 d3                	mov    %edx,%ebx
f010265f:	89 f2                	mov    %esi,%edx
f0102661:	f7 34 24             	divl   (%esp)
f0102664:	89 d6                	mov    %edx,%esi
f0102666:	d3 e3                	shl    %cl,%ebx
f0102668:	f7 64 24 04          	mull   0x4(%esp)
f010266c:	39 d6                	cmp    %edx,%esi
f010266e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102672:	89 d1                	mov    %edx,%ecx
f0102674:	89 c3                	mov    %eax,%ebx
f0102676:	72 08                	jb     f0102680 <__umoddi3+0x110>
f0102678:	75 11                	jne    f010268b <__umoddi3+0x11b>
f010267a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010267e:	73 0b                	jae    f010268b <__umoddi3+0x11b>
f0102680:	2b 44 24 04          	sub    0x4(%esp),%eax
f0102684:	1b 14 24             	sbb    (%esp),%edx
f0102687:	89 d1                	mov    %edx,%ecx
f0102689:	89 c3                	mov    %eax,%ebx
f010268b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010268f:	29 da                	sub    %ebx,%edx
f0102691:	19 ce                	sbb    %ecx,%esi
f0102693:	89 f9                	mov    %edi,%ecx
f0102695:	89 f0                	mov    %esi,%eax
f0102697:	d3 e0                	shl    %cl,%eax
f0102699:	89 e9                	mov    %ebp,%ecx
f010269b:	d3 ea                	shr    %cl,%edx
f010269d:	89 e9                	mov    %ebp,%ecx
f010269f:	d3 ee                	shr    %cl,%esi
f01026a1:	09 d0                	or     %edx,%eax
f01026a3:	89 f2                	mov    %esi,%edx
f01026a5:	83 c4 1c             	add    $0x1c,%esp
f01026a8:	5b                   	pop    %ebx
f01026a9:	5e                   	pop    %esi
f01026aa:	5f                   	pop    %edi
f01026ab:	5d                   	pop    %ebp
f01026ac:	c3                   	ret    
f01026ad:	8d 76 00             	lea    0x0(%esi),%esi
f01026b0:	29 f9                	sub    %edi,%ecx
f01026b2:	19 d6                	sbb    %edx,%esi
f01026b4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01026b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01026bc:	e9 18 ff ff ff       	jmp    f01025d9 <__umoddi3+0x69>
