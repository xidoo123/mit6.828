
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
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
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
f0100034:	bc 00 20 11 f0       	mov    $0xf0112000,%esp

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
f0100046:	b8 60 49 11 f0       	mov    $0xf0114960,%eax
f010004b:	2d 00 43 11 f0       	sub    $0xf0114300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 43 11 f0       	push   $0xf0114300
f0100058:	e8 80 20 00 00       	call   f01020dd <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 96 04 00 00       	call   f01004f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 80 25 10 f0       	push   $0xf0102580
f010006f:	e8 a5 15 00 00       	call   f0101619 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 c6 0e 00 00       	call   f0100f3f <mem_init>
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
f0100093:	83 3d 64 49 11 f0 00 	cmpl   $0x0,0xf0114964
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 64 49 11 f0    	mov    %esi,0xf0114964

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
f01000b0:	68 9b 25 10 f0       	push   $0xf010259b
f01000b5:	e8 5f 15 00 00       	call   f0101619 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 2f 15 00 00       	call   f01015f3 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 d7 25 10 f0 	movl   $0xf01025d7,(%esp)
f01000cb:	e8 49 15 00 00       	call   f0101619 <cprintf>
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
f01000f2:	68 b3 25 10 f0       	push   $0xf01025b3
f01000f7:	e8 1d 15 00 00       	call   f0101619 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 eb 14 00 00       	call   f01015f3 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 d7 25 10 f0 	movl   $0xf01025d7,(%esp)
f010010f:	e8 05 15 00 00       	call   f0101619 <cprintf>
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
f010014a:	8b 0d 24 45 11 f0    	mov    0xf0114524,%ecx
f0100150:	8d 51 01             	lea    0x1(%ecx),%edx
f0100153:	89 15 24 45 11 f0    	mov    %edx,0xf0114524
f0100159:	88 81 20 43 11 f0    	mov    %al,-0xfeebce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010015f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100165:	75 0a                	jne    f0100171 <cons_intr+0x36>
			cons.wpos = 0;
f0100167:	c7 05 24 45 11 f0 00 	movl   $0x0,0xf0114524
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
f01001a0:	83 0d 00 43 11 f0 40 	orl    $0x40,0xf0114300
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
f01001b8:	8b 0d 00 43 11 f0    	mov    0xf0114300,%ecx
f01001be:	89 cb                	mov    %ecx,%ebx
f01001c0:	83 e3 40             	and    $0x40,%ebx
f01001c3:	83 e0 7f             	and    $0x7f,%eax
f01001c6:	85 db                	test   %ebx,%ebx
f01001c8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001cb:	0f b6 d2             	movzbl %dl,%edx
f01001ce:	0f b6 82 20 27 10 f0 	movzbl -0xfefd8e0(%edx),%eax
f01001d5:	83 c8 40             	or     $0x40,%eax
f01001d8:	0f b6 c0             	movzbl %al,%eax
f01001db:	f7 d0                	not    %eax
f01001dd:	21 c8                	and    %ecx,%eax
f01001df:	a3 00 43 11 f0       	mov    %eax,0xf0114300
		return 0;
f01001e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01001e9:	e9 a4 00 00 00       	jmp    f0100292 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f01001ee:	8b 0d 00 43 11 f0    	mov    0xf0114300,%ecx
f01001f4:	f6 c1 40             	test   $0x40,%cl
f01001f7:	74 0e                	je     f0100207 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001f9:	83 c8 80             	or     $0xffffff80,%eax
f01001fc:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001fe:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100201:	89 0d 00 43 11 f0    	mov    %ecx,0xf0114300
	}

	shift |= shiftcode[data];
f0100207:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010020a:	0f b6 82 20 27 10 f0 	movzbl -0xfefd8e0(%edx),%eax
f0100211:	0b 05 00 43 11 f0    	or     0xf0114300,%eax
f0100217:	0f b6 8a 20 26 10 f0 	movzbl -0xfefd9e0(%edx),%ecx
f010021e:	31 c8                	xor    %ecx,%eax
f0100220:	a3 00 43 11 f0       	mov    %eax,0xf0114300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100225:	89 c1                	mov    %eax,%ecx
f0100227:	83 e1 03             	and    $0x3,%ecx
f010022a:	8b 0c 8d 00 26 10 f0 	mov    -0xfefda00(,%ecx,4),%ecx
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
f0100268:	68 cd 25 10 f0       	push   $0xf01025cd
f010026d:	e8 a7 13 00 00       	call   f0101619 <cprintf>
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
f0100354:	0f b7 05 28 45 11 f0 	movzwl 0xf0114528,%eax
f010035b:	66 85 c0             	test   %ax,%ax
f010035e:	0f 84 e6 00 00 00    	je     f010044a <cons_putc+0x1b3>
			crt_pos--;
f0100364:	83 e8 01             	sub    $0x1,%eax
f0100367:	66 a3 28 45 11 f0    	mov    %ax,0xf0114528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010036d:	0f b7 c0             	movzwl %ax,%eax
f0100370:	66 81 e7 00 ff       	and    $0xff00,%di
f0100375:	83 cf 20             	or     $0x20,%edi
f0100378:	8b 15 2c 45 11 f0    	mov    0xf011452c,%edx
f010037e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100382:	eb 78                	jmp    f01003fc <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100384:	66 83 05 28 45 11 f0 	addw   $0x50,0xf0114528
f010038b:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010038c:	0f b7 05 28 45 11 f0 	movzwl 0xf0114528,%eax
f0100393:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100399:	c1 e8 16             	shr    $0x16,%eax
f010039c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010039f:	c1 e0 04             	shl    $0x4,%eax
f01003a2:	66 a3 28 45 11 f0    	mov    %ax,0xf0114528
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
f01003de:	0f b7 05 28 45 11 f0 	movzwl 0xf0114528,%eax
f01003e5:	8d 50 01             	lea    0x1(%eax),%edx
f01003e8:	66 89 15 28 45 11 f0 	mov    %dx,0xf0114528
f01003ef:	0f b7 c0             	movzwl %ax,%eax
f01003f2:	8b 15 2c 45 11 f0    	mov    0xf011452c,%edx
f01003f8:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003fc:	66 81 3d 28 45 11 f0 	cmpw   $0x7cf,0xf0114528
f0100403:	cf 07 
f0100405:	76 43                	jbe    f010044a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100407:	a1 2c 45 11 f0       	mov    0xf011452c,%eax
f010040c:	83 ec 04             	sub    $0x4,%esp
f010040f:	68 00 0f 00 00       	push   $0xf00
f0100414:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010041a:	52                   	push   %edx
f010041b:	50                   	push   %eax
f010041c:	e8 09 1d 00 00       	call   f010212a <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100421:	8b 15 2c 45 11 f0    	mov    0xf011452c,%edx
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
f0100442:	66 83 2d 28 45 11 f0 	subw   $0x50,0xf0114528
f0100449:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010044a:	8b 0d 30 45 11 f0    	mov    0xf0114530,%ecx
f0100450:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100455:	89 ca                	mov    %ecx,%edx
f0100457:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100458:	0f b7 1d 28 45 11 f0 	movzwl 0xf0114528,%ebx
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
f0100480:	80 3d 34 45 11 f0 00 	cmpb   $0x0,0xf0114534
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
f01004be:	a1 20 45 11 f0       	mov    0xf0114520,%eax
f01004c3:	3b 05 24 45 11 f0    	cmp    0xf0114524,%eax
f01004c9:	74 26                	je     f01004f1 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004cb:	8d 50 01             	lea    0x1(%eax),%edx
f01004ce:	89 15 20 45 11 f0    	mov    %edx,0xf0114520
f01004d4:	0f b6 88 20 43 11 f0 	movzbl -0xfeebce0(%eax),%ecx
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
f01004e5:	c7 05 20 45 11 f0 00 	movl   $0x0,0xf0114520
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
f010051e:	c7 05 30 45 11 f0 b4 	movl   $0x3b4,0xf0114530
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
f0100536:	c7 05 30 45 11 f0 d4 	movl   $0x3d4,0xf0114530
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
f0100545:	8b 3d 30 45 11 f0    	mov    0xf0114530,%edi
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
f010056a:	89 35 2c 45 11 f0    	mov    %esi,0xf011452c
	crt_pos = pos;
f0100570:	0f b6 c0             	movzbl %al,%eax
f0100573:	09 c8                	or     %ecx,%eax
f0100575:	66 a3 28 45 11 f0    	mov    %ax,0xf0114528
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
f01005d6:	0f 95 05 34 45 11 f0 	setne  0xf0114534
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
f01005eb:	68 d9 25 10 f0       	push   $0xf01025d9
f01005f0:	e8 24 10 00 00       	call   f0101619 <cprintf>
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
f0100631:	68 20 28 10 f0       	push   $0xf0102820
f0100636:	68 3e 28 10 f0       	push   $0xf010283e
f010063b:	68 43 28 10 f0       	push   $0xf0102843
f0100640:	e8 d4 0f 00 00       	call   f0101619 <cprintf>
f0100645:	83 c4 0c             	add    $0xc,%esp
f0100648:	68 fc 28 10 f0       	push   $0xf01028fc
f010064d:	68 4c 28 10 f0       	push   $0xf010284c
f0100652:	68 43 28 10 f0       	push   $0xf0102843
f0100657:	e8 bd 0f 00 00       	call   f0101619 <cprintf>
f010065c:	83 c4 0c             	add    $0xc,%esp
f010065f:	68 55 28 10 f0       	push   $0xf0102855
f0100664:	68 73 28 10 f0       	push   $0xf0102873
f0100669:	68 43 28 10 f0       	push   $0xf0102843
f010066e:	e8 a6 0f 00 00       	call   f0101619 <cprintf>
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
f0100680:	68 7d 28 10 f0       	push   $0xf010287d
f0100685:	e8 8f 0f 00 00       	call   f0101619 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010068a:	83 c4 08             	add    $0x8,%esp
f010068d:	68 0c 00 10 00       	push   $0x10000c
f0100692:	68 24 29 10 f0       	push   $0xf0102924
f0100697:	e8 7d 0f 00 00       	call   f0101619 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010069c:	83 c4 0c             	add    $0xc,%esp
f010069f:	68 0c 00 10 00       	push   $0x10000c
f01006a4:	68 0c 00 10 f0       	push   $0xf010000c
f01006a9:	68 4c 29 10 f0       	push   $0xf010294c
f01006ae:	e8 66 0f 00 00       	call   f0101619 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b3:	83 c4 0c             	add    $0xc,%esp
f01006b6:	68 61 25 10 00       	push   $0x102561
f01006bb:	68 61 25 10 f0       	push   $0xf0102561
f01006c0:	68 70 29 10 f0       	push   $0xf0102970
f01006c5:	e8 4f 0f 00 00       	call   f0101619 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ca:	83 c4 0c             	add    $0xc,%esp
f01006cd:	68 00 43 11 00       	push   $0x114300
f01006d2:	68 00 43 11 f0       	push   $0xf0114300
f01006d7:	68 94 29 10 f0       	push   $0xf0102994
f01006dc:	e8 38 0f 00 00       	call   f0101619 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e1:	83 c4 0c             	add    $0xc,%esp
f01006e4:	68 60 49 11 00       	push   $0x114960
f01006e9:	68 60 49 11 f0       	push   $0xf0114960
f01006ee:	68 b8 29 10 f0       	push   $0xf01029b8
f01006f3:	e8 21 0f 00 00       	call   f0101619 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006f8:	b8 5f 4d 11 f0       	mov    $0xf0114d5f,%eax
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
f0100719:	68 dc 29 10 f0       	push   $0xf01029dc
f010071e:	e8 f6 0e 00 00       	call   f0101619 <cprintf>
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
f0100758:	68 96 28 10 f0       	push   $0xf0102896
f010075d:	e8 b7 0e 00 00       	call   f0101619 <cprintf>

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
f010078a:	e8 94 0f 00 00       	call   f0101723 <debuginfo_eip>

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
f01007e6:	68 08 2a 10 f0       	push   $0xf0102a08
f01007eb:	e8 29 0e 00 00       	call   f0101619 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f01007f0:	83 c4 14             	add    $0x14,%esp
f01007f3:	2b 75 cc             	sub    -0x34(%ebp),%esi
f01007f6:	56                   	push   %esi
f01007f7:	8d 45 8a             	lea    -0x76(%ebp),%eax
f01007fa:	50                   	push   %eax
f01007fb:	ff 75 c0             	pushl  -0x40(%ebp)
f01007fe:	ff 75 bc             	pushl  -0x44(%ebp)
f0100801:	68 a8 28 10 f0       	push   $0xf01028a8
f0100806:	e8 0e 0e 00 00       	call   f0101619 <cprintf>

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
f010082e:	68 40 2a 10 f0       	push   $0xf0102a40
f0100833:	e8 e1 0d 00 00       	call   f0101619 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100838:	c7 04 24 64 2a 10 f0 	movl   $0xf0102a64,(%esp)
f010083f:	e8 d5 0d 00 00       	call   f0101619 <cprintf>
f0100844:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100847:	83 ec 0c             	sub    $0xc,%esp
f010084a:	68 bf 28 10 f0       	push   $0xf01028bf
f010084f:	e8 32 16 00 00       	call   f0101e86 <readline>
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
f0100883:	68 c3 28 10 f0       	push   $0xf01028c3
f0100888:	e8 13 18 00 00       	call   f01020a0 <strchr>
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
f01008a3:	68 c8 28 10 f0       	push   $0xf01028c8
f01008a8:	e8 6c 0d 00 00       	call   f0101619 <cprintf>
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
f01008cc:	68 c3 28 10 f0       	push   $0xf01028c3
f01008d1:	e8 ca 17 00 00       	call   f01020a0 <strchr>
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
f01008fa:	ff 34 85 a0 2a 10 f0 	pushl  -0xfefd560(,%eax,4)
f0100901:	ff 75 a8             	pushl  -0x58(%ebp)
f0100904:	e8 39 17 00 00       	call   f0102042 <strcmp>
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
f010091e:	ff 14 85 a8 2a 10 f0 	call   *-0xfefd558(,%eax,4)


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
f010093f:	68 e5 28 10 f0       	push   $0xf01028e5
f0100944:	e8 d0 0c 00 00       	call   f0101619 <cprintf>
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
f0100964:	e8 49 0c 00 00       	call   f01015b2 <mc146818_read>
f0100969:	89 c6                	mov    %eax,%esi
f010096b:	83 c3 01             	add    $0x1,%ebx
f010096e:	89 1c 24             	mov    %ebx,(%esp)
f0100971:	e8 3c 0c 00 00       	call   f01015b2 <mc146818_read>
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
f0100982:	83 3d 38 45 11 f0 00 	cmpl   $0x0,0xf0114538
f0100989:	75 11                	jne    f010099c <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010098b:	ba 5f 59 11 f0       	mov    $0xf011595f,%edx
f0100990:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100996:	89 15 38 45 11 f0    	mov    %edx,0xf0114538
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ((uint32_t)nextfree > 0xffffffff - n)
f010099c:	8b 15 38 45 11 f0    	mov    0xf0114538,%edx
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
f01009b0:	68 c4 2a 10 f0       	push   $0xf0102ac4
f01009b5:	6a 6b                	push   $0x6b
f01009b7:	68 df 2a 10 f0       	push   $0xf0102adf
f01009bc:	e8 ca f6 ff ff       	call   f010008b <_panic>

	result = nextfree;
	nextfree = ROUNDUP(result + n , PGSIZE);
f01009c1:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f01009c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009cd:	a3 38 45 11 f0       	mov    %eax,0xf0114538

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
f01009eb:	3b 0d 68 49 11 f0    	cmp    0xf0114968,%ecx
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
f01009fa:	68 b0 2c 10 f0       	push   $0xf0102cb0
f01009ff:	68 da 02 00 00       	push   $0x2da
f0100a04:	68 df 2a 10 f0       	push   $0xf0102adf
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
f0100a52:	68 d4 2c 10 f0       	push   $0xf0102cd4
f0100a57:	68 19 02 00 00       	push   $0x219
f0100a5c:	68 df 2a 10 f0       	push   $0xf0102adf
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
f0100a74:	2b 15 70 49 11 f0    	sub    0xf0114970,%edx
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
f0100aaa:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
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
f0100ab4:	8b 1d 3c 45 11 f0    	mov    0xf011453c,%ebx
f0100aba:	eb 53                	jmp    f0100b0f <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100abc:	89 d8                	mov    %ebx,%eax
f0100abe:	2b 05 70 49 11 f0    	sub    0xf0114970,%eax
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
f0100ad8:	3b 15 68 49 11 f0    	cmp    0xf0114968,%edx
f0100ade:	72 12                	jb     f0100af2 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ae0:	50                   	push   %eax
f0100ae1:	68 b0 2c 10 f0       	push   $0xf0102cb0
f0100ae6:	6a 52                	push   $0x52
f0100ae8:	68 eb 2a 10 f0       	push   $0xf0102aeb
f0100aed:	e8 99 f5 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100af2:	83 ec 04             	sub    $0x4,%esp
f0100af5:	68 80 00 00 00       	push   $0x80
f0100afa:	68 97 00 00 00       	push   $0x97
f0100aff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b04:	50                   	push   %eax
f0100b05:	e8 d3 15 00 00       	call   f01020dd <memset>
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
f0100b20:	8b 15 3c 45 11 f0    	mov    0xf011453c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b26:	8b 0d 70 49 11 f0    	mov    0xf0114970,%ecx
		assert(pp < pages + npages);
f0100b2c:	a1 68 49 11 f0       	mov    0xf0114968,%eax
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
f0100b4b:	68 f9 2a 10 f0       	push   $0xf0102af9
f0100b50:	68 05 2b 10 f0       	push   $0xf0102b05
f0100b55:	68 33 02 00 00       	push   $0x233
f0100b5a:	68 df 2a 10 f0       	push   $0xf0102adf
f0100b5f:	e8 27 f5 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100b64:	39 fa                	cmp    %edi,%edx
f0100b66:	72 19                	jb     f0100b81 <check_page_free_list+0x148>
f0100b68:	68 1a 2b 10 f0       	push   $0xf0102b1a
f0100b6d:	68 05 2b 10 f0       	push   $0xf0102b05
f0100b72:	68 34 02 00 00       	push   $0x234
f0100b77:	68 df 2a 10 f0       	push   $0xf0102adf
f0100b7c:	e8 0a f5 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b81:	89 d0                	mov    %edx,%eax
f0100b83:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b86:	a8 07                	test   $0x7,%al
f0100b88:	74 19                	je     f0100ba3 <check_page_free_list+0x16a>
f0100b8a:	68 f8 2c 10 f0       	push   $0xf0102cf8
f0100b8f:	68 05 2b 10 f0       	push   $0xf0102b05
f0100b94:	68 35 02 00 00       	push   $0x235
f0100b99:	68 df 2a 10 f0       	push   $0xf0102adf
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
f0100bad:	68 2e 2b 10 f0       	push   $0xf0102b2e
f0100bb2:	68 05 2b 10 f0       	push   $0xf0102b05
f0100bb7:	68 38 02 00 00       	push   $0x238
f0100bbc:	68 df 2a 10 f0       	push   $0xf0102adf
f0100bc1:	e8 c5 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bc6:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bcb:	75 19                	jne    f0100be6 <check_page_free_list+0x1ad>
f0100bcd:	68 3f 2b 10 f0       	push   $0xf0102b3f
f0100bd2:	68 05 2b 10 f0       	push   $0xf0102b05
f0100bd7:	68 39 02 00 00       	push   $0x239
f0100bdc:	68 df 2a 10 f0       	push   $0xf0102adf
f0100be1:	e8 a5 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100be6:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100beb:	75 19                	jne    f0100c06 <check_page_free_list+0x1cd>
f0100bed:	68 2c 2d 10 f0       	push   $0xf0102d2c
f0100bf2:	68 05 2b 10 f0       	push   $0xf0102b05
f0100bf7:	68 3a 02 00 00       	push   $0x23a
f0100bfc:	68 df 2a 10 f0       	push   $0xf0102adf
f0100c01:	e8 85 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c06:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c0b:	75 19                	jne    f0100c26 <check_page_free_list+0x1ed>
f0100c0d:	68 58 2b 10 f0       	push   $0xf0102b58
f0100c12:	68 05 2b 10 f0       	push   $0xf0102b05
f0100c17:	68 3b 02 00 00       	push   $0x23b
f0100c1c:	68 df 2a 10 f0       	push   $0xf0102adf
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
f0100c38:	68 b0 2c 10 f0       	push   $0xf0102cb0
f0100c3d:	6a 52                	push   $0x52
f0100c3f:	68 eb 2a 10 f0       	push   $0xf0102aeb
f0100c44:	e8 42 f4 ff ff       	call   f010008b <_panic>
f0100c49:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c4e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c51:	76 1e                	jbe    f0100c71 <check_page_free_list+0x238>
f0100c53:	68 50 2d 10 f0       	push   $0xf0102d50
f0100c58:	68 05 2b 10 f0       	push   $0xf0102b05
f0100c5d:	68 3c 02 00 00       	push   $0x23c
f0100c62:	68 df 2a 10 f0       	push   $0xf0102adf
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
f0100c86:	68 72 2b 10 f0       	push   $0xf0102b72
f0100c8b:	68 05 2b 10 f0       	push   $0xf0102b05
f0100c90:	68 44 02 00 00       	push   $0x244
f0100c95:	68 df 2a 10 f0       	push   $0xf0102adf
f0100c9a:	e8 ec f3 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100c9f:	85 db                	test   %ebx,%ebx
f0100ca1:	7f 19                	jg     f0100cbc <check_page_free_list+0x283>
f0100ca3:	68 84 2b 10 f0       	push   $0xf0102b84
f0100ca8:	68 05 2b 10 f0       	push   $0xf0102b05
f0100cad:	68 45 02 00 00       	push   $0x245
f0100cb2:	68 df 2a 10 f0       	push   $0xf0102adf
f0100cb7:	e8 cf f3 ff ff       	call   f010008b <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100cbc:	83 ec 0c             	sub    $0xc,%esp
f0100cbf:	68 98 2d 10 f0       	push   $0xf0102d98
f0100cc4:	e8 50 09 00 00       	call   f0101619 <cprintf>
}
f0100cc9:	eb 29                	jmp    f0100cf4 <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100ccb:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f0100cd0:	85 c0                	test   %eax,%eax
f0100cd2:	0f 85 8e fd ff ff    	jne    f0100a66 <check_page_free_list+0x2d>
f0100cd8:	e9 72 fd ff ff       	jmp    f0100a4f <check_page_free_list+0x16>
f0100cdd:	83 3d 3c 45 11 f0 00 	cmpl   $0x0,0xf011453c
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
f0100d01:	a1 70 49 11 f0       	mov    0xf0114970,%eax
f0100d06:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = 0;
f0100d0c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// 2)	[1-npages_basemem) free
	for (i = 1; i < npages_basemem; i++) {
f0100d12:	8b 35 40 45 11 f0    	mov    0xf0114540,%esi
f0100d18:	8b 0d 3c 45 11 f0    	mov    0xf011453c,%ecx
f0100d1e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d23:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100d28:	eb 27                	jmp    f0100d51 <page_init+0x55>
		pages[i].pp_ref = 0;
f0100d2a:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100d31:	89 c2                	mov    %eax,%edx
f0100d33:	03 15 70 49 11 f0    	add    0xf0114970,%edx
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
f0100d44:	03 05 70 49 11 f0    	add    0xf0114970,%eax
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
f0100d59:	89 0d 3c 45 11 f0    	mov    %ecx,0xf011453c
f0100d5f:	8b 0d 3c 45 11 f0    	mov    0xf011453c,%ecx
f0100d65:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100d6c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d71:	eb 23                	jmp    f0100d96 <page_init+0x9a>
	}

	// [npages_basemem, IOPHYSMEM / PGSIZE) free
	// cprintf("[?] %d, %d, %d\n", npages_basemem, IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE);
	for (; i < IOPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100d73:	89 c2                	mov    %eax,%edx
f0100d75:	03 15 70 49 11 f0    	add    0xf0114970,%edx
f0100d7b:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100d81:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100d83:	89 c1                	mov    %eax,%ecx
f0100d85:	03 0d 70 49 11 f0    	add    0xf0114970,%ecx
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
f0100da2:	89 0d 3c 45 11 f0    	mov    %ecx,0xf011453c
f0100da8:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100daf:	eb 1a                	jmp    f0100dcb <page_init+0xcf>
		page_free_list = &pages[i];
	}

	// 3) [IOPHYSMEM / PGSIZE, EXTPHYSMEM / PGSIZE) in use
	for (; i < EXTPHYSMEM / PGSIZE; i++) {
		pages[i].pp_ref = 1;
f0100db1:	89 c2                	mov    %eax,%edx
f0100db3:	03 15 70 49 11 f0    	add    0xf0114970,%edx
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
f0100dde:	03 05 70 49 11 f0    	add    0xf0114970,%eax
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
f0100e08:	68 bc 2d 10 f0       	push   $0xf0102dbc
f0100e0d:	68 2e 01 00 00       	push   $0x12e
f0100e12:	68 df 2a 10 f0       	push   $0xf0102adf
f0100e17:	e8 6f f2 ff ff       	call   f010008b <_panic>
f0100e1c:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e21:	c1 e8 0c             	shr    $0xc,%eax
f0100e24:	39 c3                	cmp    %eax,%ebx
f0100e26:	72 b4                	jb     f0100ddc <page_init+0xe0>
f0100e28:	8b 0d 3c 45 11 f0    	mov    0xf011453c,%ecx
f0100e2e:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100e35:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e3a:	eb 23                	jmp    f0100e5f <page_init+0x163>
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
		pages[i].pp_ref = 0;
f0100e3c:	89 c2                	mov    %eax,%edx
f0100e3e:	03 15 70 49 11 f0    	add    0xf0114970,%edx
f0100e44:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100e4a:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100e4c:	89 c1                	mov    %eax,%ecx
f0100e4e:	03 0d 70 49 11 f0    	add    0xf0114970,%ecx
		pages[i].pp_link = 0;
	}

	// cprintf("[?] %d\n", npages);
	// [kernel end, npages) free
	for (; i < npages; i++) {
f0100e54:	83 c3 01             	add    $0x1,%ebx
f0100e57:	83 c0 08             	add    $0x8,%eax
f0100e5a:	ba 01 00 00 00       	mov    $0x1,%edx
f0100e5f:	3b 1d 68 49 11 f0    	cmp    0xf0114968,%ebx
f0100e65:	72 d5                	jb     f0100e3c <page_init+0x140>
f0100e67:	84 d2                	test   %dl,%dl
f0100e69:	74 06                	je     f0100e71 <page_init+0x175>
f0100e6b:	89 0d 3c 45 11 f0    	mov    %ecx,0xf011453c
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
f0100e7d:	8b 1d 3c 45 11 f0    	mov    0xf011453c,%ebx
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
f0100e97:	2b 05 70 49 11 f0    	sub    0xf0114970,%eax
f0100e9d:	c1 f8 03             	sar    $0x3,%eax
f0100ea0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ea3:	89 c2                	mov    %eax,%edx
f0100ea5:	c1 ea 0c             	shr    $0xc,%edx
f0100ea8:	3b 15 68 49 11 f0    	cmp    0xf0114968,%edx
f0100eae:	72 12                	jb     f0100ec2 <page_alloc+0x4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eb0:	50                   	push   %eax
f0100eb1:	68 b0 2c 10 f0       	push   $0xf0102cb0
f0100eb6:	6a 52                	push   $0x52
f0100eb8:	68 eb 2a 10 f0       	push   $0xf0102aeb
f0100ebd:	e8 c9 f1 ff ff       	call   f010008b <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f0100ec2:	83 ec 04             	sub    $0x4,%esp
f0100ec5:	68 00 10 00 00       	push   $0x1000
f0100eca:	6a 00                	push   $0x0
f0100ecc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ed1:	50                   	push   %eax
f0100ed2:	e8 06 12 00 00       	call   f01020dd <memset>
f0100ed7:	83 c4 10             	add    $0x10,%esp
	}
	
	// update free list head
	page_free_list = last_free;
f0100eda:	89 35 3c 45 11 f0    	mov    %esi,0xf011453c

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
f0100efe:	68 e0 2d 10 f0       	push   $0xf0102de0
f0100f03:	68 73 01 00 00       	push   $0x173
f0100f08:	68 df 2a 10 f0       	push   $0xf0102adf
f0100f0d:	e8 79 f1 ff ff       	call   f010008b <_panic>
	if (pp->pp_ref != 0)
f0100f12:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f17:	74 17                	je     f0100f30 <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0100f19:	83 ec 04             	sub    $0x4,%esp
f0100f1c:	68 08 2e 10 f0       	push   $0xf0102e08
f0100f21:	68 75 01 00 00       	push   $0x175
f0100f26:	68 df 2a 10 f0       	push   $0xf0102adf
f0100f2b:	e8 5b f1 ff ff       	call   f010008b <_panic>

	pp->pp_link = page_free_list;
f0100f30:	8b 15 3c 45 11 f0    	mov    0xf011453c,%edx
f0100f36:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f38:	a3 3c 45 11 f0       	mov    %eax,0xf011453c

}
f0100f3d:	c9                   	leave  
f0100f3e:	c3                   	ret    

f0100f3f <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100f3f:	55                   	push   %ebp
f0100f40:	89 e5                	mov    %esp,%ebp
f0100f42:	57                   	push   %edi
f0100f43:	56                   	push   %esi
f0100f44:	53                   	push   %ebx
f0100f45:	83 ec 1c             	sub    $0x1c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100f48:	b8 15 00 00 00       	mov    $0x15,%eax
f0100f4d:	e8 07 fa ff ff       	call   f0100959 <nvram_read>
f0100f52:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100f54:	b8 17 00 00 00       	mov    $0x17,%eax
f0100f59:	e8 fb f9 ff ff       	call   f0100959 <nvram_read>
f0100f5e:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100f60:	b8 34 00 00 00       	mov    $0x34,%eax
f0100f65:	e8 ef f9 ff ff       	call   f0100959 <nvram_read>
f0100f6a:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0100f6d:	85 c0                	test   %eax,%eax
f0100f6f:	74 07                	je     f0100f78 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0100f71:	05 00 40 00 00       	add    $0x4000,%eax
f0100f76:	eb 0b                	jmp    f0100f83 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0100f78:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0100f7e:	85 f6                	test   %esi,%esi
f0100f80:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0100f83:	89 c2                	mov    %eax,%edx
f0100f85:	c1 ea 02             	shr    $0x2,%edx
f0100f88:	89 15 68 49 11 f0    	mov    %edx,0xf0114968
	npages_basemem = basemem / (PGSIZE / 1024);
f0100f8e:	89 da                	mov    %ebx,%edx
f0100f90:	c1 ea 02             	shr    $0x2,%edx
f0100f93:	89 15 40 45 11 f0    	mov    %edx,0xf0114540

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100f99:	89 c2                	mov    %eax,%edx
f0100f9b:	29 da                	sub    %ebx,%edx
f0100f9d:	52                   	push   %edx
f0100f9e:	53                   	push   %ebx
f0100f9f:	50                   	push   %eax
f0100fa0:	68 4c 2e 10 f0       	push   $0xf0102e4c
f0100fa5:	e8 6f 06 00 00       	call   f0101619 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100faa:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100faf:	e8 ce f9 ff ff       	call   f0100982 <boot_alloc>
f0100fb4:	a3 6c 49 11 f0       	mov    %eax,0xf011496c
	memset(kern_pgdir, 0, PGSIZE);
f0100fb9:	83 c4 0c             	add    $0xc,%esp
f0100fbc:	68 00 10 00 00       	push   $0x1000
f0100fc1:	6a 00                	push   $0x0
f0100fc3:	50                   	push   %eax
f0100fc4:	e8 14 11 00 00       	call   f01020dd <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100fc9:	a1 6c 49 11 f0       	mov    0xf011496c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100fce:	83 c4 10             	add    $0x10,%esp
f0100fd1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100fd6:	77 15                	ja     f0100fed <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fd8:	50                   	push   %eax
f0100fd9:	68 bc 2d 10 f0       	push   $0xf0102dbc
f0100fde:	68 96 00 00 00       	push   $0x96
f0100fe3:	68 df 2a 10 f0       	push   $0xf0102adf
f0100fe8:	e8 9e f0 ff ff       	call   f010008b <_panic>
f0100fed:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100ff3:	83 ca 05             	or     $0x5,%edx
f0100ff6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f0100ffc:	a1 68 49 11 f0       	mov    0xf0114968,%eax
f0101001:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f0101008:	89 d8                	mov    %ebx,%eax
f010100a:	e8 73 f9 ff ff       	call   f0100982 <boot_alloc>
f010100f:	a3 70 49 11 f0       	mov    %eax,0xf0114970
	memset(pages, 0, n);
f0101014:	83 ec 04             	sub    $0x4,%esp
f0101017:	53                   	push   %ebx
f0101018:	6a 00                	push   $0x0
f010101a:	50                   	push   %eax
f010101b:	e8 bd 10 00 00       	call   f01020dd <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101020:	e8 d7 fc ff ff       	call   f0100cfc <page_init>

	check_page_free_list(1);
f0101025:	b8 01 00 00 00       	mov    $0x1,%eax
f010102a:	e8 0a fa ff ff       	call   f0100a39 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010102f:	83 c4 10             	add    $0x10,%esp
f0101032:	83 3d 70 49 11 f0 00 	cmpl   $0x0,0xf0114970
f0101039:	75 17                	jne    f0101052 <mem_init+0x113>
		panic("'pages' is a null pointer!");
f010103b:	83 ec 04             	sub    $0x4,%esp
f010103e:	68 95 2b 10 f0       	push   $0xf0102b95
f0101043:	68 58 02 00 00       	push   $0x258
f0101048:	68 df 2a 10 f0       	push   $0xf0102adf
f010104d:	e8 39 f0 ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101052:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f0101057:	bb 00 00 00 00       	mov    $0x0,%ebx
f010105c:	eb 05                	jmp    f0101063 <mem_init+0x124>
		++nfree;
f010105e:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101061:	8b 00                	mov    (%eax),%eax
f0101063:	85 c0                	test   %eax,%eax
f0101065:	75 f7                	jne    f010105e <mem_init+0x11f>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101067:	83 ec 0c             	sub    $0xc,%esp
f010106a:	6a 00                	push   $0x0
f010106c:	e8 07 fe ff ff       	call   f0100e78 <page_alloc>
f0101071:	89 c7                	mov    %eax,%edi
f0101073:	83 c4 10             	add    $0x10,%esp
f0101076:	85 c0                	test   %eax,%eax
f0101078:	75 19                	jne    f0101093 <mem_init+0x154>
f010107a:	68 b0 2b 10 f0       	push   $0xf0102bb0
f010107f:	68 05 2b 10 f0       	push   $0xf0102b05
f0101084:	68 60 02 00 00       	push   $0x260
f0101089:	68 df 2a 10 f0       	push   $0xf0102adf
f010108e:	e8 f8 ef ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101093:	83 ec 0c             	sub    $0xc,%esp
f0101096:	6a 00                	push   $0x0
f0101098:	e8 db fd ff ff       	call   f0100e78 <page_alloc>
f010109d:	89 c6                	mov    %eax,%esi
f010109f:	83 c4 10             	add    $0x10,%esp
f01010a2:	85 c0                	test   %eax,%eax
f01010a4:	75 19                	jne    f01010bf <mem_init+0x180>
f01010a6:	68 c6 2b 10 f0       	push   $0xf0102bc6
f01010ab:	68 05 2b 10 f0       	push   $0xf0102b05
f01010b0:	68 61 02 00 00       	push   $0x261
f01010b5:	68 df 2a 10 f0       	push   $0xf0102adf
f01010ba:	e8 cc ef ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01010bf:	83 ec 0c             	sub    $0xc,%esp
f01010c2:	6a 00                	push   $0x0
f01010c4:	e8 af fd ff ff       	call   f0100e78 <page_alloc>
f01010c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010cc:	83 c4 10             	add    $0x10,%esp
f01010cf:	85 c0                	test   %eax,%eax
f01010d1:	75 19                	jne    f01010ec <mem_init+0x1ad>
f01010d3:	68 dc 2b 10 f0       	push   $0xf0102bdc
f01010d8:	68 05 2b 10 f0       	push   $0xf0102b05
f01010dd:	68 62 02 00 00       	push   $0x262
f01010e2:	68 df 2a 10 f0       	push   $0xf0102adf
f01010e7:	e8 9f ef ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01010ec:	39 f7                	cmp    %esi,%edi
f01010ee:	75 19                	jne    f0101109 <mem_init+0x1ca>
f01010f0:	68 f2 2b 10 f0       	push   $0xf0102bf2
f01010f5:	68 05 2b 10 f0       	push   $0xf0102b05
f01010fa:	68 65 02 00 00       	push   $0x265
f01010ff:	68 df 2a 10 f0       	push   $0xf0102adf
f0101104:	e8 82 ef ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101109:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010110c:	39 c7                	cmp    %eax,%edi
f010110e:	74 04                	je     f0101114 <mem_init+0x1d5>
f0101110:	39 c6                	cmp    %eax,%esi
f0101112:	75 19                	jne    f010112d <mem_init+0x1ee>
f0101114:	68 88 2e 10 f0       	push   $0xf0102e88
f0101119:	68 05 2b 10 f0       	push   $0xf0102b05
f010111e:	68 66 02 00 00       	push   $0x266
f0101123:	68 df 2a 10 f0       	push   $0xf0102adf
f0101128:	e8 5e ef ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010112d:	8b 0d 70 49 11 f0    	mov    0xf0114970,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101133:	8b 15 68 49 11 f0    	mov    0xf0114968,%edx
f0101139:	c1 e2 0c             	shl    $0xc,%edx
f010113c:	89 f8                	mov    %edi,%eax
f010113e:	29 c8                	sub    %ecx,%eax
f0101140:	c1 f8 03             	sar    $0x3,%eax
f0101143:	c1 e0 0c             	shl    $0xc,%eax
f0101146:	39 d0                	cmp    %edx,%eax
f0101148:	72 19                	jb     f0101163 <mem_init+0x224>
f010114a:	68 04 2c 10 f0       	push   $0xf0102c04
f010114f:	68 05 2b 10 f0       	push   $0xf0102b05
f0101154:	68 67 02 00 00       	push   $0x267
f0101159:	68 df 2a 10 f0       	push   $0xf0102adf
f010115e:	e8 28 ef ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101163:	89 f0                	mov    %esi,%eax
f0101165:	29 c8                	sub    %ecx,%eax
f0101167:	c1 f8 03             	sar    $0x3,%eax
f010116a:	c1 e0 0c             	shl    $0xc,%eax
f010116d:	39 c2                	cmp    %eax,%edx
f010116f:	77 19                	ja     f010118a <mem_init+0x24b>
f0101171:	68 21 2c 10 f0       	push   $0xf0102c21
f0101176:	68 05 2b 10 f0       	push   $0xf0102b05
f010117b:	68 68 02 00 00       	push   $0x268
f0101180:	68 df 2a 10 f0       	push   $0xf0102adf
f0101185:	e8 01 ef ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010118a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010118d:	29 c8                	sub    %ecx,%eax
f010118f:	c1 f8 03             	sar    $0x3,%eax
f0101192:	c1 e0 0c             	shl    $0xc,%eax
f0101195:	39 c2                	cmp    %eax,%edx
f0101197:	77 19                	ja     f01011b2 <mem_init+0x273>
f0101199:	68 3e 2c 10 f0       	push   $0xf0102c3e
f010119e:	68 05 2b 10 f0       	push   $0xf0102b05
f01011a3:	68 69 02 00 00       	push   $0x269
f01011a8:	68 df 2a 10 f0       	push   $0xf0102adf
f01011ad:	e8 d9 ee ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01011b2:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f01011b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	page_free_list = 0;
f01011ba:	c7 05 3c 45 11 f0 00 	movl   $0x0,0xf011453c
f01011c1:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01011c4:	83 ec 0c             	sub    $0xc,%esp
f01011c7:	6a 00                	push   $0x0
f01011c9:	e8 aa fc ff ff       	call   f0100e78 <page_alloc>
f01011ce:	83 c4 10             	add    $0x10,%esp
f01011d1:	85 c0                	test   %eax,%eax
f01011d3:	74 19                	je     f01011ee <mem_init+0x2af>
f01011d5:	68 5b 2c 10 f0       	push   $0xf0102c5b
f01011da:	68 05 2b 10 f0       	push   $0xf0102b05
f01011df:	68 70 02 00 00       	push   $0x270
f01011e4:	68 df 2a 10 f0       	push   $0xf0102adf
f01011e9:	e8 9d ee ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f01011ee:	83 ec 0c             	sub    $0xc,%esp
f01011f1:	57                   	push   %edi
f01011f2:	e8 f2 fc ff ff       	call   f0100ee9 <page_free>
	page_free(pp1);
f01011f7:	89 34 24             	mov    %esi,(%esp)
f01011fa:	e8 ea fc ff ff       	call   f0100ee9 <page_free>
	page_free(pp2);
f01011ff:	83 c4 04             	add    $0x4,%esp
f0101202:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101205:	e8 df fc ff ff       	call   f0100ee9 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010120a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101211:	e8 62 fc ff ff       	call   f0100e78 <page_alloc>
f0101216:	89 c6                	mov    %eax,%esi
f0101218:	83 c4 10             	add    $0x10,%esp
f010121b:	85 c0                	test   %eax,%eax
f010121d:	75 19                	jne    f0101238 <mem_init+0x2f9>
f010121f:	68 b0 2b 10 f0       	push   $0xf0102bb0
f0101224:	68 05 2b 10 f0       	push   $0xf0102b05
f0101229:	68 77 02 00 00       	push   $0x277
f010122e:	68 df 2a 10 f0       	push   $0xf0102adf
f0101233:	e8 53 ee ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101238:	83 ec 0c             	sub    $0xc,%esp
f010123b:	6a 00                	push   $0x0
f010123d:	e8 36 fc ff ff       	call   f0100e78 <page_alloc>
f0101242:	89 c7                	mov    %eax,%edi
f0101244:	83 c4 10             	add    $0x10,%esp
f0101247:	85 c0                	test   %eax,%eax
f0101249:	75 19                	jne    f0101264 <mem_init+0x325>
f010124b:	68 c6 2b 10 f0       	push   $0xf0102bc6
f0101250:	68 05 2b 10 f0       	push   $0xf0102b05
f0101255:	68 78 02 00 00       	push   $0x278
f010125a:	68 df 2a 10 f0       	push   $0xf0102adf
f010125f:	e8 27 ee ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101264:	83 ec 0c             	sub    $0xc,%esp
f0101267:	6a 00                	push   $0x0
f0101269:	e8 0a fc ff ff       	call   f0100e78 <page_alloc>
f010126e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101271:	83 c4 10             	add    $0x10,%esp
f0101274:	85 c0                	test   %eax,%eax
f0101276:	75 19                	jne    f0101291 <mem_init+0x352>
f0101278:	68 dc 2b 10 f0       	push   $0xf0102bdc
f010127d:	68 05 2b 10 f0       	push   $0xf0102b05
f0101282:	68 79 02 00 00       	push   $0x279
f0101287:	68 df 2a 10 f0       	push   $0xf0102adf
f010128c:	e8 fa ed ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101291:	39 fe                	cmp    %edi,%esi
f0101293:	75 19                	jne    f01012ae <mem_init+0x36f>
f0101295:	68 f2 2b 10 f0       	push   $0xf0102bf2
f010129a:	68 05 2b 10 f0       	push   $0xf0102b05
f010129f:	68 7b 02 00 00       	push   $0x27b
f01012a4:	68 df 2a 10 f0       	push   $0xf0102adf
f01012a9:	e8 dd ed ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01012b1:	39 c7                	cmp    %eax,%edi
f01012b3:	74 04                	je     f01012b9 <mem_init+0x37a>
f01012b5:	39 c6                	cmp    %eax,%esi
f01012b7:	75 19                	jne    f01012d2 <mem_init+0x393>
f01012b9:	68 88 2e 10 f0       	push   $0xf0102e88
f01012be:	68 05 2b 10 f0       	push   $0xf0102b05
f01012c3:	68 7c 02 00 00       	push   $0x27c
f01012c8:	68 df 2a 10 f0       	push   $0xf0102adf
f01012cd:	e8 b9 ed ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f01012d2:	83 ec 0c             	sub    $0xc,%esp
f01012d5:	6a 00                	push   $0x0
f01012d7:	e8 9c fb ff ff       	call   f0100e78 <page_alloc>
f01012dc:	83 c4 10             	add    $0x10,%esp
f01012df:	85 c0                	test   %eax,%eax
f01012e1:	74 19                	je     f01012fc <mem_init+0x3bd>
f01012e3:	68 5b 2c 10 f0       	push   $0xf0102c5b
f01012e8:	68 05 2b 10 f0       	push   $0xf0102b05
f01012ed:	68 7d 02 00 00       	push   $0x27d
f01012f2:	68 df 2a 10 f0       	push   $0xf0102adf
f01012f7:	e8 8f ed ff ff       	call   f010008b <_panic>
f01012fc:	89 f0                	mov    %esi,%eax
f01012fe:	2b 05 70 49 11 f0    	sub    0xf0114970,%eax
f0101304:	c1 f8 03             	sar    $0x3,%eax
f0101307:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010130a:	89 c2                	mov    %eax,%edx
f010130c:	c1 ea 0c             	shr    $0xc,%edx
f010130f:	3b 15 68 49 11 f0    	cmp    0xf0114968,%edx
f0101315:	72 12                	jb     f0101329 <mem_init+0x3ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101317:	50                   	push   %eax
f0101318:	68 b0 2c 10 f0       	push   $0xf0102cb0
f010131d:	6a 52                	push   $0x52
f010131f:	68 eb 2a 10 f0       	push   $0xf0102aeb
f0101324:	e8 62 ed ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101329:	83 ec 04             	sub    $0x4,%esp
f010132c:	68 00 10 00 00       	push   $0x1000
f0101331:	6a 01                	push   $0x1
f0101333:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101338:	50                   	push   %eax
f0101339:	e8 9f 0d 00 00       	call   f01020dd <memset>
	page_free(pp0);
f010133e:	89 34 24             	mov    %esi,(%esp)
f0101341:	e8 a3 fb ff ff       	call   f0100ee9 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101346:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010134d:	e8 26 fb ff ff       	call   f0100e78 <page_alloc>
f0101352:	83 c4 10             	add    $0x10,%esp
f0101355:	85 c0                	test   %eax,%eax
f0101357:	75 19                	jne    f0101372 <mem_init+0x433>
f0101359:	68 6a 2c 10 f0       	push   $0xf0102c6a
f010135e:	68 05 2b 10 f0       	push   $0xf0102b05
f0101363:	68 82 02 00 00       	push   $0x282
f0101368:	68 df 2a 10 f0       	push   $0xf0102adf
f010136d:	e8 19 ed ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f0101372:	39 c6                	cmp    %eax,%esi
f0101374:	74 19                	je     f010138f <mem_init+0x450>
f0101376:	68 88 2c 10 f0       	push   $0xf0102c88
f010137b:	68 05 2b 10 f0       	push   $0xf0102b05
f0101380:	68 83 02 00 00       	push   $0x283
f0101385:	68 df 2a 10 f0       	push   $0xf0102adf
f010138a:	e8 fc ec ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010138f:	89 f0                	mov    %esi,%eax
f0101391:	2b 05 70 49 11 f0    	sub    0xf0114970,%eax
f0101397:	c1 f8 03             	sar    $0x3,%eax
f010139a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010139d:	89 c2                	mov    %eax,%edx
f010139f:	c1 ea 0c             	shr    $0xc,%edx
f01013a2:	3b 15 68 49 11 f0    	cmp    0xf0114968,%edx
f01013a8:	72 12                	jb     f01013bc <mem_init+0x47d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013aa:	50                   	push   %eax
f01013ab:	68 b0 2c 10 f0       	push   $0xf0102cb0
f01013b0:	6a 52                	push   $0x52
f01013b2:	68 eb 2a 10 f0       	push   $0xf0102aeb
f01013b7:	e8 cf ec ff ff       	call   f010008b <_panic>
f01013bc:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01013c2:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
f01013c8:	80 38 00             	cmpb   $0x0,(%eax)
f01013cb:	74 19                	je     f01013e6 <mem_init+0x4a7>
f01013cd:	68 98 2c 10 f0       	push   $0xf0102c98
f01013d2:	68 05 2b 10 f0       	push   $0xf0102b05
f01013d7:	68 87 02 00 00       	push   $0x287
f01013dc:	68 df 2a 10 f0       	push   $0xf0102adf
f01013e1:	e8 a5 ec ff ff       	call   f010008b <_panic>
f01013e6:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
f01013e9:	39 d0                	cmp    %edx,%eax
f01013eb:	75 db                	jne    f01013c8 <mem_init+0x489>
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
	}

	// give free list back
	page_free_list = fl;
f01013ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01013f0:	a3 3c 45 11 f0       	mov    %eax,0xf011453c

	// free the pages we took
	page_free(pp0);
f01013f5:	83 ec 0c             	sub    $0xc,%esp
f01013f8:	56                   	push   %esi
f01013f9:	e8 eb fa ff ff       	call   f0100ee9 <page_free>
	page_free(pp1);
f01013fe:	89 3c 24             	mov    %edi,(%esp)
f0101401:	e8 e3 fa ff ff       	call   f0100ee9 <page_free>
	page_free(pp2);
f0101406:	83 c4 04             	add    $0x4,%esp
f0101409:	ff 75 e4             	pushl  -0x1c(%ebp)
f010140c:	e8 d8 fa ff ff       	call   f0100ee9 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101411:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f0101416:	83 c4 10             	add    $0x10,%esp
f0101419:	eb 05                	jmp    f0101420 <mem_init+0x4e1>
		--nfree;
f010141b:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010141e:	8b 00                	mov    (%eax),%eax
f0101420:	85 c0                	test   %eax,%eax
f0101422:	75 f7                	jne    f010141b <mem_init+0x4dc>
		--nfree;
	assert(nfree == 0);
f0101424:	85 db                	test   %ebx,%ebx
f0101426:	74 19                	je     f0101441 <mem_init+0x502>
f0101428:	68 a2 2c 10 f0       	push   $0xf0102ca2
f010142d:	68 05 2b 10 f0       	push   $0xf0102b05
f0101432:	68 95 02 00 00       	push   $0x295
f0101437:	68 df 2a 10 f0       	push   $0xf0102adf
f010143c:	e8 4a ec ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101441:	83 ec 0c             	sub    $0xc,%esp
f0101444:	68 a8 2e 10 f0       	push   $0xf0102ea8
f0101449:	e8 cb 01 00 00       	call   f0101619 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010144e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101455:	e8 1e fa ff ff       	call   f0100e78 <page_alloc>
f010145a:	89 c3                	mov    %eax,%ebx
f010145c:	83 c4 10             	add    $0x10,%esp
f010145f:	85 c0                	test   %eax,%eax
f0101461:	75 19                	jne    f010147c <mem_init+0x53d>
f0101463:	68 b0 2b 10 f0       	push   $0xf0102bb0
f0101468:	68 05 2b 10 f0       	push   $0xf0102b05
f010146d:	68 ee 02 00 00       	push   $0x2ee
f0101472:	68 df 2a 10 f0       	push   $0xf0102adf
f0101477:	e8 0f ec ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010147c:	83 ec 0c             	sub    $0xc,%esp
f010147f:	6a 00                	push   $0x0
f0101481:	e8 f2 f9 ff ff       	call   f0100e78 <page_alloc>
f0101486:	89 c6                	mov    %eax,%esi
f0101488:	83 c4 10             	add    $0x10,%esp
f010148b:	85 c0                	test   %eax,%eax
f010148d:	75 19                	jne    f01014a8 <mem_init+0x569>
f010148f:	68 c6 2b 10 f0       	push   $0xf0102bc6
f0101494:	68 05 2b 10 f0       	push   $0xf0102b05
f0101499:	68 ef 02 00 00       	push   $0x2ef
f010149e:	68 df 2a 10 f0       	push   $0xf0102adf
f01014a3:	e8 e3 eb ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01014a8:	83 ec 0c             	sub    $0xc,%esp
f01014ab:	6a 00                	push   $0x0
f01014ad:	e8 c6 f9 ff ff       	call   f0100e78 <page_alloc>
f01014b2:	83 c4 10             	add    $0x10,%esp
f01014b5:	85 c0                	test   %eax,%eax
f01014b7:	75 19                	jne    f01014d2 <mem_init+0x593>
f01014b9:	68 dc 2b 10 f0       	push   $0xf0102bdc
f01014be:	68 05 2b 10 f0       	push   $0xf0102b05
f01014c3:	68 f0 02 00 00       	push   $0x2f0
f01014c8:	68 df 2a 10 f0       	push   $0xf0102adf
f01014cd:	e8 b9 eb ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014d2:	39 f3                	cmp    %esi,%ebx
f01014d4:	75 19                	jne    f01014ef <mem_init+0x5b0>
f01014d6:	68 f2 2b 10 f0       	push   $0xf0102bf2
f01014db:	68 05 2b 10 f0       	push   $0xf0102b05
f01014e0:	68 f3 02 00 00       	push   $0x2f3
f01014e5:	68 df 2a 10 f0       	push   $0xf0102adf
f01014ea:	e8 9c eb ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014ef:	39 c6                	cmp    %eax,%esi
f01014f1:	74 04                	je     f01014f7 <mem_init+0x5b8>
f01014f3:	39 c3                	cmp    %eax,%ebx
f01014f5:	75 19                	jne    f0101510 <mem_init+0x5d1>
f01014f7:	68 88 2e 10 f0       	push   $0xf0102e88
f01014fc:	68 05 2b 10 f0       	push   $0xf0102b05
f0101501:	68 f4 02 00 00       	push   $0x2f4
f0101506:	68 df 2a 10 f0       	push   $0xf0102adf
f010150b:	e8 7b eb ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;
f0101510:	c7 05 3c 45 11 f0 00 	movl   $0x0,0xf011453c
f0101517:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010151a:	83 ec 0c             	sub    $0xc,%esp
f010151d:	6a 00                	push   $0x0
f010151f:	e8 54 f9 ff ff       	call   f0100e78 <page_alloc>
f0101524:	83 c4 10             	add    $0x10,%esp
f0101527:	85 c0                	test   %eax,%eax
f0101529:	74 19                	je     f0101544 <mem_init+0x605>
f010152b:	68 5b 2c 10 f0       	push   $0xf0102c5b
f0101530:	68 05 2b 10 f0       	push   $0xf0102b05
f0101535:	68 fb 02 00 00       	push   $0x2fb
f010153a:	68 df 2a 10 f0       	push   $0xf0102adf
f010153f:	e8 47 eb ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101544:	68 c8 2e 10 f0       	push   $0xf0102ec8
f0101549:	68 05 2b 10 f0       	push   $0xf0102b05
f010154e:	68 01 03 00 00       	push   $0x301
f0101553:	68 df 2a 10 f0       	push   $0xf0102adf
f0101558:	e8 2e eb ff ff       	call   f010008b <_panic>

f010155d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010155d:	55                   	push   %ebp
f010155e:	89 e5                	mov    %esp,%ebp
f0101560:	83 ec 08             	sub    $0x8,%esp
f0101563:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101566:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010156a:	83 e8 01             	sub    $0x1,%eax
f010156d:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101571:	66 85 c0             	test   %ax,%ax
f0101574:	75 0c                	jne    f0101582 <page_decref+0x25>
		page_free(pp);
f0101576:	83 ec 0c             	sub    $0xc,%esp
f0101579:	52                   	push   %edx
f010157a:	e8 6a f9 ff ff       	call   f0100ee9 <page_free>
f010157f:	83 c4 10             	add    $0x10,%esp
}
f0101582:	c9                   	leave  
f0101583:	c3                   	ret    

f0101584 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101584:	55                   	push   %ebp
f0101585:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0101587:	b8 00 00 00 00       	mov    $0x0,%eax
f010158c:	5d                   	pop    %ebp
f010158d:	c3                   	ret    

f010158e <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010158e:	55                   	push   %ebp
f010158f:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0101591:	b8 00 00 00 00       	mov    $0x0,%eax
f0101596:	5d                   	pop    %ebp
f0101597:	c3                   	ret    

f0101598 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101598:	55                   	push   %ebp
f0101599:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f010159b:	b8 00 00 00 00       	mov    $0x0,%eax
f01015a0:	5d                   	pop    %ebp
f01015a1:	c3                   	ret    

f01015a2 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01015a2:	55                   	push   %ebp
f01015a3:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f01015a5:	5d                   	pop    %ebp
f01015a6:	c3                   	ret    

f01015a7 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01015a7:	55                   	push   %ebp
f01015a8:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01015aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015ad:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01015b0:	5d                   	pop    %ebp
f01015b1:	c3                   	ret    

f01015b2 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01015b2:	55                   	push   %ebp
f01015b3:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01015b5:	ba 70 00 00 00       	mov    $0x70,%edx
f01015ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01015bd:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01015be:	ba 71 00 00 00       	mov    $0x71,%edx
f01015c3:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01015c4:	0f b6 c0             	movzbl %al,%eax
}
f01015c7:	5d                   	pop    %ebp
f01015c8:	c3                   	ret    

f01015c9 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01015c9:	55                   	push   %ebp
f01015ca:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01015cc:	ba 70 00 00 00       	mov    $0x70,%edx
f01015d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01015d4:	ee                   	out    %al,(%dx)
f01015d5:	ba 71 00 00 00       	mov    $0x71,%edx
f01015da:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015dd:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01015de:	5d                   	pop    %ebp
f01015df:	c3                   	ret    

f01015e0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01015e0:	55                   	push   %ebp
f01015e1:	89 e5                	mov    %esp,%ebp
f01015e3:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01015e6:	ff 75 08             	pushl  0x8(%ebp)
f01015e9:	e8 12 f0 ff ff       	call   f0100600 <cputchar>
	*cnt++;
}
f01015ee:	83 c4 10             	add    $0x10,%esp
f01015f1:	c9                   	leave  
f01015f2:	c3                   	ret    

f01015f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01015f3:	55                   	push   %ebp
f01015f4:	89 e5                	mov    %esp,%ebp
f01015f6:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01015f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0101600:	ff 75 0c             	pushl  0xc(%ebp)
f0101603:	ff 75 08             	pushl  0x8(%ebp)
f0101606:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101609:	50                   	push   %eax
f010160a:	68 e0 15 10 f0       	push   $0xf01015e0
f010160f:	e8 5d 04 00 00       	call   f0101a71 <vprintfmt>
	return cnt;
}
f0101614:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101617:	c9                   	leave  
f0101618:	c3                   	ret    

f0101619 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0101619:	55                   	push   %ebp
f010161a:	89 e5                	mov    %esp,%ebp
f010161c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010161f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0101622:	50                   	push   %eax
f0101623:	ff 75 08             	pushl  0x8(%ebp)
f0101626:	e8 c8 ff ff ff       	call   f01015f3 <vcprintf>
	va_end(ap);

	return cnt;
}
f010162b:	c9                   	leave  
f010162c:	c3                   	ret    

f010162d <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010162d:	55                   	push   %ebp
f010162e:	89 e5                	mov    %esp,%ebp
f0101630:	57                   	push   %edi
f0101631:	56                   	push   %esi
f0101632:	53                   	push   %ebx
f0101633:	83 ec 14             	sub    $0x14,%esp
f0101636:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101639:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010163c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010163f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0101642:	8b 1a                	mov    (%edx),%ebx
f0101644:	8b 01                	mov    (%ecx),%eax
f0101646:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101649:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0101650:	eb 7f                	jmp    f01016d1 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0101652:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101655:	01 d8                	add    %ebx,%eax
f0101657:	89 c6                	mov    %eax,%esi
f0101659:	c1 ee 1f             	shr    $0x1f,%esi
f010165c:	01 c6                	add    %eax,%esi
f010165e:	d1 fe                	sar    %esi
f0101660:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0101663:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0101666:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0101669:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010166b:	eb 03                	jmp    f0101670 <stab_binsearch+0x43>
			m--;
f010166d:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101670:	39 c3                	cmp    %eax,%ebx
f0101672:	7f 0d                	jg     f0101681 <stab_binsearch+0x54>
f0101674:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0101678:	83 ea 0c             	sub    $0xc,%edx
f010167b:	39 f9                	cmp    %edi,%ecx
f010167d:	75 ee                	jne    f010166d <stab_binsearch+0x40>
f010167f:	eb 05                	jmp    f0101686 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0101681:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0101684:	eb 4b                	jmp    f01016d1 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0101686:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0101689:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010168c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0101690:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0101693:	76 11                	jbe    f01016a6 <stab_binsearch+0x79>
			*region_left = m;
f0101695:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101698:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010169a:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010169d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01016a4:	eb 2b                	jmp    f01016d1 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01016a6:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01016a9:	73 14                	jae    f01016bf <stab_binsearch+0x92>
			*region_right = m - 1;
f01016ab:	83 e8 01             	sub    $0x1,%eax
f01016ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01016b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01016b4:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01016b6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01016bd:	eb 12                	jmp    f01016d1 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01016bf:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01016c2:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01016c4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01016c8:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01016ca:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01016d1:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01016d4:	0f 8e 78 ff ff ff    	jle    f0101652 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01016da:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01016de:	75 0f                	jne    f01016ef <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01016e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01016e3:	8b 00                	mov    (%eax),%eax
f01016e5:	83 e8 01             	sub    $0x1,%eax
f01016e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01016eb:	89 06                	mov    %eax,(%esi)
f01016ed:	eb 2c                	jmp    f010171b <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01016ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01016f2:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01016f4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01016f7:	8b 0e                	mov    (%esi),%ecx
f01016f9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01016fc:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01016ff:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101702:	eb 03                	jmp    f0101707 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0101704:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101707:	39 c8                	cmp    %ecx,%eax
f0101709:	7e 0b                	jle    f0101716 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010170b:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010170f:	83 ea 0c             	sub    $0xc,%edx
f0101712:	39 df                	cmp    %ebx,%edi
f0101714:	75 ee                	jne    f0101704 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0101716:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101719:	89 06                	mov    %eax,(%esi)
	}
}
f010171b:	83 c4 14             	add    $0x14,%esp
f010171e:	5b                   	pop    %ebx
f010171f:	5e                   	pop    %esi
f0101720:	5f                   	pop    %edi
f0101721:	5d                   	pop    %ebp
f0101722:	c3                   	ret    

f0101723 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0101723:	55                   	push   %ebp
f0101724:	89 e5                	mov    %esp,%ebp
f0101726:	57                   	push   %edi
f0101727:	56                   	push   %esi
f0101728:	53                   	push   %ebx
f0101729:	83 ec 3c             	sub    $0x3c,%esp
f010172c:	8b 75 08             	mov    0x8(%ebp),%esi
f010172f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0101732:	c7 03 f8 2e 10 f0    	movl   $0xf0102ef8,(%ebx)
	info->eip_line = 0;
f0101738:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010173f:	c7 43 08 f8 2e 10 f0 	movl   $0xf0102ef8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0101746:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010174d:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0101750:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0101757:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010175d:	76 11                	jbe    f0101770 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010175f:	b8 f5 9b 10 f0       	mov    $0xf0109bf5,%eax
f0101764:	3d 79 7e 10 f0       	cmp    $0xf0107e79,%eax
f0101769:	77 19                	ja     f0101784 <debuginfo_eip+0x61>
f010176b:	e9 b5 01 00 00       	jmp    f0101925 <debuginfo_eip+0x202>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0101770:	83 ec 04             	sub    $0x4,%esp
f0101773:	68 02 2f 10 f0       	push   $0xf0102f02
f0101778:	6a 7f                	push   $0x7f
f010177a:	68 0f 2f 10 f0       	push   $0xf0102f0f
f010177f:	e8 07 e9 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101784:	80 3d f4 9b 10 f0 00 	cmpb   $0x0,0xf0109bf4
f010178b:	0f 85 9b 01 00 00    	jne    f010192c <debuginfo_eip+0x209>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0101791:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0101798:	b8 78 7e 10 f0       	mov    $0xf0107e78,%eax
f010179d:	2d 2c 31 10 f0       	sub    $0xf010312c,%eax
f01017a2:	c1 f8 02             	sar    $0x2,%eax
f01017a5:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01017ab:	83 e8 01             	sub    $0x1,%eax
f01017ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01017b1:	83 ec 08             	sub    $0x8,%esp
f01017b4:	56                   	push   %esi
f01017b5:	6a 64                	push   $0x64
f01017b7:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01017ba:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01017bd:	b8 2c 31 10 f0       	mov    $0xf010312c,%eax
f01017c2:	e8 66 fe ff ff       	call   f010162d <stab_binsearch>
	if (lfile == 0)
f01017c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01017ca:	83 c4 10             	add    $0x10,%esp
f01017cd:	85 c0                	test   %eax,%eax
f01017cf:	0f 84 5e 01 00 00    	je     f0101933 <debuginfo_eip+0x210>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01017d5:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01017d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01017db:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01017de:	83 ec 08             	sub    $0x8,%esp
f01017e1:	56                   	push   %esi
f01017e2:	6a 24                	push   $0x24
f01017e4:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01017e7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01017ea:	b8 2c 31 10 f0       	mov    $0xf010312c,%eax
f01017ef:	e8 39 fe ff ff       	call   f010162d <stab_binsearch>

	if (lfun <= rfun) {
f01017f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01017f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01017fa:	83 c4 10             	add    $0x10,%esp
f01017fd:	39 d0                	cmp    %edx,%eax
f01017ff:	7f 40                	jg     f0101841 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0101801:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0101804:	c1 e1 02             	shl    $0x2,%ecx
f0101807:	8d b9 2c 31 10 f0    	lea    -0xfefced4(%ecx),%edi
f010180d:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0101810:	8b b9 2c 31 10 f0    	mov    -0xfefced4(%ecx),%edi
f0101816:	b9 f5 9b 10 f0       	mov    $0xf0109bf5,%ecx
f010181b:	81 e9 79 7e 10 f0    	sub    $0xf0107e79,%ecx
f0101821:	39 cf                	cmp    %ecx,%edi
f0101823:	73 09                	jae    f010182e <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0101825:	81 c7 79 7e 10 f0    	add    $0xf0107e79,%edi
f010182b:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010182e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0101831:	8b 4f 08             	mov    0x8(%edi),%ecx
f0101834:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0101837:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0101839:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010183c:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010183f:	eb 0f                	jmp    f0101850 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0101841:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0101844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101847:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010184a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010184d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0101850:	83 ec 08             	sub    $0x8,%esp
f0101853:	6a 3a                	push   $0x3a
f0101855:	ff 73 08             	pushl  0x8(%ebx)
f0101858:	e8 64 08 00 00       	call   f01020c1 <strfind>
f010185d:	2b 43 08             	sub    0x8(%ebx),%eax
f0101860:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0101863:	83 c4 08             	add    $0x8,%esp
f0101866:	56                   	push   %esi
f0101867:	6a 44                	push   $0x44
f0101869:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010186c:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010186f:	b8 2c 31 10 f0       	mov    $0xf010312c,%eax
f0101874:	e8 b4 fd ff ff       	call   f010162d <stab_binsearch>
	if (lline == 0)
f0101879:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010187c:	83 c4 10             	add    $0x10,%esp
f010187f:	85 c0                	test   %eax,%eax
f0101881:	0f 84 b3 00 00 00    	je     f010193a <debuginfo_eip+0x217>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0101887:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010188a:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010188d:	0f b7 14 95 32 31 10 	movzwl -0xfefcece(,%edx,4),%edx
f0101894:	f0 
f0101895:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101898:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010189b:	89 c2                	mov    %eax,%edx
f010189d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01018a0:	8d 04 85 2c 31 10 f0 	lea    -0xfefced4(,%eax,4),%eax
f01018a7:	eb 06                	jmp    f01018af <debuginfo_eip+0x18c>
f01018a9:	83 ea 01             	sub    $0x1,%edx
f01018ac:	83 e8 0c             	sub    $0xc,%eax
f01018af:	39 d7                	cmp    %edx,%edi
f01018b1:	7f 34                	jg     f01018e7 <debuginfo_eip+0x1c4>
	       && stabs[lline].n_type != N_SOL
f01018b3:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f01018b7:	80 f9 84             	cmp    $0x84,%cl
f01018ba:	74 0b                	je     f01018c7 <debuginfo_eip+0x1a4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01018bc:	80 f9 64             	cmp    $0x64,%cl
f01018bf:	75 e8                	jne    f01018a9 <debuginfo_eip+0x186>
f01018c1:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f01018c5:	74 e2                	je     f01018a9 <debuginfo_eip+0x186>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01018c7:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01018ca:	8b 14 85 2c 31 10 f0 	mov    -0xfefced4(,%eax,4),%edx
f01018d1:	b8 f5 9b 10 f0       	mov    $0xf0109bf5,%eax
f01018d6:	2d 79 7e 10 f0       	sub    $0xf0107e79,%eax
f01018db:	39 c2                	cmp    %eax,%edx
f01018dd:	73 08                	jae    f01018e7 <debuginfo_eip+0x1c4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01018df:	81 c2 79 7e 10 f0    	add    $0xf0107e79,%edx
f01018e5:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01018e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01018ea:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01018ed:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01018f2:	39 f2                	cmp    %esi,%edx
f01018f4:	7d 50                	jge    f0101946 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
f01018f6:	83 c2 01             	add    $0x1,%edx
f01018f9:	89 d0                	mov    %edx,%eax
f01018fb:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01018fe:	8d 14 95 2c 31 10 f0 	lea    -0xfefced4(,%edx,4),%edx
f0101905:	eb 04                	jmp    f010190b <debuginfo_eip+0x1e8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0101907:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010190b:	39 c6                	cmp    %eax,%esi
f010190d:	7e 32                	jle    f0101941 <debuginfo_eip+0x21e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010190f:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0101913:	83 c0 01             	add    $0x1,%eax
f0101916:	83 c2 0c             	add    $0xc,%edx
f0101919:	80 f9 a0             	cmp    $0xa0,%cl
f010191c:	74 e9                	je     f0101907 <debuginfo_eip+0x1e4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010191e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101923:	eb 21                	jmp    f0101946 <debuginfo_eip+0x223>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0101925:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010192a:	eb 1a                	jmp    f0101946 <debuginfo_eip+0x223>
f010192c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101931:	eb 13                	jmp    f0101946 <debuginfo_eip+0x223>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0101933:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101938:	eb 0c                	jmp    f0101946 <debuginfo_eip+0x223>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f010193a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010193f:	eb 05                	jmp    f0101946 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101941:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101946:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101949:	5b                   	pop    %ebx
f010194a:	5e                   	pop    %esi
f010194b:	5f                   	pop    %edi
f010194c:	5d                   	pop    %ebp
f010194d:	c3                   	ret    

f010194e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010194e:	55                   	push   %ebp
f010194f:	89 e5                	mov    %esp,%ebp
f0101951:	57                   	push   %edi
f0101952:	56                   	push   %esi
f0101953:	53                   	push   %ebx
f0101954:	83 ec 1c             	sub    $0x1c,%esp
f0101957:	89 c7                	mov    %eax,%edi
f0101959:	89 d6                	mov    %edx,%esi
f010195b:	8b 45 08             	mov    0x8(%ebp),%eax
f010195e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101961:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101964:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101967:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010196a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010196f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101972:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101975:	39 d3                	cmp    %edx,%ebx
f0101977:	72 05                	jb     f010197e <printnum+0x30>
f0101979:	39 45 10             	cmp    %eax,0x10(%ebp)
f010197c:	77 45                	ja     f01019c3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010197e:	83 ec 0c             	sub    $0xc,%esp
f0101981:	ff 75 18             	pushl  0x18(%ebp)
f0101984:	8b 45 14             	mov    0x14(%ebp),%eax
f0101987:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010198a:	53                   	push   %ebx
f010198b:	ff 75 10             	pushl  0x10(%ebp)
f010198e:	83 ec 08             	sub    $0x8,%esp
f0101991:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101994:	ff 75 e0             	pushl  -0x20(%ebp)
f0101997:	ff 75 dc             	pushl  -0x24(%ebp)
f010199a:	ff 75 d8             	pushl  -0x28(%ebp)
f010199d:	e8 3e 09 00 00       	call   f01022e0 <__udivdi3>
f01019a2:	83 c4 18             	add    $0x18,%esp
f01019a5:	52                   	push   %edx
f01019a6:	50                   	push   %eax
f01019a7:	89 f2                	mov    %esi,%edx
f01019a9:	89 f8                	mov    %edi,%eax
f01019ab:	e8 9e ff ff ff       	call   f010194e <printnum>
f01019b0:	83 c4 20             	add    $0x20,%esp
f01019b3:	eb 18                	jmp    f01019cd <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01019b5:	83 ec 08             	sub    $0x8,%esp
f01019b8:	56                   	push   %esi
f01019b9:	ff 75 18             	pushl  0x18(%ebp)
f01019bc:	ff d7                	call   *%edi
f01019be:	83 c4 10             	add    $0x10,%esp
f01019c1:	eb 03                	jmp    f01019c6 <printnum+0x78>
f01019c3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01019c6:	83 eb 01             	sub    $0x1,%ebx
f01019c9:	85 db                	test   %ebx,%ebx
f01019cb:	7f e8                	jg     f01019b5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01019cd:	83 ec 08             	sub    $0x8,%esp
f01019d0:	56                   	push   %esi
f01019d1:	83 ec 04             	sub    $0x4,%esp
f01019d4:	ff 75 e4             	pushl  -0x1c(%ebp)
f01019d7:	ff 75 e0             	pushl  -0x20(%ebp)
f01019da:	ff 75 dc             	pushl  -0x24(%ebp)
f01019dd:	ff 75 d8             	pushl  -0x28(%ebp)
f01019e0:	e8 2b 0a 00 00       	call   f0102410 <__umoddi3>
f01019e5:	83 c4 14             	add    $0x14,%esp
f01019e8:	0f be 80 1d 2f 10 f0 	movsbl -0xfefd0e3(%eax),%eax
f01019ef:	50                   	push   %eax
f01019f0:	ff d7                	call   *%edi
}
f01019f2:	83 c4 10             	add    $0x10,%esp
f01019f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01019f8:	5b                   	pop    %ebx
f01019f9:	5e                   	pop    %esi
f01019fa:	5f                   	pop    %edi
f01019fb:	5d                   	pop    %ebp
f01019fc:	c3                   	ret    

f01019fd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01019fd:	55                   	push   %ebp
f01019fe:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101a00:	83 fa 01             	cmp    $0x1,%edx
f0101a03:	7e 0e                	jle    f0101a13 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0101a05:	8b 10                	mov    (%eax),%edx
f0101a07:	8d 4a 08             	lea    0x8(%edx),%ecx
f0101a0a:	89 08                	mov    %ecx,(%eax)
f0101a0c:	8b 02                	mov    (%edx),%eax
f0101a0e:	8b 52 04             	mov    0x4(%edx),%edx
f0101a11:	eb 22                	jmp    f0101a35 <getuint+0x38>
	else if (lflag)
f0101a13:	85 d2                	test   %edx,%edx
f0101a15:	74 10                	je     f0101a27 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0101a17:	8b 10                	mov    (%eax),%edx
f0101a19:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101a1c:	89 08                	mov    %ecx,(%eax)
f0101a1e:	8b 02                	mov    (%edx),%eax
f0101a20:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a25:	eb 0e                	jmp    f0101a35 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0101a27:	8b 10                	mov    (%eax),%edx
f0101a29:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101a2c:	89 08                	mov    %ecx,(%eax)
f0101a2e:	8b 02                	mov    (%edx),%eax
f0101a30:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101a35:	5d                   	pop    %ebp
f0101a36:	c3                   	ret    

f0101a37 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101a37:	55                   	push   %ebp
f0101a38:	89 e5                	mov    %esp,%ebp
f0101a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101a3d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101a41:	8b 10                	mov    (%eax),%edx
f0101a43:	3b 50 04             	cmp    0x4(%eax),%edx
f0101a46:	73 0a                	jae    f0101a52 <sprintputch+0x1b>
		*b->buf++ = ch;
f0101a48:	8d 4a 01             	lea    0x1(%edx),%ecx
f0101a4b:	89 08                	mov    %ecx,(%eax)
f0101a4d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a50:	88 02                	mov    %al,(%edx)
}
f0101a52:	5d                   	pop    %ebp
f0101a53:	c3                   	ret    

f0101a54 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101a54:	55                   	push   %ebp
f0101a55:	89 e5                	mov    %esp,%ebp
f0101a57:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0101a5a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101a5d:	50                   	push   %eax
f0101a5e:	ff 75 10             	pushl  0x10(%ebp)
f0101a61:	ff 75 0c             	pushl  0xc(%ebp)
f0101a64:	ff 75 08             	pushl  0x8(%ebp)
f0101a67:	e8 05 00 00 00       	call   f0101a71 <vprintfmt>
	va_end(ap);
}
f0101a6c:	83 c4 10             	add    $0x10,%esp
f0101a6f:	c9                   	leave  
f0101a70:	c3                   	ret    

f0101a71 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101a71:	55                   	push   %ebp
f0101a72:	89 e5                	mov    %esp,%ebp
f0101a74:	57                   	push   %edi
f0101a75:	56                   	push   %esi
f0101a76:	53                   	push   %ebx
f0101a77:	83 ec 2c             	sub    $0x2c,%esp
f0101a7a:	8b 75 08             	mov    0x8(%ebp),%esi
f0101a7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101a80:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101a83:	eb 12                	jmp    f0101a97 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0101a85:	85 c0                	test   %eax,%eax
f0101a87:	0f 84 89 03 00 00    	je     f0101e16 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0101a8d:	83 ec 08             	sub    $0x8,%esp
f0101a90:	53                   	push   %ebx
f0101a91:	50                   	push   %eax
f0101a92:	ff d6                	call   *%esi
f0101a94:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101a97:	83 c7 01             	add    $0x1,%edi
f0101a9a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101a9e:	83 f8 25             	cmp    $0x25,%eax
f0101aa1:	75 e2                	jne    f0101a85 <vprintfmt+0x14>
f0101aa3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0101aa7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0101aae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101ab5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0101abc:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ac1:	eb 07                	jmp    f0101aca <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101ac3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0101ac6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101aca:	8d 47 01             	lea    0x1(%edi),%eax
f0101acd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101ad0:	0f b6 07             	movzbl (%edi),%eax
f0101ad3:	0f b6 c8             	movzbl %al,%ecx
f0101ad6:	83 e8 23             	sub    $0x23,%eax
f0101ad9:	3c 55                	cmp    $0x55,%al
f0101adb:	0f 87 1a 03 00 00    	ja     f0101dfb <vprintfmt+0x38a>
f0101ae1:	0f b6 c0             	movzbl %al,%eax
f0101ae4:	ff 24 85 a8 2f 10 f0 	jmp    *-0xfefd058(,%eax,4)
f0101aeb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101aee:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101af2:	eb d6                	jmp    f0101aca <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101af4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101af7:	b8 00 00 00 00       	mov    $0x0,%eax
f0101afc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101aff:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101b02:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0101b06:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0101b09:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0101b0c:	83 fa 09             	cmp    $0x9,%edx
f0101b0f:	77 39                	ja     f0101b4a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0101b11:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0101b14:	eb e9                	jmp    f0101aff <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101b16:	8b 45 14             	mov    0x14(%ebp),%eax
f0101b19:	8d 48 04             	lea    0x4(%eax),%ecx
f0101b1c:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0101b1f:	8b 00                	mov    (%eax),%eax
f0101b21:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101b24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101b27:	eb 27                	jmp    f0101b50 <vprintfmt+0xdf>
f0101b29:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101b2c:	85 c0                	test   %eax,%eax
f0101b2e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101b33:	0f 49 c8             	cmovns %eax,%ecx
f0101b36:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101b39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101b3c:	eb 8c                	jmp    f0101aca <vprintfmt+0x59>
f0101b3e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101b41:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101b48:	eb 80                	jmp    f0101aca <vprintfmt+0x59>
f0101b4a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101b4d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0101b50:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101b54:	0f 89 70 ff ff ff    	jns    f0101aca <vprintfmt+0x59>
				width = precision, precision = -1;
f0101b5a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101b60:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101b67:	e9 5e ff ff ff       	jmp    f0101aca <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101b6c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101b6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0101b72:	e9 53 ff ff ff       	jmp    f0101aca <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101b77:	8b 45 14             	mov    0x14(%ebp),%eax
f0101b7a:	8d 50 04             	lea    0x4(%eax),%edx
f0101b7d:	89 55 14             	mov    %edx,0x14(%ebp)
f0101b80:	83 ec 08             	sub    $0x8,%esp
f0101b83:	53                   	push   %ebx
f0101b84:	ff 30                	pushl  (%eax)
f0101b86:	ff d6                	call   *%esi
			break;
f0101b88:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101b8b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0101b8e:	e9 04 ff ff ff       	jmp    f0101a97 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101b93:	8b 45 14             	mov    0x14(%ebp),%eax
f0101b96:	8d 50 04             	lea    0x4(%eax),%edx
f0101b99:	89 55 14             	mov    %edx,0x14(%ebp)
f0101b9c:	8b 00                	mov    (%eax),%eax
f0101b9e:	99                   	cltd   
f0101b9f:	31 d0                	xor    %edx,%eax
f0101ba1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101ba3:	83 f8 06             	cmp    $0x6,%eax
f0101ba6:	7f 0b                	jg     f0101bb3 <vprintfmt+0x142>
f0101ba8:	8b 14 85 00 31 10 f0 	mov    -0xfefcf00(,%eax,4),%edx
f0101baf:	85 d2                	test   %edx,%edx
f0101bb1:	75 18                	jne    f0101bcb <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0101bb3:	50                   	push   %eax
f0101bb4:	68 35 2f 10 f0       	push   $0xf0102f35
f0101bb9:	53                   	push   %ebx
f0101bba:	56                   	push   %esi
f0101bbb:	e8 94 fe ff ff       	call   f0101a54 <printfmt>
f0101bc0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101bc3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101bc6:	e9 cc fe ff ff       	jmp    f0101a97 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0101bcb:	52                   	push   %edx
f0101bcc:	68 17 2b 10 f0       	push   $0xf0102b17
f0101bd1:	53                   	push   %ebx
f0101bd2:	56                   	push   %esi
f0101bd3:	e8 7c fe ff ff       	call   f0101a54 <printfmt>
f0101bd8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101bdb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101bde:	e9 b4 fe ff ff       	jmp    f0101a97 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101be3:	8b 45 14             	mov    0x14(%ebp),%eax
f0101be6:	8d 50 04             	lea    0x4(%eax),%edx
f0101be9:	89 55 14             	mov    %edx,0x14(%ebp)
f0101bec:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0101bee:	85 ff                	test   %edi,%edi
f0101bf0:	b8 2e 2f 10 f0       	mov    $0xf0102f2e,%eax
f0101bf5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0101bf8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101bfc:	0f 8e 94 00 00 00    	jle    f0101c96 <vprintfmt+0x225>
f0101c02:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101c06:	0f 84 98 00 00 00    	je     f0101ca4 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101c0c:	83 ec 08             	sub    $0x8,%esp
f0101c0f:	ff 75 d0             	pushl  -0x30(%ebp)
f0101c12:	57                   	push   %edi
f0101c13:	e8 5f 03 00 00       	call   f0101f77 <strnlen>
f0101c18:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101c1b:	29 c1                	sub    %eax,%ecx
f0101c1d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101c20:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101c23:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101c27:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101c2a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101c2d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101c2f:	eb 0f                	jmp    f0101c40 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0101c31:	83 ec 08             	sub    $0x8,%esp
f0101c34:	53                   	push   %ebx
f0101c35:	ff 75 e0             	pushl  -0x20(%ebp)
f0101c38:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101c3a:	83 ef 01             	sub    $0x1,%edi
f0101c3d:	83 c4 10             	add    $0x10,%esp
f0101c40:	85 ff                	test   %edi,%edi
f0101c42:	7f ed                	jg     f0101c31 <vprintfmt+0x1c0>
f0101c44:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101c47:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101c4a:	85 c9                	test   %ecx,%ecx
f0101c4c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c51:	0f 49 c1             	cmovns %ecx,%eax
f0101c54:	29 c1                	sub    %eax,%ecx
f0101c56:	89 75 08             	mov    %esi,0x8(%ebp)
f0101c59:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101c5c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101c5f:	89 cb                	mov    %ecx,%ebx
f0101c61:	eb 4d                	jmp    f0101cb0 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101c63:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101c67:	74 1b                	je     f0101c84 <vprintfmt+0x213>
f0101c69:	0f be c0             	movsbl %al,%eax
f0101c6c:	83 e8 20             	sub    $0x20,%eax
f0101c6f:	83 f8 5e             	cmp    $0x5e,%eax
f0101c72:	76 10                	jbe    f0101c84 <vprintfmt+0x213>
					putch('?', putdat);
f0101c74:	83 ec 08             	sub    $0x8,%esp
f0101c77:	ff 75 0c             	pushl  0xc(%ebp)
f0101c7a:	6a 3f                	push   $0x3f
f0101c7c:	ff 55 08             	call   *0x8(%ebp)
f0101c7f:	83 c4 10             	add    $0x10,%esp
f0101c82:	eb 0d                	jmp    f0101c91 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0101c84:	83 ec 08             	sub    $0x8,%esp
f0101c87:	ff 75 0c             	pushl  0xc(%ebp)
f0101c8a:	52                   	push   %edx
f0101c8b:	ff 55 08             	call   *0x8(%ebp)
f0101c8e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101c91:	83 eb 01             	sub    $0x1,%ebx
f0101c94:	eb 1a                	jmp    f0101cb0 <vprintfmt+0x23f>
f0101c96:	89 75 08             	mov    %esi,0x8(%ebp)
f0101c99:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101c9c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101c9f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101ca2:	eb 0c                	jmp    f0101cb0 <vprintfmt+0x23f>
f0101ca4:	89 75 08             	mov    %esi,0x8(%ebp)
f0101ca7:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101caa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101cad:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101cb0:	83 c7 01             	add    $0x1,%edi
f0101cb3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101cb7:	0f be d0             	movsbl %al,%edx
f0101cba:	85 d2                	test   %edx,%edx
f0101cbc:	74 23                	je     f0101ce1 <vprintfmt+0x270>
f0101cbe:	85 f6                	test   %esi,%esi
f0101cc0:	78 a1                	js     f0101c63 <vprintfmt+0x1f2>
f0101cc2:	83 ee 01             	sub    $0x1,%esi
f0101cc5:	79 9c                	jns    f0101c63 <vprintfmt+0x1f2>
f0101cc7:	89 df                	mov    %ebx,%edi
f0101cc9:	8b 75 08             	mov    0x8(%ebp),%esi
f0101ccc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101ccf:	eb 18                	jmp    f0101ce9 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101cd1:	83 ec 08             	sub    $0x8,%esp
f0101cd4:	53                   	push   %ebx
f0101cd5:	6a 20                	push   $0x20
f0101cd7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101cd9:	83 ef 01             	sub    $0x1,%edi
f0101cdc:	83 c4 10             	add    $0x10,%esp
f0101cdf:	eb 08                	jmp    f0101ce9 <vprintfmt+0x278>
f0101ce1:	89 df                	mov    %ebx,%edi
f0101ce3:	8b 75 08             	mov    0x8(%ebp),%esi
f0101ce6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101ce9:	85 ff                	test   %edi,%edi
f0101ceb:	7f e4                	jg     f0101cd1 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101ced:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101cf0:	e9 a2 fd ff ff       	jmp    f0101a97 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101cf5:	83 fa 01             	cmp    $0x1,%edx
f0101cf8:	7e 16                	jle    f0101d10 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0101cfa:	8b 45 14             	mov    0x14(%ebp),%eax
f0101cfd:	8d 50 08             	lea    0x8(%eax),%edx
f0101d00:	89 55 14             	mov    %edx,0x14(%ebp)
f0101d03:	8b 50 04             	mov    0x4(%eax),%edx
f0101d06:	8b 00                	mov    (%eax),%eax
f0101d08:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101d0b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101d0e:	eb 32                	jmp    f0101d42 <vprintfmt+0x2d1>
	else if (lflag)
f0101d10:	85 d2                	test   %edx,%edx
f0101d12:	74 18                	je     f0101d2c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0101d14:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d17:	8d 50 04             	lea    0x4(%eax),%edx
f0101d1a:	89 55 14             	mov    %edx,0x14(%ebp)
f0101d1d:	8b 00                	mov    (%eax),%eax
f0101d1f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101d22:	89 c1                	mov    %eax,%ecx
f0101d24:	c1 f9 1f             	sar    $0x1f,%ecx
f0101d27:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101d2a:	eb 16                	jmp    f0101d42 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0101d2c:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d2f:	8d 50 04             	lea    0x4(%eax),%edx
f0101d32:	89 55 14             	mov    %edx,0x14(%ebp)
f0101d35:	8b 00                	mov    (%eax),%eax
f0101d37:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101d3a:	89 c1                	mov    %eax,%ecx
f0101d3c:	c1 f9 1f             	sar    $0x1f,%ecx
f0101d3f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101d42:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101d45:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101d48:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101d4d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101d51:	79 74                	jns    f0101dc7 <vprintfmt+0x356>
				putch('-', putdat);
f0101d53:	83 ec 08             	sub    $0x8,%esp
f0101d56:	53                   	push   %ebx
f0101d57:	6a 2d                	push   $0x2d
f0101d59:	ff d6                	call   *%esi
				num = -(long long) num;
f0101d5b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101d5e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101d61:	f7 d8                	neg    %eax
f0101d63:	83 d2 00             	adc    $0x0,%edx
f0101d66:	f7 da                	neg    %edx
f0101d68:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0101d6b:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101d70:	eb 55                	jmp    f0101dc7 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101d72:	8d 45 14             	lea    0x14(%ebp),%eax
f0101d75:	e8 83 fc ff ff       	call   f01019fd <getuint>
			base = 10;
f0101d7a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101d7f:	eb 46                	jmp    f0101dc7 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0101d81:	8d 45 14             	lea    0x14(%ebp),%eax
f0101d84:	e8 74 fc ff ff       	call   f01019fd <getuint>
			base = 8;
f0101d89:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0101d8e:	eb 37                	jmp    f0101dc7 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0101d90:	83 ec 08             	sub    $0x8,%esp
f0101d93:	53                   	push   %ebx
f0101d94:	6a 30                	push   $0x30
f0101d96:	ff d6                	call   *%esi
			putch('x', putdat);
f0101d98:	83 c4 08             	add    $0x8,%esp
f0101d9b:	53                   	push   %ebx
f0101d9c:	6a 78                	push   $0x78
f0101d9e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101da0:	8b 45 14             	mov    0x14(%ebp),%eax
f0101da3:	8d 50 04             	lea    0x4(%eax),%edx
f0101da6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101da9:	8b 00                	mov    (%eax),%eax
f0101dab:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101db0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101db3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0101db8:	eb 0d                	jmp    f0101dc7 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101dba:	8d 45 14             	lea    0x14(%ebp),%eax
f0101dbd:	e8 3b fc ff ff       	call   f01019fd <getuint>
			base = 16;
f0101dc2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101dc7:	83 ec 0c             	sub    $0xc,%esp
f0101dca:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101dce:	57                   	push   %edi
f0101dcf:	ff 75 e0             	pushl  -0x20(%ebp)
f0101dd2:	51                   	push   %ecx
f0101dd3:	52                   	push   %edx
f0101dd4:	50                   	push   %eax
f0101dd5:	89 da                	mov    %ebx,%edx
f0101dd7:	89 f0                	mov    %esi,%eax
f0101dd9:	e8 70 fb ff ff       	call   f010194e <printnum>
			break;
f0101dde:	83 c4 20             	add    $0x20,%esp
f0101de1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101de4:	e9 ae fc ff ff       	jmp    f0101a97 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101de9:	83 ec 08             	sub    $0x8,%esp
f0101dec:	53                   	push   %ebx
f0101ded:	51                   	push   %ecx
f0101dee:	ff d6                	call   *%esi
			break;
f0101df0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101df3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101df6:	e9 9c fc ff ff       	jmp    f0101a97 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101dfb:	83 ec 08             	sub    $0x8,%esp
f0101dfe:	53                   	push   %ebx
f0101dff:	6a 25                	push   $0x25
f0101e01:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101e03:	83 c4 10             	add    $0x10,%esp
f0101e06:	eb 03                	jmp    f0101e0b <vprintfmt+0x39a>
f0101e08:	83 ef 01             	sub    $0x1,%edi
f0101e0b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101e0f:	75 f7                	jne    f0101e08 <vprintfmt+0x397>
f0101e11:	e9 81 fc ff ff       	jmp    f0101a97 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101e16:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101e19:	5b                   	pop    %ebx
f0101e1a:	5e                   	pop    %esi
f0101e1b:	5f                   	pop    %edi
f0101e1c:	5d                   	pop    %ebp
f0101e1d:	c3                   	ret    

f0101e1e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101e1e:	55                   	push   %ebp
f0101e1f:	89 e5                	mov    %esp,%ebp
f0101e21:	83 ec 18             	sub    $0x18,%esp
f0101e24:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e27:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101e2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101e2d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101e31:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101e34:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101e3b:	85 c0                	test   %eax,%eax
f0101e3d:	74 26                	je     f0101e65 <vsnprintf+0x47>
f0101e3f:	85 d2                	test   %edx,%edx
f0101e41:	7e 22                	jle    f0101e65 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101e43:	ff 75 14             	pushl  0x14(%ebp)
f0101e46:	ff 75 10             	pushl  0x10(%ebp)
f0101e49:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101e4c:	50                   	push   %eax
f0101e4d:	68 37 1a 10 f0       	push   $0xf0101a37
f0101e52:	e8 1a fc ff ff       	call   f0101a71 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101e57:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101e5a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101e60:	83 c4 10             	add    $0x10,%esp
f0101e63:	eb 05                	jmp    f0101e6a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101e65:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101e6a:	c9                   	leave  
f0101e6b:	c3                   	ret    

f0101e6c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101e6c:	55                   	push   %ebp
f0101e6d:	89 e5                	mov    %esp,%ebp
f0101e6f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101e72:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101e75:	50                   	push   %eax
f0101e76:	ff 75 10             	pushl  0x10(%ebp)
f0101e79:	ff 75 0c             	pushl  0xc(%ebp)
f0101e7c:	ff 75 08             	pushl  0x8(%ebp)
f0101e7f:	e8 9a ff ff ff       	call   f0101e1e <vsnprintf>
	va_end(ap);

	return rc;
}
f0101e84:	c9                   	leave  
f0101e85:	c3                   	ret    

f0101e86 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101e86:	55                   	push   %ebp
f0101e87:	89 e5                	mov    %esp,%ebp
f0101e89:	57                   	push   %edi
f0101e8a:	56                   	push   %esi
f0101e8b:	53                   	push   %ebx
f0101e8c:	83 ec 0c             	sub    $0xc,%esp
f0101e8f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101e92:	85 c0                	test   %eax,%eax
f0101e94:	74 11                	je     f0101ea7 <readline+0x21>
		cprintf("%s", prompt);
f0101e96:	83 ec 08             	sub    $0x8,%esp
f0101e99:	50                   	push   %eax
f0101e9a:	68 17 2b 10 f0       	push   $0xf0102b17
f0101e9f:	e8 75 f7 ff ff       	call   f0101619 <cprintf>
f0101ea4:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101ea7:	83 ec 0c             	sub    $0xc,%esp
f0101eaa:	6a 00                	push   $0x0
f0101eac:	e8 70 e7 ff ff       	call   f0100621 <iscons>
f0101eb1:	89 c7                	mov    %eax,%edi
f0101eb3:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101eb6:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101ebb:	e8 50 e7 ff ff       	call   f0100610 <getchar>
f0101ec0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101ec2:	85 c0                	test   %eax,%eax
f0101ec4:	79 18                	jns    f0101ede <readline+0x58>
			cprintf("read error: %e\n", c);
f0101ec6:	83 ec 08             	sub    $0x8,%esp
f0101ec9:	50                   	push   %eax
f0101eca:	68 1c 31 10 f0       	push   $0xf010311c
f0101ecf:	e8 45 f7 ff ff       	call   f0101619 <cprintf>
			return NULL;
f0101ed4:	83 c4 10             	add    $0x10,%esp
f0101ed7:	b8 00 00 00 00       	mov    $0x0,%eax
f0101edc:	eb 79                	jmp    f0101f57 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101ede:	83 f8 08             	cmp    $0x8,%eax
f0101ee1:	0f 94 c2             	sete   %dl
f0101ee4:	83 f8 7f             	cmp    $0x7f,%eax
f0101ee7:	0f 94 c0             	sete   %al
f0101eea:	08 c2                	or     %al,%dl
f0101eec:	74 1a                	je     f0101f08 <readline+0x82>
f0101eee:	85 f6                	test   %esi,%esi
f0101ef0:	7e 16                	jle    f0101f08 <readline+0x82>
			if (echoing)
f0101ef2:	85 ff                	test   %edi,%edi
f0101ef4:	74 0d                	je     f0101f03 <readline+0x7d>
				cputchar('\b');
f0101ef6:	83 ec 0c             	sub    $0xc,%esp
f0101ef9:	6a 08                	push   $0x8
f0101efb:	e8 00 e7 ff ff       	call   f0100600 <cputchar>
f0101f00:	83 c4 10             	add    $0x10,%esp
			i--;
f0101f03:	83 ee 01             	sub    $0x1,%esi
f0101f06:	eb b3                	jmp    f0101ebb <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101f08:	83 fb 1f             	cmp    $0x1f,%ebx
f0101f0b:	7e 23                	jle    f0101f30 <readline+0xaa>
f0101f0d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101f13:	7f 1b                	jg     f0101f30 <readline+0xaa>
			if (echoing)
f0101f15:	85 ff                	test   %edi,%edi
f0101f17:	74 0c                	je     f0101f25 <readline+0x9f>
				cputchar(c);
f0101f19:	83 ec 0c             	sub    $0xc,%esp
f0101f1c:	53                   	push   %ebx
f0101f1d:	e8 de e6 ff ff       	call   f0100600 <cputchar>
f0101f22:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101f25:	88 9e 60 45 11 f0    	mov    %bl,-0xfeebaa0(%esi)
f0101f2b:	8d 76 01             	lea    0x1(%esi),%esi
f0101f2e:	eb 8b                	jmp    f0101ebb <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101f30:	83 fb 0a             	cmp    $0xa,%ebx
f0101f33:	74 05                	je     f0101f3a <readline+0xb4>
f0101f35:	83 fb 0d             	cmp    $0xd,%ebx
f0101f38:	75 81                	jne    f0101ebb <readline+0x35>
			if (echoing)
f0101f3a:	85 ff                	test   %edi,%edi
f0101f3c:	74 0d                	je     f0101f4b <readline+0xc5>
				cputchar('\n');
f0101f3e:	83 ec 0c             	sub    $0xc,%esp
f0101f41:	6a 0a                	push   $0xa
f0101f43:	e8 b8 e6 ff ff       	call   f0100600 <cputchar>
f0101f48:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0101f4b:	c6 86 60 45 11 f0 00 	movb   $0x0,-0xfeebaa0(%esi)
			return buf;
f0101f52:	b8 60 45 11 f0       	mov    $0xf0114560,%eax
		}
	}
}
f0101f57:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101f5a:	5b                   	pop    %ebx
f0101f5b:	5e                   	pop    %esi
f0101f5c:	5f                   	pop    %edi
f0101f5d:	5d                   	pop    %ebp
f0101f5e:	c3                   	ret    

f0101f5f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101f5f:	55                   	push   %ebp
f0101f60:	89 e5                	mov    %esp,%ebp
f0101f62:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101f65:	b8 00 00 00 00       	mov    $0x0,%eax
f0101f6a:	eb 03                	jmp    f0101f6f <strlen+0x10>
		n++;
f0101f6c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101f6f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101f73:	75 f7                	jne    f0101f6c <strlen+0xd>
		n++;
	return n;
}
f0101f75:	5d                   	pop    %ebp
f0101f76:	c3                   	ret    

f0101f77 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101f77:	55                   	push   %ebp
f0101f78:	89 e5                	mov    %esp,%ebp
f0101f7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101f80:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f85:	eb 03                	jmp    f0101f8a <strnlen+0x13>
		n++;
f0101f87:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101f8a:	39 c2                	cmp    %eax,%edx
f0101f8c:	74 08                	je     f0101f96 <strnlen+0x1f>
f0101f8e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101f92:	75 f3                	jne    f0101f87 <strnlen+0x10>
f0101f94:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0101f96:	5d                   	pop    %ebp
f0101f97:	c3                   	ret    

f0101f98 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101f98:	55                   	push   %ebp
f0101f99:	89 e5                	mov    %esp,%ebp
f0101f9b:	53                   	push   %ebx
f0101f9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0101f9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101fa2:	89 c2                	mov    %eax,%edx
f0101fa4:	83 c2 01             	add    $0x1,%edx
f0101fa7:	83 c1 01             	add    $0x1,%ecx
f0101faa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101fae:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101fb1:	84 db                	test   %bl,%bl
f0101fb3:	75 ef                	jne    f0101fa4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101fb5:	5b                   	pop    %ebx
f0101fb6:	5d                   	pop    %ebp
f0101fb7:	c3                   	ret    

f0101fb8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101fb8:	55                   	push   %ebp
f0101fb9:	89 e5                	mov    %esp,%ebp
f0101fbb:	53                   	push   %ebx
f0101fbc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101fbf:	53                   	push   %ebx
f0101fc0:	e8 9a ff ff ff       	call   f0101f5f <strlen>
f0101fc5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101fc8:	ff 75 0c             	pushl  0xc(%ebp)
f0101fcb:	01 d8                	add    %ebx,%eax
f0101fcd:	50                   	push   %eax
f0101fce:	e8 c5 ff ff ff       	call   f0101f98 <strcpy>
	return dst;
}
f0101fd3:	89 d8                	mov    %ebx,%eax
f0101fd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101fd8:	c9                   	leave  
f0101fd9:	c3                   	ret    

f0101fda <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101fda:	55                   	push   %ebp
f0101fdb:	89 e5                	mov    %esp,%ebp
f0101fdd:	56                   	push   %esi
f0101fde:	53                   	push   %ebx
f0101fdf:	8b 75 08             	mov    0x8(%ebp),%esi
f0101fe2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101fe5:	89 f3                	mov    %esi,%ebx
f0101fe7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101fea:	89 f2                	mov    %esi,%edx
f0101fec:	eb 0f                	jmp    f0101ffd <strncpy+0x23>
		*dst++ = *src;
f0101fee:	83 c2 01             	add    $0x1,%edx
f0101ff1:	0f b6 01             	movzbl (%ecx),%eax
f0101ff4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101ff7:	80 39 01             	cmpb   $0x1,(%ecx)
f0101ffa:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101ffd:	39 da                	cmp    %ebx,%edx
f0101fff:	75 ed                	jne    f0101fee <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0102001:	89 f0                	mov    %esi,%eax
f0102003:	5b                   	pop    %ebx
f0102004:	5e                   	pop    %esi
f0102005:	5d                   	pop    %ebp
f0102006:	c3                   	ret    

f0102007 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0102007:	55                   	push   %ebp
f0102008:	89 e5                	mov    %esp,%ebp
f010200a:	56                   	push   %esi
f010200b:	53                   	push   %ebx
f010200c:	8b 75 08             	mov    0x8(%ebp),%esi
f010200f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102012:	8b 55 10             	mov    0x10(%ebp),%edx
f0102015:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0102017:	85 d2                	test   %edx,%edx
f0102019:	74 21                	je     f010203c <strlcpy+0x35>
f010201b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010201f:	89 f2                	mov    %esi,%edx
f0102021:	eb 09                	jmp    f010202c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0102023:	83 c2 01             	add    $0x1,%edx
f0102026:	83 c1 01             	add    $0x1,%ecx
f0102029:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010202c:	39 c2                	cmp    %eax,%edx
f010202e:	74 09                	je     f0102039 <strlcpy+0x32>
f0102030:	0f b6 19             	movzbl (%ecx),%ebx
f0102033:	84 db                	test   %bl,%bl
f0102035:	75 ec                	jne    f0102023 <strlcpy+0x1c>
f0102037:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0102039:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010203c:	29 f0                	sub    %esi,%eax
}
f010203e:	5b                   	pop    %ebx
f010203f:	5e                   	pop    %esi
f0102040:	5d                   	pop    %ebp
f0102041:	c3                   	ret    

f0102042 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0102042:	55                   	push   %ebp
f0102043:	89 e5                	mov    %esp,%ebp
f0102045:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102048:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010204b:	eb 06                	jmp    f0102053 <strcmp+0x11>
		p++, q++;
f010204d:	83 c1 01             	add    $0x1,%ecx
f0102050:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0102053:	0f b6 01             	movzbl (%ecx),%eax
f0102056:	84 c0                	test   %al,%al
f0102058:	74 04                	je     f010205e <strcmp+0x1c>
f010205a:	3a 02                	cmp    (%edx),%al
f010205c:	74 ef                	je     f010204d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010205e:	0f b6 c0             	movzbl %al,%eax
f0102061:	0f b6 12             	movzbl (%edx),%edx
f0102064:	29 d0                	sub    %edx,%eax
}
f0102066:	5d                   	pop    %ebp
f0102067:	c3                   	ret    

f0102068 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0102068:	55                   	push   %ebp
f0102069:	89 e5                	mov    %esp,%ebp
f010206b:	53                   	push   %ebx
f010206c:	8b 45 08             	mov    0x8(%ebp),%eax
f010206f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102072:	89 c3                	mov    %eax,%ebx
f0102074:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0102077:	eb 06                	jmp    f010207f <strncmp+0x17>
		n--, p++, q++;
f0102079:	83 c0 01             	add    $0x1,%eax
f010207c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010207f:	39 d8                	cmp    %ebx,%eax
f0102081:	74 15                	je     f0102098 <strncmp+0x30>
f0102083:	0f b6 08             	movzbl (%eax),%ecx
f0102086:	84 c9                	test   %cl,%cl
f0102088:	74 04                	je     f010208e <strncmp+0x26>
f010208a:	3a 0a                	cmp    (%edx),%cl
f010208c:	74 eb                	je     f0102079 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010208e:	0f b6 00             	movzbl (%eax),%eax
f0102091:	0f b6 12             	movzbl (%edx),%edx
f0102094:	29 d0                	sub    %edx,%eax
f0102096:	eb 05                	jmp    f010209d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0102098:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010209d:	5b                   	pop    %ebx
f010209e:	5d                   	pop    %ebp
f010209f:	c3                   	ret    

f01020a0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01020a0:	55                   	push   %ebp
f01020a1:	89 e5                	mov    %esp,%ebp
f01020a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01020a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01020aa:	eb 07                	jmp    f01020b3 <strchr+0x13>
		if (*s == c)
f01020ac:	38 ca                	cmp    %cl,%dl
f01020ae:	74 0f                	je     f01020bf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01020b0:	83 c0 01             	add    $0x1,%eax
f01020b3:	0f b6 10             	movzbl (%eax),%edx
f01020b6:	84 d2                	test   %dl,%dl
f01020b8:	75 f2                	jne    f01020ac <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01020ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01020bf:	5d                   	pop    %ebp
f01020c0:	c3                   	ret    

f01020c1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01020c1:	55                   	push   %ebp
f01020c2:	89 e5                	mov    %esp,%ebp
f01020c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01020c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01020cb:	eb 03                	jmp    f01020d0 <strfind+0xf>
f01020cd:	83 c0 01             	add    $0x1,%eax
f01020d0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01020d3:	38 ca                	cmp    %cl,%dl
f01020d5:	74 04                	je     f01020db <strfind+0x1a>
f01020d7:	84 d2                	test   %dl,%dl
f01020d9:	75 f2                	jne    f01020cd <strfind+0xc>
			break;
	return (char *) s;
}
f01020db:	5d                   	pop    %ebp
f01020dc:	c3                   	ret    

f01020dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01020dd:	55                   	push   %ebp
f01020de:	89 e5                	mov    %esp,%ebp
f01020e0:	57                   	push   %edi
f01020e1:	56                   	push   %esi
f01020e2:	53                   	push   %ebx
f01020e3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01020e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01020e9:	85 c9                	test   %ecx,%ecx
f01020eb:	74 36                	je     f0102123 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01020ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01020f3:	75 28                	jne    f010211d <memset+0x40>
f01020f5:	f6 c1 03             	test   $0x3,%cl
f01020f8:	75 23                	jne    f010211d <memset+0x40>
		c &= 0xFF;
f01020fa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01020fe:	89 d3                	mov    %edx,%ebx
f0102100:	c1 e3 08             	shl    $0x8,%ebx
f0102103:	89 d6                	mov    %edx,%esi
f0102105:	c1 e6 18             	shl    $0x18,%esi
f0102108:	89 d0                	mov    %edx,%eax
f010210a:	c1 e0 10             	shl    $0x10,%eax
f010210d:	09 f0                	or     %esi,%eax
f010210f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0102111:	89 d8                	mov    %ebx,%eax
f0102113:	09 d0                	or     %edx,%eax
f0102115:	c1 e9 02             	shr    $0x2,%ecx
f0102118:	fc                   	cld    
f0102119:	f3 ab                	rep stos %eax,%es:(%edi)
f010211b:	eb 06                	jmp    f0102123 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010211d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102120:	fc                   	cld    
f0102121:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0102123:	89 f8                	mov    %edi,%eax
f0102125:	5b                   	pop    %ebx
f0102126:	5e                   	pop    %esi
f0102127:	5f                   	pop    %edi
f0102128:	5d                   	pop    %ebp
f0102129:	c3                   	ret    

f010212a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010212a:	55                   	push   %ebp
f010212b:	89 e5                	mov    %esp,%ebp
f010212d:	57                   	push   %edi
f010212e:	56                   	push   %esi
f010212f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102132:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102135:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0102138:	39 c6                	cmp    %eax,%esi
f010213a:	73 35                	jae    f0102171 <memmove+0x47>
f010213c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010213f:	39 d0                	cmp    %edx,%eax
f0102141:	73 2e                	jae    f0102171 <memmove+0x47>
		s += n;
		d += n;
f0102143:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0102146:	89 d6                	mov    %edx,%esi
f0102148:	09 fe                	or     %edi,%esi
f010214a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0102150:	75 13                	jne    f0102165 <memmove+0x3b>
f0102152:	f6 c1 03             	test   $0x3,%cl
f0102155:	75 0e                	jne    f0102165 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0102157:	83 ef 04             	sub    $0x4,%edi
f010215a:	8d 72 fc             	lea    -0x4(%edx),%esi
f010215d:	c1 e9 02             	shr    $0x2,%ecx
f0102160:	fd                   	std    
f0102161:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102163:	eb 09                	jmp    f010216e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0102165:	83 ef 01             	sub    $0x1,%edi
f0102168:	8d 72 ff             	lea    -0x1(%edx),%esi
f010216b:	fd                   	std    
f010216c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010216e:	fc                   	cld    
f010216f:	eb 1d                	jmp    f010218e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0102171:	89 f2                	mov    %esi,%edx
f0102173:	09 c2                	or     %eax,%edx
f0102175:	f6 c2 03             	test   $0x3,%dl
f0102178:	75 0f                	jne    f0102189 <memmove+0x5f>
f010217a:	f6 c1 03             	test   $0x3,%cl
f010217d:	75 0a                	jne    f0102189 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010217f:	c1 e9 02             	shr    $0x2,%ecx
f0102182:	89 c7                	mov    %eax,%edi
f0102184:	fc                   	cld    
f0102185:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102187:	eb 05                	jmp    f010218e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0102189:	89 c7                	mov    %eax,%edi
f010218b:	fc                   	cld    
f010218c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010218e:	5e                   	pop    %esi
f010218f:	5f                   	pop    %edi
f0102190:	5d                   	pop    %ebp
f0102191:	c3                   	ret    

f0102192 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0102192:	55                   	push   %ebp
f0102193:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0102195:	ff 75 10             	pushl  0x10(%ebp)
f0102198:	ff 75 0c             	pushl  0xc(%ebp)
f010219b:	ff 75 08             	pushl  0x8(%ebp)
f010219e:	e8 87 ff ff ff       	call   f010212a <memmove>
}
f01021a3:	c9                   	leave  
f01021a4:	c3                   	ret    

f01021a5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01021a5:	55                   	push   %ebp
f01021a6:	89 e5                	mov    %esp,%ebp
f01021a8:	56                   	push   %esi
f01021a9:	53                   	push   %ebx
f01021aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01021ad:	8b 55 0c             	mov    0xc(%ebp),%edx
f01021b0:	89 c6                	mov    %eax,%esi
f01021b2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01021b5:	eb 1a                	jmp    f01021d1 <memcmp+0x2c>
		if (*s1 != *s2)
f01021b7:	0f b6 08             	movzbl (%eax),%ecx
f01021ba:	0f b6 1a             	movzbl (%edx),%ebx
f01021bd:	38 d9                	cmp    %bl,%cl
f01021bf:	74 0a                	je     f01021cb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01021c1:	0f b6 c1             	movzbl %cl,%eax
f01021c4:	0f b6 db             	movzbl %bl,%ebx
f01021c7:	29 d8                	sub    %ebx,%eax
f01021c9:	eb 0f                	jmp    f01021da <memcmp+0x35>
		s1++, s2++;
f01021cb:	83 c0 01             	add    $0x1,%eax
f01021ce:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01021d1:	39 f0                	cmp    %esi,%eax
f01021d3:	75 e2                	jne    f01021b7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01021d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01021da:	5b                   	pop    %ebx
f01021db:	5e                   	pop    %esi
f01021dc:	5d                   	pop    %ebp
f01021dd:	c3                   	ret    

f01021de <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01021de:	55                   	push   %ebp
f01021df:	89 e5                	mov    %esp,%ebp
f01021e1:	53                   	push   %ebx
f01021e2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01021e5:	89 c1                	mov    %eax,%ecx
f01021e7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01021ea:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01021ee:	eb 0a                	jmp    f01021fa <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01021f0:	0f b6 10             	movzbl (%eax),%edx
f01021f3:	39 da                	cmp    %ebx,%edx
f01021f5:	74 07                	je     f01021fe <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01021f7:	83 c0 01             	add    $0x1,%eax
f01021fa:	39 c8                	cmp    %ecx,%eax
f01021fc:	72 f2                	jb     f01021f0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01021fe:	5b                   	pop    %ebx
f01021ff:	5d                   	pop    %ebp
f0102200:	c3                   	ret    

f0102201 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0102201:	55                   	push   %ebp
f0102202:	89 e5                	mov    %esp,%ebp
f0102204:	57                   	push   %edi
f0102205:	56                   	push   %esi
f0102206:	53                   	push   %ebx
f0102207:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010220a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010220d:	eb 03                	jmp    f0102212 <strtol+0x11>
		s++;
f010220f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102212:	0f b6 01             	movzbl (%ecx),%eax
f0102215:	3c 20                	cmp    $0x20,%al
f0102217:	74 f6                	je     f010220f <strtol+0xe>
f0102219:	3c 09                	cmp    $0x9,%al
f010221b:	74 f2                	je     f010220f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010221d:	3c 2b                	cmp    $0x2b,%al
f010221f:	75 0a                	jne    f010222b <strtol+0x2a>
		s++;
f0102221:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0102224:	bf 00 00 00 00       	mov    $0x0,%edi
f0102229:	eb 11                	jmp    f010223c <strtol+0x3b>
f010222b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0102230:	3c 2d                	cmp    $0x2d,%al
f0102232:	75 08                	jne    f010223c <strtol+0x3b>
		s++, neg = 1;
f0102234:	83 c1 01             	add    $0x1,%ecx
f0102237:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010223c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0102242:	75 15                	jne    f0102259 <strtol+0x58>
f0102244:	80 39 30             	cmpb   $0x30,(%ecx)
f0102247:	75 10                	jne    f0102259 <strtol+0x58>
f0102249:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010224d:	75 7c                	jne    f01022cb <strtol+0xca>
		s += 2, base = 16;
f010224f:	83 c1 02             	add    $0x2,%ecx
f0102252:	bb 10 00 00 00       	mov    $0x10,%ebx
f0102257:	eb 16                	jmp    f010226f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0102259:	85 db                	test   %ebx,%ebx
f010225b:	75 12                	jne    f010226f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010225d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0102262:	80 39 30             	cmpb   $0x30,(%ecx)
f0102265:	75 08                	jne    f010226f <strtol+0x6e>
		s++, base = 8;
f0102267:	83 c1 01             	add    $0x1,%ecx
f010226a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010226f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102274:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0102277:	0f b6 11             	movzbl (%ecx),%edx
f010227a:	8d 72 d0             	lea    -0x30(%edx),%esi
f010227d:	89 f3                	mov    %esi,%ebx
f010227f:	80 fb 09             	cmp    $0x9,%bl
f0102282:	77 08                	ja     f010228c <strtol+0x8b>
			dig = *s - '0';
f0102284:	0f be d2             	movsbl %dl,%edx
f0102287:	83 ea 30             	sub    $0x30,%edx
f010228a:	eb 22                	jmp    f01022ae <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010228c:	8d 72 9f             	lea    -0x61(%edx),%esi
f010228f:	89 f3                	mov    %esi,%ebx
f0102291:	80 fb 19             	cmp    $0x19,%bl
f0102294:	77 08                	ja     f010229e <strtol+0x9d>
			dig = *s - 'a' + 10;
f0102296:	0f be d2             	movsbl %dl,%edx
f0102299:	83 ea 57             	sub    $0x57,%edx
f010229c:	eb 10                	jmp    f01022ae <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010229e:	8d 72 bf             	lea    -0x41(%edx),%esi
f01022a1:	89 f3                	mov    %esi,%ebx
f01022a3:	80 fb 19             	cmp    $0x19,%bl
f01022a6:	77 16                	ja     f01022be <strtol+0xbd>
			dig = *s - 'A' + 10;
f01022a8:	0f be d2             	movsbl %dl,%edx
f01022ab:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01022ae:	3b 55 10             	cmp    0x10(%ebp),%edx
f01022b1:	7d 0b                	jge    f01022be <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01022b3:	83 c1 01             	add    $0x1,%ecx
f01022b6:	0f af 45 10          	imul   0x10(%ebp),%eax
f01022ba:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01022bc:	eb b9                	jmp    f0102277 <strtol+0x76>

	if (endptr)
f01022be:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01022c2:	74 0d                	je     f01022d1 <strtol+0xd0>
		*endptr = (char *) s;
f01022c4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01022c7:	89 0e                	mov    %ecx,(%esi)
f01022c9:	eb 06                	jmp    f01022d1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01022cb:	85 db                	test   %ebx,%ebx
f01022cd:	74 98                	je     f0102267 <strtol+0x66>
f01022cf:	eb 9e                	jmp    f010226f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01022d1:	89 c2                	mov    %eax,%edx
f01022d3:	f7 da                	neg    %edx
f01022d5:	85 ff                	test   %edi,%edi
f01022d7:	0f 45 c2             	cmovne %edx,%eax
}
f01022da:	5b                   	pop    %ebx
f01022db:	5e                   	pop    %esi
f01022dc:	5f                   	pop    %edi
f01022dd:	5d                   	pop    %ebp
f01022de:	c3                   	ret    
f01022df:	90                   	nop

f01022e0 <__udivdi3>:
f01022e0:	55                   	push   %ebp
f01022e1:	57                   	push   %edi
f01022e2:	56                   	push   %esi
f01022e3:	53                   	push   %ebx
f01022e4:	83 ec 1c             	sub    $0x1c,%esp
f01022e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01022eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01022ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01022f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01022f7:	85 f6                	test   %esi,%esi
f01022f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01022fd:	89 ca                	mov    %ecx,%edx
f01022ff:	89 f8                	mov    %edi,%eax
f0102301:	75 3d                	jne    f0102340 <__udivdi3+0x60>
f0102303:	39 cf                	cmp    %ecx,%edi
f0102305:	0f 87 c5 00 00 00    	ja     f01023d0 <__udivdi3+0xf0>
f010230b:	85 ff                	test   %edi,%edi
f010230d:	89 fd                	mov    %edi,%ebp
f010230f:	75 0b                	jne    f010231c <__udivdi3+0x3c>
f0102311:	b8 01 00 00 00       	mov    $0x1,%eax
f0102316:	31 d2                	xor    %edx,%edx
f0102318:	f7 f7                	div    %edi
f010231a:	89 c5                	mov    %eax,%ebp
f010231c:	89 c8                	mov    %ecx,%eax
f010231e:	31 d2                	xor    %edx,%edx
f0102320:	f7 f5                	div    %ebp
f0102322:	89 c1                	mov    %eax,%ecx
f0102324:	89 d8                	mov    %ebx,%eax
f0102326:	89 cf                	mov    %ecx,%edi
f0102328:	f7 f5                	div    %ebp
f010232a:	89 c3                	mov    %eax,%ebx
f010232c:	89 d8                	mov    %ebx,%eax
f010232e:	89 fa                	mov    %edi,%edx
f0102330:	83 c4 1c             	add    $0x1c,%esp
f0102333:	5b                   	pop    %ebx
f0102334:	5e                   	pop    %esi
f0102335:	5f                   	pop    %edi
f0102336:	5d                   	pop    %ebp
f0102337:	c3                   	ret    
f0102338:	90                   	nop
f0102339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0102340:	39 ce                	cmp    %ecx,%esi
f0102342:	77 74                	ja     f01023b8 <__udivdi3+0xd8>
f0102344:	0f bd fe             	bsr    %esi,%edi
f0102347:	83 f7 1f             	xor    $0x1f,%edi
f010234a:	0f 84 98 00 00 00    	je     f01023e8 <__udivdi3+0x108>
f0102350:	bb 20 00 00 00       	mov    $0x20,%ebx
f0102355:	89 f9                	mov    %edi,%ecx
f0102357:	89 c5                	mov    %eax,%ebp
f0102359:	29 fb                	sub    %edi,%ebx
f010235b:	d3 e6                	shl    %cl,%esi
f010235d:	89 d9                	mov    %ebx,%ecx
f010235f:	d3 ed                	shr    %cl,%ebp
f0102361:	89 f9                	mov    %edi,%ecx
f0102363:	d3 e0                	shl    %cl,%eax
f0102365:	09 ee                	or     %ebp,%esi
f0102367:	89 d9                	mov    %ebx,%ecx
f0102369:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010236d:	89 d5                	mov    %edx,%ebp
f010236f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102373:	d3 ed                	shr    %cl,%ebp
f0102375:	89 f9                	mov    %edi,%ecx
f0102377:	d3 e2                	shl    %cl,%edx
f0102379:	89 d9                	mov    %ebx,%ecx
f010237b:	d3 e8                	shr    %cl,%eax
f010237d:	09 c2                	or     %eax,%edx
f010237f:	89 d0                	mov    %edx,%eax
f0102381:	89 ea                	mov    %ebp,%edx
f0102383:	f7 f6                	div    %esi
f0102385:	89 d5                	mov    %edx,%ebp
f0102387:	89 c3                	mov    %eax,%ebx
f0102389:	f7 64 24 0c          	mull   0xc(%esp)
f010238d:	39 d5                	cmp    %edx,%ebp
f010238f:	72 10                	jb     f01023a1 <__udivdi3+0xc1>
f0102391:	8b 74 24 08          	mov    0x8(%esp),%esi
f0102395:	89 f9                	mov    %edi,%ecx
f0102397:	d3 e6                	shl    %cl,%esi
f0102399:	39 c6                	cmp    %eax,%esi
f010239b:	73 07                	jae    f01023a4 <__udivdi3+0xc4>
f010239d:	39 d5                	cmp    %edx,%ebp
f010239f:	75 03                	jne    f01023a4 <__udivdi3+0xc4>
f01023a1:	83 eb 01             	sub    $0x1,%ebx
f01023a4:	31 ff                	xor    %edi,%edi
f01023a6:	89 d8                	mov    %ebx,%eax
f01023a8:	89 fa                	mov    %edi,%edx
f01023aa:	83 c4 1c             	add    $0x1c,%esp
f01023ad:	5b                   	pop    %ebx
f01023ae:	5e                   	pop    %esi
f01023af:	5f                   	pop    %edi
f01023b0:	5d                   	pop    %ebp
f01023b1:	c3                   	ret    
f01023b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01023b8:	31 ff                	xor    %edi,%edi
f01023ba:	31 db                	xor    %ebx,%ebx
f01023bc:	89 d8                	mov    %ebx,%eax
f01023be:	89 fa                	mov    %edi,%edx
f01023c0:	83 c4 1c             	add    $0x1c,%esp
f01023c3:	5b                   	pop    %ebx
f01023c4:	5e                   	pop    %esi
f01023c5:	5f                   	pop    %edi
f01023c6:	5d                   	pop    %ebp
f01023c7:	c3                   	ret    
f01023c8:	90                   	nop
f01023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01023d0:	89 d8                	mov    %ebx,%eax
f01023d2:	f7 f7                	div    %edi
f01023d4:	31 ff                	xor    %edi,%edi
f01023d6:	89 c3                	mov    %eax,%ebx
f01023d8:	89 d8                	mov    %ebx,%eax
f01023da:	89 fa                	mov    %edi,%edx
f01023dc:	83 c4 1c             	add    $0x1c,%esp
f01023df:	5b                   	pop    %ebx
f01023e0:	5e                   	pop    %esi
f01023e1:	5f                   	pop    %edi
f01023e2:	5d                   	pop    %ebp
f01023e3:	c3                   	ret    
f01023e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01023e8:	39 ce                	cmp    %ecx,%esi
f01023ea:	72 0c                	jb     f01023f8 <__udivdi3+0x118>
f01023ec:	31 db                	xor    %ebx,%ebx
f01023ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01023f2:	0f 87 34 ff ff ff    	ja     f010232c <__udivdi3+0x4c>
f01023f8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01023fd:	e9 2a ff ff ff       	jmp    f010232c <__udivdi3+0x4c>
f0102402:	66 90                	xchg   %ax,%ax
f0102404:	66 90                	xchg   %ax,%ax
f0102406:	66 90                	xchg   %ax,%ax
f0102408:	66 90                	xchg   %ax,%ax
f010240a:	66 90                	xchg   %ax,%ax
f010240c:	66 90                	xchg   %ax,%ax
f010240e:	66 90                	xchg   %ax,%ax

f0102410 <__umoddi3>:
f0102410:	55                   	push   %ebp
f0102411:	57                   	push   %edi
f0102412:	56                   	push   %esi
f0102413:	53                   	push   %ebx
f0102414:	83 ec 1c             	sub    $0x1c,%esp
f0102417:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010241b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010241f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0102423:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0102427:	85 d2                	test   %edx,%edx
f0102429:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010242d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102431:	89 f3                	mov    %esi,%ebx
f0102433:	89 3c 24             	mov    %edi,(%esp)
f0102436:	89 74 24 04          	mov    %esi,0x4(%esp)
f010243a:	75 1c                	jne    f0102458 <__umoddi3+0x48>
f010243c:	39 f7                	cmp    %esi,%edi
f010243e:	76 50                	jbe    f0102490 <__umoddi3+0x80>
f0102440:	89 c8                	mov    %ecx,%eax
f0102442:	89 f2                	mov    %esi,%edx
f0102444:	f7 f7                	div    %edi
f0102446:	89 d0                	mov    %edx,%eax
f0102448:	31 d2                	xor    %edx,%edx
f010244a:	83 c4 1c             	add    $0x1c,%esp
f010244d:	5b                   	pop    %ebx
f010244e:	5e                   	pop    %esi
f010244f:	5f                   	pop    %edi
f0102450:	5d                   	pop    %ebp
f0102451:	c3                   	ret    
f0102452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102458:	39 f2                	cmp    %esi,%edx
f010245a:	89 d0                	mov    %edx,%eax
f010245c:	77 52                	ja     f01024b0 <__umoddi3+0xa0>
f010245e:	0f bd ea             	bsr    %edx,%ebp
f0102461:	83 f5 1f             	xor    $0x1f,%ebp
f0102464:	75 5a                	jne    f01024c0 <__umoddi3+0xb0>
f0102466:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010246a:	0f 82 e0 00 00 00    	jb     f0102550 <__umoddi3+0x140>
f0102470:	39 0c 24             	cmp    %ecx,(%esp)
f0102473:	0f 86 d7 00 00 00    	jbe    f0102550 <__umoddi3+0x140>
f0102479:	8b 44 24 08          	mov    0x8(%esp),%eax
f010247d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0102481:	83 c4 1c             	add    $0x1c,%esp
f0102484:	5b                   	pop    %ebx
f0102485:	5e                   	pop    %esi
f0102486:	5f                   	pop    %edi
f0102487:	5d                   	pop    %ebp
f0102488:	c3                   	ret    
f0102489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0102490:	85 ff                	test   %edi,%edi
f0102492:	89 fd                	mov    %edi,%ebp
f0102494:	75 0b                	jne    f01024a1 <__umoddi3+0x91>
f0102496:	b8 01 00 00 00       	mov    $0x1,%eax
f010249b:	31 d2                	xor    %edx,%edx
f010249d:	f7 f7                	div    %edi
f010249f:	89 c5                	mov    %eax,%ebp
f01024a1:	89 f0                	mov    %esi,%eax
f01024a3:	31 d2                	xor    %edx,%edx
f01024a5:	f7 f5                	div    %ebp
f01024a7:	89 c8                	mov    %ecx,%eax
f01024a9:	f7 f5                	div    %ebp
f01024ab:	89 d0                	mov    %edx,%eax
f01024ad:	eb 99                	jmp    f0102448 <__umoddi3+0x38>
f01024af:	90                   	nop
f01024b0:	89 c8                	mov    %ecx,%eax
f01024b2:	89 f2                	mov    %esi,%edx
f01024b4:	83 c4 1c             	add    $0x1c,%esp
f01024b7:	5b                   	pop    %ebx
f01024b8:	5e                   	pop    %esi
f01024b9:	5f                   	pop    %edi
f01024ba:	5d                   	pop    %ebp
f01024bb:	c3                   	ret    
f01024bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01024c0:	8b 34 24             	mov    (%esp),%esi
f01024c3:	bf 20 00 00 00       	mov    $0x20,%edi
f01024c8:	89 e9                	mov    %ebp,%ecx
f01024ca:	29 ef                	sub    %ebp,%edi
f01024cc:	d3 e0                	shl    %cl,%eax
f01024ce:	89 f9                	mov    %edi,%ecx
f01024d0:	89 f2                	mov    %esi,%edx
f01024d2:	d3 ea                	shr    %cl,%edx
f01024d4:	89 e9                	mov    %ebp,%ecx
f01024d6:	09 c2                	or     %eax,%edx
f01024d8:	89 d8                	mov    %ebx,%eax
f01024da:	89 14 24             	mov    %edx,(%esp)
f01024dd:	89 f2                	mov    %esi,%edx
f01024df:	d3 e2                	shl    %cl,%edx
f01024e1:	89 f9                	mov    %edi,%ecx
f01024e3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01024e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01024eb:	d3 e8                	shr    %cl,%eax
f01024ed:	89 e9                	mov    %ebp,%ecx
f01024ef:	89 c6                	mov    %eax,%esi
f01024f1:	d3 e3                	shl    %cl,%ebx
f01024f3:	89 f9                	mov    %edi,%ecx
f01024f5:	89 d0                	mov    %edx,%eax
f01024f7:	d3 e8                	shr    %cl,%eax
f01024f9:	89 e9                	mov    %ebp,%ecx
f01024fb:	09 d8                	or     %ebx,%eax
f01024fd:	89 d3                	mov    %edx,%ebx
f01024ff:	89 f2                	mov    %esi,%edx
f0102501:	f7 34 24             	divl   (%esp)
f0102504:	89 d6                	mov    %edx,%esi
f0102506:	d3 e3                	shl    %cl,%ebx
f0102508:	f7 64 24 04          	mull   0x4(%esp)
f010250c:	39 d6                	cmp    %edx,%esi
f010250e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102512:	89 d1                	mov    %edx,%ecx
f0102514:	89 c3                	mov    %eax,%ebx
f0102516:	72 08                	jb     f0102520 <__umoddi3+0x110>
f0102518:	75 11                	jne    f010252b <__umoddi3+0x11b>
f010251a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010251e:	73 0b                	jae    f010252b <__umoddi3+0x11b>
f0102520:	2b 44 24 04          	sub    0x4(%esp),%eax
f0102524:	1b 14 24             	sbb    (%esp),%edx
f0102527:	89 d1                	mov    %edx,%ecx
f0102529:	89 c3                	mov    %eax,%ebx
f010252b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010252f:	29 da                	sub    %ebx,%edx
f0102531:	19 ce                	sbb    %ecx,%esi
f0102533:	89 f9                	mov    %edi,%ecx
f0102535:	89 f0                	mov    %esi,%eax
f0102537:	d3 e0                	shl    %cl,%eax
f0102539:	89 e9                	mov    %ebp,%ecx
f010253b:	d3 ea                	shr    %cl,%edx
f010253d:	89 e9                	mov    %ebp,%ecx
f010253f:	d3 ee                	shr    %cl,%esi
f0102541:	09 d0                	or     %edx,%eax
f0102543:	89 f2                	mov    %esi,%edx
f0102545:	83 c4 1c             	add    $0x1c,%esp
f0102548:	5b                   	pop    %ebx
f0102549:	5e                   	pop    %esi
f010254a:	5f                   	pop    %edi
f010254b:	5d                   	pop    %ebp
f010254c:	c3                   	ret    
f010254d:	8d 76 00             	lea    0x0(%esi),%esi
f0102550:	29 f9                	sub    %edi,%ecx
f0102552:	19 d6                	sbb    %edx,%esi
f0102554:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102558:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010255c:	e9 18 ff ff ff       	jmp    f0102479 <__umoddi3+0x69>
