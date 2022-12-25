
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 60 19 10 f0       	push   $0xf0101960
f0100050:	e8 98 09 00 00       	call   f01009ed <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 0a 07 00 00       	call   f0100785 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 7c 19 10 f0       	push   $0xf010197c
f0100087:	e8 61 09 00 00       	call   f01009ed <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 40 29 11 f0       	mov    $0xf0112940,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 00 14 00 00       	call   f01014b1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 9d 04 00 00       	call   f0100553 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 97 19 10 f0       	push   $0xf0101997
f01000c3:	e8 25 09 00 00       	call   f01009ed <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 9f 07 00 00       	call   f0100880 <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 44 29 11 f0 00 	cmpl   $0x0,0xf0112944
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 44 29 11 f0    	mov    %esi,0xf0112944

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 b2 19 10 f0       	push   $0xf01019b2
f0100110:	e8 d8 08 00 00       	call   f01009ed <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 a8 08 00 00       	call   f01009c7 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 ee 19 10 f0 	movl   $0xf01019ee,(%esp)
f0100126:	e8 c2 08 00 00       	call   f01009ed <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 48 07 00 00       	call   f0100880 <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 ca 19 10 f0       	push   $0xf01019ca
f0100152:	e8 96 08 00 00       	call   f01009ed <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 64 08 00 00       	call   f01009c7 <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 ee 19 10 f0 	movl   $0xf01019ee,(%esp)
f010016a:	e8 7e 08 00 00       	call   f01009ed <cprintf>
	va_end(ap);
}
f010016f:	83 c4 10             	add    $0x10,%esp
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 0b                	je     f010018f <serial_proc_data+0x18>
f0100184:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100189:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018a:	0f b6 c0             	movzbl %al,%eax
f010018d:	eb 05                	jmp    f0100194 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100194:	5d                   	pop    %ebp
f0100195:	c3                   	ret    

f0100196 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	53                   	push   %ebx
f010019a:	83 ec 04             	sub    $0x4,%esp
f010019d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019f:	eb 2b                	jmp    f01001cc <cons_intr+0x36>
		if (c == 0)
f01001a1:	85 c0                	test   %eax,%eax
f01001a3:	74 27                	je     f01001cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a5:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ae:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001b4:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c0:	75 0a                	jne    f01001cc <cons_intr+0x36>
			cons.wpos = 0;
f01001c2:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001cc:	ff d3                	call   *%ebx
f01001ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d1:	75 ce                	jne    f01001a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d3:	83 c4 04             	add    $0x4,%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    

f01001d9 <kbd_proc_data>:
f01001d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001de:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001df:	a8 01                	test   $0x1,%al
f01001e1:	0f 84 f8 00 00 00    	je     f01002df <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001e7:	a8 20                	test   $0x20,%al
f01001e9:	0f 85 f6 00 00 00    	jne    f01002e5 <kbd_proc_data+0x10c>
f01001ef:	ba 60 00 00 00       	mov    $0x60,%edx
f01001f4:	ec                   	in     (%dx),%al
f01001f5:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001f7:	3c e0                	cmp    $0xe0,%al
f01001f9:	75 0d                	jne    f0100208 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001fb:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f0100202:	b8 00 00 00 00       	mov    $0x0,%eax
f0100207:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100208:	55                   	push   %ebp
f0100209:	89 e5                	mov    %esp,%ebp
f010020b:	53                   	push   %ebx
f010020c:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010020f:	84 c0                	test   %al,%al
f0100211:	79 36                	jns    f0100249 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100213:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100219:	89 cb                	mov    %ecx,%ebx
f010021b:	83 e3 40             	and    $0x40,%ebx
f010021e:	83 e0 7f             	and    $0x7f,%eax
f0100221:	85 db                	test   %ebx,%ebx
f0100223:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100226:	0f b6 d2             	movzbl %dl,%edx
f0100229:	0f b6 82 40 1b 10 f0 	movzbl -0xfefe4c0(%edx),%eax
f0100230:	83 c8 40             	or     $0x40,%eax
f0100233:	0f b6 c0             	movzbl %al,%eax
f0100236:	f7 d0                	not    %eax
f0100238:	21 c8                	and    %ecx,%eax
f010023a:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f010023f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100244:	e9 a4 00 00 00       	jmp    f01002ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100249:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010024f:	f6 c1 40             	test   $0x40,%cl
f0100252:	74 0e                	je     f0100262 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100254:	83 c8 80             	or     $0xffffff80,%eax
f0100257:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100259:	83 e1 bf             	and    $0xffffffbf,%ecx
f010025c:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100262:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100265:	0f b6 82 40 1b 10 f0 	movzbl -0xfefe4c0(%edx),%eax
f010026c:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f0100272:	0f b6 8a 40 1a 10 f0 	movzbl -0xfefe5c0(%edx),%ecx
f0100279:	31 c8                	xor    %ecx,%eax
f010027b:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100280:	89 c1                	mov    %eax,%ecx
f0100282:	83 e1 03             	and    $0x3,%ecx
f0100285:	8b 0c 8d 20 1a 10 f0 	mov    -0xfefe5e0(,%ecx,4),%ecx
f010028c:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100290:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100293:	a8 08                	test   $0x8,%al
f0100295:	74 1b                	je     f01002b2 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100297:	89 da                	mov    %ebx,%edx
f0100299:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010029c:	83 f9 19             	cmp    $0x19,%ecx
f010029f:	77 05                	ja     f01002a6 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002a1:	83 eb 20             	sub    $0x20,%ebx
f01002a4:	eb 0c                	jmp    f01002b2 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002a6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002a9:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002ac:	83 fa 19             	cmp    $0x19,%edx
f01002af:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002b2:	f7 d0                	not    %eax
f01002b4:	a8 06                	test   $0x6,%al
f01002b6:	75 33                	jne    f01002eb <kbd_proc_data+0x112>
f01002b8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002be:	75 2b                	jne    f01002eb <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002c0:	83 ec 0c             	sub    $0xc,%esp
f01002c3:	68 e4 19 10 f0       	push   $0xf01019e4
f01002c8:	e8 20 07 00 00       	call   f01009ed <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cd:	ba 92 00 00 00       	mov    $0x92,%edx
f01002d2:	b8 03 00 00 00       	mov    $0x3,%eax
f01002d7:	ee                   	out    %al,(%dx)
f01002d8:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002db:	89 d8                	mov    %ebx,%eax
f01002dd:	eb 0e                	jmp    f01002ed <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002e4:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ea:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002eb:	89 d8                	mov    %ebx,%eax
}
f01002ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f0:	c9                   	leave  
f01002f1:	c3                   	ret    

f01002f2 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f2:	55                   	push   %ebp
f01002f3:	89 e5                	mov    %esp,%ebp
f01002f5:	57                   	push   %edi
f01002f6:	56                   	push   %esi
f01002f7:	53                   	push   %ebx
f01002f8:	83 ec 1c             	sub    $0x1c,%esp
f01002fb:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002fd:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100302:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100307:	b9 84 00 00 00       	mov    $0x84,%ecx
f010030c:	eb 09                	jmp    f0100317 <cons_putc+0x25>
f010030e:	89 ca                	mov    %ecx,%edx
f0100310:	ec                   	in     (%dx),%al
f0100311:	ec                   	in     (%dx),%al
f0100312:	ec                   	in     (%dx),%al
f0100313:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100314:	83 c3 01             	add    $0x1,%ebx
f0100317:	89 f2                	mov    %esi,%edx
f0100319:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010031a:	a8 20                	test   $0x20,%al
f010031c:	75 08                	jne    f0100326 <cons_putc+0x34>
f010031e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100324:	7e e8                	jle    f010030e <cons_putc+0x1c>
f0100326:	89 f8                	mov    %edi,%eax
f0100328:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100330:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100331:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100336:	be 79 03 00 00       	mov    $0x379,%esi
f010033b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100340:	eb 09                	jmp    f010034b <cons_putc+0x59>
f0100342:	89 ca                	mov    %ecx,%edx
f0100344:	ec                   	in     (%dx),%al
f0100345:	ec                   	in     (%dx),%al
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	83 c3 01             	add    $0x1,%ebx
f010034b:	89 f2                	mov    %esi,%edx
f010034d:	ec                   	in     (%dx),%al
f010034e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100354:	7f 04                	jg     f010035a <cons_putc+0x68>
f0100356:	84 c0                	test   %al,%al
f0100358:	79 e8                	jns    f0100342 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035a:	ba 78 03 00 00       	mov    $0x378,%edx
f010035f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100363:	ee                   	out    %al,(%dx)
f0100364:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100369:	b8 0d 00 00 00       	mov    $0xd,%eax
f010036e:	ee                   	out    %al,(%dx)
f010036f:	b8 08 00 00 00       	mov    $0x8,%eax
f0100374:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100375:	89 fa                	mov    %edi,%edx
f0100377:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010037d:	89 f8                	mov    %edi,%eax
f010037f:	80 cc 07             	or     $0x7,%ah
f0100382:	85 d2                	test   %edx,%edx
f0100384:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100387:	89 f8                	mov    %edi,%eax
f0100389:	0f b6 c0             	movzbl %al,%eax
f010038c:	83 f8 09             	cmp    $0x9,%eax
f010038f:	74 74                	je     f0100405 <cons_putc+0x113>
f0100391:	83 f8 09             	cmp    $0x9,%eax
f0100394:	7f 0a                	jg     f01003a0 <cons_putc+0xae>
f0100396:	83 f8 08             	cmp    $0x8,%eax
f0100399:	74 14                	je     f01003af <cons_putc+0xbd>
f010039b:	e9 99 00 00 00       	jmp    f0100439 <cons_putc+0x147>
f01003a0:	83 f8 0a             	cmp    $0xa,%eax
f01003a3:	74 3a                	je     f01003df <cons_putc+0xed>
f01003a5:	83 f8 0d             	cmp    $0xd,%eax
f01003a8:	74 3d                	je     f01003e7 <cons_putc+0xf5>
f01003aa:	e9 8a 00 00 00       	jmp    f0100439 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003af:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003b6:	66 85 c0             	test   %ax,%ax
f01003b9:	0f 84 e6 00 00 00    	je     f01004a5 <cons_putc+0x1b3>
			crt_pos--;
f01003bf:	83 e8 01             	sub    $0x1,%eax
f01003c2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003c8:	0f b7 c0             	movzwl %ax,%eax
f01003cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01003d0:	83 cf 20             	or     $0x20,%edi
f01003d3:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003dd:	eb 78                	jmp    f0100457 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003df:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003e7:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003f4:	c1 e8 16             	shr    $0x16,%eax
f01003f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003fa:	c1 e0 04             	shl    $0x4,%eax
f01003fd:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f0100403:	eb 52                	jmp    f0100457 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100405:	b8 20 00 00 00       	mov    $0x20,%eax
f010040a:	e8 e3 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010040f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100414:	e8 d9 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100419:	b8 20 00 00 00       	mov    $0x20,%eax
f010041e:	e8 cf fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100423:	b8 20 00 00 00       	mov    $0x20,%eax
f0100428:	e8 c5 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010042d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100432:	e8 bb fe ff ff       	call   f01002f2 <cons_putc>
f0100437:	eb 1e                	jmp    f0100457 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100439:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100440:	8d 50 01             	lea    0x1(%eax),%edx
f0100443:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010044a:	0f b7 c0             	movzwl %ax,%eax
f010044d:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100453:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100457:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010045e:	cf 07 
f0100460:	76 43                	jbe    f01004a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100462:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100467:	83 ec 04             	sub    $0x4,%esp
f010046a:	68 00 0f 00 00       	push   $0xf00
f010046f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100475:	52                   	push   %edx
f0100476:	50                   	push   %eax
f0100477:	e8 82 10 00 00       	call   f01014fe <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010047c:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100482:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100488:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010048e:	83 c4 10             	add    $0x10,%esp
f0100491:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100496:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100499:	39 d0                	cmp    %edx,%eax
f010049b:	75 f4                	jne    f0100491 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010049d:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004a5:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b0:	89 ca                	mov    %ecx,%edx
f01004b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b3:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004ba:	8d 71 01             	lea    0x1(%ecx),%esi
f01004bd:	89 d8                	mov    %ebx,%eax
f01004bf:	66 c1 e8 08          	shr    $0x8,%ax
f01004c3:	89 f2                	mov    %esi,%edx
f01004c5:	ee                   	out    %al,(%dx)
f01004c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004cb:	89 ca                	mov    %ecx,%edx
f01004cd:	ee                   	out    %al,(%dx)
f01004ce:	89 d8                	mov    %ebx,%eax
f01004d0:	89 f2                	mov    %esi,%edx
f01004d2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d6:	5b                   	pop    %ebx
f01004d7:	5e                   	pop    %esi
f01004d8:	5f                   	pop    %edi
f01004d9:	5d                   	pop    %ebp
f01004da:	c3                   	ret    

f01004db <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004db:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004e2:	74 11                	je     f01004f5 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004e4:	55                   	push   %ebp
f01004e5:	89 e5                	mov    %esp,%ebp
f01004e7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004ea:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004ef:	e8 a2 fc ff ff       	call   f0100196 <cons_intr>
}
f01004f4:	c9                   	leave  
f01004f5:	f3 c3                	repz ret 

f01004f7 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004f7:	55                   	push   %ebp
f01004f8:	89 e5                	mov    %esp,%ebp
f01004fa:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004fd:	b8 d9 01 10 f0       	mov    $0xf01001d9,%eax
f0100502:	e8 8f fc ff ff       	call   f0100196 <cons_intr>
}
f0100507:	c9                   	leave  
f0100508:	c3                   	ret    

f0100509 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100509:	55                   	push   %ebp
f010050a:	89 e5                	mov    %esp,%ebp
f010050c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010050f:	e8 c7 ff ff ff       	call   f01004db <serial_intr>
	kbd_intr();
f0100514:	e8 de ff ff ff       	call   f01004f7 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100519:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f010051e:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100524:	74 26                	je     f010054c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100526:	8d 50 01             	lea    0x1(%eax),%edx
f0100529:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010052f:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100536:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100538:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010053e:	75 11                	jne    f0100551 <cons_getc+0x48>
			cons.rpos = 0;
f0100540:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100547:	00 00 00 
f010054a:	eb 05                	jmp    f0100551 <cons_getc+0x48>
		return c;
	}
	return 0;
f010054c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100551:	c9                   	leave  
f0100552:	c3                   	ret    

f0100553 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100553:	55                   	push   %ebp
f0100554:	89 e5                	mov    %esp,%ebp
f0100556:	57                   	push   %edi
f0100557:	56                   	push   %esi
f0100558:	53                   	push   %ebx
f0100559:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010055c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100563:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010056a:	5a a5 
	if (*cp != 0xA55A) {
f010056c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100573:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100577:	74 11                	je     f010058a <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100579:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100580:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100583:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100588:	eb 16                	jmp    f01005a0 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010058a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100591:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f0100598:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010059b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005a0:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005a6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ab:	89 fa                	mov    %edi,%edx
f01005ad:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ae:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b1:	89 da                	mov    %ebx,%edx
f01005b3:	ec                   	in     (%dx),%al
f01005b4:	0f b6 c8             	movzbl %al,%ecx
f01005b7:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005bf:	89 fa                	mov    %edi,%edx
f01005c1:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005c5:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f01005cb:	0f b6 c0             	movzbl %al,%eax
f01005ce:	09 c8                	or     %ecx,%eax
f01005d0:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d6:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005db:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e0:	89 f2                	mov    %esi,%edx
f01005e2:	ee                   	out    %al,(%dx)
f01005e3:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005e8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005ed:	ee                   	out    %al,(%dx)
f01005ee:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005f3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005f8:	89 da                	mov    %ebx,%edx
f01005fa:	ee                   	out    %al,(%dx)
f01005fb:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100600:	b8 00 00 00 00       	mov    $0x0,%eax
f0100605:	ee                   	out    %al,(%dx)
f0100606:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010060b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100610:	ee                   	out    %al,(%dx)
f0100611:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100616:	b8 00 00 00 00       	mov    $0x0,%eax
f010061b:	ee                   	out    %al,(%dx)
f010061c:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100621:	b8 01 00 00 00       	mov    $0x1,%eax
f0100626:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100627:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010062c:	ec                   	in     (%dx),%al
f010062d:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010062f:	3c ff                	cmp    $0xff,%al
f0100631:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100638:	89 f2                	mov    %esi,%edx
f010063a:	ec                   	in     (%dx),%al
f010063b:	89 da                	mov    %ebx,%edx
f010063d:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010063e:	80 f9 ff             	cmp    $0xff,%cl
f0100641:	75 10                	jne    f0100653 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100643:	83 ec 0c             	sub    $0xc,%esp
f0100646:	68 f0 19 10 f0       	push   $0xf01019f0
f010064b:	e8 9d 03 00 00       	call   f01009ed <cprintf>
f0100650:	83 c4 10             	add    $0x10,%esp
}
f0100653:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100656:	5b                   	pop    %ebx
f0100657:	5e                   	pop    %esi
f0100658:	5f                   	pop    %edi
f0100659:	5d                   	pop    %ebp
f010065a:	c3                   	ret    

f010065b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010065b:	55                   	push   %ebp
f010065c:	89 e5                	mov    %esp,%ebp
f010065e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100661:	8b 45 08             	mov    0x8(%ebp),%eax
f0100664:	e8 89 fc ff ff       	call   f01002f2 <cons_putc>
}
f0100669:	c9                   	leave  
f010066a:	c3                   	ret    

f010066b <getchar>:

int
getchar(void)
{
f010066b:	55                   	push   %ebp
f010066c:	89 e5                	mov    %esp,%ebp
f010066e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100671:	e8 93 fe ff ff       	call   f0100509 <cons_getc>
f0100676:	85 c0                	test   %eax,%eax
f0100678:	74 f7                	je     f0100671 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010067a:	c9                   	leave  
f010067b:	c3                   	ret    

f010067c <iscons>:

int
iscons(int fdnum)
{
f010067c:	55                   	push   %ebp
f010067d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010067f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100684:	5d                   	pop    %ebp
f0100685:	c3                   	ret    

f0100686 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100686:	55                   	push   %ebp
f0100687:	89 e5                	mov    %esp,%ebp
f0100689:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010068c:	68 40 1c 10 f0       	push   $0xf0101c40
f0100691:	68 5e 1c 10 f0       	push   $0xf0101c5e
f0100696:	68 63 1c 10 f0       	push   $0xf0101c63
f010069b:	e8 4d 03 00 00       	call   f01009ed <cprintf>
f01006a0:	83 c4 0c             	add    $0xc,%esp
f01006a3:	68 1c 1d 10 f0       	push   $0xf0101d1c
f01006a8:	68 6c 1c 10 f0       	push   $0xf0101c6c
f01006ad:	68 63 1c 10 f0       	push   $0xf0101c63
f01006b2:	e8 36 03 00 00       	call   f01009ed <cprintf>
f01006b7:	83 c4 0c             	add    $0xc,%esp
f01006ba:	68 75 1c 10 f0       	push   $0xf0101c75
f01006bf:	68 93 1c 10 f0       	push   $0xf0101c93
f01006c4:	68 63 1c 10 f0       	push   $0xf0101c63
f01006c9:	e8 1f 03 00 00       	call   f01009ed <cprintf>
	return 0;
}
f01006ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d3:	c9                   	leave  
f01006d4:	c3                   	ret    

f01006d5 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006d5:	55                   	push   %ebp
f01006d6:	89 e5                	mov    %esp,%ebp
f01006d8:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006db:	68 9d 1c 10 f0       	push   $0xf0101c9d
f01006e0:	e8 08 03 00 00       	call   f01009ed <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006e5:	83 c4 08             	add    $0x8,%esp
f01006e8:	68 0c 00 10 00       	push   $0x10000c
f01006ed:	68 44 1d 10 f0       	push   $0xf0101d44
f01006f2:	e8 f6 02 00 00       	call   f01009ed <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006f7:	83 c4 0c             	add    $0xc,%esp
f01006fa:	68 0c 00 10 00       	push   $0x10000c
f01006ff:	68 0c 00 10 f0       	push   $0xf010000c
f0100704:	68 6c 1d 10 f0       	push   $0xf0101d6c
f0100709:	e8 df 02 00 00       	call   f01009ed <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010070e:	83 c4 0c             	add    $0xc,%esp
f0100711:	68 41 19 10 00       	push   $0x101941
f0100716:	68 41 19 10 f0       	push   $0xf0101941
f010071b:	68 90 1d 10 f0       	push   $0xf0101d90
f0100720:	e8 c8 02 00 00       	call   f01009ed <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100725:	83 c4 0c             	add    $0xc,%esp
f0100728:	68 00 23 11 00       	push   $0x112300
f010072d:	68 00 23 11 f0       	push   $0xf0112300
f0100732:	68 b4 1d 10 f0       	push   $0xf0101db4
f0100737:	e8 b1 02 00 00       	call   f01009ed <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010073c:	83 c4 0c             	add    $0xc,%esp
f010073f:	68 40 29 11 00       	push   $0x112940
f0100744:	68 40 29 11 f0       	push   $0xf0112940
f0100749:	68 d8 1d 10 f0       	push   $0xf0101dd8
f010074e:	e8 9a 02 00 00       	call   f01009ed <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100753:	b8 3f 2d 11 f0       	mov    $0xf0112d3f,%eax
f0100758:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010075d:	83 c4 08             	add    $0x8,%esp
f0100760:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100765:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010076b:	85 c0                	test   %eax,%eax
f010076d:	0f 48 c2             	cmovs  %edx,%eax
f0100770:	c1 f8 0a             	sar    $0xa,%eax
f0100773:	50                   	push   %eax
f0100774:	68 fc 1d 10 f0       	push   $0xf0101dfc
f0100779:	e8 6f 02 00 00       	call   f01009ed <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010077e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100783:	c9                   	leave  
f0100784:	c3                   	ret    

f0100785 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100785:	55                   	push   %ebp
f0100786:	89 e5                	mov    %esp,%ebp
f0100788:	57                   	push   %edi
f0100789:	56                   	push   %esi
f010078a:	53                   	push   %ebx
f010078b:	83 ec 78             	sub    $0x78,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010078e:	89 eb                	mov    %ebp,%ebx

	uint32_t _ebp, _eip;
	// _esp = read_esp();
	_ebp = read_ebp();

	uint32_t args[5] = {0, 0, 0, 0, 0};
f0100790:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100797:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010079e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01007a5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01007ac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");
f01007b3:	68 b6 1c 10 f0       	push   $0xf0101cb6
f01007b8:	e8 30 02 00 00       	call   f01009ed <cprintf>

	while (_ebp != 0) {
f01007bd:	83 c4 10             	add    $0x10,%esp
f01007c0:	e9 a6 00 00 00       	jmp    f010086b <mon_backtrace+0xe6>
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr
f01007c5:	8b 73 04             	mov    0x4(%ebx),%esi

		for (int i=0; i<5; i++) {
f01007c8:	b8 00 00 00 00       	mov    $0x0,%eax
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
f01007cd:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f01007d1:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)

	while (_ebp != 0) {
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr

		for (int i=0; i<5; i++) {
f01007d5:	83 c0 01             	add    $0x1,%eax
f01007d8:	83 f8 05             	cmp    $0x5,%eax
f01007db:	75 f0                	jne    f01007cd <mon_backtrace+0x48>
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
		}

		debuginfo_eip((uintptr_t)_eip, &context);
f01007dd:	83 ec 08             	sub    $0x8,%esp
f01007e0:	8d 45 bc             	lea    -0x44(%ebp),%eax
f01007e3:	50                   	push   %eax
f01007e4:	56                   	push   %esi
f01007e5:	e8 0d 03 00 00       	call   f0100af7 <debuginfo_eip>

		char function_name[50] = {0};
f01007ea:	c7 45 8a 00 00 00 00 	movl   $0x0,-0x76(%ebp)
f01007f1:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
f01007f8:	8d 7d 8c             	lea    -0x74(%ebp),%edi
f01007fb:	b9 0c 00 00 00       	mov    $0xc,%ecx
f0100800:	b8 00 00 00 00       	mov    $0x0,%eax
f0100805:	f3 ab                	rep stos %eax,%es:(%edi)
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f0100807:	8b 4d c8             	mov    -0x38(%ebp),%ecx
			function_name[i] = context.eip_fn_name[i];
f010080a:	8b 7d c4             	mov    -0x3c(%ebp),%edi

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f010080d:	83 c4 10             	add    $0x10,%esp
f0100810:	eb 0b                	jmp    f010081d <mon_backtrace+0x98>
			function_name[i] = context.eip_fn_name[i];
f0100812:	0f b6 14 07          	movzbl (%edi,%eax,1),%edx
f0100816:	88 54 05 8a          	mov    %dl,-0x76(%ebp,%eax,1)

		debuginfo_eip((uintptr_t)_eip, &context);

		char function_name[50] = {0};
		int i = 0;
		for (; i<context.eip_fn_namelen; i++) {
f010081a:	83 c0 01             	add    $0x1,%eax
f010081d:	39 c8                	cmp    %ecx,%eax
f010081f:	7c f1                	jl     f0100812 <mon_backtrace+0x8d>
			function_name[i] = context.eip_fn_name[i];
		}
		function_name[i] = '\0';
f0100821:	85 c9                	test   %ecx,%ecx
f0100823:	b8 00 00 00 00       	mov    $0x0,%eax
f0100828:	0f 48 c8             	cmovs  %eax,%ecx
f010082b:	c6 44 0d 8a 00       	movb   $0x0,-0x76(%ebp,%ecx,1)

		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", _ebp, _eip, args[0], args[1], args[2], args[3], args[4]);
f0100830:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100833:	ff 75 e0             	pushl  -0x20(%ebp)
f0100836:	ff 75 dc             	pushl  -0x24(%ebp)
f0100839:	ff 75 d8             	pushl  -0x28(%ebp)
f010083c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010083f:	56                   	push   %esi
f0100840:	53                   	push   %ebx
f0100841:	68 28 1e 10 f0       	push   $0xf0101e28
f0100846:	e8 a2 01 00 00       	call   f01009ed <cprintf>
		cprintf("         %s:%d: %s+%d\n", context.eip_file, context.eip_line, function_name, _eip - context.eip_fn_addr);
f010084b:	83 c4 14             	add    $0x14,%esp
f010084e:	2b 75 cc             	sub    -0x34(%ebp),%esi
f0100851:	56                   	push   %esi
f0100852:	8d 45 8a             	lea    -0x76(%ebp),%eax
f0100855:	50                   	push   %eax
f0100856:	ff 75 c0             	pushl  -0x40(%ebp)
f0100859:	ff 75 bc             	pushl  -0x44(%ebp)
f010085c:	68 c8 1c 10 f0       	push   $0xf0101cc8
f0100861:	e8 87 01 00 00       	call   f01009ed <cprintf>

		// _rsp = _ebp + 8;			// old_rsp
		_ebp = *(uint32_t *)_ebp;	// old_ebp
f0100866:	8b 1b                	mov    (%ebx),%ebx
f0100868:	83 c4 20             	add    $0x20,%esp

	struct Eipdebuginfo context;

	cprintf("Stack backtrace:\n");

	while (_ebp != 0) {
f010086b:	85 db                	test   %ebx,%ebx
f010086d:	0f 85 52 ff ff ff    	jne    f01007c5 <mon_backtrace+0x40>
		_ebp = *(uint32_t *)_ebp;	// old_ebp

	} 

	return 0;
}
f0100873:	b8 00 00 00 00       	mov    $0x0,%eax
f0100878:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010087b:	5b                   	pop    %ebx
f010087c:	5e                   	pop    %esi
f010087d:	5f                   	pop    %edi
f010087e:	5d                   	pop    %ebp
f010087f:	c3                   	ret    

f0100880 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100880:	55                   	push   %ebp
f0100881:	89 e5                	mov    %esp,%ebp
f0100883:	57                   	push   %edi
f0100884:	56                   	push   %esi
f0100885:	53                   	push   %ebx
f0100886:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100889:	68 60 1e 10 f0       	push   $0xf0101e60
f010088e:	e8 5a 01 00 00       	call   f01009ed <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100893:	c7 04 24 84 1e 10 f0 	movl   $0xf0101e84,(%esp)
f010089a:	e8 4e 01 00 00       	call   f01009ed <cprintf>
f010089f:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01008a2:	83 ec 0c             	sub    $0xc,%esp
f01008a5:	68 df 1c 10 f0       	push   $0xf0101cdf
f01008aa:	e8 ab 09 00 00       	call   f010125a <readline>
f01008af:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008b1:	83 c4 10             	add    $0x10,%esp
f01008b4:	85 c0                	test   %eax,%eax
f01008b6:	74 ea                	je     f01008a2 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008b8:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01008bf:	be 00 00 00 00       	mov    $0x0,%esi
f01008c4:	eb 0a                	jmp    f01008d0 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008c6:	c6 03 00             	movb   $0x0,(%ebx)
f01008c9:	89 f7                	mov    %esi,%edi
f01008cb:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01008ce:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008d0:	0f b6 03             	movzbl (%ebx),%eax
f01008d3:	84 c0                	test   %al,%al
f01008d5:	74 63                	je     f010093a <monitor+0xba>
f01008d7:	83 ec 08             	sub    $0x8,%esp
f01008da:	0f be c0             	movsbl %al,%eax
f01008dd:	50                   	push   %eax
f01008de:	68 e3 1c 10 f0       	push   $0xf0101ce3
f01008e3:	e8 8c 0b 00 00       	call   f0101474 <strchr>
f01008e8:	83 c4 10             	add    $0x10,%esp
f01008eb:	85 c0                	test   %eax,%eax
f01008ed:	75 d7                	jne    f01008c6 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01008ef:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008f2:	74 46                	je     f010093a <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008f4:	83 fe 0f             	cmp    $0xf,%esi
f01008f7:	75 14                	jne    f010090d <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008f9:	83 ec 08             	sub    $0x8,%esp
f01008fc:	6a 10                	push   $0x10
f01008fe:	68 e8 1c 10 f0       	push   $0xf0101ce8
f0100903:	e8 e5 00 00 00       	call   f01009ed <cprintf>
f0100908:	83 c4 10             	add    $0x10,%esp
f010090b:	eb 95                	jmp    f01008a2 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f010090d:	8d 7e 01             	lea    0x1(%esi),%edi
f0100910:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100914:	eb 03                	jmp    f0100919 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100916:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100919:	0f b6 03             	movzbl (%ebx),%eax
f010091c:	84 c0                	test   %al,%al
f010091e:	74 ae                	je     f01008ce <monitor+0x4e>
f0100920:	83 ec 08             	sub    $0x8,%esp
f0100923:	0f be c0             	movsbl %al,%eax
f0100926:	50                   	push   %eax
f0100927:	68 e3 1c 10 f0       	push   $0xf0101ce3
f010092c:	e8 43 0b 00 00       	call   f0101474 <strchr>
f0100931:	83 c4 10             	add    $0x10,%esp
f0100934:	85 c0                	test   %eax,%eax
f0100936:	74 de                	je     f0100916 <monitor+0x96>
f0100938:	eb 94                	jmp    f01008ce <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f010093a:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100941:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100942:	85 f6                	test   %esi,%esi
f0100944:	0f 84 58 ff ff ff    	je     f01008a2 <monitor+0x22>
f010094a:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010094f:	83 ec 08             	sub    $0x8,%esp
f0100952:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100955:	ff 34 85 c0 1e 10 f0 	pushl  -0xfefe140(,%eax,4)
f010095c:	ff 75 a8             	pushl  -0x58(%ebp)
f010095f:	e8 b2 0a 00 00       	call   f0101416 <strcmp>
f0100964:	83 c4 10             	add    $0x10,%esp
f0100967:	85 c0                	test   %eax,%eax
f0100969:	75 21                	jne    f010098c <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f010096b:	83 ec 04             	sub    $0x4,%esp
f010096e:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100971:	ff 75 08             	pushl  0x8(%ebp)
f0100974:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100977:	52                   	push   %edx
f0100978:	56                   	push   %esi
f0100979:	ff 14 85 c8 1e 10 f0 	call   *-0xfefe138(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100980:	83 c4 10             	add    $0x10,%esp
f0100983:	85 c0                	test   %eax,%eax
f0100985:	78 25                	js     f01009ac <monitor+0x12c>
f0100987:	e9 16 ff ff ff       	jmp    f01008a2 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010098c:	83 c3 01             	add    $0x1,%ebx
f010098f:	83 fb 03             	cmp    $0x3,%ebx
f0100992:	75 bb                	jne    f010094f <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100994:	83 ec 08             	sub    $0x8,%esp
f0100997:	ff 75 a8             	pushl  -0x58(%ebp)
f010099a:	68 05 1d 10 f0       	push   $0xf0101d05
f010099f:	e8 49 00 00 00       	call   f01009ed <cprintf>
f01009a4:	83 c4 10             	add    $0x10,%esp
f01009a7:	e9 f6 fe ff ff       	jmp    f01008a2 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009af:	5b                   	pop    %ebx
f01009b0:	5e                   	pop    %esi
f01009b1:	5f                   	pop    %edi
f01009b2:	5d                   	pop    %ebp
f01009b3:	c3                   	ret    

f01009b4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009b4:	55                   	push   %ebp
f01009b5:	89 e5                	mov    %esp,%ebp
f01009b7:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01009ba:	ff 75 08             	pushl  0x8(%ebp)
f01009bd:	e8 99 fc ff ff       	call   f010065b <cputchar>
	*cnt++;
}
f01009c2:	83 c4 10             	add    $0x10,%esp
f01009c5:	c9                   	leave  
f01009c6:	c3                   	ret    

f01009c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01009c7:	55                   	push   %ebp
f01009c8:	89 e5                	mov    %esp,%ebp
f01009ca:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01009cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01009d4:	ff 75 0c             	pushl  0xc(%ebp)
f01009d7:	ff 75 08             	pushl  0x8(%ebp)
f01009da:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01009dd:	50                   	push   %eax
f01009de:	68 b4 09 10 f0       	push   $0xf01009b4
f01009e3:	e8 5d 04 00 00       	call   f0100e45 <vprintfmt>
	return cnt;
}
f01009e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009eb:	c9                   	leave  
f01009ec:	c3                   	ret    

f01009ed <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009ed:	55                   	push   %ebp
f01009ee:	89 e5                	mov    %esp,%ebp
f01009f0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009f3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009f6:	50                   	push   %eax
f01009f7:	ff 75 08             	pushl  0x8(%ebp)
f01009fa:	e8 c8 ff ff ff       	call   f01009c7 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009ff:	c9                   	leave  
f0100a00:	c3                   	ret    

f0100a01 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100a01:	55                   	push   %ebp
f0100a02:	89 e5                	mov    %esp,%ebp
f0100a04:	57                   	push   %edi
f0100a05:	56                   	push   %esi
f0100a06:	53                   	push   %ebx
f0100a07:	83 ec 14             	sub    $0x14,%esp
f0100a0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100a0d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100a10:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100a13:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a16:	8b 1a                	mov    (%edx),%ebx
f0100a18:	8b 01                	mov    (%ecx),%eax
f0100a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a1d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100a24:	eb 7f                	jmp    f0100aa5 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0100a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a29:	01 d8                	add    %ebx,%eax
f0100a2b:	89 c6                	mov    %eax,%esi
f0100a2d:	c1 ee 1f             	shr    $0x1f,%esi
f0100a30:	01 c6                	add    %eax,%esi
f0100a32:	d1 fe                	sar    %esi
f0100a34:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a37:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a3a:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100a3d:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a3f:	eb 03                	jmp    f0100a44 <stab_binsearch+0x43>
			m--;
f0100a41:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a44:	39 c3                	cmp    %eax,%ebx
f0100a46:	7f 0d                	jg     f0100a55 <stab_binsearch+0x54>
f0100a48:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100a4c:	83 ea 0c             	sub    $0xc,%edx
f0100a4f:	39 f9                	cmp    %edi,%ecx
f0100a51:	75 ee                	jne    f0100a41 <stab_binsearch+0x40>
f0100a53:	eb 05                	jmp    f0100a5a <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a55:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100a58:	eb 4b                	jmp    f0100aa5 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a5a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a5d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a60:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a64:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a67:	76 11                	jbe    f0100a7a <stab_binsearch+0x79>
			*region_left = m;
f0100a69:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a6c:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a6e:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a71:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a78:	eb 2b                	jmp    f0100aa5 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a7a:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a7d:	73 14                	jae    f0100a93 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a7f:	83 e8 01             	sub    $0x1,%eax
f0100a82:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a85:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a88:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a8a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a91:	eb 12                	jmp    f0100aa5 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a93:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a96:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a98:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a9c:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a9e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100aa5:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100aa8:	0f 8e 78 ff ff ff    	jle    f0100a26 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100aae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100ab2:	75 0f                	jne    f0100ac3 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100ab4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ab7:	8b 00                	mov    (%eax),%eax
f0100ab9:	83 e8 01             	sub    $0x1,%eax
f0100abc:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100abf:	89 06                	mov    %eax,(%esi)
f0100ac1:	eb 2c                	jmp    f0100aef <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ac3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ac6:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100ac8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100acb:	8b 0e                	mov    (%esi),%ecx
f0100acd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ad0:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100ad3:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ad6:	eb 03                	jmp    f0100adb <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100ad8:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100adb:	39 c8                	cmp    %ecx,%eax
f0100add:	7e 0b                	jle    f0100aea <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100adf:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100ae3:	83 ea 0c             	sub    $0xc,%edx
f0100ae6:	39 df                	cmp    %ebx,%edi
f0100ae8:	75 ee                	jne    f0100ad8 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100aea:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100aed:	89 06                	mov    %eax,(%esi)
	}
}
f0100aef:	83 c4 14             	add    $0x14,%esp
f0100af2:	5b                   	pop    %ebx
f0100af3:	5e                   	pop    %esi
f0100af4:	5f                   	pop    %edi
f0100af5:	5d                   	pop    %ebp
f0100af6:	c3                   	ret    

f0100af7 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100af7:	55                   	push   %ebp
f0100af8:	89 e5                	mov    %esp,%ebp
f0100afa:	57                   	push   %edi
f0100afb:	56                   	push   %esi
f0100afc:	53                   	push   %ebx
f0100afd:	83 ec 3c             	sub    $0x3c,%esp
f0100b00:	8b 75 08             	mov    0x8(%ebp),%esi
f0100b03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b06:	c7 03 e4 1e 10 f0    	movl   $0xf0101ee4,(%ebx)
	info->eip_line = 0;
f0100b0c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100b13:	c7 43 08 e4 1e 10 f0 	movl   $0xf0101ee4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100b1a:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100b21:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100b24:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b2b:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100b31:	76 11                	jbe    f0100b44 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b33:	b8 e7 74 10 f0       	mov    $0xf01074e7,%eax
f0100b38:	3d 79 5b 10 f0       	cmp    $0xf0105b79,%eax
f0100b3d:	77 19                	ja     f0100b58 <debuginfo_eip+0x61>
f0100b3f:	e9 b5 01 00 00       	jmp    f0100cf9 <debuginfo_eip+0x202>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b44:	83 ec 04             	sub    $0x4,%esp
f0100b47:	68 ee 1e 10 f0       	push   $0xf0101eee
f0100b4c:	6a 7f                	push   $0x7f
f0100b4e:	68 fb 1e 10 f0       	push   $0xf0101efb
f0100b53:	e8 8e f5 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b58:	80 3d e6 74 10 f0 00 	cmpb   $0x0,0xf01074e6
f0100b5f:	0f 85 9b 01 00 00    	jne    f0100d00 <debuginfo_eip+0x209>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b65:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b6c:	b8 78 5b 10 f0       	mov    $0xf0105b78,%eax
f0100b71:	2d 1c 21 10 f0       	sub    $0xf010211c,%eax
f0100b76:	c1 f8 02             	sar    $0x2,%eax
f0100b79:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b7f:	83 e8 01             	sub    $0x1,%eax
f0100b82:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b85:	83 ec 08             	sub    $0x8,%esp
f0100b88:	56                   	push   %esi
f0100b89:	6a 64                	push   $0x64
f0100b8b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b8e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b91:	b8 1c 21 10 f0       	mov    $0xf010211c,%eax
f0100b96:	e8 66 fe ff ff       	call   f0100a01 <stab_binsearch>
	if (lfile == 0)
f0100b9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b9e:	83 c4 10             	add    $0x10,%esp
f0100ba1:	85 c0                	test   %eax,%eax
f0100ba3:	0f 84 5e 01 00 00    	je     f0100d07 <debuginfo_eip+0x210>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100ba9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100bac:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100baf:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100bb2:	83 ec 08             	sub    $0x8,%esp
f0100bb5:	56                   	push   %esi
f0100bb6:	6a 24                	push   $0x24
f0100bb8:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100bbb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bbe:	b8 1c 21 10 f0       	mov    $0xf010211c,%eax
f0100bc3:	e8 39 fe ff ff       	call   f0100a01 <stab_binsearch>

	if (lfun <= rfun) {
f0100bc8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100bcb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100bce:	83 c4 10             	add    $0x10,%esp
f0100bd1:	39 d0                	cmp    %edx,%eax
f0100bd3:	7f 40                	jg     f0100c15 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100bd5:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100bd8:	c1 e1 02             	shl    $0x2,%ecx
f0100bdb:	8d b9 1c 21 10 f0    	lea    -0xfefdee4(%ecx),%edi
f0100be1:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100be4:	8b b9 1c 21 10 f0    	mov    -0xfefdee4(%ecx),%edi
f0100bea:	b9 e7 74 10 f0       	mov    $0xf01074e7,%ecx
f0100bef:	81 e9 79 5b 10 f0    	sub    $0xf0105b79,%ecx
f0100bf5:	39 cf                	cmp    %ecx,%edi
f0100bf7:	73 09                	jae    f0100c02 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100bf9:	81 c7 79 5b 10 f0    	add    $0xf0105b79,%edi
f0100bff:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c02:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100c05:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100c08:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100c0b:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100c0d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100c10:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100c13:	eb 0f                	jmp    f0100c24 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100c15:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100c18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c1b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100c1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c21:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c24:	83 ec 08             	sub    $0x8,%esp
f0100c27:	6a 3a                	push   $0x3a
f0100c29:	ff 73 08             	pushl  0x8(%ebx)
f0100c2c:	e8 64 08 00 00       	call   f0101495 <strfind>
f0100c31:	2b 43 08             	sub    0x8(%ebx),%eax
f0100c34:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100c37:	83 c4 08             	add    $0x8,%esp
f0100c3a:	56                   	push   %esi
f0100c3b:	6a 44                	push   $0x44
f0100c3d:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100c40:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100c43:	b8 1c 21 10 f0       	mov    $0xf010211c,%eax
f0100c48:	e8 b4 fd ff ff       	call   f0100a01 <stab_binsearch>
	if (lline == 0)
f0100c4d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c50:	83 c4 10             	add    $0x10,%esp
f0100c53:	85 c0                	test   %eax,%eax
f0100c55:	0f 84 b3 00 00 00    	je     f0100d0e <debuginfo_eip+0x217>
		return -1;
	// cprintf("[+] %d, %d, %d, %x\n", lline, rline, lfun, stabs[lfun].n_value);
	info->eip_line = stabs[rline].n_desc;
f0100c5b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100c5e:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c61:	0f b7 14 95 22 21 10 	movzwl -0xfefdede(,%edx,4),%edx
f0100c68:	f0 
f0100c69:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c6c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c6f:	89 c2                	mov    %eax,%edx
f0100c71:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100c74:	8d 04 85 1c 21 10 f0 	lea    -0xfefdee4(,%eax,4),%eax
f0100c7b:	eb 06                	jmp    f0100c83 <debuginfo_eip+0x18c>
f0100c7d:	83 ea 01             	sub    $0x1,%edx
f0100c80:	83 e8 0c             	sub    $0xc,%eax
f0100c83:	39 d7                	cmp    %edx,%edi
f0100c85:	7f 34                	jg     f0100cbb <debuginfo_eip+0x1c4>
	       && stabs[lline].n_type != N_SOL
f0100c87:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100c8b:	80 f9 84             	cmp    $0x84,%cl
f0100c8e:	74 0b                	je     f0100c9b <debuginfo_eip+0x1a4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c90:	80 f9 64             	cmp    $0x64,%cl
f0100c93:	75 e8                	jne    f0100c7d <debuginfo_eip+0x186>
f0100c95:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c99:	74 e2                	je     f0100c7d <debuginfo_eip+0x186>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c9b:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c9e:	8b 14 85 1c 21 10 f0 	mov    -0xfefdee4(,%eax,4),%edx
f0100ca5:	b8 e7 74 10 f0       	mov    $0xf01074e7,%eax
f0100caa:	2d 79 5b 10 f0       	sub    $0xf0105b79,%eax
f0100caf:	39 c2                	cmp    %eax,%edx
f0100cb1:	73 08                	jae    f0100cbb <debuginfo_eip+0x1c4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100cb3:	81 c2 79 5b 10 f0    	add    $0xf0105b79,%edx
f0100cb9:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100cbb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cbe:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cc1:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100cc6:	39 f2                	cmp    %esi,%edx
f0100cc8:	7d 50                	jge    f0100d1a <debuginfo_eip+0x223>
		for (lline = lfun + 1;
f0100cca:	83 c2 01             	add    $0x1,%edx
f0100ccd:	89 d0                	mov    %edx,%eax
f0100ccf:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100cd2:	8d 14 95 1c 21 10 f0 	lea    -0xfefdee4(,%edx,4),%edx
f0100cd9:	eb 04                	jmp    f0100cdf <debuginfo_eip+0x1e8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100cdb:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100cdf:	39 c6                	cmp    %eax,%esi
f0100ce1:	7e 32                	jle    f0100d15 <debuginfo_eip+0x21e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ce3:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100ce7:	83 c0 01             	add    $0x1,%eax
f0100cea:	83 c2 0c             	add    $0xc,%edx
f0100ced:	80 f9 a0             	cmp    $0xa0,%cl
f0100cf0:	74 e9                	je     f0100cdb <debuginfo_eip+0x1e4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cf2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cf7:	eb 21                	jmp    f0100d1a <debuginfo_eip+0x223>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100cf9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cfe:	eb 1a                	jmp    f0100d1a <debuginfo_eip+0x223>
f0100d00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d05:	eb 13                	jmp    f0100d1a <debuginfo_eip+0x223>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100d07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d0c:	eb 0c                	jmp    f0100d1a <debuginfo_eip+0x223>
	// Your code here.


	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == 0)
		return -1;
f0100d0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d13:	eb 05                	jmp    f0100d1a <debuginfo_eip+0x223>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d15:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d1d:	5b                   	pop    %ebx
f0100d1e:	5e                   	pop    %esi
f0100d1f:	5f                   	pop    %edi
f0100d20:	5d                   	pop    %ebp
f0100d21:	c3                   	ret    

f0100d22 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d22:	55                   	push   %ebp
f0100d23:	89 e5                	mov    %esp,%ebp
f0100d25:	57                   	push   %edi
f0100d26:	56                   	push   %esi
f0100d27:	53                   	push   %ebx
f0100d28:	83 ec 1c             	sub    $0x1c,%esp
f0100d2b:	89 c7                	mov    %eax,%edi
f0100d2d:	89 d6                	mov    %edx,%esi
f0100d2f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d32:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d35:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100d38:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d3b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100d3e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d43:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100d46:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100d49:	39 d3                	cmp    %edx,%ebx
f0100d4b:	72 05                	jb     f0100d52 <printnum+0x30>
f0100d4d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100d50:	77 45                	ja     f0100d97 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d52:	83 ec 0c             	sub    $0xc,%esp
f0100d55:	ff 75 18             	pushl  0x18(%ebp)
f0100d58:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d5b:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100d5e:	53                   	push   %ebx
f0100d5f:	ff 75 10             	pushl  0x10(%ebp)
f0100d62:	83 ec 08             	sub    $0x8,%esp
f0100d65:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d68:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d6b:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d6e:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d71:	e8 4a 09 00 00       	call   f01016c0 <__udivdi3>
f0100d76:	83 c4 18             	add    $0x18,%esp
f0100d79:	52                   	push   %edx
f0100d7a:	50                   	push   %eax
f0100d7b:	89 f2                	mov    %esi,%edx
f0100d7d:	89 f8                	mov    %edi,%eax
f0100d7f:	e8 9e ff ff ff       	call   f0100d22 <printnum>
f0100d84:	83 c4 20             	add    $0x20,%esp
f0100d87:	eb 18                	jmp    f0100da1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d89:	83 ec 08             	sub    $0x8,%esp
f0100d8c:	56                   	push   %esi
f0100d8d:	ff 75 18             	pushl  0x18(%ebp)
f0100d90:	ff d7                	call   *%edi
f0100d92:	83 c4 10             	add    $0x10,%esp
f0100d95:	eb 03                	jmp    f0100d9a <printnum+0x78>
f0100d97:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d9a:	83 eb 01             	sub    $0x1,%ebx
f0100d9d:	85 db                	test   %ebx,%ebx
f0100d9f:	7f e8                	jg     f0100d89 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100da1:	83 ec 08             	sub    $0x8,%esp
f0100da4:	56                   	push   %esi
f0100da5:	83 ec 04             	sub    $0x4,%esp
f0100da8:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100dab:	ff 75 e0             	pushl  -0x20(%ebp)
f0100dae:	ff 75 dc             	pushl  -0x24(%ebp)
f0100db1:	ff 75 d8             	pushl  -0x28(%ebp)
f0100db4:	e8 37 0a 00 00       	call   f01017f0 <__umoddi3>
f0100db9:	83 c4 14             	add    $0x14,%esp
f0100dbc:	0f be 80 09 1f 10 f0 	movsbl -0xfefe0f7(%eax),%eax
f0100dc3:	50                   	push   %eax
f0100dc4:	ff d7                	call   *%edi
}
f0100dc6:	83 c4 10             	add    $0x10,%esp
f0100dc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dcc:	5b                   	pop    %ebx
f0100dcd:	5e                   	pop    %esi
f0100dce:	5f                   	pop    %edi
f0100dcf:	5d                   	pop    %ebp
f0100dd0:	c3                   	ret    

f0100dd1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100dd1:	55                   	push   %ebp
f0100dd2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100dd4:	83 fa 01             	cmp    $0x1,%edx
f0100dd7:	7e 0e                	jle    f0100de7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100dd9:	8b 10                	mov    (%eax),%edx
f0100ddb:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100dde:	89 08                	mov    %ecx,(%eax)
f0100de0:	8b 02                	mov    (%edx),%eax
f0100de2:	8b 52 04             	mov    0x4(%edx),%edx
f0100de5:	eb 22                	jmp    f0100e09 <getuint+0x38>
	else if (lflag)
f0100de7:	85 d2                	test   %edx,%edx
f0100de9:	74 10                	je     f0100dfb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100deb:	8b 10                	mov    (%eax),%edx
f0100ded:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100df0:	89 08                	mov    %ecx,(%eax)
f0100df2:	8b 02                	mov    (%edx),%eax
f0100df4:	ba 00 00 00 00       	mov    $0x0,%edx
f0100df9:	eb 0e                	jmp    f0100e09 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100dfb:	8b 10                	mov    (%eax),%edx
f0100dfd:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e00:	89 08                	mov    %ecx,(%eax)
f0100e02:	8b 02                	mov    (%edx),%eax
f0100e04:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100e09:	5d                   	pop    %ebp
f0100e0a:	c3                   	ret    

f0100e0b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100e0b:	55                   	push   %ebp
f0100e0c:	89 e5                	mov    %esp,%ebp
f0100e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100e11:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100e15:	8b 10                	mov    (%eax),%edx
f0100e17:	3b 50 04             	cmp    0x4(%eax),%edx
f0100e1a:	73 0a                	jae    f0100e26 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100e1c:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100e1f:	89 08                	mov    %ecx,(%eax)
f0100e21:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e24:	88 02                	mov    %al,(%edx)
}
f0100e26:	5d                   	pop    %ebp
f0100e27:	c3                   	ret    

f0100e28 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100e28:	55                   	push   %ebp
f0100e29:	89 e5                	mov    %esp,%ebp
f0100e2b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100e2e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100e31:	50                   	push   %eax
f0100e32:	ff 75 10             	pushl  0x10(%ebp)
f0100e35:	ff 75 0c             	pushl  0xc(%ebp)
f0100e38:	ff 75 08             	pushl  0x8(%ebp)
f0100e3b:	e8 05 00 00 00       	call   f0100e45 <vprintfmt>
	va_end(ap);
}
f0100e40:	83 c4 10             	add    $0x10,%esp
f0100e43:	c9                   	leave  
f0100e44:	c3                   	ret    

f0100e45 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100e45:	55                   	push   %ebp
f0100e46:	89 e5                	mov    %esp,%ebp
f0100e48:	57                   	push   %edi
f0100e49:	56                   	push   %esi
f0100e4a:	53                   	push   %ebx
f0100e4b:	83 ec 2c             	sub    $0x2c,%esp
f0100e4e:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100e54:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100e57:	eb 12                	jmp    f0100e6b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100e59:	85 c0                	test   %eax,%eax
f0100e5b:	0f 84 89 03 00 00    	je     f01011ea <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100e61:	83 ec 08             	sub    $0x8,%esp
f0100e64:	53                   	push   %ebx
f0100e65:	50                   	push   %eax
f0100e66:	ff d6                	call   *%esi
f0100e68:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e6b:	83 c7 01             	add    $0x1,%edi
f0100e6e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100e72:	83 f8 25             	cmp    $0x25,%eax
f0100e75:	75 e2                	jne    f0100e59 <vprintfmt+0x14>
f0100e77:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100e7b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e82:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e89:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e90:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e95:	eb 07                	jmp    f0100e9e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e97:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e9a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e9e:	8d 47 01             	lea    0x1(%edi),%eax
f0100ea1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100ea4:	0f b6 07             	movzbl (%edi),%eax
f0100ea7:	0f b6 c8             	movzbl %al,%ecx
f0100eaa:	83 e8 23             	sub    $0x23,%eax
f0100ead:	3c 55                	cmp    $0x55,%al
f0100eaf:	0f 87 1a 03 00 00    	ja     f01011cf <vprintfmt+0x38a>
f0100eb5:	0f b6 c0             	movzbl %al,%eax
f0100eb8:	ff 24 85 98 1f 10 f0 	jmp    *-0xfefe068(,%eax,4)
f0100ebf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100ec2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100ec6:	eb d6                	jmp    f0100e9e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ec8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ecb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ed0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100ed3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100ed6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100eda:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100edd:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100ee0:	83 fa 09             	cmp    $0x9,%edx
f0100ee3:	77 39                	ja     f0100f1e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100ee5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100ee8:	eb e9                	jmp    f0100ed3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100eea:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eed:	8d 48 04             	lea    0x4(%eax),%ecx
f0100ef0:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100ef3:	8b 00                	mov    (%eax),%eax
f0100ef5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ef8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100efb:	eb 27                	jmp    f0100f24 <vprintfmt+0xdf>
f0100efd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f00:	85 c0                	test   %eax,%eax
f0100f02:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f07:	0f 49 c8             	cmovns %eax,%ecx
f0100f0a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f10:	eb 8c                	jmp    f0100e9e <vprintfmt+0x59>
f0100f12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100f15:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100f1c:	eb 80                	jmp    f0100e9e <vprintfmt+0x59>
f0100f1e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100f21:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100f24:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f28:	0f 89 70 ff ff ff    	jns    f0100e9e <vprintfmt+0x59>
				width = precision, precision = -1;
f0100f2e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100f31:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f34:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100f3b:	e9 5e ff ff ff       	jmp    f0100e9e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100f40:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100f46:	e9 53 ff ff ff       	jmp    f0100e9e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100f4b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f4e:	8d 50 04             	lea    0x4(%eax),%edx
f0100f51:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f54:	83 ec 08             	sub    $0x8,%esp
f0100f57:	53                   	push   %ebx
f0100f58:	ff 30                	pushl  (%eax)
f0100f5a:	ff d6                	call   *%esi
			break;
f0100f5c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100f62:	e9 04 ff ff ff       	jmp    f0100e6b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f67:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f6a:	8d 50 04             	lea    0x4(%eax),%edx
f0100f6d:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f70:	8b 00                	mov    (%eax),%eax
f0100f72:	99                   	cltd   
f0100f73:	31 d0                	xor    %edx,%eax
f0100f75:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f77:	83 f8 06             	cmp    $0x6,%eax
f0100f7a:	7f 0b                	jg     f0100f87 <vprintfmt+0x142>
f0100f7c:	8b 14 85 f0 20 10 f0 	mov    -0xfefdf10(,%eax,4),%edx
f0100f83:	85 d2                	test   %edx,%edx
f0100f85:	75 18                	jne    f0100f9f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100f87:	50                   	push   %eax
f0100f88:	68 21 1f 10 f0       	push   $0xf0101f21
f0100f8d:	53                   	push   %ebx
f0100f8e:	56                   	push   %esi
f0100f8f:	e8 94 fe ff ff       	call   f0100e28 <printfmt>
f0100f94:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f9a:	e9 cc fe ff ff       	jmp    f0100e6b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100f9f:	52                   	push   %edx
f0100fa0:	68 2a 1f 10 f0       	push   $0xf0101f2a
f0100fa5:	53                   	push   %ebx
f0100fa6:	56                   	push   %esi
f0100fa7:	e8 7c fe ff ff       	call   f0100e28 <printfmt>
f0100fac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100faf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100fb2:	e9 b4 fe ff ff       	jmp    f0100e6b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100fb7:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fba:	8d 50 04             	lea    0x4(%eax),%edx
f0100fbd:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fc0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100fc2:	85 ff                	test   %edi,%edi
f0100fc4:	b8 1a 1f 10 f0       	mov    $0xf0101f1a,%eax
f0100fc9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100fcc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100fd0:	0f 8e 94 00 00 00    	jle    f010106a <vprintfmt+0x225>
f0100fd6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100fda:	0f 84 98 00 00 00    	je     f0101078 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fe0:	83 ec 08             	sub    $0x8,%esp
f0100fe3:	ff 75 d0             	pushl  -0x30(%ebp)
f0100fe6:	57                   	push   %edi
f0100fe7:	e8 5f 03 00 00       	call   f010134b <strnlen>
f0100fec:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fef:	29 c1                	sub    %eax,%ecx
f0100ff1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100ff4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100ff7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100ffb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ffe:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101001:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101003:	eb 0f                	jmp    f0101014 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0101005:	83 ec 08             	sub    $0x8,%esp
f0101008:	53                   	push   %ebx
f0101009:	ff 75 e0             	pushl  -0x20(%ebp)
f010100c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010100e:	83 ef 01             	sub    $0x1,%edi
f0101011:	83 c4 10             	add    $0x10,%esp
f0101014:	85 ff                	test   %edi,%edi
f0101016:	7f ed                	jg     f0101005 <vprintfmt+0x1c0>
f0101018:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010101b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010101e:	85 c9                	test   %ecx,%ecx
f0101020:	b8 00 00 00 00       	mov    $0x0,%eax
f0101025:	0f 49 c1             	cmovns %ecx,%eax
f0101028:	29 c1                	sub    %eax,%ecx
f010102a:	89 75 08             	mov    %esi,0x8(%ebp)
f010102d:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101030:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101033:	89 cb                	mov    %ecx,%ebx
f0101035:	eb 4d                	jmp    f0101084 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101037:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010103b:	74 1b                	je     f0101058 <vprintfmt+0x213>
f010103d:	0f be c0             	movsbl %al,%eax
f0101040:	83 e8 20             	sub    $0x20,%eax
f0101043:	83 f8 5e             	cmp    $0x5e,%eax
f0101046:	76 10                	jbe    f0101058 <vprintfmt+0x213>
					putch('?', putdat);
f0101048:	83 ec 08             	sub    $0x8,%esp
f010104b:	ff 75 0c             	pushl  0xc(%ebp)
f010104e:	6a 3f                	push   $0x3f
f0101050:	ff 55 08             	call   *0x8(%ebp)
f0101053:	83 c4 10             	add    $0x10,%esp
f0101056:	eb 0d                	jmp    f0101065 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0101058:	83 ec 08             	sub    $0x8,%esp
f010105b:	ff 75 0c             	pushl  0xc(%ebp)
f010105e:	52                   	push   %edx
f010105f:	ff 55 08             	call   *0x8(%ebp)
f0101062:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101065:	83 eb 01             	sub    $0x1,%ebx
f0101068:	eb 1a                	jmp    f0101084 <vprintfmt+0x23f>
f010106a:	89 75 08             	mov    %esi,0x8(%ebp)
f010106d:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101070:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101073:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101076:	eb 0c                	jmp    f0101084 <vprintfmt+0x23f>
f0101078:	89 75 08             	mov    %esi,0x8(%ebp)
f010107b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010107e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101081:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101084:	83 c7 01             	add    $0x1,%edi
f0101087:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010108b:	0f be d0             	movsbl %al,%edx
f010108e:	85 d2                	test   %edx,%edx
f0101090:	74 23                	je     f01010b5 <vprintfmt+0x270>
f0101092:	85 f6                	test   %esi,%esi
f0101094:	78 a1                	js     f0101037 <vprintfmt+0x1f2>
f0101096:	83 ee 01             	sub    $0x1,%esi
f0101099:	79 9c                	jns    f0101037 <vprintfmt+0x1f2>
f010109b:	89 df                	mov    %ebx,%edi
f010109d:	8b 75 08             	mov    0x8(%ebp),%esi
f01010a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010a3:	eb 18                	jmp    f01010bd <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01010a5:	83 ec 08             	sub    $0x8,%esp
f01010a8:	53                   	push   %ebx
f01010a9:	6a 20                	push   $0x20
f01010ab:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01010ad:	83 ef 01             	sub    $0x1,%edi
f01010b0:	83 c4 10             	add    $0x10,%esp
f01010b3:	eb 08                	jmp    f01010bd <vprintfmt+0x278>
f01010b5:	89 df                	mov    %ebx,%edi
f01010b7:	8b 75 08             	mov    0x8(%ebp),%esi
f01010ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010bd:	85 ff                	test   %edi,%edi
f01010bf:	7f e4                	jg     f01010a5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01010c4:	e9 a2 fd ff ff       	jmp    f0100e6b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01010c9:	83 fa 01             	cmp    $0x1,%edx
f01010cc:	7e 16                	jle    f01010e4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01010ce:	8b 45 14             	mov    0x14(%ebp),%eax
f01010d1:	8d 50 08             	lea    0x8(%eax),%edx
f01010d4:	89 55 14             	mov    %edx,0x14(%ebp)
f01010d7:	8b 50 04             	mov    0x4(%eax),%edx
f01010da:	8b 00                	mov    (%eax),%eax
f01010dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010df:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01010e2:	eb 32                	jmp    f0101116 <vprintfmt+0x2d1>
	else if (lflag)
f01010e4:	85 d2                	test   %edx,%edx
f01010e6:	74 18                	je     f0101100 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01010e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01010eb:	8d 50 04             	lea    0x4(%eax),%edx
f01010ee:	89 55 14             	mov    %edx,0x14(%ebp)
f01010f1:	8b 00                	mov    (%eax),%eax
f01010f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010f6:	89 c1                	mov    %eax,%ecx
f01010f8:	c1 f9 1f             	sar    $0x1f,%ecx
f01010fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01010fe:	eb 16                	jmp    f0101116 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0101100:	8b 45 14             	mov    0x14(%ebp),%eax
f0101103:	8d 50 04             	lea    0x4(%eax),%edx
f0101106:	89 55 14             	mov    %edx,0x14(%ebp)
f0101109:	8b 00                	mov    (%eax),%eax
f010110b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010110e:	89 c1                	mov    %eax,%ecx
f0101110:	c1 f9 1f             	sar    $0x1f,%ecx
f0101113:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101116:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101119:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010111c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101121:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101125:	79 74                	jns    f010119b <vprintfmt+0x356>
				putch('-', putdat);
f0101127:	83 ec 08             	sub    $0x8,%esp
f010112a:	53                   	push   %ebx
f010112b:	6a 2d                	push   $0x2d
f010112d:	ff d6                	call   *%esi
				num = -(long long) num;
f010112f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101132:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101135:	f7 d8                	neg    %eax
f0101137:	83 d2 00             	adc    $0x0,%edx
f010113a:	f7 da                	neg    %edx
f010113c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010113f:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101144:	eb 55                	jmp    f010119b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101146:	8d 45 14             	lea    0x14(%ebp),%eax
f0101149:	e8 83 fc ff ff       	call   f0100dd1 <getuint>
			base = 10;
f010114e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101153:	eb 46                	jmp    f010119b <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0101155:	8d 45 14             	lea    0x14(%ebp),%eax
f0101158:	e8 74 fc ff ff       	call   f0100dd1 <getuint>
			base = 8;
f010115d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0101162:	eb 37                	jmp    f010119b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0101164:	83 ec 08             	sub    $0x8,%esp
f0101167:	53                   	push   %ebx
f0101168:	6a 30                	push   $0x30
f010116a:	ff d6                	call   *%esi
			putch('x', putdat);
f010116c:	83 c4 08             	add    $0x8,%esp
f010116f:	53                   	push   %ebx
f0101170:	6a 78                	push   $0x78
f0101172:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101174:	8b 45 14             	mov    0x14(%ebp),%eax
f0101177:	8d 50 04             	lea    0x4(%eax),%edx
f010117a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010117d:	8b 00                	mov    (%eax),%eax
f010117f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101184:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101187:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010118c:	eb 0d                	jmp    f010119b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010118e:	8d 45 14             	lea    0x14(%ebp),%eax
f0101191:	e8 3b fc ff ff       	call   f0100dd1 <getuint>
			base = 16;
f0101196:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010119b:	83 ec 0c             	sub    $0xc,%esp
f010119e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01011a2:	57                   	push   %edi
f01011a3:	ff 75 e0             	pushl  -0x20(%ebp)
f01011a6:	51                   	push   %ecx
f01011a7:	52                   	push   %edx
f01011a8:	50                   	push   %eax
f01011a9:	89 da                	mov    %ebx,%edx
f01011ab:	89 f0                	mov    %esi,%eax
f01011ad:	e8 70 fb ff ff       	call   f0100d22 <printnum>
			break;
f01011b2:	83 c4 20             	add    $0x20,%esp
f01011b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01011b8:	e9 ae fc ff ff       	jmp    f0100e6b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01011bd:	83 ec 08             	sub    $0x8,%esp
f01011c0:	53                   	push   %ebx
f01011c1:	51                   	push   %ecx
f01011c2:	ff d6                	call   *%esi
			break;
f01011c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01011ca:	e9 9c fc ff ff       	jmp    f0100e6b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01011cf:	83 ec 08             	sub    $0x8,%esp
f01011d2:	53                   	push   %ebx
f01011d3:	6a 25                	push   $0x25
f01011d5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01011d7:	83 c4 10             	add    $0x10,%esp
f01011da:	eb 03                	jmp    f01011df <vprintfmt+0x39a>
f01011dc:	83 ef 01             	sub    $0x1,%edi
f01011df:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01011e3:	75 f7                	jne    f01011dc <vprintfmt+0x397>
f01011e5:	e9 81 fc ff ff       	jmp    f0100e6b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01011ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011ed:	5b                   	pop    %ebx
f01011ee:	5e                   	pop    %esi
f01011ef:	5f                   	pop    %edi
f01011f0:	5d                   	pop    %ebp
f01011f1:	c3                   	ret    

f01011f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01011f2:	55                   	push   %ebp
f01011f3:	89 e5                	mov    %esp,%ebp
f01011f5:	83 ec 18             	sub    $0x18,%esp
f01011f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01011fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01011fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101201:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101205:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101208:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010120f:	85 c0                	test   %eax,%eax
f0101211:	74 26                	je     f0101239 <vsnprintf+0x47>
f0101213:	85 d2                	test   %edx,%edx
f0101215:	7e 22                	jle    f0101239 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101217:	ff 75 14             	pushl  0x14(%ebp)
f010121a:	ff 75 10             	pushl  0x10(%ebp)
f010121d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101220:	50                   	push   %eax
f0101221:	68 0b 0e 10 f0       	push   $0xf0100e0b
f0101226:	e8 1a fc ff ff       	call   f0100e45 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010122b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010122e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101231:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101234:	83 c4 10             	add    $0x10,%esp
f0101237:	eb 05                	jmp    f010123e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101239:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010123e:	c9                   	leave  
f010123f:	c3                   	ret    

f0101240 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101240:	55                   	push   %ebp
f0101241:	89 e5                	mov    %esp,%ebp
f0101243:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101246:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101249:	50                   	push   %eax
f010124a:	ff 75 10             	pushl  0x10(%ebp)
f010124d:	ff 75 0c             	pushl  0xc(%ebp)
f0101250:	ff 75 08             	pushl  0x8(%ebp)
f0101253:	e8 9a ff ff ff       	call   f01011f2 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101258:	c9                   	leave  
f0101259:	c3                   	ret    

f010125a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010125a:	55                   	push   %ebp
f010125b:	89 e5                	mov    %esp,%ebp
f010125d:	57                   	push   %edi
f010125e:	56                   	push   %esi
f010125f:	53                   	push   %ebx
f0101260:	83 ec 0c             	sub    $0xc,%esp
f0101263:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101266:	85 c0                	test   %eax,%eax
f0101268:	74 11                	je     f010127b <readline+0x21>
		cprintf("%s", prompt);
f010126a:	83 ec 08             	sub    $0x8,%esp
f010126d:	50                   	push   %eax
f010126e:	68 2a 1f 10 f0       	push   $0xf0101f2a
f0101273:	e8 75 f7 ff ff       	call   f01009ed <cprintf>
f0101278:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010127b:	83 ec 0c             	sub    $0xc,%esp
f010127e:	6a 00                	push   $0x0
f0101280:	e8 f7 f3 ff ff       	call   f010067c <iscons>
f0101285:	89 c7                	mov    %eax,%edi
f0101287:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010128a:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010128f:	e8 d7 f3 ff ff       	call   f010066b <getchar>
f0101294:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101296:	85 c0                	test   %eax,%eax
f0101298:	79 18                	jns    f01012b2 <readline+0x58>
			cprintf("read error: %e\n", c);
f010129a:	83 ec 08             	sub    $0x8,%esp
f010129d:	50                   	push   %eax
f010129e:	68 0c 21 10 f0       	push   $0xf010210c
f01012a3:	e8 45 f7 ff ff       	call   f01009ed <cprintf>
			return NULL;
f01012a8:	83 c4 10             	add    $0x10,%esp
f01012ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b0:	eb 79                	jmp    f010132b <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01012b2:	83 f8 08             	cmp    $0x8,%eax
f01012b5:	0f 94 c2             	sete   %dl
f01012b8:	83 f8 7f             	cmp    $0x7f,%eax
f01012bb:	0f 94 c0             	sete   %al
f01012be:	08 c2                	or     %al,%dl
f01012c0:	74 1a                	je     f01012dc <readline+0x82>
f01012c2:	85 f6                	test   %esi,%esi
f01012c4:	7e 16                	jle    f01012dc <readline+0x82>
			if (echoing)
f01012c6:	85 ff                	test   %edi,%edi
f01012c8:	74 0d                	je     f01012d7 <readline+0x7d>
				cputchar('\b');
f01012ca:	83 ec 0c             	sub    $0xc,%esp
f01012cd:	6a 08                	push   $0x8
f01012cf:	e8 87 f3 ff ff       	call   f010065b <cputchar>
f01012d4:	83 c4 10             	add    $0x10,%esp
			i--;
f01012d7:	83 ee 01             	sub    $0x1,%esi
f01012da:	eb b3                	jmp    f010128f <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01012dc:	83 fb 1f             	cmp    $0x1f,%ebx
f01012df:	7e 23                	jle    f0101304 <readline+0xaa>
f01012e1:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01012e7:	7f 1b                	jg     f0101304 <readline+0xaa>
			if (echoing)
f01012e9:	85 ff                	test   %edi,%edi
f01012eb:	74 0c                	je     f01012f9 <readline+0x9f>
				cputchar(c);
f01012ed:	83 ec 0c             	sub    $0xc,%esp
f01012f0:	53                   	push   %ebx
f01012f1:	e8 65 f3 ff ff       	call   f010065b <cputchar>
f01012f6:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01012f9:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f01012ff:	8d 76 01             	lea    0x1(%esi),%esi
f0101302:	eb 8b                	jmp    f010128f <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101304:	83 fb 0a             	cmp    $0xa,%ebx
f0101307:	74 05                	je     f010130e <readline+0xb4>
f0101309:	83 fb 0d             	cmp    $0xd,%ebx
f010130c:	75 81                	jne    f010128f <readline+0x35>
			if (echoing)
f010130e:	85 ff                	test   %edi,%edi
f0101310:	74 0d                	je     f010131f <readline+0xc5>
				cputchar('\n');
f0101312:	83 ec 0c             	sub    $0xc,%esp
f0101315:	6a 0a                	push   $0xa
f0101317:	e8 3f f3 ff ff       	call   f010065b <cputchar>
f010131c:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010131f:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f0101326:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f010132b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010132e:	5b                   	pop    %ebx
f010132f:	5e                   	pop    %esi
f0101330:	5f                   	pop    %edi
f0101331:	5d                   	pop    %ebp
f0101332:	c3                   	ret    

f0101333 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101333:	55                   	push   %ebp
f0101334:	89 e5                	mov    %esp,%ebp
f0101336:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101339:	b8 00 00 00 00       	mov    $0x0,%eax
f010133e:	eb 03                	jmp    f0101343 <strlen+0x10>
		n++;
f0101340:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101343:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101347:	75 f7                	jne    f0101340 <strlen+0xd>
		n++;
	return n;
}
f0101349:	5d                   	pop    %ebp
f010134a:	c3                   	ret    

f010134b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010134b:	55                   	push   %ebp
f010134c:	89 e5                	mov    %esp,%ebp
f010134e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101351:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101354:	ba 00 00 00 00       	mov    $0x0,%edx
f0101359:	eb 03                	jmp    f010135e <strnlen+0x13>
		n++;
f010135b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010135e:	39 c2                	cmp    %eax,%edx
f0101360:	74 08                	je     f010136a <strnlen+0x1f>
f0101362:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101366:	75 f3                	jne    f010135b <strnlen+0x10>
f0101368:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010136a:	5d                   	pop    %ebp
f010136b:	c3                   	ret    

f010136c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010136c:	55                   	push   %ebp
f010136d:	89 e5                	mov    %esp,%ebp
f010136f:	53                   	push   %ebx
f0101370:	8b 45 08             	mov    0x8(%ebp),%eax
f0101373:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101376:	89 c2                	mov    %eax,%edx
f0101378:	83 c2 01             	add    $0x1,%edx
f010137b:	83 c1 01             	add    $0x1,%ecx
f010137e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101382:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101385:	84 db                	test   %bl,%bl
f0101387:	75 ef                	jne    f0101378 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101389:	5b                   	pop    %ebx
f010138a:	5d                   	pop    %ebp
f010138b:	c3                   	ret    

f010138c <strcat>:

char *
strcat(char *dst, const char *src)
{
f010138c:	55                   	push   %ebp
f010138d:	89 e5                	mov    %esp,%ebp
f010138f:	53                   	push   %ebx
f0101390:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101393:	53                   	push   %ebx
f0101394:	e8 9a ff ff ff       	call   f0101333 <strlen>
f0101399:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010139c:	ff 75 0c             	pushl  0xc(%ebp)
f010139f:	01 d8                	add    %ebx,%eax
f01013a1:	50                   	push   %eax
f01013a2:	e8 c5 ff ff ff       	call   f010136c <strcpy>
	return dst;
}
f01013a7:	89 d8                	mov    %ebx,%eax
f01013a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013ac:	c9                   	leave  
f01013ad:	c3                   	ret    

f01013ae <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01013ae:	55                   	push   %ebp
f01013af:	89 e5                	mov    %esp,%ebp
f01013b1:	56                   	push   %esi
f01013b2:	53                   	push   %ebx
f01013b3:	8b 75 08             	mov    0x8(%ebp),%esi
f01013b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013b9:	89 f3                	mov    %esi,%ebx
f01013bb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013be:	89 f2                	mov    %esi,%edx
f01013c0:	eb 0f                	jmp    f01013d1 <strncpy+0x23>
		*dst++ = *src;
f01013c2:	83 c2 01             	add    $0x1,%edx
f01013c5:	0f b6 01             	movzbl (%ecx),%eax
f01013c8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01013cb:	80 39 01             	cmpb   $0x1,(%ecx)
f01013ce:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013d1:	39 da                	cmp    %ebx,%edx
f01013d3:	75 ed                	jne    f01013c2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01013d5:	89 f0                	mov    %esi,%eax
f01013d7:	5b                   	pop    %ebx
f01013d8:	5e                   	pop    %esi
f01013d9:	5d                   	pop    %ebp
f01013da:	c3                   	ret    

f01013db <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01013db:	55                   	push   %ebp
f01013dc:	89 e5                	mov    %esp,%ebp
f01013de:	56                   	push   %esi
f01013df:	53                   	push   %ebx
f01013e0:	8b 75 08             	mov    0x8(%ebp),%esi
f01013e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013e6:	8b 55 10             	mov    0x10(%ebp),%edx
f01013e9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01013eb:	85 d2                	test   %edx,%edx
f01013ed:	74 21                	je     f0101410 <strlcpy+0x35>
f01013ef:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01013f3:	89 f2                	mov    %esi,%edx
f01013f5:	eb 09                	jmp    f0101400 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01013f7:	83 c2 01             	add    $0x1,%edx
f01013fa:	83 c1 01             	add    $0x1,%ecx
f01013fd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101400:	39 c2                	cmp    %eax,%edx
f0101402:	74 09                	je     f010140d <strlcpy+0x32>
f0101404:	0f b6 19             	movzbl (%ecx),%ebx
f0101407:	84 db                	test   %bl,%bl
f0101409:	75 ec                	jne    f01013f7 <strlcpy+0x1c>
f010140b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010140d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101410:	29 f0                	sub    %esi,%eax
}
f0101412:	5b                   	pop    %ebx
f0101413:	5e                   	pop    %esi
f0101414:	5d                   	pop    %ebp
f0101415:	c3                   	ret    

f0101416 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101416:	55                   	push   %ebp
f0101417:	89 e5                	mov    %esp,%ebp
f0101419:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010141c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010141f:	eb 06                	jmp    f0101427 <strcmp+0x11>
		p++, q++;
f0101421:	83 c1 01             	add    $0x1,%ecx
f0101424:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101427:	0f b6 01             	movzbl (%ecx),%eax
f010142a:	84 c0                	test   %al,%al
f010142c:	74 04                	je     f0101432 <strcmp+0x1c>
f010142e:	3a 02                	cmp    (%edx),%al
f0101430:	74 ef                	je     f0101421 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101432:	0f b6 c0             	movzbl %al,%eax
f0101435:	0f b6 12             	movzbl (%edx),%edx
f0101438:	29 d0                	sub    %edx,%eax
}
f010143a:	5d                   	pop    %ebp
f010143b:	c3                   	ret    

f010143c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010143c:	55                   	push   %ebp
f010143d:	89 e5                	mov    %esp,%ebp
f010143f:	53                   	push   %ebx
f0101440:	8b 45 08             	mov    0x8(%ebp),%eax
f0101443:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101446:	89 c3                	mov    %eax,%ebx
f0101448:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010144b:	eb 06                	jmp    f0101453 <strncmp+0x17>
		n--, p++, q++;
f010144d:	83 c0 01             	add    $0x1,%eax
f0101450:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101453:	39 d8                	cmp    %ebx,%eax
f0101455:	74 15                	je     f010146c <strncmp+0x30>
f0101457:	0f b6 08             	movzbl (%eax),%ecx
f010145a:	84 c9                	test   %cl,%cl
f010145c:	74 04                	je     f0101462 <strncmp+0x26>
f010145e:	3a 0a                	cmp    (%edx),%cl
f0101460:	74 eb                	je     f010144d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101462:	0f b6 00             	movzbl (%eax),%eax
f0101465:	0f b6 12             	movzbl (%edx),%edx
f0101468:	29 d0                	sub    %edx,%eax
f010146a:	eb 05                	jmp    f0101471 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010146c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101471:	5b                   	pop    %ebx
f0101472:	5d                   	pop    %ebp
f0101473:	c3                   	ret    

f0101474 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101474:	55                   	push   %ebp
f0101475:	89 e5                	mov    %esp,%ebp
f0101477:	8b 45 08             	mov    0x8(%ebp),%eax
f010147a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010147e:	eb 07                	jmp    f0101487 <strchr+0x13>
		if (*s == c)
f0101480:	38 ca                	cmp    %cl,%dl
f0101482:	74 0f                	je     f0101493 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101484:	83 c0 01             	add    $0x1,%eax
f0101487:	0f b6 10             	movzbl (%eax),%edx
f010148a:	84 d2                	test   %dl,%dl
f010148c:	75 f2                	jne    f0101480 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010148e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101493:	5d                   	pop    %ebp
f0101494:	c3                   	ret    

f0101495 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101495:	55                   	push   %ebp
f0101496:	89 e5                	mov    %esp,%ebp
f0101498:	8b 45 08             	mov    0x8(%ebp),%eax
f010149b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010149f:	eb 03                	jmp    f01014a4 <strfind+0xf>
f01014a1:	83 c0 01             	add    $0x1,%eax
f01014a4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01014a7:	38 ca                	cmp    %cl,%dl
f01014a9:	74 04                	je     f01014af <strfind+0x1a>
f01014ab:	84 d2                	test   %dl,%dl
f01014ad:	75 f2                	jne    f01014a1 <strfind+0xc>
			break;
	return (char *) s;
}
f01014af:	5d                   	pop    %ebp
f01014b0:	c3                   	ret    

f01014b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01014b1:	55                   	push   %ebp
f01014b2:	89 e5                	mov    %esp,%ebp
f01014b4:	57                   	push   %edi
f01014b5:	56                   	push   %esi
f01014b6:	53                   	push   %ebx
f01014b7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01014bd:	85 c9                	test   %ecx,%ecx
f01014bf:	74 36                	je     f01014f7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01014c1:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01014c7:	75 28                	jne    f01014f1 <memset+0x40>
f01014c9:	f6 c1 03             	test   $0x3,%cl
f01014cc:	75 23                	jne    f01014f1 <memset+0x40>
		c &= 0xFF;
f01014ce:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01014d2:	89 d3                	mov    %edx,%ebx
f01014d4:	c1 e3 08             	shl    $0x8,%ebx
f01014d7:	89 d6                	mov    %edx,%esi
f01014d9:	c1 e6 18             	shl    $0x18,%esi
f01014dc:	89 d0                	mov    %edx,%eax
f01014de:	c1 e0 10             	shl    $0x10,%eax
f01014e1:	09 f0                	or     %esi,%eax
f01014e3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01014e5:	89 d8                	mov    %ebx,%eax
f01014e7:	09 d0                	or     %edx,%eax
f01014e9:	c1 e9 02             	shr    $0x2,%ecx
f01014ec:	fc                   	cld    
f01014ed:	f3 ab                	rep stos %eax,%es:(%edi)
f01014ef:	eb 06                	jmp    f01014f7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01014f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014f4:	fc                   	cld    
f01014f5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01014f7:	89 f8                	mov    %edi,%eax
f01014f9:	5b                   	pop    %ebx
f01014fa:	5e                   	pop    %esi
f01014fb:	5f                   	pop    %edi
f01014fc:	5d                   	pop    %ebp
f01014fd:	c3                   	ret    

f01014fe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01014fe:	55                   	push   %ebp
f01014ff:	89 e5                	mov    %esp,%ebp
f0101501:	57                   	push   %edi
f0101502:	56                   	push   %esi
f0101503:	8b 45 08             	mov    0x8(%ebp),%eax
f0101506:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101509:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010150c:	39 c6                	cmp    %eax,%esi
f010150e:	73 35                	jae    f0101545 <memmove+0x47>
f0101510:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101513:	39 d0                	cmp    %edx,%eax
f0101515:	73 2e                	jae    f0101545 <memmove+0x47>
		s += n;
		d += n;
f0101517:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010151a:	89 d6                	mov    %edx,%esi
f010151c:	09 fe                	or     %edi,%esi
f010151e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101524:	75 13                	jne    f0101539 <memmove+0x3b>
f0101526:	f6 c1 03             	test   $0x3,%cl
f0101529:	75 0e                	jne    f0101539 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f010152b:	83 ef 04             	sub    $0x4,%edi
f010152e:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101531:	c1 e9 02             	shr    $0x2,%ecx
f0101534:	fd                   	std    
f0101535:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101537:	eb 09                	jmp    f0101542 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101539:	83 ef 01             	sub    $0x1,%edi
f010153c:	8d 72 ff             	lea    -0x1(%edx),%esi
f010153f:	fd                   	std    
f0101540:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101542:	fc                   	cld    
f0101543:	eb 1d                	jmp    f0101562 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101545:	89 f2                	mov    %esi,%edx
f0101547:	09 c2                	or     %eax,%edx
f0101549:	f6 c2 03             	test   $0x3,%dl
f010154c:	75 0f                	jne    f010155d <memmove+0x5f>
f010154e:	f6 c1 03             	test   $0x3,%cl
f0101551:	75 0a                	jne    f010155d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0101553:	c1 e9 02             	shr    $0x2,%ecx
f0101556:	89 c7                	mov    %eax,%edi
f0101558:	fc                   	cld    
f0101559:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010155b:	eb 05                	jmp    f0101562 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010155d:	89 c7                	mov    %eax,%edi
f010155f:	fc                   	cld    
f0101560:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101562:	5e                   	pop    %esi
f0101563:	5f                   	pop    %edi
f0101564:	5d                   	pop    %ebp
f0101565:	c3                   	ret    

f0101566 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101566:	55                   	push   %ebp
f0101567:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101569:	ff 75 10             	pushl  0x10(%ebp)
f010156c:	ff 75 0c             	pushl  0xc(%ebp)
f010156f:	ff 75 08             	pushl  0x8(%ebp)
f0101572:	e8 87 ff ff ff       	call   f01014fe <memmove>
}
f0101577:	c9                   	leave  
f0101578:	c3                   	ret    

f0101579 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101579:	55                   	push   %ebp
f010157a:	89 e5                	mov    %esp,%ebp
f010157c:	56                   	push   %esi
f010157d:	53                   	push   %ebx
f010157e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101581:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101584:	89 c6                	mov    %eax,%esi
f0101586:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101589:	eb 1a                	jmp    f01015a5 <memcmp+0x2c>
		if (*s1 != *s2)
f010158b:	0f b6 08             	movzbl (%eax),%ecx
f010158e:	0f b6 1a             	movzbl (%edx),%ebx
f0101591:	38 d9                	cmp    %bl,%cl
f0101593:	74 0a                	je     f010159f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0101595:	0f b6 c1             	movzbl %cl,%eax
f0101598:	0f b6 db             	movzbl %bl,%ebx
f010159b:	29 d8                	sub    %ebx,%eax
f010159d:	eb 0f                	jmp    f01015ae <memcmp+0x35>
		s1++, s2++;
f010159f:	83 c0 01             	add    $0x1,%eax
f01015a2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015a5:	39 f0                	cmp    %esi,%eax
f01015a7:	75 e2                	jne    f010158b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01015a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015ae:	5b                   	pop    %ebx
f01015af:	5e                   	pop    %esi
f01015b0:	5d                   	pop    %ebp
f01015b1:	c3                   	ret    

f01015b2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01015b2:	55                   	push   %ebp
f01015b3:	89 e5                	mov    %esp,%ebp
f01015b5:	53                   	push   %ebx
f01015b6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01015b9:	89 c1                	mov    %eax,%ecx
f01015bb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01015be:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01015c2:	eb 0a                	jmp    f01015ce <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01015c4:	0f b6 10             	movzbl (%eax),%edx
f01015c7:	39 da                	cmp    %ebx,%edx
f01015c9:	74 07                	je     f01015d2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01015cb:	83 c0 01             	add    $0x1,%eax
f01015ce:	39 c8                	cmp    %ecx,%eax
f01015d0:	72 f2                	jb     f01015c4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01015d2:	5b                   	pop    %ebx
f01015d3:	5d                   	pop    %ebp
f01015d4:	c3                   	ret    

f01015d5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01015d5:	55                   	push   %ebp
f01015d6:	89 e5                	mov    %esp,%ebp
f01015d8:	57                   	push   %edi
f01015d9:	56                   	push   %esi
f01015da:	53                   	push   %ebx
f01015db:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015e1:	eb 03                	jmp    f01015e6 <strtol+0x11>
		s++;
f01015e3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015e6:	0f b6 01             	movzbl (%ecx),%eax
f01015e9:	3c 20                	cmp    $0x20,%al
f01015eb:	74 f6                	je     f01015e3 <strtol+0xe>
f01015ed:	3c 09                	cmp    $0x9,%al
f01015ef:	74 f2                	je     f01015e3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01015f1:	3c 2b                	cmp    $0x2b,%al
f01015f3:	75 0a                	jne    f01015ff <strtol+0x2a>
		s++;
f01015f5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01015f8:	bf 00 00 00 00       	mov    $0x0,%edi
f01015fd:	eb 11                	jmp    f0101610 <strtol+0x3b>
f01015ff:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101604:	3c 2d                	cmp    $0x2d,%al
f0101606:	75 08                	jne    f0101610 <strtol+0x3b>
		s++, neg = 1;
f0101608:	83 c1 01             	add    $0x1,%ecx
f010160b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101610:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101616:	75 15                	jne    f010162d <strtol+0x58>
f0101618:	80 39 30             	cmpb   $0x30,(%ecx)
f010161b:	75 10                	jne    f010162d <strtol+0x58>
f010161d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101621:	75 7c                	jne    f010169f <strtol+0xca>
		s += 2, base = 16;
f0101623:	83 c1 02             	add    $0x2,%ecx
f0101626:	bb 10 00 00 00       	mov    $0x10,%ebx
f010162b:	eb 16                	jmp    f0101643 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010162d:	85 db                	test   %ebx,%ebx
f010162f:	75 12                	jne    f0101643 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101631:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101636:	80 39 30             	cmpb   $0x30,(%ecx)
f0101639:	75 08                	jne    f0101643 <strtol+0x6e>
		s++, base = 8;
f010163b:	83 c1 01             	add    $0x1,%ecx
f010163e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0101643:	b8 00 00 00 00       	mov    $0x0,%eax
f0101648:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010164b:	0f b6 11             	movzbl (%ecx),%edx
f010164e:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101651:	89 f3                	mov    %esi,%ebx
f0101653:	80 fb 09             	cmp    $0x9,%bl
f0101656:	77 08                	ja     f0101660 <strtol+0x8b>
			dig = *s - '0';
f0101658:	0f be d2             	movsbl %dl,%edx
f010165b:	83 ea 30             	sub    $0x30,%edx
f010165e:	eb 22                	jmp    f0101682 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0101660:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101663:	89 f3                	mov    %esi,%ebx
f0101665:	80 fb 19             	cmp    $0x19,%bl
f0101668:	77 08                	ja     f0101672 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010166a:	0f be d2             	movsbl %dl,%edx
f010166d:	83 ea 57             	sub    $0x57,%edx
f0101670:	eb 10                	jmp    f0101682 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0101672:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101675:	89 f3                	mov    %esi,%ebx
f0101677:	80 fb 19             	cmp    $0x19,%bl
f010167a:	77 16                	ja     f0101692 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010167c:	0f be d2             	movsbl %dl,%edx
f010167f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101682:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101685:	7d 0b                	jge    f0101692 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0101687:	83 c1 01             	add    $0x1,%ecx
f010168a:	0f af 45 10          	imul   0x10(%ebp),%eax
f010168e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101690:	eb b9                	jmp    f010164b <strtol+0x76>

	if (endptr)
f0101692:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101696:	74 0d                	je     f01016a5 <strtol+0xd0>
		*endptr = (char *) s;
f0101698:	8b 75 0c             	mov    0xc(%ebp),%esi
f010169b:	89 0e                	mov    %ecx,(%esi)
f010169d:	eb 06                	jmp    f01016a5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010169f:	85 db                	test   %ebx,%ebx
f01016a1:	74 98                	je     f010163b <strtol+0x66>
f01016a3:	eb 9e                	jmp    f0101643 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01016a5:	89 c2                	mov    %eax,%edx
f01016a7:	f7 da                	neg    %edx
f01016a9:	85 ff                	test   %edi,%edi
f01016ab:	0f 45 c2             	cmovne %edx,%eax
}
f01016ae:	5b                   	pop    %ebx
f01016af:	5e                   	pop    %esi
f01016b0:	5f                   	pop    %edi
f01016b1:	5d                   	pop    %ebp
f01016b2:	c3                   	ret    
f01016b3:	66 90                	xchg   %ax,%ax
f01016b5:	66 90                	xchg   %ax,%ax
f01016b7:	66 90                	xchg   %ax,%ax
f01016b9:	66 90                	xchg   %ax,%ax
f01016bb:	66 90                	xchg   %ax,%ax
f01016bd:	66 90                	xchg   %ax,%ax
f01016bf:	90                   	nop

f01016c0 <__udivdi3>:
f01016c0:	55                   	push   %ebp
f01016c1:	57                   	push   %edi
f01016c2:	56                   	push   %esi
f01016c3:	53                   	push   %ebx
f01016c4:	83 ec 1c             	sub    $0x1c,%esp
f01016c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01016cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01016cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01016d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01016d7:	85 f6                	test   %esi,%esi
f01016d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01016dd:	89 ca                	mov    %ecx,%edx
f01016df:	89 f8                	mov    %edi,%eax
f01016e1:	75 3d                	jne    f0101720 <__udivdi3+0x60>
f01016e3:	39 cf                	cmp    %ecx,%edi
f01016e5:	0f 87 c5 00 00 00    	ja     f01017b0 <__udivdi3+0xf0>
f01016eb:	85 ff                	test   %edi,%edi
f01016ed:	89 fd                	mov    %edi,%ebp
f01016ef:	75 0b                	jne    f01016fc <__udivdi3+0x3c>
f01016f1:	b8 01 00 00 00       	mov    $0x1,%eax
f01016f6:	31 d2                	xor    %edx,%edx
f01016f8:	f7 f7                	div    %edi
f01016fa:	89 c5                	mov    %eax,%ebp
f01016fc:	89 c8                	mov    %ecx,%eax
f01016fe:	31 d2                	xor    %edx,%edx
f0101700:	f7 f5                	div    %ebp
f0101702:	89 c1                	mov    %eax,%ecx
f0101704:	89 d8                	mov    %ebx,%eax
f0101706:	89 cf                	mov    %ecx,%edi
f0101708:	f7 f5                	div    %ebp
f010170a:	89 c3                	mov    %eax,%ebx
f010170c:	89 d8                	mov    %ebx,%eax
f010170e:	89 fa                	mov    %edi,%edx
f0101710:	83 c4 1c             	add    $0x1c,%esp
f0101713:	5b                   	pop    %ebx
f0101714:	5e                   	pop    %esi
f0101715:	5f                   	pop    %edi
f0101716:	5d                   	pop    %ebp
f0101717:	c3                   	ret    
f0101718:	90                   	nop
f0101719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101720:	39 ce                	cmp    %ecx,%esi
f0101722:	77 74                	ja     f0101798 <__udivdi3+0xd8>
f0101724:	0f bd fe             	bsr    %esi,%edi
f0101727:	83 f7 1f             	xor    $0x1f,%edi
f010172a:	0f 84 98 00 00 00    	je     f01017c8 <__udivdi3+0x108>
f0101730:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101735:	89 f9                	mov    %edi,%ecx
f0101737:	89 c5                	mov    %eax,%ebp
f0101739:	29 fb                	sub    %edi,%ebx
f010173b:	d3 e6                	shl    %cl,%esi
f010173d:	89 d9                	mov    %ebx,%ecx
f010173f:	d3 ed                	shr    %cl,%ebp
f0101741:	89 f9                	mov    %edi,%ecx
f0101743:	d3 e0                	shl    %cl,%eax
f0101745:	09 ee                	or     %ebp,%esi
f0101747:	89 d9                	mov    %ebx,%ecx
f0101749:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010174d:	89 d5                	mov    %edx,%ebp
f010174f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101753:	d3 ed                	shr    %cl,%ebp
f0101755:	89 f9                	mov    %edi,%ecx
f0101757:	d3 e2                	shl    %cl,%edx
f0101759:	89 d9                	mov    %ebx,%ecx
f010175b:	d3 e8                	shr    %cl,%eax
f010175d:	09 c2                	or     %eax,%edx
f010175f:	89 d0                	mov    %edx,%eax
f0101761:	89 ea                	mov    %ebp,%edx
f0101763:	f7 f6                	div    %esi
f0101765:	89 d5                	mov    %edx,%ebp
f0101767:	89 c3                	mov    %eax,%ebx
f0101769:	f7 64 24 0c          	mull   0xc(%esp)
f010176d:	39 d5                	cmp    %edx,%ebp
f010176f:	72 10                	jb     f0101781 <__udivdi3+0xc1>
f0101771:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101775:	89 f9                	mov    %edi,%ecx
f0101777:	d3 e6                	shl    %cl,%esi
f0101779:	39 c6                	cmp    %eax,%esi
f010177b:	73 07                	jae    f0101784 <__udivdi3+0xc4>
f010177d:	39 d5                	cmp    %edx,%ebp
f010177f:	75 03                	jne    f0101784 <__udivdi3+0xc4>
f0101781:	83 eb 01             	sub    $0x1,%ebx
f0101784:	31 ff                	xor    %edi,%edi
f0101786:	89 d8                	mov    %ebx,%eax
f0101788:	89 fa                	mov    %edi,%edx
f010178a:	83 c4 1c             	add    $0x1c,%esp
f010178d:	5b                   	pop    %ebx
f010178e:	5e                   	pop    %esi
f010178f:	5f                   	pop    %edi
f0101790:	5d                   	pop    %ebp
f0101791:	c3                   	ret    
f0101792:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101798:	31 ff                	xor    %edi,%edi
f010179a:	31 db                	xor    %ebx,%ebx
f010179c:	89 d8                	mov    %ebx,%eax
f010179e:	89 fa                	mov    %edi,%edx
f01017a0:	83 c4 1c             	add    $0x1c,%esp
f01017a3:	5b                   	pop    %ebx
f01017a4:	5e                   	pop    %esi
f01017a5:	5f                   	pop    %edi
f01017a6:	5d                   	pop    %ebp
f01017a7:	c3                   	ret    
f01017a8:	90                   	nop
f01017a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017b0:	89 d8                	mov    %ebx,%eax
f01017b2:	f7 f7                	div    %edi
f01017b4:	31 ff                	xor    %edi,%edi
f01017b6:	89 c3                	mov    %eax,%ebx
f01017b8:	89 d8                	mov    %ebx,%eax
f01017ba:	89 fa                	mov    %edi,%edx
f01017bc:	83 c4 1c             	add    $0x1c,%esp
f01017bf:	5b                   	pop    %ebx
f01017c0:	5e                   	pop    %esi
f01017c1:	5f                   	pop    %edi
f01017c2:	5d                   	pop    %ebp
f01017c3:	c3                   	ret    
f01017c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017c8:	39 ce                	cmp    %ecx,%esi
f01017ca:	72 0c                	jb     f01017d8 <__udivdi3+0x118>
f01017cc:	31 db                	xor    %ebx,%ebx
f01017ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01017d2:	0f 87 34 ff ff ff    	ja     f010170c <__udivdi3+0x4c>
f01017d8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01017dd:	e9 2a ff ff ff       	jmp    f010170c <__udivdi3+0x4c>
f01017e2:	66 90                	xchg   %ax,%ax
f01017e4:	66 90                	xchg   %ax,%ax
f01017e6:	66 90                	xchg   %ax,%ax
f01017e8:	66 90                	xchg   %ax,%ax
f01017ea:	66 90                	xchg   %ax,%ax
f01017ec:	66 90                	xchg   %ax,%ax
f01017ee:	66 90                	xchg   %ax,%ax

f01017f0 <__umoddi3>:
f01017f0:	55                   	push   %ebp
f01017f1:	57                   	push   %edi
f01017f2:	56                   	push   %esi
f01017f3:	53                   	push   %ebx
f01017f4:	83 ec 1c             	sub    $0x1c,%esp
f01017f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01017fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01017ff:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101803:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101807:	85 d2                	test   %edx,%edx
f0101809:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010180d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101811:	89 f3                	mov    %esi,%ebx
f0101813:	89 3c 24             	mov    %edi,(%esp)
f0101816:	89 74 24 04          	mov    %esi,0x4(%esp)
f010181a:	75 1c                	jne    f0101838 <__umoddi3+0x48>
f010181c:	39 f7                	cmp    %esi,%edi
f010181e:	76 50                	jbe    f0101870 <__umoddi3+0x80>
f0101820:	89 c8                	mov    %ecx,%eax
f0101822:	89 f2                	mov    %esi,%edx
f0101824:	f7 f7                	div    %edi
f0101826:	89 d0                	mov    %edx,%eax
f0101828:	31 d2                	xor    %edx,%edx
f010182a:	83 c4 1c             	add    $0x1c,%esp
f010182d:	5b                   	pop    %ebx
f010182e:	5e                   	pop    %esi
f010182f:	5f                   	pop    %edi
f0101830:	5d                   	pop    %ebp
f0101831:	c3                   	ret    
f0101832:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101838:	39 f2                	cmp    %esi,%edx
f010183a:	89 d0                	mov    %edx,%eax
f010183c:	77 52                	ja     f0101890 <__umoddi3+0xa0>
f010183e:	0f bd ea             	bsr    %edx,%ebp
f0101841:	83 f5 1f             	xor    $0x1f,%ebp
f0101844:	75 5a                	jne    f01018a0 <__umoddi3+0xb0>
f0101846:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010184a:	0f 82 e0 00 00 00    	jb     f0101930 <__umoddi3+0x140>
f0101850:	39 0c 24             	cmp    %ecx,(%esp)
f0101853:	0f 86 d7 00 00 00    	jbe    f0101930 <__umoddi3+0x140>
f0101859:	8b 44 24 08          	mov    0x8(%esp),%eax
f010185d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101861:	83 c4 1c             	add    $0x1c,%esp
f0101864:	5b                   	pop    %ebx
f0101865:	5e                   	pop    %esi
f0101866:	5f                   	pop    %edi
f0101867:	5d                   	pop    %ebp
f0101868:	c3                   	ret    
f0101869:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101870:	85 ff                	test   %edi,%edi
f0101872:	89 fd                	mov    %edi,%ebp
f0101874:	75 0b                	jne    f0101881 <__umoddi3+0x91>
f0101876:	b8 01 00 00 00       	mov    $0x1,%eax
f010187b:	31 d2                	xor    %edx,%edx
f010187d:	f7 f7                	div    %edi
f010187f:	89 c5                	mov    %eax,%ebp
f0101881:	89 f0                	mov    %esi,%eax
f0101883:	31 d2                	xor    %edx,%edx
f0101885:	f7 f5                	div    %ebp
f0101887:	89 c8                	mov    %ecx,%eax
f0101889:	f7 f5                	div    %ebp
f010188b:	89 d0                	mov    %edx,%eax
f010188d:	eb 99                	jmp    f0101828 <__umoddi3+0x38>
f010188f:	90                   	nop
f0101890:	89 c8                	mov    %ecx,%eax
f0101892:	89 f2                	mov    %esi,%edx
f0101894:	83 c4 1c             	add    $0x1c,%esp
f0101897:	5b                   	pop    %ebx
f0101898:	5e                   	pop    %esi
f0101899:	5f                   	pop    %edi
f010189a:	5d                   	pop    %ebp
f010189b:	c3                   	ret    
f010189c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018a0:	8b 34 24             	mov    (%esp),%esi
f01018a3:	bf 20 00 00 00       	mov    $0x20,%edi
f01018a8:	89 e9                	mov    %ebp,%ecx
f01018aa:	29 ef                	sub    %ebp,%edi
f01018ac:	d3 e0                	shl    %cl,%eax
f01018ae:	89 f9                	mov    %edi,%ecx
f01018b0:	89 f2                	mov    %esi,%edx
f01018b2:	d3 ea                	shr    %cl,%edx
f01018b4:	89 e9                	mov    %ebp,%ecx
f01018b6:	09 c2                	or     %eax,%edx
f01018b8:	89 d8                	mov    %ebx,%eax
f01018ba:	89 14 24             	mov    %edx,(%esp)
f01018bd:	89 f2                	mov    %esi,%edx
f01018bf:	d3 e2                	shl    %cl,%edx
f01018c1:	89 f9                	mov    %edi,%ecx
f01018c3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01018c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01018cb:	d3 e8                	shr    %cl,%eax
f01018cd:	89 e9                	mov    %ebp,%ecx
f01018cf:	89 c6                	mov    %eax,%esi
f01018d1:	d3 e3                	shl    %cl,%ebx
f01018d3:	89 f9                	mov    %edi,%ecx
f01018d5:	89 d0                	mov    %edx,%eax
f01018d7:	d3 e8                	shr    %cl,%eax
f01018d9:	89 e9                	mov    %ebp,%ecx
f01018db:	09 d8                	or     %ebx,%eax
f01018dd:	89 d3                	mov    %edx,%ebx
f01018df:	89 f2                	mov    %esi,%edx
f01018e1:	f7 34 24             	divl   (%esp)
f01018e4:	89 d6                	mov    %edx,%esi
f01018e6:	d3 e3                	shl    %cl,%ebx
f01018e8:	f7 64 24 04          	mull   0x4(%esp)
f01018ec:	39 d6                	cmp    %edx,%esi
f01018ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01018f2:	89 d1                	mov    %edx,%ecx
f01018f4:	89 c3                	mov    %eax,%ebx
f01018f6:	72 08                	jb     f0101900 <__umoddi3+0x110>
f01018f8:	75 11                	jne    f010190b <__umoddi3+0x11b>
f01018fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01018fe:	73 0b                	jae    f010190b <__umoddi3+0x11b>
f0101900:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101904:	1b 14 24             	sbb    (%esp),%edx
f0101907:	89 d1                	mov    %edx,%ecx
f0101909:	89 c3                	mov    %eax,%ebx
f010190b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010190f:	29 da                	sub    %ebx,%edx
f0101911:	19 ce                	sbb    %ecx,%esi
f0101913:	89 f9                	mov    %edi,%ecx
f0101915:	89 f0                	mov    %esi,%eax
f0101917:	d3 e0                	shl    %cl,%eax
f0101919:	89 e9                	mov    %ebp,%ecx
f010191b:	d3 ea                	shr    %cl,%edx
f010191d:	89 e9                	mov    %ebp,%ecx
f010191f:	d3 ee                	shr    %cl,%esi
f0101921:	09 d0                	or     %edx,%eax
f0101923:	89 f2                	mov    %esi,%edx
f0101925:	83 c4 1c             	add    $0x1c,%esp
f0101928:	5b                   	pop    %ebx
f0101929:	5e                   	pop    %esi
f010192a:	5f                   	pop    %edi
f010192b:	5d                   	pop    %ebp
f010192c:	c3                   	ret    
f010192d:	8d 76 00             	lea    0x0(%esi),%esi
f0101930:	29 f9                	sub    %edi,%ecx
f0101932:	19 d6                	sbb    %edx,%esi
f0101934:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101938:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010193c:	e9 18 ff ff ff       	jmp    f0101859 <__umoddi3+0x69>
