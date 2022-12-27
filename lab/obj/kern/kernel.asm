
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
f0100058:	e8 9c 31 00 00       	call   f01031f9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 96 04 00 00       	call   f01004f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 a0 36 10 f0       	push   $0xf01036a0
f010006f:	e8 c1 26 00 00       	call   f0102735 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 8c 10 00 00       	call   f0101105 <mem_init>
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
f01000b0:	68 bb 36 10 f0       	push   $0xf01036bb
f01000b5:	e8 7b 26 00 00       	call   f0102735 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 4b 26 00 00       	call   f010270f <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 b0 3e 10 f0 	movl   $0xf0103eb0,(%esp)
f01000cb:	e8 65 26 00 00       	call   f0102735 <cprintf>
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
f01000f2:	68 d3 36 10 f0       	push   $0xf01036d3
f01000f7:	e8 39 26 00 00       	call   f0102735 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 07 26 00 00       	call   f010270f <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 b0 3e 10 f0 	movl   $0xf0103eb0,(%esp)
f010010f:	e8 21 26 00 00       	call   f0102735 <cprintf>
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
f01001ce:	0f b6 82 40 38 10 f0 	movzbl -0xfefc7c0(%edx),%eax
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
f010020a:	0f b6 82 40 38 10 f0 	movzbl -0xfefc7c0(%edx),%eax
f0100211:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
f0100217:	0f b6 8a 40 37 10 f0 	movzbl -0xfefc8c0(%edx),%ecx
f010021e:	31 c8                	xor    %ecx,%eax
f0100220:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100225:	89 c1                	mov    %eax,%ecx
f0100227:	83 e1 03             	and    $0x3,%ecx
f010022a:	8b 0c 8d 20 37 10 f0 	mov    -0xfefc8e0(,%ecx,4),%ecx
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
f0100268:	68 ed 36 10 f0       	push   $0xf01036ed
f010026d:	e8 c3 24 00 00       	call   f0102735 <cprintf>
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
f010041c:	e8 25 2e 00 00       	call   f0103246 <memmove>
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
f01005eb:	68 f9 36 10 f0       	push   $0xf01036f9
f01005f0:	e8 40 21 00 00       	call   f0102735 <cprintf>
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
f0100631:	68 40 39 10 f0       	push   $0xf0103940
f0100636:	68 5e 39 10 f0       	push   $0xf010395e
f010063b:	68 63 39 10 f0       	push   $0xf0103963
f0100640:	e8 f0 20 00 00       	call   f0102735 <cprintf>
f0100645:	83 c4 0c             	add    $0xc,%esp
f0100648:	68 1c 3a 10 f0       	push   $0xf0103a1c
f010064d:	68 6c 39 10 f0       	push   $0xf010396c
f0100652:	68 63 39 10 f0       	push   $0xf0103963
f0100657:	e8 d9 20 00 00       	call   f0102735 <cprintf>
f010065c:	83 c4 0c             	add    $0xc,%esp
f010065f:	68 75 39 10 f0       	push   $0xf0103975
f0100664:	68 93 39 10 f0       	push   $0xf0103993
f0100669:	68 63 39 10 f0       	push   $0xf0103963
f010066e:	e8 c2 20 00 00       	call   f0102735 <cprintf>
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
f0100680:	68 9d 39 10 f0       	push   $0xf010399d
f0100685:	e8 ab 20 00 00       	call   f0102735 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010068a:	83 c4 08             	add    $0x8,%esp
f010068d:	68 0c 00 10 00       	push   $0x10000c
f0100692:	68 44 3a 10 f0       	push   $0xf0103a44
f0100697:	e8 99 20 00 00       	call   f0102735 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010069c:	83 c4 0c             	add    $0xc,%esp
f010069f:	68 0c 00 10 00       	push   $0x10000c
f01006a4:	68 0c 00 10 f0       	push   $0xf010000c
f01006a9:	68 6c 3a 10 f0       	push   $0xf0103a6c
f01006ae:	e8 82 20 00 00       	call   f0102735 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b3:	83 c4 0c             	add    $0xc,%esp
f01006b6:	68 81 36 10 00       	push   $0x103681
f01006bb:	68 81 36 10 f0       	push   $0xf0103681
f01006c0:	68 90 3a 10 f0       	push   $0xf0103a90
f01006c5:	e8 6b 20 00 00       	call   f0102735 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ca:	83 c4 0c             	add    $0xc,%esp
f01006cd:	68 00 73 11 00       	push   $0x117300
f01006d2:	68 00 73 11 f0       	push   $0xf0117300
f01006d7:	68 b4 3a 10 f0       	push   $0xf0103ab4
f01006dc:	e8 54 20 00 00       	call   f0102735 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e1:	83 c4 0c             	add    $0xc,%esp
f01006e4:	68 60 79 11 00       	push   $0x117960
f01006e9:	68 60 79 11 f0       	push   $0xf0117960
f01006ee:	68 d8 3a 10 f0       	push   $0xf0103ad8
f01006f3:	e8 3d 20 00 00       	call   f0102735 <cprintf>
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
f0100719:	68 fc 3a 10 f0       	push   $0xf0103afc
f010071e:	e8 12 20 00 00       	call   f0102735 <cprintf>
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
f0100758:	68 b6 39 10 f0       	push   $0xf01039b6
f010075d:	e8 d3 1f 00 00       	call   f0102735 <cprintf>

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
f010078a:	e8 b0 20 00 00       	call   f010283f <debuginfo_eip>

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
f01007e6:	68 28 3b 10 f0       	push   $0xf0103b28
f01007eb:	e8 45 1f 00 00       	call   f0102735 <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f01007f0:	83 c4 14             	add    $0x14,%esp
f01007f3:	2b 75 cc             	sub    -0x34(%ebp),%esi
f01007f6:	56                   	push   %esi
f01007f7:	8d 45 8a             	lea    -0x76(%ebp),%eax
f01007fa:	50                   	push   %eax
f01007fb:	ff 75 c0             	pushl  -0x40(%ebp)
f01007fe:	ff 75 bc             	pushl  -0x44(%ebp)
f0100801:	68 c8 39 10 f0       	push   $0xf01039c8
f0100806:	e8 2a 1f 00 00       	call   f0102735 <cprintf>

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
f010082e:	68 60 3b 10 f0       	push   $0xf0103b60
f0100833:	e8 fd 1e 00 00       	call   f0102735 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100838:	c7 04 24 84 3b 10 f0 	movl   $0xf0103b84,(%esp)
f010083f:	e8 f1 1e 00 00       	call   f0102735 <cprintf>
f0100844:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100847:	83 ec 0c             	sub    $0xc,%esp
f010084a:	68 df 39 10 f0       	push   $0xf01039df
f010084f:	e8 4e 27 00 00       	call   f0102fa2 <readline>
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
f0100883:	68 e3 39 10 f0       	push   $0xf01039e3
f0100888:	e8 2f 29 00 00       	call   f01031bc <strchr>
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
f01008a3:	68 e8 39 10 f0       	push   $0xf01039e8
f01008a8:	e8 88 1e 00 00       	call   f0102735 <cprintf>
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
f01008cc:	68 e3 39 10 f0       	push   $0xf01039e3
f01008d1:	e8 e6 28 00 00       	call   f01031bc <strchr>
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
f01008fa:	ff 34 85 c0 3b 10 f0 	pushl  -0xfefc440(,%eax,4)
f0100901:	ff 75 a8             	pushl  -0x58(%ebp)
f0100904:	e8 55 28 00 00       	call   f010315e <strcmp>
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
f010091e:	ff 14 85 c8 3b 10 f0 	call   *-0xfefc438(,%eax,4)


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
f010093f:	68 05 3a 10 f0       	push   $0xf0103a05
f0100944:	e8 ec 1d 00 00       	call   f0102735 <cprintf>
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
f0100964:	e8 65 1d 00 00       	call   f01026ce <mc146818_read>
f0100969:	89 c6                	mov    %eax,%esi
f010096b:	83 c3 01             	add    $0x1,%ebx
f010096e:	89 1c 24             	mov    %ebx,(%esp)
f0100971:	e8 58 1d 00 00       	call   f01026ce <mc146818_read>
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
f01009b0:	68 e4 3b 10 f0       	push   $0xf0103be4
f01009b5:	6a 6b                	push   $0x6b
f01009b7:	68 ff 3b 10 f0       	push   $0xf0103bff
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
f01009fa:	68 e4 3e 10 f0       	push   $0xf0103ee4
f01009ff:	68 48 03 00 00       	push   $0x348
f0100a04:	68 ff 3b 10 f0       	push   $0xf0103bff
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
f0100a52:	68 08 3f 10 f0       	push   $0xf0103f08
f0100a57:	68 87 02 00 00       	push   $0x287
f0100a5c:	68 ff 3b 10 f0       	push   $0xf0103bff
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
f0100ae1:	68 e4 3e 10 f0       	push   $0xf0103ee4
f0100ae6:	6a 52                	push   $0x52
f0100ae8:	68 0b 3c 10 f0       	push   $0xf0103c0b
f0100aed:	e8 99 f5 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100af2:	83 ec 04             	sub    $0x4,%esp
f0100af5:	68 80 00 00 00       	push   $0x80
f0100afa:	68 97 00 00 00       	push   $0x97
f0100aff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b04:	50                   	push   %eax
f0100b05:	e8 ef 26 00 00       	call   f01031f9 <memset>
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
f0100b4b:	68 19 3c 10 f0       	push   $0xf0103c19
f0100b50:	68 25 3c 10 f0       	push   $0xf0103c25
f0100b55:	68 a1 02 00 00       	push   $0x2a1
f0100b5a:	68 ff 3b 10 f0       	push   $0xf0103bff
f0100b5f:	e8 27 f5 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100b64:	39 fa                	cmp    %edi,%edx
f0100b66:	72 19                	jb     f0100b81 <check_page_free_list+0x148>
f0100b68:	68 3a 3c 10 f0       	push   $0xf0103c3a
f0100b6d:	68 25 3c 10 f0       	push   $0xf0103c25
f0100b72:	68 a2 02 00 00       	push   $0x2a2
f0100b77:	68 ff 3b 10 f0       	push   $0xf0103bff
f0100b7c:	e8 0a f5 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b81:	89 d0                	mov    %edx,%eax
f0100b83:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b86:	a8 07                	test   $0x7,%al
f0100b88:	74 19                	je     f0100ba3 <check_page_free_list+0x16a>
f0100b8a:	68 2c 3f 10 f0       	push   $0xf0103f2c
f0100b8f:	68 25 3c 10 f0       	push   $0xf0103c25
f0100b94:	68 a3 02 00 00       	push   $0x2a3
f0100b99:	68 ff 3b 10 f0       	push   $0xf0103bff
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
f0100bad:	68 4e 3c 10 f0       	push   $0xf0103c4e
f0100bb2:	68 25 3c 10 f0       	push   $0xf0103c25
f0100bb7:	68 a6 02 00 00       	push   $0x2a6
f0100bbc:	68 ff 3b 10 f0       	push   $0xf0103bff
f0100bc1:	e8 c5 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bc6:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bcb:	75 19                	jne    f0100be6 <check_page_free_list+0x1ad>
f0100bcd:	68 5f 3c 10 f0       	push   $0xf0103c5f
f0100bd2:	68 25 3c 10 f0       	push   $0xf0103c25
f0100bd7:	68 a7 02 00 00       	push   $0x2a7
f0100bdc:	68 ff 3b 10 f0       	push   $0xf0103bff
f0100be1:	e8 a5 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100be6:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100beb:	75 19                	jne    f0100c06 <check_page_free_list+0x1cd>
f0100bed:	68 60 3f 10 f0       	push   $0xf0103f60
f0100bf2:	68 25 3c 10 f0       	push   $0xf0103c25
f0100bf7:	68 a8 02 00 00       	push   $0x2a8
f0100bfc:	68 ff 3b 10 f0       	push   $0xf0103bff
f0100c01:	e8 85 f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c06:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c0b:	75 19                	jne    f0100c26 <check_page_free_list+0x1ed>
f0100c0d:	68 78 3c 10 f0       	push   $0xf0103c78
f0100c12:	68 25 3c 10 f0       	push   $0xf0103c25
f0100c17:	68 a9 02 00 00       	push   $0x2a9
f0100c1c:	68 ff 3b 10 f0       	push   $0xf0103bff
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
f0100c38:	68 e4 3e 10 f0       	push   $0xf0103ee4
f0100c3d:	6a 52                	push   $0x52
f0100c3f:	68 0b 3c 10 f0       	push   $0xf0103c0b
f0100c44:	e8 42 f4 ff ff       	call   f010008b <_panic>
f0100c49:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c4e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c51:	76 1e                	jbe    f0100c71 <check_page_free_list+0x238>
f0100c53:	68 84 3f 10 f0       	push   $0xf0103f84
f0100c58:	68 25 3c 10 f0       	push   $0xf0103c25
f0100c5d:	68 aa 02 00 00       	push   $0x2aa
f0100c62:	68 ff 3b 10 f0       	push   $0xf0103bff
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
f0100c86:	68 92 3c 10 f0       	push   $0xf0103c92
f0100c8b:	68 25 3c 10 f0       	push   $0xf0103c25
f0100c90:	68 b2 02 00 00       	push   $0x2b2
f0100c95:	68 ff 3b 10 f0       	push   $0xf0103bff
f0100c9a:	e8 ec f3 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100c9f:	85 db                	test   %ebx,%ebx
f0100ca1:	7f 19                	jg     f0100cbc <check_page_free_list+0x283>
f0100ca3:	68 a4 3c 10 f0       	push   $0xf0103ca4
f0100ca8:	68 25 3c 10 f0       	push   $0xf0103c25
f0100cad:	68 b3 02 00 00       	push   $0x2b3
f0100cb2:	68 ff 3b 10 f0       	push   $0xf0103bff
f0100cb7:	e8 cf f3 ff ff       	call   f010008b <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100cbc:	83 ec 0c             	sub    $0xc,%esp
f0100cbf:	68 cc 3f 10 f0       	push   $0xf0103fcc
f0100cc4:	e8 6c 1a 00 00       	call   f0102735 <cprintf>
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
f0100e08:	68 f0 3f 10 f0       	push   $0xf0103ff0
f0100e0d:	68 2e 01 00 00       	push   $0x12e
f0100e12:	68 ff 3b 10 f0       	push   $0xf0103bff
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
f0100eb1:	68 e4 3e 10 f0       	push   $0xf0103ee4
f0100eb6:	6a 52                	push   $0x52
f0100eb8:	68 0b 3c 10 f0       	push   $0xf0103c0b
f0100ebd:	e8 c9 f1 ff ff       	call   f010008b <_panic>
		// cprintf("[?] alloc zero, %x, %x\n", page_free_list, PADDR(page_free_list));
		// memset((char *)page2pa(page_free_list), 0, PGSIZE);
		memset(page2kva(page_free_list), 0, PGSIZE);
f0100ec2:	83 ec 04             	sub    $0x4,%esp
f0100ec5:	68 00 10 00 00       	push   $0x1000
f0100eca:	6a 00                	push   $0x0
f0100ecc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ed1:	50                   	push   %eax
f0100ed2:	e8 22 23 00 00       	call   f01031f9 <memset>
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
f0100efe:	68 14 40 10 f0       	push   $0xf0104014
f0100f03:	68 73 01 00 00       	push   $0x173
f0100f08:	68 ff 3b 10 f0       	push   $0xf0103bff
f0100f0d:	e8 79 f1 ff ff       	call   f010008b <_panic>
	if (pp->pp_ref != 0)
f0100f12:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f17:	74 17                	je     f0100f30 <page_free+0x47>
		panic("page_free: other pointers still point to it, mind use-after-free!\n");
f0100f19:	83 ec 04             	sub    $0x4,%esp
f0100f1c:	68 3c 40 10 f0       	push   $0xf010403c
f0100f21:	68 75 01 00 00       	push   $0x175
f0100f26:	68 ff 3b 10 f0       	push   $0xf0103bff
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
f0100fc3:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0100fc9:	72 15                	jb     f0100fe0 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fcb:	50                   	push   %eax
f0100fcc:	68 e4 3e 10 f0       	push   $0xf0103ee4
f0100fd1:	68 bf 01 00 00       	push   $0x1bf
f0100fd6:	68 ff 3b 10 f0       	push   $0xf0103bff
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
f0101035:	68 80 40 10 f0       	push   $0xf0104080
f010103a:	6a 4b                	push   $0x4b
f010103c:	68 0b 3c 10 f0       	push   $0xf0103c0b
f0101041:	e8 45 f0 ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0101046:	8b 15 70 79 11 f0    	mov    0xf0117970,%edx
f010104c:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte)) ;
f010104f:	eb 0c                	jmp    f010105d <page_lookup+0x61>
	// do a page table walk to find real PTE
	pte_t * pte = pgdir_walk(pgdir, va, 0);

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
f0101066:	83 ec 08             	sub    $0x8,%esp
f0101069:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	pte_t **pte_store = NULL;
	struct PageInfo * pp = page_lookup(pgdir, va, pte_store);
f010106c:	6a 00                	push   $0x0
f010106e:	53                   	push   %ebx
f010106f:	ff 75 08             	pushl  0x8(%ebp)
f0101072:	e8 85 ff ff ff       	call   f0100ffc <page_lookup>

	// if not present, silently return
	if (pp == NULL)
f0101077:	83 c4 10             	add    $0x10,%esp
f010107a:	85 c0                	test   %eax,%eax
f010107c:	74 1a                	je     f0101098 <page_remove+0x36>
		return;
	
	// decrement ref count, and if reaches 0, free it
	page_decref(pp);
f010107e:	83 ec 0c             	sub    $0xc,%esp
f0101081:	50                   	push   %eax
f0101082:	e8 b8 fe ff ff       	call   f0100f3f <page_decref>

	// null the real PTE pointer 
	**pte_store = 0;
f0101087:	a1 00 00 00 00       	mov    0x0,%eax
f010108c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101092:	0f 01 3b             	invlpg (%ebx)
f0101095:	83 c4 10             	add    $0x10,%esp

	// tlb invalidate
	tlb_invalidate(pgdir, va);

}
f0101098:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010109b:	c9                   	leave  
f010109c:	c3                   	ret    

f010109d <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010109d:	55                   	push   %ebp
f010109e:	89 e5                	mov    %esp,%ebp
f01010a0:	57                   	push   %edi
f01010a1:	56                   	push   %esi
f01010a2:	53                   	push   %ebx
f01010a3:	83 ec 10             	sub    $0x10,%esp
f01010a6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01010a9:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	
f01010ac:	6a 01                	push   $0x1
f01010ae:	57                   	push   %edi
f01010af:	ff 75 08             	pushl  0x8(%ebp)
f01010b2:	e8 af fe ff ff       	call   f0100f66 <pgdir_walk>

	if (pte == 0)
f01010b7:	83 c4 10             	add    $0x10,%esp
f01010ba:	85 c0                	test   %eax,%eax
f01010bc:	74 3a                	je     f01010f8 <page_insert+0x5b>
f01010be:	89 c3                	mov    %eax,%ebx
		return -E_NO_MEM;

	// already have a page
	// remove it and invalidate tlb
	if (*pte != 0) 
f01010c0:	83 38 00             	cmpl   $0x0,(%eax)
f01010c3:	74 0f                	je     f01010d4 <page_insert+0x37>
		page_remove(pgdir, va);
f01010c5:	83 ec 08             	sub    $0x8,%esp
f01010c8:	57                   	push   %edi
f01010c9:	ff 75 08             	pushl  0x8(%ebp)
f01010cc:	e8 91 ff ff ff       	call   f0101062 <page_remove>
f01010d1:	83 c4 10             	add    $0x10,%esp

	// set the real PTE to pa, zero out least 12 bits
	*pte = PTE_ADDR(page2pa(pp));
	
	// set flags
	*pte |= (perm | PTE_P);
f01010d4:	89 f0                	mov    %esi,%eax
f01010d6:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01010dc:	c1 f8 03             	sar    $0x3,%eax
f01010df:	c1 e0 0c             	shl    $0xc,%eax
f01010e2:	8b 55 14             	mov    0x14(%ebp),%edx
f01010e5:	83 ca 01             	or     $0x1,%edx
f01010e8:	09 d0                	or     %edx,%eax
f01010ea:	89 03                	mov    %eax,(%ebx)

	// increment ref cnt
	pp->pp_ref++;
f01010ec:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

	return 0;
f01010f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01010f6:	eb 05                	jmp    f01010fd <page_insert+0x60>
	// find the real PTE for va
	// create on walk, if not present
	pte_t* pte = pgdir_walk(pgdir, (void *)va, 1);	

	if (pte == 0)
		return -E_NO_MEM;
f01010f8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	// increment ref cnt
	pp->pp_ref++;

	return 0;
}
f01010fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101100:	5b                   	pop    %ebx
f0101101:	5e                   	pop    %esi
f0101102:	5f                   	pop    %edi
f0101103:	5d                   	pop    %ebp
f0101104:	c3                   	ret    

f0101105 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101105:	55                   	push   %ebp
f0101106:	89 e5                	mov    %esp,%ebp
f0101108:	57                   	push   %edi
f0101109:	56                   	push   %esi
f010110a:	53                   	push   %ebx
f010110b:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f010110e:	b8 15 00 00 00       	mov    $0x15,%eax
f0101113:	e8 41 f8 ff ff       	call   f0100959 <nvram_read>
f0101118:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010111a:	b8 17 00 00 00       	mov    $0x17,%eax
f010111f:	e8 35 f8 ff ff       	call   f0100959 <nvram_read>
f0101124:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101126:	b8 34 00 00 00       	mov    $0x34,%eax
f010112b:	e8 29 f8 ff ff       	call   f0100959 <nvram_read>
f0101130:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101133:	85 c0                	test   %eax,%eax
f0101135:	74 07                	je     f010113e <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0101137:	05 00 40 00 00       	add    $0x4000,%eax
f010113c:	eb 0b                	jmp    f0101149 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f010113e:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101144:	85 f6                	test   %esi,%esi
f0101146:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0101149:	89 c2                	mov    %eax,%edx
f010114b:	c1 ea 02             	shr    $0x2,%edx
f010114e:	89 15 68 79 11 f0    	mov    %edx,0xf0117968
	npages_basemem = basemem / (PGSIZE / 1024);
f0101154:	89 da                	mov    %ebx,%edx
f0101156:	c1 ea 02             	shr    $0x2,%edx
f0101159:	89 15 40 75 11 f0    	mov    %edx,0xf0117540

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010115f:	89 c2                	mov    %eax,%edx
f0101161:	29 da                	sub    %ebx,%edx
f0101163:	52                   	push   %edx
f0101164:	53                   	push   %ebx
f0101165:	50                   	push   %eax
f0101166:	68 a0 40 10 f0       	push   $0xf01040a0
f010116b:	e8 c5 15 00 00       	call   f0102735 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101170:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101175:	e8 08 f8 ff ff       	call   f0100982 <boot_alloc>
f010117a:	a3 6c 79 11 f0       	mov    %eax,0xf011796c
	memset(kern_pgdir, 0, PGSIZE);
f010117f:	83 c4 0c             	add    $0xc,%esp
f0101182:	68 00 10 00 00       	push   $0x1000
f0101187:	6a 00                	push   $0x0
f0101189:	50                   	push   %eax
f010118a:	e8 6a 20 00 00       	call   f01031f9 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010118f:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101194:	83 c4 10             	add    $0x10,%esp
f0101197:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010119c:	77 15                	ja     f01011b3 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010119e:	50                   	push   %eax
f010119f:	68 f0 3f 10 f0       	push   $0xf0103ff0
f01011a4:	68 96 00 00 00       	push   $0x96
f01011a9:	68 ff 3b 10 f0       	push   $0xf0103bff
f01011ae:	e8 d8 ee ff ff       	call   f010008b <_panic>
f01011b3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01011b9:	83 ca 05             	or     $0x5,%edx
f01011bc:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	n = npages * sizeof(struct PageInfo);
f01011c2:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01011c7:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f01011ce:	89 d8                	mov    %ebx,%eax
f01011d0:	e8 ad f7 ff ff       	call   f0100982 <boot_alloc>
f01011d5:	a3 70 79 11 f0       	mov    %eax,0xf0117970
	memset(pages, 0, n);
f01011da:	83 ec 04             	sub    $0x4,%esp
f01011dd:	53                   	push   %ebx
f01011de:	6a 00                	push   $0x0
f01011e0:	50                   	push   %eax
f01011e1:	e8 13 20 00 00       	call   f01031f9 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01011e6:	e8 11 fb ff ff       	call   f0100cfc <page_init>

	check_page_free_list(1);
f01011eb:	b8 01 00 00 00       	mov    $0x1,%eax
f01011f0:	e8 44 f8 ff ff       	call   f0100a39 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01011f5:	83 c4 10             	add    $0x10,%esp
f01011f8:	83 3d 70 79 11 f0 00 	cmpl   $0x0,0xf0117970
f01011ff:	75 17                	jne    f0101218 <mem_init+0x113>
		panic("'pages' is a null pointer!");
f0101201:	83 ec 04             	sub    $0x4,%esp
f0101204:	68 b5 3c 10 f0       	push   $0xf0103cb5
f0101209:	68 c6 02 00 00       	push   $0x2c6
f010120e:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101213:	e8 73 ee ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101218:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010121d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101222:	eb 05                	jmp    f0101229 <mem_init+0x124>
		++nfree;
f0101224:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101227:	8b 00                	mov    (%eax),%eax
f0101229:	85 c0                	test   %eax,%eax
f010122b:	75 f7                	jne    f0101224 <mem_init+0x11f>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010122d:	83 ec 0c             	sub    $0xc,%esp
f0101230:	6a 00                	push   $0x0
f0101232:	e8 41 fc ff ff       	call   f0100e78 <page_alloc>
f0101237:	89 c7                	mov    %eax,%edi
f0101239:	83 c4 10             	add    $0x10,%esp
f010123c:	85 c0                	test   %eax,%eax
f010123e:	75 19                	jne    f0101259 <mem_init+0x154>
f0101240:	68 d0 3c 10 f0       	push   $0xf0103cd0
f0101245:	68 25 3c 10 f0       	push   $0xf0103c25
f010124a:	68 ce 02 00 00       	push   $0x2ce
f010124f:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101254:	e8 32 ee ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101259:	83 ec 0c             	sub    $0xc,%esp
f010125c:	6a 00                	push   $0x0
f010125e:	e8 15 fc ff ff       	call   f0100e78 <page_alloc>
f0101263:	89 c6                	mov    %eax,%esi
f0101265:	83 c4 10             	add    $0x10,%esp
f0101268:	85 c0                	test   %eax,%eax
f010126a:	75 19                	jne    f0101285 <mem_init+0x180>
f010126c:	68 e6 3c 10 f0       	push   $0xf0103ce6
f0101271:	68 25 3c 10 f0       	push   $0xf0103c25
f0101276:	68 cf 02 00 00       	push   $0x2cf
f010127b:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101280:	e8 06 ee ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101285:	83 ec 0c             	sub    $0xc,%esp
f0101288:	6a 00                	push   $0x0
f010128a:	e8 e9 fb ff ff       	call   f0100e78 <page_alloc>
f010128f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101292:	83 c4 10             	add    $0x10,%esp
f0101295:	85 c0                	test   %eax,%eax
f0101297:	75 19                	jne    f01012b2 <mem_init+0x1ad>
f0101299:	68 fc 3c 10 f0       	push   $0xf0103cfc
f010129e:	68 25 3c 10 f0       	push   $0xf0103c25
f01012a3:	68 d0 02 00 00       	push   $0x2d0
f01012a8:	68 ff 3b 10 f0       	push   $0xf0103bff
f01012ad:	e8 d9 ed ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01012b2:	39 f7                	cmp    %esi,%edi
f01012b4:	75 19                	jne    f01012cf <mem_init+0x1ca>
f01012b6:	68 12 3d 10 f0       	push   $0xf0103d12
f01012bb:	68 25 3c 10 f0       	push   $0xf0103c25
f01012c0:	68 d3 02 00 00       	push   $0x2d3
f01012c5:	68 ff 3b 10 f0       	push   $0xf0103bff
f01012ca:	e8 bc ed ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012d2:	39 c6                	cmp    %eax,%esi
f01012d4:	74 04                	je     f01012da <mem_init+0x1d5>
f01012d6:	39 c7                	cmp    %eax,%edi
f01012d8:	75 19                	jne    f01012f3 <mem_init+0x1ee>
f01012da:	68 dc 40 10 f0       	push   $0xf01040dc
f01012df:	68 25 3c 10 f0       	push   $0xf0103c25
f01012e4:	68 d4 02 00 00       	push   $0x2d4
f01012e9:	68 ff 3b 10 f0       	push   $0xf0103bff
f01012ee:	e8 98 ed ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012f3:	8b 0d 70 79 11 f0    	mov    0xf0117970,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01012f9:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f01012ff:	c1 e2 0c             	shl    $0xc,%edx
f0101302:	89 f8                	mov    %edi,%eax
f0101304:	29 c8                	sub    %ecx,%eax
f0101306:	c1 f8 03             	sar    $0x3,%eax
f0101309:	c1 e0 0c             	shl    $0xc,%eax
f010130c:	39 d0                	cmp    %edx,%eax
f010130e:	72 19                	jb     f0101329 <mem_init+0x224>
f0101310:	68 24 3d 10 f0       	push   $0xf0103d24
f0101315:	68 25 3c 10 f0       	push   $0xf0103c25
f010131a:	68 d5 02 00 00       	push   $0x2d5
f010131f:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101324:	e8 62 ed ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101329:	89 f0                	mov    %esi,%eax
f010132b:	29 c8                	sub    %ecx,%eax
f010132d:	c1 f8 03             	sar    $0x3,%eax
f0101330:	c1 e0 0c             	shl    $0xc,%eax
f0101333:	39 c2                	cmp    %eax,%edx
f0101335:	77 19                	ja     f0101350 <mem_init+0x24b>
f0101337:	68 41 3d 10 f0       	push   $0xf0103d41
f010133c:	68 25 3c 10 f0       	push   $0xf0103c25
f0101341:	68 d6 02 00 00       	push   $0x2d6
f0101346:	68 ff 3b 10 f0       	push   $0xf0103bff
f010134b:	e8 3b ed ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101350:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101353:	29 c8                	sub    %ecx,%eax
f0101355:	c1 f8 03             	sar    $0x3,%eax
f0101358:	c1 e0 0c             	shl    $0xc,%eax
f010135b:	39 c2                	cmp    %eax,%edx
f010135d:	77 19                	ja     f0101378 <mem_init+0x273>
f010135f:	68 5e 3d 10 f0       	push   $0xf0103d5e
f0101364:	68 25 3c 10 f0       	push   $0xf0103c25
f0101369:	68 d7 02 00 00       	push   $0x2d7
f010136e:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101373:	e8 13 ed ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101378:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010137d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101380:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0101387:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010138a:	83 ec 0c             	sub    $0xc,%esp
f010138d:	6a 00                	push   $0x0
f010138f:	e8 e4 fa ff ff       	call   f0100e78 <page_alloc>
f0101394:	83 c4 10             	add    $0x10,%esp
f0101397:	85 c0                	test   %eax,%eax
f0101399:	74 19                	je     f01013b4 <mem_init+0x2af>
f010139b:	68 7b 3d 10 f0       	push   $0xf0103d7b
f01013a0:	68 25 3c 10 f0       	push   $0xf0103c25
f01013a5:	68 de 02 00 00       	push   $0x2de
f01013aa:	68 ff 3b 10 f0       	push   $0xf0103bff
f01013af:	e8 d7 ec ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f01013b4:	83 ec 0c             	sub    $0xc,%esp
f01013b7:	57                   	push   %edi
f01013b8:	e8 2c fb ff ff       	call   f0100ee9 <page_free>
	page_free(pp1);
f01013bd:	89 34 24             	mov    %esi,(%esp)
f01013c0:	e8 24 fb ff ff       	call   f0100ee9 <page_free>
	page_free(pp2);
f01013c5:	83 c4 04             	add    $0x4,%esp
f01013c8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01013cb:	e8 19 fb ff ff       	call   f0100ee9 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013d7:	e8 9c fa ff ff       	call   f0100e78 <page_alloc>
f01013dc:	89 c6                	mov    %eax,%esi
f01013de:	83 c4 10             	add    $0x10,%esp
f01013e1:	85 c0                	test   %eax,%eax
f01013e3:	75 19                	jne    f01013fe <mem_init+0x2f9>
f01013e5:	68 d0 3c 10 f0       	push   $0xf0103cd0
f01013ea:	68 25 3c 10 f0       	push   $0xf0103c25
f01013ef:	68 e5 02 00 00       	push   $0x2e5
f01013f4:	68 ff 3b 10 f0       	push   $0xf0103bff
f01013f9:	e8 8d ec ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01013fe:	83 ec 0c             	sub    $0xc,%esp
f0101401:	6a 00                	push   $0x0
f0101403:	e8 70 fa ff ff       	call   f0100e78 <page_alloc>
f0101408:	89 c7                	mov    %eax,%edi
f010140a:	83 c4 10             	add    $0x10,%esp
f010140d:	85 c0                	test   %eax,%eax
f010140f:	75 19                	jne    f010142a <mem_init+0x325>
f0101411:	68 e6 3c 10 f0       	push   $0xf0103ce6
f0101416:	68 25 3c 10 f0       	push   $0xf0103c25
f010141b:	68 e6 02 00 00       	push   $0x2e6
f0101420:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101425:	e8 61 ec ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010142a:	83 ec 0c             	sub    $0xc,%esp
f010142d:	6a 00                	push   $0x0
f010142f:	e8 44 fa ff ff       	call   f0100e78 <page_alloc>
f0101434:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101437:	83 c4 10             	add    $0x10,%esp
f010143a:	85 c0                	test   %eax,%eax
f010143c:	75 19                	jne    f0101457 <mem_init+0x352>
f010143e:	68 fc 3c 10 f0       	push   $0xf0103cfc
f0101443:	68 25 3c 10 f0       	push   $0xf0103c25
f0101448:	68 e7 02 00 00       	push   $0x2e7
f010144d:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101452:	e8 34 ec ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101457:	39 fe                	cmp    %edi,%esi
f0101459:	75 19                	jne    f0101474 <mem_init+0x36f>
f010145b:	68 12 3d 10 f0       	push   $0xf0103d12
f0101460:	68 25 3c 10 f0       	push   $0xf0103c25
f0101465:	68 e9 02 00 00       	push   $0x2e9
f010146a:	68 ff 3b 10 f0       	push   $0xf0103bff
f010146f:	e8 17 ec ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101474:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101477:	39 c7                	cmp    %eax,%edi
f0101479:	74 04                	je     f010147f <mem_init+0x37a>
f010147b:	39 c6                	cmp    %eax,%esi
f010147d:	75 19                	jne    f0101498 <mem_init+0x393>
f010147f:	68 dc 40 10 f0       	push   $0xf01040dc
f0101484:	68 25 3c 10 f0       	push   $0xf0103c25
f0101489:	68 ea 02 00 00       	push   $0x2ea
f010148e:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101493:	e8 f3 eb ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101498:	83 ec 0c             	sub    $0xc,%esp
f010149b:	6a 00                	push   $0x0
f010149d:	e8 d6 f9 ff ff       	call   f0100e78 <page_alloc>
f01014a2:	83 c4 10             	add    $0x10,%esp
f01014a5:	85 c0                	test   %eax,%eax
f01014a7:	74 19                	je     f01014c2 <mem_init+0x3bd>
f01014a9:	68 7b 3d 10 f0       	push   $0xf0103d7b
f01014ae:	68 25 3c 10 f0       	push   $0xf0103c25
f01014b3:	68 eb 02 00 00       	push   $0x2eb
f01014b8:	68 ff 3b 10 f0       	push   $0xf0103bff
f01014bd:	e8 c9 eb ff ff       	call   f010008b <_panic>
f01014c2:	89 f0                	mov    %esi,%eax
f01014c4:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01014ca:	c1 f8 03             	sar    $0x3,%eax
f01014cd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014d0:	89 c2                	mov    %eax,%edx
f01014d2:	c1 ea 0c             	shr    $0xc,%edx
f01014d5:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f01014db:	72 12                	jb     f01014ef <mem_init+0x3ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014dd:	50                   	push   %eax
f01014de:	68 e4 3e 10 f0       	push   $0xf0103ee4
f01014e3:	6a 52                	push   $0x52
f01014e5:	68 0b 3c 10 f0       	push   $0xf0103c0b
f01014ea:	e8 9c eb ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01014ef:	83 ec 04             	sub    $0x4,%esp
f01014f2:	68 00 10 00 00       	push   $0x1000
f01014f7:	6a 01                	push   $0x1
f01014f9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01014fe:	50                   	push   %eax
f01014ff:	e8 f5 1c 00 00       	call   f01031f9 <memset>
	page_free(pp0);
f0101504:	89 34 24             	mov    %esi,(%esp)
f0101507:	e8 dd f9 ff ff       	call   f0100ee9 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010150c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101513:	e8 60 f9 ff ff       	call   f0100e78 <page_alloc>
f0101518:	83 c4 10             	add    $0x10,%esp
f010151b:	85 c0                	test   %eax,%eax
f010151d:	75 19                	jne    f0101538 <mem_init+0x433>
f010151f:	68 8a 3d 10 f0       	push   $0xf0103d8a
f0101524:	68 25 3c 10 f0       	push   $0xf0103c25
f0101529:	68 f0 02 00 00       	push   $0x2f0
f010152e:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101533:	e8 53 eb ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f0101538:	39 c6                	cmp    %eax,%esi
f010153a:	74 19                	je     f0101555 <mem_init+0x450>
f010153c:	68 a8 3d 10 f0       	push   $0xf0103da8
f0101541:	68 25 3c 10 f0       	push   $0xf0103c25
f0101546:	68 f1 02 00 00       	push   $0x2f1
f010154b:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101550:	e8 36 eb ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101555:	89 f0                	mov    %esi,%eax
f0101557:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f010155d:	c1 f8 03             	sar    $0x3,%eax
f0101560:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101563:	89 c2                	mov    %eax,%edx
f0101565:	c1 ea 0c             	shr    $0xc,%edx
f0101568:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f010156e:	72 12                	jb     f0101582 <mem_init+0x47d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101570:	50                   	push   %eax
f0101571:	68 e4 3e 10 f0       	push   $0xf0103ee4
f0101576:	6a 52                	push   $0x52
f0101578:	68 0b 3c 10 f0       	push   $0xf0103c0b
f010157d:	e8 09 eb ff ff       	call   f010008b <_panic>
f0101582:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101588:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
f010158e:	80 38 00             	cmpb   $0x0,(%eax)
f0101591:	74 19                	je     f01015ac <mem_init+0x4a7>
f0101593:	68 b8 3d 10 f0       	push   $0xf0103db8
f0101598:	68 25 3c 10 f0       	push   $0xf0103c25
f010159d:	68 f5 02 00 00       	push   $0x2f5
f01015a2:	68 ff 3b 10 f0       	push   $0xf0103bff
f01015a7:	e8 df ea ff ff       	call   f010008b <_panic>
f01015ac:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) {
f01015af:	39 d0                	cmp    %edx,%eax
f01015b1:	75 db                	jne    f010158e <mem_init+0x489>
		// cprintf("[?] %d\n", i);
		assert(c[i] == 0);
	}

	// give free list back
	page_free_list = fl;
f01015b3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015b6:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f01015bb:	83 ec 0c             	sub    $0xc,%esp
f01015be:	56                   	push   %esi
f01015bf:	e8 25 f9 ff ff       	call   f0100ee9 <page_free>
	page_free(pp1);
f01015c4:	89 3c 24             	mov    %edi,(%esp)
f01015c7:	e8 1d f9 ff ff       	call   f0100ee9 <page_free>
	page_free(pp2);
f01015cc:	83 c4 04             	add    $0x4,%esp
f01015cf:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015d2:	e8 12 f9 ff ff       	call   f0100ee9 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015d7:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01015dc:	83 c4 10             	add    $0x10,%esp
f01015df:	eb 05                	jmp    f01015e6 <mem_init+0x4e1>
		--nfree;
f01015e1:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015e4:	8b 00                	mov    (%eax),%eax
f01015e6:	85 c0                	test   %eax,%eax
f01015e8:	75 f7                	jne    f01015e1 <mem_init+0x4dc>
		--nfree;
	assert(nfree == 0);
f01015ea:	85 db                	test   %ebx,%ebx
f01015ec:	74 19                	je     f0101607 <mem_init+0x502>
f01015ee:	68 c2 3d 10 f0       	push   $0xf0103dc2
f01015f3:	68 25 3c 10 f0       	push   $0xf0103c25
f01015f8:	68 03 03 00 00       	push   $0x303
f01015fd:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101602:	e8 84 ea ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101607:	83 ec 0c             	sub    $0xc,%esp
f010160a:	68 fc 40 10 f0       	push   $0xf01040fc
f010160f:	e8 21 11 00 00       	call   f0102735 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101614:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010161b:	e8 58 f8 ff ff       	call   f0100e78 <page_alloc>
f0101620:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101623:	83 c4 10             	add    $0x10,%esp
f0101626:	85 c0                	test   %eax,%eax
f0101628:	75 19                	jne    f0101643 <mem_init+0x53e>
f010162a:	68 d0 3c 10 f0       	push   $0xf0103cd0
f010162f:	68 25 3c 10 f0       	push   $0xf0103c25
f0101634:	68 5c 03 00 00       	push   $0x35c
f0101639:	68 ff 3b 10 f0       	push   $0xf0103bff
f010163e:	e8 48 ea ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101643:	83 ec 0c             	sub    $0xc,%esp
f0101646:	6a 00                	push   $0x0
f0101648:	e8 2b f8 ff ff       	call   f0100e78 <page_alloc>
f010164d:	89 c3                	mov    %eax,%ebx
f010164f:	83 c4 10             	add    $0x10,%esp
f0101652:	85 c0                	test   %eax,%eax
f0101654:	75 19                	jne    f010166f <mem_init+0x56a>
f0101656:	68 e6 3c 10 f0       	push   $0xf0103ce6
f010165b:	68 25 3c 10 f0       	push   $0xf0103c25
f0101660:	68 5d 03 00 00       	push   $0x35d
f0101665:	68 ff 3b 10 f0       	push   $0xf0103bff
f010166a:	e8 1c ea ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010166f:	83 ec 0c             	sub    $0xc,%esp
f0101672:	6a 00                	push   $0x0
f0101674:	e8 ff f7 ff ff       	call   f0100e78 <page_alloc>
f0101679:	89 c6                	mov    %eax,%esi
f010167b:	83 c4 10             	add    $0x10,%esp
f010167e:	85 c0                	test   %eax,%eax
f0101680:	75 19                	jne    f010169b <mem_init+0x596>
f0101682:	68 fc 3c 10 f0       	push   $0xf0103cfc
f0101687:	68 25 3c 10 f0       	push   $0xf0103c25
f010168c:	68 5e 03 00 00       	push   $0x35e
f0101691:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101696:	e8 f0 e9 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010169b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010169e:	75 19                	jne    f01016b9 <mem_init+0x5b4>
f01016a0:	68 12 3d 10 f0       	push   $0xf0103d12
f01016a5:	68 25 3c 10 f0       	push   $0xf0103c25
f01016aa:	68 61 03 00 00       	push   $0x361
f01016af:	68 ff 3b 10 f0       	push   $0xf0103bff
f01016b4:	e8 d2 e9 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016b9:	39 c3                	cmp    %eax,%ebx
f01016bb:	74 05                	je     f01016c2 <mem_init+0x5bd>
f01016bd:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01016c0:	75 19                	jne    f01016db <mem_init+0x5d6>
f01016c2:	68 dc 40 10 f0       	push   $0xf01040dc
f01016c7:	68 25 3c 10 f0       	push   $0xf0103c25
f01016cc:	68 62 03 00 00       	push   $0x362
f01016d1:	68 ff 3b 10 f0       	push   $0xf0103bff
f01016d6:	e8 b0 e9 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01016db:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01016e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01016e3:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f01016ea:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016ed:	83 ec 0c             	sub    $0xc,%esp
f01016f0:	6a 00                	push   $0x0
f01016f2:	e8 81 f7 ff ff       	call   f0100e78 <page_alloc>
f01016f7:	83 c4 10             	add    $0x10,%esp
f01016fa:	85 c0                	test   %eax,%eax
f01016fc:	74 19                	je     f0101717 <mem_init+0x612>
f01016fe:	68 7b 3d 10 f0       	push   $0xf0103d7b
f0101703:	68 25 3c 10 f0       	push   $0xf0103c25
f0101708:	68 69 03 00 00       	push   $0x369
f010170d:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101712:	e8 74 e9 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101717:	83 ec 04             	sub    $0x4,%esp
f010171a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010171d:	50                   	push   %eax
f010171e:	6a 00                	push   $0x0
f0101720:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101726:	e8 d1 f8 ff ff       	call   f0100ffc <page_lookup>
f010172b:	83 c4 10             	add    $0x10,%esp
f010172e:	85 c0                	test   %eax,%eax
f0101730:	74 19                	je     f010174b <mem_init+0x646>
f0101732:	68 1c 41 10 f0       	push   $0xf010411c
f0101737:	68 25 3c 10 f0       	push   $0xf0103c25
f010173c:	68 6c 03 00 00       	push   $0x36c
f0101741:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101746:	e8 40 e9 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010174b:	6a 02                	push   $0x2
f010174d:	6a 00                	push   $0x0
f010174f:	53                   	push   %ebx
f0101750:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101756:	e8 42 f9 ff ff       	call   f010109d <page_insert>
f010175b:	83 c4 10             	add    $0x10,%esp
f010175e:	85 c0                	test   %eax,%eax
f0101760:	78 19                	js     f010177b <mem_init+0x676>
f0101762:	68 54 41 10 f0       	push   $0xf0104154
f0101767:	68 25 3c 10 f0       	push   $0xf0103c25
f010176c:	68 6f 03 00 00       	push   $0x36f
f0101771:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101776:	e8 10 e9 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010177b:	83 ec 0c             	sub    $0xc,%esp
f010177e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101781:	e8 63 f7 ff ff       	call   f0100ee9 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101786:	6a 02                	push   $0x2
f0101788:	6a 00                	push   $0x0
f010178a:	53                   	push   %ebx
f010178b:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101791:	e8 07 f9 ff ff       	call   f010109d <page_insert>
f0101796:	83 c4 20             	add    $0x20,%esp
f0101799:	85 c0                	test   %eax,%eax
f010179b:	74 19                	je     f01017b6 <mem_init+0x6b1>
f010179d:	68 84 41 10 f0       	push   $0xf0104184
f01017a2:	68 25 3c 10 f0       	push   $0xf0103c25
f01017a7:	68 73 03 00 00       	push   $0x373
f01017ac:	68 ff 3b 10 f0       	push   $0xf0103bff
f01017b1:	e8 d5 e8 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01017b6:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017bc:	a1 70 79 11 f0       	mov    0xf0117970,%eax
f01017c1:	89 c1                	mov    %eax,%ecx
f01017c3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01017c6:	8b 17                	mov    (%edi),%edx
f01017c8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01017ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017d1:	29 c8                	sub    %ecx,%eax
f01017d3:	c1 f8 03             	sar    $0x3,%eax
f01017d6:	c1 e0 0c             	shl    $0xc,%eax
f01017d9:	39 c2                	cmp    %eax,%edx
f01017db:	74 19                	je     f01017f6 <mem_init+0x6f1>
f01017dd:	68 b4 41 10 f0       	push   $0xf01041b4
f01017e2:	68 25 3c 10 f0       	push   $0xf0103c25
f01017e7:	68 74 03 00 00       	push   $0x374
f01017ec:	68 ff 3b 10 f0       	push   $0xf0103bff
f01017f1:	e8 95 e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01017f6:	ba 00 00 00 00       	mov    $0x0,%edx
f01017fb:	89 f8                	mov    %edi,%eax
f01017fd:	e8 d3 f1 ff ff       	call   f01009d5 <check_va2pa>
f0101802:	89 da                	mov    %ebx,%edx
f0101804:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101807:	c1 fa 03             	sar    $0x3,%edx
f010180a:	c1 e2 0c             	shl    $0xc,%edx
f010180d:	39 d0                	cmp    %edx,%eax
f010180f:	74 19                	je     f010182a <mem_init+0x725>
f0101811:	68 dc 41 10 f0       	push   $0xf01041dc
f0101816:	68 25 3c 10 f0       	push   $0xf0103c25
f010181b:	68 75 03 00 00       	push   $0x375
f0101820:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101825:	e8 61 e8 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f010182a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010182f:	74 19                	je     f010184a <mem_init+0x745>
f0101831:	68 cd 3d 10 f0       	push   $0xf0103dcd
f0101836:	68 25 3c 10 f0       	push   $0xf0103c25
f010183b:	68 76 03 00 00       	push   $0x376
f0101840:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101845:	e8 41 e8 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f010184a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010184d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101852:	74 19                	je     f010186d <mem_init+0x768>
f0101854:	68 de 3d 10 f0       	push   $0xf0103dde
f0101859:	68 25 3c 10 f0       	push   $0xf0103c25
f010185e:	68 77 03 00 00       	push   $0x377
f0101863:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101868:	e8 1e e8 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010186d:	6a 02                	push   $0x2
f010186f:	68 00 10 00 00       	push   $0x1000
f0101874:	56                   	push   %esi
f0101875:	57                   	push   %edi
f0101876:	e8 22 f8 ff ff       	call   f010109d <page_insert>
f010187b:	83 c4 10             	add    $0x10,%esp
f010187e:	85 c0                	test   %eax,%eax
f0101880:	74 19                	je     f010189b <mem_init+0x796>
f0101882:	68 0c 42 10 f0       	push   $0xf010420c
f0101887:	68 25 3c 10 f0       	push   $0xf0103c25
f010188c:	68 7a 03 00 00       	push   $0x37a
f0101891:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101896:	e8 f0 e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010189b:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018a0:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f01018a5:	e8 2b f1 ff ff       	call   f01009d5 <check_va2pa>
f01018aa:	89 f2                	mov    %esi,%edx
f01018ac:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f01018b2:	c1 fa 03             	sar    $0x3,%edx
f01018b5:	c1 e2 0c             	shl    $0xc,%edx
f01018b8:	39 d0                	cmp    %edx,%eax
f01018ba:	74 19                	je     f01018d5 <mem_init+0x7d0>
f01018bc:	68 48 42 10 f0       	push   $0xf0104248
f01018c1:	68 25 3c 10 f0       	push   $0xf0103c25
f01018c6:	68 7b 03 00 00       	push   $0x37b
f01018cb:	68 ff 3b 10 f0       	push   $0xf0103bff
f01018d0:	e8 b6 e7 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01018d5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01018da:	74 19                	je     f01018f5 <mem_init+0x7f0>
f01018dc:	68 ef 3d 10 f0       	push   $0xf0103def
f01018e1:	68 25 3c 10 f0       	push   $0xf0103c25
f01018e6:	68 7c 03 00 00       	push   $0x37c
f01018eb:	68 ff 3b 10 f0       	push   $0xf0103bff
f01018f0:	e8 96 e7 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01018f5:	83 ec 0c             	sub    $0xc,%esp
f01018f8:	6a 00                	push   $0x0
f01018fa:	e8 79 f5 ff ff       	call   f0100e78 <page_alloc>
f01018ff:	83 c4 10             	add    $0x10,%esp
f0101902:	85 c0                	test   %eax,%eax
f0101904:	74 19                	je     f010191f <mem_init+0x81a>
f0101906:	68 7b 3d 10 f0       	push   $0xf0103d7b
f010190b:	68 25 3c 10 f0       	push   $0xf0103c25
f0101910:	68 7f 03 00 00       	push   $0x37f
f0101915:	68 ff 3b 10 f0       	push   $0xf0103bff
f010191a:	e8 6c e7 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010191f:	6a 02                	push   $0x2
f0101921:	68 00 10 00 00       	push   $0x1000
f0101926:	56                   	push   %esi
f0101927:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f010192d:	e8 6b f7 ff ff       	call   f010109d <page_insert>
f0101932:	83 c4 10             	add    $0x10,%esp
f0101935:	85 c0                	test   %eax,%eax
f0101937:	74 19                	je     f0101952 <mem_init+0x84d>
f0101939:	68 0c 42 10 f0       	push   $0xf010420c
f010193e:	68 25 3c 10 f0       	push   $0xf0103c25
f0101943:	68 82 03 00 00       	push   $0x382
f0101948:	68 ff 3b 10 f0       	push   $0xf0103bff
f010194d:	e8 39 e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101952:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101957:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f010195c:	e8 74 f0 ff ff       	call   f01009d5 <check_va2pa>
f0101961:	89 f2                	mov    %esi,%edx
f0101963:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101969:	c1 fa 03             	sar    $0x3,%edx
f010196c:	c1 e2 0c             	shl    $0xc,%edx
f010196f:	39 d0                	cmp    %edx,%eax
f0101971:	74 19                	je     f010198c <mem_init+0x887>
f0101973:	68 48 42 10 f0       	push   $0xf0104248
f0101978:	68 25 3c 10 f0       	push   $0xf0103c25
f010197d:	68 83 03 00 00       	push   $0x383
f0101982:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101987:	e8 ff e6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f010198c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101991:	74 19                	je     f01019ac <mem_init+0x8a7>
f0101993:	68 ef 3d 10 f0       	push   $0xf0103def
f0101998:	68 25 3c 10 f0       	push   $0xf0103c25
f010199d:	68 84 03 00 00       	push   $0x384
f01019a2:	68 ff 3b 10 f0       	push   $0xf0103bff
f01019a7:	e8 df e6 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01019ac:	83 ec 0c             	sub    $0xc,%esp
f01019af:	6a 00                	push   $0x0
f01019b1:	e8 c2 f4 ff ff       	call   f0100e78 <page_alloc>
f01019b6:	83 c4 10             	add    $0x10,%esp
f01019b9:	85 c0                	test   %eax,%eax
f01019bb:	74 19                	je     f01019d6 <mem_init+0x8d1>
f01019bd:	68 7b 3d 10 f0       	push   $0xf0103d7b
f01019c2:	68 25 3c 10 f0       	push   $0xf0103c25
f01019c7:	68 88 03 00 00       	push   $0x388
f01019cc:	68 ff 3b 10 f0       	push   $0xf0103bff
f01019d1:	e8 b5 e6 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01019d6:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
f01019dc:	8b 02                	mov    (%edx),%eax
f01019de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019e3:	89 c1                	mov    %eax,%ecx
f01019e5:	c1 e9 0c             	shr    $0xc,%ecx
f01019e8:	3b 0d 68 79 11 f0    	cmp    0xf0117968,%ecx
f01019ee:	72 15                	jb     f0101a05 <mem_init+0x900>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019f0:	50                   	push   %eax
f01019f1:	68 e4 3e 10 f0       	push   $0xf0103ee4
f01019f6:	68 8b 03 00 00       	push   $0x38b
f01019fb:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101a00:	e8 86 e6 ff ff       	call   f010008b <_panic>
f0101a05:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a0d:	83 ec 04             	sub    $0x4,%esp
f0101a10:	6a 00                	push   $0x0
f0101a12:	68 00 10 00 00       	push   $0x1000
f0101a17:	52                   	push   %edx
f0101a18:	e8 49 f5 ff ff       	call   f0100f66 <pgdir_walk>
f0101a1d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a20:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a23:	83 c4 10             	add    $0x10,%esp
f0101a26:	39 d0                	cmp    %edx,%eax
f0101a28:	74 19                	je     f0101a43 <mem_init+0x93e>
f0101a2a:	68 78 42 10 f0       	push   $0xf0104278
f0101a2f:	68 25 3c 10 f0       	push   $0xf0103c25
f0101a34:	68 8c 03 00 00       	push   $0x38c
f0101a39:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101a3e:	e8 48 e6 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a43:	6a 06                	push   $0x6
f0101a45:	68 00 10 00 00       	push   $0x1000
f0101a4a:	56                   	push   %esi
f0101a4b:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101a51:	e8 47 f6 ff ff       	call   f010109d <page_insert>
f0101a56:	83 c4 10             	add    $0x10,%esp
f0101a59:	85 c0                	test   %eax,%eax
f0101a5b:	74 19                	je     f0101a76 <mem_init+0x971>
f0101a5d:	68 b8 42 10 f0       	push   $0xf01042b8
f0101a62:	68 25 3c 10 f0       	push   $0xf0103c25
f0101a67:	68 8f 03 00 00       	push   $0x38f
f0101a6c:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101a71:	e8 15 e6 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a76:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101a7c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a81:	89 f8                	mov    %edi,%eax
f0101a83:	e8 4d ef ff ff       	call   f01009d5 <check_va2pa>
f0101a88:	89 f2                	mov    %esi,%edx
f0101a8a:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101a90:	c1 fa 03             	sar    $0x3,%edx
f0101a93:	c1 e2 0c             	shl    $0xc,%edx
f0101a96:	39 d0                	cmp    %edx,%eax
f0101a98:	74 19                	je     f0101ab3 <mem_init+0x9ae>
f0101a9a:	68 48 42 10 f0       	push   $0xf0104248
f0101a9f:	68 25 3c 10 f0       	push   $0xf0103c25
f0101aa4:	68 90 03 00 00       	push   $0x390
f0101aa9:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101aae:	e8 d8 e5 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101ab3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ab8:	74 19                	je     f0101ad3 <mem_init+0x9ce>
f0101aba:	68 ef 3d 10 f0       	push   $0xf0103def
f0101abf:	68 25 3c 10 f0       	push   $0xf0103c25
f0101ac4:	68 91 03 00 00       	push   $0x391
f0101ac9:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101ace:	e8 b8 e5 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ad3:	83 ec 04             	sub    $0x4,%esp
f0101ad6:	6a 00                	push   $0x0
f0101ad8:	68 00 10 00 00       	push   $0x1000
f0101add:	57                   	push   %edi
f0101ade:	e8 83 f4 ff ff       	call   f0100f66 <pgdir_walk>
f0101ae3:	83 c4 10             	add    $0x10,%esp
f0101ae6:	f6 00 04             	testb  $0x4,(%eax)
f0101ae9:	75 19                	jne    f0101b04 <mem_init+0x9ff>
f0101aeb:	68 f8 42 10 f0       	push   $0xf01042f8
f0101af0:	68 25 3c 10 f0       	push   $0xf0103c25
f0101af5:	68 92 03 00 00       	push   $0x392
f0101afa:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101aff:	e8 87 e5 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101b04:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101b09:	f6 00 04             	testb  $0x4,(%eax)
f0101b0c:	75 19                	jne    f0101b27 <mem_init+0xa22>
f0101b0e:	68 00 3e 10 f0       	push   $0xf0103e00
f0101b13:	68 25 3c 10 f0       	push   $0xf0103c25
f0101b18:	68 93 03 00 00       	push   $0x393
f0101b1d:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101b22:	e8 64 e5 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b27:	6a 02                	push   $0x2
f0101b29:	68 00 10 00 00       	push   $0x1000
f0101b2e:	56                   	push   %esi
f0101b2f:	50                   	push   %eax
f0101b30:	e8 68 f5 ff ff       	call   f010109d <page_insert>
f0101b35:	83 c4 10             	add    $0x10,%esp
f0101b38:	85 c0                	test   %eax,%eax
f0101b3a:	74 19                	je     f0101b55 <mem_init+0xa50>
f0101b3c:	68 0c 42 10 f0       	push   $0xf010420c
f0101b41:	68 25 3c 10 f0       	push   $0xf0103c25
f0101b46:	68 96 03 00 00       	push   $0x396
f0101b4b:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101b50:	e8 36 e5 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b55:	83 ec 04             	sub    $0x4,%esp
f0101b58:	6a 00                	push   $0x0
f0101b5a:	68 00 10 00 00       	push   $0x1000
f0101b5f:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101b65:	e8 fc f3 ff ff       	call   f0100f66 <pgdir_walk>
f0101b6a:	83 c4 10             	add    $0x10,%esp
f0101b6d:	f6 00 02             	testb  $0x2,(%eax)
f0101b70:	75 19                	jne    f0101b8b <mem_init+0xa86>
f0101b72:	68 2c 43 10 f0       	push   $0xf010432c
f0101b77:	68 25 3c 10 f0       	push   $0xf0103c25
f0101b7c:	68 97 03 00 00       	push   $0x397
f0101b81:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101b86:	e8 00 e5 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b8b:	83 ec 04             	sub    $0x4,%esp
f0101b8e:	6a 00                	push   $0x0
f0101b90:	68 00 10 00 00       	push   $0x1000
f0101b95:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101b9b:	e8 c6 f3 ff ff       	call   f0100f66 <pgdir_walk>
f0101ba0:	83 c4 10             	add    $0x10,%esp
f0101ba3:	f6 00 04             	testb  $0x4,(%eax)
f0101ba6:	74 19                	je     f0101bc1 <mem_init+0xabc>
f0101ba8:	68 60 43 10 f0       	push   $0xf0104360
f0101bad:	68 25 3c 10 f0       	push   $0xf0103c25
f0101bb2:	68 98 03 00 00       	push   $0x398
f0101bb7:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101bbc:	e8 ca e4 ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101bc1:	6a 02                	push   $0x2
f0101bc3:	68 00 00 40 00       	push   $0x400000
f0101bc8:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bcb:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101bd1:	e8 c7 f4 ff ff       	call   f010109d <page_insert>
f0101bd6:	83 c4 10             	add    $0x10,%esp
f0101bd9:	85 c0                	test   %eax,%eax
f0101bdb:	78 19                	js     f0101bf6 <mem_init+0xaf1>
f0101bdd:	68 98 43 10 f0       	push   $0xf0104398
f0101be2:	68 25 3c 10 f0       	push   $0xf0103c25
f0101be7:	68 9b 03 00 00       	push   $0x39b
f0101bec:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101bf1:	e8 95 e4 ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101bf6:	6a 02                	push   $0x2
f0101bf8:	68 00 10 00 00       	push   $0x1000
f0101bfd:	53                   	push   %ebx
f0101bfe:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101c04:	e8 94 f4 ff ff       	call   f010109d <page_insert>
f0101c09:	83 c4 10             	add    $0x10,%esp
f0101c0c:	85 c0                	test   %eax,%eax
f0101c0e:	74 19                	je     f0101c29 <mem_init+0xb24>
f0101c10:	68 d0 43 10 f0       	push   $0xf01043d0
f0101c15:	68 25 3c 10 f0       	push   $0xf0103c25
f0101c1a:	68 9e 03 00 00       	push   $0x39e
f0101c1f:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101c24:	e8 62 e4 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c29:	83 ec 04             	sub    $0x4,%esp
f0101c2c:	6a 00                	push   $0x0
f0101c2e:	68 00 10 00 00       	push   $0x1000
f0101c33:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101c39:	e8 28 f3 ff ff       	call   f0100f66 <pgdir_walk>
f0101c3e:	83 c4 10             	add    $0x10,%esp
f0101c41:	f6 00 04             	testb  $0x4,(%eax)
f0101c44:	74 19                	je     f0101c5f <mem_init+0xb5a>
f0101c46:	68 60 43 10 f0       	push   $0xf0104360
f0101c4b:	68 25 3c 10 f0       	push   $0xf0103c25
f0101c50:	68 9f 03 00 00       	push   $0x39f
f0101c55:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101c5a:	e8 2c e4 ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c5f:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101c65:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c6a:	89 f8                	mov    %edi,%eax
f0101c6c:	e8 64 ed ff ff       	call   f01009d5 <check_va2pa>
f0101c71:	89 c1                	mov    %eax,%ecx
f0101c73:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c76:	89 d8                	mov    %ebx,%eax
f0101c78:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0101c7e:	c1 f8 03             	sar    $0x3,%eax
f0101c81:	c1 e0 0c             	shl    $0xc,%eax
f0101c84:	39 c1                	cmp    %eax,%ecx
f0101c86:	74 19                	je     f0101ca1 <mem_init+0xb9c>
f0101c88:	68 0c 44 10 f0       	push   $0xf010440c
f0101c8d:	68 25 3c 10 f0       	push   $0xf0103c25
f0101c92:	68 a2 03 00 00       	push   $0x3a2
f0101c97:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101c9c:	e8 ea e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ca1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ca6:	89 f8                	mov    %edi,%eax
f0101ca8:	e8 28 ed ff ff       	call   f01009d5 <check_va2pa>
f0101cad:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101cb0:	74 19                	je     f0101ccb <mem_init+0xbc6>
f0101cb2:	68 38 44 10 f0       	push   $0xf0104438
f0101cb7:	68 25 3c 10 f0       	push   $0xf0103c25
f0101cbc:	68 a3 03 00 00       	push   $0x3a3
f0101cc1:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101cc6:	e8 c0 e3 ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ccb:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101cd0:	74 19                	je     f0101ceb <mem_init+0xbe6>
f0101cd2:	68 16 3e 10 f0       	push   $0xf0103e16
f0101cd7:	68 25 3c 10 f0       	push   $0xf0103c25
f0101cdc:	68 a5 03 00 00       	push   $0x3a5
f0101ce1:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101ce6:	e8 a0 e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101ceb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101cf0:	74 19                	je     f0101d0b <mem_init+0xc06>
f0101cf2:	68 27 3e 10 f0       	push   $0xf0103e27
f0101cf7:	68 25 3c 10 f0       	push   $0xf0103c25
f0101cfc:	68 a6 03 00 00       	push   $0x3a6
f0101d01:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101d06:	e8 80 e3 ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d0b:	83 ec 0c             	sub    $0xc,%esp
f0101d0e:	6a 00                	push   $0x0
f0101d10:	e8 63 f1 ff ff       	call   f0100e78 <page_alloc>
f0101d15:	83 c4 10             	add    $0x10,%esp
f0101d18:	85 c0                	test   %eax,%eax
f0101d1a:	74 04                	je     f0101d20 <mem_init+0xc1b>
f0101d1c:	39 c6                	cmp    %eax,%esi
f0101d1e:	74 19                	je     f0101d39 <mem_init+0xc34>
f0101d20:	68 68 44 10 f0       	push   $0xf0104468
f0101d25:	68 25 3c 10 f0       	push   $0xf0103c25
f0101d2a:	68 a9 03 00 00       	push   $0x3a9
f0101d2f:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101d34:	e8 52 e3 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d39:	83 ec 08             	sub    $0x8,%esp
f0101d3c:	6a 00                	push   $0x0
f0101d3e:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101d44:	e8 19 f3 ff ff       	call   f0101062 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d49:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101d4f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d54:	89 f8                	mov    %edi,%eax
f0101d56:	e8 7a ec ff ff       	call   f01009d5 <check_va2pa>
f0101d5b:	83 c4 10             	add    $0x10,%esp
f0101d5e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d61:	74 19                	je     f0101d7c <mem_init+0xc77>
f0101d63:	68 8c 44 10 f0       	push   $0xf010448c
f0101d68:	68 25 3c 10 f0       	push   $0xf0103c25
f0101d6d:	68 ad 03 00 00       	push   $0x3ad
f0101d72:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101d77:	e8 0f e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d7c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d81:	89 f8                	mov    %edi,%eax
f0101d83:	e8 4d ec ff ff       	call   f01009d5 <check_va2pa>
f0101d88:	89 da                	mov    %ebx,%edx
f0101d8a:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101d90:	c1 fa 03             	sar    $0x3,%edx
f0101d93:	c1 e2 0c             	shl    $0xc,%edx
f0101d96:	39 d0                	cmp    %edx,%eax
f0101d98:	74 19                	je     f0101db3 <mem_init+0xcae>
f0101d9a:	68 38 44 10 f0       	push   $0xf0104438
f0101d9f:	68 25 3c 10 f0       	push   $0xf0103c25
f0101da4:	68 ae 03 00 00       	push   $0x3ae
f0101da9:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101dae:	e8 d8 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101db3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101db8:	74 19                	je     f0101dd3 <mem_init+0xcce>
f0101dba:	68 cd 3d 10 f0       	push   $0xf0103dcd
f0101dbf:	68 25 3c 10 f0       	push   $0xf0103c25
f0101dc4:	68 af 03 00 00       	push   $0x3af
f0101dc9:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101dce:	e8 b8 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101dd3:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101dd8:	74 19                	je     f0101df3 <mem_init+0xcee>
f0101dda:	68 27 3e 10 f0       	push   $0xf0103e27
f0101ddf:	68 25 3c 10 f0       	push   $0xf0103c25
f0101de4:	68 b0 03 00 00       	push   $0x3b0
f0101de9:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101dee:	e8 98 e2 ff ff       	call   f010008b <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101df3:	6a 00                	push   $0x0
f0101df5:	68 00 10 00 00       	push   $0x1000
f0101dfa:	53                   	push   %ebx
f0101dfb:	57                   	push   %edi
f0101dfc:	e8 9c f2 ff ff       	call   f010109d <page_insert>
f0101e01:	83 c4 10             	add    $0x10,%esp
f0101e04:	85 c0                	test   %eax,%eax
f0101e06:	74 19                	je     f0101e21 <mem_init+0xd1c>
f0101e08:	68 b0 44 10 f0       	push   $0xf01044b0
f0101e0d:	68 25 3c 10 f0       	push   $0xf0103c25
f0101e12:	68 b3 03 00 00       	push   $0x3b3
f0101e17:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101e1c:	e8 6a e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f0101e21:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e26:	75 19                	jne    f0101e41 <mem_init+0xd3c>
f0101e28:	68 38 3e 10 f0       	push   $0xf0103e38
f0101e2d:	68 25 3c 10 f0       	push   $0xf0103c25
f0101e32:	68 b4 03 00 00       	push   $0x3b4
f0101e37:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101e3c:	e8 4a e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f0101e41:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101e44:	74 19                	je     f0101e5f <mem_init+0xd5a>
f0101e46:	68 44 3e 10 f0       	push   $0xf0103e44
f0101e4b:	68 25 3c 10 f0       	push   $0xf0103c25
f0101e50:	68 b5 03 00 00       	push   $0x3b5
f0101e55:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101e5a:	e8 2c e2 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e5f:	83 ec 08             	sub    $0x8,%esp
f0101e62:	68 00 10 00 00       	push   $0x1000
f0101e67:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101e6d:	e8 f0 f1 ff ff       	call   f0101062 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e72:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101e78:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e7d:	89 f8                	mov    %edi,%eax
f0101e7f:	e8 51 eb ff ff       	call   f01009d5 <check_va2pa>
f0101e84:	83 c4 10             	add    $0x10,%esp
f0101e87:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e8a:	74 19                	je     f0101ea5 <mem_init+0xda0>
f0101e8c:	68 8c 44 10 f0       	push   $0xf010448c
f0101e91:	68 25 3c 10 f0       	push   $0xf0103c25
f0101e96:	68 b9 03 00 00       	push   $0x3b9
f0101e9b:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101ea0:	e8 e6 e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101ea5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101eaa:	89 f8                	mov    %edi,%eax
f0101eac:	e8 24 eb ff ff       	call   f01009d5 <check_va2pa>
f0101eb1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101eb4:	74 19                	je     f0101ecf <mem_init+0xdca>
f0101eb6:	68 e8 44 10 f0       	push   $0xf01044e8
f0101ebb:	68 25 3c 10 f0       	push   $0xf0103c25
f0101ec0:	68 ba 03 00 00       	push   $0x3ba
f0101ec5:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101eca:	e8 bc e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0101ecf:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ed4:	74 19                	je     f0101eef <mem_init+0xdea>
f0101ed6:	68 59 3e 10 f0       	push   $0xf0103e59
f0101edb:	68 25 3c 10 f0       	push   $0xf0103c25
f0101ee0:	68 bb 03 00 00       	push   $0x3bb
f0101ee5:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101eea:	e8 9c e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101eef:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ef4:	74 19                	je     f0101f0f <mem_init+0xe0a>
f0101ef6:	68 27 3e 10 f0       	push   $0xf0103e27
f0101efb:	68 25 3c 10 f0       	push   $0xf0103c25
f0101f00:	68 bc 03 00 00       	push   $0x3bc
f0101f05:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101f0a:	e8 7c e1 ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f0f:	83 ec 0c             	sub    $0xc,%esp
f0101f12:	6a 00                	push   $0x0
f0101f14:	e8 5f ef ff ff       	call   f0100e78 <page_alloc>
f0101f19:	83 c4 10             	add    $0x10,%esp
f0101f1c:	39 c3                	cmp    %eax,%ebx
f0101f1e:	75 04                	jne    f0101f24 <mem_init+0xe1f>
f0101f20:	85 c0                	test   %eax,%eax
f0101f22:	75 19                	jne    f0101f3d <mem_init+0xe38>
f0101f24:	68 10 45 10 f0       	push   $0xf0104510
f0101f29:	68 25 3c 10 f0       	push   $0xf0103c25
f0101f2e:	68 bf 03 00 00       	push   $0x3bf
f0101f33:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101f38:	e8 4e e1 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f3d:	83 ec 0c             	sub    $0xc,%esp
f0101f40:	6a 00                	push   $0x0
f0101f42:	e8 31 ef ff ff       	call   f0100e78 <page_alloc>
f0101f47:	83 c4 10             	add    $0x10,%esp
f0101f4a:	85 c0                	test   %eax,%eax
f0101f4c:	74 19                	je     f0101f67 <mem_init+0xe62>
f0101f4e:	68 7b 3d 10 f0       	push   $0xf0103d7b
f0101f53:	68 25 3c 10 f0       	push   $0xf0103c25
f0101f58:	68 c2 03 00 00       	push   $0x3c2
f0101f5d:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101f62:	e8 24 e1 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f67:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
f0101f6d:	8b 11                	mov    (%ecx),%edx
f0101f6f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f75:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f78:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0101f7e:	c1 f8 03             	sar    $0x3,%eax
f0101f81:	c1 e0 0c             	shl    $0xc,%eax
f0101f84:	39 c2                	cmp    %eax,%edx
f0101f86:	74 19                	je     f0101fa1 <mem_init+0xe9c>
f0101f88:	68 b4 41 10 f0       	push   $0xf01041b4
f0101f8d:	68 25 3c 10 f0       	push   $0xf0103c25
f0101f92:	68 c5 03 00 00       	push   $0x3c5
f0101f97:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101f9c:	e8 ea e0 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0101fa1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101fa7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101faa:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101faf:	74 19                	je     f0101fca <mem_init+0xec5>
f0101fb1:	68 de 3d 10 f0       	push   $0xf0103dde
f0101fb6:	68 25 3c 10 f0       	push   $0xf0103c25
f0101fbb:	68 c7 03 00 00       	push   $0x3c7
f0101fc0:	68 ff 3b 10 f0       	push   $0xf0103bff
f0101fc5:	e8 c1 e0 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0101fca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fcd:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101fd3:	83 ec 0c             	sub    $0xc,%esp
f0101fd6:	50                   	push   %eax
f0101fd7:	e8 0d ef ff ff       	call   f0100ee9 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101fdc:	83 c4 0c             	add    $0xc,%esp
f0101fdf:	6a 01                	push   $0x1
f0101fe1:	68 00 10 40 00       	push   $0x401000
f0101fe6:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101fec:	e8 75 ef ff ff       	call   f0100f66 <pgdir_walk>
f0101ff1:	89 c7                	mov    %eax,%edi
f0101ff3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101ff6:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101ffb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ffe:	8b 40 04             	mov    0x4(%eax),%eax
f0102001:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102006:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f010200c:	89 c2                	mov    %eax,%edx
f010200e:	c1 ea 0c             	shr    $0xc,%edx
f0102011:	83 c4 10             	add    $0x10,%esp
f0102014:	39 ca                	cmp    %ecx,%edx
f0102016:	72 15                	jb     f010202d <mem_init+0xf28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102018:	50                   	push   %eax
f0102019:	68 e4 3e 10 f0       	push   $0xf0103ee4
f010201e:	68 ce 03 00 00       	push   $0x3ce
f0102023:	68 ff 3b 10 f0       	push   $0xf0103bff
f0102028:	e8 5e e0 ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f010202d:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102032:	39 c7                	cmp    %eax,%edi
f0102034:	74 19                	je     f010204f <mem_init+0xf4a>
f0102036:	68 6a 3e 10 f0       	push   $0xf0103e6a
f010203b:	68 25 3c 10 f0       	push   $0xf0103c25
f0102040:	68 cf 03 00 00       	push   $0x3cf
f0102045:	68 ff 3b 10 f0       	push   $0xf0103bff
f010204a:	e8 3c e0 ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f010204f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102052:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102059:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010205c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102062:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0102068:	c1 f8 03             	sar    $0x3,%eax
f010206b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010206e:	89 c2                	mov    %eax,%edx
f0102070:	c1 ea 0c             	shr    $0xc,%edx
f0102073:	39 d1                	cmp    %edx,%ecx
f0102075:	77 12                	ja     f0102089 <mem_init+0xf84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102077:	50                   	push   %eax
f0102078:	68 e4 3e 10 f0       	push   $0xf0103ee4
f010207d:	6a 52                	push   $0x52
f010207f:	68 0b 3c 10 f0       	push   $0xf0103c0b
f0102084:	e8 02 e0 ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102089:	83 ec 04             	sub    $0x4,%esp
f010208c:	68 00 10 00 00       	push   $0x1000
f0102091:	68 ff 00 00 00       	push   $0xff
f0102096:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010209b:	50                   	push   %eax
f010209c:	e8 58 11 00 00       	call   f01031f9 <memset>
	page_free(pp0);
f01020a1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01020a4:	89 3c 24             	mov    %edi,(%esp)
f01020a7:	e8 3d ee ff ff       	call   f0100ee9 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020ac:	83 c4 0c             	add    $0xc,%esp
f01020af:	6a 01                	push   $0x1
f01020b1:	6a 00                	push   $0x0
f01020b3:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01020b9:	e8 a8 ee ff ff       	call   f0100f66 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020be:	89 fa                	mov    %edi,%edx
f01020c0:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f01020c6:	c1 fa 03             	sar    $0x3,%edx
f01020c9:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020cc:	89 d0                	mov    %edx,%eax
f01020ce:	c1 e8 0c             	shr    $0xc,%eax
f01020d1:	83 c4 10             	add    $0x10,%esp
f01020d4:	3b 05 68 79 11 f0    	cmp    0xf0117968,%eax
f01020da:	72 12                	jb     f01020ee <mem_init+0xfe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020dc:	52                   	push   %edx
f01020dd:	68 e4 3e 10 f0       	push   $0xf0103ee4
f01020e2:	6a 52                	push   $0x52
f01020e4:	68 0b 3c 10 f0       	push   $0xf0103c0b
f01020e9:	e8 9d df ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f01020ee:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01020f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01020f7:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01020fd:	f6 00 01             	testb  $0x1,(%eax)
f0102100:	74 19                	je     f010211b <mem_init+0x1016>
f0102102:	68 82 3e 10 f0       	push   $0xf0103e82
f0102107:	68 25 3c 10 f0       	push   $0xf0103c25
f010210c:	68 d9 03 00 00       	push   $0x3d9
f0102111:	68 ff 3b 10 f0       	push   $0xf0103bff
f0102116:	e8 70 df ff ff       	call   f010008b <_panic>
f010211b:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010211e:	39 d0                	cmp    %edx,%eax
f0102120:	75 db                	jne    f01020fd <mem_init+0xff8>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102122:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0102127:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010212d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102130:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102136:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102139:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c

	// free the pages we took
	page_free(pp0);
f010213f:	83 ec 0c             	sub    $0xc,%esp
f0102142:	50                   	push   %eax
f0102143:	e8 a1 ed ff ff       	call   f0100ee9 <page_free>
	page_free(pp1);
f0102148:	89 1c 24             	mov    %ebx,(%esp)
f010214b:	e8 99 ed ff ff       	call   f0100ee9 <page_free>
	page_free(pp2);
f0102150:	89 34 24             	mov    %esi,(%esp)
f0102153:	e8 91 ed ff ff       	call   f0100ee9 <page_free>

	cprintf("check_page() succeeded!\n");
f0102158:	c7 04 24 99 3e 10 f0 	movl   $0xf0103e99,(%esp)
f010215f:	e8 d1 05 00 00       	call   f0102735 <cprintf>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102164:	8b 35 6c 79 11 f0    	mov    0xf011796c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010216a:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010216f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102172:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102179:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010217e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102181:	8b 3d 70 79 11 f0    	mov    0xf0117970,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102187:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010218a:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010218d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102192:	eb 55                	jmp    f01021e9 <mem_init+0x10e4>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102194:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010219a:	89 f0                	mov    %esi,%eax
f010219c:	e8 34 e8 ff ff       	call   f01009d5 <check_va2pa>
f01021a1:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01021a8:	77 15                	ja     f01021bf <mem_init+0x10ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021aa:	57                   	push   %edi
f01021ab:	68 f0 3f 10 f0       	push   $0xf0103ff0
f01021b0:	68 1b 03 00 00       	push   $0x31b
f01021b5:	68 ff 3b 10 f0       	push   $0xf0103bff
f01021ba:	e8 cc de ff ff       	call   f010008b <_panic>
f01021bf:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f01021c6:	39 d0                	cmp    %edx,%eax
f01021c8:	74 19                	je     f01021e3 <mem_init+0x10de>
f01021ca:	68 34 45 10 f0       	push   $0xf0104534
f01021cf:	68 25 3c 10 f0       	push   $0xf0103c25
f01021d4:	68 1b 03 00 00       	push   $0x31b
f01021d9:	68 ff 3b 10 f0       	push   $0xf0103bff
f01021de:	e8 a8 de ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01021e3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01021e9:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01021ec:	77 a6                	ja     f0102194 <mem_init+0x108f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01021ee:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01021f1:	c1 e7 0c             	shl    $0xc,%edi
f01021f4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01021f9:	eb 30                	jmp    f010222b <mem_init+0x1126>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01021fb:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102201:	89 f0                	mov    %esi,%eax
f0102203:	e8 cd e7 ff ff       	call   f01009d5 <check_va2pa>
f0102208:	39 c3                	cmp    %eax,%ebx
f010220a:	74 19                	je     f0102225 <mem_init+0x1120>
f010220c:	68 68 45 10 f0       	push   $0xf0104568
f0102211:	68 25 3c 10 f0       	push   $0xf0103c25
f0102216:	68 20 03 00 00       	push   $0x320
f010221b:	68 ff 3b 10 f0       	push   $0xf0103bff
f0102220:	e8 66 de ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102225:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010222b:	39 fb                	cmp    %edi,%ebx
f010222d:	72 cc                	jb     f01021fb <mem_init+0x10f6>
f010222f:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102234:	bf 00 d0 10 f0       	mov    $0xf010d000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102239:	89 da                	mov    %ebx,%edx
f010223b:	89 f0                	mov    %esi,%eax
f010223d:	e8 93 e7 ff ff       	call   f01009d5 <check_va2pa>
f0102242:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102248:	77 19                	ja     f0102263 <mem_init+0x115e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010224a:	68 00 d0 10 f0       	push   $0xf010d000
f010224f:	68 f0 3f 10 f0       	push   $0xf0103ff0
f0102254:	68 24 03 00 00       	push   $0x324
f0102259:	68 ff 3b 10 f0       	push   $0xf0103bff
f010225e:	e8 28 de ff ff       	call   f010008b <_panic>
f0102263:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f0102269:	39 d0                	cmp    %edx,%eax
f010226b:	74 19                	je     f0102286 <mem_init+0x1181>
f010226d:	68 90 45 10 f0       	push   $0xf0104590
f0102272:	68 25 3c 10 f0       	push   $0xf0103c25
f0102277:	68 24 03 00 00       	push   $0x324
f010227c:	68 ff 3b 10 f0       	push   $0xf0103bff
f0102281:	e8 05 de ff ff       	call   f010008b <_panic>
f0102286:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010228c:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102292:	75 a5                	jne    f0102239 <mem_init+0x1134>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102294:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102299:	89 f0                	mov    %esi,%eax
f010229b:	e8 35 e7 ff ff       	call   f01009d5 <check_va2pa>
f01022a0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022a3:	74 51                	je     f01022f6 <mem_init+0x11f1>
f01022a5:	68 d8 45 10 f0       	push   $0xf01045d8
f01022aa:	68 25 3c 10 f0       	push   $0xf0103c25
f01022af:	68 25 03 00 00       	push   $0x325
f01022b4:	68 ff 3b 10 f0       	push   $0xf0103bff
f01022b9:	e8 cd dd ff ff       	call   f010008b <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01022be:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01022c3:	72 36                	jb     f01022fb <mem_init+0x11f6>
f01022c5:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01022ca:	76 07                	jbe    f01022d3 <mem_init+0x11ce>
f01022cc:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01022d1:	75 28                	jne    f01022fb <mem_init+0x11f6>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01022d3:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f01022d7:	0f 85 83 00 00 00    	jne    f0102360 <mem_init+0x125b>
f01022dd:	68 b2 3e 10 f0       	push   $0xf0103eb2
f01022e2:	68 25 3c 10 f0       	push   $0xf0103c25
f01022e7:	68 2d 03 00 00       	push   $0x32d
f01022ec:	68 ff 3b 10 f0       	push   $0xf0103bff
f01022f1:	e8 95 dd ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01022f6:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01022fb:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102300:	76 3f                	jbe    f0102341 <mem_init+0x123c>
				assert(pgdir[i] & PTE_P);
f0102302:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102305:	f6 c2 01             	test   $0x1,%dl
f0102308:	75 19                	jne    f0102323 <mem_init+0x121e>
f010230a:	68 b2 3e 10 f0       	push   $0xf0103eb2
f010230f:	68 25 3c 10 f0       	push   $0xf0103c25
f0102314:	68 31 03 00 00       	push   $0x331
f0102319:	68 ff 3b 10 f0       	push   $0xf0103bff
f010231e:	e8 68 dd ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f0102323:	f6 c2 02             	test   $0x2,%dl
f0102326:	75 38                	jne    f0102360 <mem_init+0x125b>
f0102328:	68 c3 3e 10 f0       	push   $0xf0103ec3
f010232d:	68 25 3c 10 f0       	push   $0xf0103c25
f0102332:	68 32 03 00 00       	push   $0x332
f0102337:	68 ff 3b 10 f0       	push   $0xf0103bff
f010233c:	e8 4a dd ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f0102341:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102345:	74 19                	je     f0102360 <mem_init+0x125b>
f0102347:	68 d4 3e 10 f0       	push   $0xf0103ed4
f010234c:	68 25 3c 10 f0       	push   $0xf0103c25
f0102351:	68 34 03 00 00       	push   $0x334
f0102356:	68 ff 3b 10 f0       	push   $0xf0103bff
f010235b:	e8 2b dd ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102360:	83 c0 01             	add    $0x1,%eax
f0102363:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102368:	0f 86 50 ff ff ff    	jbe    f01022be <mem_init+0x11b9>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010236e:	83 ec 0c             	sub    $0xc,%esp
f0102371:	68 08 46 10 f0       	push   $0xf0104608
f0102376:	e8 ba 03 00 00       	call   f0102735 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010237b:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102380:	83 c4 10             	add    $0x10,%esp
f0102383:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102388:	77 15                	ja     f010239f <mem_init+0x129a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010238a:	50                   	push   %eax
f010238b:	68 f0 3f 10 f0       	push   $0xf0103ff0
f0102390:	68 dc 00 00 00       	push   $0xdc
f0102395:	68 ff 3b 10 f0       	push   $0xf0103bff
f010239a:	e8 ec dc ff ff       	call   f010008b <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010239f:	05 00 00 00 10       	add    $0x10000000,%eax
f01023a4:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01023a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01023ac:	e8 88 e6 ff ff       	call   f0100a39 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01023b1:	0f 20 c0             	mov    %cr0,%eax
f01023b4:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01023b7:	0d 23 00 05 80       	or     $0x80050023,%eax
f01023bc:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01023bf:	83 ec 0c             	sub    $0xc,%esp
f01023c2:	6a 00                	push   $0x0
f01023c4:	e8 af ea ff ff       	call   f0100e78 <page_alloc>
f01023c9:	89 c3                	mov    %eax,%ebx
f01023cb:	83 c4 10             	add    $0x10,%esp
f01023ce:	85 c0                	test   %eax,%eax
f01023d0:	75 19                	jne    f01023eb <mem_init+0x12e6>
f01023d2:	68 d0 3c 10 f0       	push   $0xf0103cd0
f01023d7:	68 25 3c 10 f0       	push   $0xf0103c25
f01023dc:	68 f4 03 00 00       	push   $0x3f4
f01023e1:	68 ff 3b 10 f0       	push   $0xf0103bff
f01023e6:	e8 a0 dc ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01023eb:	83 ec 0c             	sub    $0xc,%esp
f01023ee:	6a 00                	push   $0x0
f01023f0:	e8 83 ea ff ff       	call   f0100e78 <page_alloc>
f01023f5:	89 c7                	mov    %eax,%edi
f01023f7:	83 c4 10             	add    $0x10,%esp
f01023fa:	85 c0                	test   %eax,%eax
f01023fc:	75 19                	jne    f0102417 <mem_init+0x1312>
f01023fe:	68 e6 3c 10 f0       	push   $0xf0103ce6
f0102403:	68 25 3c 10 f0       	push   $0xf0103c25
f0102408:	68 f5 03 00 00       	push   $0x3f5
f010240d:	68 ff 3b 10 f0       	push   $0xf0103bff
f0102412:	e8 74 dc ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0102417:	83 ec 0c             	sub    $0xc,%esp
f010241a:	6a 00                	push   $0x0
f010241c:	e8 57 ea ff ff       	call   f0100e78 <page_alloc>
f0102421:	89 c6                	mov    %eax,%esi
f0102423:	83 c4 10             	add    $0x10,%esp
f0102426:	85 c0                	test   %eax,%eax
f0102428:	75 19                	jne    f0102443 <mem_init+0x133e>
f010242a:	68 fc 3c 10 f0       	push   $0xf0103cfc
f010242f:	68 25 3c 10 f0       	push   $0xf0103c25
f0102434:	68 f6 03 00 00       	push   $0x3f6
f0102439:	68 ff 3b 10 f0       	push   $0xf0103bff
f010243e:	e8 48 dc ff ff       	call   f010008b <_panic>
	page_free(pp0);
f0102443:	83 ec 0c             	sub    $0xc,%esp
f0102446:	53                   	push   %ebx
f0102447:	e8 9d ea ff ff       	call   f0100ee9 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010244c:	89 f8                	mov    %edi,%eax
f010244e:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0102454:	c1 f8 03             	sar    $0x3,%eax
f0102457:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010245a:	89 c2                	mov    %eax,%edx
f010245c:	c1 ea 0c             	shr    $0xc,%edx
f010245f:	83 c4 10             	add    $0x10,%esp
f0102462:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0102468:	72 12                	jb     f010247c <mem_init+0x1377>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010246a:	50                   	push   %eax
f010246b:	68 e4 3e 10 f0       	push   $0xf0103ee4
f0102470:	6a 52                	push   $0x52
f0102472:	68 0b 3c 10 f0       	push   $0xf0103c0b
f0102477:	e8 0f dc ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010247c:	83 ec 04             	sub    $0x4,%esp
f010247f:	68 00 10 00 00       	push   $0x1000
f0102484:	6a 01                	push   $0x1
f0102486:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010248b:	50                   	push   %eax
f010248c:	e8 68 0d 00 00       	call   f01031f9 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102491:	89 f0                	mov    %esi,%eax
f0102493:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0102499:	c1 f8 03             	sar    $0x3,%eax
f010249c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010249f:	89 c2                	mov    %eax,%edx
f01024a1:	c1 ea 0c             	shr    $0xc,%edx
f01024a4:	83 c4 10             	add    $0x10,%esp
f01024a7:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f01024ad:	72 12                	jb     f01024c1 <mem_init+0x13bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024af:	50                   	push   %eax
f01024b0:	68 e4 3e 10 f0       	push   $0xf0103ee4
f01024b5:	6a 52                	push   $0x52
f01024b7:	68 0b 3c 10 f0       	push   $0xf0103c0b
f01024bc:	e8 ca db ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01024c1:	83 ec 04             	sub    $0x4,%esp
f01024c4:	68 00 10 00 00       	push   $0x1000
f01024c9:	6a 02                	push   $0x2
f01024cb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024d0:	50                   	push   %eax
f01024d1:	e8 23 0d 00 00       	call   f01031f9 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01024d6:	6a 02                	push   $0x2
f01024d8:	68 00 10 00 00       	push   $0x1000
f01024dd:	57                   	push   %edi
f01024de:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01024e4:	e8 b4 eb ff ff       	call   f010109d <page_insert>
	assert(pp1->pp_ref == 1);
f01024e9:	83 c4 20             	add    $0x20,%esp
f01024ec:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01024f1:	74 19                	je     f010250c <mem_init+0x1407>
f01024f3:	68 cd 3d 10 f0       	push   $0xf0103dcd
f01024f8:	68 25 3c 10 f0       	push   $0xf0103c25
f01024fd:	68 fb 03 00 00       	push   $0x3fb
f0102502:	68 ff 3b 10 f0       	push   $0xf0103bff
f0102507:	e8 7f db ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010250c:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102513:	01 01 01 
f0102516:	74 19                	je     f0102531 <mem_init+0x142c>
f0102518:	68 28 46 10 f0       	push   $0xf0104628
f010251d:	68 25 3c 10 f0       	push   $0xf0103c25
f0102522:	68 fc 03 00 00       	push   $0x3fc
f0102527:	68 ff 3b 10 f0       	push   $0xf0103bff
f010252c:	e8 5a db ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102531:	6a 02                	push   $0x2
f0102533:	68 00 10 00 00       	push   $0x1000
f0102538:	56                   	push   %esi
f0102539:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f010253f:	e8 59 eb ff ff       	call   f010109d <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102544:	83 c4 10             	add    $0x10,%esp
f0102547:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010254e:	02 02 02 
f0102551:	74 19                	je     f010256c <mem_init+0x1467>
f0102553:	68 4c 46 10 f0       	push   $0xf010464c
f0102558:	68 25 3c 10 f0       	push   $0xf0103c25
f010255d:	68 fe 03 00 00       	push   $0x3fe
f0102562:	68 ff 3b 10 f0       	push   $0xf0103bff
f0102567:	e8 1f db ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f010256c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102571:	74 19                	je     f010258c <mem_init+0x1487>
f0102573:	68 ef 3d 10 f0       	push   $0xf0103def
f0102578:	68 25 3c 10 f0       	push   $0xf0103c25
f010257d:	68 ff 03 00 00       	push   $0x3ff
f0102582:	68 ff 3b 10 f0       	push   $0xf0103bff
f0102587:	e8 ff da ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f010258c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102591:	74 19                	je     f01025ac <mem_init+0x14a7>
f0102593:	68 59 3e 10 f0       	push   $0xf0103e59
f0102598:	68 25 3c 10 f0       	push   $0xf0103c25
f010259d:	68 00 04 00 00       	push   $0x400
f01025a2:	68 ff 3b 10 f0       	push   $0xf0103bff
f01025a7:	e8 df da ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01025ac:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01025b3:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025b6:	89 f0                	mov    %esi,%eax
f01025b8:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01025be:	c1 f8 03             	sar    $0x3,%eax
f01025c1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025c4:	89 c2                	mov    %eax,%edx
f01025c6:	c1 ea 0c             	shr    $0xc,%edx
f01025c9:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f01025cf:	72 12                	jb     f01025e3 <mem_init+0x14de>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025d1:	50                   	push   %eax
f01025d2:	68 e4 3e 10 f0       	push   $0xf0103ee4
f01025d7:	6a 52                	push   $0x52
f01025d9:	68 0b 3c 10 f0       	push   $0xf0103c0b
f01025de:	e8 a8 da ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01025e3:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01025ea:	03 03 03 
f01025ed:	74 19                	je     f0102608 <mem_init+0x1503>
f01025ef:	68 70 46 10 f0       	push   $0xf0104670
f01025f4:	68 25 3c 10 f0       	push   $0xf0103c25
f01025f9:	68 02 04 00 00       	push   $0x402
f01025fe:	68 ff 3b 10 f0       	push   $0xf0103bff
f0102603:	e8 83 da ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102608:	83 ec 08             	sub    $0x8,%esp
f010260b:	68 00 10 00 00       	push   $0x1000
f0102610:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0102616:	e8 47 ea ff ff       	call   f0101062 <page_remove>
	assert(pp2->pp_ref == 0);
f010261b:	83 c4 10             	add    $0x10,%esp
f010261e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102623:	74 19                	je     f010263e <mem_init+0x1539>
f0102625:	68 27 3e 10 f0       	push   $0xf0103e27
f010262a:	68 25 3c 10 f0       	push   $0xf0103c25
f010262f:	68 04 04 00 00       	push   $0x404
f0102634:	68 ff 3b 10 f0       	push   $0xf0103bff
f0102639:	e8 4d da ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010263e:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
f0102644:	8b 11                	mov    (%ecx),%edx
f0102646:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010264c:	89 d8                	mov    %ebx,%eax
f010264e:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0102654:	c1 f8 03             	sar    $0x3,%eax
f0102657:	c1 e0 0c             	shl    $0xc,%eax
f010265a:	39 c2                	cmp    %eax,%edx
f010265c:	74 19                	je     f0102677 <mem_init+0x1572>
f010265e:	68 b4 41 10 f0       	push   $0xf01041b4
f0102663:	68 25 3c 10 f0       	push   $0xf0103c25
f0102668:	68 07 04 00 00       	push   $0x407
f010266d:	68 ff 3b 10 f0       	push   $0xf0103bff
f0102672:	e8 14 da ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102677:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010267d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102682:	74 19                	je     f010269d <mem_init+0x1598>
f0102684:	68 de 3d 10 f0       	push   $0xf0103dde
f0102689:	68 25 3c 10 f0       	push   $0xf0103c25
f010268e:	68 09 04 00 00       	push   $0x409
f0102693:	68 ff 3b 10 f0       	push   $0xf0103bff
f0102698:	e8 ee d9 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f010269d:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01026a3:	83 ec 0c             	sub    $0xc,%esp
f01026a6:	53                   	push   %ebx
f01026a7:	e8 3d e8 ff ff       	call   f0100ee9 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01026ac:	c7 04 24 9c 46 10 f0 	movl   $0xf010469c,(%esp)
f01026b3:	e8 7d 00 00 00       	call   f0102735 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01026b8:	83 c4 10             	add    $0x10,%esp
f01026bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01026be:	5b                   	pop    %ebx
f01026bf:	5e                   	pop    %esi
f01026c0:	5f                   	pop    %edi
f01026c1:	5d                   	pop    %ebp
f01026c2:	c3                   	ret    

f01026c3 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01026c3:	55                   	push   %ebp
f01026c4:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01026c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01026c9:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01026cc:	5d                   	pop    %ebp
f01026cd:	c3                   	ret    

f01026ce <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01026ce:	55                   	push   %ebp
f01026cf:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01026d1:	ba 70 00 00 00       	mov    $0x70,%edx
f01026d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01026d9:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01026da:	ba 71 00 00 00       	mov    $0x71,%edx
f01026df:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01026e0:	0f b6 c0             	movzbl %al,%eax
}
f01026e3:	5d                   	pop    %ebp
f01026e4:	c3                   	ret    

f01026e5 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01026e5:	55                   	push   %ebp
f01026e6:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01026e8:	ba 70 00 00 00       	mov    $0x70,%edx
f01026ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01026f0:	ee                   	out    %al,(%dx)
f01026f1:	ba 71 00 00 00       	mov    $0x71,%edx
f01026f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01026f9:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01026fa:	5d                   	pop    %ebp
f01026fb:	c3                   	ret    

f01026fc <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01026fc:	55                   	push   %ebp
f01026fd:	89 e5                	mov    %esp,%ebp
f01026ff:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102702:	ff 75 08             	pushl  0x8(%ebp)
f0102705:	e8 f6 de ff ff       	call   f0100600 <cputchar>
	*cnt++;
}
f010270a:	83 c4 10             	add    $0x10,%esp
f010270d:	c9                   	leave  
f010270e:	c3                   	ret    

f010270f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010270f:	55                   	push   %ebp
f0102710:	89 e5                	mov    %esp,%ebp
f0102712:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102715:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010271c:	ff 75 0c             	pushl  0xc(%ebp)
f010271f:	ff 75 08             	pushl  0x8(%ebp)
f0102722:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102725:	50                   	push   %eax
f0102726:	68 fc 26 10 f0       	push   $0xf01026fc
f010272b:	e8 5d 04 00 00       	call   f0102b8d <vprintfmt>
	return cnt;
}
f0102730:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102733:	c9                   	leave  
f0102734:	c3                   	ret    

f0102735 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102735:	55                   	push   %ebp
f0102736:	89 e5                	mov    %esp,%ebp
f0102738:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010273b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010273e:	50                   	push   %eax
f010273f:	ff 75 08             	pushl  0x8(%ebp)
f0102742:	e8 c8 ff ff ff       	call   f010270f <vcprintf>
	va_end(ap);

	return cnt;
}
f0102747:	c9                   	leave  
f0102748:	c3                   	ret    

f0102749 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102749:	55                   	push   %ebp
f010274a:	89 e5                	mov    %esp,%ebp
f010274c:	57                   	push   %edi
f010274d:	56                   	push   %esi
f010274e:	53                   	push   %ebx
f010274f:	83 ec 14             	sub    $0x14,%esp
f0102752:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102755:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102758:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010275b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010275e:	8b 1a                	mov    (%edx),%ebx
f0102760:	8b 01                	mov    (%ecx),%eax
f0102762:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102765:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010276c:	eb 7f                	jmp    f01027ed <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f010276e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102771:	01 d8                	add    %ebx,%eax
f0102773:	89 c6                	mov    %eax,%esi
f0102775:	c1 ee 1f             	shr    $0x1f,%esi
f0102778:	01 c6                	add    %eax,%esi
f010277a:	d1 fe                	sar    %esi
f010277c:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010277f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102782:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0102785:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102787:	eb 03                	jmp    f010278c <stab_binsearch+0x43>
			m--;
f0102789:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010278c:	39 c3                	cmp    %eax,%ebx
f010278e:	7f 0d                	jg     f010279d <stab_binsearch+0x54>
f0102790:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102794:	83 ea 0c             	sub    $0xc,%edx
f0102797:	39 f9                	cmp    %edi,%ecx
f0102799:	75 ee                	jne    f0102789 <stab_binsearch+0x40>
f010279b:	eb 05                	jmp    f01027a2 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010279d:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01027a0:	eb 4b                	jmp    f01027ed <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01027a2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01027a5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01027a8:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01027ac:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01027af:	76 11                	jbe    f01027c2 <stab_binsearch+0x79>
			*region_left = m;
f01027b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01027b4:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01027b6:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01027b9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01027c0:	eb 2b                	jmp    f01027ed <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01027c2:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01027c5:	73 14                	jae    f01027db <stab_binsearch+0x92>
			*region_right = m - 1;
f01027c7:	83 e8 01             	sub    $0x1,%eax
f01027ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01027cd:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01027d0:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01027d2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01027d9:	eb 12                	jmp    f01027ed <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01027db:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01027de:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01027e0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01027e4:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01027e6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01027ed:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01027f0:	0f 8e 78 ff ff ff    	jle    f010276e <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01027f6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01027fa:	75 0f                	jne    f010280b <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01027fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01027ff:	8b 00                	mov    (%eax),%eax
f0102801:	83 e8 01             	sub    $0x1,%eax
f0102804:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102807:	89 06                	mov    %eax,(%esi)
f0102809:	eb 2c                	jmp    f0102837 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010280b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010280e:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102810:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102813:	8b 0e                	mov    (%esi),%ecx
f0102815:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102818:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010281b:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010281e:	eb 03                	jmp    f0102823 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102820:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102823:	39 c8                	cmp    %ecx,%eax
f0102825:	7e 0b                	jle    f0102832 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0102827:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010282b:	83 ea 0c             	sub    $0xc,%edx
f010282e:	39 df                	cmp    %ebx,%edi
f0102830:	75 ee                	jne    f0102820 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102832:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102835:	89 06                	mov    %eax,(%esi)
	}
}
f0102837:	83 c4 14             	add    $0x14,%esp
f010283a:	5b                   	pop    %ebx
f010283b:	5e                   	pop    %esi
f010283c:	5f                   	pop    %edi
f010283d:	5d                   	pop    %ebp
f010283e:	c3                   	ret    

f010283f <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010283f:	55                   	push   %ebp
f0102840:	89 e5                	mov    %esp,%ebp
f0102842:	57                   	push   %edi
f0102843:	56                   	push   %esi
f0102844:	53                   	push   %ebx
f0102845:	83 ec 3c             	sub    $0x3c,%esp
f0102848:	8b 75 08             	mov    0x8(%ebp),%esi
f010284b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010284e:	c7 03 c8 46 10 f0    	movl   $0xf01046c8,(%ebx)
	info->eip_line = 0;
f0102854:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010285b:	c7 43 08 c8 46 10 f0 	movl   $0xf01046c8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102862:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102869:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010286c:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102873:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102879:	76 11                	jbe    f010288c <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010287b:	b8 60 c0 10 f0       	mov    $0xf010c060,%eax
f0102880:	3d 79 a2 10 f0       	cmp    $0xf010a279,%eax
f0102885:	77 19                	ja     f01028a0 <debuginfo_eip+0x61>
f0102887:	e9 b5 01 00 00       	jmp    f0102a41 <debuginfo_eip+0x202>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f010288c:	83 ec 04             	sub    $0x4,%esp
f010288f:	68 d2 46 10 f0       	push   $0xf01046d2
f0102894:	6a 7f                	push   $0x7f
f0102896:	68 df 46 10 f0       	push   $0xf01046df
f010289b:	e8 eb d7 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01028a0:	80 3d 5f c0 10 f0 00 	cmpb   $0x0,0xf010c05f
f01028a7:	0f 85 9b 01 00 00    	jne    f0102a48 <debuginfo_eip+0x209>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01028ad:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01028b4:	b8 78 a2 10 f0       	mov    $0xf010a278,%eax
f01028b9:	2d fc 48 10 f0       	sub    $0xf01048fc,%eax
f01028be:	c1 f8 02             	sar    $0x2,%eax
f01028c1:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01028c7:	83 e8 01             	sub    $0x1,%eax
f01028ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01028cd:	83 ec 08             	sub    $0x8,%esp
f01028d0:	56                   	push   %esi
f01028d1:	6a 64                	push   $0x64
f01028d3:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01028d6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01028d9:	b8 fc 48 10 f0       	mov    $0xf01048fc,%eax
f01028de:	e8 66 fe ff ff       	call   f0102749 <stab_binsearch>
	if (lfile == 0)
f01028e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01028e6:	83 c4 10             	add    $0x10,%esp
f01028e9:	85 c0                	test   %eax,%eax
f01028eb:	0f 84 5e 01 00 00    	je     f0102a4f <debuginfo_eip+0x210>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01028f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01028f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01028f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01028fa:	83 ec 08             	sub    $0x8,%esp
f01028fd:	56                   	push   %esi
f01028fe:	6a 24                	push   $0x24
f0102900:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102903:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102906:	b8 fc 48 10 f0       	mov    $0xf01048fc,%eax
f010290b:	e8 39 fe ff ff       	call   f0102749 <stab_binsearch>

	if (lfun <= rfun) {
f0102910:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102913:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102916:	83 c4 10             	add    $0x10,%esp
f0102919:	39 d0                	cmp    %edx,%eax
f010291b:	7f 40                	jg     f010295d <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010291d:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102920:	c1 e1 02             	shl    $0x2,%ecx
f0102923:	8d b9 fc 48 10 f0    	lea    -0xfefb704(%ecx),%edi
f0102929:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f010292c:	8b b9 fc 48 10 f0    	mov    -0xfefb704(%ecx),%edi
f0102932:	b9 60 c0 10 f0       	mov    $0xf010c060,%ecx
f0102937:	81 e9 79 a2 10 f0    	sub    $0xf010a279,%ecx
f010293d:	39 cf                	cmp    %ecx,%edi
f010293f:	73 09                	jae    f010294a <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102941:	81 c7 79 a2 10 f0    	add    $0xf010a279,%edi
f0102947:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010294a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010294d:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102950:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102953:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102955:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102958:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010295b:	eb 0f                	jmp    f010296c <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010295d:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102960:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102963:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102966:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102969:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010296c:	83 ec 08             	sub    $0x8,%esp
f010296f:	6a 3a                	push   $0x3a
f0102971:	ff 73 08             	pushl  0x8(%ebx)
f0102974:	e8 64 08 00 00       	call   f01031dd <strfind>
f0102979:	2b 43 08             	sub    0x8(%ebx),%eax
f010297c:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010297f:	83 c4 08             	add    $0x8,%esp
f0102982:	56                   	push   %esi
f0102983:	6a 44                	push   $0x44
f0102985:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102988:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010298b:	b8 fc 48 10 f0       	mov    $0xf01048fc,%eax
f0102990:	e8 b4 fd ff ff       	call   f0102749 <stab_binsearch>
	if (lline == 0)
f0102995:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102998:	83 c4 10             	add    $0x10,%esp
f010299b:	85 c0                	test   %eax,%eax
f010299d:	0f 84 b3 00 00 00    	je     f0102a56 <debuginfo_eip+0x217>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f01029a3:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01029a6:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01029a9:	0f b7 14 95 02 49 10 	movzwl -0xfefb6fe(,%edx,4),%edx
f01029b0:	f0 
f01029b1:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01029b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01029b7:	89 c2                	mov    %eax,%edx
f01029b9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01029bc:	8d 04 85 fc 48 10 f0 	lea    -0xfefb704(,%eax,4),%eax
f01029c3:	eb 06                	jmp    f01029cb <debuginfo_eip+0x18c>
f01029c5:	83 ea 01             	sub    $0x1,%edx
f01029c8:	83 e8 0c             	sub    $0xc,%eax
f01029cb:	39 d7                	cmp    %edx,%edi
f01029cd:	7f 34                	jg     f0102a03 <debuginfo_eip+0x1c4>
	       && stabs[lline].n_type != N_SOL
f01029cf:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f01029d3:	80 f9 84             	cmp    $0x84,%cl
f01029d6:	74 0b                	je     f01029e3 <debuginfo_eip+0x1a4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01029d8:	80 f9 64             	cmp    $0x64,%cl
f01029db:	75 e8                	jne    f01029c5 <debuginfo_eip+0x186>
f01029dd:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f01029e1:	74 e2                	je     f01029c5 <debuginfo_eip+0x186>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01029e3:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01029e6:	8b 14 85 fc 48 10 f0 	mov    -0xfefb704(,%eax,4),%edx
f01029ed:	b8 60 c0 10 f0       	mov    $0xf010c060,%eax
f01029f2:	2d 79 a2 10 f0       	sub    $0xf010a279,%eax
f01029f7:	39 c2                	cmp    %eax,%edx
f01029f9:	73 08                	jae    f0102a03 <debuginfo_eip+0x1c4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01029fb:	81 c2 79 a2 10 f0    	add    $0xf010a279,%edx
f0102a01:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102a03:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102a06:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102a09:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102a0e:	39 f2                	cmp    %esi,%edx
f0102a10:	7d 50                	jge    f0102a62 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
f0102a12:	83 c2 01             	add    $0x1,%edx
f0102a15:	89 d0                	mov    %edx,%eax
f0102a17:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102a1a:	8d 14 95 fc 48 10 f0 	lea    -0xfefb704(,%edx,4),%edx
f0102a21:	eb 04                	jmp    f0102a27 <debuginfo_eip+0x1e8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102a23:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102a27:	39 c6                	cmp    %eax,%esi
f0102a29:	7e 32                	jle    f0102a5d <debuginfo_eip+0x21e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102a2b:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102a2f:	83 c0 01             	add    $0x1,%eax
f0102a32:	83 c2 0c             	add    $0xc,%edx
f0102a35:	80 f9 a0             	cmp    $0xa0,%cl
f0102a38:	74 e9                	je     f0102a23 <debuginfo_eip+0x1e4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102a3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a3f:	eb 21                	jmp    f0102a62 <debuginfo_eip+0x223>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102a41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a46:	eb 1a                	jmp    f0102a62 <debuginfo_eip+0x223>
f0102a48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a4d:	eb 13                	jmp    f0102a62 <debuginfo_eip+0x223>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102a4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a54:	eb 0c                	jmp    f0102a62 <debuginfo_eip+0x223>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0102a56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a5b:	eb 05                	jmp    f0102a62 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102a5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102a62:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a65:	5b                   	pop    %ebx
f0102a66:	5e                   	pop    %esi
f0102a67:	5f                   	pop    %edi
f0102a68:	5d                   	pop    %ebp
f0102a69:	c3                   	ret    

f0102a6a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102a6a:	55                   	push   %ebp
f0102a6b:	89 e5                	mov    %esp,%ebp
f0102a6d:	57                   	push   %edi
f0102a6e:	56                   	push   %esi
f0102a6f:	53                   	push   %ebx
f0102a70:	83 ec 1c             	sub    $0x1c,%esp
f0102a73:	89 c7                	mov    %eax,%edi
f0102a75:	89 d6                	mov    %edx,%esi
f0102a77:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a7a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102a7d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102a80:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102a83:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102a86:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102a8b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102a8e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102a91:	39 d3                	cmp    %edx,%ebx
f0102a93:	72 05                	jb     f0102a9a <printnum+0x30>
f0102a95:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102a98:	77 45                	ja     f0102adf <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102a9a:	83 ec 0c             	sub    $0xc,%esp
f0102a9d:	ff 75 18             	pushl  0x18(%ebp)
f0102aa0:	8b 45 14             	mov    0x14(%ebp),%eax
f0102aa3:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102aa6:	53                   	push   %ebx
f0102aa7:	ff 75 10             	pushl  0x10(%ebp)
f0102aaa:	83 ec 08             	sub    $0x8,%esp
f0102aad:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102ab0:	ff 75 e0             	pushl  -0x20(%ebp)
f0102ab3:	ff 75 dc             	pushl  -0x24(%ebp)
f0102ab6:	ff 75 d8             	pushl  -0x28(%ebp)
f0102ab9:	e8 42 09 00 00       	call   f0103400 <__udivdi3>
f0102abe:	83 c4 18             	add    $0x18,%esp
f0102ac1:	52                   	push   %edx
f0102ac2:	50                   	push   %eax
f0102ac3:	89 f2                	mov    %esi,%edx
f0102ac5:	89 f8                	mov    %edi,%eax
f0102ac7:	e8 9e ff ff ff       	call   f0102a6a <printnum>
f0102acc:	83 c4 20             	add    $0x20,%esp
f0102acf:	eb 18                	jmp    f0102ae9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102ad1:	83 ec 08             	sub    $0x8,%esp
f0102ad4:	56                   	push   %esi
f0102ad5:	ff 75 18             	pushl  0x18(%ebp)
f0102ad8:	ff d7                	call   *%edi
f0102ada:	83 c4 10             	add    $0x10,%esp
f0102add:	eb 03                	jmp    f0102ae2 <printnum+0x78>
f0102adf:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102ae2:	83 eb 01             	sub    $0x1,%ebx
f0102ae5:	85 db                	test   %ebx,%ebx
f0102ae7:	7f e8                	jg     f0102ad1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102ae9:	83 ec 08             	sub    $0x8,%esp
f0102aec:	56                   	push   %esi
f0102aed:	83 ec 04             	sub    $0x4,%esp
f0102af0:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102af3:	ff 75 e0             	pushl  -0x20(%ebp)
f0102af6:	ff 75 dc             	pushl  -0x24(%ebp)
f0102af9:	ff 75 d8             	pushl  -0x28(%ebp)
f0102afc:	e8 2f 0a 00 00       	call   f0103530 <__umoddi3>
f0102b01:	83 c4 14             	add    $0x14,%esp
f0102b04:	0f be 80 ed 46 10 f0 	movsbl -0xfefb913(%eax),%eax
f0102b0b:	50                   	push   %eax
f0102b0c:	ff d7                	call   *%edi
}
f0102b0e:	83 c4 10             	add    $0x10,%esp
f0102b11:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b14:	5b                   	pop    %ebx
f0102b15:	5e                   	pop    %esi
f0102b16:	5f                   	pop    %edi
f0102b17:	5d                   	pop    %ebp
f0102b18:	c3                   	ret    

f0102b19 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102b19:	55                   	push   %ebp
f0102b1a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102b1c:	83 fa 01             	cmp    $0x1,%edx
f0102b1f:	7e 0e                	jle    f0102b2f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102b21:	8b 10                	mov    (%eax),%edx
f0102b23:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102b26:	89 08                	mov    %ecx,(%eax)
f0102b28:	8b 02                	mov    (%edx),%eax
f0102b2a:	8b 52 04             	mov    0x4(%edx),%edx
f0102b2d:	eb 22                	jmp    f0102b51 <getuint+0x38>
	else if (lflag)
f0102b2f:	85 d2                	test   %edx,%edx
f0102b31:	74 10                	je     f0102b43 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102b33:	8b 10                	mov    (%eax),%edx
f0102b35:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102b38:	89 08                	mov    %ecx,(%eax)
f0102b3a:	8b 02                	mov    (%edx),%eax
f0102b3c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b41:	eb 0e                	jmp    f0102b51 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102b43:	8b 10                	mov    (%eax),%edx
f0102b45:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102b48:	89 08                	mov    %ecx,(%eax)
f0102b4a:	8b 02                	mov    (%edx),%eax
f0102b4c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102b51:	5d                   	pop    %ebp
f0102b52:	c3                   	ret    

f0102b53 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102b53:	55                   	push   %ebp
f0102b54:	89 e5                	mov    %esp,%ebp
f0102b56:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102b59:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102b5d:	8b 10                	mov    (%eax),%edx
f0102b5f:	3b 50 04             	cmp    0x4(%eax),%edx
f0102b62:	73 0a                	jae    f0102b6e <sprintputch+0x1b>
		*b->buf++ = ch;
f0102b64:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102b67:	89 08                	mov    %ecx,(%eax)
f0102b69:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b6c:	88 02                	mov    %al,(%edx)
}
f0102b6e:	5d                   	pop    %ebp
f0102b6f:	c3                   	ret    

f0102b70 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102b70:	55                   	push   %ebp
f0102b71:	89 e5                	mov    %esp,%ebp
f0102b73:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102b76:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102b79:	50                   	push   %eax
f0102b7a:	ff 75 10             	pushl  0x10(%ebp)
f0102b7d:	ff 75 0c             	pushl  0xc(%ebp)
f0102b80:	ff 75 08             	pushl  0x8(%ebp)
f0102b83:	e8 05 00 00 00       	call   f0102b8d <vprintfmt>
	va_end(ap);
}
f0102b88:	83 c4 10             	add    $0x10,%esp
f0102b8b:	c9                   	leave  
f0102b8c:	c3                   	ret    

f0102b8d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102b8d:	55                   	push   %ebp
f0102b8e:	89 e5                	mov    %esp,%ebp
f0102b90:	57                   	push   %edi
f0102b91:	56                   	push   %esi
f0102b92:	53                   	push   %ebx
f0102b93:	83 ec 2c             	sub    $0x2c,%esp
f0102b96:	8b 75 08             	mov    0x8(%ebp),%esi
f0102b99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102b9c:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102b9f:	eb 12                	jmp    f0102bb3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102ba1:	85 c0                	test   %eax,%eax
f0102ba3:	0f 84 89 03 00 00    	je     f0102f32 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0102ba9:	83 ec 08             	sub    $0x8,%esp
f0102bac:	53                   	push   %ebx
f0102bad:	50                   	push   %eax
f0102bae:	ff d6                	call   *%esi
f0102bb0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102bb3:	83 c7 01             	add    $0x1,%edi
f0102bb6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102bba:	83 f8 25             	cmp    $0x25,%eax
f0102bbd:	75 e2                	jne    f0102ba1 <vprintfmt+0x14>
f0102bbf:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102bc3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102bca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102bd1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102bd8:	ba 00 00 00 00       	mov    $0x0,%edx
f0102bdd:	eb 07                	jmp    f0102be6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102bdf:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102be2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102be6:	8d 47 01             	lea    0x1(%edi),%eax
f0102be9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102bec:	0f b6 07             	movzbl (%edi),%eax
f0102bef:	0f b6 c8             	movzbl %al,%ecx
f0102bf2:	83 e8 23             	sub    $0x23,%eax
f0102bf5:	3c 55                	cmp    $0x55,%al
f0102bf7:	0f 87 1a 03 00 00    	ja     f0102f17 <vprintfmt+0x38a>
f0102bfd:	0f b6 c0             	movzbl %al,%eax
f0102c00:	ff 24 85 78 47 10 f0 	jmp    *-0xfefb888(,%eax,4)
f0102c07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102c0a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102c0e:	eb d6                	jmp    f0102be6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c10:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c13:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c18:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102c1b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102c1e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0102c22:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0102c25:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0102c28:	83 fa 09             	cmp    $0x9,%edx
f0102c2b:	77 39                	ja     f0102c66 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102c2d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102c30:	eb e9                	jmp    f0102c1b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102c32:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c35:	8d 48 04             	lea    0x4(%eax),%ecx
f0102c38:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102c3b:	8b 00                	mov    (%eax),%eax
f0102c3d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102c43:	eb 27                	jmp    f0102c6c <vprintfmt+0xdf>
f0102c45:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c48:	85 c0                	test   %eax,%eax
f0102c4a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102c4f:	0f 49 c8             	cmovns %eax,%ecx
f0102c52:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c58:	eb 8c                	jmp    f0102be6 <vprintfmt+0x59>
f0102c5a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102c5d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102c64:	eb 80                	jmp    f0102be6 <vprintfmt+0x59>
f0102c66:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102c69:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102c6c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102c70:	0f 89 70 ff ff ff    	jns    f0102be6 <vprintfmt+0x59>
				width = precision, precision = -1;
f0102c76:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c79:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102c7c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102c83:	e9 5e ff ff ff       	jmp    f0102be6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102c88:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c8b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102c8e:	e9 53 ff ff ff       	jmp    f0102be6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102c93:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c96:	8d 50 04             	lea    0x4(%eax),%edx
f0102c99:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c9c:	83 ec 08             	sub    $0x8,%esp
f0102c9f:	53                   	push   %ebx
f0102ca0:	ff 30                	pushl  (%eax)
f0102ca2:	ff d6                	call   *%esi
			break;
f0102ca4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ca7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102caa:	e9 04 ff ff ff       	jmp    f0102bb3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102caf:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cb2:	8d 50 04             	lea    0x4(%eax),%edx
f0102cb5:	89 55 14             	mov    %edx,0x14(%ebp)
f0102cb8:	8b 00                	mov    (%eax),%eax
f0102cba:	99                   	cltd   
f0102cbb:	31 d0                	xor    %edx,%eax
f0102cbd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102cbf:	83 f8 06             	cmp    $0x6,%eax
f0102cc2:	7f 0b                	jg     f0102ccf <vprintfmt+0x142>
f0102cc4:	8b 14 85 d0 48 10 f0 	mov    -0xfefb730(,%eax,4),%edx
f0102ccb:	85 d2                	test   %edx,%edx
f0102ccd:	75 18                	jne    f0102ce7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0102ccf:	50                   	push   %eax
f0102cd0:	68 05 47 10 f0       	push   $0xf0104705
f0102cd5:	53                   	push   %ebx
f0102cd6:	56                   	push   %esi
f0102cd7:	e8 94 fe ff ff       	call   f0102b70 <printfmt>
f0102cdc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cdf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102ce2:	e9 cc fe ff ff       	jmp    f0102bb3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102ce7:	52                   	push   %edx
f0102ce8:	68 37 3c 10 f0       	push   $0xf0103c37
f0102ced:	53                   	push   %ebx
f0102cee:	56                   	push   %esi
f0102cef:	e8 7c fe ff ff       	call   f0102b70 <printfmt>
f0102cf4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cf7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102cfa:	e9 b4 fe ff ff       	jmp    f0102bb3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102cff:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d02:	8d 50 04             	lea    0x4(%eax),%edx
f0102d05:	89 55 14             	mov    %edx,0x14(%ebp)
f0102d08:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102d0a:	85 ff                	test   %edi,%edi
f0102d0c:	b8 fe 46 10 f0       	mov    $0xf01046fe,%eax
f0102d11:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102d14:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102d18:	0f 8e 94 00 00 00    	jle    f0102db2 <vprintfmt+0x225>
f0102d1e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102d22:	0f 84 98 00 00 00    	je     f0102dc0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d28:	83 ec 08             	sub    $0x8,%esp
f0102d2b:	ff 75 d0             	pushl  -0x30(%ebp)
f0102d2e:	57                   	push   %edi
f0102d2f:	e8 5f 03 00 00       	call   f0103093 <strnlen>
f0102d34:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102d37:	29 c1                	sub    %eax,%ecx
f0102d39:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102d3c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102d3f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102d43:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102d46:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102d49:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d4b:	eb 0f                	jmp    f0102d5c <vprintfmt+0x1cf>
					putch(padc, putdat);
f0102d4d:	83 ec 08             	sub    $0x8,%esp
f0102d50:	53                   	push   %ebx
f0102d51:	ff 75 e0             	pushl  -0x20(%ebp)
f0102d54:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d56:	83 ef 01             	sub    $0x1,%edi
f0102d59:	83 c4 10             	add    $0x10,%esp
f0102d5c:	85 ff                	test   %edi,%edi
f0102d5e:	7f ed                	jg     f0102d4d <vprintfmt+0x1c0>
f0102d60:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102d63:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102d66:	85 c9                	test   %ecx,%ecx
f0102d68:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d6d:	0f 49 c1             	cmovns %ecx,%eax
f0102d70:	29 c1                	sub    %eax,%ecx
f0102d72:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d75:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d78:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102d7b:	89 cb                	mov    %ecx,%ebx
f0102d7d:	eb 4d                	jmp    f0102dcc <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102d7f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102d83:	74 1b                	je     f0102da0 <vprintfmt+0x213>
f0102d85:	0f be c0             	movsbl %al,%eax
f0102d88:	83 e8 20             	sub    $0x20,%eax
f0102d8b:	83 f8 5e             	cmp    $0x5e,%eax
f0102d8e:	76 10                	jbe    f0102da0 <vprintfmt+0x213>
					putch('?', putdat);
f0102d90:	83 ec 08             	sub    $0x8,%esp
f0102d93:	ff 75 0c             	pushl  0xc(%ebp)
f0102d96:	6a 3f                	push   $0x3f
f0102d98:	ff 55 08             	call   *0x8(%ebp)
f0102d9b:	83 c4 10             	add    $0x10,%esp
f0102d9e:	eb 0d                	jmp    f0102dad <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0102da0:	83 ec 08             	sub    $0x8,%esp
f0102da3:	ff 75 0c             	pushl  0xc(%ebp)
f0102da6:	52                   	push   %edx
f0102da7:	ff 55 08             	call   *0x8(%ebp)
f0102daa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102dad:	83 eb 01             	sub    $0x1,%ebx
f0102db0:	eb 1a                	jmp    f0102dcc <vprintfmt+0x23f>
f0102db2:	89 75 08             	mov    %esi,0x8(%ebp)
f0102db5:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102db8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102dbb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102dbe:	eb 0c                	jmp    f0102dcc <vprintfmt+0x23f>
f0102dc0:	89 75 08             	mov    %esi,0x8(%ebp)
f0102dc3:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102dc6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102dc9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102dcc:	83 c7 01             	add    $0x1,%edi
f0102dcf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102dd3:	0f be d0             	movsbl %al,%edx
f0102dd6:	85 d2                	test   %edx,%edx
f0102dd8:	74 23                	je     f0102dfd <vprintfmt+0x270>
f0102dda:	85 f6                	test   %esi,%esi
f0102ddc:	78 a1                	js     f0102d7f <vprintfmt+0x1f2>
f0102dde:	83 ee 01             	sub    $0x1,%esi
f0102de1:	79 9c                	jns    f0102d7f <vprintfmt+0x1f2>
f0102de3:	89 df                	mov    %ebx,%edi
f0102de5:	8b 75 08             	mov    0x8(%ebp),%esi
f0102de8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102deb:	eb 18                	jmp    f0102e05 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102ded:	83 ec 08             	sub    $0x8,%esp
f0102df0:	53                   	push   %ebx
f0102df1:	6a 20                	push   $0x20
f0102df3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102df5:	83 ef 01             	sub    $0x1,%edi
f0102df8:	83 c4 10             	add    $0x10,%esp
f0102dfb:	eb 08                	jmp    f0102e05 <vprintfmt+0x278>
f0102dfd:	89 df                	mov    %ebx,%edi
f0102dff:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e05:	85 ff                	test   %edi,%edi
f0102e07:	7f e4                	jg     f0102ded <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e0c:	e9 a2 fd ff ff       	jmp    f0102bb3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102e11:	83 fa 01             	cmp    $0x1,%edx
f0102e14:	7e 16                	jle    f0102e2c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0102e16:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e19:	8d 50 08             	lea    0x8(%eax),%edx
f0102e1c:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e1f:	8b 50 04             	mov    0x4(%eax),%edx
f0102e22:	8b 00                	mov    (%eax),%eax
f0102e24:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e27:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102e2a:	eb 32                	jmp    f0102e5e <vprintfmt+0x2d1>
	else if (lflag)
f0102e2c:	85 d2                	test   %edx,%edx
f0102e2e:	74 18                	je     f0102e48 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0102e30:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e33:	8d 50 04             	lea    0x4(%eax),%edx
f0102e36:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e39:	8b 00                	mov    (%eax),%eax
f0102e3b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e3e:	89 c1                	mov    %eax,%ecx
f0102e40:	c1 f9 1f             	sar    $0x1f,%ecx
f0102e43:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102e46:	eb 16                	jmp    f0102e5e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0102e48:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e4b:	8d 50 04             	lea    0x4(%eax),%edx
f0102e4e:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e51:	8b 00                	mov    (%eax),%eax
f0102e53:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e56:	89 c1                	mov    %eax,%ecx
f0102e58:	c1 f9 1f             	sar    $0x1f,%ecx
f0102e5b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102e5e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e61:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102e64:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102e69:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102e6d:	79 74                	jns    f0102ee3 <vprintfmt+0x356>
				putch('-', putdat);
f0102e6f:	83 ec 08             	sub    $0x8,%esp
f0102e72:	53                   	push   %ebx
f0102e73:	6a 2d                	push   $0x2d
f0102e75:	ff d6                	call   *%esi
				num = -(long long) num;
f0102e77:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e7a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e7d:	f7 d8                	neg    %eax
f0102e7f:	83 d2 00             	adc    $0x0,%edx
f0102e82:	f7 da                	neg    %edx
f0102e84:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102e87:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102e8c:	eb 55                	jmp    f0102ee3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102e8e:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e91:	e8 83 fc ff ff       	call   f0102b19 <getuint>
			base = 10;
f0102e96:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0102e9b:	eb 46                	jmp    f0102ee3 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0102e9d:	8d 45 14             	lea    0x14(%ebp),%eax
f0102ea0:	e8 74 fc ff ff       	call   f0102b19 <getuint>
			base = 8;
f0102ea5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0102eaa:	eb 37                	jmp    f0102ee3 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0102eac:	83 ec 08             	sub    $0x8,%esp
f0102eaf:	53                   	push   %ebx
f0102eb0:	6a 30                	push   $0x30
f0102eb2:	ff d6                	call   *%esi
			putch('x', putdat);
f0102eb4:	83 c4 08             	add    $0x8,%esp
f0102eb7:	53                   	push   %ebx
f0102eb8:	6a 78                	push   $0x78
f0102eba:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102ebc:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ebf:	8d 50 04             	lea    0x4(%eax),%edx
f0102ec2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102ec5:	8b 00                	mov    (%eax),%eax
f0102ec7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102ecc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102ecf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0102ed4:	eb 0d                	jmp    f0102ee3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102ed6:	8d 45 14             	lea    0x14(%ebp),%eax
f0102ed9:	e8 3b fc ff ff       	call   f0102b19 <getuint>
			base = 16;
f0102ede:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102ee3:	83 ec 0c             	sub    $0xc,%esp
f0102ee6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0102eea:	57                   	push   %edi
f0102eeb:	ff 75 e0             	pushl  -0x20(%ebp)
f0102eee:	51                   	push   %ecx
f0102eef:	52                   	push   %edx
f0102ef0:	50                   	push   %eax
f0102ef1:	89 da                	mov    %ebx,%edx
f0102ef3:	89 f0                	mov    %esi,%eax
f0102ef5:	e8 70 fb ff ff       	call   f0102a6a <printnum>
			break;
f0102efa:	83 c4 20             	add    $0x20,%esp
f0102efd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102f00:	e9 ae fc ff ff       	jmp    f0102bb3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102f05:	83 ec 08             	sub    $0x8,%esp
f0102f08:	53                   	push   %ebx
f0102f09:	51                   	push   %ecx
f0102f0a:	ff d6                	call   *%esi
			break;
f0102f0c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102f0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102f12:	e9 9c fc ff ff       	jmp    f0102bb3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0102f17:	83 ec 08             	sub    $0x8,%esp
f0102f1a:	53                   	push   %ebx
f0102f1b:	6a 25                	push   $0x25
f0102f1d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102f1f:	83 c4 10             	add    $0x10,%esp
f0102f22:	eb 03                	jmp    f0102f27 <vprintfmt+0x39a>
f0102f24:	83 ef 01             	sub    $0x1,%edi
f0102f27:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0102f2b:	75 f7                	jne    f0102f24 <vprintfmt+0x397>
f0102f2d:	e9 81 fc ff ff       	jmp    f0102bb3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0102f32:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f35:	5b                   	pop    %ebx
f0102f36:	5e                   	pop    %esi
f0102f37:	5f                   	pop    %edi
f0102f38:	5d                   	pop    %ebp
f0102f39:	c3                   	ret    

f0102f3a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102f3a:	55                   	push   %ebp
f0102f3b:	89 e5                	mov    %esp,%ebp
f0102f3d:	83 ec 18             	sub    $0x18,%esp
f0102f40:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f43:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102f46:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102f49:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102f4d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102f50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102f57:	85 c0                	test   %eax,%eax
f0102f59:	74 26                	je     f0102f81 <vsnprintf+0x47>
f0102f5b:	85 d2                	test   %edx,%edx
f0102f5d:	7e 22                	jle    f0102f81 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102f5f:	ff 75 14             	pushl  0x14(%ebp)
f0102f62:	ff 75 10             	pushl  0x10(%ebp)
f0102f65:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102f68:	50                   	push   %eax
f0102f69:	68 53 2b 10 f0       	push   $0xf0102b53
f0102f6e:	e8 1a fc ff ff       	call   f0102b8d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102f73:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102f76:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f7c:	83 c4 10             	add    $0x10,%esp
f0102f7f:	eb 05                	jmp    f0102f86 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0102f81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102f86:	c9                   	leave  
f0102f87:	c3                   	ret    

f0102f88 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102f88:	55                   	push   %ebp
f0102f89:	89 e5                	mov    %esp,%ebp
f0102f8b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102f8e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102f91:	50                   	push   %eax
f0102f92:	ff 75 10             	pushl  0x10(%ebp)
f0102f95:	ff 75 0c             	pushl  0xc(%ebp)
f0102f98:	ff 75 08             	pushl  0x8(%ebp)
f0102f9b:	e8 9a ff ff ff       	call   f0102f3a <vsnprintf>
	va_end(ap);

	return rc;
}
f0102fa0:	c9                   	leave  
f0102fa1:	c3                   	ret    

f0102fa2 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102fa2:	55                   	push   %ebp
f0102fa3:	89 e5                	mov    %esp,%ebp
f0102fa5:	57                   	push   %edi
f0102fa6:	56                   	push   %esi
f0102fa7:	53                   	push   %ebx
f0102fa8:	83 ec 0c             	sub    $0xc,%esp
f0102fab:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102fae:	85 c0                	test   %eax,%eax
f0102fb0:	74 11                	je     f0102fc3 <readline+0x21>
		cprintf("%s", prompt);
f0102fb2:	83 ec 08             	sub    $0x8,%esp
f0102fb5:	50                   	push   %eax
f0102fb6:	68 37 3c 10 f0       	push   $0xf0103c37
f0102fbb:	e8 75 f7 ff ff       	call   f0102735 <cprintf>
f0102fc0:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0102fc3:	83 ec 0c             	sub    $0xc,%esp
f0102fc6:	6a 00                	push   $0x0
f0102fc8:	e8 54 d6 ff ff       	call   f0100621 <iscons>
f0102fcd:	89 c7                	mov    %eax,%edi
f0102fcf:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0102fd2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0102fd7:	e8 34 d6 ff ff       	call   f0100610 <getchar>
f0102fdc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102fde:	85 c0                	test   %eax,%eax
f0102fe0:	79 18                	jns    f0102ffa <readline+0x58>
			cprintf("read error: %e\n", c);
f0102fe2:	83 ec 08             	sub    $0x8,%esp
f0102fe5:	50                   	push   %eax
f0102fe6:	68 ec 48 10 f0       	push   $0xf01048ec
f0102feb:	e8 45 f7 ff ff       	call   f0102735 <cprintf>
			return NULL;
f0102ff0:	83 c4 10             	add    $0x10,%esp
f0102ff3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ff8:	eb 79                	jmp    f0103073 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102ffa:	83 f8 08             	cmp    $0x8,%eax
f0102ffd:	0f 94 c2             	sete   %dl
f0103000:	83 f8 7f             	cmp    $0x7f,%eax
f0103003:	0f 94 c0             	sete   %al
f0103006:	08 c2                	or     %al,%dl
f0103008:	74 1a                	je     f0103024 <readline+0x82>
f010300a:	85 f6                	test   %esi,%esi
f010300c:	7e 16                	jle    f0103024 <readline+0x82>
			if (echoing)
f010300e:	85 ff                	test   %edi,%edi
f0103010:	74 0d                	je     f010301f <readline+0x7d>
				cputchar('\b');
f0103012:	83 ec 0c             	sub    $0xc,%esp
f0103015:	6a 08                	push   $0x8
f0103017:	e8 e4 d5 ff ff       	call   f0100600 <cputchar>
f010301c:	83 c4 10             	add    $0x10,%esp
			i--;
f010301f:	83 ee 01             	sub    $0x1,%esi
f0103022:	eb b3                	jmp    f0102fd7 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103024:	83 fb 1f             	cmp    $0x1f,%ebx
f0103027:	7e 23                	jle    f010304c <readline+0xaa>
f0103029:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010302f:	7f 1b                	jg     f010304c <readline+0xaa>
			if (echoing)
f0103031:	85 ff                	test   %edi,%edi
f0103033:	74 0c                	je     f0103041 <readline+0x9f>
				cputchar(c);
f0103035:	83 ec 0c             	sub    $0xc,%esp
f0103038:	53                   	push   %ebx
f0103039:	e8 c2 d5 ff ff       	call   f0100600 <cputchar>
f010303e:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103041:	88 9e 60 75 11 f0    	mov    %bl,-0xfee8aa0(%esi)
f0103047:	8d 76 01             	lea    0x1(%esi),%esi
f010304a:	eb 8b                	jmp    f0102fd7 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010304c:	83 fb 0a             	cmp    $0xa,%ebx
f010304f:	74 05                	je     f0103056 <readline+0xb4>
f0103051:	83 fb 0d             	cmp    $0xd,%ebx
f0103054:	75 81                	jne    f0102fd7 <readline+0x35>
			if (echoing)
f0103056:	85 ff                	test   %edi,%edi
f0103058:	74 0d                	je     f0103067 <readline+0xc5>
				cputchar('\n');
f010305a:	83 ec 0c             	sub    $0xc,%esp
f010305d:	6a 0a                	push   $0xa
f010305f:	e8 9c d5 ff ff       	call   f0100600 <cputchar>
f0103064:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103067:	c6 86 60 75 11 f0 00 	movb   $0x0,-0xfee8aa0(%esi)
			return buf;
f010306e:	b8 60 75 11 f0       	mov    $0xf0117560,%eax
		}
	}
}
f0103073:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103076:	5b                   	pop    %ebx
f0103077:	5e                   	pop    %esi
f0103078:	5f                   	pop    %edi
f0103079:	5d                   	pop    %ebp
f010307a:	c3                   	ret    

f010307b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010307b:	55                   	push   %ebp
f010307c:	89 e5                	mov    %esp,%ebp
f010307e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103081:	b8 00 00 00 00       	mov    $0x0,%eax
f0103086:	eb 03                	jmp    f010308b <strlen+0x10>
		n++;
f0103088:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010308b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010308f:	75 f7                	jne    f0103088 <strlen+0xd>
		n++;
	return n;
}
f0103091:	5d                   	pop    %ebp
f0103092:	c3                   	ret    

f0103093 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103093:	55                   	push   %ebp
f0103094:	89 e5                	mov    %esp,%ebp
f0103096:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103099:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010309c:	ba 00 00 00 00       	mov    $0x0,%edx
f01030a1:	eb 03                	jmp    f01030a6 <strnlen+0x13>
		n++;
f01030a3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01030a6:	39 c2                	cmp    %eax,%edx
f01030a8:	74 08                	je     f01030b2 <strnlen+0x1f>
f01030aa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01030ae:	75 f3                	jne    f01030a3 <strnlen+0x10>
f01030b0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01030b2:	5d                   	pop    %ebp
f01030b3:	c3                   	ret    

f01030b4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01030b4:	55                   	push   %ebp
f01030b5:	89 e5                	mov    %esp,%ebp
f01030b7:	53                   	push   %ebx
f01030b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01030bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01030be:	89 c2                	mov    %eax,%edx
f01030c0:	83 c2 01             	add    $0x1,%edx
f01030c3:	83 c1 01             	add    $0x1,%ecx
f01030c6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01030ca:	88 5a ff             	mov    %bl,-0x1(%edx)
f01030cd:	84 db                	test   %bl,%bl
f01030cf:	75 ef                	jne    f01030c0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01030d1:	5b                   	pop    %ebx
f01030d2:	5d                   	pop    %ebp
f01030d3:	c3                   	ret    

f01030d4 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01030d4:	55                   	push   %ebp
f01030d5:	89 e5                	mov    %esp,%ebp
f01030d7:	53                   	push   %ebx
f01030d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01030db:	53                   	push   %ebx
f01030dc:	e8 9a ff ff ff       	call   f010307b <strlen>
f01030e1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01030e4:	ff 75 0c             	pushl  0xc(%ebp)
f01030e7:	01 d8                	add    %ebx,%eax
f01030e9:	50                   	push   %eax
f01030ea:	e8 c5 ff ff ff       	call   f01030b4 <strcpy>
	return dst;
}
f01030ef:	89 d8                	mov    %ebx,%eax
f01030f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01030f4:	c9                   	leave  
f01030f5:	c3                   	ret    

f01030f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01030f6:	55                   	push   %ebp
f01030f7:	89 e5                	mov    %esp,%ebp
f01030f9:	56                   	push   %esi
f01030fa:	53                   	push   %ebx
f01030fb:	8b 75 08             	mov    0x8(%ebp),%esi
f01030fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103101:	89 f3                	mov    %esi,%ebx
f0103103:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103106:	89 f2                	mov    %esi,%edx
f0103108:	eb 0f                	jmp    f0103119 <strncpy+0x23>
		*dst++ = *src;
f010310a:	83 c2 01             	add    $0x1,%edx
f010310d:	0f b6 01             	movzbl (%ecx),%eax
f0103110:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103113:	80 39 01             	cmpb   $0x1,(%ecx)
f0103116:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103119:	39 da                	cmp    %ebx,%edx
f010311b:	75 ed                	jne    f010310a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010311d:	89 f0                	mov    %esi,%eax
f010311f:	5b                   	pop    %ebx
f0103120:	5e                   	pop    %esi
f0103121:	5d                   	pop    %ebp
f0103122:	c3                   	ret    

f0103123 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103123:	55                   	push   %ebp
f0103124:	89 e5                	mov    %esp,%ebp
f0103126:	56                   	push   %esi
f0103127:	53                   	push   %ebx
f0103128:	8b 75 08             	mov    0x8(%ebp),%esi
f010312b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010312e:	8b 55 10             	mov    0x10(%ebp),%edx
f0103131:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103133:	85 d2                	test   %edx,%edx
f0103135:	74 21                	je     f0103158 <strlcpy+0x35>
f0103137:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010313b:	89 f2                	mov    %esi,%edx
f010313d:	eb 09                	jmp    f0103148 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010313f:	83 c2 01             	add    $0x1,%edx
f0103142:	83 c1 01             	add    $0x1,%ecx
f0103145:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103148:	39 c2                	cmp    %eax,%edx
f010314a:	74 09                	je     f0103155 <strlcpy+0x32>
f010314c:	0f b6 19             	movzbl (%ecx),%ebx
f010314f:	84 db                	test   %bl,%bl
f0103151:	75 ec                	jne    f010313f <strlcpy+0x1c>
f0103153:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103155:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103158:	29 f0                	sub    %esi,%eax
}
f010315a:	5b                   	pop    %ebx
f010315b:	5e                   	pop    %esi
f010315c:	5d                   	pop    %ebp
f010315d:	c3                   	ret    

f010315e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010315e:	55                   	push   %ebp
f010315f:	89 e5                	mov    %esp,%ebp
f0103161:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103164:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103167:	eb 06                	jmp    f010316f <strcmp+0x11>
		p++, q++;
f0103169:	83 c1 01             	add    $0x1,%ecx
f010316c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010316f:	0f b6 01             	movzbl (%ecx),%eax
f0103172:	84 c0                	test   %al,%al
f0103174:	74 04                	je     f010317a <strcmp+0x1c>
f0103176:	3a 02                	cmp    (%edx),%al
f0103178:	74 ef                	je     f0103169 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010317a:	0f b6 c0             	movzbl %al,%eax
f010317d:	0f b6 12             	movzbl (%edx),%edx
f0103180:	29 d0                	sub    %edx,%eax
}
f0103182:	5d                   	pop    %ebp
f0103183:	c3                   	ret    

f0103184 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103184:	55                   	push   %ebp
f0103185:	89 e5                	mov    %esp,%ebp
f0103187:	53                   	push   %ebx
f0103188:	8b 45 08             	mov    0x8(%ebp),%eax
f010318b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010318e:	89 c3                	mov    %eax,%ebx
f0103190:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103193:	eb 06                	jmp    f010319b <strncmp+0x17>
		n--, p++, q++;
f0103195:	83 c0 01             	add    $0x1,%eax
f0103198:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010319b:	39 d8                	cmp    %ebx,%eax
f010319d:	74 15                	je     f01031b4 <strncmp+0x30>
f010319f:	0f b6 08             	movzbl (%eax),%ecx
f01031a2:	84 c9                	test   %cl,%cl
f01031a4:	74 04                	je     f01031aa <strncmp+0x26>
f01031a6:	3a 0a                	cmp    (%edx),%cl
f01031a8:	74 eb                	je     f0103195 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01031aa:	0f b6 00             	movzbl (%eax),%eax
f01031ad:	0f b6 12             	movzbl (%edx),%edx
f01031b0:	29 d0                	sub    %edx,%eax
f01031b2:	eb 05                	jmp    f01031b9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01031b4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01031b9:	5b                   	pop    %ebx
f01031ba:	5d                   	pop    %ebp
f01031bb:	c3                   	ret    

f01031bc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01031bc:	55                   	push   %ebp
f01031bd:	89 e5                	mov    %esp,%ebp
f01031bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01031c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01031c6:	eb 07                	jmp    f01031cf <strchr+0x13>
		if (*s == c)
f01031c8:	38 ca                	cmp    %cl,%dl
f01031ca:	74 0f                	je     f01031db <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01031cc:	83 c0 01             	add    $0x1,%eax
f01031cf:	0f b6 10             	movzbl (%eax),%edx
f01031d2:	84 d2                	test   %dl,%dl
f01031d4:	75 f2                	jne    f01031c8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01031d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031db:	5d                   	pop    %ebp
f01031dc:	c3                   	ret    

f01031dd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01031dd:	55                   	push   %ebp
f01031de:	89 e5                	mov    %esp,%ebp
f01031e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01031e3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01031e7:	eb 03                	jmp    f01031ec <strfind+0xf>
f01031e9:	83 c0 01             	add    $0x1,%eax
f01031ec:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01031ef:	38 ca                	cmp    %cl,%dl
f01031f1:	74 04                	je     f01031f7 <strfind+0x1a>
f01031f3:	84 d2                	test   %dl,%dl
f01031f5:	75 f2                	jne    f01031e9 <strfind+0xc>
			break;
	return (char *) s;
}
f01031f7:	5d                   	pop    %ebp
f01031f8:	c3                   	ret    

f01031f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01031f9:	55                   	push   %ebp
f01031fa:	89 e5                	mov    %esp,%ebp
f01031fc:	57                   	push   %edi
f01031fd:	56                   	push   %esi
f01031fe:	53                   	push   %ebx
f01031ff:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103202:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103205:	85 c9                	test   %ecx,%ecx
f0103207:	74 36                	je     f010323f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103209:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010320f:	75 28                	jne    f0103239 <memset+0x40>
f0103211:	f6 c1 03             	test   $0x3,%cl
f0103214:	75 23                	jne    f0103239 <memset+0x40>
		c &= 0xFF;
f0103216:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010321a:	89 d3                	mov    %edx,%ebx
f010321c:	c1 e3 08             	shl    $0x8,%ebx
f010321f:	89 d6                	mov    %edx,%esi
f0103221:	c1 e6 18             	shl    $0x18,%esi
f0103224:	89 d0                	mov    %edx,%eax
f0103226:	c1 e0 10             	shl    $0x10,%eax
f0103229:	09 f0                	or     %esi,%eax
f010322b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010322d:	89 d8                	mov    %ebx,%eax
f010322f:	09 d0                	or     %edx,%eax
f0103231:	c1 e9 02             	shr    $0x2,%ecx
f0103234:	fc                   	cld    
f0103235:	f3 ab                	rep stos %eax,%es:(%edi)
f0103237:	eb 06                	jmp    f010323f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103239:	8b 45 0c             	mov    0xc(%ebp),%eax
f010323c:	fc                   	cld    
f010323d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010323f:	89 f8                	mov    %edi,%eax
f0103241:	5b                   	pop    %ebx
f0103242:	5e                   	pop    %esi
f0103243:	5f                   	pop    %edi
f0103244:	5d                   	pop    %ebp
f0103245:	c3                   	ret    

f0103246 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103246:	55                   	push   %ebp
f0103247:	89 e5                	mov    %esp,%ebp
f0103249:	57                   	push   %edi
f010324a:	56                   	push   %esi
f010324b:	8b 45 08             	mov    0x8(%ebp),%eax
f010324e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103251:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103254:	39 c6                	cmp    %eax,%esi
f0103256:	73 35                	jae    f010328d <memmove+0x47>
f0103258:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010325b:	39 d0                	cmp    %edx,%eax
f010325d:	73 2e                	jae    f010328d <memmove+0x47>
		s += n;
		d += n;
f010325f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103262:	89 d6                	mov    %edx,%esi
f0103264:	09 fe                	or     %edi,%esi
f0103266:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010326c:	75 13                	jne    f0103281 <memmove+0x3b>
f010326e:	f6 c1 03             	test   $0x3,%cl
f0103271:	75 0e                	jne    f0103281 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0103273:	83 ef 04             	sub    $0x4,%edi
f0103276:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103279:	c1 e9 02             	shr    $0x2,%ecx
f010327c:	fd                   	std    
f010327d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010327f:	eb 09                	jmp    f010328a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103281:	83 ef 01             	sub    $0x1,%edi
f0103284:	8d 72 ff             	lea    -0x1(%edx),%esi
f0103287:	fd                   	std    
f0103288:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010328a:	fc                   	cld    
f010328b:	eb 1d                	jmp    f01032aa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010328d:	89 f2                	mov    %esi,%edx
f010328f:	09 c2                	or     %eax,%edx
f0103291:	f6 c2 03             	test   $0x3,%dl
f0103294:	75 0f                	jne    f01032a5 <memmove+0x5f>
f0103296:	f6 c1 03             	test   $0x3,%cl
f0103299:	75 0a                	jne    f01032a5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010329b:	c1 e9 02             	shr    $0x2,%ecx
f010329e:	89 c7                	mov    %eax,%edi
f01032a0:	fc                   	cld    
f01032a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01032a3:	eb 05                	jmp    f01032aa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01032a5:	89 c7                	mov    %eax,%edi
f01032a7:	fc                   	cld    
f01032a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01032aa:	5e                   	pop    %esi
f01032ab:	5f                   	pop    %edi
f01032ac:	5d                   	pop    %ebp
f01032ad:	c3                   	ret    

f01032ae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01032ae:	55                   	push   %ebp
f01032af:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01032b1:	ff 75 10             	pushl  0x10(%ebp)
f01032b4:	ff 75 0c             	pushl  0xc(%ebp)
f01032b7:	ff 75 08             	pushl  0x8(%ebp)
f01032ba:	e8 87 ff ff ff       	call   f0103246 <memmove>
}
f01032bf:	c9                   	leave  
f01032c0:	c3                   	ret    

f01032c1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01032c1:	55                   	push   %ebp
f01032c2:	89 e5                	mov    %esp,%ebp
f01032c4:	56                   	push   %esi
f01032c5:	53                   	push   %ebx
f01032c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01032c9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01032cc:	89 c6                	mov    %eax,%esi
f01032ce:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01032d1:	eb 1a                	jmp    f01032ed <memcmp+0x2c>
		if (*s1 != *s2)
f01032d3:	0f b6 08             	movzbl (%eax),%ecx
f01032d6:	0f b6 1a             	movzbl (%edx),%ebx
f01032d9:	38 d9                	cmp    %bl,%cl
f01032db:	74 0a                	je     f01032e7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01032dd:	0f b6 c1             	movzbl %cl,%eax
f01032e0:	0f b6 db             	movzbl %bl,%ebx
f01032e3:	29 d8                	sub    %ebx,%eax
f01032e5:	eb 0f                	jmp    f01032f6 <memcmp+0x35>
		s1++, s2++;
f01032e7:	83 c0 01             	add    $0x1,%eax
f01032ea:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01032ed:	39 f0                	cmp    %esi,%eax
f01032ef:	75 e2                	jne    f01032d3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01032f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032f6:	5b                   	pop    %ebx
f01032f7:	5e                   	pop    %esi
f01032f8:	5d                   	pop    %ebp
f01032f9:	c3                   	ret    

f01032fa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01032fa:	55                   	push   %ebp
f01032fb:	89 e5                	mov    %esp,%ebp
f01032fd:	53                   	push   %ebx
f01032fe:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103301:	89 c1                	mov    %eax,%ecx
f0103303:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0103306:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010330a:	eb 0a                	jmp    f0103316 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010330c:	0f b6 10             	movzbl (%eax),%edx
f010330f:	39 da                	cmp    %ebx,%edx
f0103311:	74 07                	je     f010331a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103313:	83 c0 01             	add    $0x1,%eax
f0103316:	39 c8                	cmp    %ecx,%eax
f0103318:	72 f2                	jb     f010330c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010331a:	5b                   	pop    %ebx
f010331b:	5d                   	pop    %ebp
f010331c:	c3                   	ret    

f010331d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010331d:	55                   	push   %ebp
f010331e:	89 e5                	mov    %esp,%ebp
f0103320:	57                   	push   %edi
f0103321:	56                   	push   %esi
f0103322:	53                   	push   %ebx
f0103323:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103326:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103329:	eb 03                	jmp    f010332e <strtol+0x11>
		s++;
f010332b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010332e:	0f b6 01             	movzbl (%ecx),%eax
f0103331:	3c 20                	cmp    $0x20,%al
f0103333:	74 f6                	je     f010332b <strtol+0xe>
f0103335:	3c 09                	cmp    $0x9,%al
f0103337:	74 f2                	je     f010332b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103339:	3c 2b                	cmp    $0x2b,%al
f010333b:	75 0a                	jne    f0103347 <strtol+0x2a>
		s++;
f010333d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103340:	bf 00 00 00 00       	mov    $0x0,%edi
f0103345:	eb 11                	jmp    f0103358 <strtol+0x3b>
f0103347:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010334c:	3c 2d                	cmp    $0x2d,%al
f010334e:	75 08                	jne    f0103358 <strtol+0x3b>
		s++, neg = 1;
f0103350:	83 c1 01             	add    $0x1,%ecx
f0103353:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103358:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010335e:	75 15                	jne    f0103375 <strtol+0x58>
f0103360:	80 39 30             	cmpb   $0x30,(%ecx)
f0103363:	75 10                	jne    f0103375 <strtol+0x58>
f0103365:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103369:	75 7c                	jne    f01033e7 <strtol+0xca>
		s += 2, base = 16;
f010336b:	83 c1 02             	add    $0x2,%ecx
f010336e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103373:	eb 16                	jmp    f010338b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0103375:	85 db                	test   %ebx,%ebx
f0103377:	75 12                	jne    f010338b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103379:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010337e:	80 39 30             	cmpb   $0x30,(%ecx)
f0103381:	75 08                	jne    f010338b <strtol+0x6e>
		s++, base = 8;
f0103383:	83 c1 01             	add    $0x1,%ecx
f0103386:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010338b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103390:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103393:	0f b6 11             	movzbl (%ecx),%edx
f0103396:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103399:	89 f3                	mov    %esi,%ebx
f010339b:	80 fb 09             	cmp    $0x9,%bl
f010339e:	77 08                	ja     f01033a8 <strtol+0x8b>
			dig = *s - '0';
f01033a0:	0f be d2             	movsbl %dl,%edx
f01033a3:	83 ea 30             	sub    $0x30,%edx
f01033a6:	eb 22                	jmp    f01033ca <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01033a8:	8d 72 9f             	lea    -0x61(%edx),%esi
f01033ab:	89 f3                	mov    %esi,%ebx
f01033ad:	80 fb 19             	cmp    $0x19,%bl
f01033b0:	77 08                	ja     f01033ba <strtol+0x9d>
			dig = *s - 'a' + 10;
f01033b2:	0f be d2             	movsbl %dl,%edx
f01033b5:	83 ea 57             	sub    $0x57,%edx
f01033b8:	eb 10                	jmp    f01033ca <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01033ba:	8d 72 bf             	lea    -0x41(%edx),%esi
f01033bd:	89 f3                	mov    %esi,%ebx
f01033bf:	80 fb 19             	cmp    $0x19,%bl
f01033c2:	77 16                	ja     f01033da <strtol+0xbd>
			dig = *s - 'A' + 10;
f01033c4:	0f be d2             	movsbl %dl,%edx
f01033c7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01033ca:	3b 55 10             	cmp    0x10(%ebp),%edx
f01033cd:	7d 0b                	jge    f01033da <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01033cf:	83 c1 01             	add    $0x1,%ecx
f01033d2:	0f af 45 10          	imul   0x10(%ebp),%eax
f01033d6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01033d8:	eb b9                	jmp    f0103393 <strtol+0x76>

	if (endptr)
f01033da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01033de:	74 0d                	je     f01033ed <strtol+0xd0>
		*endptr = (char *) s;
f01033e0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01033e3:	89 0e                	mov    %ecx,(%esi)
f01033e5:	eb 06                	jmp    f01033ed <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01033e7:	85 db                	test   %ebx,%ebx
f01033e9:	74 98                	je     f0103383 <strtol+0x66>
f01033eb:	eb 9e                	jmp    f010338b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01033ed:	89 c2                	mov    %eax,%edx
f01033ef:	f7 da                	neg    %edx
f01033f1:	85 ff                	test   %edi,%edi
f01033f3:	0f 45 c2             	cmovne %edx,%eax
}
f01033f6:	5b                   	pop    %ebx
f01033f7:	5e                   	pop    %esi
f01033f8:	5f                   	pop    %edi
f01033f9:	5d                   	pop    %ebp
f01033fa:	c3                   	ret    
f01033fb:	66 90                	xchg   %ax,%ax
f01033fd:	66 90                	xchg   %ax,%ax
f01033ff:	90                   	nop

f0103400 <__udivdi3>:
f0103400:	55                   	push   %ebp
f0103401:	57                   	push   %edi
f0103402:	56                   	push   %esi
f0103403:	53                   	push   %ebx
f0103404:	83 ec 1c             	sub    $0x1c,%esp
f0103407:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010340b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010340f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0103413:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103417:	85 f6                	test   %esi,%esi
f0103419:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010341d:	89 ca                	mov    %ecx,%edx
f010341f:	89 f8                	mov    %edi,%eax
f0103421:	75 3d                	jne    f0103460 <__udivdi3+0x60>
f0103423:	39 cf                	cmp    %ecx,%edi
f0103425:	0f 87 c5 00 00 00    	ja     f01034f0 <__udivdi3+0xf0>
f010342b:	85 ff                	test   %edi,%edi
f010342d:	89 fd                	mov    %edi,%ebp
f010342f:	75 0b                	jne    f010343c <__udivdi3+0x3c>
f0103431:	b8 01 00 00 00       	mov    $0x1,%eax
f0103436:	31 d2                	xor    %edx,%edx
f0103438:	f7 f7                	div    %edi
f010343a:	89 c5                	mov    %eax,%ebp
f010343c:	89 c8                	mov    %ecx,%eax
f010343e:	31 d2                	xor    %edx,%edx
f0103440:	f7 f5                	div    %ebp
f0103442:	89 c1                	mov    %eax,%ecx
f0103444:	89 d8                	mov    %ebx,%eax
f0103446:	89 cf                	mov    %ecx,%edi
f0103448:	f7 f5                	div    %ebp
f010344a:	89 c3                	mov    %eax,%ebx
f010344c:	89 d8                	mov    %ebx,%eax
f010344e:	89 fa                	mov    %edi,%edx
f0103450:	83 c4 1c             	add    $0x1c,%esp
f0103453:	5b                   	pop    %ebx
f0103454:	5e                   	pop    %esi
f0103455:	5f                   	pop    %edi
f0103456:	5d                   	pop    %ebp
f0103457:	c3                   	ret    
f0103458:	90                   	nop
f0103459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103460:	39 ce                	cmp    %ecx,%esi
f0103462:	77 74                	ja     f01034d8 <__udivdi3+0xd8>
f0103464:	0f bd fe             	bsr    %esi,%edi
f0103467:	83 f7 1f             	xor    $0x1f,%edi
f010346a:	0f 84 98 00 00 00    	je     f0103508 <__udivdi3+0x108>
f0103470:	bb 20 00 00 00       	mov    $0x20,%ebx
f0103475:	89 f9                	mov    %edi,%ecx
f0103477:	89 c5                	mov    %eax,%ebp
f0103479:	29 fb                	sub    %edi,%ebx
f010347b:	d3 e6                	shl    %cl,%esi
f010347d:	89 d9                	mov    %ebx,%ecx
f010347f:	d3 ed                	shr    %cl,%ebp
f0103481:	89 f9                	mov    %edi,%ecx
f0103483:	d3 e0                	shl    %cl,%eax
f0103485:	09 ee                	or     %ebp,%esi
f0103487:	89 d9                	mov    %ebx,%ecx
f0103489:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010348d:	89 d5                	mov    %edx,%ebp
f010348f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103493:	d3 ed                	shr    %cl,%ebp
f0103495:	89 f9                	mov    %edi,%ecx
f0103497:	d3 e2                	shl    %cl,%edx
f0103499:	89 d9                	mov    %ebx,%ecx
f010349b:	d3 e8                	shr    %cl,%eax
f010349d:	09 c2                	or     %eax,%edx
f010349f:	89 d0                	mov    %edx,%eax
f01034a1:	89 ea                	mov    %ebp,%edx
f01034a3:	f7 f6                	div    %esi
f01034a5:	89 d5                	mov    %edx,%ebp
f01034a7:	89 c3                	mov    %eax,%ebx
f01034a9:	f7 64 24 0c          	mull   0xc(%esp)
f01034ad:	39 d5                	cmp    %edx,%ebp
f01034af:	72 10                	jb     f01034c1 <__udivdi3+0xc1>
f01034b1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01034b5:	89 f9                	mov    %edi,%ecx
f01034b7:	d3 e6                	shl    %cl,%esi
f01034b9:	39 c6                	cmp    %eax,%esi
f01034bb:	73 07                	jae    f01034c4 <__udivdi3+0xc4>
f01034bd:	39 d5                	cmp    %edx,%ebp
f01034bf:	75 03                	jne    f01034c4 <__udivdi3+0xc4>
f01034c1:	83 eb 01             	sub    $0x1,%ebx
f01034c4:	31 ff                	xor    %edi,%edi
f01034c6:	89 d8                	mov    %ebx,%eax
f01034c8:	89 fa                	mov    %edi,%edx
f01034ca:	83 c4 1c             	add    $0x1c,%esp
f01034cd:	5b                   	pop    %ebx
f01034ce:	5e                   	pop    %esi
f01034cf:	5f                   	pop    %edi
f01034d0:	5d                   	pop    %ebp
f01034d1:	c3                   	ret    
f01034d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01034d8:	31 ff                	xor    %edi,%edi
f01034da:	31 db                	xor    %ebx,%ebx
f01034dc:	89 d8                	mov    %ebx,%eax
f01034de:	89 fa                	mov    %edi,%edx
f01034e0:	83 c4 1c             	add    $0x1c,%esp
f01034e3:	5b                   	pop    %ebx
f01034e4:	5e                   	pop    %esi
f01034e5:	5f                   	pop    %edi
f01034e6:	5d                   	pop    %ebp
f01034e7:	c3                   	ret    
f01034e8:	90                   	nop
f01034e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01034f0:	89 d8                	mov    %ebx,%eax
f01034f2:	f7 f7                	div    %edi
f01034f4:	31 ff                	xor    %edi,%edi
f01034f6:	89 c3                	mov    %eax,%ebx
f01034f8:	89 d8                	mov    %ebx,%eax
f01034fa:	89 fa                	mov    %edi,%edx
f01034fc:	83 c4 1c             	add    $0x1c,%esp
f01034ff:	5b                   	pop    %ebx
f0103500:	5e                   	pop    %esi
f0103501:	5f                   	pop    %edi
f0103502:	5d                   	pop    %ebp
f0103503:	c3                   	ret    
f0103504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103508:	39 ce                	cmp    %ecx,%esi
f010350a:	72 0c                	jb     f0103518 <__udivdi3+0x118>
f010350c:	31 db                	xor    %ebx,%ebx
f010350e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0103512:	0f 87 34 ff ff ff    	ja     f010344c <__udivdi3+0x4c>
f0103518:	bb 01 00 00 00       	mov    $0x1,%ebx
f010351d:	e9 2a ff ff ff       	jmp    f010344c <__udivdi3+0x4c>
f0103522:	66 90                	xchg   %ax,%ax
f0103524:	66 90                	xchg   %ax,%ax
f0103526:	66 90                	xchg   %ax,%ax
f0103528:	66 90                	xchg   %ax,%ax
f010352a:	66 90                	xchg   %ax,%ax
f010352c:	66 90                	xchg   %ax,%ax
f010352e:	66 90                	xchg   %ax,%ax

f0103530 <__umoddi3>:
f0103530:	55                   	push   %ebp
f0103531:	57                   	push   %edi
f0103532:	56                   	push   %esi
f0103533:	53                   	push   %ebx
f0103534:	83 ec 1c             	sub    $0x1c,%esp
f0103537:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010353b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010353f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103543:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103547:	85 d2                	test   %edx,%edx
f0103549:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010354d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103551:	89 f3                	mov    %esi,%ebx
f0103553:	89 3c 24             	mov    %edi,(%esp)
f0103556:	89 74 24 04          	mov    %esi,0x4(%esp)
f010355a:	75 1c                	jne    f0103578 <__umoddi3+0x48>
f010355c:	39 f7                	cmp    %esi,%edi
f010355e:	76 50                	jbe    f01035b0 <__umoddi3+0x80>
f0103560:	89 c8                	mov    %ecx,%eax
f0103562:	89 f2                	mov    %esi,%edx
f0103564:	f7 f7                	div    %edi
f0103566:	89 d0                	mov    %edx,%eax
f0103568:	31 d2                	xor    %edx,%edx
f010356a:	83 c4 1c             	add    $0x1c,%esp
f010356d:	5b                   	pop    %ebx
f010356e:	5e                   	pop    %esi
f010356f:	5f                   	pop    %edi
f0103570:	5d                   	pop    %ebp
f0103571:	c3                   	ret    
f0103572:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103578:	39 f2                	cmp    %esi,%edx
f010357a:	89 d0                	mov    %edx,%eax
f010357c:	77 52                	ja     f01035d0 <__umoddi3+0xa0>
f010357e:	0f bd ea             	bsr    %edx,%ebp
f0103581:	83 f5 1f             	xor    $0x1f,%ebp
f0103584:	75 5a                	jne    f01035e0 <__umoddi3+0xb0>
f0103586:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010358a:	0f 82 e0 00 00 00    	jb     f0103670 <__umoddi3+0x140>
f0103590:	39 0c 24             	cmp    %ecx,(%esp)
f0103593:	0f 86 d7 00 00 00    	jbe    f0103670 <__umoddi3+0x140>
f0103599:	8b 44 24 08          	mov    0x8(%esp),%eax
f010359d:	8b 54 24 04          	mov    0x4(%esp),%edx
f01035a1:	83 c4 1c             	add    $0x1c,%esp
f01035a4:	5b                   	pop    %ebx
f01035a5:	5e                   	pop    %esi
f01035a6:	5f                   	pop    %edi
f01035a7:	5d                   	pop    %ebp
f01035a8:	c3                   	ret    
f01035a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01035b0:	85 ff                	test   %edi,%edi
f01035b2:	89 fd                	mov    %edi,%ebp
f01035b4:	75 0b                	jne    f01035c1 <__umoddi3+0x91>
f01035b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01035bb:	31 d2                	xor    %edx,%edx
f01035bd:	f7 f7                	div    %edi
f01035bf:	89 c5                	mov    %eax,%ebp
f01035c1:	89 f0                	mov    %esi,%eax
f01035c3:	31 d2                	xor    %edx,%edx
f01035c5:	f7 f5                	div    %ebp
f01035c7:	89 c8                	mov    %ecx,%eax
f01035c9:	f7 f5                	div    %ebp
f01035cb:	89 d0                	mov    %edx,%eax
f01035cd:	eb 99                	jmp    f0103568 <__umoddi3+0x38>
f01035cf:	90                   	nop
f01035d0:	89 c8                	mov    %ecx,%eax
f01035d2:	89 f2                	mov    %esi,%edx
f01035d4:	83 c4 1c             	add    $0x1c,%esp
f01035d7:	5b                   	pop    %ebx
f01035d8:	5e                   	pop    %esi
f01035d9:	5f                   	pop    %edi
f01035da:	5d                   	pop    %ebp
f01035db:	c3                   	ret    
f01035dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01035e0:	8b 34 24             	mov    (%esp),%esi
f01035e3:	bf 20 00 00 00       	mov    $0x20,%edi
f01035e8:	89 e9                	mov    %ebp,%ecx
f01035ea:	29 ef                	sub    %ebp,%edi
f01035ec:	d3 e0                	shl    %cl,%eax
f01035ee:	89 f9                	mov    %edi,%ecx
f01035f0:	89 f2                	mov    %esi,%edx
f01035f2:	d3 ea                	shr    %cl,%edx
f01035f4:	89 e9                	mov    %ebp,%ecx
f01035f6:	09 c2                	or     %eax,%edx
f01035f8:	89 d8                	mov    %ebx,%eax
f01035fa:	89 14 24             	mov    %edx,(%esp)
f01035fd:	89 f2                	mov    %esi,%edx
f01035ff:	d3 e2                	shl    %cl,%edx
f0103601:	89 f9                	mov    %edi,%ecx
f0103603:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103607:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010360b:	d3 e8                	shr    %cl,%eax
f010360d:	89 e9                	mov    %ebp,%ecx
f010360f:	89 c6                	mov    %eax,%esi
f0103611:	d3 e3                	shl    %cl,%ebx
f0103613:	89 f9                	mov    %edi,%ecx
f0103615:	89 d0                	mov    %edx,%eax
f0103617:	d3 e8                	shr    %cl,%eax
f0103619:	89 e9                	mov    %ebp,%ecx
f010361b:	09 d8                	or     %ebx,%eax
f010361d:	89 d3                	mov    %edx,%ebx
f010361f:	89 f2                	mov    %esi,%edx
f0103621:	f7 34 24             	divl   (%esp)
f0103624:	89 d6                	mov    %edx,%esi
f0103626:	d3 e3                	shl    %cl,%ebx
f0103628:	f7 64 24 04          	mull   0x4(%esp)
f010362c:	39 d6                	cmp    %edx,%esi
f010362e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103632:	89 d1                	mov    %edx,%ecx
f0103634:	89 c3                	mov    %eax,%ebx
f0103636:	72 08                	jb     f0103640 <__umoddi3+0x110>
f0103638:	75 11                	jne    f010364b <__umoddi3+0x11b>
f010363a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010363e:	73 0b                	jae    f010364b <__umoddi3+0x11b>
f0103640:	2b 44 24 04          	sub    0x4(%esp),%eax
f0103644:	1b 14 24             	sbb    (%esp),%edx
f0103647:	89 d1                	mov    %edx,%ecx
f0103649:	89 c3                	mov    %eax,%ebx
f010364b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010364f:	29 da                	sub    %ebx,%edx
f0103651:	19 ce                	sbb    %ecx,%esi
f0103653:	89 f9                	mov    %edi,%ecx
f0103655:	89 f0                	mov    %esi,%eax
f0103657:	d3 e0                	shl    %cl,%eax
f0103659:	89 e9                	mov    %ebp,%ecx
f010365b:	d3 ea                	shr    %cl,%edx
f010365d:	89 e9                	mov    %ebp,%ecx
f010365f:	d3 ee                	shr    %cl,%esi
f0103661:	09 d0                	or     %edx,%eax
f0103663:	89 f2                	mov    %esi,%edx
f0103665:	83 c4 1c             	add    $0x1c,%esp
f0103668:	5b                   	pop    %ebx
f0103669:	5e                   	pop    %esi
f010366a:	5f                   	pop    %edi
f010366b:	5d                   	pop    %ebp
f010366c:	c3                   	ret    
f010366d:	8d 76 00             	lea    0x0(%esi),%esi
f0103670:	29 f9                	sub    %edi,%ecx
f0103672:	19 d6                	sbb    %edx,%esi
f0103674:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103678:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010367c:	e9 18 ff ff ff       	jmp    f0103599 <__umoddi3+0x69>
