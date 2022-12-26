
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
f0100015:	b8 00 10 11 00       	mov    $0x111000,%eax
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
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

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
f0100046:	b8 60 39 11 f0       	mov    $0xf0113960,%eax
f010004b:	2d 00 33 11 f0       	sub    $0xf0113300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 33 11 f0       	push   $0xf0113300
f0100058:	e8 13 1a 00 00       	call   f0101a70 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 96 04 00 00       	call   f01004f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 20 1f 10 f0       	push   $0xf0101f20
f010006f:	e8 38 0f 00 00       	call   f0100fac <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 d8 0a 00 00       	call   f0100b51 <mem_init>
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
f0100093:	83 3d 64 39 11 f0 00 	cmpl   $0x0,0xf0113964
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 64 39 11 f0    	mov    %esi,0xf0113964

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
f01000b0:	68 3b 1f 10 f0       	push   $0xf0101f3b
f01000b5:	e8 f2 0e 00 00       	call   f0100fac <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 c2 0e 00 00       	call   f0100f86 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 77 1f 10 f0 	movl   $0xf0101f77,(%esp)
f01000cb:	e8 dc 0e 00 00       	call   f0100fac <cprintf>
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
f01000f2:	68 53 1f 10 f0       	push   $0xf0101f53
f01000f7:	e8 b0 0e 00 00       	call   f0100fac <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 7e 0e 00 00       	call   f0100f86 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 77 1f 10 f0 	movl   $0xf0101f77,(%esp)
f010010f:	e8 98 0e 00 00       	call   f0100fac <cprintf>
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
f010014a:	8b 0d 24 35 11 f0    	mov    0xf0113524,%ecx
f0100150:	8d 51 01             	lea    0x1(%ecx),%edx
f0100153:	89 15 24 35 11 f0    	mov    %edx,0xf0113524
f0100159:	88 81 20 33 11 f0    	mov    %al,-0xfeecce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010015f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100165:	75 0a                	jne    f0100171 <cons_intr+0x36>
			cons.wpos = 0;
f0100167:	c7 05 24 35 11 f0 00 	movl   $0x0,0xf0113524
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
f01001a0:	83 0d 00 33 11 f0 40 	orl    $0x40,0xf0113300
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
f01001b8:	8b 0d 00 33 11 f0    	mov    0xf0113300,%ecx
f01001be:	89 cb                	mov    %ecx,%ebx
f01001c0:	83 e3 40             	and    $0x40,%ebx
f01001c3:	83 e0 7f             	and    $0x7f,%eax
f01001c6:	85 db                	test   %ebx,%ebx
f01001c8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001cb:	0f b6 d2             	movzbl %dl,%edx
f01001ce:	0f b6 82 c0 20 10 f0 	movzbl -0xfefdf40(%edx),%eax
f01001d5:	83 c8 40             	or     $0x40,%eax
f01001d8:	0f b6 c0             	movzbl %al,%eax
f01001db:	f7 d0                	not    %eax
f01001dd:	21 c8                	and    %ecx,%eax
f01001df:	a3 00 33 11 f0       	mov    %eax,0xf0113300
		return 0;
f01001e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01001e9:	e9 a4 00 00 00       	jmp    f0100292 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f01001ee:	8b 0d 00 33 11 f0    	mov    0xf0113300,%ecx
f01001f4:	f6 c1 40             	test   $0x40,%cl
f01001f7:	74 0e                	je     f0100207 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001f9:	83 c8 80             	or     $0xffffff80,%eax
f01001fc:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001fe:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100201:	89 0d 00 33 11 f0    	mov    %ecx,0xf0113300
	}

	shift |= shiftcode[data];
f0100207:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010020a:	0f b6 82 c0 20 10 f0 	movzbl -0xfefdf40(%edx),%eax
f0100211:	0b 05 00 33 11 f0    	or     0xf0113300,%eax
f0100217:	0f b6 8a c0 1f 10 f0 	movzbl -0xfefe040(%edx),%ecx
f010021e:	31 c8                	xor    %ecx,%eax
f0100220:	a3 00 33 11 f0       	mov    %eax,0xf0113300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100225:	89 c1                	mov    %eax,%ecx
f0100227:	83 e1 03             	and    $0x3,%ecx
f010022a:	8b 0c 8d a0 1f 10 f0 	mov    -0xfefe060(,%ecx,4),%ecx
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
f0100268:	68 6d 1f 10 f0       	push   $0xf0101f6d
f010026d:	e8 3a 0d 00 00       	call   f0100fac <cprintf>
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
f0100354:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f010035b:	66 85 c0             	test   %ax,%ax
f010035e:	0f 84 e6 00 00 00    	je     f010044a <cons_putc+0x1b3>
			crt_pos--;
f0100364:	83 e8 01             	sub    $0x1,%eax
f0100367:	66 a3 28 35 11 f0    	mov    %ax,0xf0113528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010036d:	0f b7 c0             	movzwl %ax,%eax
f0100370:	66 81 e7 00 ff       	and    $0xff00,%di
f0100375:	83 cf 20             	or     $0x20,%edi
f0100378:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
f010037e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100382:	eb 78                	jmp    f01003fc <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100384:	66 83 05 28 35 11 f0 	addw   $0x50,0xf0113528
f010038b:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010038c:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f0100393:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100399:	c1 e8 16             	shr    $0x16,%eax
f010039c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010039f:	c1 e0 04             	shl    $0x4,%eax
f01003a2:	66 a3 28 35 11 f0    	mov    %ax,0xf0113528
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
f01003de:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f01003e5:	8d 50 01             	lea    0x1(%eax),%edx
f01003e8:	66 89 15 28 35 11 f0 	mov    %dx,0xf0113528
f01003ef:	0f b7 c0             	movzwl %ax,%eax
f01003f2:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
f01003f8:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003fc:	66 81 3d 28 35 11 f0 	cmpw   $0x7cf,0xf0113528
f0100403:	cf 07 
f0100405:	76 43                	jbe    f010044a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100407:	a1 2c 35 11 f0       	mov    0xf011352c,%eax
f010040c:	83 ec 04             	sub    $0x4,%esp
f010040f:	68 00 0f 00 00       	push   $0xf00
f0100414:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010041a:	52                   	push   %edx
f010041b:	50                   	push   %eax
f010041c:	e8 9c 16 00 00       	call   f0101abd <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100421:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
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
f0100442:	66 83 2d 28 35 11 f0 	subw   $0x50,0xf0113528
f0100449:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010044a:	8b 0d 30 35 11 f0    	mov    0xf0113530,%ecx
f0100450:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100455:	89 ca                	mov    %ecx,%edx
f0100457:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100458:	0f b7 1d 28 35 11 f0 	movzwl 0xf0113528,%ebx
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
f0100480:	80 3d 34 35 11 f0 00 	cmpb   $0x0,0xf0113534
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
f01004be:	a1 20 35 11 f0       	mov    0xf0113520,%eax
f01004c3:	3b 05 24 35 11 f0    	cmp    0xf0113524,%eax
f01004c9:	74 26                	je     f01004f1 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004cb:	8d 50 01             	lea    0x1(%eax),%edx
f01004ce:	89 15 20 35 11 f0    	mov    %edx,0xf0113520
f01004d4:	0f b6 88 20 33 11 f0 	movzbl -0xfeecce0(%eax),%ecx
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
f01004e5:	c7 05 20 35 11 f0 00 	movl   $0x0,0xf0113520
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
f010051e:	c7 05 30 35 11 f0 b4 	movl   $0x3b4,0xf0113530
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
f0100536:	c7 05 30 35 11 f0 d4 	movl   $0x3d4,0xf0113530
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
f0100545:	8b 3d 30 35 11 f0    	mov    0xf0113530,%edi
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
f010056a:	89 35 2c 35 11 f0    	mov    %esi,0xf011352c
	crt_pos = pos;
f0100570:	0f b6 c0             	movzbl %al,%eax
f0100573:	09 c8                	or     %ecx,%eax
f0100575:	66 a3 28 35 11 f0    	mov    %ax,0xf0113528
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
f01005d6:	0f 95 05 34 35 11 f0 	setne  0xf0113534
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
f01005eb:	68 79 1f 10 f0       	push   $0xf0101f79
f01005f0:	e8 b7 09 00 00       	call   f0100fac <cprintf>
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
f0100631:	68 c0 21 10 f0       	push   $0xf01021c0
f0100636:	68 de 21 10 f0       	push   $0xf01021de
f010063b:	68 e3 21 10 f0       	push   $0xf01021e3
f0100640:	e8 67 09 00 00       	call   f0100fac <cprintf>
f0100645:	83 c4 0c             	add    $0xc,%esp
f0100648:	68 9c 22 10 f0       	push   $0xf010229c
f010064d:	68 ec 21 10 f0       	push   $0xf01021ec
f0100652:	68 e3 21 10 f0       	push   $0xf01021e3
f0100657:	e8 50 09 00 00       	call   f0100fac <cprintf>
f010065c:	83 c4 0c             	add    $0xc,%esp
f010065f:	68 f5 21 10 f0       	push   $0xf01021f5
f0100664:	68 13 22 10 f0       	push   $0xf0102213
f0100669:	68 e3 21 10 f0       	push   $0xf01021e3
f010066e:	e8 39 09 00 00       	call   f0100fac <cprintf>
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
f0100680:	68 1d 22 10 f0       	push   $0xf010221d
f0100685:	e8 22 09 00 00       	call   f0100fac <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010068a:	83 c4 08             	add    $0x8,%esp
f010068d:	68 0c 00 10 00       	push   $0x10000c
f0100692:	68 c4 22 10 f0       	push   $0xf01022c4
f0100697:	e8 10 09 00 00       	call   f0100fac <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010069c:	83 c4 0c             	add    $0xc,%esp
f010069f:	68 0c 00 10 00       	push   $0x10000c
f01006a4:	68 0c 00 10 f0       	push   $0xf010000c
f01006a9:	68 ec 22 10 f0       	push   $0xf01022ec
f01006ae:	e8 f9 08 00 00       	call   f0100fac <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b3:	83 c4 0c             	add    $0xc,%esp
f01006b6:	68 01 1f 10 00       	push   $0x101f01
f01006bb:	68 01 1f 10 f0       	push   $0xf0101f01
f01006c0:	68 10 23 10 f0       	push   $0xf0102310
f01006c5:	e8 e2 08 00 00       	call   f0100fac <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ca:	83 c4 0c             	add    $0xc,%esp
f01006cd:	68 00 33 11 00       	push   $0x113300
f01006d2:	68 00 33 11 f0       	push   $0xf0113300
f01006d7:	68 34 23 10 f0       	push   $0xf0102334
f01006dc:	e8 cb 08 00 00       	call   f0100fac <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e1:	83 c4 0c             	add    $0xc,%esp
f01006e4:	68 60 39 11 00       	push   $0x113960
f01006e9:	68 60 39 11 f0       	push   $0xf0113960
f01006ee:	68 58 23 10 f0       	push   $0xf0102358
f01006f3:	e8 b4 08 00 00       	call   f0100fac <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006f8:	b8 5f 3d 11 f0       	mov    $0xf0113d5f,%eax
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
f0100719:	68 7c 23 10 f0       	push   $0xf010237c
f010071e:	e8 89 08 00 00       	call   f0100fac <cprintf>
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
f0100758:	68 36 22 10 f0       	push   $0xf0102236
f010075d:	e8 4a 08 00 00       	call   f0100fac <cprintf>

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
f010078a:	e8 27 09 00 00       	call   f01010b6 <debuginfo_eip>

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
f01007e6:	68 a8 23 10 f0       	push   $0xf01023a8
f01007eb:	e8 bc 07 00 00       	call   f0100fac <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f01007f0:	83 c4 14             	add    $0x14,%esp
f01007f3:	2b 75 cc             	sub    -0x34(%ebp),%esi
f01007f6:	56                   	push   %esi
f01007f7:	8d 45 8a             	lea    -0x76(%ebp),%eax
f01007fa:	50                   	push   %eax
f01007fb:	ff 75 c0             	pushl  -0x40(%ebp)
f01007fe:	ff 75 bc             	pushl  -0x44(%ebp)
f0100801:	68 48 22 10 f0       	push   $0xf0102248
f0100806:	e8 a1 07 00 00       	call   f0100fac <cprintf>

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
f010082e:	68 e0 23 10 f0       	push   $0xf01023e0
f0100833:	e8 74 07 00 00       	call   f0100fac <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100838:	c7 04 24 04 24 10 f0 	movl   $0xf0102404,(%esp)
f010083f:	e8 68 07 00 00       	call   f0100fac <cprintf>
f0100844:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100847:	83 ec 0c             	sub    $0xc,%esp
f010084a:	68 5f 22 10 f0       	push   $0xf010225f
f010084f:	e8 c5 0f 00 00       	call   f0101819 <readline>
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
f0100883:	68 63 22 10 f0       	push   $0xf0102263
f0100888:	e8 a6 11 00 00       	call   f0101a33 <strchr>
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
f01008a3:	68 68 22 10 f0       	push   $0xf0102268
f01008a8:	e8 ff 06 00 00       	call   f0100fac <cprintf>
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
f01008cc:	68 63 22 10 f0       	push   $0xf0102263
f01008d1:	e8 5d 11 00 00       	call   f0101a33 <strchr>
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
f01008fa:	ff 34 85 40 24 10 f0 	pushl  -0xfefdbc0(,%eax,4)
f0100901:	ff 75 a8             	pushl  -0x58(%ebp)
f0100904:	e8 cc 10 00 00       	call   f01019d5 <strcmp>
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
f010091e:	ff 14 85 48 24 10 f0 	call   *-0xfefdbb8(,%eax,4)


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
f010093f:	68 85 22 10 f0       	push   $0xf0102285
f0100944:	e8 63 06 00 00       	call   f0100fac <cprintf>
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
f0100964:	e8 dc 05 00 00       	call   f0100f45 <mc146818_read>
f0100969:	89 c6                	mov    %eax,%esi
f010096b:	83 c3 01             	add    $0x1,%ebx
f010096e:	89 1c 24             	mov    %ebx,(%esp)
f0100971:	e8 cf 05 00 00       	call   f0100f45 <mc146818_read>
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
f0100982:	83 3d 38 35 11 f0 00 	cmpl   $0x0,0xf0113538
f0100989:	75 11                	jne    f010099c <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010098b:	ba 5f 49 11 f0       	mov    $0xf011495f,%edx
f0100990:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100996:	89 15 38 35 11 f0    	mov    %edx,0xf0113538
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f010099c:	8b 15 38 35 11 f0    	mov    0xf0113538,%edx
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
f01009b0:	68 64 24 10 f0       	push   $0xf0102464
f01009b5:	6a 6b                	push   $0x6b
f01009b7:	68 7f 24 10 f0       	push   $0xf010247f
f01009bc:	e8 ca f6 ff ff       	call   f010008b <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f01009c1:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f01009c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009cd:	a3 38 35 11 f0       	mov    %eax,0xf0113538

	return result;
}
f01009d2:	89 d0                	mov    %edx,%eax
f01009d4:	c3                   	ret    

f01009d5 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01009d5:	55                   	push   %ebp
f01009d6:	89 e5                	mov    %esp,%ebp
f01009d8:	56                   	push   %esi
f01009d9:	53                   	push   %ebx
	// 	pages[i].pp_link = page_free_list;
	// 	page_free_list = &pages[i];
	// }

	// 1)	first page in use
	pages[0].pp_ref = 1;
f01009da:	a1 70 39 11 f0       	mov    0xf0113970,%eax
f01009df:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f01009e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f01009eb:	8b 35 40 35 11 f0    	mov    0xf0113540,%esi
f01009f1:	8b 0d 3c 35 11 f0    	mov    0xf011353c,%ecx
f01009f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01009fc:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100a01:	eb 27                	jmp    f0100a2a <page_init+0x55>
		pages[i].pp_ref = 0;
f0100a03:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100a0a:	89 c2                	mov    %eax,%edx
f0100a0c:	03 15 70 39 11 f0    	add    0xf0113970,%edx
f0100a12:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100a18:	89 0a                	mov    %ecx,(%edx)
	// 1)	first page in use
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100a1a:	83 c3 01             	add    $0x1,%ebx
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100a1d:	03 05 70 39 11 f0    	add    0xf0113970,%eax
f0100a23:	89 c1                	mov    %eax,%ecx
f0100a25:	b8 01 00 00 00       	mov    $0x1,%eax
	// 1)	first page in use
	pages[0].pp_ref = 1;
	pages[0].pp_link = 0;

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100a2a:	39 f3                	cmp    %esi,%ebx
f0100a2c:	72 d5                	jb     f0100a03 <page_init+0x2e>
f0100a2e:	84 c0                	test   %al,%al
f0100a30:	74 06                	je     f0100a38 <page_init+0x63>
f0100a32:	89 0d 3c 35 11 f0    	mov    %ecx,0xf011353c
f0100a38:	8b 0d 3c 35 11 f0    	mov    0xf011353c,%ecx
f0100a3e:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100a45:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a4a:	eb 23                	jmp    f0100a6f <page_init+0x9a>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100a4c:	89 c2                	mov    %eax,%edx
f0100a4e:	03 15 70 39 11 f0    	add    0xf0113970,%edx
f0100a54:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100a5a:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100a5c:	89 c1                	mov    %eax,%ecx
f0100a5e:	03 0d 70 39 11 f0    	add    0xf0113970,%ecx
		page_free_list = &pages[i];
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
f0100a64:	83 c3 01             	add    $0x1,%ebx
f0100a67:	83 c0 08             	add    $0x8,%eax
f0100a6a:	ba 01 00 00 00       	mov    $0x1,%edx
f0100a6f:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100a75:	76 d5                	jbe    f0100a4c <page_init+0x77>
f0100a77:	84 d2                	test   %dl,%dl
f0100a79:	74 06                	je     f0100a81 <page_init+0xac>
f0100a7b:	89 0d 3c 35 11 f0    	mov    %ecx,0xf011353c
f0100a81:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100a88:	eb 1a                	jmp    f0100aa4 <page_init+0xcf>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100a8a:	89 c2                	mov    %eax,%edx
f0100a8c:	03 15 70 39 11 f0    	add    0xf0113970,%edx
f0100a92:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = 0;
f0100a98:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
f0100a9e:	83 c3 01             	add    $0x1,%ebx
f0100aa1:	83 c0 08             	add    $0x8,%eax
f0100aa4:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100aaa:	76 de                	jbe    f0100a8a <page_init+0xb5>
f0100aac:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f0100ab3:	eb 1a                	jmp    f0100acf <page_init+0xfa>


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100ab5:	89 f0                	mov    %esi,%eax
f0100ab7:	03 05 70 39 11 f0    	add    0xf0113970,%eax
f0100abd:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = 0;
f0100ac3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}


	// cprintf("[?] %d\n", PADDR(boot_alloc(0)) / PGSIZE);
	// 4) [EXTPHYSMEM / PGSIZE, kernel end) in use
	for (; i < PADDR(boot_alloc(0)) / PGSIZE; i++) {
f0100ac9:	83 c3 01             	add    $0x1,%ebx
f0100acc:	83 c6 08             	add    $0x8,%esi
f0100acf:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ad4:	e8 a9 fe ff ff       	call   f0100982 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ad9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ade:	77 15                	ja     f0100af5 <page_init+0x120>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ae0:	50                   	push   %eax
f0100ae1:	68 68 25 10 f0       	push   $0xf0102568
f0100ae6:	68 2e 01 00 00       	push   $0x12e
f0100aeb:	68 7f 24 10 f0       	push   $0xf010247f
f0100af0:	e8 96 f5 ff ff       	call   f010008b <_panic>
f0100af5:	05 00 00 00 10       	add    $0x10000000,%eax
f0100afa:	c1 e8 0c             	shr    $0xc,%eax
f0100afd:	39 c3                	cmp    %eax,%ebx
f0100aff:	72 b4                	jb     f0100ab5 <page_init+0xe0>
f0100b01:	8b 0d 3c 35 11 f0    	mov    0xf011353c,%ecx
f0100b07:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100b0e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100b13:	eb 23                	jmp    f0100b38 <page_init+0x163>
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f0100b15:	89 c2                	mov    %eax,%edx
f0100b17:	03 15 70 39 11 f0    	add    0xf0113970,%edx
f0100b1d:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100b23:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100b25:	89 c1                	mov    %eax,%ecx
f0100b27:	03 0d 70 39 11 f0    	add    0xf0113970,%ecx
		pages[i].pp_link = 0;
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
f0100b2d:	83 c3 01             	add    $0x1,%ebx
f0100b30:	83 c0 08             	add    $0x8,%eax
f0100b33:	ba 01 00 00 00       	mov    $0x1,%edx
f0100b38:	3b 1d 68 39 11 f0    	cmp    0xf0113968,%ebx
f0100b3e:	72 d5                	jb     f0100b15 <page_init+0x140>
f0100b40:	84 d2                	test   %dl,%dl
f0100b42:	74 06                	je     f0100b4a <page_init+0x175>
f0100b44:	89 0d 3c 35 11 f0    	mov    %ecx,0xf011353c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

}
f0100b4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b4d:	5b                   	pop    %ebx
f0100b4e:	5e                   	pop    %esi
f0100b4f:	5d                   	pop    %ebp
f0100b50:	c3                   	ret    

f0100b51 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100b51:	55                   	push   %ebp
f0100b52:	89 e5                	mov    %esp,%ebp
f0100b54:	57                   	push   %edi
f0100b55:	56                   	push   %esi
f0100b56:	53                   	push   %ebx
f0100b57:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100b5a:	b8 15 00 00 00       	mov    $0x15,%eax
f0100b5f:	e8 f5 fd ff ff       	call   f0100959 <nvram_read>
f0100b64:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100b66:	b8 17 00 00 00       	mov    $0x17,%eax
f0100b6b:	e8 e9 fd ff ff       	call   f0100959 <nvram_read>
f0100b70:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100b72:	b8 34 00 00 00       	mov    $0x34,%eax
f0100b77:	e8 dd fd ff ff       	call   f0100959 <nvram_read>
f0100b7c:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0100b7f:	85 c0                	test   %eax,%eax
f0100b81:	74 07                	je     f0100b8a <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0100b83:	05 00 40 00 00       	add    $0x4000,%eax
f0100b88:	eb 0b                	jmp    f0100b95 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0100b8a:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0100b90:	85 f6                	test   %esi,%esi
f0100b92:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0100b95:	89 c2                	mov    %eax,%edx
f0100b97:	c1 ea 02             	shr    $0x2,%edx
f0100b9a:	89 15 68 39 11 f0    	mov    %edx,0xf0113968
	npages_basemem = basemem / (PGSIZE / 1024);
f0100ba0:	89 da                	mov    %ebx,%edx
f0100ba2:	c1 ea 02             	shr    $0x2,%edx
f0100ba5:	89 15 40 35 11 f0    	mov    %edx,0xf0113540

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100bab:	89 c2                	mov    %eax,%edx
f0100bad:	29 da                	sub    %ebx,%edx
f0100baf:	52                   	push   %edx
f0100bb0:	53                   	push   %ebx
f0100bb1:	50                   	push   %eax
f0100bb2:	68 8c 25 10 f0       	push   $0xf010258c
f0100bb7:	e8 f0 03 00 00       	call   f0100fac <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100bbc:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100bc1:	e8 bc fd ff ff       	call   f0100982 <boot_alloc>
f0100bc6:	a3 6c 39 11 f0       	mov    %eax,0xf011396c
	memset(kern_pgdir, 0, PGSIZE);
f0100bcb:	83 c4 0c             	add    $0xc,%esp
f0100bce:	68 00 10 00 00       	push   $0x1000
f0100bd3:	6a 00                	push   $0x0
f0100bd5:	50                   	push   %eax
f0100bd6:	e8 95 0e 00 00       	call   f0101a70 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100bdb:	a1 6c 39 11 f0       	mov    0xf011396c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100be0:	83 c4 10             	add    $0x10,%esp
f0100be3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100be8:	77 15                	ja     f0100bff <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100bea:	50                   	push   %eax
f0100beb:	68 68 25 10 f0       	push   $0xf0102568
f0100bf0:	68 96 00 00 00       	push   $0x96
f0100bf5:	68 7f 24 10 f0       	push   $0xf010247f
f0100bfa:	e8 8c f4 ff ff       	call   f010008b <_panic>
f0100bff:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100c05:	83 ca 05             	or     $0x5,%edx
f0100c08:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f0100c0e:	a1 68 39 11 f0       	mov    0xf0113968,%eax
f0100c13:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f0100c1a:	89 d8                	mov    %ebx,%eax
f0100c1c:	e8 61 fd ff ff       	call   f0100982 <boot_alloc>
f0100c21:	a3 70 39 11 f0       	mov    %eax,0xf0113970
	memset(pages, 0, n);
f0100c26:	83 ec 04             	sub    $0x4,%esp
f0100c29:	53                   	push   %ebx
f0100c2a:	6a 00                	push   $0x0
f0100c2c:	50                   	push   %eax
f0100c2d:	e8 3e 0e 00 00       	call   f0101a70 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0100c32:	e8 9e fd ff ff       	call   f01009d5 <page_init>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c37:	a1 3c 35 11 f0       	mov    0xf011353c,%eax
f0100c3c:	83 c4 10             	add    $0x10,%esp
f0100c3f:	85 c0                	test   %eax,%eax
f0100c41:	75 17                	jne    f0100c5a <mem_init+0x109>
		panic("'page_free_list' is a null pointer!");
f0100c43:	83 ec 04             	sub    $0x4,%esp
f0100c46:	68 c8 25 10 f0       	push   $0xf01025c8
f0100c4b:	68 f9 01 00 00       	push   $0x1f9
f0100c50:	68 7f 24 10 f0       	push   $0xf010247f
f0100c55:	e8 31 f4 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c5a:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c5d:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c60:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c63:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c66:	89 c2                	mov    %eax,%edx
f0100c68:	2b 15 70 39 11 f0    	sub    0xf0113970,%edx
f0100c6e:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c74:	0f 95 c2             	setne  %dl
f0100c77:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c7a:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c7e:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c80:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c84:	8b 00                	mov    (%eax),%eax
f0100c86:	85 c0                	test   %eax,%eax
f0100c88:	75 dc                	jne    f0100c66 <mem_init+0x115>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c8d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c93:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c96:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c99:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c9b:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100c9e:	89 1d 3c 35 11 f0    	mov    %ebx,0xf011353c
f0100ca4:	eb 54                	jmp    f0100cfa <mem_init+0x1a9>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ca6:	89 d8                	mov    %ebx,%eax
f0100ca8:	2b 05 70 39 11 f0    	sub    0xf0113970,%eax
f0100cae:	c1 f8 03             	sar    $0x3,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
f0100cb1:	89 c2                	mov    %eax,%edx
f0100cb3:	c1 e2 0c             	shl    $0xc,%edx
f0100cb6:	a9 00 fc 0f 00       	test   $0xffc00,%eax
f0100cbb:	75 3b                	jne    f0100cf8 <mem_init+0x1a7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cbd:	89 d0                	mov    %edx,%eax
f0100cbf:	c1 e8 0c             	shr    $0xc,%eax
f0100cc2:	3b 05 68 39 11 f0    	cmp    0xf0113968,%eax
f0100cc8:	72 12                	jb     f0100cdc <mem_init+0x18b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cca:	52                   	push   %edx
f0100ccb:	68 ec 25 10 f0       	push   $0xf01025ec
f0100cd0:	6a 52                	push   $0x52
f0100cd2:	68 8b 24 10 f0       	push   $0xf010248b
f0100cd7:	e8 af f3 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100cdc:	83 ec 04             	sub    $0x4,%esp
f0100cdf:	68 80 00 00 00       	push   $0x80
f0100ce4:	68 97 00 00 00       	push   $0x97
f0100ce9:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100cef:	52                   	push   %edx
f0100cf0:	e8 7b 0d 00 00       	call   f0101a70 <memset>
f0100cf5:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cf8:	8b 1b                	mov    (%ebx),%ebx
f0100cfa:	85 db                	test   %ebx,%ebx
f0100cfc:	75 a8                	jne    f0100ca6 <mem_init+0x155>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100cfe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d03:	e8 7a fc ff ff       	call   f0100982 <boot_alloc>
f0100d08:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d0b:	8b 15 3c 35 11 f0    	mov    0xf011353c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d11:	8b 0d 70 39 11 f0    	mov    0xf0113970,%ecx
		assert(pp < pages + npages);
f0100d17:	a1 68 39 11 f0       	mov    0xf0113968,%eax
f0100d1c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100d1f:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d22:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d25:	be 00 00 00 00       	mov    $0x0,%esi
f0100d2a:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100d2d:	e9 30 01 00 00       	jmp    f0100e62 <mem_init+0x311>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d32:	39 d1                	cmp    %edx,%ecx
f0100d34:	76 19                	jbe    f0100d4f <mem_init+0x1fe>
f0100d36:	68 99 24 10 f0       	push   $0xf0102499
f0100d3b:	68 a5 24 10 f0       	push   $0xf01024a5
f0100d40:	68 13 02 00 00       	push   $0x213
f0100d45:	68 7f 24 10 f0       	push   $0xf010247f
f0100d4a:	e8 3c f3 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100d4f:	39 fa                	cmp    %edi,%edx
f0100d51:	72 19                	jb     f0100d6c <mem_init+0x21b>
f0100d53:	68 ba 24 10 f0       	push   $0xf01024ba
f0100d58:	68 a5 24 10 f0       	push   $0xf01024a5
f0100d5d:	68 14 02 00 00       	push   $0x214
f0100d62:	68 7f 24 10 f0       	push   $0xf010247f
f0100d67:	e8 1f f3 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d6c:	89 d0                	mov    %edx,%eax
f0100d6e:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100d71:	a8 07                	test   $0x7,%al
f0100d73:	74 19                	je     f0100d8e <mem_init+0x23d>
f0100d75:	68 10 26 10 f0       	push   $0xf0102610
f0100d7a:	68 a5 24 10 f0       	push   $0xf01024a5
f0100d7f:	68 15 02 00 00       	push   $0x215
f0100d84:	68 7f 24 10 f0       	push   $0xf010247f
f0100d89:	e8 fd f2 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d8e:	c1 f8 03             	sar    $0x3,%eax
f0100d91:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d94:	85 c0                	test   %eax,%eax
f0100d96:	75 19                	jne    f0100db1 <mem_init+0x260>
f0100d98:	68 ce 24 10 f0       	push   $0xf01024ce
f0100d9d:	68 a5 24 10 f0       	push   $0xf01024a5
f0100da2:	68 18 02 00 00       	push   $0x218
f0100da7:	68 7f 24 10 f0       	push   $0xf010247f
f0100dac:	e8 da f2 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100db1:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100db6:	75 19                	jne    f0100dd1 <mem_init+0x280>
f0100db8:	68 df 24 10 f0       	push   $0xf01024df
f0100dbd:	68 a5 24 10 f0       	push   $0xf01024a5
f0100dc2:	68 19 02 00 00       	push   $0x219
f0100dc7:	68 7f 24 10 f0       	push   $0xf010247f
f0100dcc:	e8 ba f2 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100dd1:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100dd6:	75 19                	jne    f0100df1 <mem_init+0x2a0>
f0100dd8:	68 44 26 10 f0       	push   $0xf0102644
f0100ddd:	68 a5 24 10 f0       	push   $0xf01024a5
f0100de2:	68 1a 02 00 00       	push   $0x21a
f0100de7:	68 7f 24 10 f0       	push   $0xf010247f
f0100dec:	e8 9a f2 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100df1:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100df6:	75 19                	jne    f0100e11 <mem_init+0x2c0>
f0100df8:	68 f8 24 10 f0       	push   $0xf01024f8
f0100dfd:	68 a5 24 10 f0       	push   $0xf01024a5
f0100e02:	68 1b 02 00 00       	push   $0x21b
f0100e07:	68 7f 24 10 f0       	push   $0xf010247f
f0100e0c:	e8 7a f2 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e11:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e16:	76 3f                	jbe    f0100e57 <mem_init+0x306>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e18:	89 c3                	mov    %eax,%ebx
f0100e1a:	c1 eb 0c             	shr    $0xc,%ebx
f0100e1d:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100e20:	77 12                	ja     f0100e34 <mem_init+0x2e3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e22:	50                   	push   %eax
f0100e23:	68 ec 25 10 f0       	push   $0xf01025ec
f0100e28:	6a 52                	push   $0x52
f0100e2a:	68 8b 24 10 f0       	push   $0xf010248b
f0100e2f:	e8 57 f2 ff ff       	call   f010008b <_panic>
f0100e34:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e39:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100e3c:	76 1e                	jbe    f0100e5c <mem_init+0x30b>
f0100e3e:	68 68 26 10 f0       	push   $0xf0102668
f0100e43:	68 a5 24 10 f0       	push   $0xf01024a5
f0100e48:	68 1c 02 00 00       	push   $0x21c
f0100e4d:	68 7f 24 10 f0       	push   $0xf010247f
f0100e52:	e8 34 f2 ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e57:	83 c6 01             	add    $0x1,%esi
f0100e5a:	eb 04                	jmp    f0100e60 <mem_init+0x30f>
		else
			++nfree_extmem;
f0100e5c:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e60:	8b 12                	mov    (%edx),%edx
f0100e62:	85 d2                	test   %edx,%edx
f0100e64:	0f 85 c8 fe ff ff    	jne    f0100d32 <mem_init+0x1e1>
f0100e6a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e6d:	85 f6                	test   %esi,%esi
f0100e6f:	7f 19                	jg     f0100e8a <mem_init+0x339>
f0100e71:	68 12 25 10 f0       	push   $0xf0102512
f0100e76:	68 a5 24 10 f0       	push   $0xf01024a5
f0100e7b:	68 24 02 00 00       	push   $0x224
f0100e80:	68 7f 24 10 f0       	push   $0xf010247f
f0100e85:	e8 01 f2 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100e8a:	85 db                	test   %ebx,%ebx
f0100e8c:	7f 19                	jg     f0100ea7 <mem_init+0x356>
f0100e8e:	68 24 25 10 f0       	push   $0xf0102524
f0100e93:	68 a5 24 10 f0       	push   $0xf01024a5
f0100e98:	68 25 02 00 00       	push   $0x225
f0100e9d:	68 7f 24 10 f0       	push   $0xf010247f
f0100ea2:	e8 e4 f1 ff ff       	call   f010008b <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100ea7:	83 ec 0c             	sub    $0xc,%esp
f0100eaa:	68 b0 26 10 f0       	push   $0xf01026b0
f0100eaf:	e8 f8 00 00 00       	call   f0100fac <cprintf>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0100eb4:	83 c4 10             	add    $0x10,%esp
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100eb7:	a1 3c 35 11 f0       	mov    0xf011353c,%eax
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0100ebc:	83 3d 70 39 11 f0 00 	cmpl   $0x0,0xf0113970
f0100ec3:	75 19                	jne    f0100ede <mem_init+0x38d>
		panic("'pages' is a null pointer!");
f0100ec5:	83 ec 04             	sub    $0x4,%esp
f0100ec8:	68 35 25 10 f0       	push   $0xf0102535
f0100ecd:	68 38 02 00 00       	push   $0x238
f0100ed2:	68 7f 24 10 f0       	push   $0xf010247f
f0100ed7:	e8 af f1 ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100edc:	8b 00                	mov    (%eax),%eax
f0100ede:	85 c0                	test   %eax,%eax
f0100ee0:	75 fa                	jne    f0100edc <mem_init+0x38b>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0100ee2:	68 50 25 10 f0       	push   $0xf0102550
f0100ee7:	68 a5 24 10 f0       	push   $0xf01024a5
f0100eec:	68 40 02 00 00       	push   $0x240
f0100ef1:	68 7f 24 10 f0       	push   $0xf010247f
f0100ef6:	e8 90 f1 ff ff       	call   f010008b <_panic>

f0100efb <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100efb:	55                   	push   %ebp
f0100efc:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100efe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f03:	5d                   	pop    %ebp
f0100f04:	c3                   	ret    

f0100f05 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f05:	55                   	push   %ebp
f0100f06:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
}
f0100f08:	5d                   	pop    %ebp
f0100f09:	c3                   	ret    

f0100f0a <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f0a:	55                   	push   %ebp
f0100f0b:	89 e5                	mov    %esp,%ebp
f0100f0d:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100f10:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
		page_free(pp);
}
f0100f15:	5d                   	pop    %ebp
f0100f16:	c3                   	ret    

f0100f17 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f17:	55                   	push   %ebp
f0100f18:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100f1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f1f:	5d                   	pop    %ebp
f0100f20:	c3                   	ret    

f0100f21 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100f21:	55                   	push   %ebp
f0100f22:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100f24:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f29:	5d                   	pop    %ebp
f0100f2a:	c3                   	ret    

f0100f2b <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f2b:	55                   	push   %ebp
f0100f2c:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100f2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f33:	5d                   	pop    %ebp
f0100f34:	c3                   	ret    

f0100f35 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f35:	55                   	push   %ebp
f0100f36:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100f38:	5d                   	pop    %ebp
f0100f39:	c3                   	ret    

f0100f3a <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100f3a:	55                   	push   %ebp
f0100f3b:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f40:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100f43:	5d                   	pop    %ebp
f0100f44:	c3                   	ret    

f0100f45 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100f45:	55                   	push   %ebp
f0100f46:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100f48:	ba 70 00 00 00       	mov    $0x70,%edx
f0100f4d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f50:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100f51:	ba 71 00 00 00       	mov    $0x71,%edx
f0100f56:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100f57:	0f b6 c0             	movzbl %al,%eax
}
f0100f5a:	5d                   	pop    %ebp
f0100f5b:	c3                   	ret    

f0100f5c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100f5c:	55                   	push   %ebp
f0100f5d:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100f5f:	ba 70 00 00 00       	mov    $0x70,%edx
f0100f64:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f67:	ee                   	out    %al,(%dx)
f0100f68:	ba 71 00 00 00       	mov    $0x71,%edx
f0100f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f70:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100f71:	5d                   	pop    %ebp
f0100f72:	c3                   	ret    

f0100f73 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100f73:	55                   	push   %ebp
f0100f74:	89 e5                	mov    %esp,%ebp
f0100f76:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100f79:	ff 75 08             	pushl  0x8(%ebp)
f0100f7c:	e8 7f f6 ff ff       	call   f0100600 <cputchar>
	*cnt++;
}
f0100f81:	83 c4 10             	add    $0x10,%esp
f0100f84:	c9                   	leave  
f0100f85:	c3                   	ret    

f0100f86 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100f86:	55                   	push   %ebp
f0100f87:	89 e5                	mov    %esp,%ebp
f0100f89:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100f8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100f93:	ff 75 0c             	pushl  0xc(%ebp)
f0100f96:	ff 75 08             	pushl  0x8(%ebp)
f0100f99:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f9c:	50                   	push   %eax
f0100f9d:	68 73 0f 10 f0       	push   $0xf0100f73
f0100fa2:	e8 5d 04 00 00       	call   f0101404 <vprintfmt>
	return cnt;
}
f0100fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100faa:	c9                   	leave  
f0100fab:	c3                   	ret    

f0100fac <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100fac:	55                   	push   %ebp
f0100fad:	89 e5                	mov    %esp,%ebp
f0100faf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100fb2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100fb5:	50                   	push   %eax
f0100fb6:	ff 75 08             	pushl  0x8(%ebp)
f0100fb9:	e8 c8 ff ff ff       	call   f0100f86 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100fbe:	c9                   	leave  
f0100fbf:	c3                   	ret    

f0100fc0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100fc0:	55                   	push   %ebp
f0100fc1:	89 e5                	mov    %esp,%ebp
f0100fc3:	57                   	push   %edi
f0100fc4:	56                   	push   %esi
f0100fc5:	53                   	push   %ebx
f0100fc6:	83 ec 14             	sub    $0x14,%esp
f0100fc9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100fcc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100fcf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100fd2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100fd5:	8b 1a                	mov    (%edx),%ebx
f0100fd7:	8b 01                	mov    (%ecx),%eax
f0100fd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100fdc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100fe3:	eb 7f                	jmp    f0101064 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0100fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100fe8:	01 d8                	add    %ebx,%eax
f0100fea:	89 c6                	mov    %eax,%esi
f0100fec:	c1 ee 1f             	shr    $0x1f,%esi
f0100fef:	01 c6                	add    %eax,%esi
f0100ff1:	d1 fe                	sar    %esi
f0100ff3:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100ff6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100ff9:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100ffc:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100ffe:	eb 03                	jmp    f0101003 <stab_binsearch+0x43>
			m--;
f0101000:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101003:	39 c3                	cmp    %eax,%ebx
f0101005:	7f 0d                	jg     f0101014 <stab_binsearch+0x54>
f0101007:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010100b:	83 ea 0c             	sub    $0xc,%edx
f010100e:	39 f9                	cmp    %edi,%ecx
f0101010:	75 ee                	jne    f0101000 <stab_binsearch+0x40>
f0101012:	eb 05                	jmp    f0101019 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0101014:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0101017:	eb 4b                	jmp    f0101064 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0101019:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010101c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010101f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0101023:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0101026:	76 11                	jbe    f0101039 <stab_binsearch+0x79>
			*region_left = m;
f0101028:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010102b:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010102d:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101030:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0101037:	eb 2b                	jmp    f0101064 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0101039:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010103c:	73 14                	jae    f0101052 <stab_binsearch+0x92>
			*region_right = m - 1;
f010103e:	83 e8 01             	sub    $0x1,%eax
f0101041:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101044:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101047:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101049:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0101050:	eb 12                	jmp    f0101064 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0101052:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101055:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0101057:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010105b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010105d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0101064:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0101067:	0f 8e 78 ff ff ff    	jle    f0100fe5 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010106d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0101071:	75 0f                	jne    f0101082 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0101073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101076:	8b 00                	mov    (%eax),%eax
f0101078:	83 e8 01             	sub    $0x1,%eax
f010107b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010107e:	89 06                	mov    %eax,(%esi)
f0101080:	eb 2c                	jmp    f01010ae <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101082:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101085:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0101087:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010108a:	8b 0e                	mov    (%esi),%ecx
f010108c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010108f:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0101092:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101095:	eb 03                	jmp    f010109a <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0101097:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010109a:	39 c8                	cmp    %ecx,%eax
f010109c:	7e 0b                	jle    f01010a9 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010109e:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01010a2:	83 ea 0c             	sub    $0xc,%edx
f01010a5:	39 df                	cmp    %ebx,%edi
f01010a7:	75 ee                	jne    f0101097 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01010a9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01010ac:	89 06                	mov    %eax,(%esi)
	}
}
f01010ae:	83 c4 14             	add    $0x14,%esp
f01010b1:	5b                   	pop    %ebx
f01010b2:	5e                   	pop    %esi
f01010b3:	5f                   	pop    %edi
f01010b4:	5d                   	pop    %ebp
f01010b5:	c3                   	ret    

f01010b6 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01010b6:	55                   	push   %ebp
f01010b7:	89 e5                	mov    %esp,%ebp
f01010b9:	57                   	push   %edi
f01010ba:	56                   	push   %esi
f01010bb:	53                   	push   %ebx
f01010bc:	83 ec 3c             	sub    $0x3c,%esp
f01010bf:	8b 75 08             	mov    0x8(%ebp),%esi
f01010c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01010c5:	c7 03 d4 26 10 f0    	movl   $0xf01026d4,(%ebx)
	info->eip_line = 0;
f01010cb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01010d2:	c7 43 08 d4 26 10 f0 	movl   $0xf01026d4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01010d9:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01010e0:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01010e3:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01010ea:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01010f0:	76 11                	jbe    f0101103 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01010f2:	b8 52 8d 10 f0       	mov    $0xf0108d52,%eax
f01010f7:	3d 79 70 10 f0       	cmp    $0xf0107079,%eax
f01010fc:	77 19                	ja     f0101117 <debuginfo_eip+0x61>
f01010fe:	e9 b5 01 00 00       	jmp    f01012b8 <debuginfo_eip+0x202>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0101103:	83 ec 04             	sub    $0x4,%esp
f0101106:	68 de 26 10 f0       	push   $0xf01026de
f010110b:	6a 7f                	push   $0x7f
f010110d:	68 eb 26 10 f0       	push   $0xf01026eb
f0101112:	e8 74 ef ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101117:	80 3d 51 8d 10 f0 00 	cmpb   $0x0,0xf0108d51
f010111e:	0f 85 9b 01 00 00    	jne    f01012bf <debuginfo_eip+0x209>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0101124:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010112b:	b8 78 70 10 f0       	mov    $0xf0107078,%eax
f0101130:	2d 08 29 10 f0       	sub    $0xf0102908,%eax
f0101135:	c1 f8 02             	sar    $0x2,%eax
f0101138:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010113e:	83 e8 01             	sub    $0x1,%eax
f0101141:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0101144:	83 ec 08             	sub    $0x8,%esp
f0101147:	56                   	push   %esi
f0101148:	6a 64                	push   $0x64
f010114a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010114d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0101150:	b8 08 29 10 f0       	mov    $0xf0102908,%eax
f0101155:	e8 66 fe ff ff       	call   f0100fc0 <stab_binsearch>
	if (lfile == 0)
f010115a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010115d:	83 c4 10             	add    $0x10,%esp
f0101160:	85 c0                	test   %eax,%eax
f0101162:	0f 84 5e 01 00 00    	je     f01012c6 <debuginfo_eip+0x210>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0101168:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010116b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010116e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0101171:	83 ec 08             	sub    $0x8,%esp
f0101174:	56                   	push   %esi
f0101175:	6a 24                	push   $0x24
f0101177:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010117a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010117d:	b8 08 29 10 f0       	mov    $0xf0102908,%eax
f0101182:	e8 39 fe ff ff       	call   f0100fc0 <stab_binsearch>

	if (lfun <= rfun) {
f0101187:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010118a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010118d:	83 c4 10             	add    $0x10,%esp
f0101190:	39 d0                	cmp    %edx,%eax
f0101192:	7f 40                	jg     f01011d4 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0101194:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0101197:	c1 e1 02             	shl    $0x2,%ecx
f010119a:	8d b9 08 29 10 f0    	lea    -0xfefd6f8(%ecx),%edi
f01011a0:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01011a3:	8b b9 08 29 10 f0    	mov    -0xfefd6f8(%ecx),%edi
f01011a9:	b9 52 8d 10 f0       	mov    $0xf0108d52,%ecx
f01011ae:	81 e9 79 70 10 f0    	sub    $0xf0107079,%ecx
f01011b4:	39 cf                	cmp    %ecx,%edi
f01011b6:	73 09                	jae    f01011c1 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01011b8:	81 c7 79 70 10 f0    	add    $0xf0107079,%edi
f01011be:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01011c1:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01011c4:	8b 4f 08             	mov    0x8(%edi),%ecx
f01011c7:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01011ca:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01011cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01011cf:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01011d2:	eb 0f                	jmp    f01011e3 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01011d4:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01011d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011da:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01011dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01011e3:	83 ec 08             	sub    $0x8,%esp
f01011e6:	6a 3a                	push   $0x3a
f01011e8:	ff 73 08             	pushl  0x8(%ebx)
f01011eb:	e8 64 08 00 00       	call   f0101a54 <strfind>
f01011f0:	2b 43 08             	sub    0x8(%ebx),%eax
f01011f3:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01011f6:	83 c4 08             	add    $0x8,%esp
f01011f9:	56                   	push   %esi
f01011fa:	6a 44                	push   $0x44
f01011fc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01011ff:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0101202:	b8 08 29 10 f0       	mov    $0xf0102908,%eax
f0101207:	e8 b4 fd ff ff       	call   f0100fc0 <stab_binsearch>
	if (lline == 0)
f010120c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010120f:	83 c4 10             	add    $0x10,%esp
f0101212:	85 c0                	test   %eax,%eax
f0101214:	0f 84 b3 00 00 00    	je     f01012cd <debuginfo_eip+0x217>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f010121a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010121d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0101220:	0f b7 14 95 0e 29 10 	movzwl -0xfefd6f2(,%edx,4),%edx
f0101227:	f0 
f0101228:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010122b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010122e:	89 c2                	mov    %eax,%edx
f0101230:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101233:	8d 04 85 08 29 10 f0 	lea    -0xfefd6f8(,%eax,4),%eax
f010123a:	eb 06                	jmp    f0101242 <debuginfo_eip+0x18c>
f010123c:	83 ea 01             	sub    $0x1,%edx
f010123f:	83 e8 0c             	sub    $0xc,%eax
f0101242:	39 d7                	cmp    %edx,%edi
f0101244:	7f 34                	jg     f010127a <debuginfo_eip+0x1c4>
	       && stabs[lline].n_type != N_SOL
f0101246:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f010124a:	80 f9 84             	cmp    $0x84,%cl
f010124d:	74 0b                	je     f010125a <debuginfo_eip+0x1a4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010124f:	80 f9 64             	cmp    $0x64,%cl
f0101252:	75 e8                	jne    f010123c <debuginfo_eip+0x186>
f0101254:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0101258:	74 e2                	je     f010123c <debuginfo_eip+0x186>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010125a:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010125d:	8b 14 85 08 29 10 f0 	mov    -0xfefd6f8(,%eax,4),%edx
f0101264:	b8 52 8d 10 f0       	mov    $0xf0108d52,%eax
f0101269:	2d 79 70 10 f0       	sub    $0xf0107079,%eax
f010126e:	39 c2                	cmp    %eax,%edx
f0101270:	73 08                	jae    f010127a <debuginfo_eip+0x1c4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0101272:	81 c2 79 70 10 f0    	add    $0xf0107079,%edx
f0101278:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010127a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010127d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101280:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101285:	39 f2                	cmp    %esi,%edx
f0101287:	7d 50                	jge    f01012d9 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
f0101289:	83 c2 01             	add    $0x1,%edx
f010128c:	89 d0                	mov    %edx,%eax
f010128e:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0101291:	8d 14 95 08 29 10 f0 	lea    -0xfefd6f8(,%edx,4),%edx
f0101298:	eb 04                	jmp    f010129e <debuginfo_eip+0x1e8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010129a:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010129e:	39 c6                	cmp    %eax,%esi
f01012a0:	7e 32                	jle    f01012d4 <debuginfo_eip+0x21e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01012a2:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01012a6:	83 c0 01             	add    $0x1,%eax
f01012a9:	83 c2 0c             	add    $0xc,%edx
f01012ac:	80 f9 a0             	cmp    $0xa0,%cl
f01012af:	74 e9                	je     f010129a <debuginfo_eip+0x1e4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01012b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b6:	eb 21                	jmp    f01012d9 <debuginfo_eip+0x223>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01012b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01012bd:	eb 1a                	jmp    f01012d9 <debuginfo_eip+0x223>
f01012bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01012c4:	eb 13                	jmp    f01012d9 <debuginfo_eip+0x223>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01012c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01012cb:	eb 0c                	jmp    f01012d9 <debuginfo_eip+0x223>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f01012cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01012d2:	eb 05                	jmp    f01012d9 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01012d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012dc:	5b                   	pop    %ebx
f01012dd:	5e                   	pop    %esi
f01012de:	5f                   	pop    %edi
f01012df:	5d                   	pop    %ebp
f01012e0:	c3                   	ret    

f01012e1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01012e1:	55                   	push   %ebp
f01012e2:	89 e5                	mov    %esp,%ebp
f01012e4:	57                   	push   %edi
f01012e5:	56                   	push   %esi
f01012e6:	53                   	push   %ebx
f01012e7:	83 ec 1c             	sub    $0x1c,%esp
f01012ea:	89 c7                	mov    %eax,%edi
f01012ec:	89 d6                	mov    %edx,%esi
f01012ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01012f1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01012f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01012fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01012fd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101302:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101305:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101308:	39 d3                	cmp    %edx,%ebx
f010130a:	72 05                	jb     f0101311 <printnum+0x30>
f010130c:	39 45 10             	cmp    %eax,0x10(%ebp)
f010130f:	77 45                	ja     f0101356 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101311:	83 ec 0c             	sub    $0xc,%esp
f0101314:	ff 75 18             	pushl  0x18(%ebp)
f0101317:	8b 45 14             	mov    0x14(%ebp),%eax
f010131a:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010131d:	53                   	push   %ebx
f010131e:	ff 75 10             	pushl  0x10(%ebp)
f0101321:	83 ec 08             	sub    $0x8,%esp
f0101324:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101327:	ff 75 e0             	pushl  -0x20(%ebp)
f010132a:	ff 75 dc             	pushl  -0x24(%ebp)
f010132d:	ff 75 d8             	pushl  -0x28(%ebp)
f0101330:	e8 4b 09 00 00       	call   f0101c80 <__udivdi3>
f0101335:	83 c4 18             	add    $0x18,%esp
f0101338:	52                   	push   %edx
f0101339:	50                   	push   %eax
f010133a:	89 f2                	mov    %esi,%edx
f010133c:	89 f8                	mov    %edi,%eax
f010133e:	e8 9e ff ff ff       	call   f01012e1 <printnum>
f0101343:	83 c4 20             	add    $0x20,%esp
f0101346:	eb 18                	jmp    f0101360 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0101348:	83 ec 08             	sub    $0x8,%esp
f010134b:	56                   	push   %esi
f010134c:	ff 75 18             	pushl  0x18(%ebp)
f010134f:	ff d7                	call   *%edi
f0101351:	83 c4 10             	add    $0x10,%esp
f0101354:	eb 03                	jmp    f0101359 <printnum+0x78>
f0101356:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101359:	83 eb 01             	sub    $0x1,%ebx
f010135c:	85 db                	test   %ebx,%ebx
f010135e:	7f e8                	jg     f0101348 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101360:	83 ec 08             	sub    $0x8,%esp
f0101363:	56                   	push   %esi
f0101364:	83 ec 04             	sub    $0x4,%esp
f0101367:	ff 75 e4             	pushl  -0x1c(%ebp)
f010136a:	ff 75 e0             	pushl  -0x20(%ebp)
f010136d:	ff 75 dc             	pushl  -0x24(%ebp)
f0101370:	ff 75 d8             	pushl  -0x28(%ebp)
f0101373:	e8 38 0a 00 00       	call   f0101db0 <__umoddi3>
f0101378:	83 c4 14             	add    $0x14,%esp
f010137b:	0f be 80 f9 26 10 f0 	movsbl -0xfefd907(%eax),%eax
f0101382:	50                   	push   %eax
f0101383:	ff d7                	call   *%edi
}
f0101385:	83 c4 10             	add    $0x10,%esp
f0101388:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010138b:	5b                   	pop    %ebx
f010138c:	5e                   	pop    %esi
f010138d:	5f                   	pop    %edi
f010138e:	5d                   	pop    %ebp
f010138f:	c3                   	ret    

f0101390 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0101390:	55                   	push   %ebp
f0101391:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101393:	83 fa 01             	cmp    $0x1,%edx
f0101396:	7e 0e                	jle    f01013a6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0101398:	8b 10                	mov    (%eax),%edx
f010139a:	8d 4a 08             	lea    0x8(%edx),%ecx
f010139d:	89 08                	mov    %ecx,(%eax)
f010139f:	8b 02                	mov    (%edx),%eax
f01013a1:	8b 52 04             	mov    0x4(%edx),%edx
f01013a4:	eb 22                	jmp    f01013c8 <getuint+0x38>
	else if (lflag)
f01013a6:	85 d2                	test   %edx,%edx
f01013a8:	74 10                	je     f01013ba <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01013aa:	8b 10                	mov    (%eax),%edx
f01013ac:	8d 4a 04             	lea    0x4(%edx),%ecx
f01013af:	89 08                	mov    %ecx,(%eax)
f01013b1:	8b 02                	mov    (%edx),%eax
f01013b3:	ba 00 00 00 00       	mov    $0x0,%edx
f01013b8:	eb 0e                	jmp    f01013c8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01013ba:	8b 10                	mov    (%eax),%edx
f01013bc:	8d 4a 04             	lea    0x4(%edx),%ecx
f01013bf:	89 08                	mov    %ecx,(%eax)
f01013c1:	8b 02                	mov    (%edx),%eax
f01013c3:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01013c8:	5d                   	pop    %ebp
f01013c9:	c3                   	ret    

f01013ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01013ca:	55                   	push   %ebp
f01013cb:	89 e5                	mov    %esp,%ebp
f01013cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01013d0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01013d4:	8b 10                	mov    (%eax),%edx
f01013d6:	3b 50 04             	cmp    0x4(%eax),%edx
f01013d9:	73 0a                	jae    f01013e5 <sprintputch+0x1b>
		*b->buf++ = ch;
f01013db:	8d 4a 01             	lea    0x1(%edx),%ecx
f01013de:	89 08                	mov    %ecx,(%eax)
f01013e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01013e3:	88 02                	mov    %al,(%edx)
}
f01013e5:	5d                   	pop    %ebp
f01013e6:	c3                   	ret    

f01013e7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01013e7:	55                   	push   %ebp
f01013e8:	89 e5                	mov    %esp,%ebp
f01013ea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01013ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01013f0:	50                   	push   %eax
f01013f1:	ff 75 10             	pushl  0x10(%ebp)
f01013f4:	ff 75 0c             	pushl  0xc(%ebp)
f01013f7:	ff 75 08             	pushl  0x8(%ebp)
f01013fa:	e8 05 00 00 00       	call   f0101404 <vprintfmt>
	va_end(ap);
}
f01013ff:	83 c4 10             	add    $0x10,%esp
f0101402:	c9                   	leave  
f0101403:	c3                   	ret    

f0101404 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101404:	55                   	push   %ebp
f0101405:	89 e5                	mov    %esp,%ebp
f0101407:	57                   	push   %edi
f0101408:	56                   	push   %esi
f0101409:	53                   	push   %ebx
f010140a:	83 ec 2c             	sub    $0x2c,%esp
f010140d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101410:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101413:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101416:	eb 12                	jmp    f010142a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0101418:	85 c0                	test   %eax,%eax
f010141a:	0f 84 89 03 00 00    	je     f01017a9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0101420:	83 ec 08             	sub    $0x8,%esp
f0101423:	53                   	push   %ebx
f0101424:	50                   	push   %eax
f0101425:	ff d6                	call   *%esi
f0101427:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010142a:	83 c7 01             	add    $0x1,%edi
f010142d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101431:	83 f8 25             	cmp    $0x25,%eax
f0101434:	75 e2                	jne    f0101418 <vprintfmt+0x14>
f0101436:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f010143a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0101441:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101448:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010144f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101454:	eb 07                	jmp    f010145d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101456:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0101459:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010145d:	8d 47 01             	lea    0x1(%edi),%eax
f0101460:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101463:	0f b6 07             	movzbl (%edi),%eax
f0101466:	0f b6 c8             	movzbl %al,%ecx
f0101469:	83 e8 23             	sub    $0x23,%eax
f010146c:	3c 55                	cmp    $0x55,%al
f010146e:	0f 87 1a 03 00 00    	ja     f010178e <vprintfmt+0x38a>
f0101474:	0f b6 c0             	movzbl %al,%eax
f0101477:	ff 24 85 84 27 10 f0 	jmp    *-0xfefd87c(,%eax,4)
f010147e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101481:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101485:	eb d6                	jmp    f010145d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010148a:	b8 00 00 00 00       	mov    $0x0,%eax
f010148f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101492:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101495:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0101499:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f010149c:	8d 51 d0             	lea    -0x30(%ecx),%edx
f010149f:	83 fa 09             	cmp    $0x9,%edx
f01014a2:	77 39                	ja     f01014dd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01014a4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01014a7:	eb e9                	jmp    f0101492 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01014a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01014ac:	8d 48 04             	lea    0x4(%eax),%ecx
f01014af:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01014b2:	8b 00                	mov    (%eax),%eax
f01014b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01014b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01014ba:	eb 27                	jmp    f01014e3 <vprintfmt+0xdf>
f01014bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01014bf:	85 c0                	test   %eax,%eax
f01014c1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01014c6:	0f 49 c8             	cmovns %eax,%ecx
f01014c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01014cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01014cf:	eb 8c                	jmp    f010145d <vprintfmt+0x59>
f01014d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01014d4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01014db:	eb 80                	jmp    f010145d <vprintfmt+0x59>
f01014dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01014e0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01014e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01014e7:	0f 89 70 ff ff ff    	jns    f010145d <vprintfmt+0x59>
				width = precision, precision = -1;
f01014ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01014f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01014f3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01014fa:	e9 5e ff ff ff       	jmp    f010145d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01014ff:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0101505:	e9 53 ff ff ff       	jmp    f010145d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010150a:	8b 45 14             	mov    0x14(%ebp),%eax
f010150d:	8d 50 04             	lea    0x4(%eax),%edx
f0101510:	89 55 14             	mov    %edx,0x14(%ebp)
f0101513:	83 ec 08             	sub    $0x8,%esp
f0101516:	53                   	push   %ebx
f0101517:	ff 30                	pushl  (%eax)
f0101519:	ff d6                	call   *%esi
			break;
f010151b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010151e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0101521:	e9 04 ff ff ff       	jmp    f010142a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101526:	8b 45 14             	mov    0x14(%ebp),%eax
f0101529:	8d 50 04             	lea    0x4(%eax),%edx
f010152c:	89 55 14             	mov    %edx,0x14(%ebp)
f010152f:	8b 00                	mov    (%eax),%eax
f0101531:	99                   	cltd   
f0101532:	31 d0                	xor    %edx,%eax
f0101534:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101536:	83 f8 06             	cmp    $0x6,%eax
f0101539:	7f 0b                	jg     f0101546 <vprintfmt+0x142>
f010153b:	8b 14 85 dc 28 10 f0 	mov    -0xfefd724(,%eax,4),%edx
f0101542:	85 d2                	test   %edx,%edx
f0101544:	75 18                	jne    f010155e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0101546:	50                   	push   %eax
f0101547:	68 11 27 10 f0       	push   $0xf0102711
f010154c:	53                   	push   %ebx
f010154d:	56                   	push   %esi
f010154e:	e8 94 fe ff ff       	call   f01013e7 <printfmt>
f0101553:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101559:	e9 cc fe ff ff       	jmp    f010142a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f010155e:	52                   	push   %edx
f010155f:	68 b7 24 10 f0       	push   $0xf01024b7
f0101564:	53                   	push   %ebx
f0101565:	56                   	push   %esi
f0101566:	e8 7c fe ff ff       	call   f01013e7 <printfmt>
f010156b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010156e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101571:	e9 b4 fe ff ff       	jmp    f010142a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101576:	8b 45 14             	mov    0x14(%ebp),%eax
f0101579:	8d 50 04             	lea    0x4(%eax),%edx
f010157c:	89 55 14             	mov    %edx,0x14(%ebp)
f010157f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0101581:	85 ff                	test   %edi,%edi
f0101583:	b8 0a 27 10 f0       	mov    $0xf010270a,%eax
f0101588:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010158b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010158f:	0f 8e 94 00 00 00    	jle    f0101629 <vprintfmt+0x225>
f0101595:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101599:	0f 84 98 00 00 00    	je     f0101637 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f010159f:	83 ec 08             	sub    $0x8,%esp
f01015a2:	ff 75 d0             	pushl  -0x30(%ebp)
f01015a5:	57                   	push   %edi
f01015a6:	e8 5f 03 00 00       	call   f010190a <strnlen>
f01015ab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01015ae:	29 c1                	sub    %eax,%ecx
f01015b0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01015b3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01015b6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01015ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01015bd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01015c0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01015c2:	eb 0f                	jmp    f01015d3 <vprintfmt+0x1cf>
					putch(padc, putdat);
f01015c4:	83 ec 08             	sub    $0x8,%esp
f01015c7:	53                   	push   %ebx
f01015c8:	ff 75 e0             	pushl  -0x20(%ebp)
f01015cb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01015cd:	83 ef 01             	sub    $0x1,%edi
f01015d0:	83 c4 10             	add    $0x10,%esp
f01015d3:	85 ff                	test   %edi,%edi
f01015d5:	7f ed                	jg     f01015c4 <vprintfmt+0x1c0>
f01015d7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01015da:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01015dd:	85 c9                	test   %ecx,%ecx
f01015df:	b8 00 00 00 00       	mov    $0x0,%eax
f01015e4:	0f 49 c1             	cmovns %ecx,%eax
f01015e7:	29 c1                	sub    %eax,%ecx
f01015e9:	89 75 08             	mov    %esi,0x8(%ebp)
f01015ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01015ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01015f2:	89 cb                	mov    %ecx,%ebx
f01015f4:	eb 4d                	jmp    f0101643 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01015f6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01015fa:	74 1b                	je     f0101617 <vprintfmt+0x213>
f01015fc:	0f be c0             	movsbl %al,%eax
f01015ff:	83 e8 20             	sub    $0x20,%eax
f0101602:	83 f8 5e             	cmp    $0x5e,%eax
f0101605:	76 10                	jbe    f0101617 <vprintfmt+0x213>
					putch('?', putdat);
f0101607:	83 ec 08             	sub    $0x8,%esp
f010160a:	ff 75 0c             	pushl  0xc(%ebp)
f010160d:	6a 3f                	push   $0x3f
f010160f:	ff 55 08             	call   *0x8(%ebp)
f0101612:	83 c4 10             	add    $0x10,%esp
f0101615:	eb 0d                	jmp    f0101624 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0101617:	83 ec 08             	sub    $0x8,%esp
f010161a:	ff 75 0c             	pushl  0xc(%ebp)
f010161d:	52                   	push   %edx
f010161e:	ff 55 08             	call   *0x8(%ebp)
f0101621:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101624:	83 eb 01             	sub    $0x1,%ebx
f0101627:	eb 1a                	jmp    f0101643 <vprintfmt+0x23f>
f0101629:	89 75 08             	mov    %esi,0x8(%ebp)
f010162c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010162f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101632:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101635:	eb 0c                	jmp    f0101643 <vprintfmt+0x23f>
f0101637:	89 75 08             	mov    %esi,0x8(%ebp)
f010163a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010163d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101640:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101643:	83 c7 01             	add    $0x1,%edi
f0101646:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010164a:	0f be d0             	movsbl %al,%edx
f010164d:	85 d2                	test   %edx,%edx
f010164f:	74 23                	je     f0101674 <vprintfmt+0x270>
f0101651:	85 f6                	test   %esi,%esi
f0101653:	78 a1                	js     f01015f6 <vprintfmt+0x1f2>
f0101655:	83 ee 01             	sub    $0x1,%esi
f0101658:	79 9c                	jns    f01015f6 <vprintfmt+0x1f2>
f010165a:	89 df                	mov    %ebx,%edi
f010165c:	8b 75 08             	mov    0x8(%ebp),%esi
f010165f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101662:	eb 18                	jmp    f010167c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101664:	83 ec 08             	sub    $0x8,%esp
f0101667:	53                   	push   %ebx
f0101668:	6a 20                	push   $0x20
f010166a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010166c:	83 ef 01             	sub    $0x1,%edi
f010166f:	83 c4 10             	add    $0x10,%esp
f0101672:	eb 08                	jmp    f010167c <vprintfmt+0x278>
f0101674:	89 df                	mov    %ebx,%edi
f0101676:	8b 75 08             	mov    0x8(%ebp),%esi
f0101679:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010167c:	85 ff                	test   %edi,%edi
f010167e:	7f e4                	jg     f0101664 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101680:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101683:	e9 a2 fd ff ff       	jmp    f010142a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101688:	83 fa 01             	cmp    $0x1,%edx
f010168b:	7e 16                	jle    f01016a3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f010168d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101690:	8d 50 08             	lea    0x8(%eax),%edx
f0101693:	89 55 14             	mov    %edx,0x14(%ebp)
f0101696:	8b 50 04             	mov    0x4(%eax),%edx
f0101699:	8b 00                	mov    (%eax),%eax
f010169b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010169e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01016a1:	eb 32                	jmp    f01016d5 <vprintfmt+0x2d1>
	else if (lflag)
f01016a3:	85 d2                	test   %edx,%edx
f01016a5:	74 18                	je     f01016bf <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01016a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01016aa:	8d 50 04             	lea    0x4(%eax),%edx
f01016ad:	89 55 14             	mov    %edx,0x14(%ebp)
f01016b0:	8b 00                	mov    (%eax),%eax
f01016b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01016b5:	89 c1                	mov    %eax,%ecx
f01016b7:	c1 f9 1f             	sar    $0x1f,%ecx
f01016ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01016bd:	eb 16                	jmp    f01016d5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01016bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01016c2:	8d 50 04             	lea    0x4(%eax),%edx
f01016c5:	89 55 14             	mov    %edx,0x14(%ebp)
f01016c8:	8b 00                	mov    (%eax),%eax
f01016ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01016cd:	89 c1                	mov    %eax,%ecx
f01016cf:	c1 f9 1f             	sar    $0x1f,%ecx
f01016d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01016d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01016d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01016db:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01016e0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01016e4:	79 74                	jns    f010175a <vprintfmt+0x356>
				putch('-', putdat);
f01016e6:	83 ec 08             	sub    $0x8,%esp
f01016e9:	53                   	push   %ebx
f01016ea:	6a 2d                	push   $0x2d
f01016ec:	ff d6                	call   *%esi
				num = -(long long) num;
f01016ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01016f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01016f4:	f7 d8                	neg    %eax
f01016f6:	83 d2 00             	adc    $0x0,%edx
f01016f9:	f7 da                	neg    %edx
f01016fb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01016fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101703:	eb 55                	jmp    f010175a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101705:	8d 45 14             	lea    0x14(%ebp),%eax
f0101708:	e8 83 fc ff ff       	call   f0101390 <getuint>
			base = 10;
f010170d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101712:	eb 46                	jmp    f010175a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0101714:	8d 45 14             	lea    0x14(%ebp),%eax
f0101717:	e8 74 fc ff ff       	call   f0101390 <getuint>
			base = 8;
f010171c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0101721:	eb 37                	jmp    f010175a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0101723:	83 ec 08             	sub    $0x8,%esp
f0101726:	53                   	push   %ebx
f0101727:	6a 30                	push   $0x30
f0101729:	ff d6                	call   *%esi
			putch('x', putdat);
f010172b:	83 c4 08             	add    $0x8,%esp
f010172e:	53                   	push   %ebx
f010172f:	6a 78                	push   $0x78
f0101731:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101733:	8b 45 14             	mov    0x14(%ebp),%eax
f0101736:	8d 50 04             	lea    0x4(%eax),%edx
f0101739:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010173c:	8b 00                	mov    (%eax),%eax
f010173e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101743:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101746:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010174b:	eb 0d                	jmp    f010175a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010174d:	8d 45 14             	lea    0x14(%ebp),%eax
f0101750:	e8 3b fc ff ff       	call   f0101390 <getuint>
			base = 16;
f0101755:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010175a:	83 ec 0c             	sub    $0xc,%esp
f010175d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101761:	57                   	push   %edi
f0101762:	ff 75 e0             	pushl  -0x20(%ebp)
f0101765:	51                   	push   %ecx
f0101766:	52                   	push   %edx
f0101767:	50                   	push   %eax
f0101768:	89 da                	mov    %ebx,%edx
f010176a:	89 f0                	mov    %esi,%eax
f010176c:	e8 70 fb ff ff       	call   f01012e1 <printnum>
			break;
f0101771:	83 c4 20             	add    $0x20,%esp
f0101774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101777:	e9 ae fc ff ff       	jmp    f010142a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010177c:	83 ec 08             	sub    $0x8,%esp
f010177f:	53                   	push   %ebx
f0101780:	51                   	push   %ecx
f0101781:	ff d6                	call   *%esi
			break;
f0101783:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101786:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101789:	e9 9c fc ff ff       	jmp    f010142a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010178e:	83 ec 08             	sub    $0x8,%esp
f0101791:	53                   	push   %ebx
f0101792:	6a 25                	push   $0x25
f0101794:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101796:	83 c4 10             	add    $0x10,%esp
f0101799:	eb 03                	jmp    f010179e <vprintfmt+0x39a>
f010179b:	83 ef 01             	sub    $0x1,%edi
f010179e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01017a2:	75 f7                	jne    f010179b <vprintfmt+0x397>
f01017a4:	e9 81 fc ff ff       	jmp    f010142a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01017a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01017ac:	5b                   	pop    %ebx
f01017ad:	5e                   	pop    %esi
f01017ae:	5f                   	pop    %edi
f01017af:	5d                   	pop    %ebp
f01017b0:	c3                   	ret    

f01017b1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01017b1:	55                   	push   %ebp
f01017b2:	89 e5                	mov    %esp,%ebp
f01017b4:	83 ec 18             	sub    $0x18,%esp
f01017b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01017ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01017bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01017c0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01017c4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01017c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01017ce:	85 c0                	test   %eax,%eax
f01017d0:	74 26                	je     f01017f8 <vsnprintf+0x47>
f01017d2:	85 d2                	test   %edx,%edx
f01017d4:	7e 22                	jle    f01017f8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01017d6:	ff 75 14             	pushl  0x14(%ebp)
f01017d9:	ff 75 10             	pushl  0x10(%ebp)
f01017dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01017df:	50                   	push   %eax
f01017e0:	68 ca 13 10 f0       	push   $0xf01013ca
f01017e5:	e8 1a fc ff ff       	call   f0101404 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01017ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01017ed:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01017f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01017f3:	83 c4 10             	add    $0x10,%esp
f01017f6:	eb 05                	jmp    f01017fd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01017f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01017fd:	c9                   	leave  
f01017fe:	c3                   	ret    

f01017ff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01017ff:	55                   	push   %ebp
f0101800:	89 e5                	mov    %esp,%ebp
f0101802:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101805:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101808:	50                   	push   %eax
f0101809:	ff 75 10             	pushl  0x10(%ebp)
f010180c:	ff 75 0c             	pushl  0xc(%ebp)
f010180f:	ff 75 08             	pushl  0x8(%ebp)
f0101812:	e8 9a ff ff ff       	call   f01017b1 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101817:	c9                   	leave  
f0101818:	c3                   	ret    

f0101819 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101819:	55                   	push   %ebp
f010181a:	89 e5                	mov    %esp,%ebp
f010181c:	57                   	push   %edi
f010181d:	56                   	push   %esi
f010181e:	53                   	push   %ebx
f010181f:	83 ec 0c             	sub    $0xc,%esp
f0101822:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101825:	85 c0                	test   %eax,%eax
f0101827:	74 11                	je     f010183a <readline+0x21>
		cprintf("%s", prompt);
f0101829:	83 ec 08             	sub    $0x8,%esp
f010182c:	50                   	push   %eax
f010182d:	68 b7 24 10 f0       	push   $0xf01024b7
f0101832:	e8 75 f7 ff ff       	call   f0100fac <cprintf>
f0101837:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010183a:	83 ec 0c             	sub    $0xc,%esp
f010183d:	6a 00                	push   $0x0
f010183f:	e8 dd ed ff ff       	call   f0100621 <iscons>
f0101844:	89 c7                	mov    %eax,%edi
f0101846:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101849:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010184e:	e8 bd ed ff ff       	call   f0100610 <getchar>
f0101853:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101855:	85 c0                	test   %eax,%eax
f0101857:	79 18                	jns    f0101871 <readline+0x58>
			cprintf("read error: %e\n", c);
f0101859:	83 ec 08             	sub    $0x8,%esp
f010185c:	50                   	push   %eax
f010185d:	68 f8 28 10 f0       	push   $0xf01028f8
f0101862:	e8 45 f7 ff ff       	call   f0100fac <cprintf>
			return NULL;
f0101867:	83 c4 10             	add    $0x10,%esp
f010186a:	b8 00 00 00 00       	mov    $0x0,%eax
f010186f:	eb 79                	jmp    f01018ea <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101871:	83 f8 08             	cmp    $0x8,%eax
f0101874:	0f 94 c2             	sete   %dl
f0101877:	83 f8 7f             	cmp    $0x7f,%eax
f010187a:	0f 94 c0             	sete   %al
f010187d:	08 c2                	or     %al,%dl
f010187f:	74 1a                	je     f010189b <readline+0x82>
f0101881:	85 f6                	test   %esi,%esi
f0101883:	7e 16                	jle    f010189b <readline+0x82>
			if (echoing)
f0101885:	85 ff                	test   %edi,%edi
f0101887:	74 0d                	je     f0101896 <readline+0x7d>
				cputchar('\b');
f0101889:	83 ec 0c             	sub    $0xc,%esp
f010188c:	6a 08                	push   $0x8
f010188e:	e8 6d ed ff ff       	call   f0100600 <cputchar>
f0101893:	83 c4 10             	add    $0x10,%esp
			i--;
f0101896:	83 ee 01             	sub    $0x1,%esi
f0101899:	eb b3                	jmp    f010184e <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010189b:	83 fb 1f             	cmp    $0x1f,%ebx
f010189e:	7e 23                	jle    f01018c3 <readline+0xaa>
f01018a0:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01018a6:	7f 1b                	jg     f01018c3 <readline+0xaa>
			if (echoing)
f01018a8:	85 ff                	test   %edi,%edi
f01018aa:	74 0c                	je     f01018b8 <readline+0x9f>
				cputchar(c);
f01018ac:	83 ec 0c             	sub    $0xc,%esp
f01018af:	53                   	push   %ebx
f01018b0:	e8 4b ed ff ff       	call   f0100600 <cputchar>
f01018b5:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01018b8:	88 9e 60 35 11 f0    	mov    %bl,-0xfeecaa0(%esi)
f01018be:	8d 76 01             	lea    0x1(%esi),%esi
f01018c1:	eb 8b                	jmp    f010184e <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01018c3:	83 fb 0a             	cmp    $0xa,%ebx
f01018c6:	74 05                	je     f01018cd <readline+0xb4>
f01018c8:	83 fb 0d             	cmp    $0xd,%ebx
f01018cb:	75 81                	jne    f010184e <readline+0x35>
			if (echoing)
f01018cd:	85 ff                	test   %edi,%edi
f01018cf:	74 0d                	je     f01018de <readline+0xc5>
				cputchar('\n');
f01018d1:	83 ec 0c             	sub    $0xc,%esp
f01018d4:	6a 0a                	push   $0xa
f01018d6:	e8 25 ed ff ff       	call   f0100600 <cputchar>
f01018db:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01018de:	c6 86 60 35 11 f0 00 	movb   $0x0,-0xfeecaa0(%esi)
			return buf;
f01018e5:	b8 60 35 11 f0       	mov    $0xf0113560,%eax
		}
	}
}
f01018ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01018ed:	5b                   	pop    %ebx
f01018ee:	5e                   	pop    %esi
f01018ef:	5f                   	pop    %edi
f01018f0:	5d                   	pop    %ebp
f01018f1:	c3                   	ret    

f01018f2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01018f2:	55                   	push   %ebp
f01018f3:	89 e5                	mov    %esp,%ebp
f01018f5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01018f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01018fd:	eb 03                	jmp    f0101902 <strlen+0x10>
		n++;
f01018ff:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101902:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101906:	75 f7                	jne    f01018ff <strlen+0xd>
		n++;
	return n;
}
f0101908:	5d                   	pop    %ebp
f0101909:	c3                   	ret    

f010190a <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010190a:	55                   	push   %ebp
f010190b:	89 e5                	mov    %esp,%ebp
f010190d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101910:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101913:	ba 00 00 00 00       	mov    $0x0,%edx
f0101918:	eb 03                	jmp    f010191d <strnlen+0x13>
		n++;
f010191a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010191d:	39 c2                	cmp    %eax,%edx
f010191f:	74 08                	je     f0101929 <strnlen+0x1f>
f0101921:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101925:	75 f3                	jne    f010191a <strnlen+0x10>
f0101927:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0101929:	5d                   	pop    %ebp
f010192a:	c3                   	ret    

f010192b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010192b:	55                   	push   %ebp
f010192c:	89 e5                	mov    %esp,%ebp
f010192e:	53                   	push   %ebx
f010192f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101935:	89 c2                	mov    %eax,%edx
f0101937:	83 c2 01             	add    $0x1,%edx
f010193a:	83 c1 01             	add    $0x1,%ecx
f010193d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101941:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101944:	84 db                	test   %bl,%bl
f0101946:	75 ef                	jne    f0101937 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101948:	5b                   	pop    %ebx
f0101949:	5d                   	pop    %ebp
f010194a:	c3                   	ret    

f010194b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010194b:	55                   	push   %ebp
f010194c:	89 e5                	mov    %esp,%ebp
f010194e:	53                   	push   %ebx
f010194f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101952:	53                   	push   %ebx
f0101953:	e8 9a ff ff ff       	call   f01018f2 <strlen>
f0101958:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010195b:	ff 75 0c             	pushl  0xc(%ebp)
f010195e:	01 d8                	add    %ebx,%eax
f0101960:	50                   	push   %eax
f0101961:	e8 c5 ff ff ff       	call   f010192b <strcpy>
	return dst;
}
f0101966:	89 d8                	mov    %ebx,%eax
f0101968:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010196b:	c9                   	leave  
f010196c:	c3                   	ret    

f010196d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010196d:	55                   	push   %ebp
f010196e:	89 e5                	mov    %esp,%ebp
f0101970:	56                   	push   %esi
f0101971:	53                   	push   %ebx
f0101972:	8b 75 08             	mov    0x8(%ebp),%esi
f0101975:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101978:	89 f3                	mov    %esi,%ebx
f010197a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010197d:	89 f2                	mov    %esi,%edx
f010197f:	eb 0f                	jmp    f0101990 <strncpy+0x23>
		*dst++ = *src;
f0101981:	83 c2 01             	add    $0x1,%edx
f0101984:	0f b6 01             	movzbl (%ecx),%eax
f0101987:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010198a:	80 39 01             	cmpb   $0x1,(%ecx)
f010198d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101990:	39 da                	cmp    %ebx,%edx
f0101992:	75 ed                	jne    f0101981 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101994:	89 f0                	mov    %esi,%eax
f0101996:	5b                   	pop    %ebx
f0101997:	5e                   	pop    %esi
f0101998:	5d                   	pop    %ebp
f0101999:	c3                   	ret    

f010199a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010199a:	55                   	push   %ebp
f010199b:	89 e5                	mov    %esp,%ebp
f010199d:	56                   	push   %esi
f010199e:	53                   	push   %ebx
f010199f:	8b 75 08             	mov    0x8(%ebp),%esi
f01019a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01019a5:	8b 55 10             	mov    0x10(%ebp),%edx
f01019a8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01019aa:	85 d2                	test   %edx,%edx
f01019ac:	74 21                	je     f01019cf <strlcpy+0x35>
f01019ae:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01019b2:	89 f2                	mov    %esi,%edx
f01019b4:	eb 09                	jmp    f01019bf <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01019b6:	83 c2 01             	add    $0x1,%edx
f01019b9:	83 c1 01             	add    $0x1,%ecx
f01019bc:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01019bf:	39 c2                	cmp    %eax,%edx
f01019c1:	74 09                	je     f01019cc <strlcpy+0x32>
f01019c3:	0f b6 19             	movzbl (%ecx),%ebx
f01019c6:	84 db                	test   %bl,%bl
f01019c8:	75 ec                	jne    f01019b6 <strlcpy+0x1c>
f01019ca:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01019cc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01019cf:	29 f0                	sub    %esi,%eax
}
f01019d1:	5b                   	pop    %ebx
f01019d2:	5e                   	pop    %esi
f01019d3:	5d                   	pop    %ebp
f01019d4:	c3                   	ret    

f01019d5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01019d5:	55                   	push   %ebp
f01019d6:	89 e5                	mov    %esp,%ebp
f01019d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01019db:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01019de:	eb 06                	jmp    f01019e6 <strcmp+0x11>
		p++, q++;
f01019e0:	83 c1 01             	add    $0x1,%ecx
f01019e3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01019e6:	0f b6 01             	movzbl (%ecx),%eax
f01019e9:	84 c0                	test   %al,%al
f01019eb:	74 04                	je     f01019f1 <strcmp+0x1c>
f01019ed:	3a 02                	cmp    (%edx),%al
f01019ef:	74 ef                	je     f01019e0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01019f1:	0f b6 c0             	movzbl %al,%eax
f01019f4:	0f b6 12             	movzbl (%edx),%edx
f01019f7:	29 d0                	sub    %edx,%eax
}
f01019f9:	5d                   	pop    %ebp
f01019fa:	c3                   	ret    

f01019fb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01019fb:	55                   	push   %ebp
f01019fc:	89 e5                	mov    %esp,%ebp
f01019fe:	53                   	push   %ebx
f01019ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a02:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101a05:	89 c3                	mov    %eax,%ebx
f0101a07:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101a0a:	eb 06                	jmp    f0101a12 <strncmp+0x17>
		n--, p++, q++;
f0101a0c:	83 c0 01             	add    $0x1,%eax
f0101a0f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101a12:	39 d8                	cmp    %ebx,%eax
f0101a14:	74 15                	je     f0101a2b <strncmp+0x30>
f0101a16:	0f b6 08             	movzbl (%eax),%ecx
f0101a19:	84 c9                	test   %cl,%cl
f0101a1b:	74 04                	je     f0101a21 <strncmp+0x26>
f0101a1d:	3a 0a                	cmp    (%edx),%cl
f0101a1f:	74 eb                	je     f0101a0c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101a21:	0f b6 00             	movzbl (%eax),%eax
f0101a24:	0f b6 12             	movzbl (%edx),%edx
f0101a27:	29 d0                	sub    %edx,%eax
f0101a29:	eb 05                	jmp    f0101a30 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101a2b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101a30:	5b                   	pop    %ebx
f0101a31:	5d                   	pop    %ebp
f0101a32:	c3                   	ret    

f0101a33 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101a33:	55                   	push   %ebp
f0101a34:	89 e5                	mov    %esp,%ebp
f0101a36:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a39:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101a3d:	eb 07                	jmp    f0101a46 <strchr+0x13>
		if (*s == c)
f0101a3f:	38 ca                	cmp    %cl,%dl
f0101a41:	74 0f                	je     f0101a52 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101a43:	83 c0 01             	add    $0x1,%eax
f0101a46:	0f b6 10             	movzbl (%eax),%edx
f0101a49:	84 d2                	test   %dl,%dl
f0101a4b:	75 f2                	jne    f0101a3f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a52:	5d                   	pop    %ebp
f0101a53:	c3                   	ret    

f0101a54 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101a54:	55                   	push   %ebp
f0101a55:	89 e5                	mov    %esp,%ebp
f0101a57:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a5a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101a5e:	eb 03                	jmp    f0101a63 <strfind+0xf>
f0101a60:	83 c0 01             	add    $0x1,%eax
f0101a63:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101a66:	38 ca                	cmp    %cl,%dl
f0101a68:	74 04                	je     f0101a6e <strfind+0x1a>
f0101a6a:	84 d2                	test   %dl,%dl
f0101a6c:	75 f2                	jne    f0101a60 <strfind+0xc>
			break;
	return (char *) s;
}
f0101a6e:	5d                   	pop    %ebp
f0101a6f:	c3                   	ret    

f0101a70 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101a70:	55                   	push   %ebp
f0101a71:	89 e5                	mov    %esp,%ebp
f0101a73:	57                   	push   %edi
f0101a74:	56                   	push   %esi
f0101a75:	53                   	push   %ebx
f0101a76:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101a79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101a7c:	85 c9                	test   %ecx,%ecx
f0101a7e:	74 36                	je     f0101ab6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101a80:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101a86:	75 28                	jne    f0101ab0 <memset+0x40>
f0101a88:	f6 c1 03             	test   $0x3,%cl
f0101a8b:	75 23                	jne    f0101ab0 <memset+0x40>
		c &= 0xFF;
f0101a8d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101a91:	89 d3                	mov    %edx,%ebx
f0101a93:	c1 e3 08             	shl    $0x8,%ebx
f0101a96:	89 d6                	mov    %edx,%esi
f0101a98:	c1 e6 18             	shl    $0x18,%esi
f0101a9b:	89 d0                	mov    %edx,%eax
f0101a9d:	c1 e0 10             	shl    $0x10,%eax
f0101aa0:	09 f0                	or     %esi,%eax
f0101aa2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0101aa4:	89 d8                	mov    %ebx,%eax
f0101aa6:	09 d0                	or     %edx,%eax
f0101aa8:	c1 e9 02             	shr    $0x2,%ecx
f0101aab:	fc                   	cld    
f0101aac:	f3 ab                	rep stos %eax,%es:(%edi)
f0101aae:	eb 06                	jmp    f0101ab6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101ab3:	fc                   	cld    
f0101ab4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101ab6:	89 f8                	mov    %edi,%eax
f0101ab8:	5b                   	pop    %ebx
f0101ab9:	5e                   	pop    %esi
f0101aba:	5f                   	pop    %edi
f0101abb:	5d                   	pop    %ebp
f0101abc:	c3                   	ret    

f0101abd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101abd:	55                   	push   %ebp
f0101abe:	89 e5                	mov    %esp,%ebp
f0101ac0:	57                   	push   %edi
f0101ac1:	56                   	push   %esi
f0101ac2:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ac5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101ac8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101acb:	39 c6                	cmp    %eax,%esi
f0101acd:	73 35                	jae    f0101b04 <memmove+0x47>
f0101acf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101ad2:	39 d0                	cmp    %edx,%eax
f0101ad4:	73 2e                	jae    f0101b04 <memmove+0x47>
		s += n;
		d += n;
f0101ad6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101ad9:	89 d6                	mov    %edx,%esi
f0101adb:	09 fe                	or     %edi,%esi
f0101add:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101ae3:	75 13                	jne    f0101af8 <memmove+0x3b>
f0101ae5:	f6 c1 03             	test   $0x3,%cl
f0101ae8:	75 0e                	jne    f0101af8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0101aea:	83 ef 04             	sub    $0x4,%edi
f0101aed:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101af0:	c1 e9 02             	shr    $0x2,%ecx
f0101af3:	fd                   	std    
f0101af4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101af6:	eb 09                	jmp    f0101b01 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101af8:	83 ef 01             	sub    $0x1,%edi
f0101afb:	8d 72 ff             	lea    -0x1(%edx),%esi
f0101afe:	fd                   	std    
f0101aff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101b01:	fc                   	cld    
f0101b02:	eb 1d                	jmp    f0101b21 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101b04:	89 f2                	mov    %esi,%edx
f0101b06:	09 c2                	or     %eax,%edx
f0101b08:	f6 c2 03             	test   $0x3,%dl
f0101b0b:	75 0f                	jne    f0101b1c <memmove+0x5f>
f0101b0d:	f6 c1 03             	test   $0x3,%cl
f0101b10:	75 0a                	jne    f0101b1c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0101b12:	c1 e9 02             	shr    $0x2,%ecx
f0101b15:	89 c7                	mov    %eax,%edi
f0101b17:	fc                   	cld    
f0101b18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101b1a:	eb 05                	jmp    f0101b21 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101b1c:	89 c7                	mov    %eax,%edi
f0101b1e:	fc                   	cld    
f0101b1f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101b21:	5e                   	pop    %esi
f0101b22:	5f                   	pop    %edi
f0101b23:	5d                   	pop    %ebp
f0101b24:	c3                   	ret    

f0101b25 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101b25:	55                   	push   %ebp
f0101b26:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101b28:	ff 75 10             	pushl  0x10(%ebp)
f0101b2b:	ff 75 0c             	pushl  0xc(%ebp)
f0101b2e:	ff 75 08             	pushl  0x8(%ebp)
f0101b31:	e8 87 ff ff ff       	call   f0101abd <memmove>
}
f0101b36:	c9                   	leave  
f0101b37:	c3                   	ret    

f0101b38 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101b38:	55                   	push   %ebp
f0101b39:	89 e5                	mov    %esp,%ebp
f0101b3b:	56                   	push   %esi
f0101b3c:	53                   	push   %ebx
f0101b3d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b40:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101b43:	89 c6                	mov    %eax,%esi
f0101b45:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101b48:	eb 1a                	jmp    f0101b64 <memcmp+0x2c>
		if (*s1 != *s2)
f0101b4a:	0f b6 08             	movzbl (%eax),%ecx
f0101b4d:	0f b6 1a             	movzbl (%edx),%ebx
f0101b50:	38 d9                	cmp    %bl,%cl
f0101b52:	74 0a                	je     f0101b5e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0101b54:	0f b6 c1             	movzbl %cl,%eax
f0101b57:	0f b6 db             	movzbl %bl,%ebx
f0101b5a:	29 d8                	sub    %ebx,%eax
f0101b5c:	eb 0f                	jmp    f0101b6d <memcmp+0x35>
		s1++, s2++;
f0101b5e:	83 c0 01             	add    $0x1,%eax
f0101b61:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101b64:	39 f0                	cmp    %esi,%eax
f0101b66:	75 e2                	jne    f0101b4a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101b68:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101b6d:	5b                   	pop    %ebx
f0101b6e:	5e                   	pop    %esi
f0101b6f:	5d                   	pop    %ebp
f0101b70:	c3                   	ret    

f0101b71 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101b71:	55                   	push   %ebp
f0101b72:	89 e5                	mov    %esp,%ebp
f0101b74:	53                   	push   %ebx
f0101b75:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101b78:	89 c1                	mov    %eax,%ecx
f0101b7a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0101b7d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101b81:	eb 0a                	jmp    f0101b8d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101b83:	0f b6 10             	movzbl (%eax),%edx
f0101b86:	39 da                	cmp    %ebx,%edx
f0101b88:	74 07                	je     f0101b91 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101b8a:	83 c0 01             	add    $0x1,%eax
f0101b8d:	39 c8                	cmp    %ecx,%eax
f0101b8f:	72 f2                	jb     f0101b83 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101b91:	5b                   	pop    %ebx
f0101b92:	5d                   	pop    %ebp
f0101b93:	c3                   	ret    

f0101b94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101b94:	55                   	push   %ebp
f0101b95:	89 e5                	mov    %esp,%ebp
f0101b97:	57                   	push   %edi
f0101b98:	56                   	push   %esi
f0101b99:	53                   	push   %ebx
f0101b9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101b9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101ba0:	eb 03                	jmp    f0101ba5 <strtol+0x11>
		s++;
f0101ba2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101ba5:	0f b6 01             	movzbl (%ecx),%eax
f0101ba8:	3c 20                	cmp    $0x20,%al
f0101baa:	74 f6                	je     f0101ba2 <strtol+0xe>
f0101bac:	3c 09                	cmp    $0x9,%al
f0101bae:	74 f2                	je     f0101ba2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101bb0:	3c 2b                	cmp    $0x2b,%al
f0101bb2:	75 0a                	jne    f0101bbe <strtol+0x2a>
		s++;
f0101bb4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101bb7:	bf 00 00 00 00       	mov    $0x0,%edi
f0101bbc:	eb 11                	jmp    f0101bcf <strtol+0x3b>
f0101bbe:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101bc3:	3c 2d                	cmp    $0x2d,%al
f0101bc5:	75 08                	jne    f0101bcf <strtol+0x3b>
		s++, neg = 1;
f0101bc7:	83 c1 01             	add    $0x1,%ecx
f0101bca:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101bcf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101bd5:	75 15                	jne    f0101bec <strtol+0x58>
f0101bd7:	80 39 30             	cmpb   $0x30,(%ecx)
f0101bda:	75 10                	jne    f0101bec <strtol+0x58>
f0101bdc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101be0:	75 7c                	jne    f0101c5e <strtol+0xca>
		s += 2, base = 16;
f0101be2:	83 c1 02             	add    $0x2,%ecx
f0101be5:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101bea:	eb 16                	jmp    f0101c02 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0101bec:	85 db                	test   %ebx,%ebx
f0101bee:	75 12                	jne    f0101c02 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101bf0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101bf5:	80 39 30             	cmpb   $0x30,(%ecx)
f0101bf8:	75 08                	jne    f0101c02 <strtol+0x6e>
		s++, base = 8;
f0101bfa:	83 c1 01             	add    $0x1,%ecx
f0101bfd:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0101c02:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c07:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101c0a:	0f b6 11             	movzbl (%ecx),%edx
f0101c0d:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101c10:	89 f3                	mov    %esi,%ebx
f0101c12:	80 fb 09             	cmp    $0x9,%bl
f0101c15:	77 08                	ja     f0101c1f <strtol+0x8b>
			dig = *s - '0';
f0101c17:	0f be d2             	movsbl %dl,%edx
f0101c1a:	83 ea 30             	sub    $0x30,%edx
f0101c1d:	eb 22                	jmp    f0101c41 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0101c1f:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101c22:	89 f3                	mov    %esi,%ebx
f0101c24:	80 fb 19             	cmp    $0x19,%bl
f0101c27:	77 08                	ja     f0101c31 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0101c29:	0f be d2             	movsbl %dl,%edx
f0101c2c:	83 ea 57             	sub    $0x57,%edx
f0101c2f:	eb 10                	jmp    f0101c41 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0101c31:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101c34:	89 f3                	mov    %esi,%ebx
f0101c36:	80 fb 19             	cmp    $0x19,%bl
f0101c39:	77 16                	ja     f0101c51 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0101c3b:	0f be d2             	movsbl %dl,%edx
f0101c3e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101c41:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101c44:	7d 0b                	jge    f0101c51 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0101c46:	83 c1 01             	add    $0x1,%ecx
f0101c49:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101c4d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101c4f:	eb b9                	jmp    f0101c0a <strtol+0x76>

	if (endptr)
f0101c51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101c55:	74 0d                	je     f0101c64 <strtol+0xd0>
		*endptr = (char *) s;
f0101c57:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101c5a:	89 0e                	mov    %ecx,(%esi)
f0101c5c:	eb 06                	jmp    f0101c64 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101c5e:	85 db                	test   %ebx,%ebx
f0101c60:	74 98                	je     f0101bfa <strtol+0x66>
f0101c62:	eb 9e                	jmp    f0101c02 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0101c64:	89 c2                	mov    %eax,%edx
f0101c66:	f7 da                	neg    %edx
f0101c68:	85 ff                	test   %edi,%edi
f0101c6a:	0f 45 c2             	cmovne %edx,%eax
}
f0101c6d:	5b                   	pop    %ebx
f0101c6e:	5e                   	pop    %esi
f0101c6f:	5f                   	pop    %edi
f0101c70:	5d                   	pop    %ebp
f0101c71:	c3                   	ret    
f0101c72:	66 90                	xchg   %ax,%ax
f0101c74:	66 90                	xchg   %ax,%ax
f0101c76:	66 90                	xchg   %ax,%ax
f0101c78:	66 90                	xchg   %ax,%ax
f0101c7a:	66 90                	xchg   %ax,%ax
f0101c7c:	66 90                	xchg   %ax,%ax
f0101c7e:	66 90                	xchg   %ax,%ax

f0101c80 <__udivdi3>:
f0101c80:	55                   	push   %ebp
f0101c81:	57                   	push   %edi
f0101c82:	56                   	push   %esi
f0101c83:	53                   	push   %ebx
f0101c84:	83 ec 1c             	sub    $0x1c,%esp
f0101c87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0101c8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0101c8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101c97:	85 f6                	test   %esi,%esi
f0101c99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101c9d:	89 ca                	mov    %ecx,%edx
f0101c9f:	89 f8                	mov    %edi,%eax
f0101ca1:	75 3d                	jne    f0101ce0 <__udivdi3+0x60>
f0101ca3:	39 cf                	cmp    %ecx,%edi
f0101ca5:	0f 87 c5 00 00 00    	ja     f0101d70 <__udivdi3+0xf0>
f0101cab:	85 ff                	test   %edi,%edi
f0101cad:	89 fd                	mov    %edi,%ebp
f0101caf:	75 0b                	jne    f0101cbc <__udivdi3+0x3c>
f0101cb1:	b8 01 00 00 00       	mov    $0x1,%eax
f0101cb6:	31 d2                	xor    %edx,%edx
f0101cb8:	f7 f7                	div    %edi
f0101cba:	89 c5                	mov    %eax,%ebp
f0101cbc:	89 c8                	mov    %ecx,%eax
f0101cbe:	31 d2                	xor    %edx,%edx
f0101cc0:	f7 f5                	div    %ebp
f0101cc2:	89 c1                	mov    %eax,%ecx
f0101cc4:	89 d8                	mov    %ebx,%eax
f0101cc6:	89 cf                	mov    %ecx,%edi
f0101cc8:	f7 f5                	div    %ebp
f0101cca:	89 c3                	mov    %eax,%ebx
f0101ccc:	89 d8                	mov    %ebx,%eax
f0101cce:	89 fa                	mov    %edi,%edx
f0101cd0:	83 c4 1c             	add    $0x1c,%esp
f0101cd3:	5b                   	pop    %ebx
f0101cd4:	5e                   	pop    %esi
f0101cd5:	5f                   	pop    %edi
f0101cd6:	5d                   	pop    %ebp
f0101cd7:	c3                   	ret    
f0101cd8:	90                   	nop
f0101cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101ce0:	39 ce                	cmp    %ecx,%esi
f0101ce2:	77 74                	ja     f0101d58 <__udivdi3+0xd8>
f0101ce4:	0f bd fe             	bsr    %esi,%edi
f0101ce7:	83 f7 1f             	xor    $0x1f,%edi
f0101cea:	0f 84 98 00 00 00    	je     f0101d88 <__udivdi3+0x108>
f0101cf0:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101cf5:	89 f9                	mov    %edi,%ecx
f0101cf7:	89 c5                	mov    %eax,%ebp
f0101cf9:	29 fb                	sub    %edi,%ebx
f0101cfb:	d3 e6                	shl    %cl,%esi
f0101cfd:	89 d9                	mov    %ebx,%ecx
f0101cff:	d3 ed                	shr    %cl,%ebp
f0101d01:	89 f9                	mov    %edi,%ecx
f0101d03:	d3 e0                	shl    %cl,%eax
f0101d05:	09 ee                	or     %ebp,%esi
f0101d07:	89 d9                	mov    %ebx,%ecx
f0101d09:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d0d:	89 d5                	mov    %edx,%ebp
f0101d0f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101d13:	d3 ed                	shr    %cl,%ebp
f0101d15:	89 f9                	mov    %edi,%ecx
f0101d17:	d3 e2                	shl    %cl,%edx
f0101d19:	89 d9                	mov    %ebx,%ecx
f0101d1b:	d3 e8                	shr    %cl,%eax
f0101d1d:	09 c2                	or     %eax,%edx
f0101d1f:	89 d0                	mov    %edx,%eax
f0101d21:	89 ea                	mov    %ebp,%edx
f0101d23:	f7 f6                	div    %esi
f0101d25:	89 d5                	mov    %edx,%ebp
f0101d27:	89 c3                	mov    %eax,%ebx
f0101d29:	f7 64 24 0c          	mull   0xc(%esp)
f0101d2d:	39 d5                	cmp    %edx,%ebp
f0101d2f:	72 10                	jb     f0101d41 <__udivdi3+0xc1>
f0101d31:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101d35:	89 f9                	mov    %edi,%ecx
f0101d37:	d3 e6                	shl    %cl,%esi
f0101d39:	39 c6                	cmp    %eax,%esi
f0101d3b:	73 07                	jae    f0101d44 <__udivdi3+0xc4>
f0101d3d:	39 d5                	cmp    %edx,%ebp
f0101d3f:	75 03                	jne    f0101d44 <__udivdi3+0xc4>
f0101d41:	83 eb 01             	sub    $0x1,%ebx
f0101d44:	31 ff                	xor    %edi,%edi
f0101d46:	89 d8                	mov    %ebx,%eax
f0101d48:	89 fa                	mov    %edi,%edx
f0101d4a:	83 c4 1c             	add    $0x1c,%esp
f0101d4d:	5b                   	pop    %ebx
f0101d4e:	5e                   	pop    %esi
f0101d4f:	5f                   	pop    %edi
f0101d50:	5d                   	pop    %ebp
f0101d51:	c3                   	ret    
f0101d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101d58:	31 ff                	xor    %edi,%edi
f0101d5a:	31 db                	xor    %ebx,%ebx
f0101d5c:	89 d8                	mov    %ebx,%eax
f0101d5e:	89 fa                	mov    %edi,%edx
f0101d60:	83 c4 1c             	add    $0x1c,%esp
f0101d63:	5b                   	pop    %ebx
f0101d64:	5e                   	pop    %esi
f0101d65:	5f                   	pop    %edi
f0101d66:	5d                   	pop    %ebp
f0101d67:	c3                   	ret    
f0101d68:	90                   	nop
f0101d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101d70:	89 d8                	mov    %ebx,%eax
f0101d72:	f7 f7                	div    %edi
f0101d74:	31 ff                	xor    %edi,%edi
f0101d76:	89 c3                	mov    %eax,%ebx
f0101d78:	89 d8                	mov    %ebx,%eax
f0101d7a:	89 fa                	mov    %edi,%edx
f0101d7c:	83 c4 1c             	add    $0x1c,%esp
f0101d7f:	5b                   	pop    %ebx
f0101d80:	5e                   	pop    %esi
f0101d81:	5f                   	pop    %edi
f0101d82:	5d                   	pop    %ebp
f0101d83:	c3                   	ret    
f0101d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101d88:	39 ce                	cmp    %ecx,%esi
f0101d8a:	72 0c                	jb     f0101d98 <__udivdi3+0x118>
f0101d8c:	31 db                	xor    %ebx,%ebx
f0101d8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101d92:	0f 87 34 ff ff ff    	ja     f0101ccc <__udivdi3+0x4c>
f0101d98:	bb 01 00 00 00       	mov    $0x1,%ebx
f0101d9d:	e9 2a ff ff ff       	jmp    f0101ccc <__udivdi3+0x4c>
f0101da2:	66 90                	xchg   %ax,%ax
f0101da4:	66 90                	xchg   %ax,%ax
f0101da6:	66 90                	xchg   %ax,%ax
f0101da8:	66 90                	xchg   %ax,%ax
f0101daa:	66 90                	xchg   %ax,%ax
f0101dac:	66 90                	xchg   %ax,%ax
f0101dae:	66 90                	xchg   %ax,%ax

f0101db0 <__umoddi3>:
f0101db0:	55                   	push   %ebp
f0101db1:	57                   	push   %edi
f0101db2:	56                   	push   %esi
f0101db3:	53                   	push   %ebx
f0101db4:	83 ec 1c             	sub    $0x1c,%esp
f0101db7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101dbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0101dbf:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101dc7:	85 d2                	test   %edx,%edx
f0101dc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101dd1:	89 f3                	mov    %esi,%ebx
f0101dd3:	89 3c 24             	mov    %edi,(%esp)
f0101dd6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101dda:	75 1c                	jne    f0101df8 <__umoddi3+0x48>
f0101ddc:	39 f7                	cmp    %esi,%edi
f0101dde:	76 50                	jbe    f0101e30 <__umoddi3+0x80>
f0101de0:	89 c8                	mov    %ecx,%eax
f0101de2:	89 f2                	mov    %esi,%edx
f0101de4:	f7 f7                	div    %edi
f0101de6:	89 d0                	mov    %edx,%eax
f0101de8:	31 d2                	xor    %edx,%edx
f0101dea:	83 c4 1c             	add    $0x1c,%esp
f0101ded:	5b                   	pop    %ebx
f0101dee:	5e                   	pop    %esi
f0101def:	5f                   	pop    %edi
f0101df0:	5d                   	pop    %ebp
f0101df1:	c3                   	ret    
f0101df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101df8:	39 f2                	cmp    %esi,%edx
f0101dfa:	89 d0                	mov    %edx,%eax
f0101dfc:	77 52                	ja     f0101e50 <__umoddi3+0xa0>
f0101dfe:	0f bd ea             	bsr    %edx,%ebp
f0101e01:	83 f5 1f             	xor    $0x1f,%ebp
f0101e04:	75 5a                	jne    f0101e60 <__umoddi3+0xb0>
f0101e06:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0101e0a:	0f 82 e0 00 00 00    	jb     f0101ef0 <__umoddi3+0x140>
f0101e10:	39 0c 24             	cmp    %ecx,(%esp)
f0101e13:	0f 86 d7 00 00 00    	jbe    f0101ef0 <__umoddi3+0x140>
f0101e19:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101e1d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101e21:	83 c4 1c             	add    $0x1c,%esp
f0101e24:	5b                   	pop    %ebx
f0101e25:	5e                   	pop    %esi
f0101e26:	5f                   	pop    %edi
f0101e27:	5d                   	pop    %ebp
f0101e28:	c3                   	ret    
f0101e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101e30:	85 ff                	test   %edi,%edi
f0101e32:	89 fd                	mov    %edi,%ebp
f0101e34:	75 0b                	jne    f0101e41 <__umoddi3+0x91>
f0101e36:	b8 01 00 00 00       	mov    $0x1,%eax
f0101e3b:	31 d2                	xor    %edx,%edx
f0101e3d:	f7 f7                	div    %edi
f0101e3f:	89 c5                	mov    %eax,%ebp
f0101e41:	89 f0                	mov    %esi,%eax
f0101e43:	31 d2                	xor    %edx,%edx
f0101e45:	f7 f5                	div    %ebp
f0101e47:	89 c8                	mov    %ecx,%eax
f0101e49:	f7 f5                	div    %ebp
f0101e4b:	89 d0                	mov    %edx,%eax
f0101e4d:	eb 99                	jmp    f0101de8 <__umoddi3+0x38>
f0101e4f:	90                   	nop
f0101e50:	89 c8                	mov    %ecx,%eax
f0101e52:	89 f2                	mov    %esi,%edx
f0101e54:	83 c4 1c             	add    $0x1c,%esp
f0101e57:	5b                   	pop    %ebx
f0101e58:	5e                   	pop    %esi
f0101e59:	5f                   	pop    %edi
f0101e5a:	5d                   	pop    %ebp
f0101e5b:	c3                   	ret    
f0101e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101e60:	8b 34 24             	mov    (%esp),%esi
f0101e63:	bf 20 00 00 00       	mov    $0x20,%edi
f0101e68:	89 e9                	mov    %ebp,%ecx
f0101e6a:	29 ef                	sub    %ebp,%edi
f0101e6c:	d3 e0                	shl    %cl,%eax
f0101e6e:	89 f9                	mov    %edi,%ecx
f0101e70:	89 f2                	mov    %esi,%edx
f0101e72:	d3 ea                	shr    %cl,%edx
f0101e74:	89 e9                	mov    %ebp,%ecx
f0101e76:	09 c2                	or     %eax,%edx
f0101e78:	89 d8                	mov    %ebx,%eax
f0101e7a:	89 14 24             	mov    %edx,(%esp)
f0101e7d:	89 f2                	mov    %esi,%edx
f0101e7f:	d3 e2                	shl    %cl,%edx
f0101e81:	89 f9                	mov    %edi,%ecx
f0101e83:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101e87:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101e8b:	d3 e8                	shr    %cl,%eax
f0101e8d:	89 e9                	mov    %ebp,%ecx
f0101e8f:	89 c6                	mov    %eax,%esi
f0101e91:	d3 e3                	shl    %cl,%ebx
f0101e93:	89 f9                	mov    %edi,%ecx
f0101e95:	89 d0                	mov    %edx,%eax
f0101e97:	d3 e8                	shr    %cl,%eax
f0101e99:	89 e9                	mov    %ebp,%ecx
f0101e9b:	09 d8                	or     %ebx,%eax
f0101e9d:	89 d3                	mov    %edx,%ebx
f0101e9f:	89 f2                	mov    %esi,%edx
f0101ea1:	f7 34 24             	divl   (%esp)
f0101ea4:	89 d6                	mov    %edx,%esi
f0101ea6:	d3 e3                	shl    %cl,%ebx
f0101ea8:	f7 64 24 04          	mull   0x4(%esp)
f0101eac:	39 d6                	cmp    %edx,%esi
f0101eae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101eb2:	89 d1                	mov    %edx,%ecx
f0101eb4:	89 c3                	mov    %eax,%ebx
f0101eb6:	72 08                	jb     f0101ec0 <__umoddi3+0x110>
f0101eb8:	75 11                	jne    f0101ecb <__umoddi3+0x11b>
f0101eba:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101ebe:	73 0b                	jae    f0101ecb <__umoddi3+0x11b>
f0101ec0:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101ec4:	1b 14 24             	sbb    (%esp),%edx
f0101ec7:	89 d1                	mov    %edx,%ecx
f0101ec9:	89 c3                	mov    %eax,%ebx
f0101ecb:	8b 54 24 08          	mov    0x8(%esp),%edx
f0101ecf:	29 da                	sub    %ebx,%edx
f0101ed1:	19 ce                	sbb    %ecx,%esi
f0101ed3:	89 f9                	mov    %edi,%ecx
f0101ed5:	89 f0                	mov    %esi,%eax
f0101ed7:	d3 e0                	shl    %cl,%eax
f0101ed9:	89 e9                	mov    %ebp,%ecx
f0101edb:	d3 ea                	shr    %cl,%edx
f0101edd:	89 e9                	mov    %ebp,%ecx
f0101edf:	d3 ee                	shr    %cl,%esi
f0101ee1:	09 d0                	or     %edx,%eax
f0101ee3:	89 f2                	mov    %esi,%edx
f0101ee5:	83 c4 1c             	add    $0x1c,%esp
f0101ee8:	5b                   	pop    %ebx
f0101ee9:	5e                   	pop    %esi
f0101eea:	5f                   	pop    %edi
f0101eeb:	5d                   	pop    %ebp
f0101eec:	c3                   	ret    
f0101eed:	8d 76 00             	lea    0x0(%esi),%esi
f0101ef0:	29 f9                	sub    %edi,%ecx
f0101ef2:	19 d6                	sbb    %edx,%esi
f0101ef4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ef8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101efc:	e9 18 ff ff ff       	jmp    f0101e19 <__umoddi3+0x69>
