
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
f0100058:	e8 c2 31 00 00       	call   f010321f <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 96 04 00 00       	call   f01004f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 c0 36 10 f0       	push   $0xf01036c0
f010006f:	e8 e7 26 00 00       	call   f010275b <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 b2 10 00 00       	call   f010112b <mem_init>
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
f01000b0:	68 db 36 10 f0       	push   $0xf01036db
f01000b5:	e8 a1 26 00 00       	call   f010275b <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 71 26 00 00       	call   f0102735 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 d0 3e 10 f0 	movl   $0xf0103ed0,(%esp)
f01000cb:	e8 8b 26 00 00       	call   f010275b <cprintf>
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
f01000f2:	68 f3 36 10 f0       	push   $0xf01036f3
f01000f7:	e8 5f 26 00 00       	call   f010275b <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 2d 26 00 00       	call   f0102735 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 d0 3e 10 f0 	movl   $0xf0103ed0,(%esp)
f010010f:	e8 47 26 00 00       	call   f010275b <cprintf>
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
f01001ce:	0f b6 82 60 38 10 f0 	movzbl -0xfefc7a0(%edx),%eax
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
f010020a:	0f b6 82 60 38 10 f0 	movzbl -0xfefc7a0(%edx),%eax
f0100211:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
f0100217:	0f b6 8a 60 37 10 f0 	movzbl -0xfefc8a0(%edx),%ecx
f010021e:	31 c8                	xor    %ecx,%eax
f0100220:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100225:	89 c1                	mov    %eax,%ecx
f0100227:	83 e1 03             	and    $0x3,%ecx
f010022a:	8b 0c 8d 40 37 10 f0 	mov    -0xfefc8c0(,%ecx,4),%ecx
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
f0100268:	68 0d 37 10 f0       	push   $0xf010370d
f010026d:	e8 e9 24 00 00       	call   f010275b <cprintf>
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
f010041c:	e8 4b 2e 00 00       	call   f010326c <memmove>
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
f01005eb:	68 19 37 10 f0       	push   $0xf0103719
f01005f0:	e8 66 21 00 00       	call   f010275b <cprintf>
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
f0100631:	68 60 39 10 f0       	push   $0xf0103960
f0100636:	68 7e 39 10 f0       	push   $0xf010397e
f010063b:	68 83 39 10 f0       	push   $0xf0103983
f0100640:	e8 16 21 00 00       	call   f010275b <cprintf>
f0100645:	83 c4 0c             	add    $0xc,%esp
f0100648:	68 3c 3a 10 f0       	push   $0xf0103a3c
f010064d:	68 8c 39 10 f0       	push   $0xf010398c
f0100652:	68 83 39 10 f0       	push   $0xf0103983
f0100657:	e8 ff 20 00 00       	call   f010275b <cprintf>
f010065c:	83 c4 0c             	add    $0xc,%esp
f010065f:	68 95 39 10 f0       	push   $0xf0103995
f0100664:	68 b3 39 10 f0       	push   $0xf01039b3
f0100669:	68 83 39 10 f0       	push   $0xf0103983
f010066e:	e8 e8 20 00 00       	call   f010275b <cprintf>
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
f0100680:	68 bd 39 10 f0       	push   $0xf01039bd
f0100685:	e8 d1 20 00 00       	call   f010275b <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010068a:	83 c4 08             	add    $0x8,%esp
f010068d:	68 0c 00 10 00       	push   $0x10000c
f0100692:	68 64 3a 10 f0       	push   $0xf0103a64
f0100697:	e8 bf 20 00 00       	call   f010275b <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010069c:	83 c4 0c             	add    $0xc,%esp
f010069f:	68 0c 00 10 00       	push   $0x10000c
f01006a4:	68 0c 00 10 f0       	push   $0xf010000c
f01006a9:	68 8c 3a 10 f0       	push   $0xf0103a8c
f01006ae:	e8 a8 20 00 00       	call   f010275b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b3:	83 c4 0c             	add    $0xc,%esp
f01006b6:	68 b1 36 10 00       	push   $0x1036b1
f01006bb:	68 b1 36 10 f0       	push   $0xf01036b1
f01006c0:	68 b0 3a 10 f0       	push   $0xf0103ab0
f01006c5:	e8 91 20 00 00       	call   f010275b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ca:	83 c4 0c             	add    $0xc,%esp
f01006cd:	68 00 73 11 00       	push   $0x117300
f01006d2:	68 00 73 11 f0       	push   $0xf0117300
f01006d7:	68 d4 3a 10 f0       	push   $0xf0103ad4
f01006dc:	e8 7a 20 00 00       	call   f010275b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e1:	83 c4 0c             	add    $0xc,%esp
f01006e4:	68 60 79 11 00       	push   $0x117960
f01006e9:	68 60 79 11 f0       	push   $0xf0117960
f01006ee:	68 f8 3a 10 f0       	push   $0xf0103af8
f01006f3:	e8 63 20 00 00       	call   f010275b <cprintf>
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
f0100719:	68 1c 3b 10 f0       	push   $0xf0103b1c
f010071e:	e8 38 20 00 00       	call   f010275b <cprintf>
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
f0100758:	68 d6 39 10 f0       	push   $0xf01039d6
f010075d:	e8 f9 1f 00 00       	call   f010275b <cprintf>

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
f010078a:	e8 d6 20 00 00       	call   f0102865 <debuginfo_eip>

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
f01007e6:	68 48 3b 10 f0       	push   $0xf0103b48
f01007eb:	e8 6b 1f 00 00       	call   f010275b <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f01007f0:	83 c4 14             	add    $0x14,%esp
f01007f3:	2b 75 cc             	sub    -0x34(%ebp),%esi
f01007f6:	56                   	push   %esi
f01007f7:	8d 45 8a             	lea    -0x76(%ebp),%eax
f01007fa:	50                   	push   %eax
f01007fb:	ff 75 c0             	pushl  -0x40(%ebp)
f01007fe:	ff 75 bc             	pushl  -0x44(%ebp)
f0100801:	68 e8 39 10 f0       	push   $0xf01039e8
f0100806:	e8 50 1f 00 00       	call   f010275b <cprintf>

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
f010082e:	68 80 3b 10 f0       	push   $0xf0103b80
f0100833:	e8 23 1f 00 00       	call   f010275b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100838:	c7 04 24 a4 3b 10 f0 	movl   $0xf0103ba4,(%esp)
f010083f:	e8 17 1f 00 00       	call   f010275b <cprintf>
f0100844:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100847:	83 ec 0c             	sub    $0xc,%esp
f010084a:	68 ff 39 10 f0       	push   $0xf01039ff
f010084f:	e8 74 27 00 00       	call   f0102fc8 <readline>
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
f0100883:	68 03 3a 10 f0       	push   $0xf0103a03
f0100888:	e8 55 29 00 00       	call   f01031e2 <strchr>
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
f01008a3:	68 08 3a 10 f0       	push   $0xf0103a08
f01008a8:	e8 ae 1e 00 00       	call   f010275b <cprintf>
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
f01008cc:	68 03 3a 10 f0       	push   $0xf0103a03
f01008d1:	e8 0c 29 00 00       	call   f01031e2 <strchr>
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
f01008fa:	ff 34 85 e0 3b 10 f0 	pushl  -0xfefc420(,%eax,4)
f0100901:	ff 75 a8             	pushl  -0x58(%ebp)
f0100904:	e8 7b 28 00 00       	call   f0103184 <strcmp>
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
f010091e:	ff 14 85 e8 3b 10 f0 	call   *-0xfefc418(,%eax,4)


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
f010093f:	68 25 3a 10 f0       	push   $0xf0103a25
f0100944:	e8 12 1e 00 00       	call   f010275b <cprintf>
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
f0100964:	e8 8b 1d 00 00       	call   f01026f4 <mc146818_read>
f0100969:	89 c6                	mov    %eax,%esi
f010096b:	83 c3 01             	add    $0x1,%ebx
f010096e:	89 1c 24             	mov    %ebx,(%esp)
f0100971:	e8 7e 1d 00 00       	call   f01026f4 <mc146818_read>
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
f01009b0:	68 04 3c 10 f0       	push   $0xf0103c04
f01009b5:	6a 6b                	push   $0x6b
f01009b7:	68 1f 3c 10 f0       	push   $0xf0103c1f
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
f01009fa:	68 04 3f 10 f0       	push   $0xf0103f04
f01009ff:	68 59 03 00 00       	push   $0x359
f0100a04:	68 1f 3c 10 f0       	push   $0xf0103c1f
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
f0100a52:	68 28 3f 10 f0       	push   $0xf0103f28
f0100a57:	68 98 02 00 00       	push   $0x298
f0100a5c:	68 1f 3c 10 f0       	push   $0xf0103c1f
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
f0100ae1:	68 04 3f 10 f0       	push   $0xf0103f04
f0100ae6:	6a 52                	push   $0x52
f0100ae8:	68 2b 3c 10 f0       	push   $0xf0103c2b
f0100aed:	e8 99 f5 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100af2:	83 ec 04             	sub    $0x4,%esp
f0100af5:	68 80 00 00 00       	push   $0x80
f0100afa:	68 97 00 00 00       	push   $0x97
f0100aff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b04:	50                   	push   %eax
f0100b05:	e8 15 27 00 00       	call   f010321f <memset>
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
f0100b4b:	68 39 3c 10 f0       	push   $0xf0103c39
f0100b50:	68 45 3c 10 f0       	push   $0xf0103c45
f0100b55:	68 b2 02 00 00       	push   $0x2b2
f0100b5a:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0100b5f:	e8 27 f5 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100b64:	39 fa                	cmp    %edi,%edx
f0100b66:	72 19                	jb     f0100b81 <check_page_free_list+0x148>
f0100b68:	68 5a 3c 10 f0       	push   $0xf0103c5a
f0100b6d:	68 45 3c 10 f0       	push   $0xf0103c45
f0100b72:	68 b3 02 00 00       	push   $0x2b3
f0100b77:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0100b7c:	e8 0a f5 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b81:	89 d0                	mov    %edx,%eax
f0100b83:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b86:	a8 07                	test   $0x7,%al
f0100b88:	74 19                	je     f0100ba3 <check_page_free_list+0x16a>
f0100b8a:	68 4c 3f 10 f0       	push   $0xf0103f4c
f0100b8f:	68 45 3c 10 f0       	push   $0xf0103c45
f0100b94:	68 b4 02 00 00       	push   $0x2b4
f0100b99:	68 1f 3c 10 f0       	push   $0xf0103c1f
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
f0100bad:	68 6e 3c 10 f0       	push   $0xf0103c6e
f0100bb2:	68 45 3c 10 f0       	push   $0xf0103c45
f0100bb7:	68 b7 02 00 00       	push   $0x2b7
f0100bbc:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0100bc1:	e8 c5 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bc6:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bcb:	75 19                	jne    f0100be6 <check_page_free_list+0x1ad>
f0100bcd:	68 7f 3c 10 f0       	push   $0xf0103c7f
f0100bd2:	68 45 3c 10 f0       	push   $0xf0103c45
f0100bd7:	68 b8 02 00 00       	push   $0x2b8
f0100bdc:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0100be1:	e8 a5 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100be6:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100beb:	75 19                	jne    f0100c06 <check_page_free_list+0x1cd>
f0100bed:	68 80 3f 10 f0       	push   $0xf0103f80
f0100bf2:	68 45 3c 10 f0       	push   $0xf0103c45
f0100bf7:	68 b9 02 00 00       	push   $0x2b9
f0100bfc:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0100c01:	e8 85 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c06:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c0b:	75 19                	jne    f0100c26 <check_page_free_list+0x1ed>
f0100c0d:	68 98 3c 10 f0       	push   $0xf0103c98
f0100c12:	68 45 3c 10 f0       	push   $0xf0103c45
f0100c17:	68 ba 02 00 00       	push   $0x2ba
f0100c1c:	68 1f 3c 10 f0       	push   $0xf0103c1f
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
f0100c38:	68 04 3f 10 f0       	push   $0xf0103f04
f0100c3d:	6a 52                	push   $0x52
f0100c3f:	68 2b 3c 10 f0       	push   $0xf0103c2b
f0100c44:	e8 42 f4 ff ff       	call   f010008b <_panic>
f0100c49:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c4e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c51:	76 1e                	jbe    f0100c71 <check_page_free_list+0x238>
f0100c53:	68 a4 3f 10 f0       	push   $0xf0103fa4
f0100c58:	68 45 3c 10 f0       	push   $0xf0103c45
f0100c5d:	68 bb 02 00 00       	push   $0x2bb
f0100c62:	68 1f 3c 10 f0       	push   $0xf0103c1f
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
f0100c86:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100c8b:	68 45 3c 10 f0       	push   $0xf0103c45
f0100c90:	68 c3 02 00 00       	push   $0x2c3
f0100c95:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0100c9a:	e8 ec f3 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100c9f:	85 db                	test   %ebx,%ebx
f0100ca1:	7f 19                	jg     f0100cbc <check_page_free_list+0x283>
f0100ca3:	68 c4 3c 10 f0       	push   $0xf0103cc4
f0100ca8:	68 45 3c 10 f0       	push   $0xf0103c45
f0100cad:	68 c4 02 00 00       	push   $0x2c4
f0100cb2:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0100cb7:	e8 cf f3 ff ff       	call   f010008b <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100cbc:	83 ec 0c             	sub    $0xc,%esp
f0100cbf:	68 ec 3f 10 f0       	push   $0xf0103fec
f0100cc4:	e8 92 1a 00 00       	call   f010275b <cprintf>
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
f0100e08:	68 10 40 10 f0       	push   $0xf0104010
f0100e0d:	68 2e 01 00 00       	push   $0x12e
f0100e12:	68 1f 3c 10 f0       	push   $0xf0103c1f
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
f0100eb1:	68 04 3f 10 f0       	push   $0xf0103f04
f0100eb6:	6a 52                	push   $0x52
f0100eb8:	68 2b 3c 10 f0       	push   $0xf0103c2b
f0100ebd:	e8 c9 f1 ff ff       	call   f010008b <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f0100ec2:	83 ec 04             	sub    $0x4,%esp
f0100ec5:	68 00 10 00 00       	push   $0x1000
f0100eca:	6a 00                	push   $0x0
f0100ecc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ed1:	50                   	push   %eax
f0100ed2:	e8 48 23 00 00       	call   f010321f <memset>
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
f0100efe:	68 34 40 10 f0       	push   $0xf0104034
f0100f03:	68 73 01 00 00       	push   $0x173
f0100f08:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0100f0d:	e8 79 f1 ff ff       	call   f010008b <_panic>
	if (pp->pp_ref != 0)
f0100f12:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f17:	74 17                	je     f0100f30 <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0100f19:	83 ec 04             	sub    $0x4,%esp
f0100f1c:	68 5c 40 10 f0       	push   $0xf010405c
f0100f21:	68 75 01 00 00       	push   $0x175
f0100f26:	68 1f 3c 10 f0       	push   $0xf0103c1f
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
f0100fcc:	68 04 3f 10 f0       	push   $0xf0103f04
f0100fd1:	68 c2 01 00 00       	push   $0x1c2
f0100fd6:	68 1f 3c 10 f0       	push   $0xf0103c1f
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

f0100ffc <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100ffc:	55                   	push   %ebp
f0100ffd:	89 e5                	mov    %esp,%ebp
f0100fff:	53                   	push   %ebx
f0101000:	83 ec 08             	sub    $0x8,%esp
f0101003:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in

	// do a page table walk to find real PTE
	pte_t * pte = pgdir_walk(pgdir, va, 0);
f0101006:	6a 00                	push   $0x0
f0101008:	ff 75 0c             	pushl  0xc(%ebp)
f010100b:	ff 75 08             	pushl  0x8(%ebp)
f010100e:	e8 53 ff ff ff       	call   f0100f66 <pgdir_walk>

	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
f0101013:	83 c4 10             	add    $0x10,%esp
f0101016:	85 c0                	test   %eax,%eax
f0101018:	74 37                	je     f0101051 <page_lookup+0x55>
f010101a:	83 38 00             	cmpl   $0x0,(%eax)
f010101d:	74 39                	je     f0101058 <page_lookup+0x5c>
		return NULL;
	
	// store pte
	if (pte_store != 0)
f010101f:	85 db                	test   %ebx,%ebx
f0101021:	74 02                	je     f0101025 <page_lookup+0x29>
		*pte_store = pte;
f0101023:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101025:	8b 00                	mov    (%eax),%eax
f0101027:	c1 e8 0c             	shr    $0xc,%eax
f010102a:	3b 05 68 79 11 f0    	cmp    0xf0117968,%eax
f0101030:	72 14                	jb     f0101046 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101032:	83 ec 04             	sub    $0x4,%esp
f0101035:	68 a0 40 10 f0       	push   $0xf01040a0
f010103a:	6a 4b                	push   $0x4b
f010103c:	68 2b 3c 10 f0       	push   $0xf0103c2b
f0101041:	e8 45 f0 ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0101046:	8b 15 70 79 11 f0    	mov    0xf0117970,%edx
f010104c:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte)) ;
f010104f:	eb 0c                	jmp    f010105d <page_lookup+0x61>
	// cprintf("[?] In page_lookup\n");
	// cprintf("[?] %x\n", pte);

	// if not present, return NULL
	if (pte == 0 || *pte == 0)
		return NULL;
f0101051:	b8 00 00 00 00       	mov    $0x0,%eax
f0101056:	eb 05                	jmp    f010105d <page_lookup+0x61>
f0101058:	b8 00 00 00 00       	mov    $0x0,%eax
	// store pte
	if (pte_store != 0)
		*pte_store = pte;

	return pa2page(PTE_ADDR(*pte)) ;
}
f010105d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101060:	c9                   	leave  
f0101061:	c3                   	ret    

f0101062 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101062:	55                   	push   %ebp
f0101063:	89 e5                	mov    %esp,%ebp
f0101065:	53                   	push   %ebx
f0101066:	83 ec 18             	sub    $0x18,%esp
f0101069:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	// pte_t *tmp;
	pte_t *pte_store = NULL;
f010106c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * pp = page_lookup(pgdir, va, &pte_store);
f0101073:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101076:	50                   	push   %eax
f0101077:	53                   	push   %ebx
f0101078:	ff 75 08             	pushl  0x8(%ebp)
f010107b:	e8 7c ff ff ff       	call   f0100ffc <page_lookup>

	// if not present, silently return
	if (pp == NULL)
f0101080:	83 c4 10             	add    $0x10,%esp
f0101083:	85 c0                	test   %eax,%eax
f0101085:	74 18                	je     f010109f <page_remove+0x3d>
		return;

	// decrement ref count, and if reaches 0, free it
	page_decref(pp);
f0101087:	83 ec 0c             	sub    $0xc,%esp
f010108a:	50                   	push   %eax
f010108b:	e8 af fe ff ff       	call   f0100f3f <page_decref>

	// null the real PTE pointer 
	*pte_store = 0;
f0101090:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101093:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101099:	0f 01 3b             	invlpg (%ebx)
f010109c:	83 c4 10             	add    $0x10,%esp
	// cprintf("[?] *pte_store:%x, **pte_store:%x\n", *pte_store, **pte_store);

	// tlb invalidate
	tlb_invalidate(pgdir, va);

}
f010109f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010a2:	c9                   	leave  
f01010a3:	c3                   	ret    

f01010a4 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01010a4:	55                   	push   %ebp
f01010a5:	89 e5                	mov    %esp,%ebp
f01010a7:	57                   	push   %edi
f01010a8:	56                   	push   %esi
f01010a9:	53                   	push   %ebx
f01010aa:	83 ec 10             	sub    $0x10,%esp
f01010ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010b0:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	
f01010b3:	6a 01                	push   $0x1
f01010b5:	57                   	push   %edi
f01010b6:	ff 75 08             	pushl  0x8(%ebp)
f01010b9:	e8 a8 fe ff ff       	call   f0100f66 <pgdir_walk>

	if (pte == 0)
f01010be:	83 c4 10             	add    $0x10,%esp
f01010c1:	85 c0                	test   %eax,%eax
f01010c3:	74 59                	je     f010111e <page_insert+0x7a>
f01010c5:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;

	// already have a page
	// remove it and invalidate tlb
	if (*pte != 0) {
f01010c7:	8b 00                	mov    (%eax),%eax
f01010c9:	85 c0                	test   %eax,%eax
f01010cb:	74 2d                	je     f01010fa <page_insert+0x56>
		// corner case
		if (page2pa(pp) == PTE_ADDR(*pte))
f01010cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01010d2:	89 da                	mov    %ebx,%edx
f01010d4:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f01010da:	c1 fa 03             	sar    $0x3,%edx
f01010dd:	c1 e2 0c             	shl    $0xc,%edx
f01010e0:	39 d0                	cmp    %edx,%eax
f01010e2:	75 07                	jne    f01010eb <page_insert+0x47>
			pp->pp_ref--;	// keep pp_ref consistent, in the meantime change perm potentially.
f01010e4:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01010e9:	eb 0f                	jmp    f01010fa <page_insert+0x56>
		else
			page_remove(pgdir, va);
f01010eb:	83 ec 08             	sub    $0x8,%esp
f01010ee:	57                   	push   %edi
f01010ef:	ff 75 08             	pushl  0x8(%ebp)
f01010f2:	e8 6b ff ff ff       	call   f0101062 <page_remove>
f01010f7:	83 c4 10             	add    $0x10,%esp

	// set the real PTE to pa, zero out least 12 bits
	*pte = PTE_ADDR(page2pa(pp));
	
	// set flags
	*pte |= (perm | PTE_P);
f01010fa:	89 d8                	mov    %ebx,%eax
f01010fc:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0101102:	c1 f8 03             	sar    $0x3,%eax
f0101105:	c1 e0 0c             	shl    $0xc,%eax
f0101108:	8b 55 14             	mov    0x14(%ebp),%edx
f010110b:	83 ca 01             	or     $0x1,%edx
f010110e:	09 d0                	or     %edx,%eax
f0101110:	89 06                	mov    %eax,(%esi)

	// increment ref cnt
	pp->pp_ref++;
f0101112:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	return 0;
f0101117:	b8 00 00 00 00       	mov    $0x0,%eax
f010111c:	eb 05                	jmp    f0101123 <page_insert+0x7f>
	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, va, 1);	

	if (pte == 0)
		return -E_NO_MEM;
f010111e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	// increment ref cnt
	pp->pp_ref++;

	return 0;
}
f0101123:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101126:	5b                   	pop    %ebx
f0101127:	5e                   	pop    %esi
f0101128:	5f                   	pop    %edi
f0101129:	5d                   	pop    %ebp
f010112a:	c3                   	ret    

f010112b <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010112b:	55                   	push   %ebp
f010112c:	89 e5                	mov    %esp,%ebp
f010112e:	57                   	push   %edi
f010112f:	56                   	push   %esi
f0101130:	53                   	push   %ebx
f0101131:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101134:	b8 15 00 00 00       	mov    $0x15,%eax
f0101139:	e8 1b f8 ff ff       	call   f0100959 <nvram_read>
f010113e:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101140:	b8 17 00 00 00       	mov    $0x17,%eax
f0101145:	e8 0f f8 ff ff       	call   f0100959 <nvram_read>
f010114a:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010114c:	b8 34 00 00 00       	mov    $0x34,%eax
f0101151:	e8 03 f8 ff ff       	call   f0100959 <nvram_read>
f0101156:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101159:	85 c0                	test   %eax,%eax
f010115b:	74 07                	je     f0101164 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f010115d:	05 00 40 00 00       	add    $0x4000,%eax
f0101162:	eb 0b                	jmp    f010116f <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0101164:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010116a:	85 f6                	test   %esi,%esi
f010116c:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f010116f:	89 c2                	mov    %eax,%edx
f0101171:	c1 ea 02             	shr    $0x2,%edx
f0101174:	89 15 68 79 11 f0    	mov    %edx,0xf0117968
	npages_basemem = basemem / (PGSIZE / 1024);
f010117a:	89 da                	mov    %ebx,%edx
f010117c:	c1 ea 02             	shr    $0x2,%edx
f010117f:	89 15 40 75 11 f0    	mov    %edx,0xf0117540

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101185:	89 c2                	mov    %eax,%edx
f0101187:	29 da                	sub    %ebx,%edx
f0101189:	52                   	push   %edx
f010118a:	53                   	push   %ebx
f010118b:	50                   	push   %eax
f010118c:	68 c0 40 10 f0       	push   $0xf01040c0
f0101191:	e8 c5 15 00 00       	call   f010275b <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101196:	b8 00 10 00 00       	mov    $0x1000,%eax
f010119b:	e8 e2 f7 ff ff       	call   f0100982 <boot_alloc>
f01011a0:	a3 6c 79 11 f0       	mov    %eax,0xf011796c
	memset(kern_pgdir, 0, PGSIZE);
f01011a5:	83 c4 0c             	add    $0xc,%esp
f01011a8:	68 00 10 00 00       	push   $0x1000
f01011ad:	6a 00                	push   $0x0
f01011af:	50                   	push   %eax
f01011b0:	e8 6a 20 00 00       	call   f010321f <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01011b5:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01011ba:	83 c4 10             	add    $0x10,%esp
f01011bd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011c2:	77 15                	ja     f01011d9 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01011c4:	50                   	push   %eax
f01011c5:	68 10 40 10 f0       	push   $0xf0104010
f01011ca:	68 96 00 00 00       	push   $0x96
f01011cf:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01011d4:	e8 b2 ee ff ff       	call   f010008b <_panic>
f01011d9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01011df:	83 ca 05             	or     $0x5,%edx
f01011e2:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f01011e8:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01011ed:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f01011f4:	89 d8                	mov    %ebx,%eax
f01011f6:	e8 87 f7 ff ff       	call   f0100982 <boot_alloc>
f01011fb:	a3 70 79 11 f0       	mov    %eax,0xf0117970
	memset(pages, 0, n);
f0101200:	83 ec 04             	sub    $0x4,%esp
f0101203:	53                   	push   %ebx
f0101204:	6a 00                	push   $0x0
f0101206:	50                   	push   %eax
f0101207:	e8 13 20 00 00       	call   f010321f <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010120c:	e8 eb fa ff ff       	call   f0100cfc <page_init>

	check_page_free_list(1);
f0101211:	b8 01 00 00 00       	mov    $0x1,%eax
f0101216:	e8 1e f8 ff ff       	call   f0100a39 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010121b:	83 c4 10             	add    $0x10,%esp
f010121e:	83 3d 70 79 11 f0 00 	cmpl   $0x0,0xf0117970
f0101225:	75 17                	jne    f010123e <mem_init+0x113>
		panic("'pages' is a null pointer!");
f0101227:	83 ec 04             	sub    $0x4,%esp
f010122a:	68 d5 3c 10 f0       	push   $0xf0103cd5
f010122f:	68 d7 02 00 00       	push   $0x2d7
f0101234:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101239:	e8 4d ee ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010123e:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101243:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101248:	eb 05                	jmp    f010124f <mem_init+0x124>
		++nfree;
f010124a:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010124d:	8b 00                	mov    (%eax),%eax
f010124f:	85 c0                	test   %eax,%eax
f0101251:	75 f7                	jne    f010124a <mem_init+0x11f>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101253:	83 ec 0c             	sub    $0xc,%esp
f0101256:	6a 00                	push   $0x0
f0101258:	e8 1b fc ff ff       	call   f0100e78 <page_alloc>
f010125d:	89 c7                	mov    %eax,%edi
f010125f:	83 c4 10             	add    $0x10,%esp
f0101262:	85 c0                	test   %eax,%eax
f0101264:	75 19                	jne    f010127f <mem_init+0x154>
f0101266:	68 f0 3c 10 f0       	push   $0xf0103cf0
f010126b:	68 45 3c 10 f0       	push   $0xf0103c45
f0101270:	68 df 02 00 00       	push   $0x2df
f0101275:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010127a:	e8 0c ee ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010127f:	83 ec 0c             	sub    $0xc,%esp
f0101282:	6a 00                	push   $0x0
f0101284:	e8 ef fb ff ff       	call   f0100e78 <page_alloc>
f0101289:	89 c6                	mov    %eax,%esi
f010128b:	83 c4 10             	add    $0x10,%esp
f010128e:	85 c0                	test   %eax,%eax
f0101290:	75 19                	jne    f01012ab <mem_init+0x180>
f0101292:	68 06 3d 10 f0       	push   $0xf0103d06
f0101297:	68 45 3c 10 f0       	push   $0xf0103c45
f010129c:	68 e0 02 00 00       	push   $0x2e0
f01012a1:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01012a6:	e8 e0 ed ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01012ab:	83 ec 0c             	sub    $0xc,%esp
f01012ae:	6a 00                	push   $0x0
f01012b0:	e8 c3 fb ff ff       	call   f0100e78 <page_alloc>
f01012b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01012b8:	83 c4 10             	add    $0x10,%esp
f01012bb:	85 c0                	test   %eax,%eax
f01012bd:	75 19                	jne    f01012d8 <mem_init+0x1ad>
f01012bf:	68 1c 3d 10 f0       	push   $0xf0103d1c
f01012c4:	68 45 3c 10 f0       	push   $0xf0103c45
f01012c9:	68 e1 02 00 00       	push   $0x2e1
f01012ce:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01012d3:	e8 b3 ed ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01012d8:	39 f7                	cmp    %esi,%edi
f01012da:	75 19                	jne    f01012f5 <mem_init+0x1ca>
f01012dc:	68 32 3d 10 f0       	push   $0xf0103d32
f01012e1:	68 45 3c 10 f0       	push   $0xf0103c45
f01012e6:	68 e4 02 00 00       	push   $0x2e4
f01012eb:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01012f0:	e8 96 ed ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012f8:	39 c6                	cmp    %eax,%esi
f01012fa:	74 04                	je     f0101300 <mem_init+0x1d5>
f01012fc:	39 c7                	cmp    %eax,%edi
f01012fe:	75 19                	jne    f0101319 <mem_init+0x1ee>
f0101300:	68 fc 40 10 f0       	push   $0xf01040fc
f0101305:	68 45 3c 10 f0       	push   $0xf0103c45
f010130a:	68 e5 02 00 00       	push   $0x2e5
f010130f:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101314:	e8 72 ed ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101319:	8b 0d 70 79 11 f0    	mov    0xf0117970,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010131f:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f0101325:	c1 e2 0c             	shl    $0xc,%edx
f0101328:	89 f8                	mov    %edi,%eax
f010132a:	29 c8                	sub    %ecx,%eax
f010132c:	c1 f8 03             	sar    $0x3,%eax
f010132f:	c1 e0 0c             	shl    $0xc,%eax
f0101332:	39 d0                	cmp    %edx,%eax
f0101334:	72 19                	jb     f010134f <mem_init+0x224>
f0101336:	68 44 3d 10 f0       	push   $0xf0103d44
f010133b:	68 45 3c 10 f0       	push   $0xf0103c45
f0101340:	68 e6 02 00 00       	push   $0x2e6
f0101345:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010134a:	e8 3c ed ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010134f:	89 f0                	mov    %esi,%eax
f0101351:	29 c8                	sub    %ecx,%eax
f0101353:	c1 f8 03             	sar    $0x3,%eax
f0101356:	c1 e0 0c             	shl    $0xc,%eax
f0101359:	39 c2                	cmp    %eax,%edx
f010135b:	77 19                	ja     f0101376 <mem_init+0x24b>
f010135d:	68 61 3d 10 f0       	push   $0xf0103d61
f0101362:	68 45 3c 10 f0       	push   $0xf0103c45
f0101367:	68 e7 02 00 00       	push   $0x2e7
f010136c:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101371:	e8 15 ed ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101376:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101379:	29 c8                	sub    %ecx,%eax
f010137b:	c1 f8 03             	sar    $0x3,%eax
f010137e:	c1 e0 0c             	shl    $0xc,%eax
f0101381:	39 c2                	cmp    %eax,%edx
f0101383:	77 19                	ja     f010139e <mem_init+0x273>
f0101385:	68 7e 3d 10 f0       	push   $0xf0103d7e
f010138a:	68 45 3c 10 f0       	push   $0xf0103c45
f010138f:	68 e8 02 00 00       	push   $0x2e8
f0101394:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101399:	e8 ed ec ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010139e:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01013a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01013a6:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f01013ad:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01013b0:	83 ec 0c             	sub    $0xc,%esp
f01013b3:	6a 00                	push   $0x0
f01013b5:	e8 be fa ff ff       	call   f0100e78 <page_alloc>
f01013ba:	83 c4 10             	add    $0x10,%esp
f01013bd:	85 c0                	test   %eax,%eax
f01013bf:	74 19                	je     f01013da <mem_init+0x2af>
f01013c1:	68 9b 3d 10 f0       	push   $0xf0103d9b
f01013c6:	68 45 3c 10 f0       	push   $0xf0103c45
f01013cb:	68 ef 02 00 00       	push   $0x2ef
f01013d0:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01013d5:	e8 b1 ec ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f01013da:	83 ec 0c             	sub    $0xc,%esp
f01013dd:	57                   	push   %edi
f01013de:	e8 06 fb ff ff       	call   f0100ee9 <page_free>
	page_free(pp1);
f01013e3:	89 34 24             	mov    %esi,(%esp)
f01013e6:	e8 fe fa ff ff       	call   f0100ee9 <page_free>
	page_free(pp2);
f01013eb:	83 c4 04             	add    $0x4,%esp
f01013ee:	ff 75 d4             	pushl  -0x2c(%ebp)
f01013f1:	e8 f3 fa ff ff       	call   f0100ee9 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013fd:	e8 76 fa ff ff       	call   f0100e78 <page_alloc>
f0101402:	89 c6                	mov    %eax,%esi
f0101404:	83 c4 10             	add    $0x10,%esp
f0101407:	85 c0                	test   %eax,%eax
f0101409:	75 19                	jne    f0101424 <mem_init+0x2f9>
f010140b:	68 f0 3c 10 f0       	push   $0xf0103cf0
f0101410:	68 45 3c 10 f0       	push   $0xf0103c45
f0101415:	68 f6 02 00 00       	push   $0x2f6
f010141a:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010141f:	e8 67 ec ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101424:	83 ec 0c             	sub    $0xc,%esp
f0101427:	6a 00                	push   $0x0
f0101429:	e8 4a fa ff ff       	call   f0100e78 <page_alloc>
f010142e:	89 c7                	mov    %eax,%edi
f0101430:	83 c4 10             	add    $0x10,%esp
f0101433:	85 c0                	test   %eax,%eax
f0101435:	75 19                	jne    f0101450 <mem_init+0x325>
f0101437:	68 06 3d 10 f0       	push   $0xf0103d06
f010143c:	68 45 3c 10 f0       	push   $0xf0103c45
f0101441:	68 f7 02 00 00       	push   $0x2f7
f0101446:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010144b:	e8 3b ec ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101450:	83 ec 0c             	sub    $0xc,%esp
f0101453:	6a 00                	push   $0x0
f0101455:	e8 1e fa ff ff       	call   f0100e78 <page_alloc>
f010145a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010145d:	83 c4 10             	add    $0x10,%esp
f0101460:	85 c0                	test   %eax,%eax
f0101462:	75 19                	jne    f010147d <mem_init+0x352>
f0101464:	68 1c 3d 10 f0       	push   $0xf0103d1c
f0101469:	68 45 3c 10 f0       	push   $0xf0103c45
f010146e:	68 f8 02 00 00       	push   $0x2f8
f0101473:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101478:	e8 0e ec ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010147d:	39 fe                	cmp    %edi,%esi
f010147f:	75 19                	jne    f010149a <mem_init+0x36f>
f0101481:	68 32 3d 10 f0       	push   $0xf0103d32
f0101486:	68 45 3c 10 f0       	push   $0xf0103c45
f010148b:	68 fa 02 00 00       	push   $0x2fa
f0101490:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101495:	e8 f1 eb ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010149a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010149d:	39 c7                	cmp    %eax,%edi
f010149f:	74 04                	je     f01014a5 <mem_init+0x37a>
f01014a1:	39 c6                	cmp    %eax,%esi
f01014a3:	75 19                	jne    f01014be <mem_init+0x393>
f01014a5:	68 fc 40 10 f0       	push   $0xf01040fc
f01014aa:	68 45 3c 10 f0       	push   $0xf0103c45
f01014af:	68 fb 02 00 00       	push   $0x2fb
f01014b4:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01014b9:	e8 cd eb ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f01014be:	83 ec 0c             	sub    $0xc,%esp
f01014c1:	6a 00                	push   $0x0
f01014c3:	e8 b0 f9 ff ff       	call   f0100e78 <page_alloc>
f01014c8:	83 c4 10             	add    $0x10,%esp
f01014cb:	85 c0                	test   %eax,%eax
f01014cd:	74 19                	je     f01014e8 <mem_init+0x3bd>
f01014cf:	68 9b 3d 10 f0       	push   $0xf0103d9b
f01014d4:	68 45 3c 10 f0       	push   $0xf0103c45
f01014d9:	68 fc 02 00 00       	push   $0x2fc
f01014de:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01014e3:	e8 a3 eb ff ff       	call   f010008b <_panic>
f01014e8:	89 f0                	mov    %esi,%eax
f01014ea:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01014f0:	c1 f8 03             	sar    $0x3,%eax
f01014f3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014f6:	89 c2                	mov    %eax,%edx
f01014f8:	c1 ea 0c             	shr    $0xc,%edx
f01014fb:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0101501:	72 12                	jb     f0101515 <mem_init+0x3ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101503:	50                   	push   %eax
f0101504:	68 04 3f 10 f0       	push   $0xf0103f04
f0101509:	6a 52                	push   $0x52
f010150b:	68 2b 3c 10 f0       	push   $0xf0103c2b
f0101510:	e8 76 eb ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101515:	83 ec 04             	sub    $0x4,%esp
f0101518:	68 00 10 00 00       	push   $0x1000
f010151d:	6a 01                	push   $0x1
f010151f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101524:	50                   	push   %eax
f0101525:	e8 f5 1c 00 00       	call   f010321f <memset>
	page_free(pp0);
f010152a:	89 34 24             	mov    %esi,(%esp)
f010152d:	e8 b7 f9 ff ff       	call   f0100ee9 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101532:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101539:	e8 3a f9 ff ff       	call   f0100e78 <page_alloc>
f010153e:	83 c4 10             	add    $0x10,%esp
f0101541:	85 c0                	test   %eax,%eax
f0101543:	75 19                	jne    f010155e <mem_init+0x433>
f0101545:	68 aa 3d 10 f0       	push   $0xf0103daa
f010154a:	68 45 3c 10 f0       	push   $0xf0103c45
f010154f:	68 01 03 00 00       	push   $0x301
f0101554:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101559:	e8 2d eb ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f010155e:	39 c6                	cmp    %eax,%esi
f0101560:	74 19                	je     f010157b <mem_init+0x450>
f0101562:	68 c8 3d 10 f0       	push   $0xf0103dc8
f0101567:	68 45 3c 10 f0       	push   $0xf0103c45
f010156c:	68 02 03 00 00       	push   $0x302
f0101571:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101576:	e8 10 eb ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010157b:	89 f0                	mov    %esi,%eax
f010157d:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0101583:	c1 f8 03             	sar    $0x3,%eax
f0101586:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101589:	89 c2                	mov    %eax,%edx
f010158b:	c1 ea 0c             	shr    $0xc,%edx
f010158e:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0101594:	72 12                	jb     f01015a8 <mem_init+0x47d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101596:	50                   	push   %eax
f0101597:	68 04 3f 10 f0       	push   $0xf0103f04
f010159c:	6a 52                	push   $0x52
f010159e:	68 2b 3c 10 f0       	push   $0xf0103c2b
f01015a3:	e8 e3 ea ff ff       	call   f010008b <_panic>
f01015a8:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01015ae:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
f01015b4:	80 38 00             	cmpb   $0x0,(%eax)
f01015b7:	74 19                	je     f01015d2 <mem_init+0x4a7>
f01015b9:	68 d8 3d 10 f0       	push   $0xf0103dd8
f01015be:	68 45 3c 10 f0       	push   $0xf0103c45
f01015c3:	68 06 03 00 00       	push   $0x306
f01015c8:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01015cd:	e8 b9 ea ff ff       	call   f010008b <_panic>
f01015d2:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
f01015d5:	39 d0                	cmp    %edx,%eax
f01015d7:	75 db                	jne    f01015b4 <mem_init+0x489>
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
	}

	// give free list back
	page_free_list = fl;
f01015d9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015dc:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f01015e1:	83 ec 0c             	sub    $0xc,%esp
f01015e4:	56                   	push   %esi
f01015e5:	e8 ff f8 ff ff       	call   f0100ee9 <page_free>
	page_free(pp1);
f01015ea:	89 3c 24             	mov    %edi,(%esp)
f01015ed:	e8 f7 f8 ff ff       	call   f0100ee9 <page_free>
	page_free(pp2);
f01015f2:	83 c4 04             	add    $0x4,%esp
f01015f5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015f8:	e8 ec f8 ff ff       	call   f0100ee9 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015fd:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101602:	83 c4 10             	add    $0x10,%esp
f0101605:	eb 05                	jmp    f010160c <mem_init+0x4e1>
		--nfree;
f0101607:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010160a:	8b 00                	mov    (%eax),%eax
f010160c:	85 c0                	test   %eax,%eax
f010160e:	75 f7                	jne    f0101607 <mem_init+0x4dc>
		--nfree;
	assert(nfree == 0);
f0101610:	85 db                	test   %ebx,%ebx
f0101612:	74 19                	je     f010162d <mem_init+0x502>
f0101614:	68 e2 3d 10 f0       	push   $0xf0103de2
f0101619:	68 45 3c 10 f0       	push   $0xf0103c45
f010161e:	68 14 03 00 00       	push   $0x314
f0101623:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101628:	e8 5e ea ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010162d:	83 ec 0c             	sub    $0xc,%esp
f0101630:	68 1c 41 10 f0       	push   $0xf010411c
f0101635:	e8 21 11 00 00       	call   f010275b <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010163a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101641:	e8 32 f8 ff ff       	call   f0100e78 <page_alloc>
f0101646:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101649:	83 c4 10             	add    $0x10,%esp
f010164c:	85 c0                	test   %eax,%eax
f010164e:	75 19                	jne    f0101669 <mem_init+0x53e>
f0101650:	68 f0 3c 10 f0       	push   $0xf0103cf0
f0101655:	68 45 3c 10 f0       	push   $0xf0103c45
f010165a:	68 71 03 00 00       	push   $0x371
f010165f:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101664:	e8 22 ea ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101669:	83 ec 0c             	sub    $0xc,%esp
f010166c:	6a 00                	push   $0x0
f010166e:	e8 05 f8 ff ff       	call   f0100e78 <page_alloc>
f0101673:	89 c3                	mov    %eax,%ebx
f0101675:	83 c4 10             	add    $0x10,%esp
f0101678:	85 c0                	test   %eax,%eax
f010167a:	75 19                	jne    f0101695 <mem_init+0x56a>
f010167c:	68 06 3d 10 f0       	push   $0xf0103d06
f0101681:	68 45 3c 10 f0       	push   $0xf0103c45
f0101686:	68 72 03 00 00       	push   $0x372
f010168b:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101690:	e8 f6 e9 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101695:	83 ec 0c             	sub    $0xc,%esp
f0101698:	6a 00                	push   $0x0
f010169a:	e8 d9 f7 ff ff       	call   f0100e78 <page_alloc>
f010169f:	89 c6                	mov    %eax,%esi
f01016a1:	83 c4 10             	add    $0x10,%esp
f01016a4:	85 c0                	test   %eax,%eax
f01016a6:	75 19                	jne    f01016c1 <mem_init+0x596>
f01016a8:	68 1c 3d 10 f0       	push   $0xf0103d1c
f01016ad:	68 45 3c 10 f0       	push   $0xf0103c45
f01016b2:	68 73 03 00 00       	push   $0x373
f01016b7:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01016bc:	e8 ca e9 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016c1:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01016c4:	75 19                	jne    f01016df <mem_init+0x5b4>
f01016c6:	68 32 3d 10 f0       	push   $0xf0103d32
f01016cb:	68 45 3c 10 f0       	push   $0xf0103c45
f01016d0:	68 76 03 00 00       	push   $0x376
f01016d5:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01016da:	e8 ac e9 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016df:	39 c3                	cmp    %eax,%ebx
f01016e1:	74 05                	je     f01016e8 <mem_init+0x5bd>
f01016e3:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01016e6:	75 19                	jne    f0101701 <mem_init+0x5d6>
f01016e8:	68 fc 40 10 f0       	push   $0xf01040fc
f01016ed:	68 45 3c 10 f0       	push   $0xf0103c45
f01016f2:	68 77 03 00 00       	push   $0x377
f01016f7:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01016fc:	e8 8a e9 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101701:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101706:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101709:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0101710:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101713:	83 ec 0c             	sub    $0xc,%esp
f0101716:	6a 00                	push   $0x0
f0101718:	e8 5b f7 ff ff       	call   f0100e78 <page_alloc>
f010171d:	83 c4 10             	add    $0x10,%esp
f0101720:	85 c0                	test   %eax,%eax
f0101722:	74 19                	je     f010173d <mem_init+0x612>
f0101724:	68 9b 3d 10 f0       	push   $0xf0103d9b
f0101729:	68 45 3c 10 f0       	push   $0xf0103c45
f010172e:	68 7e 03 00 00       	push   $0x37e
f0101733:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101738:	e8 4e e9 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010173d:	83 ec 04             	sub    $0x4,%esp
f0101740:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101743:	50                   	push   %eax
f0101744:	6a 00                	push   $0x0
f0101746:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f010174c:	e8 ab f8 ff ff       	call   f0100ffc <page_lookup>
f0101751:	83 c4 10             	add    $0x10,%esp
f0101754:	85 c0                	test   %eax,%eax
f0101756:	74 19                	je     f0101771 <mem_init+0x646>
f0101758:	68 3c 41 10 f0       	push   $0xf010413c
f010175d:	68 45 3c 10 f0       	push   $0xf0103c45
f0101762:	68 81 03 00 00       	push   $0x381
f0101767:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010176c:	e8 1a e9 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101771:	6a 02                	push   $0x2
f0101773:	6a 00                	push   $0x0
f0101775:	53                   	push   %ebx
f0101776:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f010177c:	e8 23 f9 ff ff       	call   f01010a4 <page_insert>
f0101781:	83 c4 10             	add    $0x10,%esp
f0101784:	85 c0                	test   %eax,%eax
f0101786:	78 19                	js     f01017a1 <mem_init+0x676>
f0101788:	68 74 41 10 f0       	push   $0xf0104174
f010178d:	68 45 3c 10 f0       	push   $0xf0103c45
f0101792:	68 84 03 00 00       	push   $0x384
f0101797:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010179c:	e8 ea e8 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01017a1:	83 ec 0c             	sub    $0xc,%esp
f01017a4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017a7:	e8 3d f7 ff ff       	call   f0100ee9 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01017ac:	6a 02                	push   $0x2
f01017ae:	6a 00                	push   $0x0
f01017b0:	53                   	push   %ebx
f01017b1:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01017b7:	e8 e8 f8 ff ff       	call   f01010a4 <page_insert>
f01017bc:	83 c4 20             	add    $0x20,%esp
f01017bf:	85 c0                	test   %eax,%eax
f01017c1:	74 19                	je     f01017dc <mem_init+0x6b1>
f01017c3:	68 a4 41 10 f0       	push   $0xf01041a4
f01017c8:	68 45 3c 10 f0       	push   $0xf0103c45
f01017cd:	68 88 03 00 00       	push   $0x388
f01017d2:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01017d7:	e8 af e8 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01017dc:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017e2:	a1 70 79 11 f0       	mov    0xf0117970,%eax
f01017e7:	89 c1                	mov    %eax,%ecx
f01017e9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01017ec:	8b 17                	mov    (%edi),%edx
f01017ee:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01017f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017f7:	29 c8                	sub    %ecx,%eax
f01017f9:	c1 f8 03             	sar    $0x3,%eax
f01017fc:	c1 e0 0c             	shl    $0xc,%eax
f01017ff:	39 c2                	cmp    %eax,%edx
f0101801:	74 19                	je     f010181c <mem_init+0x6f1>
f0101803:	68 d4 41 10 f0       	push   $0xf01041d4
f0101808:	68 45 3c 10 f0       	push   $0xf0103c45
f010180d:	68 89 03 00 00       	push   $0x389
f0101812:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101817:	e8 6f e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010181c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101821:	89 f8                	mov    %edi,%eax
f0101823:	e8 ad f1 ff ff       	call   f01009d5 <check_va2pa>
f0101828:	89 da                	mov    %ebx,%edx
f010182a:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010182d:	c1 fa 03             	sar    $0x3,%edx
f0101830:	c1 e2 0c             	shl    $0xc,%edx
f0101833:	39 d0                	cmp    %edx,%eax
f0101835:	74 19                	je     f0101850 <mem_init+0x725>
f0101837:	68 fc 41 10 f0       	push   $0xf01041fc
f010183c:	68 45 3c 10 f0       	push   $0xf0103c45
f0101841:	68 8a 03 00 00       	push   $0x38a
f0101846:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010184b:	e8 3b e8 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101850:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101855:	74 19                	je     f0101870 <mem_init+0x745>
f0101857:	68 ed 3d 10 f0       	push   $0xf0103ded
f010185c:	68 45 3c 10 f0       	push   $0xf0103c45
f0101861:	68 8b 03 00 00       	push   $0x38b
f0101866:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010186b:	e8 1b e8 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0101870:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101873:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101878:	74 19                	je     f0101893 <mem_init+0x768>
f010187a:	68 fe 3d 10 f0       	push   $0xf0103dfe
f010187f:	68 45 3c 10 f0       	push   $0xf0103c45
f0101884:	68 8c 03 00 00       	push   $0x38c
f0101889:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010188e:	e8 f8 e7 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101893:	6a 02                	push   $0x2
f0101895:	68 00 10 00 00       	push   $0x1000
f010189a:	56                   	push   %esi
f010189b:	57                   	push   %edi
f010189c:	e8 03 f8 ff ff       	call   f01010a4 <page_insert>
f01018a1:	83 c4 10             	add    $0x10,%esp
f01018a4:	85 c0                	test   %eax,%eax
f01018a6:	74 19                	je     f01018c1 <mem_init+0x796>
f01018a8:	68 2c 42 10 f0       	push   $0xf010422c
f01018ad:	68 45 3c 10 f0       	push   $0xf0103c45
f01018b2:	68 8f 03 00 00       	push   $0x38f
f01018b7:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01018bc:	e8 ca e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018c1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018c6:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f01018cb:	e8 05 f1 ff ff       	call   f01009d5 <check_va2pa>
f01018d0:	89 f2                	mov    %esi,%edx
f01018d2:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f01018d8:	c1 fa 03             	sar    $0x3,%edx
f01018db:	c1 e2 0c             	shl    $0xc,%edx
f01018de:	39 d0                	cmp    %edx,%eax
f01018e0:	74 19                	je     f01018fb <mem_init+0x7d0>
f01018e2:	68 68 42 10 f0       	push   $0xf0104268
f01018e7:	68 45 3c 10 f0       	push   $0xf0103c45
f01018ec:	68 90 03 00 00       	push   $0x390
f01018f1:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01018f6:	e8 90 e7 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01018fb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101900:	74 19                	je     f010191b <mem_init+0x7f0>
f0101902:	68 0f 3e 10 f0       	push   $0xf0103e0f
f0101907:	68 45 3c 10 f0       	push   $0xf0103c45
f010190c:	68 91 03 00 00       	push   $0x391
f0101911:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101916:	e8 70 e7 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010191b:	83 ec 0c             	sub    $0xc,%esp
f010191e:	6a 00                	push   $0x0
f0101920:	e8 53 f5 ff ff       	call   f0100e78 <page_alloc>
f0101925:	83 c4 10             	add    $0x10,%esp
f0101928:	85 c0                	test   %eax,%eax
f010192a:	74 19                	je     f0101945 <mem_init+0x81a>
f010192c:	68 9b 3d 10 f0       	push   $0xf0103d9b
f0101931:	68 45 3c 10 f0       	push   $0xf0103c45
f0101936:	68 94 03 00 00       	push   $0x394
f010193b:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101940:	e8 46 e7 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101945:	6a 02                	push   $0x2
f0101947:	68 00 10 00 00       	push   $0x1000
f010194c:	56                   	push   %esi
f010194d:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101953:	e8 4c f7 ff ff       	call   f01010a4 <page_insert>
f0101958:	83 c4 10             	add    $0x10,%esp
f010195b:	85 c0                	test   %eax,%eax
f010195d:	74 19                	je     f0101978 <mem_init+0x84d>
f010195f:	68 2c 42 10 f0       	push   $0xf010422c
f0101964:	68 45 3c 10 f0       	push   $0xf0103c45
f0101969:	68 97 03 00 00       	push   $0x397
f010196e:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101973:	e8 13 e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101978:	ba 00 10 00 00       	mov    $0x1000,%edx
f010197d:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101982:	e8 4e f0 ff ff       	call   f01009d5 <check_va2pa>
f0101987:	89 f2                	mov    %esi,%edx
f0101989:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f010198f:	c1 fa 03             	sar    $0x3,%edx
f0101992:	c1 e2 0c             	shl    $0xc,%edx
f0101995:	39 d0                	cmp    %edx,%eax
f0101997:	74 19                	je     f01019b2 <mem_init+0x887>
f0101999:	68 68 42 10 f0       	push   $0xf0104268
f010199e:	68 45 3c 10 f0       	push   $0xf0103c45
f01019a3:	68 98 03 00 00       	push   $0x398
f01019a8:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01019ad:	e8 d9 e6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01019b2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019b7:	74 19                	je     f01019d2 <mem_init+0x8a7>
f01019b9:	68 0f 3e 10 f0       	push   $0xf0103e0f
f01019be:	68 45 3c 10 f0       	push   $0xf0103c45
f01019c3:	68 99 03 00 00       	push   $0x399
f01019c8:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01019cd:	e8 b9 e6 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01019d2:	83 ec 0c             	sub    $0xc,%esp
f01019d5:	6a 00                	push   $0x0
f01019d7:	e8 9c f4 ff ff       	call   f0100e78 <page_alloc>
f01019dc:	83 c4 10             	add    $0x10,%esp
f01019df:	85 c0                	test   %eax,%eax
f01019e1:	74 19                	je     f01019fc <mem_init+0x8d1>
f01019e3:	68 9b 3d 10 f0       	push   $0xf0103d9b
f01019e8:	68 45 3c 10 f0       	push   $0xf0103c45
f01019ed:	68 9d 03 00 00       	push   $0x39d
f01019f2:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01019f7:	e8 8f e6 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01019fc:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
f0101a02:	8b 02                	mov    (%edx),%eax
f0101a04:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a09:	89 c1                	mov    %eax,%ecx
f0101a0b:	c1 e9 0c             	shr    $0xc,%ecx
f0101a0e:	3b 0d 68 79 11 f0    	cmp    0xf0117968,%ecx
f0101a14:	72 15                	jb     f0101a2b <mem_init+0x900>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a16:	50                   	push   %eax
f0101a17:	68 04 3f 10 f0       	push   $0xf0103f04
f0101a1c:	68 a0 03 00 00       	push   $0x3a0
f0101a21:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101a26:	e8 60 e6 ff ff       	call   f010008b <_panic>
f0101a2b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a33:	83 ec 04             	sub    $0x4,%esp
f0101a36:	6a 00                	push   $0x0
f0101a38:	68 00 10 00 00       	push   $0x1000
f0101a3d:	52                   	push   %edx
f0101a3e:	e8 23 f5 ff ff       	call   f0100f66 <pgdir_walk>
f0101a43:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a46:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a49:	83 c4 10             	add    $0x10,%esp
f0101a4c:	39 d0                	cmp    %edx,%eax
f0101a4e:	74 19                	je     f0101a69 <mem_init+0x93e>
f0101a50:	68 98 42 10 f0       	push   $0xf0104298
f0101a55:	68 45 3c 10 f0       	push   $0xf0103c45
f0101a5a:	68 a1 03 00 00       	push   $0x3a1
f0101a5f:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101a64:	e8 22 e6 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a69:	6a 06                	push   $0x6
f0101a6b:	68 00 10 00 00       	push   $0x1000
f0101a70:	56                   	push   %esi
f0101a71:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101a77:	e8 28 f6 ff ff       	call   f01010a4 <page_insert>
f0101a7c:	83 c4 10             	add    $0x10,%esp
f0101a7f:	85 c0                	test   %eax,%eax
f0101a81:	74 19                	je     f0101a9c <mem_init+0x971>
f0101a83:	68 d8 42 10 f0       	push   $0xf01042d8
f0101a88:	68 45 3c 10 f0       	push   $0xf0103c45
f0101a8d:	68 a4 03 00 00       	push   $0x3a4
f0101a92:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101a97:	e8 ef e5 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a9c:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101aa2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aa7:	89 f8                	mov    %edi,%eax
f0101aa9:	e8 27 ef ff ff       	call   f01009d5 <check_va2pa>
f0101aae:	89 f2                	mov    %esi,%edx
f0101ab0:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101ab6:	c1 fa 03             	sar    $0x3,%edx
f0101ab9:	c1 e2 0c             	shl    $0xc,%edx
f0101abc:	39 d0                	cmp    %edx,%eax
f0101abe:	74 19                	je     f0101ad9 <mem_init+0x9ae>
f0101ac0:	68 68 42 10 f0       	push   $0xf0104268
f0101ac5:	68 45 3c 10 f0       	push   $0xf0103c45
f0101aca:	68 a5 03 00 00       	push   $0x3a5
f0101acf:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101ad4:	e8 b2 e5 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101ad9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ade:	74 19                	je     f0101af9 <mem_init+0x9ce>
f0101ae0:	68 0f 3e 10 f0       	push   $0xf0103e0f
f0101ae5:	68 45 3c 10 f0       	push   $0xf0103c45
f0101aea:	68 a6 03 00 00       	push   $0x3a6
f0101aef:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101af4:	e8 92 e5 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101af9:	83 ec 04             	sub    $0x4,%esp
f0101afc:	6a 00                	push   $0x0
f0101afe:	68 00 10 00 00       	push   $0x1000
f0101b03:	57                   	push   %edi
f0101b04:	e8 5d f4 ff ff       	call   f0100f66 <pgdir_walk>
f0101b09:	83 c4 10             	add    $0x10,%esp
f0101b0c:	f6 00 04             	testb  $0x4,(%eax)
f0101b0f:	75 19                	jne    f0101b2a <mem_init+0x9ff>
f0101b11:	68 18 43 10 f0       	push   $0xf0104318
f0101b16:	68 45 3c 10 f0       	push   $0xf0103c45
f0101b1b:	68 a7 03 00 00       	push   $0x3a7
f0101b20:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101b25:	e8 61 e5 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101b2a:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101b2f:	f6 00 04             	testb  $0x4,(%eax)
f0101b32:	75 19                	jne    f0101b4d <mem_init+0xa22>
f0101b34:	68 20 3e 10 f0       	push   $0xf0103e20
f0101b39:	68 45 3c 10 f0       	push   $0xf0103c45
f0101b3e:	68 a8 03 00 00       	push   $0x3a8
f0101b43:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101b48:	e8 3e e5 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b4d:	6a 02                	push   $0x2
f0101b4f:	68 00 10 00 00       	push   $0x1000
f0101b54:	56                   	push   %esi
f0101b55:	50                   	push   %eax
f0101b56:	e8 49 f5 ff ff       	call   f01010a4 <page_insert>
f0101b5b:	83 c4 10             	add    $0x10,%esp
f0101b5e:	85 c0                	test   %eax,%eax
f0101b60:	74 19                	je     f0101b7b <mem_init+0xa50>
f0101b62:	68 2c 42 10 f0       	push   $0xf010422c
f0101b67:	68 45 3c 10 f0       	push   $0xf0103c45
f0101b6c:	68 ab 03 00 00       	push   $0x3ab
f0101b71:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101b76:	e8 10 e5 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b7b:	83 ec 04             	sub    $0x4,%esp
f0101b7e:	6a 00                	push   $0x0
f0101b80:	68 00 10 00 00       	push   $0x1000
f0101b85:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101b8b:	e8 d6 f3 ff ff       	call   f0100f66 <pgdir_walk>
f0101b90:	83 c4 10             	add    $0x10,%esp
f0101b93:	f6 00 02             	testb  $0x2,(%eax)
f0101b96:	75 19                	jne    f0101bb1 <mem_init+0xa86>
f0101b98:	68 4c 43 10 f0       	push   $0xf010434c
f0101b9d:	68 45 3c 10 f0       	push   $0xf0103c45
f0101ba2:	68 ac 03 00 00       	push   $0x3ac
f0101ba7:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101bac:	e8 da e4 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bb1:	83 ec 04             	sub    $0x4,%esp
f0101bb4:	6a 00                	push   $0x0
f0101bb6:	68 00 10 00 00       	push   $0x1000
f0101bbb:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101bc1:	e8 a0 f3 ff ff       	call   f0100f66 <pgdir_walk>
f0101bc6:	83 c4 10             	add    $0x10,%esp
f0101bc9:	f6 00 04             	testb  $0x4,(%eax)
f0101bcc:	74 19                	je     f0101be7 <mem_init+0xabc>
f0101bce:	68 80 43 10 f0       	push   $0xf0104380
f0101bd3:	68 45 3c 10 f0       	push   $0xf0103c45
f0101bd8:	68 ad 03 00 00       	push   $0x3ad
f0101bdd:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101be2:	e8 a4 e4 ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101be7:	6a 02                	push   $0x2
f0101be9:	68 00 00 40 00       	push   $0x400000
f0101bee:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bf1:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101bf7:	e8 a8 f4 ff ff       	call   f01010a4 <page_insert>
f0101bfc:	83 c4 10             	add    $0x10,%esp
f0101bff:	85 c0                	test   %eax,%eax
f0101c01:	78 19                	js     f0101c1c <mem_init+0xaf1>
f0101c03:	68 b8 43 10 f0       	push   $0xf01043b8
f0101c08:	68 45 3c 10 f0       	push   $0xf0103c45
f0101c0d:	68 b0 03 00 00       	push   $0x3b0
f0101c12:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101c17:	e8 6f e4 ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c1c:	6a 02                	push   $0x2
f0101c1e:	68 00 10 00 00       	push   $0x1000
f0101c23:	53                   	push   %ebx
f0101c24:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101c2a:	e8 75 f4 ff ff       	call   f01010a4 <page_insert>
f0101c2f:	83 c4 10             	add    $0x10,%esp
f0101c32:	85 c0                	test   %eax,%eax
f0101c34:	74 19                	je     f0101c4f <mem_init+0xb24>
f0101c36:	68 f0 43 10 f0       	push   $0xf01043f0
f0101c3b:	68 45 3c 10 f0       	push   $0xf0103c45
f0101c40:	68 b3 03 00 00       	push   $0x3b3
f0101c45:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101c4a:	e8 3c e4 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c4f:	83 ec 04             	sub    $0x4,%esp
f0101c52:	6a 00                	push   $0x0
f0101c54:	68 00 10 00 00       	push   $0x1000
f0101c59:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101c5f:	e8 02 f3 ff ff       	call   f0100f66 <pgdir_walk>
f0101c64:	83 c4 10             	add    $0x10,%esp
f0101c67:	f6 00 04             	testb  $0x4,(%eax)
f0101c6a:	74 19                	je     f0101c85 <mem_init+0xb5a>
f0101c6c:	68 80 43 10 f0       	push   $0xf0104380
f0101c71:	68 45 3c 10 f0       	push   $0xf0103c45
f0101c76:	68 b4 03 00 00       	push   $0x3b4
f0101c7b:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101c80:	e8 06 e4 ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c85:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101c8b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c90:	89 f8                	mov    %edi,%eax
f0101c92:	e8 3e ed ff ff       	call   f01009d5 <check_va2pa>
f0101c97:	89 c1                	mov    %eax,%ecx
f0101c99:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c9c:	89 d8                	mov    %ebx,%eax
f0101c9e:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0101ca4:	c1 f8 03             	sar    $0x3,%eax
f0101ca7:	c1 e0 0c             	shl    $0xc,%eax
f0101caa:	39 c1                	cmp    %eax,%ecx
f0101cac:	74 19                	je     f0101cc7 <mem_init+0xb9c>
f0101cae:	68 2c 44 10 f0       	push   $0xf010442c
f0101cb3:	68 45 3c 10 f0       	push   $0xf0103c45
f0101cb8:	68 b7 03 00 00       	push   $0x3b7
f0101cbd:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101cc2:	e8 c4 e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cc7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ccc:	89 f8                	mov    %edi,%eax
f0101cce:	e8 02 ed ff ff       	call   f01009d5 <check_va2pa>
f0101cd3:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101cd6:	74 19                	je     f0101cf1 <mem_init+0xbc6>
f0101cd8:	68 58 44 10 f0       	push   $0xf0104458
f0101cdd:	68 45 3c 10 f0       	push   $0xf0103c45
f0101ce2:	68 b8 03 00 00       	push   $0x3b8
f0101ce7:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101cec:	e8 9a e3 ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101cf1:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101cf6:	74 19                	je     f0101d11 <mem_init+0xbe6>
f0101cf8:	68 36 3e 10 f0       	push   $0xf0103e36
f0101cfd:	68 45 3c 10 f0       	push   $0xf0103c45
f0101d02:	68 ba 03 00 00       	push   $0x3ba
f0101d07:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101d0c:	e8 7a e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101d11:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d16:	74 19                	je     f0101d31 <mem_init+0xc06>
f0101d18:	68 47 3e 10 f0       	push   $0xf0103e47
f0101d1d:	68 45 3c 10 f0       	push   $0xf0103c45
f0101d22:	68 bb 03 00 00       	push   $0x3bb
f0101d27:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101d2c:	e8 5a e3 ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d31:	83 ec 0c             	sub    $0xc,%esp
f0101d34:	6a 00                	push   $0x0
f0101d36:	e8 3d f1 ff ff       	call   f0100e78 <page_alloc>
f0101d3b:	83 c4 10             	add    $0x10,%esp
f0101d3e:	85 c0                	test   %eax,%eax
f0101d40:	74 04                	je     f0101d46 <mem_init+0xc1b>
f0101d42:	39 c6                	cmp    %eax,%esi
f0101d44:	74 19                	je     f0101d5f <mem_init+0xc34>
f0101d46:	68 88 44 10 f0       	push   $0xf0104488
f0101d4b:	68 45 3c 10 f0       	push   $0xf0103c45
f0101d50:	68 be 03 00 00       	push   $0x3be
f0101d55:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101d5a:	e8 2c e3 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d5f:	83 ec 08             	sub    $0x8,%esp
f0101d62:	6a 00                	push   $0x0
f0101d64:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101d6a:	e8 f3 f2 ff ff       	call   f0101062 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d6f:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101d75:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d7a:	89 f8                	mov    %edi,%eax
f0101d7c:	e8 54 ec ff ff       	call   f01009d5 <check_va2pa>
f0101d81:	83 c4 10             	add    $0x10,%esp
f0101d84:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d87:	74 19                	je     f0101da2 <mem_init+0xc77>
f0101d89:	68 ac 44 10 f0       	push   $0xf01044ac
f0101d8e:	68 45 3c 10 f0       	push   $0xf0103c45
f0101d93:	68 c2 03 00 00       	push   $0x3c2
f0101d98:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101d9d:	e8 e9 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101da2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101da7:	89 f8                	mov    %edi,%eax
f0101da9:	e8 27 ec ff ff       	call   f01009d5 <check_va2pa>
f0101dae:	89 da                	mov    %ebx,%edx
f0101db0:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101db6:	c1 fa 03             	sar    $0x3,%edx
f0101db9:	c1 e2 0c             	shl    $0xc,%edx
f0101dbc:	39 d0                	cmp    %edx,%eax
f0101dbe:	74 19                	je     f0101dd9 <mem_init+0xcae>
f0101dc0:	68 58 44 10 f0       	push   $0xf0104458
f0101dc5:	68 45 3c 10 f0       	push   $0xf0103c45
f0101dca:	68 c3 03 00 00       	push   $0x3c3
f0101dcf:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101dd4:	e8 b2 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101dd9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101dde:	74 19                	je     f0101df9 <mem_init+0xcce>
f0101de0:	68 ed 3d 10 f0       	push   $0xf0103ded
f0101de5:	68 45 3c 10 f0       	push   $0xf0103c45
f0101dea:	68 c4 03 00 00       	push   $0x3c4
f0101def:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101df4:	e8 92 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101df9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101dfe:	74 19                	je     f0101e19 <mem_init+0xcee>
f0101e00:	68 47 3e 10 f0       	push   $0xf0103e47
f0101e05:	68 45 3c 10 f0       	push   $0xf0103c45
f0101e0a:	68 c5 03 00 00       	push   $0x3c5
f0101e0f:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101e14:	e8 72 e2 ff ff       	call   f010008b <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101e19:	6a 00                	push   $0x0
f0101e1b:	68 00 10 00 00       	push   $0x1000
f0101e20:	53                   	push   %ebx
f0101e21:	57                   	push   %edi
f0101e22:	e8 7d f2 ff ff       	call   f01010a4 <page_insert>
f0101e27:	83 c4 10             	add    $0x10,%esp
f0101e2a:	85 c0                	test   %eax,%eax
f0101e2c:	74 19                	je     f0101e47 <mem_init+0xd1c>
f0101e2e:	68 d0 44 10 f0       	push   $0xf01044d0
f0101e33:	68 45 3c 10 f0       	push   $0xf0103c45
f0101e38:	68 c8 03 00 00       	push   $0x3c8
f0101e3d:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101e42:	e8 44 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f0101e47:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e4c:	75 19                	jne    f0101e67 <mem_init+0xd3c>
f0101e4e:	68 58 3e 10 f0       	push   $0xf0103e58
f0101e53:	68 45 3c 10 f0       	push   $0xf0103c45
f0101e58:	68 c9 03 00 00       	push   $0x3c9
f0101e5d:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101e62:	e8 24 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f0101e67:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101e6a:	74 19                	je     f0101e85 <mem_init+0xd5a>
f0101e6c:	68 64 3e 10 f0       	push   $0xf0103e64
f0101e71:	68 45 3c 10 f0       	push   $0xf0103c45
f0101e76:	68 ca 03 00 00       	push   $0x3ca
f0101e7b:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101e80:	e8 06 e2 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e85:	83 ec 08             	sub    $0x8,%esp
f0101e88:	68 00 10 00 00       	push   $0x1000
f0101e8d:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101e93:	e8 ca f1 ff ff       	call   f0101062 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e98:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101e9e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ea3:	89 f8                	mov    %edi,%eax
f0101ea5:	e8 2b eb ff ff       	call   f01009d5 <check_va2pa>
f0101eaa:	83 c4 10             	add    $0x10,%esp
f0101ead:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101eb0:	74 19                	je     f0101ecb <mem_init+0xda0>
f0101eb2:	68 ac 44 10 f0       	push   $0xf01044ac
f0101eb7:	68 45 3c 10 f0       	push   $0xf0103c45
f0101ebc:	68 ce 03 00 00       	push   $0x3ce
f0101ec1:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101ec6:	e8 c0 e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101ecb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ed0:	89 f8                	mov    %edi,%eax
f0101ed2:	e8 fe ea ff ff       	call   f01009d5 <check_va2pa>
f0101ed7:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101eda:	74 19                	je     f0101ef5 <mem_init+0xdca>
f0101edc:	68 08 45 10 f0       	push   $0xf0104508
f0101ee1:	68 45 3c 10 f0       	push   $0xf0103c45
f0101ee6:	68 cf 03 00 00       	push   $0x3cf
f0101eeb:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101ef0:	e8 96 e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0101ef5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101efa:	74 19                	je     f0101f15 <mem_init+0xdea>
f0101efc:	68 79 3e 10 f0       	push   $0xf0103e79
f0101f01:	68 45 3c 10 f0       	push   $0xf0103c45
f0101f06:	68 d0 03 00 00       	push   $0x3d0
f0101f0b:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101f10:	e8 76 e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101f15:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f1a:	74 19                	je     f0101f35 <mem_init+0xe0a>
f0101f1c:	68 47 3e 10 f0       	push   $0xf0103e47
f0101f21:	68 45 3c 10 f0       	push   $0xf0103c45
f0101f26:	68 d1 03 00 00       	push   $0x3d1
f0101f2b:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101f30:	e8 56 e1 ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f35:	83 ec 0c             	sub    $0xc,%esp
f0101f38:	6a 00                	push   $0x0
f0101f3a:	e8 39 ef ff ff       	call   f0100e78 <page_alloc>
f0101f3f:	83 c4 10             	add    $0x10,%esp
f0101f42:	39 c3                	cmp    %eax,%ebx
f0101f44:	75 04                	jne    f0101f4a <mem_init+0xe1f>
f0101f46:	85 c0                	test   %eax,%eax
f0101f48:	75 19                	jne    f0101f63 <mem_init+0xe38>
f0101f4a:	68 30 45 10 f0       	push   $0xf0104530
f0101f4f:	68 45 3c 10 f0       	push   $0xf0103c45
f0101f54:	68 d4 03 00 00       	push   $0x3d4
f0101f59:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101f5e:	e8 28 e1 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f63:	83 ec 0c             	sub    $0xc,%esp
f0101f66:	6a 00                	push   $0x0
f0101f68:	e8 0b ef ff ff       	call   f0100e78 <page_alloc>
f0101f6d:	83 c4 10             	add    $0x10,%esp
f0101f70:	85 c0                	test   %eax,%eax
f0101f72:	74 19                	je     f0101f8d <mem_init+0xe62>
f0101f74:	68 9b 3d 10 f0       	push   $0xf0103d9b
f0101f79:	68 45 3c 10 f0       	push   $0xf0103c45
f0101f7e:	68 d7 03 00 00       	push   $0x3d7
f0101f83:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101f88:	e8 fe e0 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f8d:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
f0101f93:	8b 11                	mov    (%ecx),%edx
f0101f95:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f9e:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0101fa4:	c1 f8 03             	sar    $0x3,%eax
f0101fa7:	c1 e0 0c             	shl    $0xc,%eax
f0101faa:	39 c2                	cmp    %eax,%edx
f0101fac:	74 19                	je     f0101fc7 <mem_init+0xe9c>
f0101fae:	68 d4 41 10 f0       	push   $0xf01041d4
f0101fb3:	68 45 3c 10 f0       	push   $0xf0103c45
f0101fb8:	68 da 03 00 00       	push   $0x3da
f0101fbd:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101fc2:	e8 c4 e0 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0101fc7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101fcd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fd0:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101fd5:	74 19                	je     f0101ff0 <mem_init+0xec5>
f0101fd7:	68 fe 3d 10 f0       	push   $0xf0103dfe
f0101fdc:	68 45 3c 10 f0       	push   $0xf0103c45
f0101fe1:	68 dc 03 00 00       	push   $0x3dc
f0101fe6:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0101feb:	e8 9b e0 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0101ff0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ff3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101ff9:	83 ec 0c             	sub    $0xc,%esp
f0101ffc:	50                   	push   %eax
f0101ffd:	e8 e7 ee ff ff       	call   f0100ee9 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102002:	83 c4 0c             	add    $0xc,%esp
f0102005:	6a 01                	push   $0x1
f0102007:	68 00 10 40 00       	push   $0x401000
f010200c:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0102012:	e8 4f ef ff ff       	call   f0100f66 <pgdir_walk>
f0102017:	89 c7                	mov    %eax,%edi
f0102019:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010201c:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0102021:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102024:	8b 40 04             	mov    0x4(%eax),%eax
f0102027:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010202c:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f0102032:	89 c2                	mov    %eax,%edx
f0102034:	c1 ea 0c             	shr    $0xc,%edx
f0102037:	83 c4 10             	add    $0x10,%esp
f010203a:	39 ca                	cmp    %ecx,%edx
f010203c:	72 15                	jb     f0102053 <mem_init+0xf28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010203e:	50                   	push   %eax
f010203f:	68 04 3f 10 f0       	push   $0xf0103f04
f0102044:	68 e3 03 00 00       	push   $0x3e3
f0102049:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010204e:	e8 38 e0 ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102053:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102058:	39 c7                	cmp    %eax,%edi
f010205a:	74 19                	je     f0102075 <mem_init+0xf4a>
f010205c:	68 8a 3e 10 f0       	push   $0xf0103e8a
f0102061:	68 45 3c 10 f0       	push   $0xf0103c45
f0102066:	68 e4 03 00 00       	push   $0x3e4
f010206b:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0102070:	e8 16 e0 ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102075:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102078:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010207f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102082:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102088:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f010208e:	c1 f8 03             	sar    $0x3,%eax
f0102091:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102094:	89 c2                	mov    %eax,%edx
f0102096:	c1 ea 0c             	shr    $0xc,%edx
f0102099:	39 d1                	cmp    %edx,%ecx
f010209b:	77 12                	ja     f01020af <mem_init+0xf84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010209d:	50                   	push   %eax
f010209e:	68 04 3f 10 f0       	push   $0xf0103f04
f01020a3:	6a 52                	push   $0x52
f01020a5:	68 2b 3c 10 f0       	push   $0xf0103c2b
f01020aa:	e8 dc df ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020af:	83 ec 04             	sub    $0x4,%esp
f01020b2:	68 00 10 00 00       	push   $0x1000
f01020b7:	68 ff 00 00 00       	push   $0xff
f01020bc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020c1:	50                   	push   %eax
f01020c2:	e8 58 11 00 00       	call   f010321f <memset>
	page_free(pp0);
f01020c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01020ca:	89 3c 24             	mov    %edi,(%esp)
f01020cd:	e8 17 ee ff ff       	call   f0100ee9 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020d2:	83 c4 0c             	add    $0xc,%esp
f01020d5:	6a 01                	push   $0x1
f01020d7:	6a 00                	push   $0x0
f01020d9:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01020df:	e8 82 ee ff ff       	call   f0100f66 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020e4:	89 fa                	mov    %edi,%edx
f01020e6:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f01020ec:	c1 fa 03             	sar    $0x3,%edx
f01020ef:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020f2:	89 d0                	mov    %edx,%eax
f01020f4:	c1 e8 0c             	shr    $0xc,%eax
f01020f7:	83 c4 10             	add    $0x10,%esp
f01020fa:	3b 05 68 79 11 f0    	cmp    0xf0117968,%eax
f0102100:	72 12                	jb     f0102114 <mem_init+0xfe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102102:	52                   	push   %edx
f0102103:	68 04 3f 10 f0       	push   $0xf0103f04
f0102108:	6a 52                	push   $0x52
f010210a:	68 2b 3c 10 f0       	push   $0xf0103c2b
f010210f:	e8 77 df ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0102114:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010211a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010211d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102123:	f6 00 01             	testb  $0x1,(%eax)
f0102126:	74 19                	je     f0102141 <mem_init+0x1016>
f0102128:	68 a2 3e 10 f0       	push   $0xf0103ea2
f010212d:	68 45 3c 10 f0       	push   $0xf0103c45
f0102132:	68 ee 03 00 00       	push   $0x3ee
f0102137:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010213c:	e8 4a df ff ff       	call   f010008b <_panic>
f0102141:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102144:	39 d0                	cmp    %edx,%eax
f0102146:	75 db                	jne    f0102123 <mem_init+0xff8>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102148:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f010214d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102153:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102156:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010215c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010215f:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c

	// free the pages we took
	page_free(pp0);
f0102165:	83 ec 0c             	sub    $0xc,%esp
f0102168:	50                   	push   %eax
f0102169:	e8 7b ed ff ff       	call   f0100ee9 <page_free>
	page_free(pp1);
f010216e:	89 1c 24             	mov    %ebx,(%esp)
f0102171:	e8 73 ed ff ff       	call   f0100ee9 <page_free>
	page_free(pp2);
f0102176:	89 34 24             	mov    %esi,(%esp)
f0102179:	e8 6b ed ff ff       	call   f0100ee9 <page_free>

	cprintf("check_page() succeeded!\n");
f010217e:	c7 04 24 b9 3e 10 f0 	movl   $0xf0103eb9,(%esp)
f0102185:	e8 d1 05 00 00       	call   f010275b <cprintf>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010218a:	8b 35 6c 79 11 f0    	mov    0xf011796c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102190:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102195:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102198:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010219f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021a7:	8b 3d 70 79 11 f0    	mov    0xf0117970,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021ad:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01021b0:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01021b3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01021b8:	eb 55                	jmp    f010220f <mem_init+0x10e4>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021ba:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01021c0:	89 f0                	mov    %esi,%eax
f01021c2:	e8 0e e8 ff ff       	call   f01009d5 <check_va2pa>
f01021c7:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01021ce:	77 15                	ja     f01021e5 <mem_init+0x10ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021d0:	57                   	push   %edi
f01021d1:	68 10 40 10 f0       	push   $0xf0104010
f01021d6:	68 2c 03 00 00       	push   $0x32c
f01021db:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01021e0:	e8 a6 de ff ff       	call   f010008b <_panic>
f01021e5:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f01021ec:	39 d0                	cmp    %edx,%eax
f01021ee:	74 19                	je     f0102209 <mem_init+0x10de>
f01021f0:	68 54 45 10 f0       	push   $0xf0104554
f01021f5:	68 45 3c 10 f0       	push   $0xf0103c45
f01021fa:	68 2c 03 00 00       	push   $0x32c
f01021ff:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0102204:	e8 82 de ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102209:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010220f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102212:	77 a6                	ja     f01021ba <mem_init+0x108f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102214:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102217:	c1 e7 0c             	shl    $0xc,%edi
f010221a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010221f:	eb 30                	jmp    f0102251 <mem_init+0x1126>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102221:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102227:	89 f0                	mov    %esi,%eax
f0102229:	e8 a7 e7 ff ff       	call   f01009d5 <check_va2pa>
f010222e:	39 c3                	cmp    %eax,%ebx
f0102230:	74 19                	je     f010224b <mem_init+0x1120>
f0102232:	68 88 45 10 f0       	push   $0xf0104588
f0102237:	68 45 3c 10 f0       	push   $0xf0103c45
f010223c:	68 31 03 00 00       	push   $0x331
f0102241:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0102246:	e8 40 de ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010224b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102251:	39 fb                	cmp    %edi,%ebx
f0102253:	72 cc                	jb     f0102221 <mem_init+0x10f6>
f0102255:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010225a:	bf 00 d0 10 f0       	mov    $0xf010d000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010225f:	89 da                	mov    %ebx,%edx
f0102261:	89 f0                	mov    %esi,%eax
f0102263:	e8 6d e7 ff ff       	call   f01009d5 <check_va2pa>
f0102268:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f010226e:	77 19                	ja     f0102289 <mem_init+0x115e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102270:	68 00 d0 10 f0       	push   $0xf010d000
f0102275:	68 10 40 10 f0       	push   $0xf0104010
f010227a:	68 35 03 00 00       	push   $0x335
f010227f:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0102284:	e8 02 de ff ff       	call   f010008b <_panic>
f0102289:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f010228f:	39 d0                	cmp    %edx,%eax
f0102291:	74 19                	je     f01022ac <mem_init+0x1181>
f0102293:	68 b0 45 10 f0       	push   $0xf01045b0
f0102298:	68 45 3c 10 f0       	push   $0xf0103c45
f010229d:	68 35 03 00 00       	push   $0x335
f01022a2:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01022a7:	e8 df dd ff ff       	call   f010008b <_panic>
f01022ac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01022b2:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f01022b8:	75 a5                	jne    f010225f <mem_init+0x1134>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01022ba:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01022bf:	89 f0                	mov    %esi,%eax
f01022c1:	e8 0f e7 ff ff       	call   f01009d5 <check_va2pa>
f01022c6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022c9:	74 51                	je     f010231c <mem_init+0x11f1>
f01022cb:	68 f8 45 10 f0       	push   $0xf01045f8
f01022d0:	68 45 3c 10 f0       	push   $0xf0103c45
f01022d5:	68 36 03 00 00       	push   $0x336
f01022da:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01022df:	e8 a7 dd ff ff       	call   f010008b <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01022e4:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01022e9:	72 36                	jb     f0102321 <mem_init+0x11f6>
f01022eb:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01022f0:	76 07                	jbe    f01022f9 <mem_init+0x11ce>
f01022f2:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01022f7:	75 28                	jne    f0102321 <mem_init+0x11f6>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01022f9:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f01022fd:	0f 85 83 00 00 00    	jne    f0102386 <mem_init+0x125b>
f0102303:	68 d2 3e 10 f0       	push   $0xf0103ed2
f0102308:	68 45 3c 10 f0       	push   $0xf0103c45
f010230d:	68 3e 03 00 00       	push   $0x33e
f0102312:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0102317:	e8 6f dd ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010231c:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102321:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102326:	76 3f                	jbe    f0102367 <mem_init+0x123c>
				assert(pgdir[i] & PTE_P);
f0102328:	8b 14 86             	mov    (%esi,%eax,4),%edx
f010232b:	f6 c2 01             	test   $0x1,%dl
f010232e:	75 19                	jne    f0102349 <mem_init+0x121e>
f0102330:	68 d2 3e 10 f0       	push   $0xf0103ed2
f0102335:	68 45 3c 10 f0       	push   $0xf0103c45
f010233a:	68 42 03 00 00       	push   $0x342
f010233f:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0102344:	e8 42 dd ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f0102349:	f6 c2 02             	test   $0x2,%dl
f010234c:	75 38                	jne    f0102386 <mem_init+0x125b>
f010234e:	68 e3 3e 10 f0       	push   $0xf0103ee3
f0102353:	68 45 3c 10 f0       	push   $0xf0103c45
f0102358:	68 43 03 00 00       	push   $0x343
f010235d:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0102362:	e8 24 dd ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f0102367:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f010236b:	74 19                	je     f0102386 <mem_init+0x125b>
f010236d:	68 f4 3e 10 f0       	push   $0xf0103ef4
f0102372:	68 45 3c 10 f0       	push   $0xf0103c45
f0102377:	68 45 03 00 00       	push   $0x345
f010237c:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0102381:	e8 05 dd ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102386:	83 c0 01             	add    $0x1,%eax
f0102389:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010238e:	0f 86 50 ff ff ff    	jbe    f01022e4 <mem_init+0x11b9>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102394:	83 ec 0c             	sub    $0xc,%esp
f0102397:	68 28 46 10 f0       	push   $0xf0104628
f010239c:	e8 ba 03 00 00       	call   f010275b <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01023a1:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01023a6:	83 c4 10             	add    $0x10,%esp
f01023a9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023ae:	77 15                	ja     f01023c5 <mem_init+0x129a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01023b0:	50                   	push   %eax
f01023b1:	68 10 40 10 f0       	push   $0xf0104010
f01023b6:	68 dc 00 00 00       	push   $0xdc
f01023bb:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01023c0:	e8 c6 dc ff ff       	call   f010008b <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01023c5:	05 00 00 00 10       	add    $0x10000000,%eax
f01023ca:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01023cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01023d2:	e8 62 e6 ff ff       	call   f0100a39 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01023d7:	0f 20 c0             	mov    %cr0,%eax
f01023da:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01023dd:	0d 23 00 05 80       	or     $0x80050023,%eax
f01023e2:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01023e5:	83 ec 0c             	sub    $0xc,%esp
f01023e8:	6a 00                	push   $0x0
f01023ea:	e8 89 ea ff ff       	call   f0100e78 <page_alloc>
f01023ef:	89 c3                	mov    %eax,%ebx
f01023f1:	83 c4 10             	add    $0x10,%esp
f01023f4:	85 c0                	test   %eax,%eax
f01023f6:	75 19                	jne    f0102411 <mem_init+0x12e6>
f01023f8:	68 f0 3c 10 f0       	push   $0xf0103cf0
f01023fd:	68 45 3c 10 f0       	push   $0xf0103c45
f0102402:	68 09 04 00 00       	push   $0x409
f0102407:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010240c:	e8 7a dc ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0102411:	83 ec 0c             	sub    $0xc,%esp
f0102414:	6a 00                	push   $0x0
f0102416:	e8 5d ea ff ff       	call   f0100e78 <page_alloc>
f010241b:	89 c7                	mov    %eax,%edi
f010241d:	83 c4 10             	add    $0x10,%esp
f0102420:	85 c0                	test   %eax,%eax
f0102422:	75 19                	jne    f010243d <mem_init+0x1312>
f0102424:	68 06 3d 10 f0       	push   $0xf0103d06
f0102429:	68 45 3c 10 f0       	push   $0xf0103c45
f010242e:	68 0a 04 00 00       	push   $0x40a
f0102433:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0102438:	e8 4e dc ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010243d:	83 ec 0c             	sub    $0xc,%esp
f0102440:	6a 00                	push   $0x0
f0102442:	e8 31 ea ff ff       	call   f0100e78 <page_alloc>
f0102447:	89 c6                	mov    %eax,%esi
f0102449:	83 c4 10             	add    $0x10,%esp
f010244c:	85 c0                	test   %eax,%eax
f010244e:	75 19                	jne    f0102469 <mem_init+0x133e>
f0102450:	68 1c 3d 10 f0       	push   $0xf0103d1c
f0102455:	68 45 3c 10 f0       	push   $0xf0103c45
f010245a:	68 0b 04 00 00       	push   $0x40b
f010245f:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0102464:	e8 22 dc ff ff       	call   f010008b <_panic>
	page_free(pp0);
f0102469:	83 ec 0c             	sub    $0xc,%esp
f010246c:	53                   	push   %ebx
f010246d:	e8 77 ea ff ff       	call   f0100ee9 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102472:	89 f8                	mov    %edi,%eax
f0102474:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f010247a:	c1 f8 03             	sar    $0x3,%eax
f010247d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102480:	89 c2                	mov    %eax,%edx
f0102482:	c1 ea 0c             	shr    $0xc,%edx
f0102485:	83 c4 10             	add    $0x10,%esp
f0102488:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f010248e:	72 12                	jb     f01024a2 <mem_init+0x1377>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102490:	50                   	push   %eax
f0102491:	68 04 3f 10 f0       	push   $0xf0103f04
f0102496:	6a 52                	push   $0x52
f0102498:	68 2b 3c 10 f0       	push   $0xf0103c2b
f010249d:	e8 e9 db ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01024a2:	83 ec 04             	sub    $0x4,%esp
f01024a5:	68 00 10 00 00       	push   $0x1000
f01024aa:	6a 01                	push   $0x1
f01024ac:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024b1:	50                   	push   %eax
f01024b2:	e8 68 0d 00 00       	call   f010321f <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024b7:	89 f0                	mov    %esi,%eax
f01024b9:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01024bf:	c1 f8 03             	sar    $0x3,%eax
f01024c2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024c5:	89 c2                	mov    %eax,%edx
f01024c7:	c1 ea 0c             	shr    $0xc,%edx
f01024ca:	83 c4 10             	add    $0x10,%esp
f01024cd:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f01024d3:	72 12                	jb     f01024e7 <mem_init+0x13bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024d5:	50                   	push   %eax
f01024d6:	68 04 3f 10 f0       	push   $0xf0103f04
f01024db:	6a 52                	push   $0x52
f01024dd:	68 2b 3c 10 f0       	push   $0xf0103c2b
f01024e2:	e8 a4 db ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01024e7:	83 ec 04             	sub    $0x4,%esp
f01024ea:	68 00 10 00 00       	push   $0x1000
f01024ef:	6a 02                	push   $0x2
f01024f1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024f6:	50                   	push   %eax
f01024f7:	e8 23 0d 00 00       	call   f010321f <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01024fc:	6a 02                	push   $0x2
f01024fe:	68 00 10 00 00       	push   $0x1000
f0102503:	57                   	push   %edi
f0102504:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f010250a:	e8 95 eb ff ff       	call   f01010a4 <page_insert>
	assert(pp1->pp_ref == 1);
f010250f:	83 c4 20             	add    $0x20,%esp
f0102512:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102517:	74 19                	je     f0102532 <mem_init+0x1407>
f0102519:	68 ed 3d 10 f0       	push   $0xf0103ded
f010251e:	68 45 3c 10 f0       	push   $0xf0103c45
f0102523:	68 10 04 00 00       	push   $0x410
f0102528:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010252d:	e8 59 db ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102532:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102539:	01 01 01 
f010253c:	74 19                	je     f0102557 <mem_init+0x142c>
f010253e:	68 48 46 10 f0       	push   $0xf0104648
f0102543:	68 45 3c 10 f0       	push   $0xf0103c45
f0102548:	68 11 04 00 00       	push   $0x411
f010254d:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0102552:	e8 34 db ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102557:	6a 02                	push   $0x2
f0102559:	68 00 10 00 00       	push   $0x1000
f010255e:	56                   	push   %esi
f010255f:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0102565:	e8 3a eb ff ff       	call   f01010a4 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010256a:	83 c4 10             	add    $0x10,%esp
f010256d:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102574:	02 02 02 
f0102577:	74 19                	je     f0102592 <mem_init+0x1467>
f0102579:	68 6c 46 10 f0       	push   $0xf010466c
f010257e:	68 45 3c 10 f0       	push   $0xf0103c45
f0102583:	68 13 04 00 00       	push   $0x413
f0102588:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010258d:	e8 f9 da ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102592:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102597:	74 19                	je     f01025b2 <mem_init+0x1487>
f0102599:	68 0f 3e 10 f0       	push   $0xf0103e0f
f010259e:	68 45 3c 10 f0       	push   $0xf0103c45
f01025a3:	68 14 04 00 00       	push   $0x414
f01025a8:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01025ad:	e8 d9 da ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f01025b2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01025b7:	74 19                	je     f01025d2 <mem_init+0x14a7>
f01025b9:	68 79 3e 10 f0       	push   $0xf0103e79
f01025be:	68 45 3c 10 f0       	push   $0xf0103c45
f01025c3:	68 15 04 00 00       	push   $0x415
f01025c8:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01025cd:	e8 b9 da ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01025d2:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01025d9:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025dc:	89 f0                	mov    %esi,%eax
f01025de:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01025e4:	c1 f8 03             	sar    $0x3,%eax
f01025e7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025ea:	89 c2                	mov    %eax,%edx
f01025ec:	c1 ea 0c             	shr    $0xc,%edx
f01025ef:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f01025f5:	72 12                	jb     f0102609 <mem_init+0x14de>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025f7:	50                   	push   %eax
f01025f8:	68 04 3f 10 f0       	push   $0xf0103f04
f01025fd:	6a 52                	push   $0x52
f01025ff:	68 2b 3c 10 f0       	push   $0xf0103c2b
f0102604:	e8 82 da ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102609:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102610:	03 03 03 
f0102613:	74 19                	je     f010262e <mem_init+0x1503>
f0102615:	68 90 46 10 f0       	push   $0xf0104690
f010261a:	68 45 3c 10 f0       	push   $0xf0103c45
f010261f:	68 17 04 00 00       	push   $0x417
f0102624:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0102629:	e8 5d da ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010262e:	83 ec 08             	sub    $0x8,%esp
f0102631:	68 00 10 00 00       	push   $0x1000
f0102636:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f010263c:	e8 21 ea ff ff       	call   f0101062 <page_remove>
	assert(pp2->pp_ref == 0);
f0102641:	83 c4 10             	add    $0x10,%esp
f0102644:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102649:	74 19                	je     f0102664 <mem_init+0x1539>
f010264b:	68 47 3e 10 f0       	push   $0xf0103e47
f0102650:	68 45 3c 10 f0       	push   $0xf0103c45
f0102655:	68 19 04 00 00       	push   $0x419
f010265a:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010265f:	e8 27 da ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102664:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
f010266a:	8b 11                	mov    (%ecx),%edx
f010266c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102672:	89 d8                	mov    %ebx,%eax
f0102674:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f010267a:	c1 f8 03             	sar    $0x3,%eax
f010267d:	c1 e0 0c             	shl    $0xc,%eax
f0102680:	39 c2                	cmp    %eax,%edx
f0102682:	74 19                	je     f010269d <mem_init+0x1572>
f0102684:	68 d4 41 10 f0       	push   $0xf01041d4
f0102689:	68 45 3c 10 f0       	push   $0xf0103c45
f010268e:	68 1c 04 00 00       	push   $0x41c
f0102693:	68 1f 3c 10 f0       	push   $0xf0103c1f
f0102698:	e8 ee d9 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f010269d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01026a3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01026a8:	74 19                	je     f01026c3 <mem_init+0x1598>
f01026aa:	68 fe 3d 10 f0       	push   $0xf0103dfe
f01026af:	68 45 3c 10 f0       	push   $0xf0103c45
f01026b4:	68 1e 04 00 00       	push   $0x41e
f01026b9:	68 1f 3c 10 f0       	push   $0xf0103c1f
f01026be:	e8 c8 d9 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f01026c3:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01026c9:	83 ec 0c             	sub    $0xc,%esp
f01026cc:	53                   	push   %ebx
f01026cd:	e8 17 e8 ff ff       	call   f0100ee9 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01026d2:	c7 04 24 bc 46 10 f0 	movl   $0xf01046bc,(%esp)
f01026d9:	e8 7d 00 00 00       	call   f010275b <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01026de:	83 c4 10             	add    $0x10,%esp
f01026e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01026e4:	5b                   	pop    %ebx
f01026e5:	5e                   	pop    %esi
f01026e6:	5f                   	pop    %edi
f01026e7:	5d                   	pop    %ebp
f01026e8:	c3                   	ret    

f01026e9 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01026e9:	55                   	push   %ebp
f01026ea:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01026ec:	8b 45 0c             	mov    0xc(%ebp),%eax
f01026ef:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01026f2:	5d                   	pop    %ebp
f01026f3:	c3                   	ret    

f01026f4 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01026f4:	55                   	push   %ebp
f01026f5:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01026f7:	ba 70 00 00 00       	mov    $0x70,%edx
f01026fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01026ff:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102700:	ba 71 00 00 00       	mov    $0x71,%edx
f0102705:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102706:	0f b6 c0             	movzbl %al,%eax
}
f0102709:	5d                   	pop    %ebp
f010270a:	c3                   	ret    

f010270b <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010270b:	55                   	push   %ebp
f010270c:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010270e:	ba 70 00 00 00       	mov    $0x70,%edx
f0102713:	8b 45 08             	mov    0x8(%ebp),%eax
f0102716:	ee                   	out    %al,(%dx)
f0102717:	ba 71 00 00 00       	mov    $0x71,%edx
f010271c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010271f:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102720:	5d                   	pop    %ebp
f0102721:	c3                   	ret    

f0102722 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102722:	55                   	push   %ebp
f0102723:	89 e5                	mov    %esp,%ebp
f0102725:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102728:	ff 75 08             	pushl  0x8(%ebp)
f010272b:	e8 d0 de ff ff       	call   f0100600 <cputchar>
	*cnt++;
}
f0102730:	83 c4 10             	add    $0x10,%esp
f0102733:	c9                   	leave  
f0102734:	c3                   	ret    

f0102735 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102735:	55                   	push   %ebp
f0102736:	89 e5                	mov    %esp,%ebp
f0102738:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010273b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102742:	ff 75 0c             	pushl  0xc(%ebp)
f0102745:	ff 75 08             	pushl  0x8(%ebp)
f0102748:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010274b:	50                   	push   %eax
f010274c:	68 22 27 10 f0       	push   $0xf0102722
f0102751:	e8 5d 04 00 00       	call   f0102bb3 <vprintfmt>
	return cnt;
}
f0102756:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102759:	c9                   	leave  
f010275a:	c3                   	ret    

f010275b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010275b:	55                   	push   %ebp
f010275c:	89 e5                	mov    %esp,%ebp
f010275e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102761:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102764:	50                   	push   %eax
f0102765:	ff 75 08             	pushl  0x8(%ebp)
f0102768:	e8 c8 ff ff ff       	call   f0102735 <vcprintf>
	va_end(ap);

	return cnt;
}
f010276d:	c9                   	leave  
f010276e:	c3                   	ret    

f010276f <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010276f:	55                   	push   %ebp
f0102770:	89 e5                	mov    %esp,%ebp
f0102772:	57                   	push   %edi
f0102773:	56                   	push   %esi
f0102774:	53                   	push   %ebx
f0102775:	83 ec 14             	sub    $0x14,%esp
f0102778:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010277b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010277e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102781:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102784:	8b 1a                	mov    (%edx),%ebx
f0102786:	8b 01                	mov    (%ecx),%eax
f0102788:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010278b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102792:	eb 7f                	jmp    f0102813 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0102794:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102797:	01 d8                	add    %ebx,%eax
f0102799:	89 c6                	mov    %eax,%esi
f010279b:	c1 ee 1f             	shr    $0x1f,%esi
f010279e:	01 c6                	add    %eax,%esi
f01027a0:	d1 fe                	sar    %esi
f01027a2:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01027a5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01027a8:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01027ab:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01027ad:	eb 03                	jmp    f01027b2 <stab_binsearch+0x43>
			m--;
f01027af:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01027b2:	39 c3                	cmp    %eax,%ebx
f01027b4:	7f 0d                	jg     f01027c3 <stab_binsearch+0x54>
f01027b6:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01027ba:	83 ea 0c             	sub    $0xc,%edx
f01027bd:	39 f9                	cmp    %edi,%ecx
f01027bf:	75 ee                	jne    f01027af <stab_binsearch+0x40>
f01027c1:	eb 05                	jmp    f01027c8 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01027c3:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01027c6:	eb 4b                	jmp    f0102813 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01027c8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01027cb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01027ce:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01027d2:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01027d5:	76 11                	jbe    f01027e8 <stab_binsearch+0x79>
			*region_left = m;
f01027d7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01027da:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01027dc:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01027df:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01027e6:	eb 2b                	jmp    f0102813 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01027e8:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01027eb:	73 14                	jae    f0102801 <stab_binsearch+0x92>
			*region_right = m - 1;
f01027ed:	83 e8 01             	sub    $0x1,%eax
f01027f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01027f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01027f6:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01027f8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01027ff:	eb 12                	jmp    f0102813 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102801:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102804:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102806:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010280a:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010280c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102813:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102816:	0f 8e 78 ff ff ff    	jle    f0102794 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010281c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102820:	75 0f                	jne    f0102831 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0102822:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102825:	8b 00                	mov    (%eax),%eax
f0102827:	83 e8 01             	sub    $0x1,%eax
f010282a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010282d:	89 06                	mov    %eax,(%esi)
f010282f:	eb 2c                	jmp    f010285d <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102831:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102834:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102836:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102839:	8b 0e                	mov    (%esi),%ecx
f010283b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010283e:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102841:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102844:	eb 03                	jmp    f0102849 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102846:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102849:	39 c8                	cmp    %ecx,%eax
f010284b:	7e 0b                	jle    f0102858 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010284d:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0102851:	83 ea 0c             	sub    $0xc,%edx
f0102854:	39 df                	cmp    %ebx,%edi
f0102856:	75 ee                	jne    f0102846 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102858:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010285b:	89 06                	mov    %eax,(%esi)
	}
}
f010285d:	83 c4 14             	add    $0x14,%esp
f0102860:	5b                   	pop    %ebx
f0102861:	5e                   	pop    %esi
f0102862:	5f                   	pop    %edi
f0102863:	5d                   	pop    %ebp
f0102864:	c3                   	ret    

f0102865 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102865:	55                   	push   %ebp
f0102866:	89 e5                	mov    %esp,%ebp
f0102868:	57                   	push   %edi
f0102869:	56                   	push   %esi
f010286a:	53                   	push   %ebx
f010286b:	83 ec 3c             	sub    $0x3c,%esp
f010286e:	8b 75 08             	mov    0x8(%ebp),%esi
f0102871:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102874:	c7 03 e8 46 10 f0    	movl   $0xf01046e8,(%ebx)
	info->eip_line = 0;
f010287a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102881:	c7 43 08 e8 46 10 f0 	movl   $0xf01046e8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102888:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010288f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102892:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102899:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010289f:	76 11                	jbe    f01028b2 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01028a1:	b8 c1 c0 10 f0       	mov    $0xf010c0c1,%eax
f01028a6:	3d c9 a2 10 f0       	cmp    $0xf010a2c9,%eax
f01028ab:	77 19                	ja     f01028c6 <debuginfo_eip+0x61>
f01028ad:	e9 b5 01 00 00       	jmp    f0102a67 <debuginfo_eip+0x202>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f01028b2:	83 ec 04             	sub    $0x4,%esp
f01028b5:	68 f2 46 10 f0       	push   $0xf01046f2
f01028ba:	6a 7f                	push   $0x7f
f01028bc:	68 ff 46 10 f0       	push   $0xf01046ff
f01028c1:	e8 c5 d7 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01028c6:	80 3d c0 c0 10 f0 00 	cmpb   $0x0,0xf010c0c0
f01028cd:	0f 85 9b 01 00 00    	jne    f0102a6e <debuginfo_eip+0x209>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01028d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01028da:	b8 c8 a2 10 f0       	mov    $0xf010a2c8,%eax
f01028df:	2d 1c 49 10 f0       	sub    $0xf010491c,%eax
f01028e4:	c1 f8 02             	sar    $0x2,%eax
f01028e7:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01028ed:	83 e8 01             	sub    $0x1,%eax
f01028f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01028f3:	83 ec 08             	sub    $0x8,%esp
f01028f6:	56                   	push   %esi
f01028f7:	6a 64                	push   $0x64
f01028f9:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01028fc:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01028ff:	b8 1c 49 10 f0       	mov    $0xf010491c,%eax
f0102904:	e8 66 fe ff ff       	call   f010276f <stab_binsearch>
	if (lfile == 0)
f0102909:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010290c:	83 c4 10             	add    $0x10,%esp
f010290f:	85 c0                	test   %eax,%eax
f0102911:	0f 84 5e 01 00 00    	je     f0102a75 <debuginfo_eip+0x210>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102917:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010291a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010291d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102920:	83 ec 08             	sub    $0x8,%esp
f0102923:	56                   	push   %esi
f0102924:	6a 24                	push   $0x24
f0102926:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102929:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010292c:	b8 1c 49 10 f0       	mov    $0xf010491c,%eax
f0102931:	e8 39 fe ff ff       	call   f010276f <stab_binsearch>

	if (lfun <= rfun) {
f0102936:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102939:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010293c:	83 c4 10             	add    $0x10,%esp
f010293f:	39 d0                	cmp    %edx,%eax
f0102941:	7f 40                	jg     f0102983 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102943:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102946:	c1 e1 02             	shl    $0x2,%ecx
f0102949:	8d b9 1c 49 10 f0    	lea    -0xfefb6e4(%ecx),%edi
f010294f:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102952:	8b b9 1c 49 10 f0    	mov    -0xfefb6e4(%ecx),%edi
f0102958:	b9 c1 c0 10 f0       	mov    $0xf010c0c1,%ecx
f010295d:	81 e9 c9 a2 10 f0    	sub    $0xf010a2c9,%ecx
f0102963:	39 cf                	cmp    %ecx,%edi
f0102965:	73 09                	jae    f0102970 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102967:	81 c7 c9 a2 10 f0    	add    $0xf010a2c9,%edi
f010296d:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102970:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102973:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102976:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102979:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010297b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010297e:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102981:	eb 0f                	jmp    f0102992 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102983:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102986:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102989:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010298c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010298f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102992:	83 ec 08             	sub    $0x8,%esp
f0102995:	6a 3a                	push   $0x3a
f0102997:	ff 73 08             	pushl  0x8(%ebx)
f010299a:	e8 64 08 00 00       	call   f0103203 <strfind>
f010299f:	2b 43 08             	sub    0x8(%ebx),%eax
f01029a2:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01029a5:	83 c4 08             	add    $0x8,%esp
f01029a8:	56                   	push   %esi
f01029a9:	6a 44                	push   $0x44
f01029ab:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01029ae:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01029b1:	b8 1c 49 10 f0       	mov    $0xf010491c,%eax
f01029b6:	e8 b4 fd ff ff       	call   f010276f <stab_binsearch>
	if (lline == 0)
f01029bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029be:	83 c4 10             	add    $0x10,%esp
f01029c1:	85 c0                	test   %eax,%eax
f01029c3:	0f 84 b3 00 00 00    	je     f0102a7c <debuginfo_eip+0x217>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f01029c9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01029cc:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01029cf:	0f b7 14 95 22 49 10 	movzwl -0xfefb6de(,%edx,4),%edx
f01029d6:	f0 
f01029d7:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01029da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01029dd:	89 c2                	mov    %eax,%edx
f01029df:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01029e2:	8d 04 85 1c 49 10 f0 	lea    -0xfefb6e4(,%eax,4),%eax
f01029e9:	eb 06                	jmp    f01029f1 <debuginfo_eip+0x18c>
f01029eb:	83 ea 01             	sub    $0x1,%edx
f01029ee:	83 e8 0c             	sub    $0xc,%eax
f01029f1:	39 d7                	cmp    %edx,%edi
f01029f3:	7f 34                	jg     f0102a29 <debuginfo_eip+0x1c4>
	       && stabs[lline].n_type != N_SOL
f01029f5:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f01029f9:	80 f9 84             	cmp    $0x84,%cl
f01029fc:	74 0b                	je     f0102a09 <debuginfo_eip+0x1a4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01029fe:	80 f9 64             	cmp    $0x64,%cl
f0102a01:	75 e8                	jne    f01029eb <debuginfo_eip+0x186>
f0102a03:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102a07:	74 e2                	je     f01029eb <debuginfo_eip+0x186>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102a09:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102a0c:	8b 14 85 1c 49 10 f0 	mov    -0xfefb6e4(,%eax,4),%edx
f0102a13:	b8 c1 c0 10 f0       	mov    $0xf010c0c1,%eax
f0102a18:	2d c9 a2 10 f0       	sub    $0xf010a2c9,%eax
f0102a1d:	39 c2                	cmp    %eax,%edx
f0102a1f:	73 08                	jae    f0102a29 <debuginfo_eip+0x1c4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102a21:	81 c2 c9 a2 10 f0    	add    $0xf010a2c9,%edx
f0102a27:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102a29:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102a2c:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102a2f:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102a34:	39 f2                	cmp    %esi,%edx
f0102a36:	7d 50                	jge    f0102a88 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
f0102a38:	83 c2 01             	add    $0x1,%edx
f0102a3b:	89 d0                	mov    %edx,%eax
f0102a3d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102a40:	8d 14 95 1c 49 10 f0 	lea    -0xfefb6e4(,%edx,4),%edx
f0102a47:	eb 04                	jmp    f0102a4d <debuginfo_eip+0x1e8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102a49:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102a4d:	39 c6                	cmp    %eax,%esi
f0102a4f:	7e 32                	jle    f0102a83 <debuginfo_eip+0x21e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102a51:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102a55:	83 c0 01             	add    $0x1,%eax
f0102a58:	83 c2 0c             	add    $0xc,%edx
f0102a5b:	80 f9 a0             	cmp    $0xa0,%cl
f0102a5e:	74 e9                	je     f0102a49 <debuginfo_eip+0x1e4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102a60:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a65:	eb 21                	jmp    f0102a88 <debuginfo_eip+0x223>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102a67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a6c:	eb 1a                	jmp    f0102a88 <debuginfo_eip+0x223>
f0102a6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a73:	eb 13                	jmp    f0102a88 <debuginfo_eip+0x223>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102a75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a7a:	eb 0c                	jmp    f0102a88 <debuginfo_eip+0x223>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0102a7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a81:	eb 05                	jmp    f0102a88 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102a83:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102a88:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a8b:	5b                   	pop    %ebx
f0102a8c:	5e                   	pop    %esi
f0102a8d:	5f                   	pop    %edi
f0102a8e:	5d                   	pop    %ebp
f0102a8f:	c3                   	ret    

f0102a90 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102a90:	55                   	push   %ebp
f0102a91:	89 e5                	mov    %esp,%ebp
f0102a93:	57                   	push   %edi
f0102a94:	56                   	push   %esi
f0102a95:	53                   	push   %ebx
f0102a96:	83 ec 1c             	sub    $0x1c,%esp
f0102a99:	89 c7                	mov    %eax,%edi
f0102a9b:	89 d6                	mov    %edx,%esi
f0102a9d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102aa0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102aa3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102aa6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102aa9:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102aac:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ab1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102ab4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102ab7:	39 d3                	cmp    %edx,%ebx
f0102ab9:	72 05                	jb     f0102ac0 <printnum+0x30>
f0102abb:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102abe:	77 45                	ja     f0102b05 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102ac0:	83 ec 0c             	sub    $0xc,%esp
f0102ac3:	ff 75 18             	pushl  0x18(%ebp)
f0102ac6:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ac9:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102acc:	53                   	push   %ebx
f0102acd:	ff 75 10             	pushl  0x10(%ebp)
f0102ad0:	83 ec 08             	sub    $0x8,%esp
f0102ad3:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102ad6:	ff 75 e0             	pushl  -0x20(%ebp)
f0102ad9:	ff 75 dc             	pushl  -0x24(%ebp)
f0102adc:	ff 75 d8             	pushl  -0x28(%ebp)
f0102adf:	e8 4c 09 00 00       	call   f0103430 <__udivdi3>
f0102ae4:	83 c4 18             	add    $0x18,%esp
f0102ae7:	52                   	push   %edx
f0102ae8:	50                   	push   %eax
f0102ae9:	89 f2                	mov    %esi,%edx
f0102aeb:	89 f8                	mov    %edi,%eax
f0102aed:	e8 9e ff ff ff       	call   f0102a90 <printnum>
f0102af2:	83 c4 20             	add    $0x20,%esp
f0102af5:	eb 18                	jmp    f0102b0f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102af7:	83 ec 08             	sub    $0x8,%esp
f0102afa:	56                   	push   %esi
f0102afb:	ff 75 18             	pushl  0x18(%ebp)
f0102afe:	ff d7                	call   *%edi
f0102b00:	83 c4 10             	add    $0x10,%esp
f0102b03:	eb 03                	jmp    f0102b08 <printnum+0x78>
f0102b05:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102b08:	83 eb 01             	sub    $0x1,%ebx
f0102b0b:	85 db                	test   %ebx,%ebx
f0102b0d:	7f e8                	jg     f0102af7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102b0f:	83 ec 08             	sub    $0x8,%esp
f0102b12:	56                   	push   %esi
f0102b13:	83 ec 04             	sub    $0x4,%esp
f0102b16:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b19:	ff 75 e0             	pushl  -0x20(%ebp)
f0102b1c:	ff 75 dc             	pushl  -0x24(%ebp)
f0102b1f:	ff 75 d8             	pushl  -0x28(%ebp)
f0102b22:	e8 39 0a 00 00       	call   f0103560 <__umoddi3>
f0102b27:	83 c4 14             	add    $0x14,%esp
f0102b2a:	0f be 80 0d 47 10 f0 	movsbl -0xfefb8f3(%eax),%eax
f0102b31:	50                   	push   %eax
f0102b32:	ff d7                	call   *%edi
}
f0102b34:	83 c4 10             	add    $0x10,%esp
f0102b37:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b3a:	5b                   	pop    %ebx
f0102b3b:	5e                   	pop    %esi
f0102b3c:	5f                   	pop    %edi
f0102b3d:	5d                   	pop    %ebp
f0102b3e:	c3                   	ret    

f0102b3f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102b3f:	55                   	push   %ebp
f0102b40:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102b42:	83 fa 01             	cmp    $0x1,%edx
f0102b45:	7e 0e                	jle    f0102b55 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102b47:	8b 10                	mov    (%eax),%edx
f0102b49:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102b4c:	89 08                	mov    %ecx,(%eax)
f0102b4e:	8b 02                	mov    (%edx),%eax
f0102b50:	8b 52 04             	mov    0x4(%edx),%edx
f0102b53:	eb 22                	jmp    f0102b77 <getuint+0x38>
	else if (lflag)
f0102b55:	85 d2                	test   %edx,%edx
f0102b57:	74 10                	je     f0102b69 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102b59:	8b 10                	mov    (%eax),%edx
f0102b5b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102b5e:	89 08                	mov    %ecx,(%eax)
f0102b60:	8b 02                	mov    (%edx),%eax
f0102b62:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b67:	eb 0e                	jmp    f0102b77 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102b69:	8b 10                	mov    (%eax),%edx
f0102b6b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102b6e:	89 08                	mov    %ecx,(%eax)
f0102b70:	8b 02                	mov    (%edx),%eax
f0102b72:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102b77:	5d                   	pop    %ebp
f0102b78:	c3                   	ret    

f0102b79 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102b79:	55                   	push   %ebp
f0102b7a:	89 e5                	mov    %esp,%ebp
f0102b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102b7f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102b83:	8b 10                	mov    (%eax),%edx
f0102b85:	3b 50 04             	cmp    0x4(%eax),%edx
f0102b88:	73 0a                	jae    f0102b94 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102b8a:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102b8d:	89 08                	mov    %ecx,(%eax)
f0102b8f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b92:	88 02                	mov    %al,(%edx)
}
f0102b94:	5d                   	pop    %ebp
f0102b95:	c3                   	ret    

f0102b96 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102b96:	55                   	push   %ebp
f0102b97:	89 e5                	mov    %esp,%ebp
f0102b99:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102b9c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102b9f:	50                   	push   %eax
f0102ba0:	ff 75 10             	pushl  0x10(%ebp)
f0102ba3:	ff 75 0c             	pushl  0xc(%ebp)
f0102ba6:	ff 75 08             	pushl  0x8(%ebp)
f0102ba9:	e8 05 00 00 00       	call   f0102bb3 <vprintfmt>
	va_end(ap);
}
f0102bae:	83 c4 10             	add    $0x10,%esp
f0102bb1:	c9                   	leave  
f0102bb2:	c3                   	ret    

f0102bb3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102bb3:	55                   	push   %ebp
f0102bb4:	89 e5                	mov    %esp,%ebp
f0102bb6:	57                   	push   %edi
f0102bb7:	56                   	push   %esi
f0102bb8:	53                   	push   %ebx
f0102bb9:	83 ec 2c             	sub    $0x2c,%esp
f0102bbc:	8b 75 08             	mov    0x8(%ebp),%esi
f0102bbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102bc2:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102bc5:	eb 12                	jmp    f0102bd9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102bc7:	85 c0                	test   %eax,%eax
f0102bc9:	0f 84 89 03 00 00    	je     f0102f58 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0102bcf:	83 ec 08             	sub    $0x8,%esp
f0102bd2:	53                   	push   %ebx
f0102bd3:	50                   	push   %eax
f0102bd4:	ff d6                	call   *%esi
f0102bd6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102bd9:	83 c7 01             	add    $0x1,%edi
f0102bdc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102be0:	83 f8 25             	cmp    $0x25,%eax
f0102be3:	75 e2                	jne    f0102bc7 <vprintfmt+0x14>
f0102be5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102be9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102bf0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102bf7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102bfe:	ba 00 00 00 00       	mov    $0x0,%edx
f0102c03:	eb 07                	jmp    f0102c0c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c05:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102c08:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c0c:	8d 47 01             	lea    0x1(%edi),%eax
f0102c0f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102c12:	0f b6 07             	movzbl (%edi),%eax
f0102c15:	0f b6 c8             	movzbl %al,%ecx
f0102c18:	83 e8 23             	sub    $0x23,%eax
f0102c1b:	3c 55                	cmp    $0x55,%al
f0102c1d:	0f 87 1a 03 00 00    	ja     f0102f3d <vprintfmt+0x38a>
f0102c23:	0f b6 c0             	movzbl %al,%eax
f0102c26:	ff 24 85 98 47 10 f0 	jmp    *-0xfefb868(,%eax,4)
f0102c2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102c30:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102c34:	eb d6                	jmp    f0102c0c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c36:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c39:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c3e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102c41:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102c44:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0102c48:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0102c4b:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0102c4e:	83 fa 09             	cmp    $0x9,%edx
f0102c51:	77 39                	ja     f0102c8c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102c53:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102c56:	eb e9                	jmp    f0102c41 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102c58:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c5b:	8d 48 04             	lea    0x4(%eax),%ecx
f0102c5e:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102c61:	8b 00                	mov    (%eax),%eax
f0102c63:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102c69:	eb 27                	jmp    f0102c92 <vprintfmt+0xdf>
f0102c6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c6e:	85 c0                	test   %eax,%eax
f0102c70:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102c75:	0f 49 c8             	cmovns %eax,%ecx
f0102c78:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c7e:	eb 8c                	jmp    f0102c0c <vprintfmt+0x59>
f0102c80:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102c83:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102c8a:	eb 80                	jmp    f0102c0c <vprintfmt+0x59>
f0102c8c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102c8f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102c92:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102c96:	0f 89 70 ff ff ff    	jns    f0102c0c <vprintfmt+0x59>
				width = precision, precision = -1;
f0102c9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102ca2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102ca9:	e9 5e ff ff ff       	jmp    f0102c0c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102cae:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cb1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102cb4:	e9 53 ff ff ff       	jmp    f0102c0c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102cb9:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cbc:	8d 50 04             	lea    0x4(%eax),%edx
f0102cbf:	89 55 14             	mov    %edx,0x14(%ebp)
f0102cc2:	83 ec 08             	sub    $0x8,%esp
f0102cc5:	53                   	push   %ebx
f0102cc6:	ff 30                	pushl  (%eax)
f0102cc8:	ff d6                	call   *%esi
			break;
f0102cca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ccd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102cd0:	e9 04 ff ff ff       	jmp    f0102bd9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102cd5:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cd8:	8d 50 04             	lea    0x4(%eax),%edx
f0102cdb:	89 55 14             	mov    %edx,0x14(%ebp)
f0102cde:	8b 00                	mov    (%eax),%eax
f0102ce0:	99                   	cltd   
f0102ce1:	31 d0                	xor    %edx,%eax
f0102ce3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102ce5:	83 f8 06             	cmp    $0x6,%eax
f0102ce8:	7f 0b                	jg     f0102cf5 <vprintfmt+0x142>
f0102cea:	8b 14 85 f0 48 10 f0 	mov    -0xfefb710(,%eax,4),%edx
f0102cf1:	85 d2                	test   %edx,%edx
f0102cf3:	75 18                	jne    f0102d0d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0102cf5:	50                   	push   %eax
f0102cf6:	68 25 47 10 f0       	push   $0xf0104725
f0102cfb:	53                   	push   %ebx
f0102cfc:	56                   	push   %esi
f0102cfd:	e8 94 fe ff ff       	call   f0102b96 <printfmt>
f0102d02:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d05:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102d08:	e9 cc fe ff ff       	jmp    f0102bd9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102d0d:	52                   	push   %edx
f0102d0e:	68 57 3c 10 f0       	push   $0xf0103c57
f0102d13:	53                   	push   %ebx
f0102d14:	56                   	push   %esi
f0102d15:	e8 7c fe ff ff       	call   f0102b96 <printfmt>
f0102d1a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d1d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102d20:	e9 b4 fe ff ff       	jmp    f0102bd9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102d25:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d28:	8d 50 04             	lea    0x4(%eax),%edx
f0102d2b:	89 55 14             	mov    %edx,0x14(%ebp)
f0102d2e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102d30:	85 ff                	test   %edi,%edi
f0102d32:	b8 1e 47 10 f0       	mov    $0xf010471e,%eax
f0102d37:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102d3a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102d3e:	0f 8e 94 00 00 00    	jle    f0102dd8 <vprintfmt+0x225>
f0102d44:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102d48:	0f 84 98 00 00 00    	je     f0102de6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d4e:	83 ec 08             	sub    $0x8,%esp
f0102d51:	ff 75 d0             	pushl  -0x30(%ebp)
f0102d54:	57                   	push   %edi
f0102d55:	e8 5f 03 00 00       	call   f01030b9 <strnlen>
f0102d5a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102d5d:	29 c1                	sub    %eax,%ecx
f0102d5f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102d62:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102d65:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102d69:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102d6c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102d6f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d71:	eb 0f                	jmp    f0102d82 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0102d73:	83 ec 08             	sub    $0x8,%esp
f0102d76:	53                   	push   %ebx
f0102d77:	ff 75 e0             	pushl  -0x20(%ebp)
f0102d7a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d7c:	83 ef 01             	sub    $0x1,%edi
f0102d7f:	83 c4 10             	add    $0x10,%esp
f0102d82:	85 ff                	test   %edi,%edi
f0102d84:	7f ed                	jg     f0102d73 <vprintfmt+0x1c0>
f0102d86:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102d89:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102d8c:	85 c9                	test   %ecx,%ecx
f0102d8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d93:	0f 49 c1             	cmovns %ecx,%eax
f0102d96:	29 c1                	sub    %eax,%ecx
f0102d98:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d9b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d9e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102da1:	89 cb                	mov    %ecx,%ebx
f0102da3:	eb 4d                	jmp    f0102df2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102da5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102da9:	74 1b                	je     f0102dc6 <vprintfmt+0x213>
f0102dab:	0f be c0             	movsbl %al,%eax
f0102dae:	83 e8 20             	sub    $0x20,%eax
f0102db1:	83 f8 5e             	cmp    $0x5e,%eax
f0102db4:	76 10                	jbe    f0102dc6 <vprintfmt+0x213>
					putch('?', putdat);
f0102db6:	83 ec 08             	sub    $0x8,%esp
f0102db9:	ff 75 0c             	pushl  0xc(%ebp)
f0102dbc:	6a 3f                	push   $0x3f
f0102dbe:	ff 55 08             	call   *0x8(%ebp)
f0102dc1:	83 c4 10             	add    $0x10,%esp
f0102dc4:	eb 0d                	jmp    f0102dd3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0102dc6:	83 ec 08             	sub    $0x8,%esp
f0102dc9:	ff 75 0c             	pushl  0xc(%ebp)
f0102dcc:	52                   	push   %edx
f0102dcd:	ff 55 08             	call   *0x8(%ebp)
f0102dd0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102dd3:	83 eb 01             	sub    $0x1,%ebx
f0102dd6:	eb 1a                	jmp    f0102df2 <vprintfmt+0x23f>
f0102dd8:	89 75 08             	mov    %esi,0x8(%ebp)
f0102ddb:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102dde:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102de1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102de4:	eb 0c                	jmp    f0102df2 <vprintfmt+0x23f>
f0102de6:	89 75 08             	mov    %esi,0x8(%ebp)
f0102de9:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102dec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102def:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102df2:	83 c7 01             	add    $0x1,%edi
f0102df5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102df9:	0f be d0             	movsbl %al,%edx
f0102dfc:	85 d2                	test   %edx,%edx
f0102dfe:	74 23                	je     f0102e23 <vprintfmt+0x270>
f0102e00:	85 f6                	test   %esi,%esi
f0102e02:	78 a1                	js     f0102da5 <vprintfmt+0x1f2>
f0102e04:	83 ee 01             	sub    $0x1,%esi
f0102e07:	79 9c                	jns    f0102da5 <vprintfmt+0x1f2>
f0102e09:	89 df                	mov    %ebx,%edi
f0102e0b:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e11:	eb 18                	jmp    f0102e2b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102e13:	83 ec 08             	sub    $0x8,%esp
f0102e16:	53                   	push   %ebx
f0102e17:	6a 20                	push   $0x20
f0102e19:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102e1b:	83 ef 01             	sub    $0x1,%edi
f0102e1e:	83 c4 10             	add    $0x10,%esp
f0102e21:	eb 08                	jmp    f0102e2b <vprintfmt+0x278>
f0102e23:	89 df                	mov    %ebx,%edi
f0102e25:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e2b:	85 ff                	test   %edi,%edi
f0102e2d:	7f e4                	jg     f0102e13 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e32:	e9 a2 fd ff ff       	jmp    f0102bd9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102e37:	83 fa 01             	cmp    $0x1,%edx
f0102e3a:	7e 16                	jle    f0102e52 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0102e3c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e3f:	8d 50 08             	lea    0x8(%eax),%edx
f0102e42:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e45:	8b 50 04             	mov    0x4(%eax),%edx
f0102e48:	8b 00                	mov    (%eax),%eax
f0102e4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e4d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102e50:	eb 32                	jmp    f0102e84 <vprintfmt+0x2d1>
	else if (lflag)
f0102e52:	85 d2                	test   %edx,%edx
f0102e54:	74 18                	je     f0102e6e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0102e56:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e59:	8d 50 04             	lea    0x4(%eax),%edx
f0102e5c:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e5f:	8b 00                	mov    (%eax),%eax
f0102e61:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e64:	89 c1                	mov    %eax,%ecx
f0102e66:	c1 f9 1f             	sar    $0x1f,%ecx
f0102e69:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102e6c:	eb 16                	jmp    f0102e84 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0102e6e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e71:	8d 50 04             	lea    0x4(%eax),%edx
f0102e74:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e77:	8b 00                	mov    (%eax),%eax
f0102e79:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e7c:	89 c1                	mov    %eax,%ecx
f0102e7e:	c1 f9 1f             	sar    $0x1f,%ecx
f0102e81:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102e84:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e87:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102e8a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102e8f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102e93:	79 74                	jns    f0102f09 <vprintfmt+0x356>
				putch('-', putdat);
f0102e95:	83 ec 08             	sub    $0x8,%esp
f0102e98:	53                   	push   %ebx
f0102e99:	6a 2d                	push   $0x2d
f0102e9b:	ff d6                	call   *%esi
				num = -(long long) num;
f0102e9d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102ea0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102ea3:	f7 d8                	neg    %eax
f0102ea5:	83 d2 00             	adc    $0x0,%edx
f0102ea8:	f7 da                	neg    %edx
f0102eaa:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102ead:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102eb2:	eb 55                	jmp    f0102f09 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102eb4:	8d 45 14             	lea    0x14(%ebp),%eax
f0102eb7:	e8 83 fc ff ff       	call   f0102b3f <getuint>
			base = 10;
f0102ebc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0102ec1:	eb 46                	jmp    f0102f09 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0102ec3:	8d 45 14             	lea    0x14(%ebp),%eax
f0102ec6:	e8 74 fc ff ff       	call   f0102b3f <getuint>
			base = 8;
f0102ecb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0102ed0:	eb 37                	jmp    f0102f09 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0102ed2:	83 ec 08             	sub    $0x8,%esp
f0102ed5:	53                   	push   %ebx
f0102ed6:	6a 30                	push   $0x30
f0102ed8:	ff d6                	call   *%esi
			putch('x', putdat);
f0102eda:	83 c4 08             	add    $0x8,%esp
f0102edd:	53                   	push   %ebx
f0102ede:	6a 78                	push   $0x78
f0102ee0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102ee2:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ee5:	8d 50 04             	lea    0x4(%eax),%edx
f0102ee8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102eeb:	8b 00                	mov    (%eax),%eax
f0102eed:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102ef2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102ef5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0102efa:	eb 0d                	jmp    f0102f09 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102efc:	8d 45 14             	lea    0x14(%ebp),%eax
f0102eff:	e8 3b fc ff ff       	call   f0102b3f <getuint>
			base = 16;
f0102f04:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102f09:	83 ec 0c             	sub    $0xc,%esp
f0102f0c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0102f10:	57                   	push   %edi
f0102f11:	ff 75 e0             	pushl  -0x20(%ebp)
f0102f14:	51                   	push   %ecx
f0102f15:	52                   	push   %edx
f0102f16:	50                   	push   %eax
f0102f17:	89 da                	mov    %ebx,%edx
f0102f19:	89 f0                	mov    %esi,%eax
f0102f1b:	e8 70 fb ff ff       	call   f0102a90 <printnum>
			break;
f0102f20:	83 c4 20             	add    $0x20,%esp
f0102f23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102f26:	e9 ae fc ff ff       	jmp    f0102bd9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102f2b:	83 ec 08             	sub    $0x8,%esp
f0102f2e:	53                   	push   %ebx
f0102f2f:	51                   	push   %ecx
f0102f30:	ff d6                	call   *%esi
			break;
f0102f32:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102f35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102f38:	e9 9c fc ff ff       	jmp    f0102bd9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0102f3d:	83 ec 08             	sub    $0x8,%esp
f0102f40:	53                   	push   %ebx
f0102f41:	6a 25                	push   $0x25
f0102f43:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102f45:	83 c4 10             	add    $0x10,%esp
f0102f48:	eb 03                	jmp    f0102f4d <vprintfmt+0x39a>
f0102f4a:	83 ef 01             	sub    $0x1,%edi
f0102f4d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0102f51:	75 f7                	jne    f0102f4a <vprintfmt+0x397>
f0102f53:	e9 81 fc ff ff       	jmp    f0102bd9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0102f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f5b:	5b                   	pop    %ebx
f0102f5c:	5e                   	pop    %esi
f0102f5d:	5f                   	pop    %edi
f0102f5e:	5d                   	pop    %ebp
f0102f5f:	c3                   	ret    

f0102f60 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102f60:	55                   	push   %ebp
f0102f61:	89 e5                	mov    %esp,%ebp
f0102f63:	83 ec 18             	sub    $0x18,%esp
f0102f66:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f69:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102f6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102f6f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102f73:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102f76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102f7d:	85 c0                	test   %eax,%eax
f0102f7f:	74 26                	je     f0102fa7 <vsnprintf+0x47>
f0102f81:	85 d2                	test   %edx,%edx
f0102f83:	7e 22                	jle    f0102fa7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102f85:	ff 75 14             	pushl  0x14(%ebp)
f0102f88:	ff 75 10             	pushl  0x10(%ebp)
f0102f8b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102f8e:	50                   	push   %eax
f0102f8f:	68 79 2b 10 f0       	push   $0xf0102b79
f0102f94:	e8 1a fc ff ff       	call   f0102bb3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102f99:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102f9c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102fa2:	83 c4 10             	add    $0x10,%esp
f0102fa5:	eb 05                	jmp    f0102fac <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0102fa7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102fac:	c9                   	leave  
f0102fad:	c3                   	ret    

f0102fae <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102fae:	55                   	push   %ebp
f0102faf:	89 e5                	mov    %esp,%ebp
f0102fb1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102fb4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102fb7:	50                   	push   %eax
f0102fb8:	ff 75 10             	pushl  0x10(%ebp)
f0102fbb:	ff 75 0c             	pushl  0xc(%ebp)
f0102fbe:	ff 75 08             	pushl  0x8(%ebp)
f0102fc1:	e8 9a ff ff ff       	call   f0102f60 <vsnprintf>
	va_end(ap);

	return rc;
}
f0102fc6:	c9                   	leave  
f0102fc7:	c3                   	ret    

f0102fc8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102fc8:	55                   	push   %ebp
f0102fc9:	89 e5                	mov    %esp,%ebp
f0102fcb:	57                   	push   %edi
f0102fcc:	56                   	push   %esi
f0102fcd:	53                   	push   %ebx
f0102fce:	83 ec 0c             	sub    $0xc,%esp
f0102fd1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102fd4:	85 c0                	test   %eax,%eax
f0102fd6:	74 11                	je     f0102fe9 <readline+0x21>
		cprintf("%s", prompt);
f0102fd8:	83 ec 08             	sub    $0x8,%esp
f0102fdb:	50                   	push   %eax
f0102fdc:	68 57 3c 10 f0       	push   $0xf0103c57
f0102fe1:	e8 75 f7 ff ff       	call   f010275b <cprintf>
f0102fe6:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0102fe9:	83 ec 0c             	sub    $0xc,%esp
f0102fec:	6a 00                	push   $0x0
f0102fee:	e8 2e d6 ff ff       	call   f0100621 <iscons>
f0102ff3:	89 c7                	mov    %eax,%edi
f0102ff5:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0102ff8:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0102ffd:	e8 0e d6 ff ff       	call   f0100610 <getchar>
f0103002:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103004:	85 c0                	test   %eax,%eax
f0103006:	79 18                	jns    f0103020 <readline+0x58>
			cprintf("read error: %e\n", c);
f0103008:	83 ec 08             	sub    $0x8,%esp
f010300b:	50                   	push   %eax
f010300c:	68 0c 49 10 f0       	push   $0xf010490c
f0103011:	e8 45 f7 ff ff       	call   f010275b <cprintf>
			return NULL;
f0103016:	83 c4 10             	add    $0x10,%esp
f0103019:	b8 00 00 00 00       	mov    $0x0,%eax
f010301e:	eb 79                	jmp    f0103099 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103020:	83 f8 08             	cmp    $0x8,%eax
f0103023:	0f 94 c2             	sete   %dl
f0103026:	83 f8 7f             	cmp    $0x7f,%eax
f0103029:	0f 94 c0             	sete   %al
f010302c:	08 c2                	or     %al,%dl
f010302e:	74 1a                	je     f010304a <readline+0x82>
f0103030:	85 f6                	test   %esi,%esi
f0103032:	7e 16                	jle    f010304a <readline+0x82>
			if (echoing)
f0103034:	85 ff                	test   %edi,%edi
f0103036:	74 0d                	je     f0103045 <readline+0x7d>
				cputchar('\b');
f0103038:	83 ec 0c             	sub    $0xc,%esp
f010303b:	6a 08                	push   $0x8
f010303d:	e8 be d5 ff ff       	call   f0100600 <cputchar>
f0103042:	83 c4 10             	add    $0x10,%esp
			i--;
f0103045:	83 ee 01             	sub    $0x1,%esi
f0103048:	eb b3                	jmp    f0102ffd <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010304a:	83 fb 1f             	cmp    $0x1f,%ebx
f010304d:	7e 23                	jle    f0103072 <readline+0xaa>
f010304f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103055:	7f 1b                	jg     f0103072 <readline+0xaa>
			if (echoing)
f0103057:	85 ff                	test   %edi,%edi
f0103059:	74 0c                	je     f0103067 <readline+0x9f>
				cputchar(c);
f010305b:	83 ec 0c             	sub    $0xc,%esp
f010305e:	53                   	push   %ebx
f010305f:	e8 9c d5 ff ff       	call   f0100600 <cputchar>
f0103064:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103067:	88 9e 60 75 11 f0    	mov    %bl,-0xfee8aa0(%esi)
f010306d:	8d 76 01             	lea    0x1(%esi),%esi
f0103070:	eb 8b                	jmp    f0102ffd <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103072:	83 fb 0a             	cmp    $0xa,%ebx
f0103075:	74 05                	je     f010307c <readline+0xb4>
f0103077:	83 fb 0d             	cmp    $0xd,%ebx
f010307a:	75 81                	jne    f0102ffd <readline+0x35>
			if (echoing)
f010307c:	85 ff                	test   %edi,%edi
f010307e:	74 0d                	je     f010308d <readline+0xc5>
				cputchar('\n');
f0103080:	83 ec 0c             	sub    $0xc,%esp
f0103083:	6a 0a                	push   $0xa
f0103085:	e8 76 d5 ff ff       	call   f0100600 <cputchar>
f010308a:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010308d:	c6 86 60 75 11 f0 00 	movb   $0x0,-0xfee8aa0(%esi)
			return buf;
f0103094:	b8 60 75 11 f0       	mov    $0xf0117560,%eax
		}
	}
}
f0103099:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010309c:	5b                   	pop    %ebx
f010309d:	5e                   	pop    %esi
f010309e:	5f                   	pop    %edi
f010309f:	5d                   	pop    %ebp
f01030a0:	c3                   	ret    

f01030a1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01030a1:	55                   	push   %ebp
f01030a2:	89 e5                	mov    %esp,%ebp
f01030a4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01030a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01030ac:	eb 03                	jmp    f01030b1 <strlen+0x10>
		n++;
f01030ae:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01030b1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01030b5:	75 f7                	jne    f01030ae <strlen+0xd>
		n++;
	return n;
}
f01030b7:	5d                   	pop    %ebp
f01030b8:	c3                   	ret    

f01030b9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01030b9:	55                   	push   %ebp
f01030ba:	89 e5                	mov    %esp,%ebp
f01030bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01030bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01030c2:	ba 00 00 00 00       	mov    $0x0,%edx
f01030c7:	eb 03                	jmp    f01030cc <strnlen+0x13>
		n++;
f01030c9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01030cc:	39 c2                	cmp    %eax,%edx
f01030ce:	74 08                	je     f01030d8 <strnlen+0x1f>
f01030d0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01030d4:	75 f3                	jne    f01030c9 <strnlen+0x10>
f01030d6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01030d8:	5d                   	pop    %ebp
f01030d9:	c3                   	ret    

f01030da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01030da:	55                   	push   %ebp
f01030db:	89 e5                	mov    %esp,%ebp
f01030dd:	53                   	push   %ebx
f01030de:	8b 45 08             	mov    0x8(%ebp),%eax
f01030e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01030e4:	89 c2                	mov    %eax,%edx
f01030e6:	83 c2 01             	add    $0x1,%edx
f01030e9:	83 c1 01             	add    $0x1,%ecx
f01030ec:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01030f0:	88 5a ff             	mov    %bl,-0x1(%edx)
f01030f3:	84 db                	test   %bl,%bl
f01030f5:	75 ef                	jne    f01030e6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01030f7:	5b                   	pop    %ebx
f01030f8:	5d                   	pop    %ebp
f01030f9:	c3                   	ret    

f01030fa <strcat>:

char *
strcat(char *dst, const char *src)
{
f01030fa:	55                   	push   %ebp
f01030fb:	89 e5                	mov    %esp,%ebp
f01030fd:	53                   	push   %ebx
f01030fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103101:	53                   	push   %ebx
f0103102:	e8 9a ff ff ff       	call   f01030a1 <strlen>
f0103107:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010310a:	ff 75 0c             	pushl  0xc(%ebp)
f010310d:	01 d8                	add    %ebx,%eax
f010310f:	50                   	push   %eax
f0103110:	e8 c5 ff ff ff       	call   f01030da <strcpy>
	return dst;
}
f0103115:	89 d8                	mov    %ebx,%eax
f0103117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010311a:	c9                   	leave  
f010311b:	c3                   	ret    

f010311c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010311c:	55                   	push   %ebp
f010311d:	89 e5                	mov    %esp,%ebp
f010311f:	56                   	push   %esi
f0103120:	53                   	push   %ebx
f0103121:	8b 75 08             	mov    0x8(%ebp),%esi
f0103124:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103127:	89 f3                	mov    %esi,%ebx
f0103129:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010312c:	89 f2                	mov    %esi,%edx
f010312e:	eb 0f                	jmp    f010313f <strncpy+0x23>
		*dst++ = *src;
f0103130:	83 c2 01             	add    $0x1,%edx
f0103133:	0f b6 01             	movzbl (%ecx),%eax
f0103136:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103139:	80 39 01             	cmpb   $0x1,(%ecx)
f010313c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010313f:	39 da                	cmp    %ebx,%edx
f0103141:	75 ed                	jne    f0103130 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103143:	89 f0                	mov    %esi,%eax
f0103145:	5b                   	pop    %ebx
f0103146:	5e                   	pop    %esi
f0103147:	5d                   	pop    %ebp
f0103148:	c3                   	ret    

f0103149 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103149:	55                   	push   %ebp
f010314a:	89 e5                	mov    %esp,%ebp
f010314c:	56                   	push   %esi
f010314d:	53                   	push   %ebx
f010314e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103151:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103154:	8b 55 10             	mov    0x10(%ebp),%edx
f0103157:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103159:	85 d2                	test   %edx,%edx
f010315b:	74 21                	je     f010317e <strlcpy+0x35>
f010315d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103161:	89 f2                	mov    %esi,%edx
f0103163:	eb 09                	jmp    f010316e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103165:	83 c2 01             	add    $0x1,%edx
f0103168:	83 c1 01             	add    $0x1,%ecx
f010316b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010316e:	39 c2                	cmp    %eax,%edx
f0103170:	74 09                	je     f010317b <strlcpy+0x32>
f0103172:	0f b6 19             	movzbl (%ecx),%ebx
f0103175:	84 db                	test   %bl,%bl
f0103177:	75 ec                	jne    f0103165 <strlcpy+0x1c>
f0103179:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010317b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010317e:	29 f0                	sub    %esi,%eax
}
f0103180:	5b                   	pop    %ebx
f0103181:	5e                   	pop    %esi
f0103182:	5d                   	pop    %ebp
f0103183:	c3                   	ret    

f0103184 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103184:	55                   	push   %ebp
f0103185:	89 e5                	mov    %esp,%ebp
f0103187:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010318a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010318d:	eb 06                	jmp    f0103195 <strcmp+0x11>
		p++, q++;
f010318f:	83 c1 01             	add    $0x1,%ecx
f0103192:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103195:	0f b6 01             	movzbl (%ecx),%eax
f0103198:	84 c0                	test   %al,%al
f010319a:	74 04                	je     f01031a0 <strcmp+0x1c>
f010319c:	3a 02                	cmp    (%edx),%al
f010319e:	74 ef                	je     f010318f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01031a0:	0f b6 c0             	movzbl %al,%eax
f01031a3:	0f b6 12             	movzbl (%edx),%edx
f01031a6:	29 d0                	sub    %edx,%eax
}
f01031a8:	5d                   	pop    %ebp
f01031a9:	c3                   	ret    

f01031aa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01031aa:	55                   	push   %ebp
f01031ab:	89 e5                	mov    %esp,%ebp
f01031ad:	53                   	push   %ebx
f01031ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01031b1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01031b4:	89 c3                	mov    %eax,%ebx
f01031b6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01031b9:	eb 06                	jmp    f01031c1 <strncmp+0x17>
		n--, p++, q++;
f01031bb:	83 c0 01             	add    $0x1,%eax
f01031be:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01031c1:	39 d8                	cmp    %ebx,%eax
f01031c3:	74 15                	je     f01031da <strncmp+0x30>
f01031c5:	0f b6 08             	movzbl (%eax),%ecx
f01031c8:	84 c9                	test   %cl,%cl
f01031ca:	74 04                	je     f01031d0 <strncmp+0x26>
f01031cc:	3a 0a                	cmp    (%edx),%cl
f01031ce:	74 eb                	je     f01031bb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01031d0:	0f b6 00             	movzbl (%eax),%eax
f01031d3:	0f b6 12             	movzbl (%edx),%edx
f01031d6:	29 d0                	sub    %edx,%eax
f01031d8:	eb 05                	jmp    f01031df <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01031da:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01031df:	5b                   	pop    %ebx
f01031e0:	5d                   	pop    %ebp
f01031e1:	c3                   	ret    

f01031e2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01031e2:	55                   	push   %ebp
f01031e3:	89 e5                	mov    %esp,%ebp
f01031e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01031e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01031ec:	eb 07                	jmp    f01031f5 <strchr+0x13>
		if (*s == c)
f01031ee:	38 ca                	cmp    %cl,%dl
f01031f0:	74 0f                	je     f0103201 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01031f2:	83 c0 01             	add    $0x1,%eax
f01031f5:	0f b6 10             	movzbl (%eax),%edx
f01031f8:	84 d2                	test   %dl,%dl
f01031fa:	75 f2                	jne    f01031ee <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01031fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103201:	5d                   	pop    %ebp
f0103202:	c3                   	ret    

f0103203 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103203:	55                   	push   %ebp
f0103204:	89 e5                	mov    %esp,%ebp
f0103206:	8b 45 08             	mov    0x8(%ebp),%eax
f0103209:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010320d:	eb 03                	jmp    f0103212 <strfind+0xf>
f010320f:	83 c0 01             	add    $0x1,%eax
f0103212:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103215:	38 ca                	cmp    %cl,%dl
f0103217:	74 04                	je     f010321d <strfind+0x1a>
f0103219:	84 d2                	test   %dl,%dl
f010321b:	75 f2                	jne    f010320f <strfind+0xc>
			break;
	return (char *) s;
}
f010321d:	5d                   	pop    %ebp
f010321e:	c3                   	ret    

f010321f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010321f:	55                   	push   %ebp
f0103220:	89 e5                	mov    %esp,%ebp
f0103222:	57                   	push   %edi
f0103223:	56                   	push   %esi
f0103224:	53                   	push   %ebx
f0103225:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103228:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010322b:	85 c9                	test   %ecx,%ecx
f010322d:	74 36                	je     f0103265 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010322f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103235:	75 28                	jne    f010325f <memset+0x40>
f0103237:	f6 c1 03             	test   $0x3,%cl
f010323a:	75 23                	jne    f010325f <memset+0x40>
		c &= 0xFF;
f010323c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103240:	89 d3                	mov    %edx,%ebx
f0103242:	c1 e3 08             	shl    $0x8,%ebx
f0103245:	89 d6                	mov    %edx,%esi
f0103247:	c1 e6 18             	shl    $0x18,%esi
f010324a:	89 d0                	mov    %edx,%eax
f010324c:	c1 e0 10             	shl    $0x10,%eax
f010324f:	09 f0                	or     %esi,%eax
f0103251:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0103253:	89 d8                	mov    %ebx,%eax
f0103255:	09 d0                	or     %edx,%eax
f0103257:	c1 e9 02             	shr    $0x2,%ecx
f010325a:	fc                   	cld    
f010325b:	f3 ab                	rep stos %eax,%es:(%edi)
f010325d:	eb 06                	jmp    f0103265 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010325f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103262:	fc                   	cld    
f0103263:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103265:	89 f8                	mov    %edi,%eax
f0103267:	5b                   	pop    %ebx
f0103268:	5e                   	pop    %esi
f0103269:	5f                   	pop    %edi
f010326a:	5d                   	pop    %ebp
f010326b:	c3                   	ret    

f010326c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010326c:	55                   	push   %ebp
f010326d:	89 e5                	mov    %esp,%ebp
f010326f:	57                   	push   %edi
f0103270:	56                   	push   %esi
f0103271:	8b 45 08             	mov    0x8(%ebp),%eax
f0103274:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103277:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010327a:	39 c6                	cmp    %eax,%esi
f010327c:	73 35                	jae    f01032b3 <memmove+0x47>
f010327e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103281:	39 d0                	cmp    %edx,%eax
f0103283:	73 2e                	jae    f01032b3 <memmove+0x47>
		s += n;
		d += n;
f0103285:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103288:	89 d6                	mov    %edx,%esi
f010328a:	09 fe                	or     %edi,%esi
f010328c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103292:	75 13                	jne    f01032a7 <memmove+0x3b>
f0103294:	f6 c1 03             	test   $0x3,%cl
f0103297:	75 0e                	jne    f01032a7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0103299:	83 ef 04             	sub    $0x4,%edi
f010329c:	8d 72 fc             	lea    -0x4(%edx),%esi
f010329f:	c1 e9 02             	shr    $0x2,%ecx
f01032a2:	fd                   	std    
f01032a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01032a5:	eb 09                	jmp    f01032b0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01032a7:	83 ef 01             	sub    $0x1,%edi
f01032aa:	8d 72 ff             	lea    -0x1(%edx),%esi
f01032ad:	fd                   	std    
f01032ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01032b0:	fc                   	cld    
f01032b1:	eb 1d                	jmp    f01032d0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01032b3:	89 f2                	mov    %esi,%edx
f01032b5:	09 c2                	or     %eax,%edx
f01032b7:	f6 c2 03             	test   $0x3,%dl
f01032ba:	75 0f                	jne    f01032cb <memmove+0x5f>
f01032bc:	f6 c1 03             	test   $0x3,%cl
f01032bf:	75 0a                	jne    f01032cb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01032c1:	c1 e9 02             	shr    $0x2,%ecx
f01032c4:	89 c7                	mov    %eax,%edi
f01032c6:	fc                   	cld    
f01032c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01032c9:	eb 05                	jmp    f01032d0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01032cb:	89 c7                	mov    %eax,%edi
f01032cd:	fc                   	cld    
f01032ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01032d0:	5e                   	pop    %esi
f01032d1:	5f                   	pop    %edi
f01032d2:	5d                   	pop    %ebp
f01032d3:	c3                   	ret    

f01032d4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01032d4:	55                   	push   %ebp
f01032d5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01032d7:	ff 75 10             	pushl  0x10(%ebp)
f01032da:	ff 75 0c             	pushl  0xc(%ebp)
f01032dd:	ff 75 08             	pushl  0x8(%ebp)
f01032e0:	e8 87 ff ff ff       	call   f010326c <memmove>
}
f01032e5:	c9                   	leave  
f01032e6:	c3                   	ret    

f01032e7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01032e7:	55                   	push   %ebp
f01032e8:	89 e5                	mov    %esp,%ebp
f01032ea:	56                   	push   %esi
f01032eb:	53                   	push   %ebx
f01032ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01032ef:	8b 55 0c             	mov    0xc(%ebp),%edx
f01032f2:	89 c6                	mov    %eax,%esi
f01032f4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01032f7:	eb 1a                	jmp    f0103313 <memcmp+0x2c>
		if (*s1 != *s2)
f01032f9:	0f b6 08             	movzbl (%eax),%ecx
f01032fc:	0f b6 1a             	movzbl (%edx),%ebx
f01032ff:	38 d9                	cmp    %bl,%cl
f0103301:	74 0a                	je     f010330d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0103303:	0f b6 c1             	movzbl %cl,%eax
f0103306:	0f b6 db             	movzbl %bl,%ebx
f0103309:	29 d8                	sub    %ebx,%eax
f010330b:	eb 0f                	jmp    f010331c <memcmp+0x35>
		s1++, s2++;
f010330d:	83 c0 01             	add    $0x1,%eax
f0103310:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103313:	39 f0                	cmp    %esi,%eax
f0103315:	75 e2                	jne    f01032f9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103317:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010331c:	5b                   	pop    %ebx
f010331d:	5e                   	pop    %esi
f010331e:	5d                   	pop    %ebp
f010331f:	c3                   	ret    

f0103320 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103320:	55                   	push   %ebp
f0103321:	89 e5                	mov    %esp,%ebp
f0103323:	53                   	push   %ebx
f0103324:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103327:	89 c1                	mov    %eax,%ecx
f0103329:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010332c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103330:	eb 0a                	jmp    f010333c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103332:	0f b6 10             	movzbl (%eax),%edx
f0103335:	39 da                	cmp    %ebx,%edx
f0103337:	74 07                	je     f0103340 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103339:	83 c0 01             	add    $0x1,%eax
f010333c:	39 c8                	cmp    %ecx,%eax
f010333e:	72 f2                	jb     f0103332 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103340:	5b                   	pop    %ebx
f0103341:	5d                   	pop    %ebp
f0103342:	c3                   	ret    

f0103343 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103343:	55                   	push   %ebp
f0103344:	89 e5                	mov    %esp,%ebp
f0103346:	57                   	push   %edi
f0103347:	56                   	push   %esi
f0103348:	53                   	push   %ebx
f0103349:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010334c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010334f:	eb 03                	jmp    f0103354 <strtol+0x11>
		s++;
f0103351:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103354:	0f b6 01             	movzbl (%ecx),%eax
f0103357:	3c 20                	cmp    $0x20,%al
f0103359:	74 f6                	je     f0103351 <strtol+0xe>
f010335b:	3c 09                	cmp    $0x9,%al
f010335d:	74 f2                	je     f0103351 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010335f:	3c 2b                	cmp    $0x2b,%al
f0103361:	75 0a                	jne    f010336d <strtol+0x2a>
		s++;
f0103363:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103366:	bf 00 00 00 00       	mov    $0x0,%edi
f010336b:	eb 11                	jmp    f010337e <strtol+0x3b>
f010336d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103372:	3c 2d                	cmp    $0x2d,%al
f0103374:	75 08                	jne    f010337e <strtol+0x3b>
		s++, neg = 1;
f0103376:	83 c1 01             	add    $0x1,%ecx
f0103379:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010337e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103384:	75 15                	jne    f010339b <strtol+0x58>
f0103386:	80 39 30             	cmpb   $0x30,(%ecx)
f0103389:	75 10                	jne    f010339b <strtol+0x58>
f010338b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010338f:	75 7c                	jne    f010340d <strtol+0xca>
		s += 2, base = 16;
f0103391:	83 c1 02             	add    $0x2,%ecx
f0103394:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103399:	eb 16                	jmp    f01033b1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010339b:	85 db                	test   %ebx,%ebx
f010339d:	75 12                	jne    f01033b1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010339f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01033a4:	80 39 30             	cmpb   $0x30,(%ecx)
f01033a7:	75 08                	jne    f01033b1 <strtol+0x6e>
		s++, base = 8;
f01033a9:	83 c1 01             	add    $0x1,%ecx
f01033ac:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01033b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01033b6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01033b9:	0f b6 11             	movzbl (%ecx),%edx
f01033bc:	8d 72 d0             	lea    -0x30(%edx),%esi
f01033bf:	89 f3                	mov    %esi,%ebx
f01033c1:	80 fb 09             	cmp    $0x9,%bl
f01033c4:	77 08                	ja     f01033ce <strtol+0x8b>
			dig = *s - '0';
f01033c6:	0f be d2             	movsbl %dl,%edx
f01033c9:	83 ea 30             	sub    $0x30,%edx
f01033cc:	eb 22                	jmp    f01033f0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01033ce:	8d 72 9f             	lea    -0x61(%edx),%esi
f01033d1:	89 f3                	mov    %esi,%ebx
f01033d3:	80 fb 19             	cmp    $0x19,%bl
f01033d6:	77 08                	ja     f01033e0 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01033d8:	0f be d2             	movsbl %dl,%edx
f01033db:	83 ea 57             	sub    $0x57,%edx
f01033de:	eb 10                	jmp    f01033f0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01033e0:	8d 72 bf             	lea    -0x41(%edx),%esi
f01033e3:	89 f3                	mov    %esi,%ebx
f01033e5:	80 fb 19             	cmp    $0x19,%bl
f01033e8:	77 16                	ja     f0103400 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01033ea:	0f be d2             	movsbl %dl,%edx
f01033ed:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01033f0:	3b 55 10             	cmp    0x10(%ebp),%edx
f01033f3:	7d 0b                	jge    f0103400 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01033f5:	83 c1 01             	add    $0x1,%ecx
f01033f8:	0f af 45 10          	imul   0x10(%ebp),%eax
f01033fc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01033fe:	eb b9                	jmp    f01033b9 <strtol+0x76>

	if (endptr)
f0103400:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103404:	74 0d                	je     f0103413 <strtol+0xd0>
		*endptr = (char *) s;
f0103406:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103409:	89 0e                	mov    %ecx,(%esi)
f010340b:	eb 06                	jmp    f0103413 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010340d:	85 db                	test   %ebx,%ebx
f010340f:	74 98                	je     f01033a9 <strtol+0x66>
f0103411:	eb 9e                	jmp    f01033b1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0103413:	89 c2                	mov    %eax,%edx
f0103415:	f7 da                	neg    %edx
f0103417:	85 ff                	test   %edi,%edi
f0103419:	0f 45 c2             	cmovne %edx,%eax
}
f010341c:	5b                   	pop    %ebx
f010341d:	5e                   	pop    %esi
f010341e:	5f                   	pop    %edi
f010341f:	5d                   	pop    %ebp
f0103420:	c3                   	ret    
f0103421:	66 90                	xchg   %ax,%ax
f0103423:	66 90                	xchg   %ax,%ax
f0103425:	66 90                	xchg   %ax,%ax
f0103427:	66 90                	xchg   %ax,%ax
f0103429:	66 90                	xchg   %ax,%ax
f010342b:	66 90                	xchg   %ax,%ax
f010342d:	66 90                	xchg   %ax,%ax
f010342f:	90                   	nop

f0103430 <__udivdi3>:
f0103430:	55                   	push   %ebp
f0103431:	57                   	push   %edi
f0103432:	56                   	push   %esi
f0103433:	53                   	push   %ebx
f0103434:	83 ec 1c             	sub    $0x1c,%esp
f0103437:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010343b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010343f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0103443:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103447:	85 f6                	test   %esi,%esi
f0103449:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010344d:	89 ca                	mov    %ecx,%edx
f010344f:	89 f8                	mov    %edi,%eax
f0103451:	75 3d                	jne    f0103490 <__udivdi3+0x60>
f0103453:	39 cf                	cmp    %ecx,%edi
f0103455:	0f 87 c5 00 00 00    	ja     f0103520 <__udivdi3+0xf0>
f010345b:	85 ff                	test   %edi,%edi
f010345d:	89 fd                	mov    %edi,%ebp
f010345f:	75 0b                	jne    f010346c <__udivdi3+0x3c>
f0103461:	b8 01 00 00 00       	mov    $0x1,%eax
f0103466:	31 d2                	xor    %edx,%edx
f0103468:	f7 f7                	div    %edi
f010346a:	89 c5                	mov    %eax,%ebp
f010346c:	89 c8                	mov    %ecx,%eax
f010346e:	31 d2                	xor    %edx,%edx
f0103470:	f7 f5                	div    %ebp
f0103472:	89 c1                	mov    %eax,%ecx
f0103474:	89 d8                	mov    %ebx,%eax
f0103476:	89 cf                	mov    %ecx,%edi
f0103478:	f7 f5                	div    %ebp
f010347a:	89 c3                	mov    %eax,%ebx
f010347c:	89 d8                	mov    %ebx,%eax
f010347e:	89 fa                	mov    %edi,%edx
f0103480:	83 c4 1c             	add    $0x1c,%esp
f0103483:	5b                   	pop    %ebx
f0103484:	5e                   	pop    %esi
f0103485:	5f                   	pop    %edi
f0103486:	5d                   	pop    %ebp
f0103487:	c3                   	ret    
f0103488:	90                   	nop
f0103489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103490:	39 ce                	cmp    %ecx,%esi
f0103492:	77 74                	ja     f0103508 <__udivdi3+0xd8>
f0103494:	0f bd fe             	bsr    %esi,%edi
f0103497:	83 f7 1f             	xor    $0x1f,%edi
f010349a:	0f 84 98 00 00 00    	je     f0103538 <__udivdi3+0x108>
f01034a0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01034a5:	89 f9                	mov    %edi,%ecx
f01034a7:	89 c5                	mov    %eax,%ebp
f01034a9:	29 fb                	sub    %edi,%ebx
f01034ab:	d3 e6                	shl    %cl,%esi
f01034ad:	89 d9                	mov    %ebx,%ecx
f01034af:	d3 ed                	shr    %cl,%ebp
f01034b1:	89 f9                	mov    %edi,%ecx
f01034b3:	d3 e0                	shl    %cl,%eax
f01034b5:	09 ee                	or     %ebp,%esi
f01034b7:	89 d9                	mov    %ebx,%ecx
f01034b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034bd:	89 d5                	mov    %edx,%ebp
f01034bf:	8b 44 24 08          	mov    0x8(%esp),%eax
f01034c3:	d3 ed                	shr    %cl,%ebp
f01034c5:	89 f9                	mov    %edi,%ecx
f01034c7:	d3 e2                	shl    %cl,%edx
f01034c9:	89 d9                	mov    %ebx,%ecx
f01034cb:	d3 e8                	shr    %cl,%eax
f01034cd:	09 c2                	or     %eax,%edx
f01034cf:	89 d0                	mov    %edx,%eax
f01034d1:	89 ea                	mov    %ebp,%edx
f01034d3:	f7 f6                	div    %esi
f01034d5:	89 d5                	mov    %edx,%ebp
f01034d7:	89 c3                	mov    %eax,%ebx
f01034d9:	f7 64 24 0c          	mull   0xc(%esp)
f01034dd:	39 d5                	cmp    %edx,%ebp
f01034df:	72 10                	jb     f01034f1 <__udivdi3+0xc1>
f01034e1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01034e5:	89 f9                	mov    %edi,%ecx
f01034e7:	d3 e6                	shl    %cl,%esi
f01034e9:	39 c6                	cmp    %eax,%esi
f01034eb:	73 07                	jae    f01034f4 <__udivdi3+0xc4>
f01034ed:	39 d5                	cmp    %edx,%ebp
f01034ef:	75 03                	jne    f01034f4 <__udivdi3+0xc4>
f01034f1:	83 eb 01             	sub    $0x1,%ebx
f01034f4:	31 ff                	xor    %edi,%edi
f01034f6:	89 d8                	mov    %ebx,%eax
f01034f8:	89 fa                	mov    %edi,%edx
f01034fa:	83 c4 1c             	add    $0x1c,%esp
f01034fd:	5b                   	pop    %ebx
f01034fe:	5e                   	pop    %esi
f01034ff:	5f                   	pop    %edi
f0103500:	5d                   	pop    %ebp
f0103501:	c3                   	ret    
f0103502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103508:	31 ff                	xor    %edi,%edi
f010350a:	31 db                	xor    %ebx,%ebx
f010350c:	89 d8                	mov    %ebx,%eax
f010350e:	89 fa                	mov    %edi,%edx
f0103510:	83 c4 1c             	add    $0x1c,%esp
f0103513:	5b                   	pop    %ebx
f0103514:	5e                   	pop    %esi
f0103515:	5f                   	pop    %edi
f0103516:	5d                   	pop    %ebp
f0103517:	c3                   	ret    
f0103518:	90                   	nop
f0103519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103520:	89 d8                	mov    %ebx,%eax
f0103522:	f7 f7                	div    %edi
f0103524:	31 ff                	xor    %edi,%edi
f0103526:	89 c3                	mov    %eax,%ebx
f0103528:	89 d8                	mov    %ebx,%eax
f010352a:	89 fa                	mov    %edi,%edx
f010352c:	83 c4 1c             	add    $0x1c,%esp
f010352f:	5b                   	pop    %ebx
f0103530:	5e                   	pop    %esi
f0103531:	5f                   	pop    %edi
f0103532:	5d                   	pop    %ebp
f0103533:	c3                   	ret    
f0103534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103538:	39 ce                	cmp    %ecx,%esi
f010353a:	72 0c                	jb     f0103548 <__udivdi3+0x118>
f010353c:	31 db                	xor    %ebx,%ebx
f010353e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0103542:	0f 87 34 ff ff ff    	ja     f010347c <__udivdi3+0x4c>
f0103548:	bb 01 00 00 00       	mov    $0x1,%ebx
f010354d:	e9 2a ff ff ff       	jmp    f010347c <__udivdi3+0x4c>
f0103552:	66 90                	xchg   %ax,%ax
f0103554:	66 90                	xchg   %ax,%ax
f0103556:	66 90                	xchg   %ax,%ax
f0103558:	66 90                	xchg   %ax,%ax
f010355a:	66 90                	xchg   %ax,%ax
f010355c:	66 90                	xchg   %ax,%ax
f010355e:	66 90                	xchg   %ax,%ax

f0103560 <__umoddi3>:
f0103560:	55                   	push   %ebp
f0103561:	57                   	push   %edi
f0103562:	56                   	push   %esi
f0103563:	53                   	push   %ebx
f0103564:	83 ec 1c             	sub    $0x1c,%esp
f0103567:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010356b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010356f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103573:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103577:	85 d2                	test   %edx,%edx
f0103579:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010357d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103581:	89 f3                	mov    %esi,%ebx
f0103583:	89 3c 24             	mov    %edi,(%esp)
f0103586:	89 74 24 04          	mov    %esi,0x4(%esp)
f010358a:	75 1c                	jne    f01035a8 <__umoddi3+0x48>
f010358c:	39 f7                	cmp    %esi,%edi
f010358e:	76 50                	jbe    f01035e0 <__umoddi3+0x80>
f0103590:	89 c8                	mov    %ecx,%eax
f0103592:	89 f2                	mov    %esi,%edx
f0103594:	f7 f7                	div    %edi
f0103596:	89 d0                	mov    %edx,%eax
f0103598:	31 d2                	xor    %edx,%edx
f010359a:	83 c4 1c             	add    $0x1c,%esp
f010359d:	5b                   	pop    %ebx
f010359e:	5e                   	pop    %esi
f010359f:	5f                   	pop    %edi
f01035a0:	5d                   	pop    %ebp
f01035a1:	c3                   	ret    
f01035a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01035a8:	39 f2                	cmp    %esi,%edx
f01035aa:	89 d0                	mov    %edx,%eax
f01035ac:	77 52                	ja     f0103600 <__umoddi3+0xa0>
f01035ae:	0f bd ea             	bsr    %edx,%ebp
f01035b1:	83 f5 1f             	xor    $0x1f,%ebp
f01035b4:	75 5a                	jne    f0103610 <__umoddi3+0xb0>
f01035b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01035ba:	0f 82 e0 00 00 00    	jb     f01036a0 <__umoddi3+0x140>
f01035c0:	39 0c 24             	cmp    %ecx,(%esp)
f01035c3:	0f 86 d7 00 00 00    	jbe    f01036a0 <__umoddi3+0x140>
f01035c9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01035cd:	8b 54 24 04          	mov    0x4(%esp),%edx
f01035d1:	83 c4 1c             	add    $0x1c,%esp
f01035d4:	5b                   	pop    %ebx
f01035d5:	5e                   	pop    %esi
f01035d6:	5f                   	pop    %edi
f01035d7:	5d                   	pop    %ebp
f01035d8:	c3                   	ret    
f01035d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01035e0:	85 ff                	test   %edi,%edi
f01035e2:	89 fd                	mov    %edi,%ebp
f01035e4:	75 0b                	jne    f01035f1 <__umoddi3+0x91>
f01035e6:	b8 01 00 00 00       	mov    $0x1,%eax
f01035eb:	31 d2                	xor    %edx,%edx
f01035ed:	f7 f7                	div    %edi
f01035ef:	89 c5                	mov    %eax,%ebp
f01035f1:	89 f0                	mov    %esi,%eax
f01035f3:	31 d2                	xor    %edx,%edx
f01035f5:	f7 f5                	div    %ebp
f01035f7:	89 c8                	mov    %ecx,%eax
f01035f9:	f7 f5                	div    %ebp
f01035fb:	89 d0                	mov    %edx,%eax
f01035fd:	eb 99                	jmp    f0103598 <__umoddi3+0x38>
f01035ff:	90                   	nop
f0103600:	89 c8                	mov    %ecx,%eax
f0103602:	89 f2                	mov    %esi,%edx
f0103604:	83 c4 1c             	add    $0x1c,%esp
f0103607:	5b                   	pop    %ebx
f0103608:	5e                   	pop    %esi
f0103609:	5f                   	pop    %edi
f010360a:	5d                   	pop    %ebp
f010360b:	c3                   	ret    
f010360c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103610:	8b 34 24             	mov    (%esp),%esi
f0103613:	bf 20 00 00 00       	mov    $0x20,%edi
f0103618:	89 e9                	mov    %ebp,%ecx
f010361a:	29 ef                	sub    %ebp,%edi
f010361c:	d3 e0                	shl    %cl,%eax
f010361e:	89 f9                	mov    %edi,%ecx
f0103620:	89 f2                	mov    %esi,%edx
f0103622:	d3 ea                	shr    %cl,%edx
f0103624:	89 e9                	mov    %ebp,%ecx
f0103626:	09 c2                	or     %eax,%edx
f0103628:	89 d8                	mov    %ebx,%eax
f010362a:	89 14 24             	mov    %edx,(%esp)
f010362d:	89 f2                	mov    %esi,%edx
f010362f:	d3 e2                	shl    %cl,%edx
f0103631:	89 f9                	mov    %edi,%ecx
f0103633:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103637:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010363b:	d3 e8                	shr    %cl,%eax
f010363d:	89 e9                	mov    %ebp,%ecx
f010363f:	89 c6                	mov    %eax,%esi
f0103641:	d3 e3                	shl    %cl,%ebx
f0103643:	89 f9                	mov    %edi,%ecx
f0103645:	89 d0                	mov    %edx,%eax
f0103647:	d3 e8                	shr    %cl,%eax
f0103649:	89 e9                	mov    %ebp,%ecx
f010364b:	09 d8                	or     %ebx,%eax
f010364d:	89 d3                	mov    %edx,%ebx
f010364f:	89 f2                	mov    %esi,%edx
f0103651:	f7 34 24             	divl   (%esp)
f0103654:	89 d6                	mov    %edx,%esi
f0103656:	d3 e3                	shl    %cl,%ebx
f0103658:	f7 64 24 04          	mull   0x4(%esp)
f010365c:	39 d6                	cmp    %edx,%esi
f010365e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103662:	89 d1                	mov    %edx,%ecx
f0103664:	89 c3                	mov    %eax,%ebx
f0103666:	72 08                	jb     f0103670 <__umoddi3+0x110>
f0103668:	75 11                	jne    f010367b <__umoddi3+0x11b>
f010366a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010366e:	73 0b                	jae    f010367b <__umoddi3+0x11b>
f0103670:	2b 44 24 04          	sub    0x4(%esp),%eax
f0103674:	1b 14 24             	sbb    (%esp),%edx
f0103677:	89 d1                	mov    %edx,%ecx
f0103679:	89 c3                	mov    %eax,%ebx
f010367b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010367f:	29 da                	sub    %ebx,%edx
f0103681:	19 ce                	sbb    %ecx,%esi
f0103683:	89 f9                	mov    %edi,%ecx
f0103685:	89 f0                	mov    %esi,%eax
f0103687:	d3 e0                	shl    %cl,%eax
f0103689:	89 e9                	mov    %ebp,%ecx
f010368b:	d3 ea                	shr    %cl,%edx
f010368d:	89 e9                	mov    %ebp,%ecx
f010368f:	d3 ee                	shr    %cl,%esi
f0103691:	09 d0                	or     %edx,%eax
f0103693:	89 f2                	mov    %esi,%edx
f0103695:	83 c4 1c             	add    $0x1c,%esp
f0103698:	5b                   	pop    %ebx
f0103699:	5e                   	pop    %esi
f010369a:	5f                   	pop    %edi
f010369b:	5d                   	pop    %ebp
f010369c:	c3                   	ret    
f010369d:	8d 76 00             	lea    0x0(%esi),%esi
f01036a0:	29 f9                	sub    %edi,%ecx
f01036a2:	19 d6                	sbb    %edx,%esi
f01036a4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01036a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01036ac:	e9 18 ff ff ff       	jmp    f01035c9 <__umoddi3+0x69>
