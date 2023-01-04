
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
  80004b:	68 e0 1d 80 00       	push   $0x801de0
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
  800066:	68 f4 1d 80 00       	push   $0x801df4
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
  800092:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8000c1:	e8 e6 0d 00 00       	call   800eac <close_all>
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
  8001cb:	e8 70 19 00 00       	call   801b40 <__udivdi3>
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
  80020e:	e8 5d 1a 00 00       	call   801c70 <__umoddi3>
  800213:	83 c4 14             	add    $0x14,%esp
  800216:	0f be 80 18 1e 80 00 	movsbl 0x801e18(%eax),%eax
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
  800312:	ff 24 85 60 1f 80 00 	jmp    *0x801f60(,%eax,4)
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
  8003d6:	8b 14 85 c0 20 80 00 	mov    0x8020c0(,%eax,4),%edx
  8003dd:	85 d2                	test   %edx,%edx
  8003df:	75 18                	jne    8003f9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003e1:	50                   	push   %eax
  8003e2:	68 30 1e 80 00       	push   $0x801e30
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
  8003fa:	68 f1 21 80 00       	push   $0x8021f1
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
  80041e:	b8 29 1e 80 00       	mov    $0x801e29,%eax
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
  800a99:	68 1f 21 80 00       	push   $0x80211f
  800a9e:	6a 23                	push   $0x23
  800aa0:	68 3c 21 80 00       	push   $0x80213c
  800aa5:	e8 14 0f 00 00       	call   8019be <_panic>

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
  800b1a:	68 1f 21 80 00       	push   $0x80211f
  800b1f:	6a 23                	push   $0x23
  800b21:	68 3c 21 80 00       	push   $0x80213c
  800b26:	e8 93 0e 00 00       	call   8019be <_panic>

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
  800b5c:	68 1f 21 80 00       	push   $0x80211f
  800b61:	6a 23                	push   $0x23
  800b63:	68 3c 21 80 00       	push   $0x80213c
  800b68:	e8 51 0e 00 00       	call   8019be <_panic>

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
  800b9e:	68 1f 21 80 00       	push   $0x80211f
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 3c 21 80 00       	push   $0x80213c
  800baa:	e8 0f 0e 00 00       	call   8019be <_panic>

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
  800be0:	68 1f 21 80 00       	push   $0x80211f
  800be5:	6a 23                	push   $0x23
  800be7:	68 3c 21 80 00       	push   $0x80213c
  800bec:	e8 cd 0d 00 00       	call   8019be <_panic>

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
  800c22:	68 1f 21 80 00       	push   $0x80211f
  800c27:	6a 23                	push   $0x23
  800c29:	68 3c 21 80 00       	push   $0x80213c
  800c2e:	e8 8b 0d 00 00       	call   8019be <_panic>

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
  800c64:	68 1f 21 80 00       	push   $0x80211f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 3c 21 80 00       	push   $0x80213c
  800c70:	e8 49 0d 00 00       	call   8019be <_panic>

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
  800cc8:	68 1f 21 80 00       	push   $0x80211f
  800ccd:	6a 23                	push   $0x23
  800ccf:	68 3c 21 80 00       	push   $0x80213c
  800cd4:	e8 e5 0c 00 00       	call   8019be <_panic>

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

00800ce1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce7:	05 00 00 00 30       	add    $0x30000000,%eax
  800cec:	c1 e8 0c             	shr    $0xc,%eax
}
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	05 00 00 00 30       	add    $0x30000000,%eax
  800cfc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d01:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d13:	89 c2                	mov    %eax,%edx
  800d15:	c1 ea 16             	shr    $0x16,%edx
  800d18:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d1f:	f6 c2 01             	test   $0x1,%dl
  800d22:	74 11                	je     800d35 <fd_alloc+0x2d>
  800d24:	89 c2                	mov    %eax,%edx
  800d26:	c1 ea 0c             	shr    $0xc,%edx
  800d29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d30:	f6 c2 01             	test   $0x1,%dl
  800d33:	75 09                	jne    800d3e <fd_alloc+0x36>
			*fd_store = fd;
  800d35:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d37:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3c:	eb 17                	jmp    800d55 <fd_alloc+0x4d>
  800d3e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d43:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d48:	75 c9                	jne    800d13 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d4a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d50:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d5d:	83 f8 1f             	cmp    $0x1f,%eax
  800d60:	77 36                	ja     800d98 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d62:	c1 e0 0c             	shl    $0xc,%eax
  800d65:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d6a:	89 c2                	mov    %eax,%edx
  800d6c:	c1 ea 16             	shr    $0x16,%edx
  800d6f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d76:	f6 c2 01             	test   $0x1,%dl
  800d79:	74 24                	je     800d9f <fd_lookup+0x48>
  800d7b:	89 c2                	mov    %eax,%edx
  800d7d:	c1 ea 0c             	shr    $0xc,%edx
  800d80:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d87:	f6 c2 01             	test   $0x1,%dl
  800d8a:	74 1a                	je     800da6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d8f:	89 02                	mov    %eax,(%edx)
	return 0;
  800d91:	b8 00 00 00 00       	mov    $0x0,%eax
  800d96:	eb 13                	jmp    800dab <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d9d:	eb 0c                	jmp    800dab <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800da4:	eb 05                	jmp    800dab <fd_lookup+0x54>
  800da6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	83 ec 08             	sub    $0x8,%esp
  800db3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db6:	ba c8 21 80 00       	mov    $0x8021c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dbb:	eb 13                	jmp    800dd0 <dev_lookup+0x23>
  800dbd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800dc0:	39 08                	cmp    %ecx,(%eax)
  800dc2:	75 0c                	jne    800dd0 <dev_lookup+0x23>
			*dev = devtab[i];
  800dc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dce:	eb 2e                	jmp    800dfe <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dd0:	8b 02                	mov    (%edx),%eax
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	75 e7                	jne    800dbd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dd6:	a1 04 40 80 00       	mov    0x804004,%eax
  800ddb:	8b 40 48             	mov    0x48(%eax),%eax
  800dde:	83 ec 04             	sub    $0x4,%esp
  800de1:	51                   	push   %ecx
  800de2:	50                   	push   %eax
  800de3:	68 4c 21 80 00       	push   $0x80214c
  800de8:	e8 7b f3 ff ff       	call   800168 <cprintf>
	*dev = 0;
  800ded:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800df6:	83 c4 10             	add    $0x10,%esp
  800df9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800dfe:	c9                   	leave  
  800dff:	c3                   	ret    

00800e00 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	83 ec 10             	sub    $0x10,%esp
  800e08:	8b 75 08             	mov    0x8(%ebp),%esi
  800e0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e11:	50                   	push   %eax
  800e12:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e18:	c1 e8 0c             	shr    $0xc,%eax
  800e1b:	50                   	push   %eax
  800e1c:	e8 36 ff ff ff       	call   800d57 <fd_lookup>
  800e21:	83 c4 08             	add    $0x8,%esp
  800e24:	85 c0                	test   %eax,%eax
  800e26:	78 05                	js     800e2d <fd_close+0x2d>
	    || fd != fd2)
  800e28:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e2b:	74 0c                	je     800e39 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e2d:	84 db                	test   %bl,%bl
  800e2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e34:	0f 44 c2             	cmove  %edx,%eax
  800e37:	eb 41                	jmp    800e7a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e39:	83 ec 08             	sub    $0x8,%esp
  800e3c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e3f:	50                   	push   %eax
  800e40:	ff 36                	pushl  (%esi)
  800e42:	e8 66 ff ff ff       	call   800dad <dev_lookup>
  800e47:	89 c3                	mov    %eax,%ebx
  800e49:	83 c4 10             	add    $0x10,%esp
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	78 1a                	js     800e6a <fd_close+0x6a>
		if (dev->dev_close)
  800e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e53:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e56:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	74 0b                	je     800e6a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	56                   	push   %esi
  800e63:	ff d0                	call   *%eax
  800e65:	89 c3                	mov    %eax,%ebx
  800e67:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e6a:	83 ec 08             	sub    $0x8,%esp
  800e6d:	56                   	push   %esi
  800e6e:	6a 00                	push   $0x0
  800e70:	e8 00 fd ff ff       	call   800b75 <sys_page_unmap>
	return r;
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	89 d8                	mov    %ebx,%eax
}
  800e7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8a:	50                   	push   %eax
  800e8b:	ff 75 08             	pushl  0x8(%ebp)
  800e8e:	e8 c4 fe ff ff       	call   800d57 <fd_lookup>
  800e93:	83 c4 08             	add    $0x8,%esp
  800e96:	85 c0                	test   %eax,%eax
  800e98:	78 10                	js     800eaa <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800e9a:	83 ec 08             	sub    $0x8,%esp
  800e9d:	6a 01                	push   $0x1
  800e9f:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea2:	e8 59 ff ff ff       	call   800e00 <fd_close>
  800ea7:	83 c4 10             	add    $0x10,%esp
}
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <close_all>:

void
close_all(void)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800eb3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	53                   	push   %ebx
  800ebc:	e8 c0 ff ff ff       	call   800e81 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ec1:	83 c3 01             	add    $0x1,%ebx
  800ec4:	83 c4 10             	add    $0x10,%esp
  800ec7:	83 fb 20             	cmp    $0x20,%ebx
  800eca:	75 ec                	jne    800eb8 <close_all+0xc>
		close(i);
}
  800ecc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	57                   	push   %edi
  800ed5:	56                   	push   %esi
  800ed6:	53                   	push   %ebx
  800ed7:	83 ec 2c             	sub    $0x2c,%esp
  800eda:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800edd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ee0:	50                   	push   %eax
  800ee1:	ff 75 08             	pushl  0x8(%ebp)
  800ee4:	e8 6e fe ff ff       	call   800d57 <fd_lookup>
  800ee9:	83 c4 08             	add    $0x8,%esp
  800eec:	85 c0                	test   %eax,%eax
  800eee:	0f 88 c1 00 00 00    	js     800fb5 <dup+0xe4>
		return r;
	close(newfdnum);
  800ef4:	83 ec 0c             	sub    $0xc,%esp
  800ef7:	56                   	push   %esi
  800ef8:	e8 84 ff ff ff       	call   800e81 <close>

	newfd = INDEX2FD(newfdnum);
  800efd:	89 f3                	mov    %esi,%ebx
  800eff:	c1 e3 0c             	shl    $0xc,%ebx
  800f02:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f08:	83 c4 04             	add    $0x4,%esp
  800f0b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f0e:	e8 de fd ff ff       	call   800cf1 <fd2data>
  800f13:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f15:	89 1c 24             	mov    %ebx,(%esp)
  800f18:	e8 d4 fd ff ff       	call   800cf1 <fd2data>
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f23:	89 f8                	mov    %edi,%eax
  800f25:	c1 e8 16             	shr    $0x16,%eax
  800f28:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f2f:	a8 01                	test   $0x1,%al
  800f31:	74 37                	je     800f6a <dup+0x99>
  800f33:	89 f8                	mov    %edi,%eax
  800f35:	c1 e8 0c             	shr    $0xc,%eax
  800f38:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3f:	f6 c2 01             	test   $0x1,%dl
  800f42:	74 26                	je     800f6a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f44:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4b:	83 ec 0c             	sub    $0xc,%esp
  800f4e:	25 07 0e 00 00       	and    $0xe07,%eax
  800f53:	50                   	push   %eax
  800f54:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f57:	6a 00                	push   $0x0
  800f59:	57                   	push   %edi
  800f5a:	6a 00                	push   $0x0
  800f5c:	e8 d2 fb ff ff       	call   800b33 <sys_page_map>
  800f61:	89 c7                	mov    %eax,%edi
  800f63:	83 c4 20             	add    $0x20,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 2e                	js     800f98 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f6a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f6d:	89 d0                	mov    %edx,%eax
  800f6f:	c1 e8 0c             	shr    $0xc,%eax
  800f72:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f79:	83 ec 0c             	sub    $0xc,%esp
  800f7c:	25 07 0e 00 00       	and    $0xe07,%eax
  800f81:	50                   	push   %eax
  800f82:	53                   	push   %ebx
  800f83:	6a 00                	push   $0x0
  800f85:	52                   	push   %edx
  800f86:	6a 00                	push   $0x0
  800f88:	e8 a6 fb ff ff       	call   800b33 <sys_page_map>
  800f8d:	89 c7                	mov    %eax,%edi
  800f8f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f92:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f94:	85 ff                	test   %edi,%edi
  800f96:	79 1d                	jns    800fb5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800f98:	83 ec 08             	sub    $0x8,%esp
  800f9b:	53                   	push   %ebx
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 d2 fb ff ff       	call   800b75 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fa3:	83 c4 08             	add    $0x8,%esp
  800fa6:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fa9:	6a 00                	push   $0x0
  800fab:	e8 c5 fb ff ff       	call   800b75 <sys_page_unmap>
	return r;
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	89 f8                	mov    %edi,%eax
}
  800fb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb8:	5b                   	pop    %ebx
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    

00800fbd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	53                   	push   %ebx
  800fc1:	83 ec 14             	sub    $0x14,%esp
  800fc4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fc7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fca:	50                   	push   %eax
  800fcb:	53                   	push   %ebx
  800fcc:	e8 86 fd ff ff       	call   800d57 <fd_lookup>
  800fd1:	83 c4 08             	add    $0x8,%esp
  800fd4:	89 c2                	mov    %eax,%edx
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 6d                	js     801047 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fda:	83 ec 08             	sub    $0x8,%esp
  800fdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe0:	50                   	push   %eax
  800fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fe4:	ff 30                	pushl  (%eax)
  800fe6:	e8 c2 fd ff ff       	call   800dad <dev_lookup>
  800feb:	83 c4 10             	add    $0x10,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 4c                	js     80103e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ff2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ff5:	8b 42 08             	mov    0x8(%edx),%eax
  800ff8:	83 e0 03             	and    $0x3,%eax
  800ffb:	83 f8 01             	cmp    $0x1,%eax
  800ffe:	75 21                	jne    801021 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801000:	a1 04 40 80 00       	mov    0x804004,%eax
  801005:	8b 40 48             	mov    0x48(%eax),%eax
  801008:	83 ec 04             	sub    $0x4,%esp
  80100b:	53                   	push   %ebx
  80100c:	50                   	push   %eax
  80100d:	68 8d 21 80 00       	push   $0x80218d
  801012:	e8 51 f1 ff ff       	call   800168 <cprintf>
		return -E_INVAL;
  801017:	83 c4 10             	add    $0x10,%esp
  80101a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80101f:	eb 26                	jmp    801047 <read+0x8a>
	}
	if (!dev->dev_read)
  801021:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801024:	8b 40 08             	mov    0x8(%eax),%eax
  801027:	85 c0                	test   %eax,%eax
  801029:	74 17                	je     801042 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80102b:	83 ec 04             	sub    $0x4,%esp
  80102e:	ff 75 10             	pushl  0x10(%ebp)
  801031:	ff 75 0c             	pushl  0xc(%ebp)
  801034:	52                   	push   %edx
  801035:	ff d0                	call   *%eax
  801037:	89 c2                	mov    %eax,%edx
  801039:	83 c4 10             	add    $0x10,%esp
  80103c:	eb 09                	jmp    801047 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80103e:	89 c2                	mov    %eax,%edx
  801040:	eb 05                	jmp    801047 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801042:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801047:	89 d0                	mov    %edx,%eax
  801049:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104c:	c9                   	leave  
  80104d:	c3                   	ret    

0080104e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	8b 7d 08             	mov    0x8(%ebp),%edi
  80105a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80105d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801062:	eb 21                	jmp    801085 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801064:	83 ec 04             	sub    $0x4,%esp
  801067:	89 f0                	mov    %esi,%eax
  801069:	29 d8                	sub    %ebx,%eax
  80106b:	50                   	push   %eax
  80106c:	89 d8                	mov    %ebx,%eax
  80106e:	03 45 0c             	add    0xc(%ebp),%eax
  801071:	50                   	push   %eax
  801072:	57                   	push   %edi
  801073:	e8 45 ff ff ff       	call   800fbd <read>
		if (m < 0)
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	85 c0                	test   %eax,%eax
  80107d:	78 10                	js     80108f <readn+0x41>
			return m;
		if (m == 0)
  80107f:	85 c0                	test   %eax,%eax
  801081:	74 0a                	je     80108d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801083:	01 c3                	add    %eax,%ebx
  801085:	39 f3                	cmp    %esi,%ebx
  801087:	72 db                	jb     801064 <readn+0x16>
  801089:	89 d8                	mov    %ebx,%eax
  80108b:	eb 02                	jmp    80108f <readn+0x41>
  80108d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80108f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801092:	5b                   	pop    %ebx
  801093:	5e                   	pop    %esi
  801094:	5f                   	pop    %edi
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	53                   	push   %ebx
  80109b:	83 ec 14             	sub    $0x14,%esp
  80109e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a4:	50                   	push   %eax
  8010a5:	53                   	push   %ebx
  8010a6:	e8 ac fc ff ff       	call   800d57 <fd_lookup>
  8010ab:	83 c4 08             	add    $0x8,%esp
  8010ae:	89 c2                	mov    %eax,%edx
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	78 68                	js     80111c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010b4:	83 ec 08             	sub    $0x8,%esp
  8010b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ba:	50                   	push   %eax
  8010bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010be:	ff 30                	pushl  (%eax)
  8010c0:	e8 e8 fc ff ff       	call   800dad <dev_lookup>
  8010c5:	83 c4 10             	add    $0x10,%esp
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	78 47                	js     801113 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010d3:	75 21                	jne    8010f6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8010da:	8b 40 48             	mov    0x48(%eax),%eax
  8010dd:	83 ec 04             	sub    $0x4,%esp
  8010e0:	53                   	push   %ebx
  8010e1:	50                   	push   %eax
  8010e2:	68 a9 21 80 00       	push   $0x8021a9
  8010e7:	e8 7c f0 ff ff       	call   800168 <cprintf>
		return -E_INVAL;
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010f4:	eb 26                	jmp    80111c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8010fc:	85 d2                	test   %edx,%edx
  8010fe:	74 17                	je     801117 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	ff 75 10             	pushl  0x10(%ebp)
  801106:	ff 75 0c             	pushl  0xc(%ebp)
  801109:	50                   	push   %eax
  80110a:	ff d2                	call   *%edx
  80110c:	89 c2                	mov    %eax,%edx
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	eb 09                	jmp    80111c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801113:	89 c2                	mov    %eax,%edx
  801115:	eb 05                	jmp    80111c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801117:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80111c:	89 d0                	mov    %edx,%eax
  80111e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801121:	c9                   	leave  
  801122:	c3                   	ret    

00801123 <seek>:

int
seek(int fdnum, off_t offset)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801129:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80112c:	50                   	push   %eax
  80112d:	ff 75 08             	pushl  0x8(%ebp)
  801130:	e8 22 fc ff ff       	call   800d57 <fd_lookup>
  801135:	83 c4 08             	add    $0x8,%esp
  801138:	85 c0                	test   %eax,%eax
  80113a:	78 0e                	js     80114a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80113c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80113f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801142:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801145:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80114a:	c9                   	leave  
  80114b:	c3                   	ret    

0080114c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	53                   	push   %ebx
  801150:	83 ec 14             	sub    $0x14,%esp
  801153:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801156:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801159:	50                   	push   %eax
  80115a:	53                   	push   %ebx
  80115b:	e8 f7 fb ff ff       	call   800d57 <fd_lookup>
  801160:	83 c4 08             	add    $0x8,%esp
  801163:	89 c2                	mov    %eax,%edx
  801165:	85 c0                	test   %eax,%eax
  801167:	78 65                	js     8011ce <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801173:	ff 30                	pushl  (%eax)
  801175:	e8 33 fc ff ff       	call   800dad <dev_lookup>
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	78 44                	js     8011c5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801181:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801184:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801188:	75 21                	jne    8011ab <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80118a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80118f:	8b 40 48             	mov    0x48(%eax),%eax
  801192:	83 ec 04             	sub    $0x4,%esp
  801195:	53                   	push   %ebx
  801196:	50                   	push   %eax
  801197:	68 6c 21 80 00       	push   $0x80216c
  80119c:	e8 c7 ef ff ff       	call   800168 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a9:	eb 23                	jmp    8011ce <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ae:	8b 52 18             	mov    0x18(%edx),%edx
  8011b1:	85 d2                	test   %edx,%edx
  8011b3:	74 14                	je     8011c9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011b5:	83 ec 08             	sub    $0x8,%esp
  8011b8:	ff 75 0c             	pushl  0xc(%ebp)
  8011bb:	50                   	push   %eax
  8011bc:	ff d2                	call   *%edx
  8011be:	89 c2                	mov    %eax,%edx
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	eb 09                	jmp    8011ce <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c5:	89 c2                	mov    %eax,%edx
  8011c7:	eb 05                	jmp    8011ce <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011ce:	89 d0                	mov    %edx,%eax
  8011d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    

008011d5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 14             	sub    $0x14,%esp
  8011dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e2:	50                   	push   %eax
  8011e3:	ff 75 08             	pushl  0x8(%ebp)
  8011e6:	e8 6c fb ff ff       	call   800d57 <fd_lookup>
  8011eb:	83 c4 08             	add    $0x8,%esp
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	78 58                	js     80124c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f4:	83 ec 08             	sub    $0x8,%esp
  8011f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fa:	50                   	push   %eax
  8011fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fe:	ff 30                	pushl  (%eax)
  801200:	e8 a8 fb ff ff       	call   800dad <dev_lookup>
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	85 c0                	test   %eax,%eax
  80120a:	78 37                	js     801243 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80120c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801213:	74 32                	je     801247 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801215:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801218:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80121f:	00 00 00 
	stat->st_isdir = 0;
  801222:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801229:	00 00 00 
	stat->st_dev = dev;
  80122c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801232:	83 ec 08             	sub    $0x8,%esp
  801235:	53                   	push   %ebx
  801236:	ff 75 f0             	pushl  -0x10(%ebp)
  801239:	ff 50 14             	call   *0x14(%eax)
  80123c:	89 c2                	mov    %eax,%edx
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	eb 09                	jmp    80124c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801243:	89 c2                	mov    %eax,%edx
  801245:	eb 05                	jmp    80124c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801247:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80124c:	89 d0                	mov    %edx,%eax
  80124e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801258:	83 ec 08             	sub    $0x8,%esp
  80125b:	6a 00                	push   $0x0
  80125d:	ff 75 08             	pushl  0x8(%ebp)
  801260:	e8 d6 01 00 00       	call   80143b <open>
  801265:	89 c3                	mov    %eax,%ebx
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 1b                	js     801289 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	ff 75 0c             	pushl  0xc(%ebp)
  801274:	50                   	push   %eax
  801275:	e8 5b ff ff ff       	call   8011d5 <fstat>
  80127a:	89 c6                	mov    %eax,%esi
	close(fd);
  80127c:	89 1c 24             	mov    %ebx,(%esp)
  80127f:	e8 fd fb ff ff       	call   800e81 <close>
	return r;
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	89 f0                	mov    %esi,%eax
}
  801289:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80128c:	5b                   	pop    %ebx
  80128d:	5e                   	pop    %esi
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	56                   	push   %esi
  801294:	53                   	push   %ebx
  801295:	89 c6                	mov    %eax,%esi
  801297:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801299:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012a0:	75 12                	jne    8012b4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012a2:	83 ec 0c             	sub    $0xc,%esp
  8012a5:	6a 01                	push   $0x1
  8012a7:	e8 13 08 00 00       	call   801abf <ipc_find_env>
  8012ac:	a3 00 40 80 00       	mov    %eax,0x804000
  8012b1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012b4:	6a 07                	push   $0x7
  8012b6:	68 00 50 80 00       	push   $0x805000
  8012bb:	56                   	push   %esi
  8012bc:	ff 35 00 40 80 00    	pushl  0x804000
  8012c2:	e8 a4 07 00 00       	call   801a6b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012c7:	83 c4 0c             	add    $0xc,%esp
  8012ca:	6a 00                	push   $0x0
  8012cc:	53                   	push   %ebx
  8012cd:	6a 00                	push   $0x0
  8012cf:	e8 30 07 00 00       	call   801a04 <ipc_recv>
}
  8012d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d7:	5b                   	pop    %ebx
  8012d8:	5e                   	pop    %esi
  8012d9:	5d                   	pop    %ebp
  8012da:	c3                   	ret    

008012db <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8012e7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ef:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f9:	b8 02 00 00 00       	mov    $0x2,%eax
  8012fe:	e8 8d ff ff ff       	call   801290 <fsipc>
}
  801303:	c9                   	leave  
  801304:	c3                   	ret    

00801305 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80130b:	8b 45 08             	mov    0x8(%ebp),%eax
  80130e:	8b 40 0c             	mov    0xc(%eax),%eax
  801311:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801316:	ba 00 00 00 00       	mov    $0x0,%edx
  80131b:	b8 06 00 00 00       	mov    $0x6,%eax
  801320:	e8 6b ff ff ff       	call   801290 <fsipc>
}
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	53                   	push   %ebx
  80132b:	83 ec 04             	sub    $0x4,%esp
  80132e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801331:	8b 45 08             	mov    0x8(%ebp),%eax
  801334:	8b 40 0c             	mov    0xc(%eax),%eax
  801337:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80133c:	ba 00 00 00 00       	mov    $0x0,%edx
  801341:	b8 05 00 00 00       	mov    $0x5,%eax
  801346:	e8 45 ff ff ff       	call   801290 <fsipc>
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 2c                	js     80137b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	68 00 50 80 00       	push   $0x805000
  801357:	53                   	push   %ebx
  801358:	e8 90 f3 ff ff       	call   8006ed <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80135d:	a1 80 50 80 00       	mov    0x805080,%eax
  801362:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801368:	a1 84 50 80 00       	mov    0x805084,%eax
  80136d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80137b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	83 ec 0c             	sub    $0xc,%esp
  801386:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801389:	8b 55 08             	mov    0x8(%ebp),%edx
  80138c:	8b 52 0c             	mov    0xc(%edx),%edx
  80138f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801395:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80139a:	50                   	push   %eax
  80139b:	ff 75 0c             	pushl  0xc(%ebp)
  80139e:	68 08 50 80 00       	push   $0x805008
  8013a3:	e8 d7 f4 ff ff       	call   80087f <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8013a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ad:	b8 04 00 00 00       	mov    $0x4,%eax
  8013b2:	e8 d9 fe ff ff       	call   801290 <fsipc>

}
  8013b7:	c9                   	leave  
  8013b8:	c3                   	ret    

008013b9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	56                   	push   %esi
  8013bd:	53                   	push   %ebx
  8013be:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013cc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d7:	b8 03 00 00 00       	mov    $0x3,%eax
  8013dc:	e8 af fe ff ff       	call   801290 <fsipc>
  8013e1:	89 c3                	mov    %eax,%ebx
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 4b                	js     801432 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013e7:	39 c6                	cmp    %eax,%esi
  8013e9:	73 16                	jae    801401 <devfile_read+0x48>
  8013eb:	68 d8 21 80 00       	push   $0x8021d8
  8013f0:	68 df 21 80 00       	push   $0x8021df
  8013f5:	6a 7c                	push   $0x7c
  8013f7:	68 f4 21 80 00       	push   $0x8021f4
  8013fc:	e8 bd 05 00 00       	call   8019be <_panic>
	assert(r <= PGSIZE);
  801401:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801406:	7e 16                	jle    80141e <devfile_read+0x65>
  801408:	68 ff 21 80 00       	push   $0x8021ff
  80140d:	68 df 21 80 00       	push   $0x8021df
  801412:	6a 7d                	push   $0x7d
  801414:	68 f4 21 80 00       	push   $0x8021f4
  801419:	e8 a0 05 00 00       	call   8019be <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80141e:	83 ec 04             	sub    $0x4,%esp
  801421:	50                   	push   %eax
  801422:	68 00 50 80 00       	push   $0x805000
  801427:	ff 75 0c             	pushl  0xc(%ebp)
  80142a:	e8 50 f4 ff ff       	call   80087f <memmove>
	return r;
  80142f:	83 c4 10             	add    $0x10,%esp
}
  801432:	89 d8                	mov    %ebx,%eax
  801434:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801437:	5b                   	pop    %ebx
  801438:	5e                   	pop    %esi
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    

0080143b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	53                   	push   %ebx
  80143f:	83 ec 20             	sub    $0x20,%esp
  801442:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801445:	53                   	push   %ebx
  801446:	e8 69 f2 ff ff       	call   8006b4 <strlen>
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801453:	7f 67                	jg     8014bc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801455:	83 ec 0c             	sub    $0xc,%esp
  801458:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145b:	50                   	push   %eax
  80145c:	e8 a7 f8 ff ff       	call   800d08 <fd_alloc>
  801461:	83 c4 10             	add    $0x10,%esp
		return r;
  801464:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801466:	85 c0                	test   %eax,%eax
  801468:	78 57                	js     8014c1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80146a:	83 ec 08             	sub    $0x8,%esp
  80146d:	53                   	push   %ebx
  80146e:	68 00 50 80 00       	push   $0x805000
  801473:	e8 75 f2 ff ff       	call   8006ed <strcpy>
	fsipcbuf.open.req_omode = mode;
  801478:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801480:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801483:	b8 01 00 00 00       	mov    $0x1,%eax
  801488:	e8 03 fe ff ff       	call   801290 <fsipc>
  80148d:	89 c3                	mov    %eax,%ebx
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	79 14                	jns    8014aa <open+0x6f>
		fd_close(fd, 0);
  801496:	83 ec 08             	sub    $0x8,%esp
  801499:	6a 00                	push   $0x0
  80149b:	ff 75 f4             	pushl  -0xc(%ebp)
  80149e:	e8 5d f9 ff ff       	call   800e00 <fd_close>
		return r;
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	89 da                	mov    %ebx,%edx
  8014a8:	eb 17                	jmp    8014c1 <open+0x86>
	}

	return fd2num(fd);
  8014aa:	83 ec 0c             	sub    $0xc,%esp
  8014ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b0:	e8 2c f8 ff ff       	call   800ce1 <fd2num>
  8014b5:	89 c2                	mov    %eax,%edx
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	eb 05                	jmp    8014c1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014bc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014c1:	89 d0                	mov    %edx,%eax
  8014c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c6:	c9                   	leave  
  8014c7:	c3                   	ret    

008014c8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d3:	b8 08 00 00 00       	mov    $0x8,%eax
  8014d8:	e8 b3 fd ff ff       	call   801290 <fsipc>
}
  8014dd:	c9                   	leave  
  8014de:	c3                   	ret    

008014df <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	56                   	push   %esi
  8014e3:	53                   	push   %ebx
  8014e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014e7:	83 ec 0c             	sub    $0xc,%esp
  8014ea:	ff 75 08             	pushl  0x8(%ebp)
  8014ed:	e8 ff f7 ff ff       	call   800cf1 <fd2data>
  8014f2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8014f4:	83 c4 08             	add    $0x8,%esp
  8014f7:	68 0b 22 80 00       	push   $0x80220b
  8014fc:	53                   	push   %ebx
  8014fd:	e8 eb f1 ff ff       	call   8006ed <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801502:	8b 46 04             	mov    0x4(%esi),%eax
  801505:	2b 06                	sub    (%esi),%eax
  801507:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80150d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801514:	00 00 00 
	stat->st_dev = &devpipe;
  801517:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80151e:	30 80 00 
	return 0;
}
  801521:	b8 00 00 00 00       	mov    $0x0,%eax
  801526:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801529:	5b                   	pop    %ebx
  80152a:	5e                   	pop    %esi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    

0080152d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	53                   	push   %ebx
  801531:	83 ec 0c             	sub    $0xc,%esp
  801534:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801537:	53                   	push   %ebx
  801538:	6a 00                	push   $0x0
  80153a:	e8 36 f6 ff ff       	call   800b75 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80153f:	89 1c 24             	mov    %ebx,(%esp)
  801542:	e8 aa f7 ff ff       	call   800cf1 <fd2data>
  801547:	83 c4 08             	add    $0x8,%esp
  80154a:	50                   	push   %eax
  80154b:	6a 00                	push   $0x0
  80154d:	e8 23 f6 ff ff       	call   800b75 <sys_page_unmap>
}
  801552:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801555:	c9                   	leave  
  801556:	c3                   	ret    

00801557 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	57                   	push   %edi
  80155b:	56                   	push   %esi
  80155c:	53                   	push   %ebx
  80155d:	83 ec 1c             	sub    $0x1c,%esp
  801560:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801563:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801565:	a1 04 40 80 00       	mov    0x804004,%eax
  80156a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80156d:	83 ec 0c             	sub    $0xc,%esp
  801570:	ff 75 e0             	pushl  -0x20(%ebp)
  801573:	e8 80 05 00 00       	call   801af8 <pageref>
  801578:	89 c3                	mov    %eax,%ebx
  80157a:	89 3c 24             	mov    %edi,(%esp)
  80157d:	e8 76 05 00 00       	call   801af8 <pageref>
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	39 c3                	cmp    %eax,%ebx
  801587:	0f 94 c1             	sete   %cl
  80158a:	0f b6 c9             	movzbl %cl,%ecx
  80158d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801590:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801596:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801599:	39 ce                	cmp    %ecx,%esi
  80159b:	74 1b                	je     8015b8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80159d:	39 c3                	cmp    %eax,%ebx
  80159f:	75 c4                	jne    801565 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015a1:	8b 42 58             	mov    0x58(%edx),%eax
  8015a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015a7:	50                   	push   %eax
  8015a8:	56                   	push   %esi
  8015a9:	68 12 22 80 00       	push   $0x802212
  8015ae:	e8 b5 eb ff ff       	call   800168 <cprintf>
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	eb ad                	jmp    801565 <_pipeisclosed+0xe>
	}
}
  8015b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015be:	5b                   	pop    %ebx
  8015bf:	5e                   	pop    %esi
  8015c0:	5f                   	pop    %edi
  8015c1:	5d                   	pop    %ebp
  8015c2:	c3                   	ret    

008015c3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	57                   	push   %edi
  8015c7:	56                   	push   %esi
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 28             	sub    $0x28,%esp
  8015cc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015cf:	56                   	push   %esi
  8015d0:	e8 1c f7 ff ff       	call   800cf1 <fd2data>
  8015d5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	bf 00 00 00 00       	mov    $0x0,%edi
  8015df:	eb 4b                	jmp    80162c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015e1:	89 da                	mov    %ebx,%edx
  8015e3:	89 f0                	mov    %esi,%eax
  8015e5:	e8 6d ff ff ff       	call   801557 <_pipeisclosed>
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	75 48                	jne    801636 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015ee:	e8 de f4 ff ff       	call   800ad1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015f3:	8b 43 04             	mov    0x4(%ebx),%eax
  8015f6:	8b 0b                	mov    (%ebx),%ecx
  8015f8:	8d 51 20             	lea    0x20(%ecx),%edx
  8015fb:	39 d0                	cmp    %edx,%eax
  8015fd:	73 e2                	jae    8015e1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8015ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801602:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801606:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801609:	89 c2                	mov    %eax,%edx
  80160b:	c1 fa 1f             	sar    $0x1f,%edx
  80160e:	89 d1                	mov    %edx,%ecx
  801610:	c1 e9 1b             	shr    $0x1b,%ecx
  801613:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801616:	83 e2 1f             	and    $0x1f,%edx
  801619:	29 ca                	sub    %ecx,%edx
  80161b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80161f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801623:	83 c0 01             	add    $0x1,%eax
  801626:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801629:	83 c7 01             	add    $0x1,%edi
  80162c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80162f:	75 c2                	jne    8015f3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801631:	8b 45 10             	mov    0x10(%ebp),%eax
  801634:	eb 05                	jmp    80163b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801636:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80163b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163e:	5b                   	pop    %ebx
  80163f:	5e                   	pop    %esi
  801640:	5f                   	pop    %edi
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    

00801643 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	57                   	push   %edi
  801647:	56                   	push   %esi
  801648:	53                   	push   %ebx
  801649:	83 ec 18             	sub    $0x18,%esp
  80164c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80164f:	57                   	push   %edi
  801650:	e8 9c f6 ff ff       	call   800cf1 <fd2data>
  801655:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165f:	eb 3d                	jmp    80169e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801661:	85 db                	test   %ebx,%ebx
  801663:	74 04                	je     801669 <devpipe_read+0x26>
				return i;
  801665:	89 d8                	mov    %ebx,%eax
  801667:	eb 44                	jmp    8016ad <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801669:	89 f2                	mov    %esi,%edx
  80166b:	89 f8                	mov    %edi,%eax
  80166d:	e8 e5 fe ff ff       	call   801557 <_pipeisclosed>
  801672:	85 c0                	test   %eax,%eax
  801674:	75 32                	jne    8016a8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801676:	e8 56 f4 ff ff       	call   800ad1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80167b:	8b 06                	mov    (%esi),%eax
  80167d:	3b 46 04             	cmp    0x4(%esi),%eax
  801680:	74 df                	je     801661 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801682:	99                   	cltd   
  801683:	c1 ea 1b             	shr    $0x1b,%edx
  801686:	01 d0                	add    %edx,%eax
  801688:	83 e0 1f             	and    $0x1f,%eax
  80168b:	29 d0                	sub    %edx,%eax
  80168d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801692:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801695:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801698:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80169b:	83 c3 01             	add    $0x1,%ebx
  80169e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016a1:	75 d8                	jne    80167b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8016a6:	eb 05                	jmp    8016ad <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016a8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b0:	5b                   	pop    %ebx
  8016b1:	5e                   	pop    %esi
  8016b2:	5f                   	pop    %edi
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	56                   	push   %esi
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c0:	50                   	push   %eax
  8016c1:	e8 42 f6 ff ff       	call   800d08 <fd_alloc>
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	89 c2                	mov    %eax,%edx
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	0f 88 2c 01 00 00    	js     8017ff <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016d3:	83 ec 04             	sub    $0x4,%esp
  8016d6:	68 07 04 00 00       	push   $0x407
  8016db:	ff 75 f4             	pushl  -0xc(%ebp)
  8016de:	6a 00                	push   $0x0
  8016e0:	e8 0b f4 ff ff       	call   800af0 <sys_page_alloc>
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	0f 88 0d 01 00 00    	js     8017ff <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016f2:	83 ec 0c             	sub    $0xc,%esp
  8016f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f8:	50                   	push   %eax
  8016f9:	e8 0a f6 ff ff       	call   800d08 <fd_alloc>
  8016fe:	89 c3                	mov    %eax,%ebx
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	85 c0                	test   %eax,%eax
  801705:	0f 88 e2 00 00 00    	js     8017ed <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80170b:	83 ec 04             	sub    $0x4,%esp
  80170e:	68 07 04 00 00       	push   $0x407
  801713:	ff 75 f0             	pushl  -0x10(%ebp)
  801716:	6a 00                	push   $0x0
  801718:	e8 d3 f3 ff ff       	call   800af0 <sys_page_alloc>
  80171d:	89 c3                	mov    %eax,%ebx
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	85 c0                	test   %eax,%eax
  801724:	0f 88 c3 00 00 00    	js     8017ed <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80172a:	83 ec 0c             	sub    $0xc,%esp
  80172d:	ff 75 f4             	pushl  -0xc(%ebp)
  801730:	e8 bc f5 ff ff       	call   800cf1 <fd2data>
  801735:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801737:	83 c4 0c             	add    $0xc,%esp
  80173a:	68 07 04 00 00       	push   $0x407
  80173f:	50                   	push   %eax
  801740:	6a 00                	push   $0x0
  801742:	e8 a9 f3 ff ff       	call   800af0 <sys_page_alloc>
  801747:	89 c3                	mov    %eax,%ebx
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	85 c0                	test   %eax,%eax
  80174e:	0f 88 89 00 00 00    	js     8017dd <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801754:	83 ec 0c             	sub    $0xc,%esp
  801757:	ff 75 f0             	pushl  -0x10(%ebp)
  80175a:	e8 92 f5 ff ff       	call   800cf1 <fd2data>
  80175f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801766:	50                   	push   %eax
  801767:	6a 00                	push   $0x0
  801769:	56                   	push   %esi
  80176a:	6a 00                	push   $0x0
  80176c:	e8 c2 f3 ff ff       	call   800b33 <sys_page_map>
  801771:	89 c3                	mov    %eax,%ebx
  801773:	83 c4 20             	add    $0x20,%esp
  801776:	85 c0                	test   %eax,%eax
  801778:	78 55                	js     8017cf <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80177a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801780:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801783:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801785:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801788:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80178f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801795:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801798:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80179a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017a4:	83 ec 0c             	sub    $0xc,%esp
  8017a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8017aa:	e8 32 f5 ff ff       	call   800ce1 <fd2num>
  8017af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017b4:	83 c4 04             	add    $0x4,%esp
  8017b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ba:	e8 22 f5 ff ff       	call   800ce1 <fd2num>
  8017bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017c5:	83 c4 10             	add    $0x10,%esp
  8017c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cd:	eb 30                	jmp    8017ff <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017cf:	83 ec 08             	sub    $0x8,%esp
  8017d2:	56                   	push   %esi
  8017d3:	6a 00                	push   $0x0
  8017d5:	e8 9b f3 ff ff       	call   800b75 <sys_page_unmap>
  8017da:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017dd:	83 ec 08             	sub    $0x8,%esp
  8017e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e3:	6a 00                	push   $0x0
  8017e5:	e8 8b f3 ff ff       	call   800b75 <sys_page_unmap>
  8017ea:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017ed:	83 ec 08             	sub    $0x8,%esp
  8017f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f3:	6a 00                	push   $0x0
  8017f5:	e8 7b f3 ff ff       	call   800b75 <sys_page_unmap>
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8017ff:	89 d0                	mov    %edx,%eax
  801801:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801804:	5b                   	pop    %ebx
  801805:	5e                   	pop    %esi
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    

00801808 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80180e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801811:	50                   	push   %eax
  801812:	ff 75 08             	pushl  0x8(%ebp)
  801815:	e8 3d f5 ff ff       	call   800d57 <fd_lookup>
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 18                	js     801839 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801821:	83 ec 0c             	sub    $0xc,%esp
  801824:	ff 75 f4             	pushl  -0xc(%ebp)
  801827:	e8 c5 f4 ff ff       	call   800cf1 <fd2data>
	return _pipeisclosed(fd, p);
  80182c:	89 c2                	mov    %eax,%edx
  80182e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801831:	e8 21 fd ff ff       	call   801557 <_pipeisclosed>
  801836:	83 c4 10             	add    $0x10,%esp
}
  801839:	c9                   	leave  
  80183a:	c3                   	ret    

0080183b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80183e:	b8 00 00 00 00       	mov    $0x0,%eax
  801843:	5d                   	pop    %ebp
  801844:	c3                   	ret    

00801845 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80184b:	68 2a 22 80 00       	push   $0x80222a
  801850:	ff 75 0c             	pushl  0xc(%ebp)
  801853:	e8 95 ee ff ff       	call   8006ed <strcpy>
	return 0;
}
  801858:	b8 00 00 00 00       	mov    $0x0,%eax
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	57                   	push   %edi
  801863:	56                   	push   %esi
  801864:	53                   	push   %ebx
  801865:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80186b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801870:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801876:	eb 2d                	jmp    8018a5 <devcons_write+0x46>
		m = n - tot;
  801878:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80187b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80187d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801880:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801885:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801888:	83 ec 04             	sub    $0x4,%esp
  80188b:	53                   	push   %ebx
  80188c:	03 45 0c             	add    0xc(%ebp),%eax
  80188f:	50                   	push   %eax
  801890:	57                   	push   %edi
  801891:	e8 e9 ef ff ff       	call   80087f <memmove>
		sys_cputs(buf, m);
  801896:	83 c4 08             	add    $0x8,%esp
  801899:	53                   	push   %ebx
  80189a:	57                   	push   %edi
  80189b:	e8 94 f1 ff ff       	call   800a34 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018a0:	01 de                	add    %ebx,%esi
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	89 f0                	mov    %esi,%eax
  8018a7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018aa:	72 cc                	jb     801878 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018af:	5b                   	pop    %ebx
  8018b0:	5e                   	pop    %esi
  8018b1:	5f                   	pop    %edi
  8018b2:	5d                   	pop    %ebp
  8018b3:	c3                   	ret    

008018b4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	83 ec 08             	sub    $0x8,%esp
  8018ba:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018c3:	74 2a                	je     8018ef <devcons_read+0x3b>
  8018c5:	eb 05                	jmp    8018cc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018c7:	e8 05 f2 ff ff       	call   800ad1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018cc:	e8 81 f1 ff ff       	call   800a52 <sys_cgetc>
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	74 f2                	je     8018c7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	78 16                	js     8018ef <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018d9:	83 f8 04             	cmp    $0x4,%eax
  8018dc:	74 0c                	je     8018ea <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e1:	88 02                	mov    %al,(%edx)
	return 1;
  8018e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8018e8:	eb 05                	jmp    8018ef <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018ea:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    

008018f1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fa:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8018fd:	6a 01                	push   $0x1
  8018ff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801902:	50                   	push   %eax
  801903:	e8 2c f1 ff ff       	call   800a34 <sys_cputs>
}
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	c9                   	leave  
  80190c:	c3                   	ret    

0080190d <getchar>:

int
getchar(void)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801913:	6a 01                	push   $0x1
  801915:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801918:	50                   	push   %eax
  801919:	6a 00                	push   $0x0
  80191b:	e8 9d f6 ff ff       	call   800fbd <read>
	if (r < 0)
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	85 c0                	test   %eax,%eax
  801925:	78 0f                	js     801936 <getchar+0x29>
		return r;
	if (r < 1)
  801927:	85 c0                	test   %eax,%eax
  801929:	7e 06                	jle    801931 <getchar+0x24>
		return -E_EOF;
	return c;
  80192b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80192f:	eb 05                	jmp    801936 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801931:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801936:	c9                   	leave  
  801937:	c3                   	ret    

00801938 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80193e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801941:	50                   	push   %eax
  801942:	ff 75 08             	pushl  0x8(%ebp)
  801945:	e8 0d f4 ff ff       	call   800d57 <fd_lookup>
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 11                	js     801962 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801951:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801954:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80195a:	39 10                	cmp    %edx,(%eax)
  80195c:	0f 94 c0             	sete   %al
  80195f:	0f b6 c0             	movzbl %al,%eax
}
  801962:	c9                   	leave  
  801963:	c3                   	ret    

00801964 <opencons>:

int
opencons(void)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80196a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196d:	50                   	push   %eax
  80196e:	e8 95 f3 ff ff       	call   800d08 <fd_alloc>
  801973:	83 c4 10             	add    $0x10,%esp
		return r;
  801976:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801978:	85 c0                	test   %eax,%eax
  80197a:	78 3e                	js     8019ba <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80197c:	83 ec 04             	sub    $0x4,%esp
  80197f:	68 07 04 00 00       	push   $0x407
  801984:	ff 75 f4             	pushl  -0xc(%ebp)
  801987:	6a 00                	push   $0x0
  801989:	e8 62 f1 ff ff       	call   800af0 <sys_page_alloc>
  80198e:	83 c4 10             	add    $0x10,%esp
		return r;
  801991:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801993:	85 c0                	test   %eax,%eax
  801995:	78 23                	js     8019ba <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801997:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80199d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019ac:	83 ec 0c             	sub    $0xc,%esp
  8019af:	50                   	push   %eax
  8019b0:	e8 2c f3 ff ff       	call   800ce1 <fd2num>
  8019b5:	89 c2                	mov    %eax,%edx
  8019b7:	83 c4 10             	add    $0x10,%esp
}
  8019ba:	89 d0                	mov    %edx,%eax
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    

008019be <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	56                   	push   %esi
  8019c2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019c3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019c6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019cc:	e8 e1 f0 ff ff       	call   800ab2 <sys_getenvid>
  8019d1:	83 ec 0c             	sub    $0xc,%esp
  8019d4:	ff 75 0c             	pushl  0xc(%ebp)
  8019d7:	ff 75 08             	pushl  0x8(%ebp)
  8019da:	56                   	push   %esi
  8019db:	50                   	push   %eax
  8019dc:	68 38 22 80 00       	push   $0x802238
  8019e1:	e8 82 e7 ff ff       	call   800168 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019e6:	83 c4 18             	add    $0x18,%esp
  8019e9:	53                   	push   %ebx
  8019ea:	ff 75 10             	pushl  0x10(%ebp)
  8019ed:	e8 25 e7 ff ff       	call   800117 <vcprintf>
	cprintf("\n");
  8019f2:	c7 04 24 23 22 80 00 	movl   $0x802223,(%esp)
  8019f9:	e8 6a e7 ff ff       	call   800168 <cprintf>
  8019fe:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a01:	cc                   	int3   
  801a02:	eb fd                	jmp    801a01 <_panic+0x43>

00801a04 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	56                   	push   %esi
  801a08:	53                   	push   %ebx
  801a09:	8b 75 08             	mov    0x8(%ebp),%esi
  801a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801a12:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801a14:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a19:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801a1c:	83 ec 0c             	sub    $0xc,%esp
  801a1f:	50                   	push   %eax
  801a20:	e8 7b f2 ff ff       	call   800ca0 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	85 f6                	test   %esi,%esi
  801a2a:	74 14                	je     801a40 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801a2c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a31:	85 c0                	test   %eax,%eax
  801a33:	78 09                	js     801a3e <ipc_recv+0x3a>
  801a35:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a3b:	8b 52 74             	mov    0x74(%edx),%edx
  801a3e:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a40:	85 db                	test   %ebx,%ebx
  801a42:	74 14                	je     801a58 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a44:	ba 00 00 00 00       	mov    $0x0,%edx
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	78 09                	js     801a56 <ipc_recv+0x52>
  801a4d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a53:	8b 52 78             	mov    0x78(%edx),%edx
  801a56:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 08                	js     801a64 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a61:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	57                   	push   %edi
  801a6f:	56                   	push   %esi
  801a70:	53                   	push   %ebx
  801a71:	83 ec 0c             	sub    $0xc,%esp
  801a74:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a77:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a7d:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a7f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a84:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a87:	ff 75 14             	pushl  0x14(%ebp)
  801a8a:	53                   	push   %ebx
  801a8b:	56                   	push   %esi
  801a8c:	57                   	push   %edi
  801a8d:	e8 eb f1 ff ff       	call   800c7d <sys_ipc_try_send>

		if (err < 0) {
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	85 c0                	test   %eax,%eax
  801a97:	79 1e                	jns    801ab7 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a99:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a9c:	75 07                	jne    801aa5 <ipc_send+0x3a>
				sys_yield();
  801a9e:	e8 2e f0 ff ff       	call   800ad1 <sys_yield>
  801aa3:	eb e2                	jmp    801a87 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801aa5:	50                   	push   %eax
  801aa6:	68 5c 22 80 00       	push   $0x80225c
  801aab:	6a 49                	push   $0x49
  801aad:	68 69 22 80 00       	push   $0x802269
  801ab2:	e8 07 ff ff ff       	call   8019be <_panic>
		}

	} while (err < 0);

}
  801ab7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aba:	5b                   	pop    %ebx
  801abb:	5e                   	pop    %esi
  801abc:	5f                   	pop    %edi
  801abd:	5d                   	pop    %ebp
  801abe:	c3                   	ret    

00801abf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aca:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801acd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad3:	8b 52 50             	mov    0x50(%edx),%edx
  801ad6:	39 ca                	cmp    %ecx,%edx
  801ad8:	75 0d                	jne    801ae7 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ada:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801add:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ae2:	8b 40 48             	mov    0x48(%eax),%eax
  801ae5:	eb 0f                	jmp    801af6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae7:	83 c0 01             	add    $0x1,%eax
  801aea:	3d 00 04 00 00       	cmp    $0x400,%eax
  801aef:	75 d9                	jne    801aca <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    

00801af8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afe:	89 d0                	mov    %edx,%eax
  801b00:	c1 e8 16             	shr    $0x16,%eax
  801b03:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b0a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0f:	f6 c1 01             	test   $0x1,%cl
  801b12:	74 1d                	je     801b31 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b14:	c1 ea 0c             	shr    $0xc,%edx
  801b17:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b1e:	f6 c2 01             	test   $0x1,%dl
  801b21:	74 0e                	je     801b31 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b23:	c1 ea 0c             	shr    $0xc,%edx
  801b26:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b2d:	ef 
  801b2e:	0f b7 c0             	movzwl %ax,%eax
}
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    
  801b33:	66 90                	xchg   %ax,%ax
  801b35:	66 90                	xchg   %ax,%ax
  801b37:	66 90                	xchg   %ax,%ax
  801b39:	66 90                	xchg   %ax,%ax
  801b3b:	66 90                	xchg   %ax,%ax
  801b3d:	66 90                	xchg   %ax,%ax
  801b3f:	90                   	nop

00801b40 <__udivdi3>:
  801b40:	55                   	push   %ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	83 ec 1c             	sub    $0x1c,%esp
  801b47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b57:	85 f6                	test   %esi,%esi
  801b59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b5d:	89 ca                	mov    %ecx,%edx
  801b5f:	89 f8                	mov    %edi,%eax
  801b61:	75 3d                	jne    801ba0 <__udivdi3+0x60>
  801b63:	39 cf                	cmp    %ecx,%edi
  801b65:	0f 87 c5 00 00 00    	ja     801c30 <__udivdi3+0xf0>
  801b6b:	85 ff                	test   %edi,%edi
  801b6d:	89 fd                	mov    %edi,%ebp
  801b6f:	75 0b                	jne    801b7c <__udivdi3+0x3c>
  801b71:	b8 01 00 00 00       	mov    $0x1,%eax
  801b76:	31 d2                	xor    %edx,%edx
  801b78:	f7 f7                	div    %edi
  801b7a:	89 c5                	mov    %eax,%ebp
  801b7c:	89 c8                	mov    %ecx,%eax
  801b7e:	31 d2                	xor    %edx,%edx
  801b80:	f7 f5                	div    %ebp
  801b82:	89 c1                	mov    %eax,%ecx
  801b84:	89 d8                	mov    %ebx,%eax
  801b86:	89 cf                	mov    %ecx,%edi
  801b88:	f7 f5                	div    %ebp
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	89 d8                	mov    %ebx,%eax
  801b8e:	89 fa                	mov    %edi,%edx
  801b90:	83 c4 1c             	add    $0x1c,%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    
  801b98:	90                   	nop
  801b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ba0:	39 ce                	cmp    %ecx,%esi
  801ba2:	77 74                	ja     801c18 <__udivdi3+0xd8>
  801ba4:	0f bd fe             	bsr    %esi,%edi
  801ba7:	83 f7 1f             	xor    $0x1f,%edi
  801baa:	0f 84 98 00 00 00    	je     801c48 <__udivdi3+0x108>
  801bb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bb5:	89 f9                	mov    %edi,%ecx
  801bb7:	89 c5                	mov    %eax,%ebp
  801bb9:	29 fb                	sub    %edi,%ebx
  801bbb:	d3 e6                	shl    %cl,%esi
  801bbd:	89 d9                	mov    %ebx,%ecx
  801bbf:	d3 ed                	shr    %cl,%ebp
  801bc1:	89 f9                	mov    %edi,%ecx
  801bc3:	d3 e0                	shl    %cl,%eax
  801bc5:	09 ee                	or     %ebp,%esi
  801bc7:	89 d9                	mov    %ebx,%ecx
  801bc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bcd:	89 d5                	mov    %edx,%ebp
  801bcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bd3:	d3 ed                	shr    %cl,%ebp
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	d3 e2                	shl    %cl,%edx
  801bd9:	89 d9                	mov    %ebx,%ecx
  801bdb:	d3 e8                	shr    %cl,%eax
  801bdd:	09 c2                	or     %eax,%edx
  801bdf:	89 d0                	mov    %edx,%eax
  801be1:	89 ea                	mov    %ebp,%edx
  801be3:	f7 f6                	div    %esi
  801be5:	89 d5                	mov    %edx,%ebp
  801be7:	89 c3                	mov    %eax,%ebx
  801be9:	f7 64 24 0c          	mull   0xc(%esp)
  801bed:	39 d5                	cmp    %edx,%ebp
  801bef:	72 10                	jb     801c01 <__udivdi3+0xc1>
  801bf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e6                	shl    %cl,%esi
  801bf9:	39 c6                	cmp    %eax,%esi
  801bfb:	73 07                	jae    801c04 <__udivdi3+0xc4>
  801bfd:	39 d5                	cmp    %edx,%ebp
  801bff:	75 03                	jne    801c04 <__udivdi3+0xc4>
  801c01:	83 eb 01             	sub    $0x1,%ebx
  801c04:	31 ff                	xor    %edi,%edi
  801c06:	89 d8                	mov    %ebx,%eax
  801c08:	89 fa                	mov    %edi,%edx
  801c0a:	83 c4 1c             	add    $0x1c,%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5f                   	pop    %edi
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    
  801c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c18:	31 ff                	xor    %edi,%edi
  801c1a:	31 db                	xor    %ebx,%ebx
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	90                   	nop
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	89 d8                	mov    %ebx,%eax
  801c32:	f7 f7                	div    %edi
  801c34:	31 ff                	xor    %edi,%edi
  801c36:	89 c3                	mov    %eax,%ebx
  801c38:	89 d8                	mov    %ebx,%eax
  801c3a:	89 fa                	mov    %edi,%edx
  801c3c:	83 c4 1c             	add    $0x1c,%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5f                   	pop    %edi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    
  801c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c48:	39 ce                	cmp    %ecx,%esi
  801c4a:	72 0c                	jb     801c58 <__udivdi3+0x118>
  801c4c:	31 db                	xor    %ebx,%ebx
  801c4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c52:	0f 87 34 ff ff ff    	ja     801b8c <__udivdi3+0x4c>
  801c58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c5d:	e9 2a ff ff ff       	jmp    801b8c <__udivdi3+0x4c>
  801c62:	66 90                	xchg   %ax,%ax
  801c64:	66 90                	xchg   %ax,%ax
  801c66:	66 90                	xchg   %ax,%ax
  801c68:	66 90                	xchg   %ax,%ax
  801c6a:	66 90                	xchg   %ax,%ax
  801c6c:	66 90                	xchg   %ax,%ax
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <__umoddi3>:
  801c70:	55                   	push   %ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 1c             	sub    $0x1c,%esp
  801c77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c87:	85 d2                	test   %edx,%edx
  801c89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c91:	89 f3                	mov    %esi,%ebx
  801c93:	89 3c 24             	mov    %edi,(%esp)
  801c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c9a:	75 1c                	jne    801cb8 <__umoddi3+0x48>
  801c9c:	39 f7                	cmp    %esi,%edi
  801c9e:	76 50                	jbe    801cf0 <__umoddi3+0x80>
  801ca0:	89 c8                	mov    %ecx,%eax
  801ca2:	89 f2                	mov    %esi,%edx
  801ca4:	f7 f7                	div    %edi
  801ca6:	89 d0                	mov    %edx,%eax
  801ca8:	31 d2                	xor    %edx,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	89 d0                	mov    %edx,%eax
  801cbc:	77 52                	ja     801d10 <__umoddi3+0xa0>
  801cbe:	0f bd ea             	bsr    %edx,%ebp
  801cc1:	83 f5 1f             	xor    $0x1f,%ebp
  801cc4:	75 5a                	jne    801d20 <__umoddi3+0xb0>
  801cc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cca:	0f 82 e0 00 00 00    	jb     801db0 <__umoddi3+0x140>
  801cd0:	39 0c 24             	cmp    %ecx,(%esp)
  801cd3:	0f 86 d7 00 00 00    	jbe    801db0 <__umoddi3+0x140>
  801cd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cdd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ce1:	83 c4 1c             	add    $0x1c,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5e                   	pop    %esi
  801ce6:	5f                   	pop    %edi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	85 ff                	test   %edi,%edi
  801cf2:	89 fd                	mov    %edi,%ebp
  801cf4:	75 0b                	jne    801d01 <__umoddi3+0x91>
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	f7 f7                	div    %edi
  801cff:	89 c5                	mov    %eax,%ebp
  801d01:	89 f0                	mov    %esi,%eax
  801d03:	31 d2                	xor    %edx,%edx
  801d05:	f7 f5                	div    %ebp
  801d07:	89 c8                	mov    %ecx,%eax
  801d09:	f7 f5                	div    %ebp
  801d0b:	89 d0                	mov    %edx,%eax
  801d0d:	eb 99                	jmp    801ca8 <__umoddi3+0x38>
  801d0f:	90                   	nop
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	83 c4 1c             	add    $0x1c,%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5f                   	pop    %edi
  801d1a:	5d                   	pop    %ebp
  801d1b:	c3                   	ret    
  801d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d20:	8b 34 24             	mov    (%esp),%esi
  801d23:	bf 20 00 00 00       	mov    $0x20,%edi
  801d28:	89 e9                	mov    %ebp,%ecx
  801d2a:	29 ef                	sub    %ebp,%edi
  801d2c:	d3 e0                	shl    %cl,%eax
  801d2e:	89 f9                	mov    %edi,%ecx
  801d30:	89 f2                	mov    %esi,%edx
  801d32:	d3 ea                	shr    %cl,%edx
  801d34:	89 e9                	mov    %ebp,%ecx
  801d36:	09 c2                	or     %eax,%edx
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	89 14 24             	mov    %edx,(%esp)
  801d3d:	89 f2                	mov    %esi,%edx
  801d3f:	d3 e2                	shl    %cl,%edx
  801d41:	89 f9                	mov    %edi,%ecx
  801d43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d4b:	d3 e8                	shr    %cl,%eax
  801d4d:	89 e9                	mov    %ebp,%ecx
  801d4f:	89 c6                	mov    %eax,%esi
  801d51:	d3 e3                	shl    %cl,%ebx
  801d53:	89 f9                	mov    %edi,%ecx
  801d55:	89 d0                	mov    %edx,%eax
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	09 d8                	or     %ebx,%eax
  801d5d:	89 d3                	mov    %edx,%ebx
  801d5f:	89 f2                	mov    %esi,%edx
  801d61:	f7 34 24             	divl   (%esp)
  801d64:	89 d6                	mov    %edx,%esi
  801d66:	d3 e3                	shl    %cl,%ebx
  801d68:	f7 64 24 04          	mull   0x4(%esp)
  801d6c:	39 d6                	cmp    %edx,%esi
  801d6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d72:	89 d1                	mov    %edx,%ecx
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	72 08                	jb     801d80 <__umoddi3+0x110>
  801d78:	75 11                	jne    801d8b <__umoddi3+0x11b>
  801d7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d7e:	73 0b                	jae    801d8b <__umoddi3+0x11b>
  801d80:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d84:	1b 14 24             	sbb    (%esp),%edx
  801d87:	89 d1                	mov    %edx,%ecx
  801d89:	89 c3                	mov    %eax,%ebx
  801d8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d8f:	29 da                	sub    %ebx,%edx
  801d91:	19 ce                	sbb    %ecx,%esi
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 f0                	mov    %esi,%eax
  801d97:	d3 e0                	shl    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	d3 ea                	shr    %cl,%edx
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	d3 ee                	shr    %cl,%esi
  801da1:	09 d0                	or     %edx,%eax
  801da3:	89 f2                	mov    %esi,%edx
  801da5:	83 c4 1c             	add    $0x1c,%esp
  801da8:	5b                   	pop    %ebx
  801da9:	5e                   	pop    %esi
  801daa:	5f                   	pop    %edi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    
  801dad:	8d 76 00             	lea    0x0(%esi),%esi
  801db0:	29 f9                	sub    %edi,%ecx
  801db2:	19 d6                	sbb    %edx,%esi
  801db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dbc:	e9 18 ff ff ff       	jmp    801cd9 <__umoddi3+0x69>
