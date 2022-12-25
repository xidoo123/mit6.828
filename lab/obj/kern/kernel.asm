
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
f010004b:	68 80 18 10 f0       	push   $0xf0101880
f0100050:	e8 1e 09 00 00       	call   f0100973 <cprintf>
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
f0100082:	68 9c 18 10 f0       	push   $0xf010189c
f0100087:	e8 e7 08 00 00       	call   f0100973 <cprintf>
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
f01000ac:	e8 2c 13 00 00       	call   f01013dd <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 9d 04 00 00       	call   f0100553 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 b7 18 10 f0       	push   $0xf01018b7
f01000c3:	e8 ab 08 00 00       	call   f0100973 <cprintf>

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
f01000dc:	e8 25 07 00 00       	call   f0100806 <monitor>
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
f010010b:	68 d2 18 10 f0       	push   $0xf01018d2
f0100110:	e8 5e 08 00 00       	call   f0100973 <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 2e 08 00 00       	call   f010094d <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 0e 19 10 f0 	movl   $0xf010190e,(%esp)
f0100126:	e8 48 08 00 00       	call   f0100973 <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 ce 06 00 00       	call   f0100806 <monitor>
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
f010014d:	68 ea 18 10 f0       	push   $0xf01018ea
f0100152:	e8 1c 08 00 00       	call   f0100973 <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 ea 07 00 00       	call   f010094d <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 0e 19 10 f0 	movl   $0xf010190e,(%esp)
f010016a:	e8 04 08 00 00       	call   f0100973 <cprintf>
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
f0100229:	0f b6 82 60 1a 10 f0 	movzbl -0xfefe5a0(%edx),%eax
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
f0100265:	0f b6 82 60 1a 10 f0 	movzbl -0xfefe5a0(%edx),%eax
f010026c:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f0100272:	0f b6 8a 60 19 10 f0 	movzbl -0xfefe6a0(%edx),%ecx
f0100279:	31 c8                	xor    %ecx,%eax
f010027b:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100280:	89 c1                	mov    %eax,%ecx
f0100282:	83 e1 03             	and    $0x3,%ecx
f0100285:	8b 0c 8d 40 19 10 f0 	mov    -0xfefe6c0(,%ecx,4),%ecx
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
f01002c3:	68 04 19 10 f0       	push   $0xf0101904
f01002c8:	e8 a6 06 00 00       	call   f0100973 <cprintf>
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
f0100477:	e8 ae 0f 00 00       	call   f010142a <memmove>
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
f0100646:	68 10 19 10 f0       	push   $0xf0101910
f010064b:	e8 23 03 00 00       	call   f0100973 <cprintf>
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
f010068c:	68 60 1b 10 f0       	push   $0xf0101b60
f0100691:	68 7e 1b 10 f0       	push   $0xf0101b7e
f0100696:	68 83 1b 10 f0       	push   $0xf0101b83
f010069b:	e8 d3 02 00 00       	call   f0100973 <cprintf>
f01006a0:	83 c4 0c             	add    $0xc,%esp
f01006a3:	68 24 1c 10 f0       	push   $0xf0101c24
f01006a8:	68 8c 1b 10 f0       	push   $0xf0101b8c
f01006ad:	68 83 1b 10 f0       	push   $0xf0101b83
f01006b2:	e8 bc 02 00 00       	call   f0100973 <cprintf>
f01006b7:	83 c4 0c             	add    $0xc,%esp
f01006ba:	68 95 1b 10 f0       	push   $0xf0101b95
f01006bf:	68 b3 1b 10 f0       	push   $0xf0101bb3
f01006c4:	68 83 1b 10 f0       	push   $0xf0101b83
f01006c9:	e8 a5 02 00 00       	call   f0100973 <cprintf>
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
f01006db:	68 bd 1b 10 f0       	push   $0xf0101bbd
f01006e0:	e8 8e 02 00 00       	call   f0100973 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006e5:	83 c4 08             	add    $0x8,%esp
f01006e8:	68 0c 00 10 00       	push   $0x10000c
f01006ed:	68 4c 1c 10 f0       	push   $0xf0101c4c
f01006f2:	e8 7c 02 00 00       	call   f0100973 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006f7:	83 c4 0c             	add    $0xc,%esp
f01006fa:	68 0c 00 10 00       	push   $0x10000c
f01006ff:	68 0c 00 10 f0       	push   $0xf010000c
f0100704:	68 74 1c 10 f0       	push   $0xf0101c74
f0100709:	e8 65 02 00 00       	call   f0100973 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010070e:	83 c4 0c             	add    $0xc,%esp
f0100711:	68 61 18 10 00       	push   $0x101861
f0100716:	68 61 18 10 f0       	push   $0xf0101861
f010071b:	68 98 1c 10 f0       	push   $0xf0101c98
f0100720:	e8 4e 02 00 00       	call   f0100973 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100725:	83 c4 0c             	add    $0xc,%esp
f0100728:	68 00 23 11 00       	push   $0x112300
f010072d:	68 00 23 11 f0       	push   $0xf0112300
f0100732:	68 bc 1c 10 f0       	push   $0xf0101cbc
f0100737:	e8 37 02 00 00       	call   f0100973 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010073c:	83 c4 0c             	add    $0xc,%esp
f010073f:	68 40 29 11 00       	push   $0x112940
f0100744:	68 40 29 11 f0       	push   $0xf0112940
f0100749:	68 e0 1c 10 f0       	push   $0xf0101ce0
f010074e:	e8 20 02 00 00       	call   f0100973 <cprintf>
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
f0100774:	68 04 1d 10 f0       	push   $0xf0101d04
f0100779:	e8 f5 01 00 00       	call   f0100973 <cprintf>
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
f0100788:	53                   	push   %ebx
f0100789:	83 ec 30             	sub    $0x30,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010078c:	89 eb                	mov    %ebp,%ebx

	uint32_t _ebp, _eip;
	// _esp = read_esp();
	_ebp = read_ebp();

	uint32_t args[5] = {0, 0, 0, 0, 0};
f010078e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100795:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f010079c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f01007a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01007aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	cprintf("Stack backtrace:\n");
f01007b1:	68 d6 1b 10 f0       	push   $0xf0101bd6
f01007b6:	e8 b8 01 00 00       	call   f0100973 <cprintf>

	while (_ebp != 0) {
f01007bb:	83 c4 10             	add    $0x10,%esp
f01007be:	eb 38                	jmp    f01007f8 <mon_backtrace+0x73>
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr
f01007c0:	8b 4b 04             	mov    0x4(%ebx),%ecx

		for (int i=0; i<5; i++) {
f01007c3:	b8 00 00 00 00       	mov    $0x0,%eax
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
f01007c8:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f01007cc:	89 54 85 e4          	mov    %edx,-0x1c(%ebp,%eax,4)

	while (_ebp != 0) {
		
		_eip = *(uint32_t *)(_ebp + 4);		// ret addr

		for (int i=0; i<5; i++) {
f01007d0:	83 c0 01             	add    $0x1,%eax
f01007d3:	83 f8 05             	cmp    $0x5,%eax
f01007d6:	75 f0                	jne    f01007c8 <mon_backtrace+0x43>
			args[i] = *(uint32_t *)(_ebp + 8 + i * 4);
		}

		// _rsp = _ebp + 8;			// old_rsp
		_ebp = *(uint32_t *)_ebp;	// old_ebp
f01007d8:	8b 1b                	mov    (%ebx),%ebx

		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", _ebp, _eip, args[0], args[1], args[2], args[3], args[4]);
f01007da:	ff 75 f4             	pushl  -0xc(%ebp)
f01007dd:	ff 75 f0             	pushl  -0x10(%ebp)
f01007e0:	ff 75 ec             	pushl  -0x14(%ebp)
f01007e3:	ff 75 e8             	pushl  -0x18(%ebp)
f01007e6:	ff 75 e4             	pushl  -0x1c(%ebp)
f01007e9:	51                   	push   %ecx
f01007ea:	53                   	push   %ebx
f01007eb:	68 30 1d 10 f0       	push   $0xf0101d30
f01007f0:	e8 7e 01 00 00       	call   f0100973 <cprintf>
f01007f5:	83 c4 20             	add    $0x20,%esp

	uint32_t args[5] = {0, 0, 0, 0, 0};

	cprintf("Stack backtrace:\n");

	while (_ebp != 0) {
f01007f8:	85 db                	test   %ebx,%ebx
f01007fa:	75 c4                	jne    f01007c0 <mon_backtrace+0x3b>

		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", _ebp, _eip, args[0], args[1], args[2], args[3], args[4]);
	} 

	return 0;
}
f01007fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100804:	c9                   	leave  
f0100805:	c3                   	ret    

f0100806 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100806:	55                   	push   %ebp
f0100807:	89 e5                	mov    %esp,%ebp
f0100809:	57                   	push   %edi
f010080a:	56                   	push   %esi
f010080b:	53                   	push   %ebx
f010080c:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010080f:	68 68 1d 10 f0       	push   $0xf0101d68
f0100814:	e8 5a 01 00 00       	call   f0100973 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100819:	c7 04 24 8c 1d 10 f0 	movl   $0xf0101d8c,(%esp)
f0100820:	e8 4e 01 00 00       	call   f0100973 <cprintf>
f0100825:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100828:	83 ec 0c             	sub    $0xc,%esp
f010082b:	68 e8 1b 10 f0       	push   $0xf0101be8
f0100830:	e8 51 09 00 00       	call   f0101186 <readline>
f0100835:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100837:	83 c4 10             	add    $0x10,%esp
f010083a:	85 c0                	test   %eax,%eax
f010083c:	74 ea                	je     f0100828 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010083e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100845:	be 00 00 00 00       	mov    $0x0,%esi
f010084a:	eb 0a                	jmp    f0100856 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010084c:	c6 03 00             	movb   $0x0,(%ebx)
f010084f:	89 f7                	mov    %esi,%edi
f0100851:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100854:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100856:	0f b6 03             	movzbl (%ebx),%eax
f0100859:	84 c0                	test   %al,%al
f010085b:	74 63                	je     f01008c0 <monitor+0xba>
f010085d:	83 ec 08             	sub    $0x8,%esp
f0100860:	0f be c0             	movsbl %al,%eax
f0100863:	50                   	push   %eax
f0100864:	68 ec 1b 10 f0       	push   $0xf0101bec
f0100869:	e8 32 0b 00 00       	call   f01013a0 <strchr>
f010086e:	83 c4 10             	add    $0x10,%esp
f0100871:	85 c0                	test   %eax,%eax
f0100873:	75 d7                	jne    f010084c <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100875:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100878:	74 46                	je     f01008c0 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010087a:	83 fe 0f             	cmp    $0xf,%esi
f010087d:	75 14                	jne    f0100893 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010087f:	83 ec 08             	sub    $0x8,%esp
f0100882:	6a 10                	push   $0x10
f0100884:	68 f1 1b 10 f0       	push   $0xf0101bf1
f0100889:	e8 e5 00 00 00       	call   f0100973 <cprintf>
f010088e:	83 c4 10             	add    $0x10,%esp
f0100891:	eb 95                	jmp    f0100828 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100893:	8d 7e 01             	lea    0x1(%esi),%edi
f0100896:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010089a:	eb 03                	jmp    f010089f <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010089c:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010089f:	0f b6 03             	movzbl (%ebx),%eax
f01008a2:	84 c0                	test   %al,%al
f01008a4:	74 ae                	je     f0100854 <monitor+0x4e>
f01008a6:	83 ec 08             	sub    $0x8,%esp
f01008a9:	0f be c0             	movsbl %al,%eax
f01008ac:	50                   	push   %eax
f01008ad:	68 ec 1b 10 f0       	push   $0xf0101bec
f01008b2:	e8 e9 0a 00 00       	call   f01013a0 <strchr>
f01008b7:	83 c4 10             	add    $0x10,%esp
f01008ba:	85 c0                	test   %eax,%eax
f01008bc:	74 de                	je     f010089c <monitor+0x96>
f01008be:	eb 94                	jmp    f0100854 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008c0:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008c7:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008c8:	85 f6                	test   %esi,%esi
f01008ca:	0f 84 58 ff ff ff    	je     f0100828 <monitor+0x22>
f01008d0:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008d5:	83 ec 08             	sub    $0x8,%esp
f01008d8:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008db:	ff 34 85 c0 1d 10 f0 	pushl  -0xfefe240(,%eax,4)
f01008e2:	ff 75 a8             	pushl  -0x58(%ebp)
f01008e5:	e8 58 0a 00 00       	call   f0101342 <strcmp>
f01008ea:	83 c4 10             	add    $0x10,%esp
f01008ed:	85 c0                	test   %eax,%eax
f01008ef:	75 21                	jne    f0100912 <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f01008f1:	83 ec 04             	sub    $0x4,%esp
f01008f4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008f7:	ff 75 08             	pushl  0x8(%ebp)
f01008fa:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008fd:	52                   	push   %edx
f01008fe:	56                   	push   %esi
f01008ff:	ff 14 85 c8 1d 10 f0 	call   *-0xfefe238(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100906:	83 c4 10             	add    $0x10,%esp
f0100909:	85 c0                	test   %eax,%eax
f010090b:	78 25                	js     f0100932 <monitor+0x12c>
f010090d:	e9 16 ff ff ff       	jmp    f0100828 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100912:	83 c3 01             	add    $0x1,%ebx
f0100915:	83 fb 03             	cmp    $0x3,%ebx
f0100918:	75 bb                	jne    f01008d5 <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010091a:	83 ec 08             	sub    $0x8,%esp
f010091d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100920:	68 0e 1c 10 f0       	push   $0xf0101c0e
f0100925:	e8 49 00 00 00       	call   f0100973 <cprintf>
f010092a:	83 c4 10             	add    $0x10,%esp
f010092d:	e9 f6 fe ff ff       	jmp    f0100828 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100932:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100935:	5b                   	pop    %ebx
f0100936:	5e                   	pop    %esi
f0100937:	5f                   	pop    %edi
f0100938:	5d                   	pop    %ebp
f0100939:	c3                   	ret    

f010093a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010093a:	55                   	push   %ebp
f010093b:	89 e5                	mov    %esp,%ebp
f010093d:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100940:	ff 75 08             	pushl  0x8(%ebp)
f0100943:	e8 13 fd ff ff       	call   f010065b <cputchar>
	*cnt++;
}
f0100948:	83 c4 10             	add    $0x10,%esp
f010094b:	c9                   	leave  
f010094c:	c3                   	ret    

f010094d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010094d:	55                   	push   %ebp
f010094e:	89 e5                	mov    %esp,%ebp
f0100950:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100953:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010095a:	ff 75 0c             	pushl  0xc(%ebp)
f010095d:	ff 75 08             	pushl  0x8(%ebp)
f0100960:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100963:	50                   	push   %eax
f0100964:	68 3a 09 10 f0       	push   $0xf010093a
f0100969:	e8 03 04 00 00       	call   f0100d71 <vprintfmt>
	return cnt;
}
f010096e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100971:	c9                   	leave  
f0100972:	c3                   	ret    

f0100973 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100973:	55                   	push   %ebp
f0100974:	89 e5                	mov    %esp,%ebp
f0100976:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100979:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010097c:	50                   	push   %eax
f010097d:	ff 75 08             	pushl  0x8(%ebp)
f0100980:	e8 c8 ff ff ff       	call   f010094d <vcprintf>
	va_end(ap);

	return cnt;
}
f0100985:	c9                   	leave  
f0100986:	c3                   	ret    

f0100987 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100987:	55                   	push   %ebp
f0100988:	89 e5                	mov    %esp,%ebp
f010098a:	57                   	push   %edi
f010098b:	56                   	push   %esi
f010098c:	53                   	push   %ebx
f010098d:	83 ec 14             	sub    $0x14,%esp
f0100990:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100993:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100996:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100999:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010099c:	8b 1a                	mov    (%edx),%ebx
f010099e:	8b 01                	mov    (%ecx),%eax
f01009a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009a3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009aa:	eb 7f                	jmp    f0100a2b <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01009ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009af:	01 d8                	add    %ebx,%eax
f01009b1:	89 c6                	mov    %eax,%esi
f01009b3:	c1 ee 1f             	shr    $0x1f,%esi
f01009b6:	01 c6                	add    %eax,%esi
f01009b8:	d1 fe                	sar    %esi
f01009ba:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009bd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009c0:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01009c3:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009c5:	eb 03                	jmp    f01009ca <stab_binsearch+0x43>
			m--;
f01009c7:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009ca:	39 c3                	cmp    %eax,%ebx
f01009cc:	7f 0d                	jg     f01009db <stab_binsearch+0x54>
f01009ce:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01009d2:	83 ea 0c             	sub    $0xc,%edx
f01009d5:	39 f9                	cmp    %edi,%ecx
f01009d7:	75 ee                	jne    f01009c7 <stab_binsearch+0x40>
f01009d9:	eb 05                	jmp    f01009e0 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009db:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01009de:	eb 4b                	jmp    f0100a2b <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009e0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009e3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009e6:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01009ea:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01009ed:	76 11                	jbe    f0100a00 <stab_binsearch+0x79>
			*region_left = m;
f01009ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01009f2:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01009f4:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009f7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01009fe:	eb 2b                	jmp    f0100a2b <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a00:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a03:	73 14                	jae    f0100a19 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a05:	83 e8 01             	sub    $0x1,%eax
f0100a08:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a0b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a0e:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a10:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a17:	eb 12                	jmp    f0100a2b <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a19:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a1c:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a1e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a22:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a24:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a2b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a2e:	0f 8e 78 ff ff ff    	jle    f01009ac <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a34:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a38:	75 0f                	jne    f0100a49 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100a3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a3d:	8b 00                	mov    (%eax),%eax
f0100a3f:	83 e8 01             	sub    $0x1,%eax
f0100a42:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a45:	89 06                	mov    %eax,(%esi)
f0100a47:	eb 2c                	jmp    f0100a75 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a49:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a4c:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a4e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a51:	8b 0e                	mov    (%esi),%ecx
f0100a53:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a56:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a59:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a5c:	eb 03                	jmp    f0100a61 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a5e:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a61:	39 c8                	cmp    %ecx,%eax
f0100a63:	7e 0b                	jle    f0100a70 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100a65:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100a69:	83 ea 0c             	sub    $0xc,%edx
f0100a6c:	39 df                	cmp    %ebx,%edi
f0100a6e:	75 ee                	jne    f0100a5e <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a70:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a73:	89 06                	mov    %eax,(%esi)
	}
}
f0100a75:	83 c4 14             	add    $0x14,%esp
f0100a78:	5b                   	pop    %ebx
f0100a79:	5e                   	pop    %esi
f0100a7a:	5f                   	pop    %edi
f0100a7b:	5d                   	pop    %ebp
f0100a7c:	c3                   	ret    

f0100a7d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a7d:	55                   	push   %ebp
f0100a7e:	89 e5                	mov    %esp,%ebp
f0100a80:	57                   	push   %edi
f0100a81:	56                   	push   %esi
f0100a82:	53                   	push   %ebx
f0100a83:	83 ec 1c             	sub    $0x1c,%esp
f0100a86:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100a89:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a8c:	c7 06 e4 1d 10 f0    	movl   $0xf0101de4,(%esi)
	info->eip_line = 0;
f0100a92:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100a99:	c7 46 08 e4 1d 10 f0 	movl   $0xf0101de4,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100aa0:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100aa7:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100aaa:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100ab1:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100ab7:	76 11                	jbe    f0100aca <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ab9:	b8 9c 72 10 f0       	mov    $0xf010729c,%eax
f0100abe:	3d 7d 59 10 f0       	cmp    $0xf010597d,%eax
f0100ac3:	77 19                	ja     f0100ade <debuginfo_eip+0x61>
f0100ac5:	e9 62 01 00 00       	jmp    f0100c2c <debuginfo_eip+0x1af>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100aca:	83 ec 04             	sub    $0x4,%esp
f0100acd:	68 ee 1d 10 f0       	push   $0xf0101dee
f0100ad2:	6a 7f                	push   $0x7f
f0100ad4:	68 fb 1d 10 f0       	push   $0xf0101dfb
f0100ad9:	e8 08 f6 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ade:	80 3d 9b 72 10 f0 00 	cmpb   $0x0,0xf010729b
f0100ae5:	0f 85 48 01 00 00    	jne    f0100c33 <debuginfo_eip+0x1b6>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100aeb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100af2:	b8 7c 59 10 f0       	mov    $0xf010597c,%eax
f0100af7:	2d 1c 20 10 f0       	sub    $0xf010201c,%eax
f0100afc:	c1 f8 02             	sar    $0x2,%eax
f0100aff:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b05:	83 e8 01             	sub    $0x1,%eax
f0100b08:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b0b:	83 ec 08             	sub    $0x8,%esp
f0100b0e:	57                   	push   %edi
f0100b0f:	6a 64                	push   $0x64
f0100b11:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b14:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b17:	b8 1c 20 10 f0       	mov    $0xf010201c,%eax
f0100b1c:	e8 66 fe ff ff       	call   f0100987 <stab_binsearch>
	if (lfile == 0)
f0100b21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b24:	83 c4 10             	add    $0x10,%esp
f0100b27:	85 c0                	test   %eax,%eax
f0100b29:	0f 84 0b 01 00 00    	je     f0100c3a <debuginfo_eip+0x1bd>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b2f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b32:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b35:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b38:	83 ec 08             	sub    $0x8,%esp
f0100b3b:	57                   	push   %edi
f0100b3c:	6a 24                	push   $0x24
f0100b3e:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b41:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b44:	b8 1c 20 10 f0       	mov    $0xf010201c,%eax
f0100b49:	e8 39 fe ff ff       	call   f0100987 <stab_binsearch>

	if (lfun <= rfun) {
f0100b4e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100b51:	83 c4 10             	add    $0x10,%esp
f0100b54:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100b57:	7f 31                	jg     f0100b8a <debuginfo_eip+0x10d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b59:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b5c:	c1 e0 02             	shl    $0x2,%eax
f0100b5f:	8d 90 1c 20 10 f0    	lea    -0xfefdfe4(%eax),%edx
f0100b65:	8b 88 1c 20 10 f0    	mov    -0xfefdfe4(%eax),%ecx
f0100b6b:	b8 9c 72 10 f0       	mov    $0xf010729c,%eax
f0100b70:	2d 7d 59 10 f0       	sub    $0xf010597d,%eax
f0100b75:	39 c1                	cmp    %eax,%ecx
f0100b77:	73 09                	jae    f0100b82 <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b79:	81 c1 7d 59 10 f0    	add    $0xf010597d,%ecx
f0100b7f:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b82:	8b 42 08             	mov    0x8(%edx),%eax
f0100b85:	89 46 10             	mov    %eax,0x10(%esi)
f0100b88:	eb 06                	jmp    f0100b90 <debuginfo_eip+0x113>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b8a:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100b8d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b90:	83 ec 08             	sub    $0x8,%esp
f0100b93:	6a 3a                	push   $0x3a
f0100b95:	ff 76 08             	pushl  0x8(%esi)
f0100b98:	e8 24 08 00 00       	call   f01013c1 <strfind>
f0100b9d:	2b 46 08             	sub    0x8(%esi),%eax
f0100ba0:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100ba3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ba6:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ba9:	8d 04 85 1c 20 10 f0 	lea    -0xfefdfe4(,%eax,4),%eax
f0100bb0:	83 c4 10             	add    $0x10,%esp
f0100bb3:	eb 06                	jmp    f0100bbb <debuginfo_eip+0x13e>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100bb5:	83 eb 01             	sub    $0x1,%ebx
f0100bb8:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bbb:	39 fb                	cmp    %edi,%ebx
f0100bbd:	7c 34                	jl     f0100bf3 <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0100bbf:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0100bc3:	80 fa 84             	cmp    $0x84,%dl
f0100bc6:	74 0b                	je     f0100bd3 <debuginfo_eip+0x156>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100bc8:	80 fa 64             	cmp    $0x64,%dl
f0100bcb:	75 e8                	jne    f0100bb5 <debuginfo_eip+0x138>
f0100bcd:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100bd1:	74 e2                	je     f0100bb5 <debuginfo_eip+0x138>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100bd3:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bd6:	8b 14 85 1c 20 10 f0 	mov    -0xfefdfe4(,%eax,4),%edx
f0100bdd:	b8 9c 72 10 f0       	mov    $0xf010729c,%eax
f0100be2:	2d 7d 59 10 f0       	sub    $0xf010597d,%eax
f0100be7:	39 c2                	cmp    %eax,%edx
f0100be9:	73 08                	jae    f0100bf3 <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100beb:	81 c2 7d 59 10 f0    	add    $0xf010597d,%edx
f0100bf1:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100bf3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100bf6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100bf9:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100bfe:	39 cb                	cmp    %ecx,%ebx
f0100c00:	7d 44                	jge    f0100c46 <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
f0100c02:	8d 53 01             	lea    0x1(%ebx),%edx
f0100c05:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c08:	8d 04 85 1c 20 10 f0 	lea    -0xfefdfe4(,%eax,4),%eax
f0100c0f:	eb 07                	jmp    f0100c18 <debuginfo_eip+0x19b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c11:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100c15:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c18:	39 ca                	cmp    %ecx,%edx
f0100c1a:	74 25                	je     f0100c41 <debuginfo_eip+0x1c4>
f0100c1c:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c1f:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0100c23:	74 ec                	je     f0100c11 <debuginfo_eip+0x194>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c25:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c2a:	eb 1a                	jmp    f0100c46 <debuginfo_eip+0x1c9>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c31:	eb 13                	jmp    f0100c46 <debuginfo_eip+0x1c9>
f0100c33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c38:	eb 0c                	jmp    f0100c46 <debuginfo_eip+0x1c9>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100c3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c3f:	eb 05                	jmp    f0100c46 <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c41:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c49:	5b                   	pop    %ebx
f0100c4a:	5e                   	pop    %esi
f0100c4b:	5f                   	pop    %edi
f0100c4c:	5d                   	pop    %ebp
f0100c4d:	c3                   	ret    

f0100c4e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100c4e:	55                   	push   %ebp
f0100c4f:	89 e5                	mov    %esp,%ebp
f0100c51:	57                   	push   %edi
f0100c52:	56                   	push   %esi
f0100c53:	53                   	push   %ebx
f0100c54:	83 ec 1c             	sub    $0x1c,%esp
f0100c57:	89 c7                	mov    %eax,%edi
f0100c59:	89 d6                	mov    %edx,%esi
f0100c5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100c64:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100c67:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100c6a:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c6f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100c72:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100c75:	39 d3                	cmp    %edx,%ebx
f0100c77:	72 05                	jb     f0100c7e <printnum+0x30>
f0100c79:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100c7c:	77 45                	ja     f0100cc3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100c7e:	83 ec 0c             	sub    $0xc,%esp
f0100c81:	ff 75 18             	pushl  0x18(%ebp)
f0100c84:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c87:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100c8a:	53                   	push   %ebx
f0100c8b:	ff 75 10             	pushl  0x10(%ebp)
f0100c8e:	83 ec 08             	sub    $0x8,%esp
f0100c91:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c94:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c97:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c9a:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c9d:	e8 3e 09 00 00       	call   f01015e0 <__udivdi3>
f0100ca2:	83 c4 18             	add    $0x18,%esp
f0100ca5:	52                   	push   %edx
f0100ca6:	50                   	push   %eax
f0100ca7:	89 f2                	mov    %esi,%edx
f0100ca9:	89 f8                	mov    %edi,%eax
f0100cab:	e8 9e ff ff ff       	call   f0100c4e <printnum>
f0100cb0:	83 c4 20             	add    $0x20,%esp
f0100cb3:	eb 18                	jmp    f0100ccd <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100cb5:	83 ec 08             	sub    $0x8,%esp
f0100cb8:	56                   	push   %esi
f0100cb9:	ff 75 18             	pushl  0x18(%ebp)
f0100cbc:	ff d7                	call   *%edi
f0100cbe:	83 c4 10             	add    $0x10,%esp
f0100cc1:	eb 03                	jmp    f0100cc6 <printnum+0x78>
f0100cc3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100cc6:	83 eb 01             	sub    $0x1,%ebx
f0100cc9:	85 db                	test   %ebx,%ebx
f0100ccb:	7f e8                	jg     f0100cb5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100ccd:	83 ec 08             	sub    $0x8,%esp
f0100cd0:	56                   	push   %esi
f0100cd1:	83 ec 04             	sub    $0x4,%esp
f0100cd4:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100cd7:	ff 75 e0             	pushl  -0x20(%ebp)
f0100cda:	ff 75 dc             	pushl  -0x24(%ebp)
f0100cdd:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ce0:	e8 2b 0a 00 00       	call   f0101710 <__umoddi3>
f0100ce5:	83 c4 14             	add    $0x14,%esp
f0100ce8:	0f be 80 09 1e 10 f0 	movsbl -0xfefe1f7(%eax),%eax
f0100cef:	50                   	push   %eax
f0100cf0:	ff d7                	call   *%edi
}
f0100cf2:	83 c4 10             	add    $0x10,%esp
f0100cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cf8:	5b                   	pop    %ebx
f0100cf9:	5e                   	pop    %esi
f0100cfa:	5f                   	pop    %edi
f0100cfb:	5d                   	pop    %ebp
f0100cfc:	c3                   	ret    

f0100cfd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100cfd:	55                   	push   %ebp
f0100cfe:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d00:	83 fa 01             	cmp    $0x1,%edx
f0100d03:	7e 0e                	jle    f0100d13 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d05:	8b 10                	mov    (%eax),%edx
f0100d07:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d0a:	89 08                	mov    %ecx,(%eax)
f0100d0c:	8b 02                	mov    (%edx),%eax
f0100d0e:	8b 52 04             	mov    0x4(%edx),%edx
f0100d11:	eb 22                	jmp    f0100d35 <getuint+0x38>
	else if (lflag)
f0100d13:	85 d2                	test   %edx,%edx
f0100d15:	74 10                	je     f0100d27 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d17:	8b 10                	mov    (%eax),%edx
f0100d19:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d1c:	89 08                	mov    %ecx,(%eax)
f0100d1e:	8b 02                	mov    (%edx),%eax
f0100d20:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d25:	eb 0e                	jmp    f0100d35 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100d27:	8b 10                	mov    (%eax),%edx
f0100d29:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d2c:	89 08                	mov    %ecx,(%eax)
f0100d2e:	8b 02                	mov    (%edx),%eax
f0100d30:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d35:	5d                   	pop    %ebp
f0100d36:	c3                   	ret    

f0100d37 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d37:	55                   	push   %ebp
f0100d38:	89 e5                	mov    %esp,%ebp
f0100d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d3d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100d41:	8b 10                	mov    (%eax),%edx
f0100d43:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d46:	73 0a                	jae    f0100d52 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100d48:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100d4b:	89 08                	mov    %ecx,(%eax)
f0100d4d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d50:	88 02                	mov    %al,(%edx)
}
f0100d52:	5d                   	pop    %ebp
f0100d53:	c3                   	ret    

f0100d54 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100d54:	55                   	push   %ebp
f0100d55:	89 e5                	mov    %esp,%ebp
f0100d57:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100d5a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100d5d:	50                   	push   %eax
f0100d5e:	ff 75 10             	pushl  0x10(%ebp)
f0100d61:	ff 75 0c             	pushl  0xc(%ebp)
f0100d64:	ff 75 08             	pushl  0x8(%ebp)
f0100d67:	e8 05 00 00 00       	call   f0100d71 <vprintfmt>
	va_end(ap);
}
f0100d6c:	83 c4 10             	add    $0x10,%esp
f0100d6f:	c9                   	leave  
f0100d70:	c3                   	ret    

f0100d71 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100d71:	55                   	push   %ebp
f0100d72:	89 e5                	mov    %esp,%ebp
f0100d74:	57                   	push   %edi
f0100d75:	56                   	push   %esi
f0100d76:	53                   	push   %ebx
f0100d77:	83 ec 2c             	sub    $0x2c,%esp
f0100d7a:	8b 75 08             	mov    0x8(%ebp),%esi
f0100d7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100d80:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100d83:	eb 12                	jmp    f0100d97 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100d85:	85 c0                	test   %eax,%eax
f0100d87:	0f 84 89 03 00 00    	je     f0101116 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100d8d:	83 ec 08             	sub    $0x8,%esp
f0100d90:	53                   	push   %ebx
f0100d91:	50                   	push   %eax
f0100d92:	ff d6                	call   *%esi
f0100d94:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100d97:	83 c7 01             	add    $0x1,%edi
f0100d9a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100d9e:	83 f8 25             	cmp    $0x25,%eax
f0100da1:	75 e2                	jne    f0100d85 <vprintfmt+0x14>
f0100da3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100da7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100dae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100db5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100dbc:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dc1:	eb 07                	jmp    f0100dca <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dc3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100dc6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dca:	8d 47 01             	lea    0x1(%edi),%eax
f0100dcd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100dd0:	0f b6 07             	movzbl (%edi),%eax
f0100dd3:	0f b6 c8             	movzbl %al,%ecx
f0100dd6:	83 e8 23             	sub    $0x23,%eax
f0100dd9:	3c 55                	cmp    $0x55,%al
f0100ddb:	0f 87 1a 03 00 00    	ja     f01010fb <vprintfmt+0x38a>
f0100de1:	0f b6 c0             	movzbl %al,%eax
f0100de4:	ff 24 85 98 1e 10 f0 	jmp    *-0xfefe168(,%eax,4)
f0100deb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100dee:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100df2:	eb d6                	jmp    f0100dca <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100df4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100df7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dfc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100dff:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e02:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100e06:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100e09:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100e0c:	83 fa 09             	cmp    $0x9,%edx
f0100e0f:	77 39                	ja     f0100e4a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e11:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e14:	eb e9                	jmp    f0100dff <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e16:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e19:	8d 48 04             	lea    0x4(%eax),%ecx
f0100e1c:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100e1f:	8b 00                	mov    (%eax),%eax
f0100e21:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100e27:	eb 27                	jmp    f0100e50 <vprintfmt+0xdf>
f0100e29:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e2c:	85 c0                	test   %eax,%eax
f0100e2e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e33:	0f 49 c8             	cmovns %eax,%ecx
f0100e36:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e3c:	eb 8c                	jmp    f0100dca <vprintfmt+0x59>
f0100e3e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100e41:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100e48:	eb 80                	jmp    f0100dca <vprintfmt+0x59>
f0100e4a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100e4d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100e50:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100e54:	0f 89 70 ff ff ff    	jns    f0100dca <vprintfmt+0x59>
				width = precision, precision = -1;
f0100e5a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100e5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e60:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e67:	e9 5e ff ff ff       	jmp    f0100dca <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100e6c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100e72:	e9 53 ff ff ff       	jmp    f0100dca <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100e77:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e7a:	8d 50 04             	lea    0x4(%eax),%edx
f0100e7d:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e80:	83 ec 08             	sub    $0x8,%esp
f0100e83:	53                   	push   %ebx
f0100e84:	ff 30                	pushl  (%eax)
f0100e86:	ff d6                	call   *%esi
			break;
f0100e88:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e8b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100e8e:	e9 04 ff ff ff       	jmp    f0100d97 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100e93:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e96:	8d 50 04             	lea    0x4(%eax),%edx
f0100e99:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e9c:	8b 00                	mov    (%eax),%eax
f0100e9e:	99                   	cltd   
f0100e9f:	31 d0                	xor    %edx,%eax
f0100ea1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100ea3:	83 f8 06             	cmp    $0x6,%eax
f0100ea6:	7f 0b                	jg     f0100eb3 <vprintfmt+0x142>
f0100ea8:	8b 14 85 f0 1f 10 f0 	mov    -0xfefe010(,%eax,4),%edx
f0100eaf:	85 d2                	test   %edx,%edx
f0100eb1:	75 18                	jne    f0100ecb <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100eb3:	50                   	push   %eax
f0100eb4:	68 21 1e 10 f0       	push   $0xf0101e21
f0100eb9:	53                   	push   %ebx
f0100eba:	56                   	push   %esi
f0100ebb:	e8 94 fe ff ff       	call   f0100d54 <printfmt>
f0100ec0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ec3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100ec6:	e9 cc fe ff ff       	jmp    f0100d97 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100ecb:	52                   	push   %edx
f0100ecc:	68 2a 1e 10 f0       	push   $0xf0101e2a
f0100ed1:	53                   	push   %ebx
f0100ed2:	56                   	push   %esi
f0100ed3:	e8 7c fe ff ff       	call   f0100d54 <printfmt>
f0100ed8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100edb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ede:	e9 b4 fe ff ff       	jmp    f0100d97 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100ee3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ee6:	8d 50 04             	lea    0x4(%eax),%edx
f0100ee9:	89 55 14             	mov    %edx,0x14(%ebp)
f0100eec:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100eee:	85 ff                	test   %edi,%edi
f0100ef0:	b8 1a 1e 10 f0       	mov    $0xf0101e1a,%eax
f0100ef5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100ef8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100efc:	0f 8e 94 00 00 00    	jle    f0100f96 <vprintfmt+0x225>
f0100f02:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f06:	0f 84 98 00 00 00    	je     f0100fa4 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f0c:	83 ec 08             	sub    $0x8,%esp
f0100f0f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f12:	57                   	push   %edi
f0100f13:	e8 5f 03 00 00       	call   f0101277 <strnlen>
f0100f18:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f1b:	29 c1                	sub    %eax,%ecx
f0100f1d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100f20:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100f23:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100f27:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f2a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100f2d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f2f:	eb 0f                	jmp    f0100f40 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0100f31:	83 ec 08             	sub    $0x8,%esp
f0100f34:	53                   	push   %ebx
f0100f35:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f38:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f3a:	83 ef 01             	sub    $0x1,%edi
f0100f3d:	83 c4 10             	add    $0x10,%esp
f0100f40:	85 ff                	test   %edi,%edi
f0100f42:	7f ed                	jg     f0100f31 <vprintfmt+0x1c0>
f0100f44:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100f47:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100f4a:	85 c9                	test   %ecx,%ecx
f0100f4c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f51:	0f 49 c1             	cmovns %ecx,%eax
f0100f54:	29 c1                	sub    %eax,%ecx
f0100f56:	89 75 08             	mov    %esi,0x8(%ebp)
f0100f59:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100f5c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100f5f:	89 cb                	mov    %ecx,%ebx
f0100f61:	eb 4d                	jmp    f0100fb0 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100f63:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100f67:	74 1b                	je     f0100f84 <vprintfmt+0x213>
f0100f69:	0f be c0             	movsbl %al,%eax
f0100f6c:	83 e8 20             	sub    $0x20,%eax
f0100f6f:	83 f8 5e             	cmp    $0x5e,%eax
f0100f72:	76 10                	jbe    f0100f84 <vprintfmt+0x213>
					putch('?', putdat);
f0100f74:	83 ec 08             	sub    $0x8,%esp
f0100f77:	ff 75 0c             	pushl  0xc(%ebp)
f0100f7a:	6a 3f                	push   $0x3f
f0100f7c:	ff 55 08             	call   *0x8(%ebp)
f0100f7f:	83 c4 10             	add    $0x10,%esp
f0100f82:	eb 0d                	jmp    f0100f91 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0100f84:	83 ec 08             	sub    $0x8,%esp
f0100f87:	ff 75 0c             	pushl  0xc(%ebp)
f0100f8a:	52                   	push   %edx
f0100f8b:	ff 55 08             	call   *0x8(%ebp)
f0100f8e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f91:	83 eb 01             	sub    $0x1,%ebx
f0100f94:	eb 1a                	jmp    f0100fb0 <vprintfmt+0x23f>
f0100f96:	89 75 08             	mov    %esi,0x8(%ebp)
f0100f99:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100f9c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100f9f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100fa2:	eb 0c                	jmp    f0100fb0 <vprintfmt+0x23f>
f0100fa4:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fa7:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100faa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fad:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100fb0:	83 c7 01             	add    $0x1,%edi
f0100fb3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100fb7:	0f be d0             	movsbl %al,%edx
f0100fba:	85 d2                	test   %edx,%edx
f0100fbc:	74 23                	je     f0100fe1 <vprintfmt+0x270>
f0100fbe:	85 f6                	test   %esi,%esi
f0100fc0:	78 a1                	js     f0100f63 <vprintfmt+0x1f2>
f0100fc2:	83 ee 01             	sub    $0x1,%esi
f0100fc5:	79 9c                	jns    f0100f63 <vprintfmt+0x1f2>
f0100fc7:	89 df                	mov    %ebx,%edi
f0100fc9:	8b 75 08             	mov    0x8(%ebp),%esi
f0100fcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100fcf:	eb 18                	jmp    f0100fe9 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100fd1:	83 ec 08             	sub    $0x8,%esp
f0100fd4:	53                   	push   %ebx
f0100fd5:	6a 20                	push   $0x20
f0100fd7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100fd9:	83 ef 01             	sub    $0x1,%edi
f0100fdc:	83 c4 10             	add    $0x10,%esp
f0100fdf:	eb 08                	jmp    f0100fe9 <vprintfmt+0x278>
f0100fe1:	89 df                	mov    %ebx,%edi
f0100fe3:	8b 75 08             	mov    0x8(%ebp),%esi
f0100fe6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100fe9:	85 ff                	test   %edi,%edi
f0100feb:	7f e4                	jg     f0100fd1 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ff0:	e9 a2 fd ff ff       	jmp    f0100d97 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100ff5:	83 fa 01             	cmp    $0x1,%edx
f0100ff8:	7e 16                	jle    f0101010 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0100ffa:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ffd:	8d 50 08             	lea    0x8(%eax),%edx
f0101000:	89 55 14             	mov    %edx,0x14(%ebp)
f0101003:	8b 50 04             	mov    0x4(%eax),%edx
f0101006:	8b 00                	mov    (%eax),%eax
f0101008:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010100b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010100e:	eb 32                	jmp    f0101042 <vprintfmt+0x2d1>
	else if (lflag)
f0101010:	85 d2                	test   %edx,%edx
f0101012:	74 18                	je     f010102c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0101014:	8b 45 14             	mov    0x14(%ebp),%eax
f0101017:	8d 50 04             	lea    0x4(%eax),%edx
f010101a:	89 55 14             	mov    %edx,0x14(%ebp)
f010101d:	8b 00                	mov    (%eax),%eax
f010101f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101022:	89 c1                	mov    %eax,%ecx
f0101024:	c1 f9 1f             	sar    $0x1f,%ecx
f0101027:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010102a:	eb 16                	jmp    f0101042 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f010102c:	8b 45 14             	mov    0x14(%ebp),%eax
f010102f:	8d 50 04             	lea    0x4(%eax),%edx
f0101032:	89 55 14             	mov    %edx,0x14(%ebp)
f0101035:	8b 00                	mov    (%eax),%eax
f0101037:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010103a:	89 c1                	mov    %eax,%ecx
f010103c:	c1 f9 1f             	sar    $0x1f,%ecx
f010103f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101042:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101045:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101048:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010104d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101051:	79 74                	jns    f01010c7 <vprintfmt+0x356>
				putch('-', putdat);
f0101053:	83 ec 08             	sub    $0x8,%esp
f0101056:	53                   	push   %ebx
f0101057:	6a 2d                	push   $0x2d
f0101059:	ff d6                	call   *%esi
				num = -(long long) num;
f010105b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010105e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101061:	f7 d8                	neg    %eax
f0101063:	83 d2 00             	adc    $0x0,%edx
f0101066:	f7 da                	neg    %edx
f0101068:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010106b:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101070:	eb 55                	jmp    f01010c7 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101072:	8d 45 14             	lea    0x14(%ebp),%eax
f0101075:	e8 83 fc ff ff       	call   f0100cfd <getuint>
			base = 10;
f010107a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010107f:	eb 46                	jmp    f01010c7 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0101081:	8d 45 14             	lea    0x14(%ebp),%eax
f0101084:	e8 74 fc ff ff       	call   f0100cfd <getuint>
			base = 8;
f0101089:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f010108e:	eb 37                	jmp    f01010c7 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0101090:	83 ec 08             	sub    $0x8,%esp
f0101093:	53                   	push   %ebx
f0101094:	6a 30                	push   $0x30
f0101096:	ff d6                	call   *%esi
			putch('x', putdat);
f0101098:	83 c4 08             	add    $0x8,%esp
f010109b:	53                   	push   %ebx
f010109c:	6a 78                	push   $0x78
f010109e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01010a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a3:	8d 50 04             	lea    0x4(%eax),%edx
f01010a6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01010a9:	8b 00                	mov    (%eax),%eax
f01010ab:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01010b0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01010b3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01010b8:	eb 0d                	jmp    f01010c7 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01010ba:	8d 45 14             	lea    0x14(%ebp),%eax
f01010bd:	e8 3b fc ff ff       	call   f0100cfd <getuint>
			base = 16;
f01010c2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01010c7:	83 ec 0c             	sub    $0xc,%esp
f01010ca:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01010ce:	57                   	push   %edi
f01010cf:	ff 75 e0             	pushl  -0x20(%ebp)
f01010d2:	51                   	push   %ecx
f01010d3:	52                   	push   %edx
f01010d4:	50                   	push   %eax
f01010d5:	89 da                	mov    %ebx,%edx
f01010d7:	89 f0                	mov    %esi,%eax
f01010d9:	e8 70 fb ff ff       	call   f0100c4e <printnum>
			break;
f01010de:	83 c4 20             	add    $0x20,%esp
f01010e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01010e4:	e9 ae fc ff ff       	jmp    f0100d97 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01010e9:	83 ec 08             	sub    $0x8,%esp
f01010ec:	53                   	push   %ebx
f01010ed:	51                   	push   %ecx
f01010ee:	ff d6                	call   *%esi
			break;
f01010f0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01010f6:	e9 9c fc ff ff       	jmp    f0100d97 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01010fb:	83 ec 08             	sub    $0x8,%esp
f01010fe:	53                   	push   %ebx
f01010ff:	6a 25                	push   $0x25
f0101101:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101103:	83 c4 10             	add    $0x10,%esp
f0101106:	eb 03                	jmp    f010110b <vprintfmt+0x39a>
f0101108:	83 ef 01             	sub    $0x1,%edi
f010110b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010110f:	75 f7                	jne    f0101108 <vprintfmt+0x397>
f0101111:	e9 81 fc ff ff       	jmp    f0100d97 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101116:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101119:	5b                   	pop    %ebx
f010111a:	5e                   	pop    %esi
f010111b:	5f                   	pop    %edi
f010111c:	5d                   	pop    %ebp
f010111d:	c3                   	ret    

f010111e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010111e:	55                   	push   %ebp
f010111f:	89 e5                	mov    %esp,%ebp
f0101121:	83 ec 18             	sub    $0x18,%esp
f0101124:	8b 45 08             	mov    0x8(%ebp),%eax
f0101127:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010112a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010112d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101131:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101134:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010113b:	85 c0                	test   %eax,%eax
f010113d:	74 26                	je     f0101165 <vsnprintf+0x47>
f010113f:	85 d2                	test   %edx,%edx
f0101141:	7e 22                	jle    f0101165 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101143:	ff 75 14             	pushl  0x14(%ebp)
f0101146:	ff 75 10             	pushl  0x10(%ebp)
f0101149:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010114c:	50                   	push   %eax
f010114d:	68 37 0d 10 f0       	push   $0xf0100d37
f0101152:	e8 1a fc ff ff       	call   f0100d71 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101157:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010115a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010115d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101160:	83 c4 10             	add    $0x10,%esp
f0101163:	eb 05                	jmp    f010116a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101165:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010116a:	c9                   	leave  
f010116b:	c3                   	ret    

f010116c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010116c:	55                   	push   %ebp
f010116d:	89 e5                	mov    %esp,%ebp
f010116f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101172:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101175:	50                   	push   %eax
f0101176:	ff 75 10             	pushl  0x10(%ebp)
f0101179:	ff 75 0c             	pushl  0xc(%ebp)
f010117c:	ff 75 08             	pushl  0x8(%ebp)
f010117f:	e8 9a ff ff ff       	call   f010111e <vsnprintf>
	va_end(ap);

	return rc;
}
f0101184:	c9                   	leave  
f0101185:	c3                   	ret    

f0101186 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101186:	55                   	push   %ebp
f0101187:	89 e5                	mov    %esp,%ebp
f0101189:	57                   	push   %edi
f010118a:	56                   	push   %esi
f010118b:	53                   	push   %ebx
f010118c:	83 ec 0c             	sub    $0xc,%esp
f010118f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101192:	85 c0                	test   %eax,%eax
f0101194:	74 11                	je     f01011a7 <readline+0x21>
		cprintf("%s", prompt);
f0101196:	83 ec 08             	sub    $0x8,%esp
f0101199:	50                   	push   %eax
f010119a:	68 2a 1e 10 f0       	push   $0xf0101e2a
f010119f:	e8 cf f7 ff ff       	call   f0100973 <cprintf>
f01011a4:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01011a7:	83 ec 0c             	sub    $0xc,%esp
f01011aa:	6a 00                	push   $0x0
f01011ac:	e8 cb f4 ff ff       	call   f010067c <iscons>
f01011b1:	89 c7                	mov    %eax,%edi
f01011b3:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01011b6:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01011bb:	e8 ab f4 ff ff       	call   f010066b <getchar>
f01011c0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01011c2:	85 c0                	test   %eax,%eax
f01011c4:	79 18                	jns    f01011de <readline+0x58>
			cprintf("read error: %e\n", c);
f01011c6:	83 ec 08             	sub    $0x8,%esp
f01011c9:	50                   	push   %eax
f01011ca:	68 0c 20 10 f0       	push   $0xf010200c
f01011cf:	e8 9f f7 ff ff       	call   f0100973 <cprintf>
			return NULL;
f01011d4:	83 c4 10             	add    $0x10,%esp
f01011d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01011dc:	eb 79                	jmp    f0101257 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01011de:	83 f8 08             	cmp    $0x8,%eax
f01011e1:	0f 94 c2             	sete   %dl
f01011e4:	83 f8 7f             	cmp    $0x7f,%eax
f01011e7:	0f 94 c0             	sete   %al
f01011ea:	08 c2                	or     %al,%dl
f01011ec:	74 1a                	je     f0101208 <readline+0x82>
f01011ee:	85 f6                	test   %esi,%esi
f01011f0:	7e 16                	jle    f0101208 <readline+0x82>
			if (echoing)
f01011f2:	85 ff                	test   %edi,%edi
f01011f4:	74 0d                	je     f0101203 <readline+0x7d>
				cputchar('\b');
f01011f6:	83 ec 0c             	sub    $0xc,%esp
f01011f9:	6a 08                	push   $0x8
f01011fb:	e8 5b f4 ff ff       	call   f010065b <cputchar>
f0101200:	83 c4 10             	add    $0x10,%esp
			i--;
f0101203:	83 ee 01             	sub    $0x1,%esi
f0101206:	eb b3                	jmp    f01011bb <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101208:	83 fb 1f             	cmp    $0x1f,%ebx
f010120b:	7e 23                	jle    f0101230 <readline+0xaa>
f010120d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101213:	7f 1b                	jg     f0101230 <readline+0xaa>
			if (echoing)
f0101215:	85 ff                	test   %edi,%edi
f0101217:	74 0c                	je     f0101225 <readline+0x9f>
				cputchar(c);
f0101219:	83 ec 0c             	sub    $0xc,%esp
f010121c:	53                   	push   %ebx
f010121d:	e8 39 f4 ff ff       	call   f010065b <cputchar>
f0101222:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101225:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f010122b:	8d 76 01             	lea    0x1(%esi),%esi
f010122e:	eb 8b                	jmp    f01011bb <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101230:	83 fb 0a             	cmp    $0xa,%ebx
f0101233:	74 05                	je     f010123a <readline+0xb4>
f0101235:	83 fb 0d             	cmp    $0xd,%ebx
f0101238:	75 81                	jne    f01011bb <readline+0x35>
			if (echoing)
f010123a:	85 ff                	test   %edi,%edi
f010123c:	74 0d                	je     f010124b <readline+0xc5>
				cputchar('\n');
f010123e:	83 ec 0c             	sub    $0xc,%esp
f0101241:	6a 0a                	push   $0xa
f0101243:	e8 13 f4 ff ff       	call   f010065b <cputchar>
f0101248:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010124b:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f0101252:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f0101257:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010125a:	5b                   	pop    %ebx
f010125b:	5e                   	pop    %esi
f010125c:	5f                   	pop    %edi
f010125d:	5d                   	pop    %ebp
f010125e:	c3                   	ret    

f010125f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010125f:	55                   	push   %ebp
f0101260:	89 e5                	mov    %esp,%ebp
f0101262:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101265:	b8 00 00 00 00       	mov    $0x0,%eax
f010126a:	eb 03                	jmp    f010126f <strlen+0x10>
		n++;
f010126c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010126f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101273:	75 f7                	jne    f010126c <strlen+0xd>
		n++;
	return n;
}
f0101275:	5d                   	pop    %ebp
f0101276:	c3                   	ret    

f0101277 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101277:	55                   	push   %ebp
f0101278:	89 e5                	mov    %esp,%ebp
f010127a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010127d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101280:	ba 00 00 00 00       	mov    $0x0,%edx
f0101285:	eb 03                	jmp    f010128a <strnlen+0x13>
		n++;
f0101287:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010128a:	39 c2                	cmp    %eax,%edx
f010128c:	74 08                	je     f0101296 <strnlen+0x1f>
f010128e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101292:	75 f3                	jne    f0101287 <strnlen+0x10>
f0101294:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0101296:	5d                   	pop    %ebp
f0101297:	c3                   	ret    

f0101298 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101298:	55                   	push   %ebp
f0101299:	89 e5                	mov    %esp,%ebp
f010129b:	53                   	push   %ebx
f010129c:	8b 45 08             	mov    0x8(%ebp),%eax
f010129f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01012a2:	89 c2                	mov    %eax,%edx
f01012a4:	83 c2 01             	add    $0x1,%edx
f01012a7:	83 c1 01             	add    $0x1,%ecx
f01012aa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01012ae:	88 5a ff             	mov    %bl,-0x1(%edx)
f01012b1:	84 db                	test   %bl,%bl
f01012b3:	75 ef                	jne    f01012a4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01012b5:	5b                   	pop    %ebx
f01012b6:	5d                   	pop    %ebp
f01012b7:	c3                   	ret    

f01012b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01012b8:	55                   	push   %ebp
f01012b9:	89 e5                	mov    %esp,%ebp
f01012bb:	53                   	push   %ebx
f01012bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01012bf:	53                   	push   %ebx
f01012c0:	e8 9a ff ff ff       	call   f010125f <strlen>
f01012c5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01012c8:	ff 75 0c             	pushl  0xc(%ebp)
f01012cb:	01 d8                	add    %ebx,%eax
f01012cd:	50                   	push   %eax
f01012ce:	e8 c5 ff ff ff       	call   f0101298 <strcpy>
	return dst;
}
f01012d3:	89 d8                	mov    %ebx,%eax
f01012d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012d8:	c9                   	leave  
f01012d9:	c3                   	ret    

f01012da <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01012da:	55                   	push   %ebp
f01012db:	89 e5                	mov    %esp,%ebp
f01012dd:	56                   	push   %esi
f01012de:	53                   	push   %ebx
f01012df:	8b 75 08             	mov    0x8(%ebp),%esi
f01012e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01012e5:	89 f3                	mov    %esi,%ebx
f01012e7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01012ea:	89 f2                	mov    %esi,%edx
f01012ec:	eb 0f                	jmp    f01012fd <strncpy+0x23>
		*dst++ = *src;
f01012ee:	83 c2 01             	add    $0x1,%edx
f01012f1:	0f b6 01             	movzbl (%ecx),%eax
f01012f4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01012f7:	80 39 01             	cmpb   $0x1,(%ecx)
f01012fa:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01012fd:	39 da                	cmp    %ebx,%edx
f01012ff:	75 ed                	jne    f01012ee <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101301:	89 f0                	mov    %esi,%eax
f0101303:	5b                   	pop    %ebx
f0101304:	5e                   	pop    %esi
f0101305:	5d                   	pop    %ebp
f0101306:	c3                   	ret    

f0101307 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101307:	55                   	push   %ebp
f0101308:	89 e5                	mov    %esp,%ebp
f010130a:	56                   	push   %esi
f010130b:	53                   	push   %ebx
f010130c:	8b 75 08             	mov    0x8(%ebp),%esi
f010130f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101312:	8b 55 10             	mov    0x10(%ebp),%edx
f0101315:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101317:	85 d2                	test   %edx,%edx
f0101319:	74 21                	je     f010133c <strlcpy+0x35>
f010131b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010131f:	89 f2                	mov    %esi,%edx
f0101321:	eb 09                	jmp    f010132c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101323:	83 c2 01             	add    $0x1,%edx
f0101326:	83 c1 01             	add    $0x1,%ecx
f0101329:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010132c:	39 c2                	cmp    %eax,%edx
f010132e:	74 09                	je     f0101339 <strlcpy+0x32>
f0101330:	0f b6 19             	movzbl (%ecx),%ebx
f0101333:	84 db                	test   %bl,%bl
f0101335:	75 ec                	jne    f0101323 <strlcpy+0x1c>
f0101337:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101339:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010133c:	29 f0                	sub    %esi,%eax
}
f010133e:	5b                   	pop    %ebx
f010133f:	5e                   	pop    %esi
f0101340:	5d                   	pop    %ebp
f0101341:	c3                   	ret    

f0101342 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101342:	55                   	push   %ebp
f0101343:	89 e5                	mov    %esp,%ebp
f0101345:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101348:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010134b:	eb 06                	jmp    f0101353 <strcmp+0x11>
		p++, q++;
f010134d:	83 c1 01             	add    $0x1,%ecx
f0101350:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101353:	0f b6 01             	movzbl (%ecx),%eax
f0101356:	84 c0                	test   %al,%al
f0101358:	74 04                	je     f010135e <strcmp+0x1c>
f010135a:	3a 02                	cmp    (%edx),%al
f010135c:	74 ef                	je     f010134d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010135e:	0f b6 c0             	movzbl %al,%eax
f0101361:	0f b6 12             	movzbl (%edx),%edx
f0101364:	29 d0                	sub    %edx,%eax
}
f0101366:	5d                   	pop    %ebp
f0101367:	c3                   	ret    

f0101368 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101368:	55                   	push   %ebp
f0101369:	89 e5                	mov    %esp,%ebp
f010136b:	53                   	push   %ebx
f010136c:	8b 45 08             	mov    0x8(%ebp),%eax
f010136f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101372:	89 c3                	mov    %eax,%ebx
f0101374:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101377:	eb 06                	jmp    f010137f <strncmp+0x17>
		n--, p++, q++;
f0101379:	83 c0 01             	add    $0x1,%eax
f010137c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010137f:	39 d8                	cmp    %ebx,%eax
f0101381:	74 15                	je     f0101398 <strncmp+0x30>
f0101383:	0f b6 08             	movzbl (%eax),%ecx
f0101386:	84 c9                	test   %cl,%cl
f0101388:	74 04                	je     f010138e <strncmp+0x26>
f010138a:	3a 0a                	cmp    (%edx),%cl
f010138c:	74 eb                	je     f0101379 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010138e:	0f b6 00             	movzbl (%eax),%eax
f0101391:	0f b6 12             	movzbl (%edx),%edx
f0101394:	29 d0                	sub    %edx,%eax
f0101396:	eb 05                	jmp    f010139d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101398:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010139d:	5b                   	pop    %ebx
f010139e:	5d                   	pop    %ebp
f010139f:	c3                   	ret    

f01013a0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01013a0:	55                   	push   %ebp
f01013a1:	89 e5                	mov    %esp,%ebp
f01013a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01013a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01013aa:	eb 07                	jmp    f01013b3 <strchr+0x13>
		if (*s == c)
f01013ac:	38 ca                	cmp    %cl,%dl
f01013ae:	74 0f                	je     f01013bf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01013b0:	83 c0 01             	add    $0x1,%eax
f01013b3:	0f b6 10             	movzbl (%eax),%edx
f01013b6:	84 d2                	test   %dl,%dl
f01013b8:	75 f2                	jne    f01013ac <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01013ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013bf:	5d                   	pop    %ebp
f01013c0:	c3                   	ret    

f01013c1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01013c1:	55                   	push   %ebp
f01013c2:	89 e5                	mov    %esp,%ebp
f01013c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01013c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01013cb:	eb 03                	jmp    f01013d0 <strfind+0xf>
f01013cd:	83 c0 01             	add    $0x1,%eax
f01013d0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01013d3:	38 ca                	cmp    %cl,%dl
f01013d5:	74 04                	je     f01013db <strfind+0x1a>
f01013d7:	84 d2                	test   %dl,%dl
f01013d9:	75 f2                	jne    f01013cd <strfind+0xc>
			break;
	return (char *) s;
}
f01013db:	5d                   	pop    %ebp
f01013dc:	c3                   	ret    

f01013dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01013dd:	55                   	push   %ebp
f01013de:	89 e5                	mov    %esp,%ebp
f01013e0:	57                   	push   %edi
f01013e1:	56                   	push   %esi
f01013e2:	53                   	push   %ebx
f01013e3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01013e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01013e9:	85 c9                	test   %ecx,%ecx
f01013eb:	74 36                	je     f0101423 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01013ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01013f3:	75 28                	jne    f010141d <memset+0x40>
f01013f5:	f6 c1 03             	test   $0x3,%cl
f01013f8:	75 23                	jne    f010141d <memset+0x40>
		c &= 0xFF;
f01013fa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01013fe:	89 d3                	mov    %edx,%ebx
f0101400:	c1 e3 08             	shl    $0x8,%ebx
f0101403:	89 d6                	mov    %edx,%esi
f0101405:	c1 e6 18             	shl    $0x18,%esi
f0101408:	89 d0                	mov    %edx,%eax
f010140a:	c1 e0 10             	shl    $0x10,%eax
f010140d:	09 f0                	or     %esi,%eax
f010140f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0101411:	89 d8                	mov    %ebx,%eax
f0101413:	09 d0                	or     %edx,%eax
f0101415:	c1 e9 02             	shr    $0x2,%ecx
f0101418:	fc                   	cld    
f0101419:	f3 ab                	rep stos %eax,%es:(%edi)
f010141b:	eb 06                	jmp    f0101423 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010141d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101420:	fc                   	cld    
f0101421:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101423:	89 f8                	mov    %edi,%eax
f0101425:	5b                   	pop    %ebx
f0101426:	5e                   	pop    %esi
f0101427:	5f                   	pop    %edi
f0101428:	5d                   	pop    %ebp
f0101429:	c3                   	ret    

f010142a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010142a:	55                   	push   %ebp
f010142b:	89 e5                	mov    %esp,%ebp
f010142d:	57                   	push   %edi
f010142e:	56                   	push   %esi
f010142f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101432:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101435:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101438:	39 c6                	cmp    %eax,%esi
f010143a:	73 35                	jae    f0101471 <memmove+0x47>
f010143c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010143f:	39 d0                	cmp    %edx,%eax
f0101441:	73 2e                	jae    f0101471 <memmove+0x47>
		s += n;
		d += n;
f0101443:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101446:	89 d6                	mov    %edx,%esi
f0101448:	09 fe                	or     %edi,%esi
f010144a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101450:	75 13                	jne    f0101465 <memmove+0x3b>
f0101452:	f6 c1 03             	test   $0x3,%cl
f0101455:	75 0e                	jne    f0101465 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0101457:	83 ef 04             	sub    $0x4,%edi
f010145a:	8d 72 fc             	lea    -0x4(%edx),%esi
f010145d:	c1 e9 02             	shr    $0x2,%ecx
f0101460:	fd                   	std    
f0101461:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101463:	eb 09                	jmp    f010146e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101465:	83 ef 01             	sub    $0x1,%edi
f0101468:	8d 72 ff             	lea    -0x1(%edx),%esi
f010146b:	fd                   	std    
f010146c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010146e:	fc                   	cld    
f010146f:	eb 1d                	jmp    f010148e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101471:	89 f2                	mov    %esi,%edx
f0101473:	09 c2                	or     %eax,%edx
f0101475:	f6 c2 03             	test   $0x3,%dl
f0101478:	75 0f                	jne    f0101489 <memmove+0x5f>
f010147a:	f6 c1 03             	test   $0x3,%cl
f010147d:	75 0a                	jne    f0101489 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010147f:	c1 e9 02             	shr    $0x2,%ecx
f0101482:	89 c7                	mov    %eax,%edi
f0101484:	fc                   	cld    
f0101485:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101487:	eb 05                	jmp    f010148e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101489:	89 c7                	mov    %eax,%edi
f010148b:	fc                   	cld    
f010148c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010148e:	5e                   	pop    %esi
f010148f:	5f                   	pop    %edi
f0101490:	5d                   	pop    %ebp
f0101491:	c3                   	ret    

f0101492 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101492:	55                   	push   %ebp
f0101493:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101495:	ff 75 10             	pushl  0x10(%ebp)
f0101498:	ff 75 0c             	pushl  0xc(%ebp)
f010149b:	ff 75 08             	pushl  0x8(%ebp)
f010149e:	e8 87 ff ff ff       	call   f010142a <memmove>
}
f01014a3:	c9                   	leave  
f01014a4:	c3                   	ret    

f01014a5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01014a5:	55                   	push   %ebp
f01014a6:	89 e5                	mov    %esp,%ebp
f01014a8:	56                   	push   %esi
f01014a9:	53                   	push   %ebx
f01014aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01014ad:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014b0:	89 c6                	mov    %eax,%esi
f01014b2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014b5:	eb 1a                	jmp    f01014d1 <memcmp+0x2c>
		if (*s1 != *s2)
f01014b7:	0f b6 08             	movzbl (%eax),%ecx
f01014ba:	0f b6 1a             	movzbl (%edx),%ebx
f01014bd:	38 d9                	cmp    %bl,%cl
f01014bf:	74 0a                	je     f01014cb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01014c1:	0f b6 c1             	movzbl %cl,%eax
f01014c4:	0f b6 db             	movzbl %bl,%ebx
f01014c7:	29 d8                	sub    %ebx,%eax
f01014c9:	eb 0f                	jmp    f01014da <memcmp+0x35>
		s1++, s2++;
f01014cb:	83 c0 01             	add    $0x1,%eax
f01014ce:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014d1:	39 f0                	cmp    %esi,%eax
f01014d3:	75 e2                	jne    f01014b7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01014d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014da:	5b                   	pop    %ebx
f01014db:	5e                   	pop    %esi
f01014dc:	5d                   	pop    %ebp
f01014dd:	c3                   	ret    

f01014de <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01014de:	55                   	push   %ebp
f01014df:	89 e5                	mov    %esp,%ebp
f01014e1:	53                   	push   %ebx
f01014e2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01014e5:	89 c1                	mov    %eax,%ecx
f01014e7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01014ea:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01014ee:	eb 0a                	jmp    f01014fa <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01014f0:	0f b6 10             	movzbl (%eax),%edx
f01014f3:	39 da                	cmp    %ebx,%edx
f01014f5:	74 07                	je     f01014fe <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01014f7:	83 c0 01             	add    $0x1,%eax
f01014fa:	39 c8                	cmp    %ecx,%eax
f01014fc:	72 f2                	jb     f01014f0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01014fe:	5b                   	pop    %ebx
f01014ff:	5d                   	pop    %ebp
f0101500:	c3                   	ret    

f0101501 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101501:	55                   	push   %ebp
f0101502:	89 e5                	mov    %esp,%ebp
f0101504:	57                   	push   %edi
f0101505:	56                   	push   %esi
f0101506:	53                   	push   %ebx
f0101507:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010150a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010150d:	eb 03                	jmp    f0101512 <strtol+0x11>
		s++;
f010150f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101512:	0f b6 01             	movzbl (%ecx),%eax
f0101515:	3c 20                	cmp    $0x20,%al
f0101517:	74 f6                	je     f010150f <strtol+0xe>
f0101519:	3c 09                	cmp    $0x9,%al
f010151b:	74 f2                	je     f010150f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010151d:	3c 2b                	cmp    $0x2b,%al
f010151f:	75 0a                	jne    f010152b <strtol+0x2a>
		s++;
f0101521:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101524:	bf 00 00 00 00       	mov    $0x0,%edi
f0101529:	eb 11                	jmp    f010153c <strtol+0x3b>
f010152b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101530:	3c 2d                	cmp    $0x2d,%al
f0101532:	75 08                	jne    f010153c <strtol+0x3b>
		s++, neg = 1;
f0101534:	83 c1 01             	add    $0x1,%ecx
f0101537:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010153c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101542:	75 15                	jne    f0101559 <strtol+0x58>
f0101544:	80 39 30             	cmpb   $0x30,(%ecx)
f0101547:	75 10                	jne    f0101559 <strtol+0x58>
f0101549:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010154d:	75 7c                	jne    f01015cb <strtol+0xca>
		s += 2, base = 16;
f010154f:	83 c1 02             	add    $0x2,%ecx
f0101552:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101557:	eb 16                	jmp    f010156f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0101559:	85 db                	test   %ebx,%ebx
f010155b:	75 12                	jne    f010156f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010155d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101562:	80 39 30             	cmpb   $0x30,(%ecx)
f0101565:	75 08                	jne    f010156f <strtol+0x6e>
		s++, base = 8;
f0101567:	83 c1 01             	add    $0x1,%ecx
f010156a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010156f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101574:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101577:	0f b6 11             	movzbl (%ecx),%edx
f010157a:	8d 72 d0             	lea    -0x30(%edx),%esi
f010157d:	89 f3                	mov    %esi,%ebx
f010157f:	80 fb 09             	cmp    $0x9,%bl
f0101582:	77 08                	ja     f010158c <strtol+0x8b>
			dig = *s - '0';
f0101584:	0f be d2             	movsbl %dl,%edx
f0101587:	83 ea 30             	sub    $0x30,%edx
f010158a:	eb 22                	jmp    f01015ae <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010158c:	8d 72 9f             	lea    -0x61(%edx),%esi
f010158f:	89 f3                	mov    %esi,%ebx
f0101591:	80 fb 19             	cmp    $0x19,%bl
f0101594:	77 08                	ja     f010159e <strtol+0x9d>
			dig = *s - 'a' + 10;
f0101596:	0f be d2             	movsbl %dl,%edx
f0101599:	83 ea 57             	sub    $0x57,%edx
f010159c:	eb 10                	jmp    f01015ae <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010159e:	8d 72 bf             	lea    -0x41(%edx),%esi
f01015a1:	89 f3                	mov    %esi,%ebx
f01015a3:	80 fb 19             	cmp    $0x19,%bl
f01015a6:	77 16                	ja     f01015be <strtol+0xbd>
			dig = *s - 'A' + 10;
f01015a8:	0f be d2             	movsbl %dl,%edx
f01015ab:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01015ae:	3b 55 10             	cmp    0x10(%ebp),%edx
f01015b1:	7d 0b                	jge    f01015be <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01015b3:	83 c1 01             	add    $0x1,%ecx
f01015b6:	0f af 45 10          	imul   0x10(%ebp),%eax
f01015ba:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01015bc:	eb b9                	jmp    f0101577 <strtol+0x76>

	if (endptr)
f01015be:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01015c2:	74 0d                	je     f01015d1 <strtol+0xd0>
		*endptr = (char *) s;
f01015c4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015c7:	89 0e                	mov    %ecx,(%esi)
f01015c9:	eb 06                	jmp    f01015d1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015cb:	85 db                	test   %ebx,%ebx
f01015cd:	74 98                	je     f0101567 <strtol+0x66>
f01015cf:	eb 9e                	jmp    f010156f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01015d1:	89 c2                	mov    %eax,%edx
f01015d3:	f7 da                	neg    %edx
f01015d5:	85 ff                	test   %edi,%edi
f01015d7:	0f 45 c2             	cmovne %edx,%eax
}
f01015da:	5b                   	pop    %ebx
f01015db:	5e                   	pop    %esi
f01015dc:	5f                   	pop    %edi
f01015dd:	5d                   	pop    %ebp
f01015de:	c3                   	ret    
f01015df:	90                   	nop

f01015e0 <__udivdi3>:
f01015e0:	55                   	push   %ebp
f01015e1:	57                   	push   %edi
f01015e2:	56                   	push   %esi
f01015e3:	53                   	push   %ebx
f01015e4:	83 ec 1c             	sub    $0x1c,%esp
f01015e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01015eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01015ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01015f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01015f7:	85 f6                	test   %esi,%esi
f01015f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01015fd:	89 ca                	mov    %ecx,%edx
f01015ff:	89 f8                	mov    %edi,%eax
f0101601:	75 3d                	jne    f0101640 <__udivdi3+0x60>
f0101603:	39 cf                	cmp    %ecx,%edi
f0101605:	0f 87 c5 00 00 00    	ja     f01016d0 <__udivdi3+0xf0>
f010160b:	85 ff                	test   %edi,%edi
f010160d:	89 fd                	mov    %edi,%ebp
f010160f:	75 0b                	jne    f010161c <__udivdi3+0x3c>
f0101611:	b8 01 00 00 00       	mov    $0x1,%eax
f0101616:	31 d2                	xor    %edx,%edx
f0101618:	f7 f7                	div    %edi
f010161a:	89 c5                	mov    %eax,%ebp
f010161c:	89 c8                	mov    %ecx,%eax
f010161e:	31 d2                	xor    %edx,%edx
f0101620:	f7 f5                	div    %ebp
f0101622:	89 c1                	mov    %eax,%ecx
f0101624:	89 d8                	mov    %ebx,%eax
f0101626:	89 cf                	mov    %ecx,%edi
f0101628:	f7 f5                	div    %ebp
f010162a:	89 c3                	mov    %eax,%ebx
f010162c:	89 d8                	mov    %ebx,%eax
f010162e:	89 fa                	mov    %edi,%edx
f0101630:	83 c4 1c             	add    $0x1c,%esp
f0101633:	5b                   	pop    %ebx
f0101634:	5e                   	pop    %esi
f0101635:	5f                   	pop    %edi
f0101636:	5d                   	pop    %ebp
f0101637:	c3                   	ret    
f0101638:	90                   	nop
f0101639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101640:	39 ce                	cmp    %ecx,%esi
f0101642:	77 74                	ja     f01016b8 <__udivdi3+0xd8>
f0101644:	0f bd fe             	bsr    %esi,%edi
f0101647:	83 f7 1f             	xor    $0x1f,%edi
f010164a:	0f 84 98 00 00 00    	je     f01016e8 <__udivdi3+0x108>
f0101650:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101655:	89 f9                	mov    %edi,%ecx
f0101657:	89 c5                	mov    %eax,%ebp
f0101659:	29 fb                	sub    %edi,%ebx
f010165b:	d3 e6                	shl    %cl,%esi
f010165d:	89 d9                	mov    %ebx,%ecx
f010165f:	d3 ed                	shr    %cl,%ebp
f0101661:	89 f9                	mov    %edi,%ecx
f0101663:	d3 e0                	shl    %cl,%eax
f0101665:	09 ee                	or     %ebp,%esi
f0101667:	89 d9                	mov    %ebx,%ecx
f0101669:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010166d:	89 d5                	mov    %edx,%ebp
f010166f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101673:	d3 ed                	shr    %cl,%ebp
f0101675:	89 f9                	mov    %edi,%ecx
f0101677:	d3 e2                	shl    %cl,%edx
f0101679:	89 d9                	mov    %ebx,%ecx
f010167b:	d3 e8                	shr    %cl,%eax
f010167d:	09 c2                	or     %eax,%edx
f010167f:	89 d0                	mov    %edx,%eax
f0101681:	89 ea                	mov    %ebp,%edx
f0101683:	f7 f6                	div    %esi
f0101685:	89 d5                	mov    %edx,%ebp
f0101687:	89 c3                	mov    %eax,%ebx
f0101689:	f7 64 24 0c          	mull   0xc(%esp)
f010168d:	39 d5                	cmp    %edx,%ebp
f010168f:	72 10                	jb     f01016a1 <__udivdi3+0xc1>
f0101691:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101695:	89 f9                	mov    %edi,%ecx
f0101697:	d3 e6                	shl    %cl,%esi
f0101699:	39 c6                	cmp    %eax,%esi
f010169b:	73 07                	jae    f01016a4 <__udivdi3+0xc4>
f010169d:	39 d5                	cmp    %edx,%ebp
f010169f:	75 03                	jne    f01016a4 <__udivdi3+0xc4>
f01016a1:	83 eb 01             	sub    $0x1,%ebx
f01016a4:	31 ff                	xor    %edi,%edi
f01016a6:	89 d8                	mov    %ebx,%eax
f01016a8:	89 fa                	mov    %edi,%edx
f01016aa:	83 c4 1c             	add    $0x1c,%esp
f01016ad:	5b                   	pop    %ebx
f01016ae:	5e                   	pop    %esi
f01016af:	5f                   	pop    %edi
f01016b0:	5d                   	pop    %ebp
f01016b1:	c3                   	ret    
f01016b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01016b8:	31 ff                	xor    %edi,%edi
f01016ba:	31 db                	xor    %ebx,%ebx
f01016bc:	89 d8                	mov    %ebx,%eax
f01016be:	89 fa                	mov    %edi,%edx
f01016c0:	83 c4 1c             	add    $0x1c,%esp
f01016c3:	5b                   	pop    %ebx
f01016c4:	5e                   	pop    %esi
f01016c5:	5f                   	pop    %edi
f01016c6:	5d                   	pop    %ebp
f01016c7:	c3                   	ret    
f01016c8:	90                   	nop
f01016c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016d0:	89 d8                	mov    %ebx,%eax
f01016d2:	f7 f7                	div    %edi
f01016d4:	31 ff                	xor    %edi,%edi
f01016d6:	89 c3                	mov    %eax,%ebx
f01016d8:	89 d8                	mov    %ebx,%eax
f01016da:	89 fa                	mov    %edi,%edx
f01016dc:	83 c4 1c             	add    $0x1c,%esp
f01016df:	5b                   	pop    %ebx
f01016e0:	5e                   	pop    %esi
f01016e1:	5f                   	pop    %edi
f01016e2:	5d                   	pop    %ebp
f01016e3:	c3                   	ret    
f01016e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01016e8:	39 ce                	cmp    %ecx,%esi
f01016ea:	72 0c                	jb     f01016f8 <__udivdi3+0x118>
f01016ec:	31 db                	xor    %ebx,%ebx
f01016ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01016f2:	0f 87 34 ff ff ff    	ja     f010162c <__udivdi3+0x4c>
f01016f8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01016fd:	e9 2a ff ff ff       	jmp    f010162c <__udivdi3+0x4c>
f0101702:	66 90                	xchg   %ax,%ax
f0101704:	66 90                	xchg   %ax,%ax
f0101706:	66 90                	xchg   %ax,%ax
f0101708:	66 90                	xchg   %ax,%ax
f010170a:	66 90                	xchg   %ax,%ax
f010170c:	66 90                	xchg   %ax,%ax
f010170e:	66 90                	xchg   %ax,%ax

f0101710 <__umoddi3>:
f0101710:	55                   	push   %ebp
f0101711:	57                   	push   %edi
f0101712:	56                   	push   %esi
f0101713:	53                   	push   %ebx
f0101714:	83 ec 1c             	sub    $0x1c,%esp
f0101717:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010171b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010171f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101723:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101727:	85 d2                	test   %edx,%edx
f0101729:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010172d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101731:	89 f3                	mov    %esi,%ebx
f0101733:	89 3c 24             	mov    %edi,(%esp)
f0101736:	89 74 24 04          	mov    %esi,0x4(%esp)
f010173a:	75 1c                	jne    f0101758 <__umoddi3+0x48>
f010173c:	39 f7                	cmp    %esi,%edi
f010173e:	76 50                	jbe    f0101790 <__umoddi3+0x80>
f0101740:	89 c8                	mov    %ecx,%eax
f0101742:	89 f2                	mov    %esi,%edx
f0101744:	f7 f7                	div    %edi
f0101746:	89 d0                	mov    %edx,%eax
f0101748:	31 d2                	xor    %edx,%edx
f010174a:	83 c4 1c             	add    $0x1c,%esp
f010174d:	5b                   	pop    %ebx
f010174e:	5e                   	pop    %esi
f010174f:	5f                   	pop    %edi
f0101750:	5d                   	pop    %ebp
f0101751:	c3                   	ret    
f0101752:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101758:	39 f2                	cmp    %esi,%edx
f010175a:	89 d0                	mov    %edx,%eax
f010175c:	77 52                	ja     f01017b0 <__umoddi3+0xa0>
f010175e:	0f bd ea             	bsr    %edx,%ebp
f0101761:	83 f5 1f             	xor    $0x1f,%ebp
f0101764:	75 5a                	jne    f01017c0 <__umoddi3+0xb0>
f0101766:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010176a:	0f 82 e0 00 00 00    	jb     f0101850 <__umoddi3+0x140>
f0101770:	39 0c 24             	cmp    %ecx,(%esp)
f0101773:	0f 86 d7 00 00 00    	jbe    f0101850 <__umoddi3+0x140>
f0101779:	8b 44 24 08          	mov    0x8(%esp),%eax
f010177d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101781:	83 c4 1c             	add    $0x1c,%esp
f0101784:	5b                   	pop    %ebx
f0101785:	5e                   	pop    %esi
f0101786:	5f                   	pop    %edi
f0101787:	5d                   	pop    %ebp
f0101788:	c3                   	ret    
f0101789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101790:	85 ff                	test   %edi,%edi
f0101792:	89 fd                	mov    %edi,%ebp
f0101794:	75 0b                	jne    f01017a1 <__umoddi3+0x91>
f0101796:	b8 01 00 00 00       	mov    $0x1,%eax
f010179b:	31 d2                	xor    %edx,%edx
f010179d:	f7 f7                	div    %edi
f010179f:	89 c5                	mov    %eax,%ebp
f01017a1:	89 f0                	mov    %esi,%eax
f01017a3:	31 d2                	xor    %edx,%edx
f01017a5:	f7 f5                	div    %ebp
f01017a7:	89 c8                	mov    %ecx,%eax
f01017a9:	f7 f5                	div    %ebp
f01017ab:	89 d0                	mov    %edx,%eax
f01017ad:	eb 99                	jmp    f0101748 <__umoddi3+0x38>
f01017af:	90                   	nop
f01017b0:	89 c8                	mov    %ecx,%eax
f01017b2:	89 f2                	mov    %esi,%edx
f01017b4:	83 c4 1c             	add    $0x1c,%esp
f01017b7:	5b                   	pop    %ebx
f01017b8:	5e                   	pop    %esi
f01017b9:	5f                   	pop    %edi
f01017ba:	5d                   	pop    %ebp
f01017bb:	c3                   	ret    
f01017bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017c0:	8b 34 24             	mov    (%esp),%esi
f01017c3:	bf 20 00 00 00       	mov    $0x20,%edi
f01017c8:	89 e9                	mov    %ebp,%ecx
f01017ca:	29 ef                	sub    %ebp,%edi
f01017cc:	d3 e0                	shl    %cl,%eax
f01017ce:	89 f9                	mov    %edi,%ecx
f01017d0:	89 f2                	mov    %esi,%edx
f01017d2:	d3 ea                	shr    %cl,%edx
f01017d4:	89 e9                	mov    %ebp,%ecx
f01017d6:	09 c2                	or     %eax,%edx
f01017d8:	89 d8                	mov    %ebx,%eax
f01017da:	89 14 24             	mov    %edx,(%esp)
f01017dd:	89 f2                	mov    %esi,%edx
f01017df:	d3 e2                	shl    %cl,%edx
f01017e1:	89 f9                	mov    %edi,%ecx
f01017e3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01017e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01017eb:	d3 e8                	shr    %cl,%eax
f01017ed:	89 e9                	mov    %ebp,%ecx
f01017ef:	89 c6                	mov    %eax,%esi
f01017f1:	d3 e3                	shl    %cl,%ebx
f01017f3:	89 f9                	mov    %edi,%ecx
f01017f5:	89 d0                	mov    %edx,%eax
f01017f7:	d3 e8                	shr    %cl,%eax
f01017f9:	89 e9                	mov    %ebp,%ecx
f01017fb:	09 d8                	or     %ebx,%eax
f01017fd:	89 d3                	mov    %edx,%ebx
f01017ff:	89 f2                	mov    %esi,%edx
f0101801:	f7 34 24             	divl   (%esp)
f0101804:	89 d6                	mov    %edx,%esi
f0101806:	d3 e3                	shl    %cl,%ebx
f0101808:	f7 64 24 04          	mull   0x4(%esp)
f010180c:	39 d6                	cmp    %edx,%esi
f010180e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101812:	89 d1                	mov    %edx,%ecx
f0101814:	89 c3                	mov    %eax,%ebx
f0101816:	72 08                	jb     f0101820 <__umoddi3+0x110>
f0101818:	75 11                	jne    f010182b <__umoddi3+0x11b>
f010181a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010181e:	73 0b                	jae    f010182b <__umoddi3+0x11b>
f0101820:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101824:	1b 14 24             	sbb    (%esp),%edx
f0101827:	89 d1                	mov    %edx,%ecx
f0101829:	89 c3                	mov    %eax,%ebx
f010182b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010182f:	29 da                	sub    %ebx,%edx
f0101831:	19 ce                	sbb    %ecx,%esi
f0101833:	89 f9                	mov    %edi,%ecx
f0101835:	89 f0                	mov    %esi,%eax
f0101837:	d3 e0                	shl    %cl,%eax
f0101839:	89 e9                	mov    %ebp,%ecx
f010183b:	d3 ea                	shr    %cl,%edx
f010183d:	89 e9                	mov    %ebp,%ecx
f010183f:	d3 ee                	shr    %cl,%esi
f0101841:	09 d0                	or     %edx,%eax
f0101843:	89 f2                	mov    %esi,%edx
f0101845:	83 c4 1c             	add    $0x1c,%esp
f0101848:	5b                   	pop    %ebx
f0101849:	5e                   	pop    %esi
f010184a:	5f                   	pop    %edi
f010184b:	5d                   	pop    %ebp
f010184c:	c3                   	ret    
f010184d:	8d 76 00             	lea    0x0(%esi),%esi
f0101850:	29 f9                	sub    %edi,%ecx
f0101852:	19 d6                	sbb    %edx,%esi
f0101854:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101858:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010185c:	e9 18 ff ff ff       	jmp    f0101779 <__umoddi3+0x69>
