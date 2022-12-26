
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
f0100046:	b8 40 39 11 f0       	mov    $0xf0113940,%eax
f010004b:	2d 00 33 11 f0       	sub    $0xf0113300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 33 11 f0       	push   $0xf0113300
f0100058:	e8 5f 15 00 00       	call   f01015bc <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 96 04 00 00       	call   f01004f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 60 1a 10 f0       	push   $0xf0101a60
f010006f:	e8 84 0a 00 00       	call   f0100af8 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 09 09 00 00       	call   f0100982 <mem_init>
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
f0100093:	83 3d 44 39 11 f0 00 	cmpl   $0x0,0xf0113944
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 44 39 11 f0    	mov    %esi,0xf0113944

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
f01000b0:	68 7b 1a 10 f0       	push   $0xf0101a7b
f01000b5:	e8 3e 0a 00 00       	call   f0100af8 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 0e 0a 00 00       	call   f0100ad2 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 b7 1a 10 f0 	movl   $0xf0101ab7,(%esp)
f01000cb:	e8 28 0a 00 00       	call   f0100af8 <cprintf>
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
f01000f2:	68 93 1a 10 f0       	push   $0xf0101a93
f01000f7:	e8 fc 09 00 00       	call   f0100af8 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 ca 09 00 00       	call   f0100ad2 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 b7 1a 10 f0 	movl   $0xf0101ab7,(%esp)
f010010f:	e8 e4 09 00 00       	call   f0100af8 <cprintf>
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
f01001ce:	0f b6 82 00 1c 10 f0 	movzbl -0xfefe400(%edx),%eax
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
f010020a:	0f b6 82 00 1c 10 f0 	movzbl -0xfefe400(%edx),%eax
f0100211:	0b 05 00 33 11 f0    	or     0xf0113300,%eax
f0100217:	0f b6 8a 00 1b 10 f0 	movzbl -0xfefe500(%edx),%ecx
f010021e:	31 c8                	xor    %ecx,%eax
f0100220:	a3 00 33 11 f0       	mov    %eax,0xf0113300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100225:	89 c1                	mov    %eax,%ecx
f0100227:	83 e1 03             	and    $0x3,%ecx
f010022a:	8b 0c 8d e0 1a 10 f0 	mov    -0xfefe520(,%ecx,4),%ecx
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
f0100268:	68 ad 1a 10 f0       	push   $0xf0101aad
f010026d:	e8 86 08 00 00       	call   f0100af8 <cprintf>
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
f010041c:	e8 e8 11 00 00       	call   f0101609 <memmove>
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
f01005eb:	68 b9 1a 10 f0       	push   $0xf0101ab9
f01005f0:	e8 03 05 00 00       	call   f0100af8 <cprintf>
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
f0100631:	68 00 1d 10 f0       	push   $0xf0101d00
f0100636:	68 1e 1d 10 f0       	push   $0xf0101d1e
f010063b:	68 23 1d 10 f0       	push   $0xf0101d23
f0100640:	e8 b3 04 00 00       	call   f0100af8 <cprintf>
f0100645:	83 c4 0c             	add    $0xc,%esp
f0100648:	68 dc 1d 10 f0       	push   $0xf0101ddc
f010064d:	68 2c 1d 10 f0       	push   $0xf0101d2c
f0100652:	68 23 1d 10 f0       	push   $0xf0101d23
f0100657:	e8 9c 04 00 00       	call   f0100af8 <cprintf>
f010065c:	83 c4 0c             	add    $0xc,%esp
f010065f:	68 35 1d 10 f0       	push   $0xf0101d35
f0100664:	68 53 1d 10 f0       	push   $0xf0101d53
f0100669:	68 23 1d 10 f0       	push   $0xf0101d23
f010066e:	e8 85 04 00 00       	call   f0100af8 <cprintf>
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
f0100680:	68 5d 1d 10 f0       	push   $0xf0101d5d
f0100685:	e8 6e 04 00 00       	call   f0100af8 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010068a:	83 c4 08             	add    $0x8,%esp
f010068d:	68 0c 00 10 00       	push   $0x10000c
f0100692:	68 04 1e 10 f0       	push   $0xf0101e04
f0100697:	e8 5c 04 00 00       	call   f0100af8 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010069c:	83 c4 0c             	add    $0xc,%esp
f010069f:	68 0c 00 10 00       	push   $0x10000c
f01006a4:	68 0c 00 10 f0       	push   $0xf010000c
f01006a9:	68 2c 1e 10 f0       	push   $0xf0101e2c
f01006ae:	e8 45 04 00 00       	call   f0100af8 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b3:	83 c4 0c             	add    $0xc,%esp
f01006b6:	68 41 1a 10 00       	push   $0x101a41
f01006bb:	68 41 1a 10 f0       	push   $0xf0101a41
f01006c0:	68 50 1e 10 f0       	push   $0xf0101e50
f01006c5:	e8 2e 04 00 00       	call   f0100af8 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ca:	83 c4 0c             	add    $0xc,%esp
f01006cd:	68 00 33 11 00       	push   $0x113300
f01006d2:	68 00 33 11 f0       	push   $0xf0113300
f01006d7:	68 74 1e 10 f0       	push   $0xf0101e74
f01006dc:	e8 17 04 00 00       	call   f0100af8 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e1:	83 c4 0c             	add    $0xc,%esp
f01006e4:	68 40 39 11 00       	push   $0x113940
f01006e9:	68 40 39 11 f0       	push   $0xf0113940
f01006ee:	68 98 1e 10 f0       	push   $0xf0101e98
f01006f3:	e8 00 04 00 00       	call   f0100af8 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006f8:	b8 3f 3d 11 f0       	mov    $0xf0113d3f,%eax
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
f0100719:	68 bc 1e 10 f0       	push   $0xf0101ebc
f010071e:	e8 d5 03 00 00       	call   f0100af8 <cprintf>
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
f0100758:	68 76 1d 10 f0       	push   $0xf0101d76
f010075d:	e8 96 03 00 00       	call   f0100af8 <cprintf>

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
f010078a:	e8 73 04 00 00       	call   f0100c02 <debuginfo_eip>

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
f01007e6:	68 e8 1e 10 f0       	push   $0xf0101ee8
f01007eb:	e8 08 03 00 00       	call   f0100af8 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f01007f0:	83 c4 14             	add    $0x14,%esp
f01007f3:	2b 75 cc             	sub    -0x34(%ebp),%esi
f01007f6:	56                   	push   %esi
f01007f7:	8d 45 8a             	lea    -0x76(%ebp),%eax
f01007fa:	50                   	push   %eax
f01007fb:	ff 75 c0             	pushl  -0x40(%ebp)
f01007fe:	ff 75 bc             	pushl  -0x44(%ebp)
f0100801:	68 88 1d 10 f0       	push   $0xf0101d88
f0100806:	e8 ed 02 00 00       	call   f0100af8 <cprintf>

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
f010082e:	68 20 1f 10 f0       	push   $0xf0101f20
f0100833:	e8 c0 02 00 00       	call   f0100af8 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100838:	c7 04 24 44 1f 10 f0 	movl   $0xf0101f44,(%esp)
f010083f:	e8 b4 02 00 00       	call   f0100af8 <cprintf>
f0100844:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100847:	83 ec 0c             	sub    $0xc,%esp
f010084a:	68 9f 1d 10 f0       	push   $0xf0101d9f
f010084f:	e8 11 0b 00 00       	call   f0101365 <readline>
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
f0100883:	68 a3 1d 10 f0       	push   $0xf0101da3
f0100888:	e8 f2 0c 00 00       	call   f010157f <strchr>
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
f01008a3:	68 a8 1d 10 f0       	push   $0xf0101da8
f01008a8:	e8 4b 02 00 00       	call   f0100af8 <cprintf>
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
f01008cc:	68 a3 1d 10 f0       	push   $0xf0101da3
f01008d1:	e8 a9 0c 00 00       	call   f010157f <strchr>
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
f01008fa:	ff 34 85 80 1f 10 f0 	pushl  -0xfefe080(,%eax,4)
f0100901:	ff 75 a8             	pushl  -0x58(%ebp)
f0100904:	e8 18 0c 00 00       	call   f0101521 <strcmp>
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
f010091e:	ff 14 85 88 1f 10 f0 	call   *-0xfefe078(,%eax,4)


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
f010093f:	68 c5 1d 10 f0       	push   $0xf0101dc5
f0100944:	e8 af 01 00 00       	call   f0100af8 <cprintf>
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
f0100964:	e8 28 01 00 00       	call   f0100a91 <mc146818_read>
f0100969:	89 c6                	mov    %eax,%esi
f010096b:	83 c3 01             	add    $0x1,%ebx
f010096e:	89 1c 24             	mov    %ebx,(%esp)
f0100971:	e8 1b 01 00 00       	call   f0100a91 <mc146818_read>
f0100976:	c1 e0 08             	shl    $0x8,%eax
f0100979:	09 f0                	or     %esi,%eax
}
f010097b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010097e:	5b                   	pop    %ebx
f010097f:	5e                   	pop    %esi
f0100980:	5d                   	pop    %ebp
f0100981:	c3                   	ret    

f0100982 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100982:	55                   	push   %ebp
f0100983:	89 e5                	mov    %esp,%ebp
f0100985:	56                   	push   %esi
f0100986:	53                   	push   %ebx
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100987:	b8 15 00 00 00       	mov    $0x15,%eax
f010098c:	e8 c8 ff ff ff       	call   f0100959 <nvram_read>
f0100991:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100993:	b8 17 00 00 00       	mov    $0x17,%eax
f0100998:	e8 bc ff ff ff       	call   f0100959 <nvram_read>
f010099d:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010099f:	b8 34 00 00 00       	mov    $0x34,%eax
f01009a4:	e8 b0 ff ff ff       	call   f0100959 <nvram_read>
f01009a9:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01009ac:	85 c0                	test   %eax,%eax
f01009ae:	74 07                	je     f01009b7 <mem_init+0x35>
		totalmem = 16 * 1024 + ext16mem;
f01009b0:	05 00 40 00 00       	add    $0x4000,%eax
f01009b5:	eb 0b                	jmp    f01009c2 <mem_init+0x40>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01009b7:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01009bd:	85 f6                	test   %esi,%esi
f01009bf:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01009c2:	89 c2                	mov    %eax,%edx
f01009c4:	c1 ea 02             	shr    $0x2,%edx
f01009c7:	89 15 48 39 11 f0    	mov    %edx,0xf0113948
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01009cd:	89 c2                	mov    %eax,%edx
f01009cf:	29 da                	sub    %ebx,%edx
f01009d1:	52                   	push   %edx
f01009d2:	53                   	push   %ebx
f01009d3:	50                   	push   %eax
f01009d4:	68 a4 1f 10 f0       	push   $0xf0101fa4
f01009d9:	e8 1a 01 00 00       	call   f0100af8 <cprintf>

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	// Remove this line when you're ready to test this function.
	panic("mem_init: This function is not finished\n");
f01009de:	83 c4 0c             	add    $0xc,%esp
f01009e1:	68 e0 1f 10 f0       	push   $0xf0101fe0
f01009e6:	68 80 00 00 00       	push   $0x80
f01009eb:	68 0c 20 10 f0       	push   $0xf010200c
f01009f0:	e8 96 f6 ff ff       	call   f010008b <_panic>

f01009f5 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01009f5:	55                   	push   %ebp
f01009f6:	89 e5                	mov    %esp,%ebp
f01009f8:	53                   	push   %ebx
f01009f9:	8b 1d 38 35 11 f0    	mov    0xf0113538,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01009ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a04:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a09:	eb 27                	jmp    f0100a32 <page_init+0x3d>
f0100a0b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100a12:	89 d1                	mov    %edx,%ecx
f0100a14:	03 0d 50 39 11 f0    	add    0xf0113950,%ecx
f0100a1a:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100a20:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100a22:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100a25:	89 d3                	mov    %edx,%ebx
f0100a27:	03 1d 50 39 11 f0    	add    0xf0113950,%ebx
f0100a2d:	ba 01 00 00 00       	mov    $0x1,%edx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100a32:	3b 05 48 39 11 f0    	cmp    0xf0113948,%eax
f0100a38:	72 d1                	jb     f0100a0b <page_init+0x16>
f0100a3a:	84 d2                	test   %dl,%dl
f0100a3c:	74 06                	je     f0100a44 <page_init+0x4f>
f0100a3e:	89 1d 38 35 11 f0    	mov    %ebx,0xf0113538
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100a44:	5b                   	pop    %ebx
f0100a45:	5d                   	pop    %ebp
f0100a46:	c3                   	ret    

f0100a47 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100a47:	55                   	push   %ebp
f0100a48:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100a4a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a4f:	5d                   	pop    %ebp
f0100a50:	c3                   	ret    

f0100a51 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100a51:	55                   	push   %ebp
f0100a52:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
}
f0100a54:	5d                   	pop    %ebp
f0100a55:	c3                   	ret    

f0100a56 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100a56:	55                   	push   %ebp
f0100a57:	89 e5                	mov    %esp,%ebp
f0100a59:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100a5c:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
		page_free(pp);
}
f0100a61:	5d                   	pop    %ebp
f0100a62:	c3                   	ret    

f0100a63 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100a63:	55                   	push   %ebp
f0100a64:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100a66:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a6b:	5d                   	pop    %ebp
f0100a6c:	c3                   	ret    

f0100a6d <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100a6d:	55                   	push   %ebp
f0100a6e:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100a70:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a75:	5d                   	pop    %ebp
f0100a76:	c3                   	ret    

f0100a77 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100a77:	55                   	push   %ebp
f0100a78:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100a7a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a7f:	5d                   	pop    %ebp
f0100a80:	c3                   	ret    

f0100a81 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100a81:	55                   	push   %ebp
f0100a82:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100a84:	5d                   	pop    %ebp
f0100a85:	c3                   	ret    

f0100a86 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100a86:	55                   	push   %ebp
f0100a87:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100a89:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a8c:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100a8f:	5d                   	pop    %ebp
f0100a90:	c3                   	ret    

f0100a91 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100a91:	55                   	push   %ebp
f0100a92:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100a94:	ba 70 00 00 00       	mov    $0x70,%edx
f0100a99:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a9c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100a9d:	ba 71 00 00 00       	mov    $0x71,%edx
f0100aa2:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100aa3:	0f b6 c0             	movzbl %al,%eax
}
f0100aa6:	5d                   	pop    %ebp
f0100aa7:	c3                   	ret    

f0100aa8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100aa8:	55                   	push   %ebp
f0100aa9:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100aab:	ba 70 00 00 00       	mov    $0x70,%edx
f0100ab0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ab3:	ee                   	out    %al,(%dx)
f0100ab4:	ba 71 00 00 00       	mov    $0x71,%edx
f0100ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100abc:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100abd:	5d                   	pop    %ebp
f0100abe:	c3                   	ret    

f0100abf <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100abf:	55                   	push   %ebp
f0100ac0:	89 e5                	mov    %esp,%ebp
f0100ac2:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100ac5:	ff 75 08             	pushl  0x8(%ebp)
f0100ac8:	e8 33 fb ff ff       	call   f0100600 <cputchar>
	*cnt++;
}
f0100acd:	83 c4 10             	add    $0x10,%esp
f0100ad0:	c9                   	leave  
f0100ad1:	c3                   	ret    

f0100ad2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100ad2:	55                   	push   %ebp
f0100ad3:	89 e5                	mov    %esp,%ebp
f0100ad5:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100ad8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100adf:	ff 75 0c             	pushl  0xc(%ebp)
f0100ae2:	ff 75 08             	pushl  0x8(%ebp)
f0100ae5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100ae8:	50                   	push   %eax
f0100ae9:	68 bf 0a 10 f0       	push   $0xf0100abf
f0100aee:	e8 5d 04 00 00       	call   f0100f50 <vprintfmt>
	return cnt;
}
f0100af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100af6:	c9                   	leave  
f0100af7:	c3                   	ret    

f0100af8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100af8:	55                   	push   %ebp
f0100af9:	89 e5                	mov    %esp,%ebp
f0100afb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100afe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b01:	50                   	push   %eax
f0100b02:	ff 75 08             	pushl  0x8(%ebp)
f0100b05:	e8 c8 ff ff ff       	call   f0100ad2 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b0a:	c9                   	leave  
f0100b0b:	c3                   	ret    

f0100b0c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b0c:	55                   	push   %ebp
f0100b0d:	89 e5                	mov    %esp,%ebp
f0100b0f:	57                   	push   %edi
f0100b10:	56                   	push   %esi
f0100b11:	53                   	push   %ebx
f0100b12:	83 ec 14             	sub    $0x14,%esp
f0100b15:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b18:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b1b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b1e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b21:	8b 1a                	mov    (%edx),%ebx
f0100b23:	8b 01                	mov    (%ecx),%eax
f0100b25:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b28:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b2f:	eb 7f                	jmp    f0100bb0 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0100b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b34:	01 d8                	add    %ebx,%eax
f0100b36:	89 c6                	mov    %eax,%esi
f0100b38:	c1 ee 1f             	shr    $0x1f,%esi
f0100b3b:	01 c6                	add    %eax,%esi
f0100b3d:	d1 fe                	sar    %esi
f0100b3f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100b42:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b45:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100b48:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100b4a:	eb 03                	jmp    f0100b4f <stab_binsearch+0x43>
			m--;
f0100b4c:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100b4f:	39 c3                	cmp    %eax,%ebx
f0100b51:	7f 0d                	jg     f0100b60 <stab_binsearch+0x54>
f0100b53:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100b57:	83 ea 0c             	sub    $0xc,%edx
f0100b5a:	39 f9                	cmp    %edi,%ecx
f0100b5c:	75 ee                	jne    f0100b4c <stab_binsearch+0x40>
f0100b5e:	eb 05                	jmp    f0100b65 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100b60:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100b63:	eb 4b                	jmp    f0100bb0 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b65:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b68:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b6b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b6f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100b72:	76 11                	jbe    f0100b85 <stab_binsearch+0x79>
			*region_left = m;
f0100b74:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100b77:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100b79:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100b7c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b83:	eb 2b                	jmp    f0100bb0 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100b85:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100b88:	73 14                	jae    f0100b9e <stab_binsearch+0x92>
			*region_right = m - 1;
f0100b8a:	83 e8 01             	sub    $0x1,%eax
f0100b8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b90:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100b93:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100b95:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b9c:	eb 12                	jmp    f0100bb0 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b9e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ba1:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100ba3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100ba7:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100ba9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100bb0:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100bb3:	0f 8e 78 ff ff ff    	jle    f0100b31 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100bb9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100bbd:	75 0f                	jne    f0100bce <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100bbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bc2:	8b 00                	mov    (%eax),%eax
f0100bc4:	83 e8 01             	sub    $0x1,%eax
f0100bc7:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100bca:	89 06                	mov    %eax,(%esi)
f0100bcc:	eb 2c                	jmp    f0100bfa <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100bce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bd1:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100bd3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bd6:	8b 0e                	mov    (%esi),%ecx
f0100bd8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bdb:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100bde:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100be1:	eb 03                	jmp    f0100be6 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100be3:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100be6:	39 c8                	cmp    %ecx,%eax
f0100be8:	7e 0b                	jle    f0100bf5 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100bea:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100bee:	83 ea 0c             	sub    $0xc,%edx
f0100bf1:	39 df                	cmp    %ebx,%edi
f0100bf3:	75 ee                	jne    f0100be3 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100bf5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bf8:	89 06                	mov    %eax,(%esi)
	}
}
f0100bfa:	83 c4 14             	add    $0x14,%esp
f0100bfd:	5b                   	pop    %ebx
f0100bfe:	5e                   	pop    %esi
f0100bff:	5f                   	pop    %edi
f0100c00:	5d                   	pop    %ebp
f0100c01:	c3                   	ret    

f0100c02 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c02:	55                   	push   %ebp
f0100c03:	89 e5                	mov    %esp,%ebp
f0100c05:	57                   	push   %edi
f0100c06:	56                   	push   %esi
f0100c07:	53                   	push   %ebx
f0100c08:	83 ec 3c             	sub    $0x3c,%esp
f0100c0b:	8b 75 08             	mov    0x8(%ebp),%esi
f0100c0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c11:	c7 03 18 20 10 f0    	movl   $0xf0102018,(%ebx)
	info->eip_line = 0;
f0100c17:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100c1e:	c7 43 08 18 20 10 f0 	movl   $0xf0102018,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100c25:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100c2c:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100c2f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c36:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100c3c:	76 11                	jbe    f0100c4f <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c3e:	b8 0f 80 10 f0       	mov    $0xf010800f,%eax
f0100c43:	3d f1 63 10 f0       	cmp    $0xf01063f1,%eax
f0100c48:	77 19                	ja     f0100c63 <debuginfo_eip+0x61>
f0100c4a:	e9 b5 01 00 00       	jmp    f0100e04 <debuginfo_eip+0x202>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100c4f:	83 ec 04             	sub    $0x4,%esp
f0100c52:	68 22 20 10 f0       	push   $0xf0102022
f0100c57:	6a 7f                	push   $0x7f
f0100c59:	68 2f 20 10 f0       	push   $0xf010202f
f0100c5e:	e8 28 f4 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c63:	80 3d 0e 80 10 f0 00 	cmpb   $0x0,0xf010800e
f0100c6a:	0f 85 9b 01 00 00    	jne    f0100e0b <debuginfo_eip+0x209>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c70:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c77:	b8 f0 63 10 f0       	mov    $0xf01063f0,%eax
f0100c7c:	2d 50 22 10 f0       	sub    $0xf0102250,%eax
f0100c81:	c1 f8 02             	sar    $0x2,%eax
f0100c84:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100c8a:	83 e8 01             	sub    $0x1,%eax
f0100c8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c90:	83 ec 08             	sub    $0x8,%esp
f0100c93:	56                   	push   %esi
f0100c94:	6a 64                	push   $0x64
f0100c96:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c99:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c9c:	b8 50 22 10 f0       	mov    $0xf0102250,%eax
f0100ca1:	e8 66 fe ff ff       	call   f0100b0c <stab_binsearch>
	if (lfile == 0)
f0100ca6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ca9:	83 c4 10             	add    $0x10,%esp
f0100cac:	85 c0                	test   %eax,%eax
f0100cae:	0f 84 5e 01 00 00    	je     f0100e12 <debuginfo_eip+0x210>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100cb4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100cb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cba:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100cbd:	83 ec 08             	sub    $0x8,%esp
f0100cc0:	56                   	push   %esi
f0100cc1:	6a 24                	push   $0x24
f0100cc3:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100cc6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cc9:	b8 50 22 10 f0       	mov    $0xf0102250,%eax
f0100cce:	e8 39 fe ff ff       	call   f0100b0c <stab_binsearch>

	if (lfun <= rfun) {
f0100cd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cd6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100cd9:	83 c4 10             	add    $0x10,%esp
f0100cdc:	39 d0                	cmp    %edx,%eax
f0100cde:	7f 40                	jg     f0100d20 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100ce0:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100ce3:	c1 e1 02             	shl    $0x2,%ecx
f0100ce6:	8d b9 50 22 10 f0    	lea    -0xfefddb0(%ecx),%edi
f0100cec:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100cef:	8b b9 50 22 10 f0    	mov    -0xfefddb0(%ecx),%edi
f0100cf5:	b9 0f 80 10 f0       	mov    $0xf010800f,%ecx
f0100cfa:	81 e9 f1 63 10 f0    	sub    $0xf01063f1,%ecx
f0100d00:	39 cf                	cmp    %ecx,%edi
f0100d02:	73 09                	jae    f0100d0d <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d04:	81 c7 f1 63 10 f0    	add    $0xf01063f1,%edi
f0100d0a:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d0d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100d10:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100d13:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100d16:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100d18:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d1b:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100d1e:	eb 0f                	jmp    f0100d2f <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100d20:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100d23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d26:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100d29:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d2c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d2f:	83 ec 08             	sub    $0x8,%esp
f0100d32:	6a 3a                	push   $0x3a
f0100d34:	ff 73 08             	pushl  0x8(%ebx)
f0100d37:	e8 64 08 00 00       	call   f01015a0 <strfind>
f0100d3c:	2b 43 08             	sub    0x8(%ebx),%eax
f0100d3f:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d42:	83 c4 08             	add    $0x8,%esp
f0100d45:	56                   	push   %esi
f0100d46:	6a 44                	push   $0x44
f0100d48:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d4b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d4e:	b8 50 22 10 f0       	mov    $0xf0102250,%eax
f0100d53:	e8 b4 fd ff ff       	call   f0100b0c <stab_binsearch>
	if (lline == 0)
f0100d58:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d5b:	83 c4 10             	add    $0x10,%esp
f0100d5e:	85 c0                	test   %eax,%eax
f0100d60:	0f 84 b3 00 00 00    	je     f0100e19 <debuginfo_eip+0x217>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0100d66:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100d69:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100d6c:	0f b7 14 95 56 22 10 	movzwl -0xfefddaa(,%edx,4),%edx
f0100d73:	f0 
f0100d74:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d7a:	89 c2                	mov    %eax,%edx
f0100d7c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100d7f:	8d 04 85 50 22 10 f0 	lea    -0xfefddb0(,%eax,4),%eax
f0100d86:	eb 06                	jmp    f0100d8e <debuginfo_eip+0x18c>
f0100d88:	83 ea 01             	sub    $0x1,%edx
f0100d8b:	83 e8 0c             	sub    $0xc,%eax
f0100d8e:	39 d7                	cmp    %edx,%edi
f0100d90:	7f 34                	jg     f0100dc6 <debuginfo_eip+0x1c4>
	       && stabs[lline].n_type != N_SOL
f0100d92:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100d96:	80 f9 84             	cmp    $0x84,%cl
f0100d99:	74 0b                	je     f0100da6 <debuginfo_eip+0x1a4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d9b:	80 f9 64             	cmp    $0x64,%cl
f0100d9e:	75 e8                	jne    f0100d88 <debuginfo_eip+0x186>
f0100da0:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100da4:	74 e2                	je     f0100d88 <debuginfo_eip+0x186>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100da6:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100da9:	8b 14 85 50 22 10 f0 	mov    -0xfefddb0(,%eax,4),%edx
f0100db0:	b8 0f 80 10 f0       	mov    $0xf010800f,%eax
f0100db5:	2d f1 63 10 f0       	sub    $0xf01063f1,%eax
f0100dba:	39 c2                	cmp    %eax,%edx
f0100dbc:	73 08                	jae    f0100dc6 <debuginfo_eip+0x1c4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100dbe:	81 c2 f1 63 10 f0    	add    $0xf01063f1,%edx
f0100dc4:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100dc6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100dc9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100dcc:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100dd1:	39 f2                	cmp    %esi,%edx
f0100dd3:	7d 50                	jge    f0100e25 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
f0100dd5:	83 c2 01             	add    $0x1,%edx
f0100dd8:	89 d0                	mov    %edx,%eax
f0100dda:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100ddd:	8d 14 95 50 22 10 f0 	lea    -0xfefddb0(,%edx,4),%edx
f0100de4:	eb 04                	jmp    f0100dea <debuginfo_eip+0x1e8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100de6:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100dea:	39 c6                	cmp    %eax,%esi
f0100dec:	7e 32                	jle    f0100e20 <debuginfo_eip+0x21e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100dee:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100df2:	83 c0 01             	add    $0x1,%eax
f0100df5:	83 c2 0c             	add    $0xc,%edx
f0100df8:	80 f9 a0             	cmp    $0xa0,%cl
f0100dfb:	74 e9                	je     f0100de6 <debuginfo_eip+0x1e4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100dfd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e02:	eb 21                	jmp    f0100e25 <debuginfo_eip+0x223>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100e04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e09:	eb 1a                	jmp    f0100e25 <debuginfo_eip+0x223>
f0100e0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e10:	eb 13                	jmp    f0100e25 <debuginfo_eip+0x223>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100e12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e17:	eb 0c                	jmp    f0100e25 <debuginfo_eip+0x223>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0100e19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e1e:	eb 05                	jmp    f0100e25 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e20:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e25:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e28:	5b                   	pop    %ebx
f0100e29:	5e                   	pop    %esi
f0100e2a:	5f                   	pop    %edi
f0100e2b:	5d                   	pop    %ebp
f0100e2c:	c3                   	ret    

f0100e2d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100e2d:	55                   	push   %ebp
f0100e2e:	89 e5                	mov    %esp,%ebp
f0100e30:	57                   	push   %edi
f0100e31:	56                   	push   %esi
f0100e32:	53                   	push   %ebx
f0100e33:	83 ec 1c             	sub    $0x1c,%esp
f0100e36:	89 c7                	mov    %eax,%edi
f0100e38:	89 d6                	mov    %edx,%esi
f0100e3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e3d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100e40:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e43:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e46:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100e49:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e4e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100e51:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100e54:	39 d3                	cmp    %edx,%ebx
f0100e56:	72 05                	jb     f0100e5d <printnum+0x30>
f0100e58:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100e5b:	77 45                	ja     f0100ea2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100e5d:	83 ec 0c             	sub    $0xc,%esp
f0100e60:	ff 75 18             	pushl  0x18(%ebp)
f0100e63:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e66:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100e69:	53                   	push   %ebx
f0100e6a:	ff 75 10             	pushl  0x10(%ebp)
f0100e6d:	83 ec 08             	sub    $0x8,%esp
f0100e70:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100e73:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e76:	ff 75 dc             	pushl  -0x24(%ebp)
f0100e79:	ff 75 d8             	pushl  -0x28(%ebp)
f0100e7c:	e8 3f 09 00 00       	call   f01017c0 <__udivdi3>
f0100e81:	83 c4 18             	add    $0x18,%esp
f0100e84:	52                   	push   %edx
f0100e85:	50                   	push   %eax
f0100e86:	89 f2                	mov    %esi,%edx
f0100e88:	89 f8                	mov    %edi,%eax
f0100e8a:	e8 9e ff ff ff       	call   f0100e2d <printnum>
f0100e8f:	83 c4 20             	add    $0x20,%esp
f0100e92:	eb 18                	jmp    f0100eac <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100e94:	83 ec 08             	sub    $0x8,%esp
f0100e97:	56                   	push   %esi
f0100e98:	ff 75 18             	pushl  0x18(%ebp)
f0100e9b:	ff d7                	call   *%edi
f0100e9d:	83 c4 10             	add    $0x10,%esp
f0100ea0:	eb 03                	jmp    f0100ea5 <printnum+0x78>
f0100ea2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100ea5:	83 eb 01             	sub    $0x1,%ebx
f0100ea8:	85 db                	test   %ebx,%ebx
f0100eaa:	7f e8                	jg     f0100e94 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100eac:	83 ec 08             	sub    $0x8,%esp
f0100eaf:	56                   	push   %esi
f0100eb0:	83 ec 04             	sub    $0x4,%esp
f0100eb3:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100eb6:	ff 75 e0             	pushl  -0x20(%ebp)
f0100eb9:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ebc:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ebf:	e8 2c 0a 00 00       	call   f01018f0 <__umoddi3>
f0100ec4:	83 c4 14             	add    $0x14,%esp
f0100ec7:	0f be 80 3d 20 10 f0 	movsbl -0xfefdfc3(%eax),%eax
f0100ece:	50                   	push   %eax
f0100ecf:	ff d7                	call   *%edi
}
f0100ed1:	83 c4 10             	add    $0x10,%esp
f0100ed4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ed7:	5b                   	pop    %ebx
f0100ed8:	5e                   	pop    %esi
f0100ed9:	5f                   	pop    %edi
f0100eda:	5d                   	pop    %ebp
f0100edb:	c3                   	ret    

f0100edc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100edc:	55                   	push   %ebp
f0100edd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100edf:	83 fa 01             	cmp    $0x1,%edx
f0100ee2:	7e 0e                	jle    f0100ef2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100ee4:	8b 10                	mov    (%eax),%edx
f0100ee6:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100ee9:	89 08                	mov    %ecx,(%eax)
f0100eeb:	8b 02                	mov    (%edx),%eax
f0100eed:	8b 52 04             	mov    0x4(%edx),%edx
f0100ef0:	eb 22                	jmp    f0100f14 <getuint+0x38>
	else if (lflag)
f0100ef2:	85 d2                	test   %edx,%edx
f0100ef4:	74 10                	je     f0100f06 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100ef6:	8b 10                	mov    (%eax),%edx
f0100ef8:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100efb:	89 08                	mov    %ecx,(%eax)
f0100efd:	8b 02                	mov    (%edx),%eax
f0100eff:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f04:	eb 0e                	jmp    f0100f14 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100f06:	8b 10                	mov    (%eax),%edx
f0100f08:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100f0b:	89 08                	mov    %ecx,(%eax)
f0100f0d:	8b 02                	mov    (%edx),%eax
f0100f0f:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100f14:	5d                   	pop    %ebp
f0100f15:	c3                   	ret    

f0100f16 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f16:	55                   	push   %ebp
f0100f17:	89 e5                	mov    %esp,%ebp
f0100f19:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f1c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f20:	8b 10                	mov    (%eax),%edx
f0100f22:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f25:	73 0a                	jae    f0100f31 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f27:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f2a:	89 08                	mov    %ecx,(%eax)
f0100f2c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f2f:	88 02                	mov    %al,(%edx)
}
f0100f31:	5d                   	pop    %ebp
f0100f32:	c3                   	ret    

f0100f33 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100f33:	55                   	push   %ebp
f0100f34:	89 e5                	mov    %esp,%ebp
f0100f36:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100f39:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f3c:	50                   	push   %eax
f0100f3d:	ff 75 10             	pushl  0x10(%ebp)
f0100f40:	ff 75 0c             	pushl  0xc(%ebp)
f0100f43:	ff 75 08             	pushl  0x8(%ebp)
f0100f46:	e8 05 00 00 00       	call   f0100f50 <vprintfmt>
	va_end(ap);
}
f0100f4b:	83 c4 10             	add    $0x10,%esp
f0100f4e:	c9                   	leave  
f0100f4f:	c3                   	ret    

f0100f50 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100f50:	55                   	push   %ebp
f0100f51:	89 e5                	mov    %esp,%ebp
f0100f53:	57                   	push   %edi
f0100f54:	56                   	push   %esi
f0100f55:	53                   	push   %ebx
f0100f56:	83 ec 2c             	sub    $0x2c,%esp
f0100f59:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f5f:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100f62:	eb 12                	jmp    f0100f76 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100f64:	85 c0                	test   %eax,%eax
f0100f66:	0f 84 89 03 00 00    	je     f01012f5 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100f6c:	83 ec 08             	sub    $0x8,%esp
f0100f6f:	53                   	push   %ebx
f0100f70:	50                   	push   %eax
f0100f71:	ff d6                	call   *%esi
f0100f73:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100f76:	83 c7 01             	add    $0x1,%edi
f0100f79:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100f7d:	83 f8 25             	cmp    $0x25,%eax
f0100f80:	75 e2                	jne    f0100f64 <vprintfmt+0x14>
f0100f82:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100f86:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100f8d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100f94:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100f9b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100fa0:	eb 07                	jmp    f0100fa9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fa2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100fa5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fa9:	8d 47 01             	lea    0x1(%edi),%eax
f0100fac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100faf:	0f b6 07             	movzbl (%edi),%eax
f0100fb2:	0f b6 c8             	movzbl %al,%ecx
f0100fb5:	83 e8 23             	sub    $0x23,%eax
f0100fb8:	3c 55                	cmp    $0x55,%al
f0100fba:	0f 87 1a 03 00 00    	ja     f01012da <vprintfmt+0x38a>
f0100fc0:	0f b6 c0             	movzbl %al,%eax
f0100fc3:	ff 24 85 cc 20 10 f0 	jmp    *-0xfefdf34(,%eax,4)
f0100fca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100fcd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100fd1:	eb d6                	jmp    f0100fa9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fd3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100fd6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fdb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100fde:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100fe1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100fe5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100fe8:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100feb:	83 fa 09             	cmp    $0x9,%edx
f0100fee:	77 39                	ja     f0101029 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100ff0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100ff3:	eb e9                	jmp    f0100fde <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100ff5:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff8:	8d 48 04             	lea    0x4(%eax),%ecx
f0100ffb:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100ffe:	8b 00                	mov    (%eax),%eax
f0101000:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101003:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101006:	eb 27                	jmp    f010102f <vprintfmt+0xdf>
f0101008:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010100b:	85 c0                	test   %eax,%eax
f010100d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101012:	0f 49 c8             	cmovns %eax,%ecx
f0101015:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101018:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010101b:	eb 8c                	jmp    f0100fa9 <vprintfmt+0x59>
f010101d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101020:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101027:	eb 80                	jmp    f0100fa9 <vprintfmt+0x59>
f0101029:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010102c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010102f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101033:	0f 89 70 ff ff ff    	jns    f0100fa9 <vprintfmt+0x59>
				width = precision, precision = -1;
f0101039:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010103c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010103f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101046:	e9 5e ff ff ff       	jmp    f0100fa9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010104b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010104e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0101051:	e9 53 ff ff ff       	jmp    f0100fa9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101056:	8b 45 14             	mov    0x14(%ebp),%eax
f0101059:	8d 50 04             	lea    0x4(%eax),%edx
f010105c:	89 55 14             	mov    %edx,0x14(%ebp)
f010105f:	83 ec 08             	sub    $0x8,%esp
f0101062:	53                   	push   %ebx
f0101063:	ff 30                	pushl  (%eax)
f0101065:	ff d6                	call   *%esi
			break;
f0101067:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010106a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010106d:	e9 04 ff ff ff       	jmp    f0100f76 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101072:	8b 45 14             	mov    0x14(%ebp),%eax
f0101075:	8d 50 04             	lea    0x4(%eax),%edx
f0101078:	89 55 14             	mov    %edx,0x14(%ebp)
f010107b:	8b 00                	mov    (%eax),%eax
f010107d:	99                   	cltd   
f010107e:	31 d0                	xor    %edx,%eax
f0101080:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101082:	83 f8 06             	cmp    $0x6,%eax
f0101085:	7f 0b                	jg     f0101092 <vprintfmt+0x142>
f0101087:	8b 14 85 24 22 10 f0 	mov    -0xfefdddc(,%eax,4),%edx
f010108e:	85 d2                	test   %edx,%edx
f0101090:	75 18                	jne    f01010aa <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0101092:	50                   	push   %eax
f0101093:	68 55 20 10 f0       	push   $0xf0102055
f0101098:	53                   	push   %ebx
f0101099:	56                   	push   %esi
f010109a:	e8 94 fe ff ff       	call   f0100f33 <printfmt>
f010109f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01010a5:	e9 cc fe ff ff       	jmp    f0100f76 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01010aa:	52                   	push   %edx
f01010ab:	68 5e 20 10 f0       	push   $0xf010205e
f01010b0:	53                   	push   %ebx
f01010b1:	56                   	push   %esi
f01010b2:	e8 7c fe ff ff       	call   f0100f33 <printfmt>
f01010b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01010bd:	e9 b4 fe ff ff       	jmp    f0100f76 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01010c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c5:	8d 50 04             	lea    0x4(%eax),%edx
f01010c8:	89 55 14             	mov    %edx,0x14(%ebp)
f01010cb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01010cd:	85 ff                	test   %edi,%edi
f01010cf:	b8 4e 20 10 f0       	mov    $0xf010204e,%eax
f01010d4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01010d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01010db:	0f 8e 94 00 00 00    	jle    f0101175 <vprintfmt+0x225>
f01010e1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01010e5:	0f 84 98 00 00 00    	je     f0101183 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f01010eb:	83 ec 08             	sub    $0x8,%esp
f01010ee:	ff 75 d0             	pushl  -0x30(%ebp)
f01010f1:	57                   	push   %edi
f01010f2:	e8 5f 03 00 00       	call   f0101456 <strnlen>
f01010f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01010fa:	29 c1                	sub    %eax,%ecx
f01010fc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01010ff:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101102:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101106:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101109:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010110c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010110e:	eb 0f                	jmp    f010111f <vprintfmt+0x1cf>
					putch(padc, putdat);
f0101110:	83 ec 08             	sub    $0x8,%esp
f0101113:	53                   	push   %ebx
f0101114:	ff 75 e0             	pushl  -0x20(%ebp)
f0101117:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101119:	83 ef 01             	sub    $0x1,%edi
f010111c:	83 c4 10             	add    $0x10,%esp
f010111f:	85 ff                	test   %edi,%edi
f0101121:	7f ed                	jg     f0101110 <vprintfmt+0x1c0>
f0101123:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101126:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101129:	85 c9                	test   %ecx,%ecx
f010112b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101130:	0f 49 c1             	cmovns %ecx,%eax
f0101133:	29 c1                	sub    %eax,%ecx
f0101135:	89 75 08             	mov    %esi,0x8(%ebp)
f0101138:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010113b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010113e:	89 cb                	mov    %ecx,%ebx
f0101140:	eb 4d                	jmp    f010118f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101142:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101146:	74 1b                	je     f0101163 <vprintfmt+0x213>
f0101148:	0f be c0             	movsbl %al,%eax
f010114b:	83 e8 20             	sub    $0x20,%eax
f010114e:	83 f8 5e             	cmp    $0x5e,%eax
f0101151:	76 10                	jbe    f0101163 <vprintfmt+0x213>
					putch('?', putdat);
f0101153:	83 ec 08             	sub    $0x8,%esp
f0101156:	ff 75 0c             	pushl  0xc(%ebp)
f0101159:	6a 3f                	push   $0x3f
f010115b:	ff 55 08             	call   *0x8(%ebp)
f010115e:	83 c4 10             	add    $0x10,%esp
f0101161:	eb 0d                	jmp    f0101170 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0101163:	83 ec 08             	sub    $0x8,%esp
f0101166:	ff 75 0c             	pushl  0xc(%ebp)
f0101169:	52                   	push   %edx
f010116a:	ff 55 08             	call   *0x8(%ebp)
f010116d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101170:	83 eb 01             	sub    $0x1,%ebx
f0101173:	eb 1a                	jmp    f010118f <vprintfmt+0x23f>
f0101175:	89 75 08             	mov    %esi,0x8(%ebp)
f0101178:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010117b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010117e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101181:	eb 0c                	jmp    f010118f <vprintfmt+0x23f>
f0101183:	89 75 08             	mov    %esi,0x8(%ebp)
f0101186:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101189:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010118c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010118f:	83 c7 01             	add    $0x1,%edi
f0101192:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101196:	0f be d0             	movsbl %al,%edx
f0101199:	85 d2                	test   %edx,%edx
f010119b:	74 23                	je     f01011c0 <vprintfmt+0x270>
f010119d:	85 f6                	test   %esi,%esi
f010119f:	78 a1                	js     f0101142 <vprintfmt+0x1f2>
f01011a1:	83 ee 01             	sub    $0x1,%esi
f01011a4:	79 9c                	jns    f0101142 <vprintfmt+0x1f2>
f01011a6:	89 df                	mov    %ebx,%edi
f01011a8:	8b 75 08             	mov    0x8(%ebp),%esi
f01011ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011ae:	eb 18                	jmp    f01011c8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01011b0:	83 ec 08             	sub    $0x8,%esp
f01011b3:	53                   	push   %ebx
f01011b4:	6a 20                	push   $0x20
f01011b6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01011b8:	83 ef 01             	sub    $0x1,%edi
f01011bb:	83 c4 10             	add    $0x10,%esp
f01011be:	eb 08                	jmp    f01011c8 <vprintfmt+0x278>
f01011c0:	89 df                	mov    %ebx,%edi
f01011c2:	8b 75 08             	mov    0x8(%ebp),%esi
f01011c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011c8:	85 ff                	test   %edi,%edi
f01011ca:	7f e4                	jg     f01011b0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01011cf:	e9 a2 fd ff ff       	jmp    f0100f76 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01011d4:	83 fa 01             	cmp    $0x1,%edx
f01011d7:	7e 16                	jle    f01011ef <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01011d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01011dc:	8d 50 08             	lea    0x8(%eax),%edx
f01011df:	89 55 14             	mov    %edx,0x14(%ebp)
f01011e2:	8b 50 04             	mov    0x4(%eax),%edx
f01011e5:	8b 00                	mov    (%eax),%eax
f01011e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01011ed:	eb 32                	jmp    f0101221 <vprintfmt+0x2d1>
	else if (lflag)
f01011ef:	85 d2                	test   %edx,%edx
f01011f1:	74 18                	je     f010120b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01011f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01011f6:	8d 50 04             	lea    0x4(%eax),%edx
f01011f9:	89 55 14             	mov    %edx,0x14(%ebp)
f01011fc:	8b 00                	mov    (%eax),%eax
f01011fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101201:	89 c1                	mov    %eax,%ecx
f0101203:	c1 f9 1f             	sar    $0x1f,%ecx
f0101206:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101209:	eb 16                	jmp    f0101221 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f010120b:	8b 45 14             	mov    0x14(%ebp),%eax
f010120e:	8d 50 04             	lea    0x4(%eax),%edx
f0101211:	89 55 14             	mov    %edx,0x14(%ebp)
f0101214:	8b 00                	mov    (%eax),%eax
f0101216:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101219:	89 c1                	mov    %eax,%ecx
f010121b:	c1 f9 1f             	sar    $0x1f,%ecx
f010121e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101221:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101224:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101227:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010122c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101230:	79 74                	jns    f01012a6 <vprintfmt+0x356>
				putch('-', putdat);
f0101232:	83 ec 08             	sub    $0x8,%esp
f0101235:	53                   	push   %ebx
f0101236:	6a 2d                	push   $0x2d
f0101238:	ff d6                	call   *%esi
				num = -(long long) num;
f010123a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010123d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101240:	f7 d8                	neg    %eax
f0101242:	83 d2 00             	adc    $0x0,%edx
f0101245:	f7 da                	neg    %edx
f0101247:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010124a:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010124f:	eb 55                	jmp    f01012a6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101251:	8d 45 14             	lea    0x14(%ebp),%eax
f0101254:	e8 83 fc ff ff       	call   f0100edc <getuint>
			base = 10;
f0101259:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010125e:	eb 46                	jmp    f01012a6 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0101260:	8d 45 14             	lea    0x14(%ebp),%eax
f0101263:	e8 74 fc ff ff       	call   f0100edc <getuint>
			base = 8;
f0101268:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f010126d:	eb 37                	jmp    f01012a6 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f010126f:	83 ec 08             	sub    $0x8,%esp
f0101272:	53                   	push   %ebx
f0101273:	6a 30                	push   $0x30
f0101275:	ff d6                	call   *%esi
			putch('x', putdat);
f0101277:	83 c4 08             	add    $0x8,%esp
f010127a:	53                   	push   %ebx
f010127b:	6a 78                	push   $0x78
f010127d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010127f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101282:	8d 50 04             	lea    0x4(%eax),%edx
f0101285:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101288:	8b 00                	mov    (%eax),%eax
f010128a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010128f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101292:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0101297:	eb 0d                	jmp    f01012a6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101299:	8d 45 14             	lea    0x14(%ebp),%eax
f010129c:	e8 3b fc ff ff       	call   f0100edc <getuint>
			base = 16;
f01012a1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01012a6:	83 ec 0c             	sub    $0xc,%esp
f01012a9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01012ad:	57                   	push   %edi
f01012ae:	ff 75 e0             	pushl  -0x20(%ebp)
f01012b1:	51                   	push   %ecx
f01012b2:	52                   	push   %edx
f01012b3:	50                   	push   %eax
f01012b4:	89 da                	mov    %ebx,%edx
f01012b6:	89 f0                	mov    %esi,%eax
f01012b8:	e8 70 fb ff ff       	call   f0100e2d <printnum>
			break;
f01012bd:	83 c4 20             	add    $0x20,%esp
f01012c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01012c3:	e9 ae fc ff ff       	jmp    f0100f76 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01012c8:	83 ec 08             	sub    $0x8,%esp
f01012cb:	53                   	push   %ebx
f01012cc:	51                   	push   %ecx
f01012cd:	ff d6                	call   *%esi
			break;
f01012cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01012d5:	e9 9c fc ff ff       	jmp    f0100f76 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01012da:	83 ec 08             	sub    $0x8,%esp
f01012dd:	53                   	push   %ebx
f01012de:	6a 25                	push   $0x25
f01012e0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01012e2:	83 c4 10             	add    $0x10,%esp
f01012e5:	eb 03                	jmp    f01012ea <vprintfmt+0x39a>
f01012e7:	83 ef 01             	sub    $0x1,%edi
f01012ea:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01012ee:	75 f7                	jne    f01012e7 <vprintfmt+0x397>
f01012f0:	e9 81 fc ff ff       	jmp    f0100f76 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01012f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012f8:	5b                   	pop    %ebx
f01012f9:	5e                   	pop    %esi
f01012fa:	5f                   	pop    %edi
f01012fb:	5d                   	pop    %ebp
f01012fc:	c3                   	ret    

f01012fd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01012fd:	55                   	push   %ebp
f01012fe:	89 e5                	mov    %esp,%ebp
f0101300:	83 ec 18             	sub    $0x18,%esp
f0101303:	8b 45 08             	mov    0x8(%ebp),%eax
f0101306:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101309:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010130c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101310:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101313:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010131a:	85 c0                	test   %eax,%eax
f010131c:	74 26                	je     f0101344 <vsnprintf+0x47>
f010131e:	85 d2                	test   %edx,%edx
f0101320:	7e 22                	jle    f0101344 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101322:	ff 75 14             	pushl  0x14(%ebp)
f0101325:	ff 75 10             	pushl  0x10(%ebp)
f0101328:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010132b:	50                   	push   %eax
f010132c:	68 16 0f 10 f0       	push   $0xf0100f16
f0101331:	e8 1a fc ff ff       	call   f0100f50 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101336:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101339:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010133c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010133f:	83 c4 10             	add    $0x10,%esp
f0101342:	eb 05                	jmp    f0101349 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101344:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101349:	c9                   	leave  
f010134a:	c3                   	ret    

f010134b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010134b:	55                   	push   %ebp
f010134c:	89 e5                	mov    %esp,%ebp
f010134e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101351:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101354:	50                   	push   %eax
f0101355:	ff 75 10             	pushl  0x10(%ebp)
f0101358:	ff 75 0c             	pushl  0xc(%ebp)
f010135b:	ff 75 08             	pushl  0x8(%ebp)
f010135e:	e8 9a ff ff ff       	call   f01012fd <vsnprintf>
	va_end(ap);

	return rc;
}
f0101363:	c9                   	leave  
f0101364:	c3                   	ret    

f0101365 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101365:	55                   	push   %ebp
f0101366:	89 e5                	mov    %esp,%ebp
f0101368:	57                   	push   %edi
f0101369:	56                   	push   %esi
f010136a:	53                   	push   %ebx
f010136b:	83 ec 0c             	sub    $0xc,%esp
f010136e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101371:	85 c0                	test   %eax,%eax
f0101373:	74 11                	je     f0101386 <readline+0x21>
		cprintf("%s", prompt);
f0101375:	83 ec 08             	sub    $0x8,%esp
f0101378:	50                   	push   %eax
f0101379:	68 5e 20 10 f0       	push   $0xf010205e
f010137e:	e8 75 f7 ff ff       	call   f0100af8 <cprintf>
f0101383:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101386:	83 ec 0c             	sub    $0xc,%esp
f0101389:	6a 00                	push   $0x0
f010138b:	e8 91 f2 ff ff       	call   f0100621 <iscons>
f0101390:	89 c7                	mov    %eax,%edi
f0101392:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101395:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010139a:	e8 71 f2 ff ff       	call   f0100610 <getchar>
f010139f:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01013a1:	85 c0                	test   %eax,%eax
f01013a3:	79 18                	jns    f01013bd <readline+0x58>
			cprintf("read error: %e\n", c);
f01013a5:	83 ec 08             	sub    $0x8,%esp
f01013a8:	50                   	push   %eax
f01013a9:	68 40 22 10 f0       	push   $0xf0102240
f01013ae:	e8 45 f7 ff ff       	call   f0100af8 <cprintf>
			return NULL;
f01013b3:	83 c4 10             	add    $0x10,%esp
f01013b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01013bb:	eb 79                	jmp    f0101436 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01013bd:	83 f8 08             	cmp    $0x8,%eax
f01013c0:	0f 94 c2             	sete   %dl
f01013c3:	83 f8 7f             	cmp    $0x7f,%eax
f01013c6:	0f 94 c0             	sete   %al
f01013c9:	08 c2                	or     %al,%dl
f01013cb:	74 1a                	je     f01013e7 <readline+0x82>
f01013cd:	85 f6                	test   %esi,%esi
f01013cf:	7e 16                	jle    f01013e7 <readline+0x82>
			if (echoing)
f01013d1:	85 ff                	test   %edi,%edi
f01013d3:	74 0d                	je     f01013e2 <readline+0x7d>
				cputchar('\b');
f01013d5:	83 ec 0c             	sub    $0xc,%esp
f01013d8:	6a 08                	push   $0x8
f01013da:	e8 21 f2 ff ff       	call   f0100600 <cputchar>
f01013df:	83 c4 10             	add    $0x10,%esp
			i--;
f01013e2:	83 ee 01             	sub    $0x1,%esi
f01013e5:	eb b3                	jmp    f010139a <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01013e7:	83 fb 1f             	cmp    $0x1f,%ebx
f01013ea:	7e 23                	jle    f010140f <readline+0xaa>
f01013ec:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01013f2:	7f 1b                	jg     f010140f <readline+0xaa>
			if (echoing)
f01013f4:	85 ff                	test   %edi,%edi
f01013f6:	74 0c                	je     f0101404 <readline+0x9f>
				cputchar(c);
f01013f8:	83 ec 0c             	sub    $0xc,%esp
f01013fb:	53                   	push   %ebx
f01013fc:	e8 ff f1 ff ff       	call   f0100600 <cputchar>
f0101401:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101404:	88 9e 40 35 11 f0    	mov    %bl,-0xfeecac0(%esi)
f010140a:	8d 76 01             	lea    0x1(%esi),%esi
f010140d:	eb 8b                	jmp    f010139a <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010140f:	83 fb 0a             	cmp    $0xa,%ebx
f0101412:	74 05                	je     f0101419 <readline+0xb4>
f0101414:	83 fb 0d             	cmp    $0xd,%ebx
f0101417:	75 81                	jne    f010139a <readline+0x35>
			if (echoing)
f0101419:	85 ff                	test   %edi,%edi
f010141b:	74 0d                	je     f010142a <readline+0xc5>
				cputchar('\n');
f010141d:	83 ec 0c             	sub    $0xc,%esp
f0101420:	6a 0a                	push   $0xa
f0101422:	e8 d9 f1 ff ff       	call   f0100600 <cputchar>
f0101427:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010142a:	c6 86 40 35 11 f0 00 	movb   $0x0,-0xfeecac0(%esi)
			return buf;
f0101431:	b8 40 35 11 f0       	mov    $0xf0113540,%eax
		}
	}
}
f0101436:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101439:	5b                   	pop    %ebx
f010143a:	5e                   	pop    %esi
f010143b:	5f                   	pop    %edi
f010143c:	5d                   	pop    %ebp
f010143d:	c3                   	ret    

f010143e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010143e:	55                   	push   %ebp
f010143f:	89 e5                	mov    %esp,%ebp
f0101441:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101444:	b8 00 00 00 00       	mov    $0x0,%eax
f0101449:	eb 03                	jmp    f010144e <strlen+0x10>
		n++;
f010144b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010144e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101452:	75 f7                	jne    f010144b <strlen+0xd>
		n++;
	return n;
}
f0101454:	5d                   	pop    %ebp
f0101455:	c3                   	ret    

f0101456 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101456:	55                   	push   %ebp
f0101457:	89 e5                	mov    %esp,%ebp
f0101459:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010145c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010145f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101464:	eb 03                	jmp    f0101469 <strnlen+0x13>
		n++;
f0101466:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101469:	39 c2                	cmp    %eax,%edx
f010146b:	74 08                	je     f0101475 <strnlen+0x1f>
f010146d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101471:	75 f3                	jne    f0101466 <strnlen+0x10>
f0101473:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0101475:	5d                   	pop    %ebp
f0101476:	c3                   	ret    

f0101477 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101477:	55                   	push   %ebp
f0101478:	89 e5                	mov    %esp,%ebp
f010147a:	53                   	push   %ebx
f010147b:	8b 45 08             	mov    0x8(%ebp),%eax
f010147e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101481:	89 c2                	mov    %eax,%edx
f0101483:	83 c2 01             	add    $0x1,%edx
f0101486:	83 c1 01             	add    $0x1,%ecx
f0101489:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010148d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101490:	84 db                	test   %bl,%bl
f0101492:	75 ef                	jne    f0101483 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101494:	5b                   	pop    %ebx
f0101495:	5d                   	pop    %ebp
f0101496:	c3                   	ret    

f0101497 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101497:	55                   	push   %ebp
f0101498:	89 e5                	mov    %esp,%ebp
f010149a:	53                   	push   %ebx
f010149b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010149e:	53                   	push   %ebx
f010149f:	e8 9a ff ff ff       	call   f010143e <strlen>
f01014a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01014a7:	ff 75 0c             	pushl  0xc(%ebp)
f01014aa:	01 d8                	add    %ebx,%eax
f01014ac:	50                   	push   %eax
f01014ad:	e8 c5 ff ff ff       	call   f0101477 <strcpy>
	return dst;
}
f01014b2:	89 d8                	mov    %ebx,%eax
f01014b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014b7:	c9                   	leave  
f01014b8:	c3                   	ret    

f01014b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01014b9:	55                   	push   %ebp
f01014ba:	89 e5                	mov    %esp,%ebp
f01014bc:	56                   	push   %esi
f01014bd:	53                   	push   %ebx
f01014be:	8b 75 08             	mov    0x8(%ebp),%esi
f01014c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01014c4:	89 f3                	mov    %esi,%ebx
f01014c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01014c9:	89 f2                	mov    %esi,%edx
f01014cb:	eb 0f                	jmp    f01014dc <strncpy+0x23>
		*dst++ = *src;
f01014cd:	83 c2 01             	add    $0x1,%edx
f01014d0:	0f b6 01             	movzbl (%ecx),%eax
f01014d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01014d6:	80 39 01             	cmpb   $0x1,(%ecx)
f01014d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01014dc:	39 da                	cmp    %ebx,%edx
f01014de:	75 ed                	jne    f01014cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01014e0:	89 f0                	mov    %esi,%eax
f01014e2:	5b                   	pop    %ebx
f01014e3:	5e                   	pop    %esi
f01014e4:	5d                   	pop    %ebp
f01014e5:	c3                   	ret    

f01014e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01014e6:	55                   	push   %ebp
f01014e7:	89 e5                	mov    %esp,%ebp
f01014e9:	56                   	push   %esi
f01014ea:	53                   	push   %ebx
f01014eb:	8b 75 08             	mov    0x8(%ebp),%esi
f01014ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01014f1:	8b 55 10             	mov    0x10(%ebp),%edx
f01014f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01014f6:	85 d2                	test   %edx,%edx
f01014f8:	74 21                	je     f010151b <strlcpy+0x35>
f01014fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01014fe:	89 f2                	mov    %esi,%edx
f0101500:	eb 09                	jmp    f010150b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101502:	83 c2 01             	add    $0x1,%edx
f0101505:	83 c1 01             	add    $0x1,%ecx
f0101508:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010150b:	39 c2                	cmp    %eax,%edx
f010150d:	74 09                	je     f0101518 <strlcpy+0x32>
f010150f:	0f b6 19             	movzbl (%ecx),%ebx
f0101512:	84 db                	test   %bl,%bl
f0101514:	75 ec                	jne    f0101502 <strlcpy+0x1c>
f0101516:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101518:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010151b:	29 f0                	sub    %esi,%eax
}
f010151d:	5b                   	pop    %ebx
f010151e:	5e                   	pop    %esi
f010151f:	5d                   	pop    %ebp
f0101520:	c3                   	ret    

f0101521 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101521:	55                   	push   %ebp
f0101522:	89 e5                	mov    %esp,%ebp
f0101524:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101527:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010152a:	eb 06                	jmp    f0101532 <strcmp+0x11>
		p++, q++;
f010152c:	83 c1 01             	add    $0x1,%ecx
f010152f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101532:	0f b6 01             	movzbl (%ecx),%eax
f0101535:	84 c0                	test   %al,%al
f0101537:	74 04                	je     f010153d <strcmp+0x1c>
f0101539:	3a 02                	cmp    (%edx),%al
f010153b:	74 ef                	je     f010152c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010153d:	0f b6 c0             	movzbl %al,%eax
f0101540:	0f b6 12             	movzbl (%edx),%edx
f0101543:	29 d0                	sub    %edx,%eax
}
f0101545:	5d                   	pop    %ebp
f0101546:	c3                   	ret    

f0101547 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101547:	55                   	push   %ebp
f0101548:	89 e5                	mov    %esp,%ebp
f010154a:	53                   	push   %ebx
f010154b:	8b 45 08             	mov    0x8(%ebp),%eax
f010154e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101551:	89 c3                	mov    %eax,%ebx
f0101553:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101556:	eb 06                	jmp    f010155e <strncmp+0x17>
		n--, p++, q++;
f0101558:	83 c0 01             	add    $0x1,%eax
f010155b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010155e:	39 d8                	cmp    %ebx,%eax
f0101560:	74 15                	je     f0101577 <strncmp+0x30>
f0101562:	0f b6 08             	movzbl (%eax),%ecx
f0101565:	84 c9                	test   %cl,%cl
f0101567:	74 04                	je     f010156d <strncmp+0x26>
f0101569:	3a 0a                	cmp    (%edx),%cl
f010156b:	74 eb                	je     f0101558 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010156d:	0f b6 00             	movzbl (%eax),%eax
f0101570:	0f b6 12             	movzbl (%edx),%edx
f0101573:	29 d0                	sub    %edx,%eax
f0101575:	eb 05                	jmp    f010157c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101577:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010157c:	5b                   	pop    %ebx
f010157d:	5d                   	pop    %ebp
f010157e:	c3                   	ret    

f010157f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010157f:	55                   	push   %ebp
f0101580:	89 e5                	mov    %esp,%ebp
f0101582:	8b 45 08             	mov    0x8(%ebp),%eax
f0101585:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101589:	eb 07                	jmp    f0101592 <strchr+0x13>
		if (*s == c)
f010158b:	38 ca                	cmp    %cl,%dl
f010158d:	74 0f                	je     f010159e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010158f:	83 c0 01             	add    $0x1,%eax
f0101592:	0f b6 10             	movzbl (%eax),%edx
f0101595:	84 d2                	test   %dl,%dl
f0101597:	75 f2                	jne    f010158b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101599:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010159e:	5d                   	pop    %ebp
f010159f:	c3                   	ret    

f01015a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01015a0:	55                   	push   %ebp
f01015a1:	89 e5                	mov    %esp,%ebp
f01015a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01015a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01015aa:	eb 03                	jmp    f01015af <strfind+0xf>
f01015ac:	83 c0 01             	add    $0x1,%eax
f01015af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01015b2:	38 ca                	cmp    %cl,%dl
f01015b4:	74 04                	je     f01015ba <strfind+0x1a>
f01015b6:	84 d2                	test   %dl,%dl
f01015b8:	75 f2                	jne    f01015ac <strfind+0xc>
			break;
	return (char *) s;
}
f01015ba:	5d                   	pop    %ebp
f01015bb:	c3                   	ret    

f01015bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01015bc:	55                   	push   %ebp
f01015bd:	89 e5                	mov    %esp,%ebp
f01015bf:	57                   	push   %edi
f01015c0:	56                   	push   %esi
f01015c1:	53                   	push   %ebx
f01015c2:	8b 7d 08             	mov    0x8(%ebp),%edi
f01015c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01015c8:	85 c9                	test   %ecx,%ecx
f01015ca:	74 36                	je     f0101602 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01015cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01015d2:	75 28                	jne    f01015fc <memset+0x40>
f01015d4:	f6 c1 03             	test   $0x3,%cl
f01015d7:	75 23                	jne    f01015fc <memset+0x40>
		c &= 0xFF;
f01015d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01015dd:	89 d3                	mov    %edx,%ebx
f01015df:	c1 e3 08             	shl    $0x8,%ebx
f01015e2:	89 d6                	mov    %edx,%esi
f01015e4:	c1 e6 18             	shl    $0x18,%esi
f01015e7:	89 d0                	mov    %edx,%eax
f01015e9:	c1 e0 10             	shl    $0x10,%eax
f01015ec:	09 f0                	or     %esi,%eax
f01015ee:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01015f0:	89 d8                	mov    %ebx,%eax
f01015f2:	09 d0                	or     %edx,%eax
f01015f4:	c1 e9 02             	shr    $0x2,%ecx
f01015f7:	fc                   	cld    
f01015f8:	f3 ab                	rep stos %eax,%es:(%edi)
f01015fa:	eb 06                	jmp    f0101602 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01015fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015ff:	fc                   	cld    
f0101600:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101602:	89 f8                	mov    %edi,%eax
f0101604:	5b                   	pop    %ebx
f0101605:	5e                   	pop    %esi
f0101606:	5f                   	pop    %edi
f0101607:	5d                   	pop    %ebp
f0101608:	c3                   	ret    

f0101609 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101609:	55                   	push   %ebp
f010160a:	89 e5                	mov    %esp,%ebp
f010160c:	57                   	push   %edi
f010160d:	56                   	push   %esi
f010160e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101611:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101614:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101617:	39 c6                	cmp    %eax,%esi
f0101619:	73 35                	jae    f0101650 <memmove+0x47>
f010161b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010161e:	39 d0                	cmp    %edx,%eax
f0101620:	73 2e                	jae    f0101650 <memmove+0x47>
		s += n;
		d += n;
f0101622:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101625:	89 d6                	mov    %edx,%esi
f0101627:	09 fe                	or     %edi,%esi
f0101629:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010162f:	75 13                	jne    f0101644 <memmove+0x3b>
f0101631:	f6 c1 03             	test   $0x3,%cl
f0101634:	75 0e                	jne    f0101644 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0101636:	83 ef 04             	sub    $0x4,%edi
f0101639:	8d 72 fc             	lea    -0x4(%edx),%esi
f010163c:	c1 e9 02             	shr    $0x2,%ecx
f010163f:	fd                   	std    
f0101640:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101642:	eb 09                	jmp    f010164d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101644:	83 ef 01             	sub    $0x1,%edi
f0101647:	8d 72 ff             	lea    -0x1(%edx),%esi
f010164a:	fd                   	std    
f010164b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010164d:	fc                   	cld    
f010164e:	eb 1d                	jmp    f010166d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101650:	89 f2                	mov    %esi,%edx
f0101652:	09 c2                	or     %eax,%edx
f0101654:	f6 c2 03             	test   $0x3,%dl
f0101657:	75 0f                	jne    f0101668 <memmove+0x5f>
f0101659:	f6 c1 03             	test   $0x3,%cl
f010165c:	75 0a                	jne    f0101668 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010165e:	c1 e9 02             	shr    $0x2,%ecx
f0101661:	89 c7                	mov    %eax,%edi
f0101663:	fc                   	cld    
f0101664:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101666:	eb 05                	jmp    f010166d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101668:	89 c7                	mov    %eax,%edi
f010166a:	fc                   	cld    
f010166b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010166d:	5e                   	pop    %esi
f010166e:	5f                   	pop    %edi
f010166f:	5d                   	pop    %ebp
f0101670:	c3                   	ret    

f0101671 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101671:	55                   	push   %ebp
f0101672:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101674:	ff 75 10             	pushl  0x10(%ebp)
f0101677:	ff 75 0c             	pushl  0xc(%ebp)
f010167a:	ff 75 08             	pushl  0x8(%ebp)
f010167d:	e8 87 ff ff ff       	call   f0101609 <memmove>
}
f0101682:	c9                   	leave  
f0101683:	c3                   	ret    

f0101684 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101684:	55                   	push   %ebp
f0101685:	89 e5                	mov    %esp,%ebp
f0101687:	56                   	push   %esi
f0101688:	53                   	push   %ebx
f0101689:	8b 45 08             	mov    0x8(%ebp),%eax
f010168c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010168f:	89 c6                	mov    %eax,%esi
f0101691:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101694:	eb 1a                	jmp    f01016b0 <memcmp+0x2c>
		if (*s1 != *s2)
f0101696:	0f b6 08             	movzbl (%eax),%ecx
f0101699:	0f b6 1a             	movzbl (%edx),%ebx
f010169c:	38 d9                	cmp    %bl,%cl
f010169e:	74 0a                	je     f01016aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01016a0:	0f b6 c1             	movzbl %cl,%eax
f01016a3:	0f b6 db             	movzbl %bl,%ebx
f01016a6:	29 d8                	sub    %ebx,%eax
f01016a8:	eb 0f                	jmp    f01016b9 <memcmp+0x35>
		s1++, s2++;
f01016aa:	83 c0 01             	add    $0x1,%eax
f01016ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01016b0:	39 f0                	cmp    %esi,%eax
f01016b2:	75 e2                	jne    f0101696 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01016b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016b9:	5b                   	pop    %ebx
f01016ba:	5e                   	pop    %esi
f01016bb:	5d                   	pop    %ebp
f01016bc:	c3                   	ret    

f01016bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01016bd:	55                   	push   %ebp
f01016be:	89 e5                	mov    %esp,%ebp
f01016c0:	53                   	push   %ebx
f01016c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01016c4:	89 c1                	mov    %eax,%ecx
f01016c6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01016c9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01016cd:	eb 0a                	jmp    f01016d9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01016cf:	0f b6 10             	movzbl (%eax),%edx
f01016d2:	39 da                	cmp    %ebx,%edx
f01016d4:	74 07                	je     f01016dd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01016d6:	83 c0 01             	add    $0x1,%eax
f01016d9:	39 c8                	cmp    %ecx,%eax
f01016db:	72 f2                	jb     f01016cf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01016dd:	5b                   	pop    %ebx
f01016de:	5d                   	pop    %ebp
f01016df:	c3                   	ret    

f01016e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01016e0:	55                   	push   %ebp
f01016e1:	89 e5                	mov    %esp,%ebp
f01016e3:	57                   	push   %edi
f01016e4:	56                   	push   %esi
f01016e5:	53                   	push   %ebx
f01016e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01016ec:	eb 03                	jmp    f01016f1 <strtol+0x11>
		s++;
f01016ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01016f1:	0f b6 01             	movzbl (%ecx),%eax
f01016f4:	3c 20                	cmp    $0x20,%al
f01016f6:	74 f6                	je     f01016ee <strtol+0xe>
f01016f8:	3c 09                	cmp    $0x9,%al
f01016fa:	74 f2                	je     f01016ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01016fc:	3c 2b                	cmp    $0x2b,%al
f01016fe:	75 0a                	jne    f010170a <strtol+0x2a>
		s++;
f0101700:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101703:	bf 00 00 00 00       	mov    $0x0,%edi
f0101708:	eb 11                	jmp    f010171b <strtol+0x3b>
f010170a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010170f:	3c 2d                	cmp    $0x2d,%al
f0101711:	75 08                	jne    f010171b <strtol+0x3b>
		s++, neg = 1;
f0101713:	83 c1 01             	add    $0x1,%ecx
f0101716:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010171b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101721:	75 15                	jne    f0101738 <strtol+0x58>
f0101723:	80 39 30             	cmpb   $0x30,(%ecx)
f0101726:	75 10                	jne    f0101738 <strtol+0x58>
f0101728:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010172c:	75 7c                	jne    f01017aa <strtol+0xca>
		s += 2, base = 16;
f010172e:	83 c1 02             	add    $0x2,%ecx
f0101731:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101736:	eb 16                	jmp    f010174e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0101738:	85 db                	test   %ebx,%ebx
f010173a:	75 12                	jne    f010174e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010173c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101741:	80 39 30             	cmpb   $0x30,(%ecx)
f0101744:	75 08                	jne    f010174e <strtol+0x6e>
		s++, base = 8;
f0101746:	83 c1 01             	add    $0x1,%ecx
f0101749:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010174e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101753:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101756:	0f b6 11             	movzbl (%ecx),%edx
f0101759:	8d 72 d0             	lea    -0x30(%edx),%esi
f010175c:	89 f3                	mov    %esi,%ebx
f010175e:	80 fb 09             	cmp    $0x9,%bl
f0101761:	77 08                	ja     f010176b <strtol+0x8b>
			dig = *s - '0';
f0101763:	0f be d2             	movsbl %dl,%edx
f0101766:	83 ea 30             	sub    $0x30,%edx
f0101769:	eb 22                	jmp    f010178d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010176b:	8d 72 9f             	lea    -0x61(%edx),%esi
f010176e:	89 f3                	mov    %esi,%ebx
f0101770:	80 fb 19             	cmp    $0x19,%bl
f0101773:	77 08                	ja     f010177d <strtol+0x9d>
			dig = *s - 'a' + 10;
f0101775:	0f be d2             	movsbl %dl,%edx
f0101778:	83 ea 57             	sub    $0x57,%edx
f010177b:	eb 10                	jmp    f010178d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010177d:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101780:	89 f3                	mov    %esi,%ebx
f0101782:	80 fb 19             	cmp    $0x19,%bl
f0101785:	77 16                	ja     f010179d <strtol+0xbd>
			dig = *s - 'A' + 10;
f0101787:	0f be d2             	movsbl %dl,%edx
f010178a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010178d:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101790:	7d 0b                	jge    f010179d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0101792:	83 c1 01             	add    $0x1,%ecx
f0101795:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101799:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010179b:	eb b9                	jmp    f0101756 <strtol+0x76>

	if (endptr)
f010179d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01017a1:	74 0d                	je     f01017b0 <strtol+0xd0>
		*endptr = (char *) s;
f01017a3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017a6:	89 0e                	mov    %ecx,(%esi)
f01017a8:	eb 06                	jmp    f01017b0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01017aa:	85 db                	test   %ebx,%ebx
f01017ac:	74 98                	je     f0101746 <strtol+0x66>
f01017ae:	eb 9e                	jmp    f010174e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01017b0:	89 c2                	mov    %eax,%edx
f01017b2:	f7 da                	neg    %edx
f01017b4:	85 ff                	test   %edi,%edi
f01017b6:	0f 45 c2             	cmovne %edx,%eax
}
f01017b9:	5b                   	pop    %ebx
f01017ba:	5e                   	pop    %esi
f01017bb:	5f                   	pop    %edi
f01017bc:	5d                   	pop    %ebp
f01017bd:	c3                   	ret    
f01017be:	66 90                	xchg   %ax,%ax

f01017c0 <__udivdi3>:
f01017c0:	55                   	push   %ebp
f01017c1:	57                   	push   %edi
f01017c2:	56                   	push   %esi
f01017c3:	53                   	push   %ebx
f01017c4:	83 ec 1c             	sub    $0x1c,%esp
f01017c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01017cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01017cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01017d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01017d7:	85 f6                	test   %esi,%esi
f01017d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01017dd:	89 ca                	mov    %ecx,%edx
f01017df:	89 f8                	mov    %edi,%eax
f01017e1:	75 3d                	jne    f0101820 <__udivdi3+0x60>
f01017e3:	39 cf                	cmp    %ecx,%edi
f01017e5:	0f 87 c5 00 00 00    	ja     f01018b0 <__udivdi3+0xf0>
f01017eb:	85 ff                	test   %edi,%edi
f01017ed:	89 fd                	mov    %edi,%ebp
f01017ef:	75 0b                	jne    f01017fc <__udivdi3+0x3c>
f01017f1:	b8 01 00 00 00       	mov    $0x1,%eax
f01017f6:	31 d2                	xor    %edx,%edx
f01017f8:	f7 f7                	div    %edi
f01017fa:	89 c5                	mov    %eax,%ebp
f01017fc:	89 c8                	mov    %ecx,%eax
f01017fe:	31 d2                	xor    %edx,%edx
f0101800:	f7 f5                	div    %ebp
f0101802:	89 c1                	mov    %eax,%ecx
f0101804:	89 d8                	mov    %ebx,%eax
f0101806:	89 cf                	mov    %ecx,%edi
f0101808:	f7 f5                	div    %ebp
f010180a:	89 c3                	mov    %eax,%ebx
f010180c:	89 d8                	mov    %ebx,%eax
f010180e:	89 fa                	mov    %edi,%edx
f0101810:	83 c4 1c             	add    $0x1c,%esp
f0101813:	5b                   	pop    %ebx
f0101814:	5e                   	pop    %esi
f0101815:	5f                   	pop    %edi
f0101816:	5d                   	pop    %ebp
f0101817:	c3                   	ret    
f0101818:	90                   	nop
f0101819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101820:	39 ce                	cmp    %ecx,%esi
f0101822:	77 74                	ja     f0101898 <__udivdi3+0xd8>
f0101824:	0f bd fe             	bsr    %esi,%edi
f0101827:	83 f7 1f             	xor    $0x1f,%edi
f010182a:	0f 84 98 00 00 00    	je     f01018c8 <__udivdi3+0x108>
f0101830:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101835:	89 f9                	mov    %edi,%ecx
f0101837:	89 c5                	mov    %eax,%ebp
f0101839:	29 fb                	sub    %edi,%ebx
f010183b:	d3 e6                	shl    %cl,%esi
f010183d:	89 d9                	mov    %ebx,%ecx
f010183f:	d3 ed                	shr    %cl,%ebp
f0101841:	89 f9                	mov    %edi,%ecx
f0101843:	d3 e0                	shl    %cl,%eax
f0101845:	09 ee                	or     %ebp,%esi
f0101847:	89 d9                	mov    %ebx,%ecx
f0101849:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010184d:	89 d5                	mov    %edx,%ebp
f010184f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101853:	d3 ed                	shr    %cl,%ebp
f0101855:	89 f9                	mov    %edi,%ecx
f0101857:	d3 e2                	shl    %cl,%edx
f0101859:	89 d9                	mov    %ebx,%ecx
f010185b:	d3 e8                	shr    %cl,%eax
f010185d:	09 c2                	or     %eax,%edx
f010185f:	89 d0                	mov    %edx,%eax
f0101861:	89 ea                	mov    %ebp,%edx
f0101863:	f7 f6                	div    %esi
f0101865:	89 d5                	mov    %edx,%ebp
f0101867:	89 c3                	mov    %eax,%ebx
f0101869:	f7 64 24 0c          	mull   0xc(%esp)
f010186d:	39 d5                	cmp    %edx,%ebp
f010186f:	72 10                	jb     f0101881 <__udivdi3+0xc1>
f0101871:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101875:	89 f9                	mov    %edi,%ecx
f0101877:	d3 e6                	shl    %cl,%esi
f0101879:	39 c6                	cmp    %eax,%esi
f010187b:	73 07                	jae    f0101884 <__udivdi3+0xc4>
f010187d:	39 d5                	cmp    %edx,%ebp
f010187f:	75 03                	jne    f0101884 <__udivdi3+0xc4>
f0101881:	83 eb 01             	sub    $0x1,%ebx
f0101884:	31 ff                	xor    %edi,%edi
f0101886:	89 d8                	mov    %ebx,%eax
f0101888:	89 fa                	mov    %edi,%edx
f010188a:	83 c4 1c             	add    $0x1c,%esp
f010188d:	5b                   	pop    %ebx
f010188e:	5e                   	pop    %esi
f010188f:	5f                   	pop    %edi
f0101890:	5d                   	pop    %ebp
f0101891:	c3                   	ret    
f0101892:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101898:	31 ff                	xor    %edi,%edi
f010189a:	31 db                	xor    %ebx,%ebx
f010189c:	89 d8                	mov    %ebx,%eax
f010189e:	89 fa                	mov    %edi,%edx
f01018a0:	83 c4 1c             	add    $0x1c,%esp
f01018a3:	5b                   	pop    %ebx
f01018a4:	5e                   	pop    %esi
f01018a5:	5f                   	pop    %edi
f01018a6:	5d                   	pop    %ebp
f01018a7:	c3                   	ret    
f01018a8:	90                   	nop
f01018a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018b0:	89 d8                	mov    %ebx,%eax
f01018b2:	f7 f7                	div    %edi
f01018b4:	31 ff                	xor    %edi,%edi
f01018b6:	89 c3                	mov    %eax,%ebx
f01018b8:	89 d8                	mov    %ebx,%eax
f01018ba:	89 fa                	mov    %edi,%edx
f01018bc:	83 c4 1c             	add    $0x1c,%esp
f01018bf:	5b                   	pop    %ebx
f01018c0:	5e                   	pop    %esi
f01018c1:	5f                   	pop    %edi
f01018c2:	5d                   	pop    %ebp
f01018c3:	c3                   	ret    
f01018c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018c8:	39 ce                	cmp    %ecx,%esi
f01018ca:	72 0c                	jb     f01018d8 <__udivdi3+0x118>
f01018cc:	31 db                	xor    %ebx,%ebx
f01018ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01018d2:	0f 87 34 ff ff ff    	ja     f010180c <__udivdi3+0x4c>
f01018d8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01018dd:	e9 2a ff ff ff       	jmp    f010180c <__udivdi3+0x4c>
f01018e2:	66 90                	xchg   %ax,%ax
f01018e4:	66 90                	xchg   %ax,%ax
f01018e6:	66 90                	xchg   %ax,%ax
f01018e8:	66 90                	xchg   %ax,%ax
f01018ea:	66 90                	xchg   %ax,%ax
f01018ec:	66 90                	xchg   %ax,%ax
f01018ee:	66 90                	xchg   %ax,%ax

f01018f0 <__umoddi3>:
f01018f0:	55                   	push   %ebp
f01018f1:	57                   	push   %edi
f01018f2:	56                   	push   %esi
f01018f3:	53                   	push   %ebx
f01018f4:	83 ec 1c             	sub    $0x1c,%esp
f01018f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01018fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01018ff:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101903:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101907:	85 d2                	test   %edx,%edx
f0101909:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010190d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101911:	89 f3                	mov    %esi,%ebx
f0101913:	89 3c 24             	mov    %edi,(%esp)
f0101916:	89 74 24 04          	mov    %esi,0x4(%esp)
f010191a:	75 1c                	jne    f0101938 <__umoddi3+0x48>
f010191c:	39 f7                	cmp    %esi,%edi
f010191e:	76 50                	jbe    f0101970 <__umoddi3+0x80>
f0101920:	89 c8                	mov    %ecx,%eax
f0101922:	89 f2                	mov    %esi,%edx
f0101924:	f7 f7                	div    %edi
f0101926:	89 d0                	mov    %edx,%eax
f0101928:	31 d2                	xor    %edx,%edx
f010192a:	83 c4 1c             	add    $0x1c,%esp
f010192d:	5b                   	pop    %ebx
f010192e:	5e                   	pop    %esi
f010192f:	5f                   	pop    %edi
f0101930:	5d                   	pop    %ebp
f0101931:	c3                   	ret    
f0101932:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101938:	39 f2                	cmp    %esi,%edx
f010193a:	89 d0                	mov    %edx,%eax
f010193c:	77 52                	ja     f0101990 <__umoddi3+0xa0>
f010193e:	0f bd ea             	bsr    %edx,%ebp
f0101941:	83 f5 1f             	xor    $0x1f,%ebp
f0101944:	75 5a                	jne    f01019a0 <__umoddi3+0xb0>
f0101946:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010194a:	0f 82 e0 00 00 00    	jb     f0101a30 <__umoddi3+0x140>
f0101950:	39 0c 24             	cmp    %ecx,(%esp)
f0101953:	0f 86 d7 00 00 00    	jbe    f0101a30 <__umoddi3+0x140>
f0101959:	8b 44 24 08          	mov    0x8(%esp),%eax
f010195d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101961:	83 c4 1c             	add    $0x1c,%esp
f0101964:	5b                   	pop    %ebx
f0101965:	5e                   	pop    %esi
f0101966:	5f                   	pop    %edi
f0101967:	5d                   	pop    %ebp
f0101968:	c3                   	ret    
f0101969:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101970:	85 ff                	test   %edi,%edi
f0101972:	89 fd                	mov    %edi,%ebp
f0101974:	75 0b                	jne    f0101981 <__umoddi3+0x91>
f0101976:	b8 01 00 00 00       	mov    $0x1,%eax
f010197b:	31 d2                	xor    %edx,%edx
f010197d:	f7 f7                	div    %edi
f010197f:	89 c5                	mov    %eax,%ebp
f0101981:	89 f0                	mov    %esi,%eax
f0101983:	31 d2                	xor    %edx,%edx
f0101985:	f7 f5                	div    %ebp
f0101987:	89 c8                	mov    %ecx,%eax
f0101989:	f7 f5                	div    %ebp
f010198b:	89 d0                	mov    %edx,%eax
f010198d:	eb 99                	jmp    f0101928 <__umoddi3+0x38>
f010198f:	90                   	nop
f0101990:	89 c8                	mov    %ecx,%eax
f0101992:	89 f2                	mov    %esi,%edx
f0101994:	83 c4 1c             	add    $0x1c,%esp
f0101997:	5b                   	pop    %ebx
f0101998:	5e                   	pop    %esi
f0101999:	5f                   	pop    %edi
f010199a:	5d                   	pop    %ebp
f010199b:	c3                   	ret    
f010199c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019a0:	8b 34 24             	mov    (%esp),%esi
f01019a3:	bf 20 00 00 00       	mov    $0x20,%edi
f01019a8:	89 e9                	mov    %ebp,%ecx
f01019aa:	29 ef                	sub    %ebp,%edi
f01019ac:	d3 e0                	shl    %cl,%eax
f01019ae:	89 f9                	mov    %edi,%ecx
f01019b0:	89 f2                	mov    %esi,%edx
f01019b2:	d3 ea                	shr    %cl,%edx
f01019b4:	89 e9                	mov    %ebp,%ecx
f01019b6:	09 c2                	or     %eax,%edx
f01019b8:	89 d8                	mov    %ebx,%eax
f01019ba:	89 14 24             	mov    %edx,(%esp)
f01019bd:	89 f2                	mov    %esi,%edx
f01019bf:	d3 e2                	shl    %cl,%edx
f01019c1:	89 f9                	mov    %edi,%ecx
f01019c3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01019c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01019cb:	d3 e8                	shr    %cl,%eax
f01019cd:	89 e9                	mov    %ebp,%ecx
f01019cf:	89 c6                	mov    %eax,%esi
f01019d1:	d3 e3                	shl    %cl,%ebx
f01019d3:	89 f9                	mov    %edi,%ecx
f01019d5:	89 d0                	mov    %edx,%eax
f01019d7:	d3 e8                	shr    %cl,%eax
f01019d9:	89 e9                	mov    %ebp,%ecx
f01019db:	09 d8                	or     %ebx,%eax
f01019dd:	89 d3                	mov    %edx,%ebx
f01019df:	89 f2                	mov    %esi,%edx
f01019e1:	f7 34 24             	divl   (%esp)
f01019e4:	89 d6                	mov    %edx,%esi
f01019e6:	d3 e3                	shl    %cl,%ebx
f01019e8:	f7 64 24 04          	mull   0x4(%esp)
f01019ec:	39 d6                	cmp    %edx,%esi
f01019ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01019f2:	89 d1                	mov    %edx,%ecx
f01019f4:	89 c3                	mov    %eax,%ebx
f01019f6:	72 08                	jb     f0101a00 <__umoddi3+0x110>
f01019f8:	75 11                	jne    f0101a0b <__umoddi3+0x11b>
f01019fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01019fe:	73 0b                	jae    f0101a0b <__umoddi3+0x11b>
f0101a00:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101a04:	1b 14 24             	sbb    (%esp),%edx
f0101a07:	89 d1                	mov    %edx,%ecx
f0101a09:	89 c3                	mov    %eax,%ebx
f0101a0b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0101a0f:	29 da                	sub    %ebx,%edx
f0101a11:	19 ce                	sbb    %ecx,%esi
f0101a13:	89 f9                	mov    %edi,%ecx
f0101a15:	89 f0                	mov    %esi,%eax
f0101a17:	d3 e0                	shl    %cl,%eax
f0101a19:	89 e9                	mov    %ebp,%ecx
f0101a1b:	d3 ea                	shr    %cl,%edx
f0101a1d:	89 e9                	mov    %ebp,%ecx
f0101a1f:	d3 ee                	shr    %cl,%esi
f0101a21:	09 d0                	or     %edx,%eax
f0101a23:	89 f2                	mov    %esi,%edx
f0101a25:	83 c4 1c             	add    $0x1c,%esp
f0101a28:	5b                   	pop    %ebx
f0101a29:	5e                   	pop    %esi
f0101a2a:	5f                   	pop    %edi
f0101a2b:	5d                   	pop    %ebp
f0101a2c:	c3                   	ret    
f0101a2d:	8d 76 00             	lea    0x0(%esi),%esi
f0101a30:	29 f9                	sub    %edi,%ecx
f0101a32:	19 d6                	sbb    %edx,%esi
f0101a34:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101a38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101a3c:	e9 18 ff ff ff       	jmp    f0101959 <__umoddi3+0x69>
