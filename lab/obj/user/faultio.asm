
obj/user/faultio.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 44 00 00 00       	call   800075 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	74 18                	je     800058 <umain+0x25>
  800040:	9c                   	pushf  
  800041:	58                   	pop    %eax
		cprintf("eflags wrong, 0x%x\n", read_eflags() & FL_IOPL_3);
  800042:	83 ec 08             	sub    $0x8,%esp
  800045:	25 00 30 00 00       	and    $0x3000,%eax
  80004a:	50                   	push   %eax
  80004b:	68 e0 22 80 00       	push   $0x8022e0
  800050:	e8 13 01 00 00       	call   800168 <cprintf>
  800055:	83 c4 10             	add    $0x10,%esp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800058:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80005d:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800062:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	68 f4 22 80 00       	push   $0x8022f4
  80006b:	e8 f8 00 00 00       	call   800168 <cprintf>
}
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	c9                   	leave  
  800074:	c3                   	ret    

00800075 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800075:	55                   	push   %ebp
  800076:	89 e5                	mov    %esp,%ebp
  800078:	56                   	push   %esi
  800079:	53                   	push   %ebx
  80007a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800080:	e8 2d 0a 00 00       	call   800ab2 <sys_getenvid>
  800085:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80008d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800092:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800097:	85 db                	test   %ebx,%ebx
  800099:	7e 07                	jle    8000a2 <libmain+0x2d>
		binaryname = argv[0];
  80009b:	8b 06                	mov    (%esi),%eax
  80009d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a2:	83 ec 08             	sub    $0x8,%esp
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	e8 87 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ac:	e8 0a 00 00 00       	call   8000bb <exit>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c1:	e8 89 0e 00 00       	call   800f4f <close_all>
	sys_env_destroy(0);
  8000c6:	83 ec 0c             	sub    $0xc,%esp
  8000c9:	6a 00                	push   $0x0
  8000cb:	e8 a1 09 00 00       	call   800a71 <sys_env_destroy>
}
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    

008000d5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 04             	sub    $0x4,%esp
  8000dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000df:	8b 13                	mov    (%ebx),%edx
  8000e1:	8d 42 01             	lea    0x1(%edx),%eax
  8000e4:	89 03                	mov    %eax,(%ebx)
  8000e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ed:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f2:	75 1a                	jne    80010e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000f4:	83 ec 08             	sub    $0x8,%esp
  8000f7:	68 ff 00 00 00       	push   $0xff
  8000fc:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ff:	50                   	push   %eax
  800100:	e8 2f 09 00 00       	call   800a34 <sys_cputs>
		b->idx = 0;
  800105:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80010e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800112:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800115:	c9                   	leave  
  800116:	c3                   	ret    

00800117 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800120:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800127:	00 00 00 
	b.cnt = 0;
  80012a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800131:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800134:	ff 75 0c             	pushl  0xc(%ebp)
  800137:	ff 75 08             	pushl  0x8(%ebp)
  80013a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800140:	50                   	push   %eax
  800141:	68 d5 00 80 00       	push   $0x8000d5
  800146:	e8 54 01 00 00       	call   80029f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014b:	83 c4 08             	add    $0x8,%esp
  80014e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800154:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015a:	50                   	push   %eax
  80015b:	e8 d4 08 00 00       	call   800a34 <sys_cputs>

	return b.cnt;
}
  800160:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800171:	50                   	push   %eax
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	e8 9d ff ff ff       	call   800117 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	53                   	push   %ebx
  800182:	83 ec 1c             	sub    $0x1c,%esp
  800185:	89 c7                	mov    %eax,%edi
  800187:	89 d6                	mov    %edx,%esi
  800189:	8b 45 08             	mov    0x8(%ebp),%eax
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800192:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800195:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800198:	bb 00 00 00 00       	mov    $0x0,%ebx
  80019d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001a0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001a3:	39 d3                	cmp    %edx,%ebx
  8001a5:	72 05                	jb     8001ac <printnum+0x30>
  8001a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001aa:	77 45                	ja     8001f1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ac:	83 ec 0c             	sub    $0xc,%esp
  8001af:	ff 75 18             	pushl  0x18(%ebp)
  8001b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	ff 75 10             	pushl  0x10(%ebp)
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001cb:	e8 70 1e 00 00       	call   802040 <__udivdi3>
  8001d0:	83 c4 18             	add    $0x18,%esp
  8001d3:	52                   	push   %edx
  8001d4:	50                   	push   %eax
  8001d5:	89 f2                	mov    %esi,%edx
  8001d7:	89 f8                	mov    %edi,%eax
  8001d9:	e8 9e ff ff ff       	call   80017c <printnum>
  8001de:	83 c4 20             	add    $0x20,%esp
  8001e1:	eb 18                	jmp    8001fb <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	56                   	push   %esi
  8001e7:	ff 75 18             	pushl  0x18(%ebp)
  8001ea:	ff d7                	call   *%edi
  8001ec:	83 c4 10             	add    $0x10,%esp
  8001ef:	eb 03                	jmp    8001f4 <printnum+0x78>
  8001f1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f4:	83 eb 01             	sub    $0x1,%ebx
  8001f7:	85 db                	test   %ebx,%ebx
  8001f9:	7f e8                	jg     8001e3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	56                   	push   %esi
  8001ff:	83 ec 04             	sub    $0x4,%esp
  800202:	ff 75 e4             	pushl  -0x1c(%ebp)
  800205:	ff 75 e0             	pushl  -0x20(%ebp)
  800208:	ff 75 dc             	pushl  -0x24(%ebp)
  80020b:	ff 75 d8             	pushl  -0x28(%ebp)
  80020e:	e8 5d 1f 00 00       	call   802170 <__umoddi3>
  800213:	83 c4 14             	add    $0x14,%esp
  800216:	0f be 80 18 23 80 00 	movsbl 0x802318(%eax),%eax
  80021d:	50                   	push   %eax
  80021e:	ff d7                	call   *%edi
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5f                   	pop    %edi
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80022e:	83 fa 01             	cmp    $0x1,%edx
  800231:	7e 0e                	jle    800241 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800233:	8b 10                	mov    (%eax),%edx
  800235:	8d 4a 08             	lea    0x8(%edx),%ecx
  800238:	89 08                	mov    %ecx,(%eax)
  80023a:	8b 02                	mov    (%edx),%eax
  80023c:	8b 52 04             	mov    0x4(%edx),%edx
  80023f:	eb 22                	jmp    800263 <getuint+0x38>
	else if (lflag)
  800241:	85 d2                	test   %edx,%edx
  800243:	74 10                	je     800255 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800245:	8b 10                	mov    (%eax),%edx
  800247:	8d 4a 04             	lea    0x4(%edx),%ecx
  80024a:	89 08                	mov    %ecx,(%eax)
  80024c:	8b 02                	mov    (%edx),%eax
  80024e:	ba 00 00 00 00       	mov    $0x0,%edx
  800253:	eb 0e                	jmp    800263 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800255:	8b 10                	mov    (%eax),%edx
  800257:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025a:	89 08                	mov    %ecx,(%eax)
  80025c:	8b 02                	mov    (%edx),%eax
  80025e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80026b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80026f:	8b 10                	mov    (%eax),%edx
  800271:	3b 50 04             	cmp    0x4(%eax),%edx
  800274:	73 0a                	jae    800280 <sprintputch+0x1b>
		*b->buf++ = ch;
  800276:	8d 4a 01             	lea    0x1(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 45 08             	mov    0x8(%ebp),%eax
  80027e:	88 02                	mov    %al,(%edx)
}
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800288:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80028b:	50                   	push   %eax
  80028c:	ff 75 10             	pushl  0x10(%ebp)
  80028f:	ff 75 0c             	pushl  0xc(%ebp)
  800292:	ff 75 08             	pushl  0x8(%ebp)
  800295:	e8 05 00 00 00       	call   80029f <vprintfmt>
	va_end(ap);
}
  80029a:	83 c4 10             	add    $0x10,%esp
  80029d:	c9                   	leave  
  80029e:	c3                   	ret    

0080029f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	57                   	push   %edi
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 2c             	sub    $0x2c,%esp
  8002a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b1:	eb 12                	jmp    8002c5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b3:	85 c0                	test   %eax,%eax
  8002b5:	0f 84 89 03 00 00    	je     800644 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002bb:	83 ec 08             	sub    $0x8,%esp
  8002be:	53                   	push   %ebx
  8002bf:	50                   	push   %eax
  8002c0:	ff d6                	call   *%esi
  8002c2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c5:	83 c7 01             	add    $0x1,%edi
  8002c8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002cc:	83 f8 25             	cmp    $0x25,%eax
  8002cf:	75 e2                	jne    8002b3 <vprintfmt+0x14>
  8002d1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002d5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002dc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ef:	eb 07                	jmp    8002f8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f8:	8d 47 01             	lea    0x1(%edi),%eax
  8002fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fe:	0f b6 07             	movzbl (%edi),%eax
  800301:	0f b6 c8             	movzbl %al,%ecx
  800304:	83 e8 23             	sub    $0x23,%eax
  800307:	3c 55                	cmp    $0x55,%al
  800309:	0f 87 1a 03 00 00    	ja     800629 <vprintfmt+0x38a>
  80030f:	0f b6 c0             	movzbl %al,%eax
  800312:	ff 24 85 60 24 80 00 	jmp    *0x802460(,%eax,4)
  800319:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80031c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800320:	eb d6                	jmp    8002f8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800325:	b8 00 00 00 00       	mov    $0x0,%eax
  80032a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80032d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800330:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800334:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800337:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80033a:	83 fa 09             	cmp    $0x9,%edx
  80033d:	77 39                	ja     800378 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80033f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800342:	eb e9                	jmp    80032d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800344:	8b 45 14             	mov    0x14(%ebp),%eax
  800347:	8d 48 04             	lea    0x4(%eax),%ecx
  80034a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80034d:	8b 00                	mov    (%eax),%eax
  80034f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800355:	eb 27                	jmp    80037e <vprintfmt+0xdf>
  800357:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80035a:	85 c0                	test   %eax,%eax
  80035c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800361:	0f 49 c8             	cmovns %eax,%ecx
  800364:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036a:	eb 8c                	jmp    8002f8 <vprintfmt+0x59>
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80036f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800376:	eb 80                	jmp    8002f8 <vprintfmt+0x59>
  800378:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80037b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80037e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800382:	0f 89 70 ff ff ff    	jns    8002f8 <vprintfmt+0x59>
				width = precision, precision = -1;
  800388:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80038b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80038e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800395:	e9 5e ff ff ff       	jmp    8002f8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80039a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003a0:	e9 53 ff ff ff       	jmp    8002f8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 50 04             	lea    0x4(%eax),%edx
  8003ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ae:	83 ec 08             	sub    $0x8,%esp
  8003b1:	53                   	push   %ebx
  8003b2:	ff 30                	pushl  (%eax)
  8003b4:	ff d6                	call   *%esi
			break;
  8003b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003bc:	e9 04 ff ff ff       	jmp    8002c5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8d 50 04             	lea    0x4(%eax),%edx
  8003c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	99                   	cltd   
  8003cd:	31 d0                	xor    %edx,%eax
  8003cf:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d1:	83 f8 0f             	cmp    $0xf,%eax
  8003d4:	7f 0b                	jg     8003e1 <vprintfmt+0x142>
  8003d6:	8b 14 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%edx
  8003dd:	85 d2                	test   %edx,%edx
  8003df:	75 18                	jne    8003f9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003e1:	50                   	push   %eax
  8003e2:	68 30 23 80 00       	push   $0x802330
  8003e7:	53                   	push   %ebx
  8003e8:	56                   	push   %esi
  8003e9:	e8 94 fe ff ff       	call   800282 <printfmt>
  8003ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f4:	e9 cc fe ff ff       	jmp    8002c5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f9:	52                   	push   %edx
  8003fa:	68 f5 26 80 00       	push   $0x8026f5
  8003ff:	53                   	push   %ebx
  800400:	56                   	push   %esi
  800401:	e8 7c fe ff ff       	call   800282 <printfmt>
  800406:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040c:	e9 b4 fe ff ff       	jmp    8002c5 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 50 04             	lea    0x4(%eax),%edx
  800417:	89 55 14             	mov    %edx,0x14(%ebp)
  80041a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041c:	85 ff                	test   %edi,%edi
  80041e:	b8 29 23 80 00       	mov    $0x802329,%eax
  800423:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800426:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042a:	0f 8e 94 00 00 00    	jle    8004c4 <vprintfmt+0x225>
  800430:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800434:	0f 84 98 00 00 00    	je     8004d2 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	ff 75 d0             	pushl  -0x30(%ebp)
  800440:	57                   	push   %edi
  800441:	e8 86 02 00 00       	call   8006cc <strnlen>
  800446:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800449:	29 c1                	sub    %eax,%ecx
  80044b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80044e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800451:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800455:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800458:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045d:	eb 0f                	jmp    80046e <vprintfmt+0x1cf>
					putch(padc, putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	53                   	push   %ebx
  800463:	ff 75 e0             	pushl  -0x20(%ebp)
  800466:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	83 ef 01             	sub    $0x1,%edi
  80046b:	83 c4 10             	add    $0x10,%esp
  80046e:	85 ff                	test   %edi,%edi
  800470:	7f ed                	jg     80045f <vprintfmt+0x1c0>
  800472:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800475:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800478:	85 c9                	test   %ecx,%ecx
  80047a:	b8 00 00 00 00       	mov    $0x0,%eax
  80047f:	0f 49 c1             	cmovns %ecx,%eax
  800482:	29 c1                	sub    %eax,%ecx
  800484:	89 75 08             	mov    %esi,0x8(%ebp)
  800487:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048d:	89 cb                	mov    %ecx,%ebx
  80048f:	eb 4d                	jmp    8004de <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800491:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800495:	74 1b                	je     8004b2 <vprintfmt+0x213>
  800497:	0f be c0             	movsbl %al,%eax
  80049a:	83 e8 20             	sub    $0x20,%eax
  80049d:	83 f8 5e             	cmp    $0x5e,%eax
  8004a0:	76 10                	jbe    8004b2 <vprintfmt+0x213>
					putch('?', putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	ff 75 0c             	pushl  0xc(%ebp)
  8004a8:	6a 3f                	push   $0x3f
  8004aa:	ff 55 08             	call   *0x8(%ebp)
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	eb 0d                	jmp    8004bf <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	ff 75 0c             	pushl  0xc(%ebp)
  8004b8:	52                   	push   %edx
  8004b9:	ff 55 08             	call   *0x8(%ebp)
  8004bc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bf:	83 eb 01             	sub    $0x1,%ebx
  8004c2:	eb 1a                	jmp    8004de <vprintfmt+0x23f>
  8004c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d0:	eb 0c                	jmp    8004de <vprintfmt+0x23f>
  8004d2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004db:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004de:	83 c7 01             	add    $0x1,%edi
  8004e1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e5:	0f be d0             	movsbl %al,%edx
  8004e8:	85 d2                	test   %edx,%edx
  8004ea:	74 23                	je     80050f <vprintfmt+0x270>
  8004ec:	85 f6                	test   %esi,%esi
  8004ee:	78 a1                	js     800491 <vprintfmt+0x1f2>
  8004f0:	83 ee 01             	sub    $0x1,%esi
  8004f3:	79 9c                	jns    800491 <vprintfmt+0x1f2>
  8004f5:	89 df                	mov    %ebx,%edi
  8004f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fd:	eb 18                	jmp    800517 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	53                   	push   %ebx
  800503:	6a 20                	push   $0x20
  800505:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800507:	83 ef 01             	sub    $0x1,%edi
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	eb 08                	jmp    800517 <vprintfmt+0x278>
  80050f:	89 df                	mov    %ebx,%edi
  800511:	8b 75 08             	mov    0x8(%ebp),%esi
  800514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800517:	85 ff                	test   %edi,%edi
  800519:	7f e4                	jg     8004ff <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051e:	e9 a2 fd ff ff       	jmp    8002c5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800523:	83 fa 01             	cmp    $0x1,%edx
  800526:	7e 16                	jle    80053e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 08             	lea    0x8(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	8b 50 04             	mov    0x4(%eax),%edx
  800534:	8b 00                	mov    (%eax),%eax
  800536:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800539:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053c:	eb 32                	jmp    800570 <vprintfmt+0x2d1>
	else if (lflag)
  80053e:	85 d2                	test   %edx,%edx
  800540:	74 18                	je     80055a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800550:	89 c1                	mov    %eax,%ecx
  800552:	c1 f9 1f             	sar    $0x1f,%ecx
  800555:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800558:	eb 16                	jmp    800570 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	8b 00                	mov    (%eax),%eax
  800565:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800568:	89 c1                	mov    %eax,%ecx
  80056a:	c1 f9 1f             	sar    $0x1f,%ecx
  80056d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800570:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800573:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800576:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80057b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057f:	79 74                	jns    8005f5 <vprintfmt+0x356>
				putch('-', putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	53                   	push   %ebx
  800585:	6a 2d                	push   $0x2d
  800587:	ff d6                	call   *%esi
				num = -(long long) num;
  800589:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80058c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80058f:	f7 d8                	neg    %eax
  800591:	83 d2 00             	adc    $0x0,%edx
  800594:	f7 da                	neg    %edx
  800596:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800599:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80059e:	eb 55                	jmp    8005f5 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a3:	e8 83 fc ff ff       	call   80022b <getuint>
			base = 10;
  8005a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ad:	eb 46                	jmp    8005f5 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005af:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b2:	e8 74 fc ff ff       	call   80022b <getuint>
			base = 8;
  8005b7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005bc:	eb 37                	jmp    8005f5 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	6a 30                	push   $0x30
  8005c4:	ff d6                	call   *%esi
			putch('x', putdat);
  8005c6:	83 c4 08             	add    $0x8,%esp
  8005c9:	53                   	push   %ebx
  8005ca:	6a 78                	push   $0x78
  8005cc:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 50 04             	lea    0x4(%eax),%edx
  8005d4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005d7:	8b 00                	mov    (%eax),%eax
  8005d9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005de:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005e1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005e6:	eb 0d                	jmp    8005f5 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005eb:	e8 3b fc ff ff       	call   80022b <getuint>
			base = 16;
  8005f0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f5:	83 ec 0c             	sub    $0xc,%esp
  8005f8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005fc:	57                   	push   %edi
  8005fd:	ff 75 e0             	pushl  -0x20(%ebp)
  800600:	51                   	push   %ecx
  800601:	52                   	push   %edx
  800602:	50                   	push   %eax
  800603:	89 da                	mov    %ebx,%edx
  800605:	89 f0                	mov    %esi,%eax
  800607:	e8 70 fb ff ff       	call   80017c <printnum>
			break;
  80060c:	83 c4 20             	add    $0x20,%esp
  80060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800612:	e9 ae fc ff ff       	jmp    8002c5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	51                   	push   %ecx
  80061c:	ff d6                	call   *%esi
			break;
  80061e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800621:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800624:	e9 9c fc ff ff       	jmp    8002c5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 25                	push   $0x25
  80062f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	eb 03                	jmp    800639 <vprintfmt+0x39a>
  800636:	83 ef 01             	sub    $0x1,%edi
  800639:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80063d:	75 f7                	jne    800636 <vprintfmt+0x397>
  80063f:	e9 81 fc ff ff       	jmp    8002c5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800644:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800647:	5b                   	pop    %ebx
  800648:	5e                   	pop    %esi
  800649:	5f                   	pop    %edi
  80064a:	5d                   	pop    %ebp
  80064b:	c3                   	ret    

0080064c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 18             	sub    $0x18,%esp
  800652:	8b 45 08             	mov    0x8(%ebp),%eax
  800655:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800658:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80065b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80065f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800662:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800669:	85 c0                	test   %eax,%eax
  80066b:	74 26                	je     800693 <vsnprintf+0x47>
  80066d:	85 d2                	test   %edx,%edx
  80066f:	7e 22                	jle    800693 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800671:	ff 75 14             	pushl  0x14(%ebp)
  800674:	ff 75 10             	pushl  0x10(%ebp)
  800677:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80067a:	50                   	push   %eax
  80067b:	68 65 02 80 00       	push   $0x800265
  800680:	e8 1a fc ff ff       	call   80029f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800685:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800688:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	eb 05                	jmp    800698 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800693:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800698:	c9                   	leave  
  800699:	c3                   	ret    

0080069a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a3:	50                   	push   %eax
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	ff 75 08             	pushl  0x8(%ebp)
  8006ad:	e8 9a ff ff ff       	call   80064c <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bf:	eb 03                	jmp    8006c4 <strlen+0x10>
		n++;
  8006c1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c8:	75 f7                	jne    8006c1 <strlen+0xd>
		n++;
	return n;
}
  8006ca:	5d                   	pop    %ebp
  8006cb:	c3                   	ret    

008006cc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8006da:	eb 03                	jmp    8006df <strnlen+0x13>
		n++;
  8006dc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006df:	39 c2                	cmp    %eax,%edx
  8006e1:	74 08                	je     8006eb <strnlen+0x1f>
  8006e3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006e7:	75 f3                	jne    8006dc <strnlen+0x10>
  8006e9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	53                   	push   %ebx
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006f7:	89 c2                	mov    %eax,%edx
  8006f9:	83 c2 01             	add    $0x1,%edx
  8006fc:	83 c1 01             	add    $0x1,%ecx
  8006ff:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800703:	88 5a ff             	mov    %bl,-0x1(%edx)
  800706:	84 db                	test   %bl,%bl
  800708:	75 ef                	jne    8006f9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80070a:	5b                   	pop    %ebx
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800714:	53                   	push   %ebx
  800715:	e8 9a ff ff ff       	call   8006b4 <strlen>
  80071a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80071d:	ff 75 0c             	pushl  0xc(%ebp)
  800720:	01 d8                	add    %ebx,%eax
  800722:	50                   	push   %eax
  800723:	e8 c5 ff ff ff       	call   8006ed <strcpy>
	return dst;
}
  800728:	89 d8                	mov    %ebx,%eax
  80072a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	56                   	push   %esi
  800733:	53                   	push   %ebx
  800734:	8b 75 08             	mov    0x8(%ebp),%esi
  800737:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073a:	89 f3                	mov    %esi,%ebx
  80073c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073f:	89 f2                	mov    %esi,%edx
  800741:	eb 0f                	jmp    800752 <strncpy+0x23>
		*dst++ = *src;
  800743:	83 c2 01             	add    $0x1,%edx
  800746:	0f b6 01             	movzbl (%ecx),%eax
  800749:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80074c:	80 39 01             	cmpb   $0x1,(%ecx)
  80074f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800752:	39 da                	cmp    %ebx,%edx
  800754:	75 ed                	jne    800743 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800756:	89 f0                	mov    %esi,%eax
  800758:	5b                   	pop    %ebx
  800759:	5e                   	pop    %esi
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	56                   	push   %esi
  800760:	53                   	push   %ebx
  800761:	8b 75 08             	mov    0x8(%ebp),%esi
  800764:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800767:	8b 55 10             	mov    0x10(%ebp),%edx
  80076a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80076c:	85 d2                	test   %edx,%edx
  80076e:	74 21                	je     800791 <strlcpy+0x35>
  800770:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800774:	89 f2                	mov    %esi,%edx
  800776:	eb 09                	jmp    800781 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800778:	83 c2 01             	add    $0x1,%edx
  80077b:	83 c1 01             	add    $0x1,%ecx
  80077e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800781:	39 c2                	cmp    %eax,%edx
  800783:	74 09                	je     80078e <strlcpy+0x32>
  800785:	0f b6 19             	movzbl (%ecx),%ebx
  800788:	84 db                	test   %bl,%bl
  80078a:	75 ec                	jne    800778 <strlcpy+0x1c>
  80078c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80078e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800791:	29 f0                	sub    %esi,%eax
}
  800793:	5b                   	pop    %ebx
  800794:	5e                   	pop    %esi
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007a0:	eb 06                	jmp    8007a8 <strcmp+0x11>
		p++, q++;
  8007a2:	83 c1 01             	add    $0x1,%ecx
  8007a5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007a8:	0f b6 01             	movzbl (%ecx),%eax
  8007ab:	84 c0                	test   %al,%al
  8007ad:	74 04                	je     8007b3 <strcmp+0x1c>
  8007af:	3a 02                	cmp    (%edx),%al
  8007b1:	74 ef                	je     8007a2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b3:	0f b6 c0             	movzbl %al,%eax
  8007b6:	0f b6 12             	movzbl (%edx),%edx
  8007b9:	29 d0                	sub    %edx,%eax
}
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	53                   	push   %ebx
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c7:	89 c3                	mov    %eax,%ebx
  8007c9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007cc:	eb 06                	jmp    8007d4 <strncmp+0x17>
		n--, p++, q++;
  8007ce:	83 c0 01             	add    $0x1,%eax
  8007d1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007d4:	39 d8                	cmp    %ebx,%eax
  8007d6:	74 15                	je     8007ed <strncmp+0x30>
  8007d8:	0f b6 08             	movzbl (%eax),%ecx
  8007db:	84 c9                	test   %cl,%cl
  8007dd:	74 04                	je     8007e3 <strncmp+0x26>
  8007df:	3a 0a                	cmp    (%edx),%cl
  8007e1:	74 eb                	je     8007ce <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e3:	0f b6 00             	movzbl (%eax),%eax
  8007e6:	0f b6 12             	movzbl (%edx),%edx
  8007e9:	29 d0                	sub    %edx,%eax
  8007eb:	eb 05                	jmp    8007f2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007ed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007f2:	5b                   	pop    %ebx
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007ff:	eb 07                	jmp    800808 <strchr+0x13>
		if (*s == c)
  800801:	38 ca                	cmp    %cl,%dl
  800803:	74 0f                	je     800814 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800805:	83 c0 01             	add    $0x1,%eax
  800808:	0f b6 10             	movzbl (%eax),%edx
  80080b:	84 d2                	test   %dl,%dl
  80080d:	75 f2                	jne    800801 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800820:	eb 03                	jmp    800825 <strfind+0xf>
  800822:	83 c0 01             	add    $0x1,%eax
  800825:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800828:	38 ca                	cmp    %cl,%dl
  80082a:	74 04                	je     800830 <strfind+0x1a>
  80082c:	84 d2                	test   %dl,%dl
  80082e:	75 f2                	jne    800822 <strfind+0xc>
			break;
	return (char *) s;
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	57                   	push   %edi
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80083e:	85 c9                	test   %ecx,%ecx
  800840:	74 36                	je     800878 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800842:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800848:	75 28                	jne    800872 <memset+0x40>
  80084a:	f6 c1 03             	test   $0x3,%cl
  80084d:	75 23                	jne    800872 <memset+0x40>
		c &= 0xFF;
  80084f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800853:	89 d3                	mov    %edx,%ebx
  800855:	c1 e3 08             	shl    $0x8,%ebx
  800858:	89 d6                	mov    %edx,%esi
  80085a:	c1 e6 18             	shl    $0x18,%esi
  80085d:	89 d0                	mov    %edx,%eax
  80085f:	c1 e0 10             	shl    $0x10,%eax
  800862:	09 f0                	or     %esi,%eax
  800864:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800866:	89 d8                	mov    %ebx,%eax
  800868:	09 d0                	or     %edx,%eax
  80086a:	c1 e9 02             	shr    $0x2,%ecx
  80086d:	fc                   	cld    
  80086e:	f3 ab                	rep stos %eax,%es:(%edi)
  800870:	eb 06                	jmp    800878 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800872:	8b 45 0c             	mov    0xc(%ebp),%eax
  800875:	fc                   	cld    
  800876:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800878:	89 f8                	mov    %edi,%eax
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5f                   	pop    %edi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	57                   	push   %edi
  800883:	56                   	push   %esi
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80088d:	39 c6                	cmp    %eax,%esi
  80088f:	73 35                	jae    8008c6 <memmove+0x47>
  800891:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800894:	39 d0                	cmp    %edx,%eax
  800896:	73 2e                	jae    8008c6 <memmove+0x47>
		s += n;
		d += n;
  800898:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089b:	89 d6                	mov    %edx,%esi
  80089d:	09 fe                	or     %edi,%esi
  80089f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008a5:	75 13                	jne    8008ba <memmove+0x3b>
  8008a7:	f6 c1 03             	test   $0x3,%cl
  8008aa:	75 0e                	jne    8008ba <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008ac:	83 ef 04             	sub    $0x4,%edi
  8008af:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b2:	c1 e9 02             	shr    $0x2,%ecx
  8008b5:	fd                   	std    
  8008b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b8:	eb 09                	jmp    8008c3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ba:	83 ef 01             	sub    $0x1,%edi
  8008bd:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008c0:	fd                   	std    
  8008c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c3:	fc                   	cld    
  8008c4:	eb 1d                	jmp    8008e3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c6:	89 f2                	mov    %esi,%edx
  8008c8:	09 c2                	or     %eax,%edx
  8008ca:	f6 c2 03             	test   $0x3,%dl
  8008cd:	75 0f                	jne    8008de <memmove+0x5f>
  8008cf:	f6 c1 03             	test   $0x3,%cl
  8008d2:	75 0a                	jne    8008de <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008d4:	c1 e9 02             	shr    $0x2,%ecx
  8008d7:	89 c7                	mov    %eax,%edi
  8008d9:	fc                   	cld    
  8008da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008dc:	eb 05                	jmp    8008e3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008de:	89 c7                	mov    %eax,%edi
  8008e0:	fc                   	cld    
  8008e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008e3:	5e                   	pop    %esi
  8008e4:	5f                   	pop    %edi
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008ea:	ff 75 10             	pushl  0x10(%ebp)
  8008ed:	ff 75 0c             	pushl  0xc(%ebp)
  8008f0:	ff 75 08             	pushl  0x8(%ebp)
  8008f3:	e8 87 ff ff ff       	call   80087f <memmove>
}
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    

008008fa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
  800905:	89 c6                	mov    %eax,%esi
  800907:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090a:	eb 1a                	jmp    800926 <memcmp+0x2c>
		if (*s1 != *s2)
  80090c:	0f b6 08             	movzbl (%eax),%ecx
  80090f:	0f b6 1a             	movzbl (%edx),%ebx
  800912:	38 d9                	cmp    %bl,%cl
  800914:	74 0a                	je     800920 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800916:	0f b6 c1             	movzbl %cl,%eax
  800919:	0f b6 db             	movzbl %bl,%ebx
  80091c:	29 d8                	sub    %ebx,%eax
  80091e:	eb 0f                	jmp    80092f <memcmp+0x35>
		s1++, s2++;
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800926:	39 f0                	cmp    %esi,%eax
  800928:	75 e2                	jne    80090c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092f:	5b                   	pop    %ebx
  800930:	5e                   	pop    %esi
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	53                   	push   %ebx
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80093a:	89 c1                	mov    %eax,%ecx
  80093c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80093f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800943:	eb 0a                	jmp    80094f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800945:	0f b6 10             	movzbl (%eax),%edx
  800948:	39 da                	cmp    %ebx,%edx
  80094a:	74 07                	je     800953 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	39 c8                	cmp    %ecx,%eax
  800951:	72 f2                	jb     800945 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800953:	5b                   	pop    %ebx
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	57                   	push   %edi
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800962:	eb 03                	jmp    800967 <strtol+0x11>
		s++;
  800964:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800967:	0f b6 01             	movzbl (%ecx),%eax
  80096a:	3c 20                	cmp    $0x20,%al
  80096c:	74 f6                	je     800964 <strtol+0xe>
  80096e:	3c 09                	cmp    $0x9,%al
  800970:	74 f2                	je     800964 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800972:	3c 2b                	cmp    $0x2b,%al
  800974:	75 0a                	jne    800980 <strtol+0x2a>
		s++;
  800976:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800979:	bf 00 00 00 00       	mov    $0x0,%edi
  80097e:	eb 11                	jmp    800991 <strtol+0x3b>
  800980:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800985:	3c 2d                	cmp    $0x2d,%al
  800987:	75 08                	jne    800991 <strtol+0x3b>
		s++, neg = 1;
  800989:	83 c1 01             	add    $0x1,%ecx
  80098c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800991:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800997:	75 15                	jne    8009ae <strtol+0x58>
  800999:	80 39 30             	cmpb   $0x30,(%ecx)
  80099c:	75 10                	jne    8009ae <strtol+0x58>
  80099e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009a2:	75 7c                	jne    800a20 <strtol+0xca>
		s += 2, base = 16;
  8009a4:	83 c1 02             	add    $0x2,%ecx
  8009a7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ac:	eb 16                	jmp    8009c4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009ae:	85 db                	test   %ebx,%ebx
  8009b0:	75 12                	jne    8009c4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009b2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009b7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ba:	75 08                	jne    8009c4 <strtol+0x6e>
		s++, base = 8;
  8009bc:	83 c1 01             	add    $0x1,%ecx
  8009bf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009cc:	0f b6 11             	movzbl (%ecx),%edx
  8009cf:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009d2:	89 f3                	mov    %esi,%ebx
  8009d4:	80 fb 09             	cmp    $0x9,%bl
  8009d7:	77 08                	ja     8009e1 <strtol+0x8b>
			dig = *s - '0';
  8009d9:	0f be d2             	movsbl %dl,%edx
  8009dc:	83 ea 30             	sub    $0x30,%edx
  8009df:	eb 22                	jmp    800a03 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009e1:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009e4:	89 f3                	mov    %esi,%ebx
  8009e6:	80 fb 19             	cmp    $0x19,%bl
  8009e9:	77 08                	ja     8009f3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009eb:	0f be d2             	movsbl %dl,%edx
  8009ee:	83 ea 57             	sub    $0x57,%edx
  8009f1:	eb 10                	jmp    800a03 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009f3:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009f6:	89 f3                	mov    %esi,%ebx
  8009f8:	80 fb 19             	cmp    $0x19,%bl
  8009fb:	77 16                	ja     800a13 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009fd:	0f be d2             	movsbl %dl,%edx
  800a00:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a03:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a06:	7d 0b                	jge    800a13 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a08:	83 c1 01             	add    $0x1,%ecx
  800a0b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a0f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a11:	eb b9                	jmp    8009cc <strtol+0x76>

	if (endptr)
  800a13:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a17:	74 0d                	je     800a26 <strtol+0xd0>
		*endptr = (char *) s;
  800a19:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1c:	89 0e                	mov    %ecx,(%esi)
  800a1e:	eb 06                	jmp    800a26 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a20:	85 db                	test   %ebx,%ebx
  800a22:	74 98                	je     8009bc <strtol+0x66>
  800a24:	eb 9e                	jmp    8009c4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a26:	89 c2                	mov    %eax,%edx
  800a28:	f7 da                	neg    %edx
  800a2a:	85 ff                	test   %edi,%edi
  800a2c:	0f 45 c2             	cmovne %edx,%eax
}
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a42:	8b 55 08             	mov    0x8(%ebp),%edx
  800a45:	89 c3                	mov    %eax,%ebx
  800a47:	89 c7                	mov    %eax,%edi
  800a49:	89 c6                	mov    %eax,%esi
  800a4b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a58:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a62:	89 d1                	mov    %edx,%ecx
  800a64:	89 d3                	mov    %edx,%ebx
  800a66:	89 d7                	mov    %edx,%edi
  800a68:	89 d6                	mov    %edx,%esi
  800a6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5f                   	pop    %edi
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	57                   	push   %edi
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
  800a77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a84:	8b 55 08             	mov    0x8(%ebp),%edx
  800a87:	89 cb                	mov    %ecx,%ebx
  800a89:	89 cf                	mov    %ecx,%edi
  800a8b:	89 ce                	mov    %ecx,%esi
  800a8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	7e 17                	jle    800aaa <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a93:	83 ec 0c             	sub    $0xc,%esp
  800a96:	50                   	push   %eax
  800a97:	6a 03                	push   $0x3
  800a99:	68 1f 26 80 00       	push   $0x80261f
  800a9e:	6a 23                	push   $0x23
  800aa0:	68 3c 26 80 00       	push   $0x80263c
  800aa5:	e8 1e 14 00 00       	call   801ec8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  800abd:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac2:	89 d1                	mov    %edx,%ecx
  800ac4:	89 d3                	mov    %edx,%ebx
  800ac6:	89 d7                	mov    %edx,%edi
  800ac8:	89 d6                	mov    %edx,%esi
  800aca:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <sys_yield>:

void
sys_yield(void)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad7:	ba 00 00 00 00       	mov    $0x0,%edx
  800adc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ae1:	89 d1                	mov    %edx,%ecx
  800ae3:	89 d3                	mov    %edx,%ebx
  800ae5:	89 d7                	mov    %edx,%edi
  800ae7:	89 d6                	mov    %edx,%esi
  800ae9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af9:	be 00 00 00 00       	mov    $0x0,%esi
  800afe:	b8 04 00 00 00       	mov    $0x4,%eax
  800b03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b06:	8b 55 08             	mov    0x8(%ebp),%edx
  800b09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b0c:	89 f7                	mov    %esi,%edi
  800b0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b10:	85 c0                	test   %eax,%eax
  800b12:	7e 17                	jle    800b2b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b14:	83 ec 0c             	sub    $0xc,%esp
  800b17:	50                   	push   %eax
  800b18:	6a 04                	push   $0x4
  800b1a:	68 1f 26 80 00       	push   $0x80261f
  800b1f:	6a 23                	push   $0x23
  800b21:	68 3c 26 80 00       	push   $0x80263c
  800b26:	e8 9d 13 00 00       	call   801ec8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3c:	b8 05 00 00 00       	mov    $0x5,%eax
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b4d:	8b 75 18             	mov    0x18(%ebp),%esi
  800b50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b52:	85 c0                	test   %eax,%eax
  800b54:	7e 17                	jle    800b6d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b56:	83 ec 0c             	sub    $0xc,%esp
  800b59:	50                   	push   %eax
  800b5a:	6a 05                	push   $0x5
  800b5c:	68 1f 26 80 00       	push   $0x80261f
  800b61:	6a 23                	push   $0x23
  800b63:	68 3c 26 80 00       	push   $0x80263c
  800b68:	e8 5b 13 00 00       	call   801ec8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b83:	b8 06 00 00 00       	mov    $0x6,%eax
  800b88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	89 df                	mov    %ebx,%edi
  800b90:	89 de                	mov    %ebx,%esi
  800b92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b94:	85 c0                	test   %eax,%eax
  800b96:	7e 17                	jle    800baf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	50                   	push   %eax
  800b9c:	6a 06                	push   $0x6
  800b9e:	68 1f 26 80 00       	push   $0x80261f
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 3c 26 80 00       	push   $0x80263c
  800baa:	e8 19 13 00 00       	call   801ec8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800baf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
  800bbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc5:	b8 08 00 00 00       	mov    $0x8,%eax
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	89 df                	mov    %ebx,%edi
  800bd2:	89 de                	mov    %ebx,%esi
  800bd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd6:	85 c0                	test   %eax,%eax
  800bd8:	7e 17                	jle    800bf1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 08                	push   $0x8
  800be0:	68 1f 26 80 00       	push   $0x80261f
  800be5:	6a 23                	push   $0x23
  800be7:	68 3c 26 80 00       	push   $0x80263c
  800bec:	e8 d7 12 00 00       	call   801ec8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c07:	b8 09 00 00 00       	mov    $0x9,%eax
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	89 df                	mov    %ebx,%edi
  800c14:	89 de                	mov    %ebx,%esi
  800c16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 09                	push   $0x9
  800c22:	68 1f 26 80 00       	push   $0x80261f
  800c27:	6a 23                	push   $0x23
  800c29:	68 3c 26 80 00       	push   $0x80263c
  800c2e:	e8 95 12 00 00       	call   801ec8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c49:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	89 df                	mov    %ebx,%edi
  800c56:	89 de                	mov    %ebx,%esi
  800c58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 17                	jle    800c75 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 0a                	push   $0xa
  800c64:	68 1f 26 80 00       	push   $0x80261f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 3c 26 80 00       	push   $0x80263c
  800c70:	e8 53 12 00 00       	call   801ec8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	be 00 00 00 00       	mov    $0x0,%esi
  800c88:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c99:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cae:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 cb                	mov    %ecx,%ebx
  800cb8:	89 cf                	mov    %ecx,%edi
  800cba:	89 ce                	mov    %ecx,%esi
  800cbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7e 17                	jle    800cd9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc2:	83 ec 0c             	sub    $0xc,%esp
  800cc5:	50                   	push   %eax
  800cc6:	6a 0d                	push   $0xd
  800cc8:	68 1f 26 80 00       	push   $0x80261f
  800ccd:	6a 23                	push   $0x23
  800ccf:	68 3c 26 80 00       	push   $0x80263c
  800cd4:	e8 ef 11 00 00       	call   801ec8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cec:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cf1:	89 d1                	mov    %edx,%ecx
  800cf3:	89 d3                	mov    %edx,%ebx
  800cf5:	89 d7                	mov    %edx,%edi
  800cf7:	89 d6                	mov    %edx,%esi
  800cf9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 df                	mov    %ebx,%edi
  800d1b:	89 de                	mov    %ebx,%esi
  800d1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 17                	jle    800d3a <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	50                   	push   %eax
  800d27:	6a 0f                	push   $0xf
  800d29:	68 1f 26 80 00       	push   $0x80261f
  800d2e:	6a 23                	push   $0x23
  800d30:	68 3c 26 80 00       	push   $0x80263c
  800d35:	e8 8e 11 00 00       	call   801ec8 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d50:	b8 10 00 00 00       	mov    $0x10,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 df                	mov    %ebx,%edi
  800d5d:	89 de                	mov    %ebx,%esi
  800d5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 17                	jle    800d7c <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	50                   	push   %eax
  800d69:	6a 10                	push   $0x10
  800d6b:	68 1f 26 80 00       	push   $0x80261f
  800d70:	6a 23                	push   $0x23
  800d72:	68 3c 26 80 00       	push   $0x80263c
  800d77:	e8 4c 11 00 00       	call   801ec8 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d8f:	c1 e8 0c             	shr    $0xc,%eax
}
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800da4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800db6:	89 c2                	mov    %eax,%edx
  800db8:	c1 ea 16             	shr    $0x16,%edx
  800dbb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc2:	f6 c2 01             	test   $0x1,%dl
  800dc5:	74 11                	je     800dd8 <fd_alloc+0x2d>
  800dc7:	89 c2                	mov    %eax,%edx
  800dc9:	c1 ea 0c             	shr    $0xc,%edx
  800dcc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd3:	f6 c2 01             	test   $0x1,%dl
  800dd6:	75 09                	jne    800de1 <fd_alloc+0x36>
			*fd_store = fd;
  800dd8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dda:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddf:	eb 17                	jmp    800df8 <fd_alloc+0x4d>
  800de1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800de6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800deb:	75 c9                	jne    800db6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ded:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800df3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e00:	83 f8 1f             	cmp    $0x1f,%eax
  800e03:	77 36                	ja     800e3b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e05:	c1 e0 0c             	shl    $0xc,%eax
  800e08:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	c1 ea 16             	shr    $0x16,%edx
  800e12:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e19:	f6 c2 01             	test   $0x1,%dl
  800e1c:	74 24                	je     800e42 <fd_lookup+0x48>
  800e1e:	89 c2                	mov    %eax,%edx
  800e20:	c1 ea 0c             	shr    $0xc,%edx
  800e23:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2a:	f6 c2 01             	test   $0x1,%dl
  800e2d:	74 1a                	je     800e49 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e32:	89 02                	mov    %eax,(%edx)
	return 0;
  800e34:	b8 00 00 00 00       	mov    $0x0,%eax
  800e39:	eb 13                	jmp    800e4e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e40:	eb 0c                	jmp    800e4e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e47:	eb 05                	jmp    800e4e <fd_lookup+0x54>
  800e49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e59:	ba c8 26 80 00       	mov    $0x8026c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e5e:	eb 13                	jmp    800e73 <dev_lookup+0x23>
  800e60:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e63:	39 08                	cmp    %ecx,(%eax)
  800e65:	75 0c                	jne    800e73 <dev_lookup+0x23>
			*dev = devtab[i];
  800e67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e71:	eb 2e                	jmp    800ea1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e73:	8b 02                	mov    (%edx),%eax
  800e75:	85 c0                	test   %eax,%eax
  800e77:	75 e7                	jne    800e60 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e79:	a1 08 40 80 00       	mov    0x804008,%eax
  800e7e:	8b 40 48             	mov    0x48(%eax),%eax
  800e81:	83 ec 04             	sub    $0x4,%esp
  800e84:	51                   	push   %ecx
  800e85:	50                   	push   %eax
  800e86:	68 4c 26 80 00       	push   $0x80264c
  800e8b:	e8 d8 f2 ff ff       	call   800168 <cprintf>
	*dev = 0;
  800e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e93:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	56                   	push   %esi
  800ea7:	53                   	push   %ebx
  800ea8:	83 ec 10             	sub    $0x10,%esp
  800eab:	8b 75 08             	mov    0x8(%ebp),%esi
  800eae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb4:	50                   	push   %eax
  800eb5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ebb:	c1 e8 0c             	shr    $0xc,%eax
  800ebe:	50                   	push   %eax
  800ebf:	e8 36 ff ff ff       	call   800dfa <fd_lookup>
  800ec4:	83 c4 08             	add    $0x8,%esp
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	78 05                	js     800ed0 <fd_close+0x2d>
	    || fd != fd2)
  800ecb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ece:	74 0c                	je     800edc <fd_close+0x39>
		return (must_exist ? r : 0);
  800ed0:	84 db                	test   %bl,%bl
  800ed2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed7:	0f 44 c2             	cmove  %edx,%eax
  800eda:	eb 41                	jmp    800f1d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800edc:	83 ec 08             	sub    $0x8,%esp
  800edf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ee2:	50                   	push   %eax
  800ee3:	ff 36                	pushl  (%esi)
  800ee5:	e8 66 ff ff ff       	call   800e50 <dev_lookup>
  800eea:	89 c3                	mov    %eax,%ebx
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	78 1a                	js     800f0d <fd_close+0x6a>
		if (dev->dev_close)
  800ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ef9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800efe:	85 c0                	test   %eax,%eax
  800f00:	74 0b                	je     800f0d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f02:	83 ec 0c             	sub    $0xc,%esp
  800f05:	56                   	push   %esi
  800f06:	ff d0                	call   *%eax
  800f08:	89 c3                	mov    %eax,%ebx
  800f0a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f0d:	83 ec 08             	sub    $0x8,%esp
  800f10:	56                   	push   %esi
  800f11:	6a 00                	push   $0x0
  800f13:	e8 5d fc ff ff       	call   800b75 <sys_page_unmap>
	return r;
  800f18:	83 c4 10             	add    $0x10,%esp
  800f1b:	89 d8                	mov    %ebx,%eax
}
  800f1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    

00800f24 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2d:	50                   	push   %eax
  800f2e:	ff 75 08             	pushl  0x8(%ebp)
  800f31:	e8 c4 fe ff ff       	call   800dfa <fd_lookup>
  800f36:	83 c4 08             	add    $0x8,%esp
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	78 10                	js     800f4d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f3d:	83 ec 08             	sub    $0x8,%esp
  800f40:	6a 01                	push   $0x1
  800f42:	ff 75 f4             	pushl  -0xc(%ebp)
  800f45:	e8 59 ff ff ff       	call   800ea3 <fd_close>
  800f4a:	83 c4 10             	add    $0x10,%esp
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <close_all>:

void
close_all(void)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	53                   	push   %ebx
  800f53:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f56:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f5b:	83 ec 0c             	sub    $0xc,%esp
  800f5e:	53                   	push   %ebx
  800f5f:	e8 c0 ff ff ff       	call   800f24 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f64:	83 c3 01             	add    $0x1,%ebx
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	83 fb 20             	cmp    $0x20,%ebx
  800f6d:	75 ec                	jne    800f5b <close_all+0xc>
		close(i);
}
  800f6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	57                   	push   %edi
  800f78:	56                   	push   %esi
  800f79:	53                   	push   %ebx
  800f7a:	83 ec 2c             	sub    $0x2c,%esp
  800f7d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f80:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f83:	50                   	push   %eax
  800f84:	ff 75 08             	pushl  0x8(%ebp)
  800f87:	e8 6e fe ff ff       	call   800dfa <fd_lookup>
  800f8c:	83 c4 08             	add    $0x8,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	0f 88 c1 00 00 00    	js     801058 <dup+0xe4>
		return r;
	close(newfdnum);
  800f97:	83 ec 0c             	sub    $0xc,%esp
  800f9a:	56                   	push   %esi
  800f9b:	e8 84 ff ff ff       	call   800f24 <close>

	newfd = INDEX2FD(newfdnum);
  800fa0:	89 f3                	mov    %esi,%ebx
  800fa2:	c1 e3 0c             	shl    $0xc,%ebx
  800fa5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fab:	83 c4 04             	add    $0x4,%esp
  800fae:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb1:	e8 de fd ff ff       	call   800d94 <fd2data>
  800fb6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fb8:	89 1c 24             	mov    %ebx,(%esp)
  800fbb:	e8 d4 fd ff ff       	call   800d94 <fd2data>
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fc6:	89 f8                	mov    %edi,%eax
  800fc8:	c1 e8 16             	shr    $0x16,%eax
  800fcb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd2:	a8 01                	test   $0x1,%al
  800fd4:	74 37                	je     80100d <dup+0x99>
  800fd6:	89 f8                	mov    %edi,%eax
  800fd8:	c1 e8 0c             	shr    $0xc,%eax
  800fdb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe2:	f6 c2 01             	test   $0x1,%dl
  800fe5:	74 26                	je     80100d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fe7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff6:	50                   	push   %eax
  800ff7:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ffa:	6a 00                	push   $0x0
  800ffc:	57                   	push   %edi
  800ffd:	6a 00                	push   $0x0
  800fff:	e8 2f fb ff ff       	call   800b33 <sys_page_map>
  801004:	89 c7                	mov    %eax,%edi
  801006:	83 c4 20             	add    $0x20,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 2e                	js     80103b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80100d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801010:	89 d0                	mov    %edx,%eax
  801012:	c1 e8 0c             	shr    $0xc,%eax
  801015:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	25 07 0e 00 00       	and    $0xe07,%eax
  801024:	50                   	push   %eax
  801025:	53                   	push   %ebx
  801026:	6a 00                	push   $0x0
  801028:	52                   	push   %edx
  801029:	6a 00                	push   $0x0
  80102b:	e8 03 fb ff ff       	call   800b33 <sys_page_map>
  801030:	89 c7                	mov    %eax,%edi
  801032:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801035:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801037:	85 ff                	test   %edi,%edi
  801039:	79 1d                	jns    801058 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80103b:	83 ec 08             	sub    $0x8,%esp
  80103e:	53                   	push   %ebx
  80103f:	6a 00                	push   $0x0
  801041:	e8 2f fb ff ff       	call   800b75 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801046:	83 c4 08             	add    $0x8,%esp
  801049:	ff 75 d4             	pushl  -0x2c(%ebp)
  80104c:	6a 00                	push   $0x0
  80104e:	e8 22 fb ff ff       	call   800b75 <sys_page_unmap>
	return r;
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	89 f8                	mov    %edi,%eax
}
  801058:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	53                   	push   %ebx
  801064:	83 ec 14             	sub    $0x14,%esp
  801067:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80106a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106d:	50                   	push   %eax
  80106e:	53                   	push   %ebx
  80106f:	e8 86 fd ff ff       	call   800dfa <fd_lookup>
  801074:	83 c4 08             	add    $0x8,%esp
  801077:	89 c2                	mov    %eax,%edx
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 6d                	js     8010ea <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80107d:	83 ec 08             	sub    $0x8,%esp
  801080:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801083:	50                   	push   %eax
  801084:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801087:	ff 30                	pushl  (%eax)
  801089:	e8 c2 fd ff ff       	call   800e50 <dev_lookup>
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	78 4c                	js     8010e1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801095:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801098:	8b 42 08             	mov    0x8(%edx),%eax
  80109b:	83 e0 03             	and    $0x3,%eax
  80109e:	83 f8 01             	cmp    $0x1,%eax
  8010a1:	75 21                	jne    8010c4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010a3:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a8:	8b 40 48             	mov    0x48(%eax),%eax
  8010ab:	83 ec 04             	sub    $0x4,%esp
  8010ae:	53                   	push   %ebx
  8010af:	50                   	push   %eax
  8010b0:	68 8d 26 80 00       	push   $0x80268d
  8010b5:	e8 ae f0 ff ff       	call   800168 <cprintf>
		return -E_INVAL;
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010c2:	eb 26                	jmp    8010ea <read+0x8a>
	}
	if (!dev->dev_read)
  8010c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c7:	8b 40 08             	mov    0x8(%eax),%eax
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	74 17                	je     8010e5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010ce:	83 ec 04             	sub    $0x4,%esp
  8010d1:	ff 75 10             	pushl  0x10(%ebp)
  8010d4:	ff 75 0c             	pushl  0xc(%ebp)
  8010d7:	52                   	push   %edx
  8010d8:	ff d0                	call   *%eax
  8010da:	89 c2                	mov    %eax,%edx
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	eb 09                	jmp    8010ea <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e1:	89 c2                	mov    %eax,%edx
  8010e3:	eb 05                	jmp    8010ea <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010ea:	89 d0                	mov    %edx,%eax
  8010ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	57                   	push   %edi
  8010f5:	56                   	push   %esi
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010fd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801100:	bb 00 00 00 00       	mov    $0x0,%ebx
  801105:	eb 21                	jmp    801128 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801107:	83 ec 04             	sub    $0x4,%esp
  80110a:	89 f0                	mov    %esi,%eax
  80110c:	29 d8                	sub    %ebx,%eax
  80110e:	50                   	push   %eax
  80110f:	89 d8                	mov    %ebx,%eax
  801111:	03 45 0c             	add    0xc(%ebp),%eax
  801114:	50                   	push   %eax
  801115:	57                   	push   %edi
  801116:	e8 45 ff ff ff       	call   801060 <read>
		if (m < 0)
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 10                	js     801132 <readn+0x41>
			return m;
		if (m == 0)
  801122:	85 c0                	test   %eax,%eax
  801124:	74 0a                	je     801130 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801126:	01 c3                	add    %eax,%ebx
  801128:	39 f3                	cmp    %esi,%ebx
  80112a:	72 db                	jb     801107 <readn+0x16>
  80112c:	89 d8                	mov    %ebx,%eax
  80112e:	eb 02                	jmp    801132 <readn+0x41>
  801130:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801132:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	53                   	push   %ebx
  80113e:	83 ec 14             	sub    $0x14,%esp
  801141:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801144:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801147:	50                   	push   %eax
  801148:	53                   	push   %ebx
  801149:	e8 ac fc ff ff       	call   800dfa <fd_lookup>
  80114e:	83 c4 08             	add    $0x8,%esp
  801151:	89 c2                	mov    %eax,%edx
  801153:	85 c0                	test   %eax,%eax
  801155:	78 68                	js     8011bf <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801157:	83 ec 08             	sub    $0x8,%esp
  80115a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115d:	50                   	push   %eax
  80115e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801161:	ff 30                	pushl  (%eax)
  801163:	e8 e8 fc ff ff       	call   800e50 <dev_lookup>
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	78 47                	js     8011b6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80116f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801172:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801176:	75 21                	jne    801199 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801178:	a1 08 40 80 00       	mov    0x804008,%eax
  80117d:	8b 40 48             	mov    0x48(%eax),%eax
  801180:	83 ec 04             	sub    $0x4,%esp
  801183:	53                   	push   %ebx
  801184:	50                   	push   %eax
  801185:	68 a9 26 80 00       	push   $0x8026a9
  80118a:	e8 d9 ef ff ff       	call   800168 <cprintf>
		return -E_INVAL;
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801197:	eb 26                	jmp    8011bf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801199:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80119c:	8b 52 0c             	mov    0xc(%edx),%edx
  80119f:	85 d2                	test   %edx,%edx
  8011a1:	74 17                	je     8011ba <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011a3:	83 ec 04             	sub    $0x4,%esp
  8011a6:	ff 75 10             	pushl  0x10(%ebp)
  8011a9:	ff 75 0c             	pushl  0xc(%ebp)
  8011ac:	50                   	push   %eax
  8011ad:	ff d2                	call   *%edx
  8011af:	89 c2                	mov    %eax,%edx
  8011b1:	83 c4 10             	add    $0x10,%esp
  8011b4:	eb 09                	jmp    8011bf <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b6:	89 c2                	mov    %eax,%edx
  8011b8:	eb 05                	jmp    8011bf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011bf:	89 d0                	mov    %edx,%eax
  8011c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c4:	c9                   	leave  
  8011c5:	c3                   	ret    

008011c6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011cc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011cf:	50                   	push   %eax
  8011d0:	ff 75 08             	pushl  0x8(%ebp)
  8011d3:	e8 22 fc ff ff       	call   800dfa <fd_lookup>
  8011d8:	83 c4 08             	add    $0x8,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 0e                	js     8011ed <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    

008011ef <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 14             	sub    $0x14,%esp
  8011f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fc:	50                   	push   %eax
  8011fd:	53                   	push   %ebx
  8011fe:	e8 f7 fb ff ff       	call   800dfa <fd_lookup>
  801203:	83 c4 08             	add    $0x8,%esp
  801206:	89 c2                	mov    %eax,%edx
  801208:	85 c0                	test   %eax,%eax
  80120a:	78 65                	js     801271 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120c:	83 ec 08             	sub    $0x8,%esp
  80120f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801212:	50                   	push   %eax
  801213:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801216:	ff 30                	pushl  (%eax)
  801218:	e8 33 fc ff ff       	call   800e50 <dev_lookup>
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	78 44                	js     801268 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801224:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801227:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80122b:	75 21                	jne    80124e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80122d:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801232:	8b 40 48             	mov    0x48(%eax),%eax
  801235:	83 ec 04             	sub    $0x4,%esp
  801238:	53                   	push   %ebx
  801239:	50                   	push   %eax
  80123a:	68 6c 26 80 00       	push   $0x80266c
  80123f:	e8 24 ef ff ff       	call   800168 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124c:	eb 23                	jmp    801271 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80124e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801251:	8b 52 18             	mov    0x18(%edx),%edx
  801254:	85 d2                	test   %edx,%edx
  801256:	74 14                	je     80126c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801258:	83 ec 08             	sub    $0x8,%esp
  80125b:	ff 75 0c             	pushl  0xc(%ebp)
  80125e:	50                   	push   %eax
  80125f:	ff d2                	call   *%edx
  801261:	89 c2                	mov    %eax,%edx
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	eb 09                	jmp    801271 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801268:	89 c2                	mov    %eax,%edx
  80126a:	eb 05                	jmp    801271 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80126c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801271:	89 d0                	mov    %edx,%eax
  801273:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801276:	c9                   	leave  
  801277:	c3                   	ret    

00801278 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	53                   	push   %ebx
  80127c:	83 ec 14             	sub    $0x14,%esp
  80127f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801282:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	ff 75 08             	pushl  0x8(%ebp)
  801289:	e8 6c fb ff ff       	call   800dfa <fd_lookup>
  80128e:	83 c4 08             	add    $0x8,%esp
  801291:	89 c2                	mov    %eax,%edx
  801293:	85 c0                	test   %eax,%eax
  801295:	78 58                	js     8012ef <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801297:	83 ec 08             	sub    $0x8,%esp
  80129a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a1:	ff 30                	pushl  (%eax)
  8012a3:	e8 a8 fb ff ff       	call   800e50 <dev_lookup>
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 37                	js     8012e6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012b6:	74 32                	je     8012ea <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012b8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012bb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012c2:	00 00 00 
	stat->st_isdir = 0;
  8012c5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012cc:	00 00 00 
	stat->st_dev = dev;
  8012cf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012d5:	83 ec 08             	sub    $0x8,%esp
  8012d8:	53                   	push   %ebx
  8012d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8012dc:	ff 50 14             	call   *0x14(%eax)
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	eb 09                	jmp    8012ef <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e6:	89 c2                	mov    %eax,%edx
  8012e8:	eb 05                	jmp    8012ef <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012ef:	89 d0                	mov    %edx,%eax
  8012f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f4:	c9                   	leave  
  8012f5:	c3                   	ret    

008012f6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	56                   	push   %esi
  8012fa:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012fb:	83 ec 08             	sub    $0x8,%esp
  8012fe:	6a 00                	push   $0x0
  801300:	ff 75 08             	pushl  0x8(%ebp)
  801303:	e8 d6 01 00 00       	call   8014de <open>
  801308:	89 c3                	mov    %eax,%ebx
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 1b                	js     80132c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801311:	83 ec 08             	sub    $0x8,%esp
  801314:	ff 75 0c             	pushl  0xc(%ebp)
  801317:	50                   	push   %eax
  801318:	e8 5b ff ff ff       	call   801278 <fstat>
  80131d:	89 c6                	mov    %eax,%esi
	close(fd);
  80131f:	89 1c 24             	mov    %ebx,(%esp)
  801322:	e8 fd fb ff ff       	call   800f24 <close>
	return r;
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	89 f0                	mov    %esi,%eax
}
  80132c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	56                   	push   %esi
  801337:	53                   	push   %ebx
  801338:	89 c6                	mov    %eax,%esi
  80133a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80133c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801343:	75 12                	jne    801357 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801345:	83 ec 0c             	sub    $0xc,%esp
  801348:	6a 01                	push   $0x1
  80134a:	e8 7a 0c 00 00       	call   801fc9 <ipc_find_env>
  80134f:	a3 00 40 80 00       	mov    %eax,0x804000
  801354:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801357:	6a 07                	push   $0x7
  801359:	68 00 50 80 00       	push   $0x805000
  80135e:	56                   	push   %esi
  80135f:	ff 35 00 40 80 00    	pushl  0x804000
  801365:	e8 0b 0c 00 00       	call   801f75 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80136a:	83 c4 0c             	add    $0xc,%esp
  80136d:	6a 00                	push   $0x0
  80136f:	53                   	push   %ebx
  801370:	6a 00                	push   $0x0
  801372:	e8 97 0b 00 00       	call   801f0e <ipc_recv>
}
  801377:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137a:	5b                   	pop    %ebx
  80137b:	5e                   	pop    %esi
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    

0080137e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801384:	8b 45 08             	mov    0x8(%ebp),%eax
  801387:	8b 40 0c             	mov    0xc(%eax),%eax
  80138a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80138f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801392:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801397:	ba 00 00 00 00       	mov    $0x0,%edx
  80139c:	b8 02 00 00 00       	mov    $0x2,%eax
  8013a1:	e8 8d ff ff ff       	call   801333 <fsipc>
}
  8013a6:	c9                   	leave  
  8013a7:	c3                   	ret    

008013a8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013be:	b8 06 00 00 00       	mov    $0x6,%eax
  8013c3:	e8 6b ff ff ff       	call   801333 <fsipc>
}
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 04             	sub    $0x4,%esp
  8013d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013da:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013df:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8013e9:	e8 45 ff ff ff       	call   801333 <fsipc>
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 2c                	js     80141e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	68 00 50 80 00       	push   $0x805000
  8013fa:	53                   	push   %ebx
  8013fb:	e8 ed f2 ff ff       	call   8006ed <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801400:	a1 80 50 80 00       	mov    0x805080,%eax
  801405:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80140b:	a1 84 50 80 00       	mov    0x805084,%eax
  801410:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80141e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80142c:	8b 55 08             	mov    0x8(%ebp),%edx
  80142f:	8b 52 0c             	mov    0xc(%edx),%edx
  801432:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801438:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80143d:	50                   	push   %eax
  80143e:	ff 75 0c             	pushl  0xc(%ebp)
  801441:	68 08 50 80 00       	push   $0x805008
  801446:	e8 34 f4 ff ff       	call   80087f <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80144b:	ba 00 00 00 00       	mov    $0x0,%edx
  801450:	b8 04 00 00 00       	mov    $0x4,%eax
  801455:	e8 d9 fe ff ff       	call   801333 <fsipc>

}
  80145a:	c9                   	leave  
  80145b:	c3                   	ret    

0080145c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	56                   	push   %esi
  801460:	53                   	push   %ebx
  801461:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801464:	8b 45 08             	mov    0x8(%ebp),%eax
  801467:	8b 40 0c             	mov    0xc(%eax),%eax
  80146a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80146f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801475:	ba 00 00 00 00       	mov    $0x0,%edx
  80147a:	b8 03 00 00 00       	mov    $0x3,%eax
  80147f:	e8 af fe ff ff       	call   801333 <fsipc>
  801484:	89 c3                	mov    %eax,%ebx
  801486:	85 c0                	test   %eax,%eax
  801488:	78 4b                	js     8014d5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80148a:	39 c6                	cmp    %eax,%esi
  80148c:	73 16                	jae    8014a4 <devfile_read+0x48>
  80148e:	68 dc 26 80 00       	push   $0x8026dc
  801493:	68 e3 26 80 00       	push   $0x8026e3
  801498:	6a 7c                	push   $0x7c
  80149a:	68 f8 26 80 00       	push   $0x8026f8
  80149f:	e8 24 0a 00 00       	call   801ec8 <_panic>
	assert(r <= PGSIZE);
  8014a4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014a9:	7e 16                	jle    8014c1 <devfile_read+0x65>
  8014ab:	68 03 27 80 00       	push   $0x802703
  8014b0:	68 e3 26 80 00       	push   $0x8026e3
  8014b5:	6a 7d                	push   $0x7d
  8014b7:	68 f8 26 80 00       	push   $0x8026f8
  8014bc:	e8 07 0a 00 00       	call   801ec8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014c1:	83 ec 04             	sub    $0x4,%esp
  8014c4:	50                   	push   %eax
  8014c5:	68 00 50 80 00       	push   $0x805000
  8014ca:	ff 75 0c             	pushl  0xc(%ebp)
  8014cd:	e8 ad f3 ff ff       	call   80087f <memmove>
	return r;
  8014d2:	83 c4 10             	add    $0x10,%esp
}
  8014d5:	89 d8                	mov    %ebx,%eax
  8014d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014da:	5b                   	pop    %ebx
  8014db:	5e                   	pop    %esi
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    

008014de <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	53                   	push   %ebx
  8014e2:	83 ec 20             	sub    $0x20,%esp
  8014e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014e8:	53                   	push   %ebx
  8014e9:	e8 c6 f1 ff ff       	call   8006b4 <strlen>
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014f6:	7f 67                	jg     80155f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014f8:	83 ec 0c             	sub    $0xc,%esp
  8014fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	e8 a7 f8 ff ff       	call   800dab <fd_alloc>
  801504:	83 c4 10             	add    $0x10,%esp
		return r;
  801507:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 57                	js     801564 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80150d:	83 ec 08             	sub    $0x8,%esp
  801510:	53                   	push   %ebx
  801511:	68 00 50 80 00       	push   $0x805000
  801516:	e8 d2 f1 ff ff       	call   8006ed <strcpy>
	fsipcbuf.open.req_omode = mode;
  80151b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801523:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801526:	b8 01 00 00 00       	mov    $0x1,%eax
  80152b:	e8 03 fe ff ff       	call   801333 <fsipc>
  801530:	89 c3                	mov    %eax,%ebx
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	85 c0                	test   %eax,%eax
  801537:	79 14                	jns    80154d <open+0x6f>
		fd_close(fd, 0);
  801539:	83 ec 08             	sub    $0x8,%esp
  80153c:	6a 00                	push   $0x0
  80153e:	ff 75 f4             	pushl  -0xc(%ebp)
  801541:	e8 5d f9 ff ff       	call   800ea3 <fd_close>
		return r;
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	89 da                	mov    %ebx,%edx
  80154b:	eb 17                	jmp    801564 <open+0x86>
	}

	return fd2num(fd);
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	ff 75 f4             	pushl  -0xc(%ebp)
  801553:	e8 2c f8 ff ff       	call   800d84 <fd2num>
  801558:	89 c2                	mov    %eax,%edx
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	eb 05                	jmp    801564 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80155f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801564:	89 d0                	mov    %edx,%eax
  801566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801571:	ba 00 00 00 00       	mov    $0x0,%edx
  801576:	b8 08 00 00 00       	mov    $0x8,%eax
  80157b:	e8 b3 fd ff ff       	call   801333 <fsipc>
}
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801588:	68 0f 27 80 00       	push   $0x80270f
  80158d:	ff 75 0c             	pushl  0xc(%ebp)
  801590:	e8 58 f1 ff ff       	call   8006ed <strcpy>
	return 0;
}
  801595:	b8 00 00 00 00       	mov    $0x0,%eax
  80159a:	c9                   	leave  
  80159b:	c3                   	ret    

0080159c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	53                   	push   %ebx
  8015a0:	83 ec 10             	sub    $0x10,%esp
  8015a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015a6:	53                   	push   %ebx
  8015a7:	e8 56 0a 00 00       	call   802002 <pageref>
  8015ac:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015af:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8015b4:	83 f8 01             	cmp    $0x1,%eax
  8015b7:	75 10                	jne    8015c9 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015b9:	83 ec 0c             	sub    $0xc,%esp
  8015bc:	ff 73 0c             	pushl  0xc(%ebx)
  8015bf:	e8 c0 02 00 00       	call   801884 <nsipc_close>
  8015c4:	89 c2                	mov    %eax,%edx
  8015c6:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015c9:	89 d0                	mov    %edx,%eax
  8015cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ce:	c9                   	leave  
  8015cf:	c3                   	ret    

008015d0 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015d6:	6a 00                	push   $0x0
  8015d8:	ff 75 10             	pushl  0x10(%ebp)
  8015db:	ff 75 0c             	pushl  0xc(%ebp)
  8015de:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e1:	ff 70 0c             	pushl  0xc(%eax)
  8015e4:	e8 78 03 00 00       	call   801961 <nsipc_send>
}
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    

008015eb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015f1:	6a 00                	push   $0x0
  8015f3:	ff 75 10             	pushl  0x10(%ebp)
  8015f6:	ff 75 0c             	pushl  0xc(%ebp)
  8015f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fc:	ff 70 0c             	pushl  0xc(%eax)
  8015ff:	e8 f1 02 00 00       	call   8018f5 <nsipc_recv>
}
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80160c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80160f:	52                   	push   %edx
  801610:	50                   	push   %eax
  801611:	e8 e4 f7 ff ff       	call   800dfa <fd_lookup>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 17                	js     801634 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80161d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801620:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801626:	39 08                	cmp    %ecx,(%eax)
  801628:	75 05                	jne    80162f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80162a:	8b 40 0c             	mov    0xc(%eax),%eax
  80162d:	eb 05                	jmp    801634 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80162f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801634:	c9                   	leave  
  801635:	c3                   	ret    

00801636 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	56                   	push   %esi
  80163a:	53                   	push   %ebx
  80163b:	83 ec 1c             	sub    $0x1c,%esp
  80163e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801640:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	e8 62 f7 ff ff       	call   800dab <fd_alloc>
  801649:	89 c3                	mov    %eax,%ebx
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	85 c0                	test   %eax,%eax
  801650:	78 1b                	js     80166d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801652:	83 ec 04             	sub    $0x4,%esp
  801655:	68 07 04 00 00       	push   $0x407
  80165a:	ff 75 f4             	pushl  -0xc(%ebp)
  80165d:	6a 00                	push   $0x0
  80165f:	e8 8c f4 ff ff       	call   800af0 <sys_page_alloc>
  801664:	89 c3                	mov    %eax,%ebx
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	85 c0                	test   %eax,%eax
  80166b:	79 10                	jns    80167d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80166d:	83 ec 0c             	sub    $0xc,%esp
  801670:	56                   	push   %esi
  801671:	e8 0e 02 00 00       	call   801884 <nsipc_close>
		return r;
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	89 d8                	mov    %ebx,%eax
  80167b:	eb 24                	jmp    8016a1 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80167d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801683:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801686:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801688:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801692:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801695:	83 ec 0c             	sub    $0xc,%esp
  801698:	50                   	push   %eax
  801699:	e8 e6 f6 ff ff       	call   800d84 <fd2num>
  80169e:	83 c4 10             	add    $0x10,%esp
}
  8016a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5e                   	pop    %esi
  8016a6:	5d                   	pop    %ebp
  8016a7:	c3                   	ret    

008016a8 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b1:	e8 50 ff ff ff       	call   801606 <fd2sockid>
		return r;
  8016b6:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 1f                	js     8016db <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016bc:	83 ec 04             	sub    $0x4,%esp
  8016bf:	ff 75 10             	pushl  0x10(%ebp)
  8016c2:	ff 75 0c             	pushl  0xc(%ebp)
  8016c5:	50                   	push   %eax
  8016c6:	e8 12 01 00 00       	call   8017dd <nsipc_accept>
  8016cb:	83 c4 10             	add    $0x10,%esp
		return r;
  8016ce:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	78 07                	js     8016db <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016d4:	e8 5d ff ff ff       	call   801636 <alloc_sockfd>
  8016d9:	89 c1                	mov    %eax,%ecx
}
  8016db:	89 c8                	mov    %ecx,%eax
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e8:	e8 19 ff ff ff       	call   801606 <fd2sockid>
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	78 12                	js     801703 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8016f1:	83 ec 04             	sub    $0x4,%esp
  8016f4:	ff 75 10             	pushl  0x10(%ebp)
  8016f7:	ff 75 0c             	pushl  0xc(%ebp)
  8016fa:	50                   	push   %eax
  8016fb:	e8 2d 01 00 00       	call   80182d <nsipc_bind>
  801700:	83 c4 10             	add    $0x10,%esp
}
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <shutdown>:

int
shutdown(int s, int how)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80170b:	8b 45 08             	mov    0x8(%ebp),%eax
  80170e:	e8 f3 fe ff ff       	call   801606 <fd2sockid>
  801713:	85 c0                	test   %eax,%eax
  801715:	78 0f                	js     801726 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801717:	83 ec 08             	sub    $0x8,%esp
  80171a:	ff 75 0c             	pushl  0xc(%ebp)
  80171d:	50                   	push   %eax
  80171e:	e8 3f 01 00 00       	call   801862 <nsipc_shutdown>
  801723:	83 c4 10             	add    $0x10,%esp
}
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80172e:	8b 45 08             	mov    0x8(%ebp),%eax
  801731:	e8 d0 fe ff ff       	call   801606 <fd2sockid>
  801736:	85 c0                	test   %eax,%eax
  801738:	78 12                	js     80174c <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80173a:	83 ec 04             	sub    $0x4,%esp
  80173d:	ff 75 10             	pushl  0x10(%ebp)
  801740:	ff 75 0c             	pushl  0xc(%ebp)
  801743:	50                   	push   %eax
  801744:	e8 55 01 00 00       	call   80189e <nsipc_connect>
  801749:	83 c4 10             	add    $0x10,%esp
}
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <listen>:

int
listen(int s, int backlog)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801754:	8b 45 08             	mov    0x8(%ebp),%eax
  801757:	e8 aa fe ff ff       	call   801606 <fd2sockid>
  80175c:	85 c0                	test   %eax,%eax
  80175e:	78 0f                	js     80176f <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801760:	83 ec 08             	sub    $0x8,%esp
  801763:	ff 75 0c             	pushl  0xc(%ebp)
  801766:	50                   	push   %eax
  801767:	e8 67 01 00 00       	call   8018d3 <nsipc_listen>
  80176c:	83 c4 10             	add    $0x10,%esp
}
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801777:	ff 75 10             	pushl  0x10(%ebp)
  80177a:	ff 75 0c             	pushl  0xc(%ebp)
  80177d:	ff 75 08             	pushl  0x8(%ebp)
  801780:	e8 3a 02 00 00       	call   8019bf <nsipc_socket>
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	85 c0                	test   %eax,%eax
  80178a:	78 05                	js     801791 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80178c:	e8 a5 fe ff ff       	call   801636 <alloc_sockfd>
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	53                   	push   %ebx
  801797:	83 ec 04             	sub    $0x4,%esp
  80179a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80179c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017a3:	75 12                	jne    8017b7 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	6a 02                	push   $0x2
  8017aa:	e8 1a 08 00 00       	call   801fc9 <ipc_find_env>
  8017af:	a3 04 40 80 00       	mov    %eax,0x804004
  8017b4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017b7:	6a 07                	push   $0x7
  8017b9:	68 00 60 80 00       	push   $0x806000
  8017be:	53                   	push   %ebx
  8017bf:	ff 35 04 40 80 00    	pushl  0x804004
  8017c5:	e8 ab 07 00 00       	call   801f75 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017ca:	83 c4 0c             	add    $0xc,%esp
  8017cd:	6a 00                	push   $0x0
  8017cf:	6a 00                	push   $0x0
  8017d1:	6a 00                	push   $0x0
  8017d3:	e8 36 07 00 00       	call   801f0e <ipc_recv>
}
  8017d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017db:	c9                   	leave  
  8017dc:	c3                   	ret    

008017dd <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	56                   	push   %esi
  8017e1:	53                   	push   %ebx
  8017e2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017ed:	8b 06                	mov    (%esi),%eax
  8017ef:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8017f9:	e8 95 ff ff ff       	call   801793 <nsipc>
  8017fe:	89 c3                	mov    %eax,%ebx
  801800:	85 c0                	test   %eax,%eax
  801802:	78 20                	js     801824 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801804:	83 ec 04             	sub    $0x4,%esp
  801807:	ff 35 10 60 80 00    	pushl  0x806010
  80180d:	68 00 60 80 00       	push   $0x806000
  801812:	ff 75 0c             	pushl  0xc(%ebp)
  801815:	e8 65 f0 ff ff       	call   80087f <memmove>
		*addrlen = ret->ret_addrlen;
  80181a:	a1 10 60 80 00       	mov    0x806010,%eax
  80181f:	89 06                	mov    %eax,(%esi)
  801821:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801824:	89 d8                	mov    %ebx,%eax
  801826:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801829:	5b                   	pop    %ebx
  80182a:	5e                   	pop    %esi
  80182b:	5d                   	pop    %ebp
  80182c:	c3                   	ret    

0080182d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	53                   	push   %ebx
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801837:	8b 45 08             	mov    0x8(%ebp),%eax
  80183a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80183f:	53                   	push   %ebx
  801840:	ff 75 0c             	pushl  0xc(%ebp)
  801843:	68 04 60 80 00       	push   $0x806004
  801848:	e8 32 f0 ff ff       	call   80087f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80184d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801853:	b8 02 00 00 00       	mov    $0x2,%eax
  801858:	e8 36 ff ff ff       	call   801793 <nsipc>
}
  80185d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801868:	8b 45 08             	mov    0x8(%ebp),%eax
  80186b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801870:	8b 45 0c             	mov    0xc(%ebp),%eax
  801873:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801878:	b8 03 00 00 00       	mov    $0x3,%eax
  80187d:	e8 11 ff ff ff       	call   801793 <nsipc>
}
  801882:	c9                   	leave  
  801883:	c3                   	ret    

00801884 <nsipc_close>:

int
nsipc_close(int s)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80188a:	8b 45 08             	mov    0x8(%ebp),%eax
  80188d:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801892:	b8 04 00 00 00       	mov    $0x4,%eax
  801897:	e8 f7 fe ff ff       	call   801793 <nsipc>
}
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	53                   	push   %ebx
  8018a2:	83 ec 08             	sub    $0x8,%esp
  8018a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ab:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018b0:	53                   	push   %ebx
  8018b1:	ff 75 0c             	pushl  0xc(%ebp)
  8018b4:	68 04 60 80 00       	push   $0x806004
  8018b9:	e8 c1 ef ff ff       	call   80087f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018be:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8018c9:	e8 c5 fe ff ff       	call   801793 <nsipc>
}
  8018ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d1:	c9                   	leave  
  8018d2:	c3                   	ret    

008018d3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8018e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8018e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ee:	e8 a0 fe ff ff       	call   801793 <nsipc>
}
  8018f3:	c9                   	leave  
  8018f4:	c3                   	ret    

008018f5 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	56                   	push   %esi
  8018f9:	53                   	push   %ebx
  8018fa:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801900:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801905:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80190b:	8b 45 14             	mov    0x14(%ebp),%eax
  80190e:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801913:	b8 07 00 00 00       	mov    $0x7,%eax
  801918:	e8 76 fe ff ff       	call   801793 <nsipc>
  80191d:	89 c3                	mov    %eax,%ebx
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 35                	js     801958 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801923:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801928:	7f 04                	jg     80192e <nsipc_recv+0x39>
  80192a:	39 c6                	cmp    %eax,%esi
  80192c:	7d 16                	jge    801944 <nsipc_recv+0x4f>
  80192e:	68 1b 27 80 00       	push   $0x80271b
  801933:	68 e3 26 80 00       	push   $0x8026e3
  801938:	6a 62                	push   $0x62
  80193a:	68 30 27 80 00       	push   $0x802730
  80193f:	e8 84 05 00 00       	call   801ec8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801944:	83 ec 04             	sub    $0x4,%esp
  801947:	50                   	push   %eax
  801948:	68 00 60 80 00       	push   $0x806000
  80194d:	ff 75 0c             	pushl  0xc(%ebp)
  801950:	e8 2a ef ff ff       	call   80087f <memmove>
  801955:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801958:	89 d8                	mov    %ebx,%eax
  80195a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5e                   	pop    %esi
  80195f:	5d                   	pop    %ebp
  801960:	c3                   	ret    

00801961 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	53                   	push   %ebx
  801965:	83 ec 04             	sub    $0x4,%esp
  801968:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80196b:	8b 45 08             	mov    0x8(%ebp),%eax
  80196e:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801973:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801979:	7e 16                	jle    801991 <nsipc_send+0x30>
  80197b:	68 3c 27 80 00       	push   $0x80273c
  801980:	68 e3 26 80 00       	push   $0x8026e3
  801985:	6a 6d                	push   $0x6d
  801987:	68 30 27 80 00       	push   $0x802730
  80198c:	e8 37 05 00 00       	call   801ec8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801991:	83 ec 04             	sub    $0x4,%esp
  801994:	53                   	push   %ebx
  801995:	ff 75 0c             	pushl  0xc(%ebp)
  801998:	68 0c 60 80 00       	push   $0x80600c
  80199d:	e8 dd ee ff ff       	call   80087f <memmove>
	nsipcbuf.send.req_size = size;
  8019a2:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ab:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019b0:	b8 08 00 00 00       	mov    $0x8,%eax
  8019b5:	e8 d9 fd ff ff       	call   801793 <nsipc>
}
  8019ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d0:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8019d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8019dd:	b8 09 00 00 00       	mov    $0x9,%eax
  8019e2:	e8 ac fd ff ff       	call   801793 <nsipc>
}
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	56                   	push   %esi
  8019ed:	53                   	push   %ebx
  8019ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019f1:	83 ec 0c             	sub    $0xc,%esp
  8019f4:	ff 75 08             	pushl  0x8(%ebp)
  8019f7:	e8 98 f3 ff ff       	call   800d94 <fd2data>
  8019fc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019fe:	83 c4 08             	add    $0x8,%esp
  801a01:	68 48 27 80 00       	push   $0x802748
  801a06:	53                   	push   %ebx
  801a07:	e8 e1 ec ff ff       	call   8006ed <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a0c:	8b 46 04             	mov    0x4(%esi),%eax
  801a0f:	2b 06                	sub    (%esi),%eax
  801a11:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a17:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a1e:	00 00 00 
	stat->st_dev = &devpipe;
  801a21:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a28:	30 80 00 
	return 0;
}
  801a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a33:	5b                   	pop    %ebx
  801a34:	5e                   	pop    %esi
  801a35:	5d                   	pop    %ebp
  801a36:	c3                   	ret    

00801a37 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	53                   	push   %ebx
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a41:	53                   	push   %ebx
  801a42:	6a 00                	push   $0x0
  801a44:	e8 2c f1 ff ff       	call   800b75 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a49:	89 1c 24             	mov    %ebx,(%esp)
  801a4c:	e8 43 f3 ff ff       	call   800d94 <fd2data>
  801a51:	83 c4 08             	add    $0x8,%esp
  801a54:	50                   	push   %eax
  801a55:	6a 00                	push   $0x0
  801a57:	e8 19 f1 ff ff       	call   800b75 <sys_page_unmap>
}
  801a5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5f:	c9                   	leave  
  801a60:	c3                   	ret    

00801a61 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	57                   	push   %edi
  801a65:	56                   	push   %esi
  801a66:	53                   	push   %ebx
  801a67:	83 ec 1c             	sub    $0x1c,%esp
  801a6a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a6d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a6f:	a1 08 40 80 00       	mov    0x804008,%eax
  801a74:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	ff 75 e0             	pushl  -0x20(%ebp)
  801a7d:	e8 80 05 00 00       	call   802002 <pageref>
  801a82:	89 c3                	mov    %eax,%ebx
  801a84:	89 3c 24             	mov    %edi,(%esp)
  801a87:	e8 76 05 00 00       	call   802002 <pageref>
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	39 c3                	cmp    %eax,%ebx
  801a91:	0f 94 c1             	sete   %cl
  801a94:	0f b6 c9             	movzbl %cl,%ecx
  801a97:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a9a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801aa0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801aa3:	39 ce                	cmp    %ecx,%esi
  801aa5:	74 1b                	je     801ac2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aa7:	39 c3                	cmp    %eax,%ebx
  801aa9:	75 c4                	jne    801a6f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aab:	8b 42 58             	mov    0x58(%edx),%eax
  801aae:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ab1:	50                   	push   %eax
  801ab2:	56                   	push   %esi
  801ab3:	68 4f 27 80 00       	push   $0x80274f
  801ab8:	e8 ab e6 ff ff       	call   800168 <cprintf>
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	eb ad                	jmp    801a6f <_pipeisclosed+0xe>
	}
}
  801ac2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac8:	5b                   	pop    %ebx
  801ac9:	5e                   	pop    %esi
  801aca:	5f                   	pop    %edi
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    

00801acd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	57                   	push   %edi
  801ad1:	56                   	push   %esi
  801ad2:	53                   	push   %ebx
  801ad3:	83 ec 28             	sub    $0x28,%esp
  801ad6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ad9:	56                   	push   %esi
  801ada:	e8 b5 f2 ff ff       	call   800d94 <fd2data>
  801adf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	bf 00 00 00 00       	mov    $0x0,%edi
  801ae9:	eb 4b                	jmp    801b36 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aeb:	89 da                	mov    %ebx,%edx
  801aed:	89 f0                	mov    %esi,%eax
  801aef:	e8 6d ff ff ff       	call   801a61 <_pipeisclosed>
  801af4:	85 c0                	test   %eax,%eax
  801af6:	75 48                	jne    801b40 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801af8:	e8 d4 ef ff ff       	call   800ad1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801afd:	8b 43 04             	mov    0x4(%ebx),%eax
  801b00:	8b 0b                	mov    (%ebx),%ecx
  801b02:	8d 51 20             	lea    0x20(%ecx),%edx
  801b05:	39 d0                	cmp    %edx,%eax
  801b07:	73 e2                	jae    801aeb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b10:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b13:	89 c2                	mov    %eax,%edx
  801b15:	c1 fa 1f             	sar    $0x1f,%edx
  801b18:	89 d1                	mov    %edx,%ecx
  801b1a:	c1 e9 1b             	shr    $0x1b,%ecx
  801b1d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b20:	83 e2 1f             	and    $0x1f,%edx
  801b23:	29 ca                	sub    %ecx,%edx
  801b25:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b29:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b2d:	83 c0 01             	add    $0x1,%eax
  801b30:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b33:	83 c7 01             	add    $0x1,%edi
  801b36:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b39:	75 c2                	jne    801afd <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b3b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b3e:	eb 05                	jmp    801b45 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b40:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b48:	5b                   	pop    %ebx
  801b49:	5e                   	pop    %esi
  801b4a:	5f                   	pop    %edi
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    

00801b4d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	57                   	push   %edi
  801b51:	56                   	push   %esi
  801b52:	53                   	push   %ebx
  801b53:	83 ec 18             	sub    $0x18,%esp
  801b56:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b59:	57                   	push   %edi
  801b5a:	e8 35 f2 ff ff       	call   800d94 <fd2data>
  801b5f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b61:	83 c4 10             	add    $0x10,%esp
  801b64:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b69:	eb 3d                	jmp    801ba8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b6b:	85 db                	test   %ebx,%ebx
  801b6d:	74 04                	je     801b73 <devpipe_read+0x26>
				return i;
  801b6f:	89 d8                	mov    %ebx,%eax
  801b71:	eb 44                	jmp    801bb7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b73:	89 f2                	mov    %esi,%edx
  801b75:	89 f8                	mov    %edi,%eax
  801b77:	e8 e5 fe ff ff       	call   801a61 <_pipeisclosed>
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	75 32                	jne    801bb2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b80:	e8 4c ef ff ff       	call   800ad1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b85:	8b 06                	mov    (%esi),%eax
  801b87:	3b 46 04             	cmp    0x4(%esi),%eax
  801b8a:	74 df                	je     801b6b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b8c:	99                   	cltd   
  801b8d:	c1 ea 1b             	shr    $0x1b,%edx
  801b90:	01 d0                	add    %edx,%eax
  801b92:	83 e0 1f             	and    $0x1f,%eax
  801b95:	29 d0                	sub    %edx,%eax
  801b97:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ba2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba5:	83 c3 01             	add    $0x1,%ebx
  801ba8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bab:	75 d8                	jne    801b85 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bad:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb0:	eb 05                	jmp    801bb7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bb2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bba:	5b                   	pop    %ebx
  801bbb:	5e                   	pop    %esi
  801bbc:	5f                   	pop    %edi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bca:	50                   	push   %eax
  801bcb:	e8 db f1 ff ff       	call   800dab <fd_alloc>
  801bd0:	83 c4 10             	add    $0x10,%esp
  801bd3:	89 c2                	mov    %eax,%edx
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	0f 88 2c 01 00 00    	js     801d09 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bdd:	83 ec 04             	sub    $0x4,%esp
  801be0:	68 07 04 00 00       	push   $0x407
  801be5:	ff 75 f4             	pushl  -0xc(%ebp)
  801be8:	6a 00                	push   $0x0
  801bea:	e8 01 ef ff ff       	call   800af0 <sys_page_alloc>
  801bef:	83 c4 10             	add    $0x10,%esp
  801bf2:	89 c2                	mov    %eax,%edx
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	0f 88 0d 01 00 00    	js     801d09 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bfc:	83 ec 0c             	sub    $0xc,%esp
  801bff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c02:	50                   	push   %eax
  801c03:	e8 a3 f1 ff ff       	call   800dab <fd_alloc>
  801c08:	89 c3                	mov    %eax,%ebx
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	0f 88 e2 00 00 00    	js     801cf7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c15:	83 ec 04             	sub    $0x4,%esp
  801c18:	68 07 04 00 00       	push   $0x407
  801c1d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c20:	6a 00                	push   $0x0
  801c22:	e8 c9 ee ff ff       	call   800af0 <sys_page_alloc>
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	83 c4 10             	add    $0x10,%esp
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	0f 88 c3 00 00 00    	js     801cf7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c34:	83 ec 0c             	sub    $0xc,%esp
  801c37:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3a:	e8 55 f1 ff ff       	call   800d94 <fd2data>
  801c3f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c41:	83 c4 0c             	add    $0xc,%esp
  801c44:	68 07 04 00 00       	push   $0x407
  801c49:	50                   	push   %eax
  801c4a:	6a 00                	push   $0x0
  801c4c:	e8 9f ee ff ff       	call   800af0 <sys_page_alloc>
  801c51:	89 c3                	mov    %eax,%ebx
  801c53:	83 c4 10             	add    $0x10,%esp
  801c56:	85 c0                	test   %eax,%eax
  801c58:	0f 88 89 00 00 00    	js     801ce7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5e:	83 ec 0c             	sub    $0xc,%esp
  801c61:	ff 75 f0             	pushl  -0x10(%ebp)
  801c64:	e8 2b f1 ff ff       	call   800d94 <fd2data>
  801c69:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c70:	50                   	push   %eax
  801c71:	6a 00                	push   $0x0
  801c73:	56                   	push   %esi
  801c74:	6a 00                	push   $0x0
  801c76:	e8 b8 ee ff ff       	call   800b33 <sys_page_map>
  801c7b:	89 c3                	mov    %eax,%ebx
  801c7d:	83 c4 20             	add    $0x20,%esp
  801c80:	85 c0                	test   %eax,%eax
  801c82:	78 55                	js     801cd9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c84:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c92:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c99:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cae:	83 ec 0c             	sub    $0xc,%esp
  801cb1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb4:	e8 cb f0 ff ff       	call   800d84 <fd2num>
  801cb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cbe:	83 c4 04             	add    $0x4,%esp
  801cc1:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc4:	e8 bb f0 ff ff       	call   800d84 <fd2num>
  801cc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd7:	eb 30                	jmp    801d09 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cd9:	83 ec 08             	sub    $0x8,%esp
  801cdc:	56                   	push   %esi
  801cdd:	6a 00                	push   $0x0
  801cdf:	e8 91 ee ff ff       	call   800b75 <sys_page_unmap>
  801ce4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ce7:	83 ec 08             	sub    $0x8,%esp
  801cea:	ff 75 f0             	pushl  -0x10(%ebp)
  801ced:	6a 00                	push   $0x0
  801cef:	e8 81 ee ff ff       	call   800b75 <sys_page_unmap>
  801cf4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cf7:	83 ec 08             	sub    $0x8,%esp
  801cfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfd:	6a 00                	push   $0x0
  801cff:	e8 71 ee ff ff       	call   800b75 <sys_page_unmap>
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d09:	89 d0                	mov    %edx,%eax
  801d0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0e:	5b                   	pop    %ebx
  801d0f:	5e                   	pop    %esi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    

00801d12 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1b:	50                   	push   %eax
  801d1c:	ff 75 08             	pushl  0x8(%ebp)
  801d1f:	e8 d6 f0 ff ff       	call   800dfa <fd_lookup>
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	85 c0                	test   %eax,%eax
  801d29:	78 18                	js     801d43 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d2b:	83 ec 0c             	sub    $0xc,%esp
  801d2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d31:	e8 5e f0 ff ff       	call   800d94 <fd2data>
	return _pipeisclosed(fd, p);
  801d36:	89 c2                	mov    %eax,%edx
  801d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3b:	e8 21 fd ff ff       	call   801a61 <_pipeisclosed>
  801d40:	83 c4 10             	add    $0x10,%esp
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d48:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4d:	5d                   	pop    %ebp
  801d4e:	c3                   	ret    

00801d4f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d55:	68 67 27 80 00       	push   $0x802767
  801d5a:	ff 75 0c             	pushl  0xc(%ebp)
  801d5d:	e8 8b e9 ff ff       	call   8006ed <strcpy>
	return 0;
}
  801d62:	b8 00 00 00 00       	mov    $0x0,%eax
  801d67:	c9                   	leave  
  801d68:	c3                   	ret    

00801d69 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	57                   	push   %edi
  801d6d:	56                   	push   %esi
  801d6e:	53                   	push   %ebx
  801d6f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d75:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d7a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d80:	eb 2d                	jmp    801daf <devcons_write+0x46>
		m = n - tot;
  801d82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d85:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d87:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d8a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d8f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d92:	83 ec 04             	sub    $0x4,%esp
  801d95:	53                   	push   %ebx
  801d96:	03 45 0c             	add    0xc(%ebp),%eax
  801d99:	50                   	push   %eax
  801d9a:	57                   	push   %edi
  801d9b:	e8 df ea ff ff       	call   80087f <memmove>
		sys_cputs(buf, m);
  801da0:	83 c4 08             	add    $0x8,%esp
  801da3:	53                   	push   %ebx
  801da4:	57                   	push   %edi
  801da5:	e8 8a ec ff ff       	call   800a34 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801daa:	01 de                	add    %ebx,%esi
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	89 f0                	mov    %esi,%eax
  801db1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801db4:	72 cc                	jb     801d82 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801db6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db9:	5b                   	pop    %ebx
  801dba:	5e                   	pop    %esi
  801dbb:	5f                   	pop    %edi
  801dbc:	5d                   	pop    %ebp
  801dbd:	c3                   	ret    

00801dbe <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	83 ec 08             	sub    $0x8,%esp
  801dc4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dc9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dcd:	74 2a                	je     801df9 <devcons_read+0x3b>
  801dcf:	eb 05                	jmp    801dd6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dd1:	e8 fb ec ff ff       	call   800ad1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dd6:	e8 77 ec ff ff       	call   800a52 <sys_cgetc>
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	74 f2                	je     801dd1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	78 16                	js     801df9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801de3:	83 f8 04             	cmp    $0x4,%eax
  801de6:	74 0c                	je     801df4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801de8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801deb:	88 02                	mov    %al,(%edx)
	return 1;
  801ded:	b8 01 00 00 00       	mov    $0x1,%eax
  801df2:	eb 05                	jmp    801df9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801df4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e01:	8b 45 08             	mov    0x8(%ebp),%eax
  801e04:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e07:	6a 01                	push   $0x1
  801e09:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0c:	50                   	push   %eax
  801e0d:	e8 22 ec ff ff       	call   800a34 <sys_cputs>
}
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    

00801e17 <getchar>:

int
getchar(void)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e1d:	6a 01                	push   $0x1
  801e1f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e22:	50                   	push   %eax
  801e23:	6a 00                	push   $0x0
  801e25:	e8 36 f2 ff ff       	call   801060 <read>
	if (r < 0)
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	78 0f                	js     801e40 <getchar+0x29>
		return r;
	if (r < 1)
  801e31:	85 c0                	test   %eax,%eax
  801e33:	7e 06                	jle    801e3b <getchar+0x24>
		return -E_EOF;
	return c;
  801e35:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e39:	eb 05                	jmp    801e40 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e3b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e40:	c9                   	leave  
  801e41:	c3                   	ret    

00801e42 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4b:	50                   	push   %eax
  801e4c:	ff 75 08             	pushl  0x8(%ebp)
  801e4f:	e8 a6 ef ff ff       	call   800dfa <fd_lookup>
  801e54:	83 c4 10             	add    $0x10,%esp
  801e57:	85 c0                	test   %eax,%eax
  801e59:	78 11                	js     801e6c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e64:	39 10                	cmp    %edx,(%eax)
  801e66:	0f 94 c0             	sete   %al
  801e69:	0f b6 c0             	movzbl %al,%eax
}
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <opencons>:

int
opencons(void)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e77:	50                   	push   %eax
  801e78:	e8 2e ef ff ff       	call   800dab <fd_alloc>
  801e7d:	83 c4 10             	add    $0x10,%esp
		return r;
  801e80:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e82:	85 c0                	test   %eax,%eax
  801e84:	78 3e                	js     801ec4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e86:	83 ec 04             	sub    $0x4,%esp
  801e89:	68 07 04 00 00       	push   $0x407
  801e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e91:	6a 00                	push   $0x0
  801e93:	e8 58 ec ff ff       	call   800af0 <sys_page_alloc>
  801e98:	83 c4 10             	add    $0x10,%esp
		return r;
  801e9b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	78 23                	js     801ec4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ea1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eaa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eaf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eb6:	83 ec 0c             	sub    $0xc,%esp
  801eb9:	50                   	push   %eax
  801eba:	e8 c5 ee ff ff       	call   800d84 <fd2num>
  801ebf:	89 c2                	mov    %eax,%edx
  801ec1:	83 c4 10             	add    $0x10,%esp
}
  801ec4:	89 d0                	mov    %edx,%eax
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	56                   	push   %esi
  801ecc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ecd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ed0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ed6:	e8 d7 eb ff ff       	call   800ab2 <sys_getenvid>
  801edb:	83 ec 0c             	sub    $0xc,%esp
  801ede:	ff 75 0c             	pushl  0xc(%ebp)
  801ee1:	ff 75 08             	pushl  0x8(%ebp)
  801ee4:	56                   	push   %esi
  801ee5:	50                   	push   %eax
  801ee6:	68 74 27 80 00       	push   $0x802774
  801eeb:	e8 78 e2 ff ff       	call   800168 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ef0:	83 c4 18             	add    $0x18,%esp
  801ef3:	53                   	push   %ebx
  801ef4:	ff 75 10             	pushl  0x10(%ebp)
  801ef7:	e8 1b e2 ff ff       	call   800117 <vcprintf>
	cprintf("\n");
  801efc:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  801f03:	e8 60 e2 ff ff       	call   800168 <cprintf>
  801f08:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f0b:	cc                   	int3   
  801f0c:	eb fd                	jmp    801f0b <_panic+0x43>

00801f0e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	56                   	push   %esi
  801f12:	53                   	push   %ebx
  801f13:	8b 75 08             	mov    0x8(%ebp),%esi
  801f16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f1c:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f1e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f23:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f26:	83 ec 0c             	sub    $0xc,%esp
  801f29:	50                   	push   %eax
  801f2a:	e8 71 ed ff ff       	call   800ca0 <sys_ipc_recv>

	if (from_env_store != NULL)
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	85 f6                	test   %esi,%esi
  801f34:	74 14                	je     801f4a <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f36:	ba 00 00 00 00       	mov    $0x0,%edx
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	78 09                	js     801f48 <ipc_recv+0x3a>
  801f3f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f45:	8b 52 74             	mov    0x74(%edx),%edx
  801f48:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f4a:	85 db                	test   %ebx,%ebx
  801f4c:	74 14                	je     801f62 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801f53:	85 c0                	test   %eax,%eax
  801f55:	78 09                	js     801f60 <ipc_recv+0x52>
  801f57:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f5d:	8b 52 78             	mov    0x78(%edx),%edx
  801f60:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f62:	85 c0                	test   %eax,%eax
  801f64:	78 08                	js     801f6e <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f66:	a1 08 40 80 00       	mov    0x804008,%eax
  801f6b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f71:	5b                   	pop    %ebx
  801f72:	5e                   	pop    %esi
  801f73:	5d                   	pop    %ebp
  801f74:	c3                   	ret    

00801f75 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	57                   	push   %edi
  801f79:	56                   	push   %esi
  801f7a:	53                   	push   %ebx
  801f7b:	83 ec 0c             	sub    $0xc,%esp
  801f7e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f81:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801f87:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801f89:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f8e:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801f91:	ff 75 14             	pushl  0x14(%ebp)
  801f94:	53                   	push   %ebx
  801f95:	56                   	push   %esi
  801f96:	57                   	push   %edi
  801f97:	e8 e1 ec ff ff       	call   800c7d <sys_ipc_try_send>

		if (err < 0) {
  801f9c:	83 c4 10             	add    $0x10,%esp
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	79 1e                	jns    801fc1 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801fa3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fa6:	75 07                	jne    801faf <ipc_send+0x3a>
				sys_yield();
  801fa8:	e8 24 eb ff ff       	call   800ad1 <sys_yield>
  801fad:	eb e2                	jmp    801f91 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801faf:	50                   	push   %eax
  801fb0:	68 98 27 80 00       	push   $0x802798
  801fb5:	6a 49                	push   $0x49
  801fb7:	68 a5 27 80 00       	push   $0x8027a5
  801fbc:	e8 07 ff ff ff       	call   801ec8 <_panic>
		}

	} while (err < 0);

}
  801fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5e                   	pop    %esi
  801fc6:	5f                   	pop    %edi
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    

00801fc9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fcf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fd4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fd7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fdd:	8b 52 50             	mov    0x50(%edx),%edx
  801fe0:	39 ca                	cmp    %ecx,%edx
  801fe2:	75 0d                	jne    801ff1 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fe4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fe7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fec:	8b 40 48             	mov    0x48(%eax),%eax
  801fef:	eb 0f                	jmp    802000 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ff1:	83 c0 01             	add    $0x1,%eax
  801ff4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ff9:	75 d9                	jne    801fd4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ffb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    

00802002 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802008:	89 d0                	mov    %edx,%eax
  80200a:	c1 e8 16             	shr    $0x16,%eax
  80200d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802014:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802019:	f6 c1 01             	test   $0x1,%cl
  80201c:	74 1d                	je     80203b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80201e:	c1 ea 0c             	shr    $0xc,%edx
  802021:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802028:	f6 c2 01             	test   $0x1,%dl
  80202b:	74 0e                	je     80203b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80202d:	c1 ea 0c             	shr    $0xc,%edx
  802030:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802037:	ef 
  802038:	0f b7 c0             	movzwl %ax,%eax
}
  80203b:	5d                   	pop    %ebp
  80203c:	c3                   	ret    
  80203d:	66 90                	xchg   %ax,%ax
  80203f:	90                   	nop

00802040 <__udivdi3>:
  802040:	55                   	push   %ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 1c             	sub    $0x1c,%esp
  802047:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80204b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80204f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802057:	85 f6                	test   %esi,%esi
  802059:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80205d:	89 ca                	mov    %ecx,%edx
  80205f:	89 f8                	mov    %edi,%eax
  802061:	75 3d                	jne    8020a0 <__udivdi3+0x60>
  802063:	39 cf                	cmp    %ecx,%edi
  802065:	0f 87 c5 00 00 00    	ja     802130 <__udivdi3+0xf0>
  80206b:	85 ff                	test   %edi,%edi
  80206d:	89 fd                	mov    %edi,%ebp
  80206f:	75 0b                	jne    80207c <__udivdi3+0x3c>
  802071:	b8 01 00 00 00       	mov    $0x1,%eax
  802076:	31 d2                	xor    %edx,%edx
  802078:	f7 f7                	div    %edi
  80207a:	89 c5                	mov    %eax,%ebp
  80207c:	89 c8                	mov    %ecx,%eax
  80207e:	31 d2                	xor    %edx,%edx
  802080:	f7 f5                	div    %ebp
  802082:	89 c1                	mov    %eax,%ecx
  802084:	89 d8                	mov    %ebx,%eax
  802086:	89 cf                	mov    %ecx,%edi
  802088:	f7 f5                	div    %ebp
  80208a:	89 c3                	mov    %eax,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	39 ce                	cmp    %ecx,%esi
  8020a2:	77 74                	ja     802118 <__udivdi3+0xd8>
  8020a4:	0f bd fe             	bsr    %esi,%edi
  8020a7:	83 f7 1f             	xor    $0x1f,%edi
  8020aa:	0f 84 98 00 00 00    	je     802148 <__udivdi3+0x108>
  8020b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	89 c5                	mov    %eax,%ebp
  8020b9:	29 fb                	sub    %edi,%ebx
  8020bb:	d3 e6                	shl    %cl,%esi
  8020bd:	89 d9                	mov    %ebx,%ecx
  8020bf:	d3 ed                	shr    %cl,%ebp
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	d3 e0                	shl    %cl,%eax
  8020c5:	09 ee                	or     %ebp,%esi
  8020c7:	89 d9                	mov    %ebx,%ecx
  8020c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020cd:	89 d5                	mov    %edx,%ebp
  8020cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020d3:	d3 ed                	shr    %cl,%ebp
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e2                	shl    %cl,%edx
  8020d9:	89 d9                	mov    %ebx,%ecx
  8020db:	d3 e8                	shr    %cl,%eax
  8020dd:	09 c2                	or     %eax,%edx
  8020df:	89 d0                	mov    %edx,%eax
  8020e1:	89 ea                	mov    %ebp,%edx
  8020e3:	f7 f6                	div    %esi
  8020e5:	89 d5                	mov    %edx,%ebp
  8020e7:	89 c3                	mov    %eax,%ebx
  8020e9:	f7 64 24 0c          	mull   0xc(%esp)
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	72 10                	jb     802101 <__udivdi3+0xc1>
  8020f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e6                	shl    %cl,%esi
  8020f9:	39 c6                	cmp    %eax,%esi
  8020fb:	73 07                	jae    802104 <__udivdi3+0xc4>
  8020fd:	39 d5                	cmp    %edx,%ebp
  8020ff:	75 03                	jne    802104 <__udivdi3+0xc4>
  802101:	83 eb 01             	sub    $0x1,%ebx
  802104:	31 ff                	xor    %edi,%edi
  802106:	89 d8                	mov    %ebx,%eax
  802108:	89 fa                	mov    %edi,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	31 ff                	xor    %edi,%edi
  80211a:	31 db                	xor    %ebx,%ebx
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	89 fa                	mov    %edi,%edx
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	90                   	nop
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	89 d8                	mov    %ebx,%eax
  802132:	f7 f7                	div    %edi
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 c3                	mov    %eax,%ebx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 fa                	mov    %edi,%edx
  80213c:	83 c4 1c             	add    $0x1c,%esp
  80213f:	5b                   	pop    %ebx
  802140:	5e                   	pop    %esi
  802141:	5f                   	pop    %edi
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	39 ce                	cmp    %ecx,%esi
  80214a:	72 0c                	jb     802158 <__udivdi3+0x118>
  80214c:	31 db                	xor    %ebx,%ebx
  80214e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802152:	0f 87 34 ff ff ff    	ja     80208c <__udivdi3+0x4c>
  802158:	bb 01 00 00 00       	mov    $0x1,%ebx
  80215d:	e9 2a ff ff ff       	jmp    80208c <__udivdi3+0x4c>
  802162:	66 90                	xchg   %ax,%ax
  802164:	66 90                	xchg   %ax,%ax
  802166:	66 90                	xchg   %ax,%ax
  802168:	66 90                	xchg   %ax,%ax
  80216a:	66 90                	xchg   %ax,%ax
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__umoddi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80217b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80217f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 d2                	test   %edx,%edx
  802189:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80218d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802191:	89 f3                	mov    %esi,%ebx
  802193:	89 3c 24             	mov    %edi,(%esp)
  802196:	89 74 24 04          	mov    %esi,0x4(%esp)
  80219a:	75 1c                	jne    8021b8 <__umoddi3+0x48>
  80219c:	39 f7                	cmp    %esi,%edi
  80219e:	76 50                	jbe    8021f0 <__umoddi3+0x80>
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	f7 f7                	div    %edi
  8021a6:	89 d0                	mov    %edx,%eax
  8021a8:	31 d2                	xor    %edx,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	39 f2                	cmp    %esi,%edx
  8021ba:	89 d0                	mov    %edx,%eax
  8021bc:	77 52                	ja     802210 <__umoddi3+0xa0>
  8021be:	0f bd ea             	bsr    %edx,%ebp
  8021c1:	83 f5 1f             	xor    $0x1f,%ebp
  8021c4:	75 5a                	jne    802220 <__umoddi3+0xb0>
  8021c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ca:	0f 82 e0 00 00 00    	jb     8022b0 <__umoddi3+0x140>
  8021d0:	39 0c 24             	cmp    %ecx,(%esp)
  8021d3:	0f 86 d7 00 00 00    	jbe    8022b0 <__umoddi3+0x140>
  8021d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021e1:	83 c4 1c             	add    $0x1c,%esp
  8021e4:	5b                   	pop    %ebx
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	85 ff                	test   %edi,%edi
  8021f2:	89 fd                	mov    %edi,%ebp
  8021f4:	75 0b                	jne    802201 <__umoddi3+0x91>
  8021f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	f7 f7                	div    %edi
  8021ff:	89 c5                	mov    %eax,%ebp
  802201:	89 f0                	mov    %esi,%eax
  802203:	31 d2                	xor    %edx,%edx
  802205:	f7 f5                	div    %ebp
  802207:	89 c8                	mov    %ecx,%eax
  802209:	f7 f5                	div    %ebp
  80220b:	89 d0                	mov    %edx,%eax
  80220d:	eb 99                	jmp    8021a8 <__umoddi3+0x38>
  80220f:	90                   	nop
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	83 c4 1c             	add    $0x1c,%esp
  802217:	5b                   	pop    %ebx
  802218:	5e                   	pop    %esi
  802219:	5f                   	pop    %edi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	8b 34 24             	mov    (%esp),%esi
  802223:	bf 20 00 00 00       	mov    $0x20,%edi
  802228:	89 e9                	mov    %ebp,%ecx
  80222a:	29 ef                	sub    %ebp,%edi
  80222c:	d3 e0                	shl    %cl,%eax
  80222e:	89 f9                	mov    %edi,%ecx
  802230:	89 f2                	mov    %esi,%edx
  802232:	d3 ea                	shr    %cl,%edx
  802234:	89 e9                	mov    %ebp,%ecx
  802236:	09 c2                	or     %eax,%edx
  802238:	89 d8                	mov    %ebx,%eax
  80223a:	89 14 24             	mov    %edx,(%esp)
  80223d:	89 f2                	mov    %esi,%edx
  80223f:	d3 e2                	shl    %cl,%edx
  802241:	89 f9                	mov    %edi,%ecx
  802243:	89 54 24 04          	mov    %edx,0x4(%esp)
  802247:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80224b:	d3 e8                	shr    %cl,%eax
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	89 c6                	mov    %eax,%esi
  802251:	d3 e3                	shl    %cl,%ebx
  802253:	89 f9                	mov    %edi,%ecx
  802255:	89 d0                	mov    %edx,%eax
  802257:	d3 e8                	shr    %cl,%eax
  802259:	89 e9                	mov    %ebp,%ecx
  80225b:	09 d8                	or     %ebx,%eax
  80225d:	89 d3                	mov    %edx,%ebx
  80225f:	89 f2                	mov    %esi,%edx
  802261:	f7 34 24             	divl   (%esp)
  802264:	89 d6                	mov    %edx,%esi
  802266:	d3 e3                	shl    %cl,%ebx
  802268:	f7 64 24 04          	mull   0x4(%esp)
  80226c:	39 d6                	cmp    %edx,%esi
  80226e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802272:	89 d1                	mov    %edx,%ecx
  802274:	89 c3                	mov    %eax,%ebx
  802276:	72 08                	jb     802280 <__umoddi3+0x110>
  802278:	75 11                	jne    80228b <__umoddi3+0x11b>
  80227a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80227e:	73 0b                	jae    80228b <__umoddi3+0x11b>
  802280:	2b 44 24 04          	sub    0x4(%esp),%eax
  802284:	1b 14 24             	sbb    (%esp),%edx
  802287:	89 d1                	mov    %edx,%ecx
  802289:	89 c3                	mov    %eax,%ebx
  80228b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80228f:	29 da                	sub    %ebx,%edx
  802291:	19 ce                	sbb    %ecx,%esi
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 f0                	mov    %esi,%eax
  802297:	d3 e0                	shl    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	d3 ea                	shr    %cl,%edx
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	d3 ee                	shr    %cl,%esi
  8022a1:	09 d0                	or     %edx,%eax
  8022a3:	89 f2                	mov    %esi,%edx
  8022a5:	83 c4 1c             	add    $0x1c,%esp
  8022a8:	5b                   	pop    %ebx
  8022a9:	5e                   	pop    %esi
  8022aa:	5f                   	pop    %edi
  8022ab:	5d                   	pop    %ebp
  8022ac:	c3                   	ret    
  8022ad:	8d 76 00             	lea    0x0(%esi),%esi
  8022b0:	29 f9                	sub    %edi,%ecx
  8022b2:	19 d6                	sbb    %edx,%esi
  8022b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022bc:	e9 18 ff ff ff       	jmp    8021d9 <__umoddi3+0x69>
